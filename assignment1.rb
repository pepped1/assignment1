#!/usr/bin/env ruby
require 'csv'

# Dean Peppe
# CSC415-01
# Assignment 1 Resubmission

Percent_attendees_eating = 0.6
Percent_attendees_no_computer = 0.1
One_hour_meal_interval = 6

# used to sort rooms.csv
def rooms_sort(array)
    for i in 0..array.length - 1 do
        j = i
        while (j > 0) && (array[j-1][2].to_i > array[j][2].to_i)  
            array[j], array[j-1] = array[j-1], array[j]
            j-=1
        end
    end
    array
end

# formats the integer given for hour
def formatHour(hour)
	if hour == 0
		hour = "12"
	elsif hour < 10
		hour = "0" + hour.to_s
	else
		hour = hour.to_s
	end
end

# formats the integer given for minutes
def formatMin(min)
	if min < 10
		min = "0" + min.to_s
	else
		min = min.to_s
	end
end

# takes integers for time and returns a string that matches the times in schedule.csv
def formatTime(hour, min)
	if hour > 12
		hour -= 12
		handle = "PM"
	else
		handle = "AM"
	end
	hourReal = formatHour hour
	minReal = formatMin min
	time = hourReal + ":" + minReal + " " + handle
end

# increments the time (only hours in this state)
def incrementHour(hour)
	hour += 1
	if hour == 24
		hour = 0
	end
	hour
end

# increments the days (no support for months/years)
def incrementDay(date)
	dateSplit = date.split('-')
	day = dateSplit[2].to_i + 1
	date = dateSplit[0] + "-" + dateSplit[1] + "-" + day.to_s
end	

# checks the validity of the input for reserving rooms
def roomReserveCheck(array, oneRoomFlag, numberOfOptions)
	error = false
	if array.length == 0 # option to not reserve anything
		error = false
	elsif oneRoomFlag # must only choose one room
		if array.length == 1 && array[0].to_i.between?(1,numberOfOptions)
			error = false
		else
			error = true
		end
	else
		for j in array # can choose multiple rooms
			if !(j.to_i.between?(1,numberOfOptions)) 
				# if any of the elements entered are not between 1 and the number of options given
				# an error has occurred
				error = true
				break
			end
		end
	end
	error
end


# ***** program starts here *****


# these two blocks handle the file input
print "Input the name of the file with data about rooms on campus: "
begin
	file1 = gets.chomp
	roomsTable = CSV.parse(File.read(file1), headers: true)
	if roomsTable
		puts file1 + " successfully read!"
	end
rescue
	puts "ERROR: " + file1 + " does not exist!"
	retry
end

print "Input the name of the file with data about availability of rooms on campus: "
begin
	file2 = gets.chomp
	schedTable = CSV.parse(File.read(file2), headers: true)
	if schedTable
		puts file2 + " successfully read!"
	end
rescue
	puts "ERROR: " + file2 + " does not exist!"
	retry
end

# requests start date
print "What date will HackTCNJ start? (yyyy-mm-dd): "
begin
	date = gets.chomp
	Date.iso8601(date) # throws an error when not in correct format
rescue
	puts "ERROR: Invalid date entered!"
	retry
end

# requests time start
print "What time will HackTCNJ start? (hh:mm (24-hour clock)): "
while true
	timeGet = gets.chomp
	timeSplit = timeGet.split(':')
	if (timeSplit.length != 2) || !(timeSplit[0].to_i.between?(0,23)) || !(timeSplit[1].to_i.between?(0,59))
		puts "ERROR: Incorrect time entered!"
	else
		break
	end
end

startHour = timeSplit[0].to_i
startMin = 0 # program does not process times with minutes other than zero


print "How long will HackTCNJ run? (hh:mm): "
while true
	runGet = gets.chomp
	runSplit = runGet.split(':')
	if (runSplit.length != 2) || (runSplit[0].to_i < 1) || !(runSplit[1].to_i.between?(0,59))
		puts "ERROR: Incorrect format entered!"
	else
		break
	end
end

# rounds to the hour (since minutes are not handled)
if runSplit[1].to_i > 29
	runTime = runSplit[0].to_i + 1
else
	runTime = runSplit[0].to_i
end


print "How many people will be attending? "
while true
	attendees = gets.chomp.to_i
	if attendees <= 0
		puts "ERROR: Invalid number of attendees entered! Must be above zero."
	else
		break
	end
end


print "How many people will be in groups? "
while true
	groupCount = gets.chomp.to_i
	if !groupCount.between?(0,attendees)
		puts "ERROR: Invalid number of group members entered!"
	else
		break
	end
end
indCount = attendees - groupCount
hungryCount = (attendees * Percent_attendees_eating).ceil
compCount = (attendees * Percent_attendees_no_computer).ceil

finalSchedule = []

