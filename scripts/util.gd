@icon("res://icon.svg")
extends Node

## This class is mainly used for getting the nth polynominal

#region signals
## Is emitting when get_nth_polyomino is finished

#signal got_nth_polyomino
#endregion

#region enums
#endregion

#region constants
## The byte representing a row of all water.  Note that this code counts
## 0-islands, not 1-islands
const ALL_WATER = 0xFF
#endregion

#region static variables
## checker_state + next_row_number * 4096 + have_islands*65536 -> generator_state
static var gen_state_numbers: Dictionary[int, int] = {}

## Generator states.  These for a DFA that accepts all 8-row polyminoes.
## State 0 is used as both the unique start state and the unique accept state
# NOTE: If nested arrays ever become a thing, use Array[Array[GenTransitionInfo]]
static var gen_states: Array = []
## Map from the long-form state code for each state to the state number
## see expandState.
## 
## This is only used during state table construction.

static var state_numbers: Dictionary[String, int] = {}

## Packed map from (state*256 + next_row_byte) -> transition
## 
## transition is next_state + (island_count<<12), where island_count is the
## number of islands cut off from the further rows
static var transitions: Array = []
#endregion

#region @export variables
#endregion

#region remaining regular variables
#endregion

#region @onready variables
#endregion

#region _static_init()
#endregion

#region static methods

#func save_gen_states(file_path: String, gen_states: Array):
	#var file = FileAccess.open(file_path, FileAccess.WRITE)
	#if not file:
		#print("Error opening file for writing")
		#return
	#file
	## First write the number of states (outer array size)
	#file.store_32(gen_states.size())
	#
	## For each state's transition list
	#for tlist in gen_states:
		## Write number of transitions in this state
		#file.store_8(tlist.size())
		## Write each transition
		#for state in tlist:
			#file.store_8(state.next_row)
			#file.store_16(state.next_state)
			#file.store_64(state.cumulative_paths)
	#
	#file.close()
	#print("Saved gen_states successfully.")


## Loads the gen states
# TODO: The file path can probably be hard coded since it's a resource.
func load_gen_states_v1() -> void:
	# Prevents loading twice
	#if gen_states.size() > 0:
		##printerr("You shouldn't be loading this again. 😥")
		#return

	var file = FileAccess.open("res://gen_states.bin", FileAccess.READ)
	if not file:
		printerr("Error opening file for reading")
		return

	var _gen_states: Array = []
	
	# Read number of states
	var state_count = file.get_16()

	# For each state
	for _i in range(state_count):
		var tlist: Array[GenTransitionInfo] = []
		# Read number of transitions in this state
		var transition_count = file.get_16()
		# Read each transition
		for _j in range(transition_count):
			var _next_row = file.get_8()
			var _next_state = file.get_16()
			var _cumulative_paths = file.get_64()
			tlist.append(GenTransitionInfo.new(_next_row, _next_state, _cumulative_paths))
		_gen_states.append(tlist)

	
	file.close()
	gen_states = _gen_states


func load_gen_states_v2_async() -> void:
	var thread = Thread.new()
	thread.start(load_gen_states_v2)

## Loads the gen states
# TODO: The file path can probably be hard coded since it's a resource.
func load_gen_states_v2() -> void:
	# Prevents loading twice
	#if gen_states.size() > 0:
		##printerr("You shouldn't be loading this again. 😥")
		#return
	
	var file = FileAccess.open("res://gen_states.bin", FileAccess.READ)
	if not file:
		printerr("Error opening file for reading")
		return

	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
	
	var pos: int = 0
	var _gen_states: Array = []
	
	# Read number of states
	var state_count: int = buffer.decode_u16(pos)
	pos += 2

	# For each state
	for _i: int in range(state_count):
		var tlist: Array[GenTransitionInfo] = []
		# Read number of transitions in this state
		var transition_count = buffer.decode_u16(pos)
		pos += 2
		# Read each transition
		for _j: int in range(transition_count):
			tlist.append(GenTransitionInfo.new(buffer[pos], buffer.decode_u16(pos + 1), buffer.decode_u64(pos + 3)))
			pos += 11
		_gen_states.append(tlist)
	gen_states = _gen_states


func load_gen_states_resource() -> Array:
	var resource = load("res://gen_states.tres") as GenStateResource
	if resource:
		return resource.gen_states
	else:
		printerr("Failed to load gen state resource")
		return []


