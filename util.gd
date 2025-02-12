extends Node

class gen_transition_info:
	var next_row
	var next_state
	var cumulative_paths

## checker_state + next_row_number * 4096 + have_islands*65536 -> generator_state
static var gen_state_numbers: Dictionary[int, int] = {}

## Generator states.  These for a DFA that accepts all 8-row polyminoes.
## State 0 is used as both the unique start state and the unique accept state
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

## The byte representing a row of all water.  Note that this code counts
## 0-islands, not 1-islands
const ALL_WATER = 0xFF

func _ready() -> void:
	bitboard.wall_data = 49340209542762048
	expand_state("00000000", 0xFF)
	make_gen_state(0, 0, 0)
	print(gen_state_numbers.size())
	print(gen_states.size())
	print(state_numbers.size())
	print(transitions.size())
	
	

## Fill out a state in the generator table if it doesn't exist
## Return the state number
static func make_gen_state(next_row_number: int, checker_state: int, have_islands: int):
	var state_key: int = checker_state + next_row_number * 4096 + have_islands * 65536
	if gen_state_numbers.has(state_key):
		return gen_state_numbers[state_key]
	var new_gen_state: int = gen_states.size()
	gen_state_numbers[state_key] = new_gen_state
	var tlist: Array[gen_transition_info] = []
	gen_states.append(tlist)
	var transitions_offset: int = checker_state * 256
	var total_paths: int = 0
	for i in range(0, 256):
		var transition: int = transitions[transitions_offset + i]
		var next_checker_state: int = transition & 0x0FFF
		var new_inslands: int = (transition >> 12) + have_islands
		if new_inslands > (1 if ALL_WATER == i else 0):
			# we are destined to get too many islands this way.
			continue;
		if next_row_number == 7:
			# all transitions for row 7 have to to the accept state
			# calculate total number of islands
			new_inslands += transitions[next_checker_state * 256 + ALL_WATER] >> 12
			if new_inslands  == 1:
				total_paths += 1
				var new_gen: gen_transition_info = gen_transition_info.new()
				new_gen.next_row = i
				new_gen.next_state = 0
				new_gen.cumulative_paths = total_paths
				tlist.append(new_gen)
		else:
			var next_gen_state: int = make_gen_state(next_row_number + 1, next_checker_state, new_inslands)
			var new_paths: int = gen_states[next_gen_state][-1].cumulative_paths
			if new_paths > 0:
				total_paths += new_paths
				var new_gen: gen_transition_info = gen_transition_info.new()
				new_gen.next_row = i
				new_gen.next_state = next_gen_state
				new_gen.cumulative_paths = total_paths
				tlist.append(new_gen)
	return new_gen_state

func get_nth_polyomino(n: int) -> int:
	var state: int = 0
	var poly: int = 0
	for row in range(0, 8):
		var tlist = gen_states[state]
		#// binary search to find the transition that contains the nth path
		var hi: int = tlist.Size - 1
		var lo: int = 0
		while (hi > lo):
			var test: int = (lo + hi) >> 1
			if n >= tlist[test].cumulativePaths:
				lo = test + 1
			else:
				hi = test
		if lo > 0:
			n -= tlist[lo - 1].cumulativePaths
		var transition = tlist[lo]
		poly = (poly << 8) | transition.nextRow
		state = transition.nextState
	return poly

#
#
#
#
#
#
#

## Expands the specified state code.
## 
## A state code is a string of digits.
##  0 => water
##  x => island number x.  new islands are numbered from left to right

# <param name="stateCode">The state code to expand.</param>
# <param name="nextrow">the lower 8 bits represent the next row.  0-bits are land</param>
# <returns>The transition code for the transition from stateCode to nextrow</returns>
static func expand_state(state_code: String, next_row: int) -> int:
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
			cutoff_count += 1 # This was originally ++cutoffCount
	
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
	var new_state_code: String
	for _char in new_chars:
		new_state_code += char(_char)
	#string newStateCode = new string(newChars);
	
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
static func union(sets: Array[int], x: int, y: int) -> bool:
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


static func find(sets: Array[int], s: int) -> int:
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

#/// <summary>
#/// Gets the value of the bool at position (x, y)
#/// </summary>
#/// <param name="bitBoard">The bitboard to query.</param>
#/// <param name="col">The 0-indexed column value.</param>
#/// <param name="row">The 0-indexed row value.</param>
#/// <returns></returns>
#public static bool GetBitboardCell(ulong bitBoard, int col, int row)
#{
#
	#int bitPosition = row * 8 + col;
	#return (bitBoard & (1UL << bitPosition)) != 0;
#}
#
#
#
#
#/// <summary>
#/// 
#/// </summary>
#/// <param name="bitBoard"></param>
#/// <param name="invert"></param>
#public static void PrintBitboard(ulong bitBoard, bool invert = false)
#{
	#StringBuilder sb = new StringBuilder();
#
	#// Prints the puzzle ID so we always know which puzzle we are displaying
	#sb.Append(bitBoard + "\n");
#
	#for (int row = 0; row < 8; row++)
	#{
		#for (int col = 0; col < 8; col++)
		#{
			#if (invert == true)
			#{
				#if (GetBitboardCell(bitBoard, col, row) == true)
				#{
					#sb.Append("- ");
				#}
				#else
				#{
					#sb.Append("1 ");
				#}
			#}
			#else
			#{
				#if (GetBitboardCell(bitBoard, col, row) == true)
				#{
					#sb.Append("1 ");
				#}
				#else
				#{
					#sb.Append("- ");
				#}
			#}
		#}
		#sb.Append('\n');
	#}
	#GD.Print(sb.ToString());
		#}
	#}
#}
#
