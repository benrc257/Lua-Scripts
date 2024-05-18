print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem");
    os.sleep(0.05)
until (modem)
modemName = peripheral.getName(modem);
rednet.open(modemName)
print("\nWireless modem found. Opening...")

print("\nSearching for file named \"station.txt\" with this station's turtle ID...")
file = fs.open("station.txt", "r")
if (not file) then
    print("\nFile \"station.txt\" could not be opened. Returning...")
    return;
end
print("\nFile opened. Reading...")
stationID = tonumber(file.readLine())

if (not stationID) then
    print("\nFile \"station.txt\" is empty. Returning...")
    return;
end
print("\nTurtle ID found. Closing file...")
file.close()

protocol = "aurora";

function search()
    local id = nil;
    local lookup = {rednet.lookup(protocol)};
    local destinations = {};
    local size = #lookup;
    if (type(lookup) == "table") then
        for i=1, size do
            rednet.send(lookup[i], "request", protocol)
            repeat
                id, destinations[i] = rednet.receive(protocol, 5)
            until (id == lookup[i])
        end
        return true, size, lookup, destinations;
    else
        return false, 0, {false}, {false};
    end
end

function update()
    local oldSize, oldLookup, oldMessages = size, lookup, destinations;
    repeat
        local success, newSize, newLookup, newDestinations = search();
        if (success) then
            if (size > oldSize) then
                size, lookup, destinations = newSize, newLookup, newDestinations;
                return;
            end
        else
            size, lookup, destinations = 0, {false}, {false};
            return;
        end
        os.sleep(1)
    until (false);
end

function input()
    keyOut = false;
    repeat
        local event, key = os.pullEvent("key_up");
        if (key == keys.up) then
            keyOut = "up";
        elseif (key == keys.down) then
            keyOut = "down";
        elseif (key == keys.enter) then
            keyOut = "enter";
        elseif (key == keys.left) then
            keyOut = "left";
        elseif (key == keys.right) then
            keyOut = "right";
        elseif (key == keys.f5) then
            keyOut = "refresh";
        end
        os.sleep(0.05)
    until (keyOut);
end

function printPage()
    currentLine = 1;
    term.setBackgroundColor(colors.black)   
    term.clear()
    term.setCursorBlink(false)
    for i=1, pageLength[currentPage] do
        if (i == currentLine) then
            term.setBackgroundColor(colors.white) 
            term.setTextColor(colors.black)
        else
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        end
        term.setCursorPos(1, i)
        print((i+((currentPage-1)*17)) .. " - " .. destinations[i+((currentPage-1)*17)])
    end
    term.setCursorPos(1, 18)
    print("Page " .. currentPage .. " of " .. totalPages)
end

function nextLine(line)
    term.setCursorPos(1, currentLine)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clearLine()
    print((currentLine+((currentPage-1)*17)) .. " - " .. destinations[currentLine+((currentPage-1)*17)])
    currentLine = currentLine+line;
    term.setCursorPos(1, currentLine)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.clearLine()
    print((currentLine+((currentPage-1)*17)) .. " - " .. destinations[currentLine+((currentPage-1)*17)])
end

function warp(destinationID)
    rednet.send(stationID, "warp", protocol)
    os.sleep(2)
    rednet.send(destinationID, "warp", protocol)
end

success, size, lookup, destinations = search();
currentPage = 1;
totalPages = math.ceil(size/17)
pageLength = {};
for i=1, totalPages do
    if (i ~= totalPages) then
        pageLength[i] = 17;
    else
        pageLength[i] = size%17;
    end
end
printPage()

repeat
    parallel.waitForAny(input, update)
    if (keyOut) then
        if (keyOut == "up") then
            if (currentLine > (1+((currentPage-1)*17))) then
                nextLine(-1)
            end
        elseif (keyOut == "down") then
            if (currentLine < pageLength[currentPage]) then
                nextLine(1)
            end
        elseif (keyOut == "enter") then
            warp(lookup[currentLine + ((currentPage-1)*17)]);
            currentPage = 1;
            printPage();
        elseif (keyOut == "left") then
            if (currentPage > 1) then
                currentPage = currentPage-1;
                printPage();
            end
        elseif (keyOut == "right") then
            if (currentPage < totalPages) then
                currentPage = currentPage+1;
                printPage();
            end
        else -- refresh
            success, size, lookup, destinations = search();
            currentPage = 1;
            totalPages = math.ceil(size/17)
            pageLength = {};
            for i=1, totalPages do
                if (i ~= totalPages) then
                    pageLength[i] = 17;
                else
                    pageLength[i] = size%17;
                end
            end
            printPage();
        end
    else
        currentPage = 1;
        totalPages = math.ceil(size/17)
        pageLength = {};
        for i=1, totalPages do
            if (i ~= totalPages) then
                pageLength[i] = 17;
            else
                pageLength[i] = size%17;
            end
        end
        printPage();
    end
    os.sleep(0.05)
until false;