## Fill out a state in the generator table if it doesn't exist
## Return the state number
func make_gen_state(next_row_number: int, checker_state: int, have_islands: int):
	var state_key: int = checker_state + next_row_number * 4096 + have_islands * 65536
	if gen_state_numbers.has(state_key):
		return gen_state_numbers[state_key]
	var new_gen_state: int = gen_states.size()
	gen_state_numbers[state_key] = new_gen_state
	var tlist: Array[GenTransitionInfo] = []
	gen_states.append(tlist)
	var transitions_offset: int = checker_state * 256
	var total_paths: int = 0
	for i in range(0, 256):
		var transition: int = transitions[transitions_offset + i]
		var next_checker_state: int = transition & 0x0FFF
		var new_inlands: int = (transition >> 12) + have_islands
		if new_inlands > (1 if i == ALL_WATER else 0):
			# we are destined to get too many islands this way.
			continue;
		if next_row_number == 7:
			# all transitions for row 7 have to to the accept state
			# calculate total number of islands
			new_inlands += transitions[next_checker_state * 256 + ALL_WATER] >> 12
			if new_inlands  == 1:
				total_paths += 1
				var new_gen: GenTransitionInfo = GenTransitionInfo.new()
				new_gen.next_row = i
				new_gen.next_state = 0
				new_gen.cumulative_paths = total_paths
				tlist.append(new_gen)
		else:
			var next_gen_state: int = make_gen_state(next_row_number + 1, next_checker_state, new_inlands)
			var new_paths: int = gen_states[next_gen_state][-1].cumulative_paths
			if new_paths > 0:
				total_paths += new_paths
				var new_gen: GenTransitionInfo = GenTransitionInfo.new()
				new_gen.next_row = i
				new_gen.next_state = next_gen_state
				new_gen.cumulative_paths = total_paths
				tlist.append(new_gen)
	return new_gen_state


## Give a index, returns the polyomino in the range (0, 51_016_818_604_894_742)
# Code using this should make sure it doesn't use an input larger than 51_016_818_604_894_742
func get_nth_polyomino(index: int) -> int:
	var state: int = 0
	var poly: int = 0
	for row in range(0, 8):
		var tlist: Array[GenTransitionInfo] = gen_states[state]
		#// binary search to find the transition that contains the nth path
		var hi: int = tlist.size() - 1
		var lo: int = 0
		while lo < hi:
			var test: int = (lo + hi) >> 1
			if index >= tlist[test].cumulative_paths:
				lo = test + 1
			else:
				hi = test
		if lo > 0:
			index -= tlist[lo - 1].cumulative_paths
		var transition = tlist[lo]
		poly = (poly << 8) | transition.next_row
		state = transition.next_state
	return poly


## Inverts get_nth_poly. Given a poly, give the index
func get_n_value(polyomino: int) -> int:
	var state: int = 0
	var n: int = 0 # TODO Rename to index
	
	for row in range(8):
		var current_row: int = ((polyomino >> ((7 - row) * 8)) & 0xFF)
		var tlist: Array = gen_states[state]
		
		#var transition_index: int = tlist.FindIndex()
		var transition_index: int = tlist.find_custom(func(t): return t.next_row == current_row)
		
		if transition_index < 0:
			printerr("Invalid polyomino")
		
		if transition_index > 0:
			n += tlist[transition_index - 1].cumulative_paths
		
		state = tlist[transition_index].next_state
	
	return n


## Expands the specified state code.
## 
## A state code is a string of digits.
##  0 => water
##  x => island number x.  new islands are numbered from left to right