for i in 0..(runTime)
	availableRooms = [] # array of rooms that have the space
	presentableRooms = [] # array of rooms that have the space and are open
	fitAllFlag = false # flag used with ceremonies
	roomPrompt = "" # variable used in a prompt later
	snackTime = false # flag used to tell the program its time to eat
	roomFlag = false # flag used for ceremony rooms
	timeStart = formatTime startHour, startMin # time in readable string format

	if (i % One_hour_meal_interval == (One_hour_meal_interval / 2)) && (runTime >= One_hour_meal_interval)
		snackTime = true
	end

	if i == 0
		fitAllFlag = true
		roomPrompt = "Which room do you want to reserve for the opening ceremony? "
	elsif i == runTime
		fitAllFlag = true
		roomPrompt = "Which room do you want to reserve for the closing ceremony? "
	elsif snackTime
		roomFlag = true # not a ceremony time
		roomPrompt = "Which rooms do you want to reserve for HackTCNJ and for eating? "
	else
		roomFlag = true
		roomPrompt = "Which rooms do you want to reserve for HackTCNJ? "
	end

	for j in roomsTable
		if fitAllFlag # if a ceremony is next, it looks for rooms that can fit everyone
			if j["Capacity"].to_i >= attendees
				availableRooms << j
			end
		else 
			if snackTime # looks for rooms that can fit people eating
				if j["Capacity"].to_i >= hungryCount && j["Food Allowed"] == "Yes"
					availableRooms << j
				end
			end
			if j["Capacity"].to_i >= compCount && j["Computers Available"] == "Yes" #looks for rooms that can fit people that need computers
				availableRooms << j
			elsif j["Priority"] == "Computer Science" # the rest of the rooms
				availableRooms << j
			end
		end
	end
	totalRoom = 0
	totalFood = 0
	totalComp = 0
	for k in 0..(availableRooms.length - 1)
		j=0
		# checks for the right line in schedule.csv and sees if the slot is open
		while j < schedTable.length
			if schedTable[j]["Date"] == date
				if schedTable[j]["Room"] == availableRooms[k][1]
					if schedTable[j]["Building"] == availableRooms[k][0]
						if schedTable[j]["Time"] == timeStart
							if schedTable[j]["Available"] == "true"
								# if the slot is open, it writes down its details to be shown to the user
								roomOutput = [] # temp variable used to assemble output in the required format
								roomOutput << date
								roomOutput << timeStart
								roomOutput << schedTable[j]["Building"]
								roomOutput << "Room " + schedTable[j]["Room"]
								roomOutput << "Capacity: " + availableRooms[k][2]
								roomOutput << "Computers Available: " + availableRooms[k][3]
								roomOutput << "Food Allowed: " + availableRooms[k][6]
								if fitAllFlag
									roomFlag = true
								elsif snackTime && availableRooms[k][6] == "Yes"
									totalFood += availableRooms[k][2].to_i
								elsif availableRooms[k][3] == "Yes"
									totalComp += availableRooms[k][2].to_i
								end
								totalRoom += availableRooms[k][2].to_i
								presentableRooms << roomOutput
							end
							break
						else
							j += 1 # incs by 1 to find the right hour
						end
					else
						j += 24 # incs by 24 to skip to the right day
					end
				else
					j += 24
				end
			else
				j += 24
			end
		end			
	end
	# throws an error if the schedule cannot fit with schedule.csv
	if (!roomFlag && fitAllFlag) || (snackTime && totalFood < hungryCount) || (!fitAllFlag && (totalComp < compCount || totalRoom < attendees))
		abort("ERROR: Not enough room available for everyone with the given schedule!")
	end
	
	# for printing to the user
	for k in 0..(presentableRooms.length - 1)
		puts (k + 1).to_s + "."
		puts presentableRooms[k]
		puts
	end

	# message being used
	print roomPrompt
	if fitAllFlag
		print "(Enter one of the numbers above the dates "
	else
		print "(Enter the number(s) above the dates seperate by commas "
	end

	print "or hit Enter to not reserve anything for this hour) "

	while true
		input = gets.chomp
		inputSplit = input.split(',')
		if roomReserveCheck inputSplit, fitAllFlag, presentableRooms.length
			puts "ERROR: Incorrect format entered!"
		else
			break
		end
	end
	for k in 0..(inputSplit.length - 1)
		if inputSplit[k].to_i <= presentableRooms.length
			finalSchedule << presentableRooms[inputSplit[k].to_i - 1]
			finalSchedule << " "
		end
	end

	startHour = incrementHour startHour
	if startHour == 0
		date = incrementDay date
	end
end

print "Schedule complete! What do you want to name the schedule file? "
fileDone = gets.chomp
File.new(fileDone, "w+")
File.open(fileDone, "w+") do |k|
	k.puts(finalSchedule)
end

puts fileDone + " created!"
