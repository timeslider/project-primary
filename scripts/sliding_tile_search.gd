#extends Node
#
#class_name SlidingTileSearch
#
## State info structure
#class StateInfo:
	#var bitmask: int
	#var lowest_reachable_index: int
	#var is_on_stack: bool
	#var has_outflow: bool
	#
	#func _init(bm: int, lri: int, ios: bool, ho: bool):
		#bitmask = bm
		#lowest_reachable_index = lri
		#is_on_stack = ios
		#has_outflow = ho
#
## Pre-sized capacity for collections
#const CAPACITY = 32 * 63
#var state_index: Dictionary = {}
#var state_info: Array = []
#var unassigned_states: Array = []
#var starting_states: Array = []
#var walls: int = 0
#
## State context for iterative DFS
#class StateContext:
	#var state: int
	#var index: int
	#var children: Array
	#var next_child_index: int
	#
	#func _init(s: int, i: int, c: Array, nci: int):
		#state = s
		#index = i
		#children = c
		#next_child_index = nci
#
## Custom trailing zero count implementation
#func tzcnt(x: int) -> int:
	#if x == 0:
		#return 64
	#var count = 0
	#while (x & 1) == 0:
		#x = x >> 1
		#count += 1
	#return count
#
#func find_valid_starting_points(tile_count: int) -> int:
	## Reset data structures
	#state_index.clear()
	#state_info.clear()
	#starting_states.clear()
	#unassigned_states.clear()
	#
	## Generate initial and final states
	#var candidate: int = 0
	#var last: int = 0
	#for i in range(tile_count):
		#candidate |= 1 << i
		#last |= 1 << (63 - i)
	#
	#var next_index: int = 0
	#while true:
		#if (candidate & walls) == 0:
			#if not state_index.has(candidate):
				## Initialize new state info
				#var info = StateInfo.new(
					#candidate, 
					#next_index, 
					#true, 
					#false
				#)
				#state_index[candidate] = next_index
				#state_info.append(info)
				#unassigned_states.push_back(next_index)
				#next_index += 1
				#
				## Get reachable children
				#var children = find_reachable_children(candidate)
				#var dfs_stack: Array = []
				#dfs_stack.push_back(StateContext.new(
					#candidate, 
					#state_index[candidate], 
					#children, 
					#0
				#))
				#
				## Iterative DFS
				#while not dfs_stack.is_empty():
					#var current = dfs_stack.back()
					#
					#if current.next_child_index < current.children.size():
						#var child_state = current.children[current.next_child_index]
						#current.next_child_index += 1
						#
						#if state_index.has(child_state):
							#var child_idx = state_index[child_state]
							#var child_info = state_info[child_idx]
							#
							#if child_info.is_on_stack:
								## Update lowlink for back edge
								#var current_info = state_info[current.index]
								#if child_idx < current_info.lowest_reachable_index:
									#current_info.lowest_reachable_index = child_idx
									#state_info[current.index] = current_info
							#else:
								## Mark outflow for cross edge
								#var current_info = state_info[current.index]
								#current_info.has_outflow = true
								#state_info[current.index] = current_info
						#else:
							## Discover new state
							#var child_info = StateInfo.new(
								#child_state,
								#next_index,
								#true,
								#false
							#)
							#state_index[child_state] = next_index
							#state_info.append(child_info)
							#unassigned_states.push_back(next_index)
							#next_index += 1
							#
							## Process new state
							#var child_children = find_reachable_children(child_state)
							#dfs_stack.push_back(StateContext.new(
								#child_state,
								#state_index[child_state],
								#child_children,
								#0
							#))
					#else:
						## Finished processing children
						#dfs_stack.pop_back()
						#var current_info = state_info[current.index]
						#
						## Check for SCC root
						#if current_info.lowest_reachable_index == current.index:
							#var scc = null
							#if not current_info.has_outflow:
								#scc = []
							#
							## Pop SCC from stack
							#while true:
								#var pop_index = unassigned_states.pop_back()
								#var pop_info = state_info[pop_index]
								#pop_info.is_on_stack = false
								#pop_info.has_outflow = true
								#state_info[pop_index] = pop_info
								#
								#if scc != null:
									#scc.append(pop_info.bitmask)
								#
								#if pop_index == current.index:
									#break
							#
							#if scc != null:
								#starting_states.append(scc)
						#else:
							## Propagate lowlink to parent
							#if not dfs_stack.is_empty():
								#var parent = dfs_stack.back()
								#var parent_info = state_info[parent.index]
								#if current_info.lowest_reachable_index < parent_info.lowest_reachable_index:
									#parent_info.lowest_reachable_index = current_info.lowest_reachable_index
								#parent_info.has_outflow = parent_info.has_outflow or current_info.has_outflow
								#state_info[parent.index] = parent_info
		#
		#if candidate == last:
			#break
		#candidate = next_permutation(candidate)
	#
	## Log results
	#print("Checked %d states, found %d clusters" % [state_info.size(), starting_states.size()])
	#var total_state_count = 0
	#for group in starting_states:
		#var state_str = ""
		#for state in group:
			#total_state_count += 1
			#state_str += "\n"
			#var remaining = state
			#while remaining != 0:
				#var result = extract_lowest_bit(remaining)
				#remaining = result[0]
				#var x = result[1]
				#var y = result[2]
				#state_str += "(%d, %d) " % [x, y]
		#print("Cluster with %d states: %s" % [group.size(), state_str])
	#
	#return total_state_count
#
#func find_reachable_children(state: int) -> Array:
	#var children = []
	#var remaining = state
	#while remaining != 0:
		#var result = extract_lowest_bit(remaining)
		#remaining = result[0]
		#var bit = result[3]
		#var x = result[1]
		#var y = result[2]
		#
		## Other tiles stay in place
		#var other_state = state ^ bit
		## Walls and other tiles are obstacles
		#var obstacles = walls | other_state
		#
		## Try moving in each direction
		#var directions = [
			#{"shift": -1, "limit": x + 1, "step": 1},   # Right
			#{"shift": 1,  "limit": 8 - x, "step": 1},   # Left
			#{"shift": -8, "limit": y + 1, "step": 8},   # Down
			#{"shift": 8,  "limit": 8 - y, "step": 8}    # Up
		#]
		#
		#for dir in directions:
			#var i = 1
			#while i < dir["limit"]:
				#var shifted = bit
				## Apply shift while preserving 64-bit representation
				#if dir["shift"] > 0:
					#shifted = (bit << dir["shift"]) & 0xFFFF_FFFF_FFFF_FFFF
				#else:
					#shifted = bit >> abs(dir["shift"])
				#
				#if (shifted & obstacles) != 0:
					#break
				#
				#i += 1
			#
			#if i > 1:
				## Apply valid move
				#var valid_shift = dir["shift"] * (i - 1)
				#var moved_bit = bit
				#if valid_shift > 0:
					#moved_bit = (bit << valid_shift) & 0xFFFFFFFFFFFFFFFF
				#else:
					#moved_bit = bit >> abs(valid_shift)
				#children.append(other_state | moved_bit)
	#
	#return children
#
#func extract_lowest_bit(state: int) -> Array:
	#var zeros = tzcnt(state)
	#var x = zeros % 8
	#var y = zeros / 8
	#var bit = 1 << zeros
	#state &= ~bit  # Clear the lowest bit
	#return [state, x, y, bit]
#
#func next_permutation(state: int) -> int:
	#var v = state
	#var t = v | (v - 1)
	#var tz = tzcnt(v)
	#var part = (~t) & (t + 1)
	#var shifted = (part - 1) >> (tz + 1)
	#return (t + 1) | shifted