# <param name="stateCode">The state code to expand.</param>
# <param name="nextrow">the lower 8 bits represent the next row.  0-bits are land</param>
# <returns>The transition code for the transition from stateCode to nextrow</returns>
func expand_state(state_code: String, next_row: int) -> int:
	var sets: Array[int] = []
	#sets.resize(8) This is not be necessary
	#int[] sets = new int[8];
	for i in range(0, 8):
		sets.append((~next_row >> i) & 1)
	for i in range(0, 7):
		if ((~next_row >> i) & 3) == 3:
			union(sets, i, i + 1)
	# map from state code island to first attached set in sets
	var links: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1]
	var top_island_count: int = 0
	for i in range(0, 8):
		# The unicode at function should return the ascii value. If not, we'll need another solution
		var digit: int = state_code.unicode_at(i)
		var top_island: int = digit - 49 # 49 = '1' in ascii
		top_island_count = max(top_island_count, top_island + 1)
		
		if sets[i] != 0 and top_island >= 0:
			var bottom_set: int = links[top_island]
			if bottom_set < 0:
				links[top_island] = i
			else:
				union(sets, bottom_set, i)
	var cutoff_count: int = 0
	for i in range(0, top_island_count):
		if links[i] < 0:
			cutoff_count += 1
	
	var next_set: int = 49
	#char nextSet = '1';
	var new_chars: Array[int] = [48, 48, 48, 48, 48, 48, 48, 48]
	
	links = [-1, -1, -1, -1, -1, -1, -1, -1]
	
	for i in range(0, 8):
		if sets[i] != 0:
			var _set: int = find(sets, i)
			var link: int = links[_set]
			if link >= 0:
				new_chars[i] = new_chars[link]
			else:
				new_chars[i] = next_set
				next_set += 1
				links[_set] = i
	var new_state_code: String = ""
	for _char in new_chars:
		new_state_code += char(_char)
	
	if state_numbers.has(new_state_code):
		return state_numbers[new_state_code] | (cutoff_count << 12)
	
	var new_state: int = state_numbers.size()
	state_numbers[new_state_code] = new_state
	
	while transitions.size() <= (new_state + 1) * 256:
		transitions.append(0)
	for i in range(256):
		transitions[new_state * 256 + i] = expand_state(new_state_code, i)
	return new_state | (cutoff_count << 12)



## union by size
func union(sets: Array[int], x: int, y: int) -> bool:
	x = find(sets, x)
	y = find(sets, y)
	if x == y:
		return false
	
	var size_x: int = sets[x]
	var size_y: int = sets[y]
	if size_x < size_y:
		sets[y] += size_x
		sets[x] = ~y
	else:
		sets[x] += size_y
		sets[y] = ~x
	return true;


func find(sets: Array[int], s: int) -> int:
	var parent: int = sets[s]
	if parent > 0:
		return s
	elif parent < 0:
		parent = find(sets, ~parent)
		sets[s] = ~parent
		return parent
	else:
		sets[s] = 1
		return s
#endregion

#region _init()
#endregion

#region _enter_tree()
#endregion

#region _ready()
func _ready() -> void:
	#expand_state("00000000", 0xFF)
	#make_gen_state(0, 0, 0)
	#measure_function_time(load_gen_states, 1, ["res://gen_states.bin"])
	
	# Used to create gen state resource
	#load_gen_states_new("res://gen_states.bin")
	#if gen_states != null:
		#print(gen_states[0])
	#var resource = GenStateResource.new(gen_states)
	#ResourceSaver.save(resource, "res://gen_states.tres")
	#print(gen_states.size())
	
	load_gen_states_v2()
	
	#var count: int = 0
	#for tlist in gen_states:
		#count += tlist.size()
	#
	#print("There are ", count, " tlist.")
	#
	#print("The 100th polyomino is: ", get_nth_polyomino(100))
	pass
#endregion

#region _process()
#endregion

#region _physics_process()
#endregion

#region remaining virtual methods
#endregion

#region overridden custom methods
#endregion

#region methods
func measure_function_time(function_to_measure: Callable, iterations: int = 1, parameters: Array = []) -> void:
	var total_time: float = 0
	var times: Array = []
	
	for i in range(iterations):
		var start_time: int = 0
		
		# Call the function with parameters if provided
		if parameters.is_empty():
			start_time = Time.get_ticks_usec()
			function_to_measure.call()
		else:
			start_time = Time.get_ticks_usec()
			function_to_measure.callv(parameters)
	
		var end_time = Time.get_ticks_usec()
		var elapsed_time = (end_time - start_time)
	
		times.append(elapsed_time)
		total_time += elapsed_time
	
	# Calculate statistics
	var average_time = total_time / iterations
	var min_time = times.min()
	var max_time = times.max()
	print({
		"total_time": total_time,
		"average_time": average_time,
		"min_time": min_time,
		"max_time": max_time,
		"iterations": iterations,
		"all_times": times
	})
#endregion

#region subclasses
class GenTransitionInfo:
	@export var next_row: int
	@export var next_state: int
	@export var cumulative_paths: int


	func _init(_next_row = 0, _next_state = 0, _cumulative_paths = 0):
		next_row = _next_row
		next_state = _next_state
		cumulative_paths = _cumulative_paths
#endregion
