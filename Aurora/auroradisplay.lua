print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem");
    os.sleep(0.05)
until (modem)
modemName = peripheral.getName(modem);
rednet.open(modemName)
print("\nWireless modem found. Opening...")

protocol = "aurora"; 
label = "Aurora";
os.setComputerLabel(label)
print("\nComputer Label (\"" .. label .. "\") successfully set. Hosting aurora rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

print("\nSearching for monitor...")
repeat -- opening monitor
    monitor = peripheral.find("monitor");
    os.sleep(0.05)
until (monitor ~= nil);
print("\nCreating monitor interface...")
width, height = monitor.getSize()
monitor.setBackgroundColor(colors.black)
monitor.clear()
monitor.setTextScale(.5)
marginH = math.floor(height/2);


function hubUpdate()
    local hubTotal = 0
    local hubID = {}
    local destination = {}
    print("\nSearching for hubs...")
    repeat
        hubTotal = hubTotal+1;
        local lookup =  rednet.lookup(protocol, "Hub " .. destination);
        if (lookup ~= nil) then
            print("\nHub " .. hubTotal .. " found.")
            hubID[hubTotal] = lookup
        end
        os.sleep(0.05)
    until (lookup == nil);
    hubTotal = hubTotal-1;
    print("\nRequesting destination names...")
    for i=1, hubTotal do
        local id = nil;
        rednet.send(hubID[i], "requesting") -- sends "requesting" when asking for destination names
        repeat
            id, destination[i] = rednet.receive(protocol)
            os.sleep(0.05)
        until (id == hubID[i])
        print("\nHub " .. i .. ": " .. destination[i])
    end
    return hubTotal, hubID, destination;
end

hubTotal, hubID, destination = hubUpdate()

function monitoring()
    monitor.clear()
    old = term.redirect(monitor)
        print("" .. destination[currentDestination])
    term.redirect(old)
    os.pullEvent("monitor_touch")
    print("\nInput Detected")
    if (currentDestination == hubTotal) then
        currentDestination = 1;
    else
        currentDestination = currentDestination+1;
    end
end

function getHubUpdate()
    local oldHubTotal, oldHubID, oldDestination = hubTotal, hubID, destination;
    local newHubTotal, newHubID, newDestination = nil;
    repeat
        local changed = false;
        newHubTotal, newHubID, newDestination = hubUpdate();
        if (newHubTotal == oldHubTotal) then
            for i=1, newHubTotal do
                if (newHubID[i] ~= oldHubID[i]) then
                    changed = true;
                elseif (newDestination[i] ~= oldDestination[i]) then
                    changed = true;
                end
            end
        else
            changed = true;
        end
        os.sleep(0.05)
    until (changed == true)
    hubTotal, hubID, destination = hubUpdate();
end

currentDestination = 1;
repeat
    parallel.waitForAny(monitoring, getHubUpdate)
    rednet.broadcast(currentDestination, protocol)
    os.sleep(0.05)
until false;
