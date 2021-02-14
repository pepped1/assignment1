#!/usr/bin/ruby
require 'csv'

def rooms_sort(array)
 	(array.length).times do |i|
		while i > 0
			if array[i-1][2].to_i > array[i][2].to_i
				array[i], array[i-1] = array[i-1], array[i]
			else
				break
			end
			i-=1
		end
	end
	array
end

#########################################

print "Input the name of the file with data about rooms on campus: "
file1 = gets.chomp
if File.file?(file1)
	roomsTable = CSV.parse(File.read(file1), headers: true)
	puts file1 + " successfully read!"
	rooms_sort roomsTable
else
	abort("ERROR: " + file1 + " does not exist!")
end

=begin

print "Input the name of the file with data about availability of rooms on campus: "
file2 = gets.chomp
if File.file?(file2)
	schedTable = CSV.parse(File.read(file2), headers: true)
	puts file2 + " successfully read!"
else
	abort("ERROR: " + file2 + " does not exist!")
end

print "What date will HackTCNJ be held? (yyyy-mm-dd): "
date = gets.chomp
Date.iso8601(date)
dateSplit = date.split('-')
for i in dateSplit
	puts i.to_i
end

print "What time will HackTCNJ start? (hh:mm (24-hour clock)): "
timeStart = gets.chomp
timeSplit = timeStart.split(':')
if timeSplit.length() != 2
	abort("ERROR: Incorrect format entered")
end
for i in timeSplit
	puts i.to_i
end

print "How long will HackTCNJ run? (hh:mm): "
runTime = gets.chomp
runSplit = runTime.split(':')
if runSplit.length() != 2
	abort("ERROR: Incorrect format entered")
end
for i in runSplit
	puts i.to_i
end

print "How many people will be attending? "
attendees = gets.chomp.to_i
puts attendees

print "How many groups will there be? "
groupNum = gets.chomp.to_i
puts groupNum

print "What is the maximum number of people in each group? "
groupMax = gets.chomp.to_i
puts groupMax

print "How many people will be in groups? "
groupCount = gets.chomp.to_i
puts groupCount
=end

#########################################

for i in roomsTable
	


