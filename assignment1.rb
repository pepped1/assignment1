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

def neaten(hour, min)
	if min < 10
		min = "0" + min.to_s
	end
	if hour > 12
		hour -= 12
		handle = "PM"
	else
		handle = "AM"
	end
	if hour < 10
		hour = "0" + hour.to_s
	end
	time = hour.to_s + ":" + min.to_s + " " + handle
end

def arrayShift(array, pos)
	if pos.between?(0, array.length - 1)
		for i in (pos)..(array.length - 2)
			array[i] = array[i+1]
		end
		array.delete_at (array.length - 1)
		array
	else
		abort("ERROR: Tried to replace an element out of scope")
	end
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


print "Input the name of the file with data about availability of rooms on campus: "
file2 = gets.chomp
if File.file?(file2)
	schedTable = CSV.parse(File.read(file2), headers: true)
	puts file2 + " successfully read!"
else
	abort("ERROR: " + file2 + " does not exist!")
end


print "What date will HackTCNJ start? (yyyy-mm-dd): "
date = gets.chomp
Date.iso8601(date)
puts date

print "What time will HackTCNJ start? (hh:mm (24-hour clock)): "
timeGet = gets.chomp
timeSplit = timeGet.split(':')
if timeSplit.length() != 2
	abort("ERROR: Incorrect format entered")
end

startHour = timeSplit[0].to_i
startMin = 0
#obviously would be changed in full version

timeStart = neaten startHour, startMin

puts timeStart


print "How long will HackTCNJ run? (hh:mm): "
runGet = gets.chomp
runSplit = runGet.split(':')
if runSplit.length() != 2
	abort("ERROR: Incorrect format entered")
end

if runSplit[1].to_i > 29
	runTime = runSplit[0].to_i + 1
else
	runTime = runSplit[0].to_i
end
puts runTime


print "How many people will be attending? "
attendees = gets.chomp.to_i

#print "How many groups will there be? "
#groupNum = gets.chomp.to_i
#puts groupNum

#print "What is the maximum number of people in each group? "
#groupMax = gets.chomp.to_i
#puts groupMax

print "How many people will be in groups? "
groupCount = gets.chomp.to_i

#########################################

avail = []
finalSched = []
present = []

for i in roomsTable
	if i["Capacity"].to_i >= attendees
		#puts i["Capacity"]
		avail << i
	end
end

for i in 0..(avail.length - 1)
	j=0
	while j < schedTable.length
		if schedTable[j]["Date"] == date
			if schedTable[j]["Room"] == avail[i][1]
				if schedTable[j]["Building"] == avail[i][0]
					if schedTable[j]["Time"] == timeStart
						if schedTable[j]["Available"] == "true"
							temp = []
							temp << date
							temp << timeStart
							temp << schedTable[j]["Building"]
							temp << "Room " + schedTable[j]["Room"]
							temp << "Capacity: " + avail[i][2]
							temp << "Computers Available: " + avail[i][3]
							temp << "Food Allowed: " + avail[i][6]
							present << temp
						end
						break
					else
						j += 1
					end
				else
					j += 24
				end
			else
				j += 24
			end
		else
			j += 24
		end
	end			
end

puts present

#print "Which room do you want the opening ceremony in? (Enter the number next to the room)" 

