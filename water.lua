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
    message = ("Dredging broadcast starting " .. textutils.formatTime(os.time()))
    rednet.broadcast(message, "mining")
else
    hasModem = false;
    print("\nNo wireless modem found.")
end

print("\nDredging is starting...");
sleep(3);

function detectWater()
    local present, block = turtle.inspectDown();
    if (present) then if (block.name == "minecraft:water") then if (block.state.level <= 2) then return true end end
    else return false end
end

slot = 16;
function detectSlot()
    turtle.select(slot)
    if (turtle.getItemCount(slot) == 0 and slot ~= 2) then
        slot = slot-1;
        turtle.select(slot)
    elseif (turtle.getItemCount(slot) == 0 and slot == 2) then
        repeat sleep(1) until (turtle.getItemCount(slot) > 0)
    end
end


trackerD = 0; --initalizes depth tracker to 1
repeat --whole script
    local trackerL = 0; --reinitalizes length tracker to 0
    local facingEast = facingEast --facingEast is used to determine which way the robot is facing at the start

    if (turtle.getFuelLevel() < ((fuelNeed*4)/Depth)) then --turtle refuels if fuelLevel is less than fuelNeed
        local refuelCount = 0;
        turtle.select(1)
        repeat
            turtle.refuel()
            refuelCount = refuelCount+1;
            if (refuelCount > 100) then
                if (hasModem) then rednet.broadcast("Error(fuel needed), mining paused! " .. textutils.formatTime(os.time()), "mining") end
                sleep(10)
            end
        until (turtle.getFuelLevel() >= ((fuelNeed*4)/Depth)); --turtle will not proceed until fuel is provided
        turtle.select(slot)
    end

    if (turtle.getItemCount(2) < 64) then
        repeat
            if (hasModem) then rednet.broadcast("Error(low inventory), dredging paused! " .. textutils.formatTime(os.time()), "mining") end
            sleep(5)
        until (turtle.getItemCount(2) == 64);
    end
    turtle.select(slot)

    repeat --length segment
        local trackerW = 1; --reinitalizes width tracker to 1
        repeat -- width segment
            detectSlot()
            if (detectWater()) then
                turtle.placeDown()
            end
            repeat turtle.dig() until turtle.forward(); --digs until it can move forward
            trackerW = trackerW+1; --increments width tracker
        until (trackerW > Width-1);
        detectSlot()
        if (detectWater()) then
            turtle.placeDown()
        end
        trackerL = trackerL+1; --increments length tracker
        if (facingEast and trackerL < Length) then --facing east handling if length not reached
            turtle.turnRight()
            turtle.dig()
            turtle.forward()
            turtle.turnRight()
            detectSlot()
            if (detectWater()) then
                turtle.placeDown()
            end
            facingEast = false;
        elseif (trackerL < Length) then
            turtle.turnLeft()
            turtle.dig()
            detectSlot()
            turtle.forward()
            turtle.turnLeft()
            detectSlot()
            if (detectWater()) then
                turtle.placeDown()
            end
            facingEast = true;
        end
    until (trackerL >= Length);
    
    detectSlot()
    if (detectWater()) then
        turtle.placeDown()
    end

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

    detectSlot()
    if (detectWater()) then
        turtle.placeDown()
    end

    repeat turtle.digDown() until turtle.down(); --keeps digging beneath until it can move down
    trackerD = trackerD+1; --increments depth tracker
until (trackerD >= Depth);

print("\nDredging completed!")
if (hasModem) then rednet.broadcast("Event(dredging complete), dredging completed! " .. textutils.formatTime(os.time()), "mining") end