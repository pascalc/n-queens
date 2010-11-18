#!/usr/bin/env ruby

DEBUGGING = false

if ARGV.length != 1
	puts "Usage: ./nqueens.rb <n>"
	puts "Where n is the size of the board and number of queens."
	exit
end

N = ARGV[0].to_i

Queens = (0...N).to_a

Attackable = ([0]*(N-1)).zip((-(N-1))..-1) + 
			 ([0]*(N-1)).zip(1..(N-1)) +
			 ((-(N-1))..-1).zip([0]*(N-1)) +
			 (1..(N-1)).zip([0]*(N-1)) +
			 (1..(N-1)).zip(1..(N-1)) + 
			 (-(N-1)..-1).zip(-(N-1)..-1) + 
			 (1..(N-1)).zip(-1.downto -(N-1)) +
			 (-1.downto -(N-1)).zip(1..(N-1))

# Helper methods

def is_valid?(pos)
	(0...N).include? pos[0] and (0...N).include? pos[1]
end

def debug(str)
	puts str if DEBUGGING
end

# Forward checking

def infer(var,value,curr_domains)
	col = var
	row = value

	new_domains = curr_domains.dup

	Attackable.each do |v|
		square = [col + v[0], row + v[1]]
		if is_valid? square
			if new_domains[square[0]].include? square[1]
				debug "\tRemoving #{square[1]} from domain(#{square[0]}): #{new_domains[square[0]]}"
				new_domains[square[0]] = new_domains[square[0]] - [square[1]]
			end
			return nil if new_domains[square[0]].empty?
		end
	end

	return new_domains
end	

# Unassigned variable selection heuristic

def select_unassigned_variable(assignment,domains)
	# Random
	return (Queens - assignment.keys).shuffle.first
end

# Backtracking search

def backtrack(curr_assignment,curr_domains)
	return curr_assignment if curr_assignment.size == N
	var = select_unassigned_variable(curr_assignment,curr_domains)
	debug "Considering queen #{var}:"
	
	curr_domains[var].each do |value|
		# Add value to assignment
		new_assignment = curr_assignment.dup
		new_assignment[var] = value
		debug "\tAdded Q#{var} = #{value} to assignment => #{new_assignment}"
		# carry out forward checking
		new_domains = infer(var,value,curr_domains)
		if not new_domains.nil?
			debug "\tAfter inference, new domains are: #{new_domains}"
			result = backtrack(new_assignment,new_domains)
			if not result.nil?
				return result
			end
		else
			debug "\tFAILURE"
		end
	end

	return nil	
end

initial_domains = {}
Queens.each { |q| initial_domains[q] = (0...N).to_a }

puts "-"*70
puts "Solving the #{N}-queens problem..."
puts "-"*70

t_start = Time.now
solution = backtrack({},initial_domains)
t_taken = (Time.now - t_start).round(2)

if not solution.nil?
	puts "-"*70
	puts "Solution: #{solution}"
	puts "Found a solution in #{t_taken} seconds"
	puts "-"*70

	N.times do |row|
		N.times do |col|
			if solution[col] == row
				print "X "
			else
				print "0 "
			end
		end
		puts
	end
else
	puts "-"*70
	puts "Failed to find a solution in #{t_taken} seconds"
	puts "-"*70
end
