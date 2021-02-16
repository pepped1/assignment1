#!/usr/bin/ruby
require 'csv'

# Deam Peppe
# CSC415-01
# Assignment 1

# used to sort rooms.csv
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

# takes integers for time and returns a string that matches time in schedule.csv
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
	if hour == 0
		hour = 12
	end
	if hour < 10
		hour = "0" + hour.to_s
	end
	time = hour.to_s + ":" + min.to_s + " " + handle
end

# increments the time (only hours in this state)
def timeInc(hour)
	hour += 1
	if hour == 24
		hour = 0
	end
	hour
end

# increments the days (no support for months/years)
def dayInc(date)
	dateSplit = date.split('-')
	day = dateSplit[2].to_i + 1
	date = dateSplit[0] + "-" + dateSplit[1] + "-" + day.to_s
end	

# these two blocks handle the file input
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
Date.iso8601(date) # throws an error when not in the correct format

print "What time will HackTCNJ start? (hh:mm (24-hour clock)): "
timeGet = gets.chomp
timeSplit = timeGet.split(':')
if (timeSplit.length != 2) || (timeSplit[0].to_i > 24) || !(timeSplit[1].to_i.between?(0,59))
	abort("ERROR: Incorrect format entered")
end

startHour = timeSplit[0].to_i
startMin = 0 # program cannot handle minutes other than zero


print "How long will HackTCNJ run? (hh:mm): "
runGet = gets.chomp
runSplit = runGet.split(':')
if (runSplit.length != 2) || !(runSplit[1].to_i.between?(0,59))
	abort("ERROR: Incorrect format entered")
end

# rounds to the hour (since minutes are not handled)
if runSplit[1].to_i > 29
	runTime = runSplit[0].to_i + 1
else
	runTime = runSplit[0].to_i
end


print "How many people will be attending? "
attendees = gets.chomp.to_i

if attendees <= 0
	abort("ERROR: Invalid number of attendees entered. Must be above zero.")
end


print "How many people will be in groups? "
groupCount = gets.chomp.to_i
if !groupCount.between?(0,attendees)
	abort("ERROR: Invalid number of group members entered.")
end
indCount = attendees - groupCount
hungryCount = (attendees * 0.6).ceil
compCount = (attendees * 0.1).ceil


finalSched = []

for i in 0..(runTime)
	avail = [] #array of rooms that have the space
	present = [] #array of rooms that have the space and are open
	fill = false #flag used with ceremonies
	msg = "" #message used later
	snackTime = false #flag used to tell the program its time to eat
	roomFlag = false #flag used for ceremony rooms
	timeStart = neaten startHour, startMin #time in readable string format

	if (i % 6 == 3) && (runTime >= 6)
		snackTime = true
	end

	if i == 0
		fill = true
		msg = "Which room do you want to reserve for the opening ceremony? "
	elsif i == runTime
		fill = true
		msg = "Which room do you want to reserve for the closing ceremony? "
	elsif snackTime
		roomFlag = true #not a ceremony time
		msg = "Which rooms do you want to reserve for HackTCNJ and for eating? "
	else
		roomFlag = true
		msg = "Which rooms do you want to reserve for HackTCNJ? "
	end

	for j in roomsTable
		if fill #if a ceremony is next, it looks for rooms that can fit everyone
			if j["Capacity"].to_i >= attendees
				avail << j
			end
		else 
			if snackTime # looks for rooms that can fit people eating
				if j["Capacity"].to_i >= hungryCount && j["Food Allowed"] == "Yes"
					avail << j
				end
			end
			if j["Capacity"].to_i >= compCount && j["Computers Available"] == "Yes" #looks for rooms that can fit people that need computers
				avail << j
			elsif j["Priority"] == "Computer Science" #the rest of the rooms
				avail << j
			end
		end
	end
	totalRoom = 0
	totalFood = 0
	totalComp = 0
	for k in 0..(avail.length - 1)
		j=0
		#checks for the right line in schedule.csv and sees if the slot is open
		while j < schedTable.length
			if schedTable[j]["Date"] == date
				if schedTable[j]["Room"] == avail[k][1]
					if schedTable[j]["Building"] == avail[k][0]
						if schedTable[j]["Time"] == timeStart
							if schedTable[j]["Available"] == "true"
								#if the slot is open, it writes down its details to be shown to the user
								temp = []
								temp << date
								temp << timeStart
								temp << schedTable[j]["Building"]
								temp << "Room " + schedTable[j]["Room"]
								temp << "Capacity: " + avail[k][2]
								temp << "Computers Available: " + avail[k][3]
								temp << "Food Allowed: " + avail[k][6]
								if fill
									roomFlag = true
								elsif snackTime && avail[k][6] == "Yes"
									totalFood += avail[k][2].to_i
								elsif avail[k][3] == "Yes"
									totalComp += avail[k][2].to_i
								end
								totalRoom += avail[k][2].to_i
								puts totalRoom
								present << temp
							end
							break
						else
							j += 1 #incs by 1 to find the right hour
						end
					else
						j += 24 #incs by 24 to skip to the right day
					end
				else
					j += 24
				end
			else
				j += 24
			end
		end			
	end
	#throws an error if the schedule cannot fit with schedule.csv
	if (!roomFlag && fill) || (snackTime && totalFood < hungryCount) || (!fill && (totalComp < compCount || totalRoom < attendees))
		abort("ERROR: Not enough room available for everyone with the given schedule!")
	end
	
	#for printing to the user
	for k in 0..(present.length - 1)
		puts (k + 1).to_s + "."
		puts present[k]
	end
	#msg being used
	print msg
	if fill
		print "(Enter one of the numbers above the dates) "
	else
		print "(Enter the number(s) above the dates seperate by commas) "
	end
	input = gets.chomp
	inputSplit = input.split(',')
	for k in 0..(inputSplit.length - 1)
		if inputSplit[k].to_i <= present.length
			finalSched << present[inputSplit[k].to_i - 1]
		end
	end

	startHour = timeInc startHour
	if startHour == 0
		date = dayInc date
	end
end

print "Schedule complete! What do you want to name the schedule file? "
fileDone = gets.chomp
File.new(fileDone, "w+")
File.open(fileDone, "w+") do |k|
	k.puts(finalSched)
end

puts fileDone + " created!"
