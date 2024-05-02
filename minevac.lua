print("Please enter Length (East-West):")
Length = tonumber(read());

print("Please enter Width (North-South):")
Width = tonumber(read());

print("Please enter Depth:")
Depth = tonumber(read());

print("Is the robot facing East or West? (E or W):")
EoW = read();
if (EoW == 'E' or EoW == 'e') then facingEast = true else facingEast = false end

fuelNeed = ((Length*Width*Depth)/4);
print("This turtle will need a total amount of fuel equal to a burn time of: ", fuelNeed)
print("Please insert fuel now, then press enter.\r")
read();

print("Scanning for wireless modems...")
if (peripheral.find("modem")) then
    modem = {peripheral.find("modem", rednet.open)}
    hasModem = true;
    print("\nWireless modem found. Opening...")
    message = ("Mining broadcast starting " .. textutils.formatTime(os.time()))
    rednet.broadcast(message, "mining")
else
    hasModem = false;
    print("\nNo wireless modem found.")
end

print("\nMining is starting...");
sleep(3);

trackerD = 0; --initalizes depth tracker to 1
repeat --whole script
    local trackerL = 0; --reinitalizes length tracker to 0
    local facingEast = facingEast --facingEast is used to determine which way the robot is facing at the start

    local slot = 1
    if (turtle.getFuelLevel() < ((fuelNeed*4)/Depth)) then --turtle refuels if fuelLevel is less than fuelNeed
        local refuelCount = 0;
        repeat
            turtle.refuel()
            refuelCount = refuelCount+1;
            if (refuelCount > 100) then
                if (hasModem) then rednet.broadcast("Error(fuel needed), mining paused! " .. textutils.formatTime(os.time()), "mining") end
                sleep(10)
            end
        until (turtle.getFuelLevel() >= ((fuelNeed*4)/Depth)); --turtle will not proceed until fuel is provided
    end

    
    slot = 2
    repeat
        turtle.select(slot)
        turtle.dropDown()
        slot = slot+1
    until (slot > 16);
    slot = 2
    

    repeat --length segment
        local trackerW = 1; --reinitalizes width tracker to 1
        repeat -- width segment
            repeat turtle.dig() until turtle.forward(); --digs until it can move forward
            trackerW = trackerW+1; --increments width tracker
        until (trackerW > Width-1);
        trackerL = trackerL+1; --increments length tracker
        if (facingEast and trackerL < Length) then --facing east handling if length not reached
            turtle.turnRight()
            turtle.dig()
            turtle.forward()
            turtle.turnRight()
            facingEast = false;
        elseif (trackerL < Length) then
            turtle.turnLeft()
            turtle.dig()
            turtle.forward()
            turtle.turnLeft()
            facingEast = true;
        end
    until (trackerL >= Length);
    
    if (facingEast) then --returns the bot to square 1 (facing East)
        turtle.turnLeft()
        for i=1, Length-1 do turtle.forward() end
        turtle.turnRight()
        for i=1, Width-1 do turtle.back() end
    else --returns the bot to square 1 (facing West)
        turtle.turnRight()
        for i=1, Length-1 do turtle.forward() end
        turtle.turnRight()
    end

    repeat turtle.digDown() until turtle.down(); --keeps digging beneath until it can move down
    trackerD = trackerD+1; --increments depth tracker
until (trackerD >= Depth);

print("\nMining completed!")
if (hasModem) then rednet.broadcast("Event(mining complete), mining completed! " .. textutils.formatTime(os.time()), "mining") end