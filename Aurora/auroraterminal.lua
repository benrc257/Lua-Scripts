print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem");
    os.sleep(0.05)
until (modem)
modemName = peripheral.getName(modem);
rednet.open(modemName)
print("\nWireless modem found. Opening...")

protocol = "aurora";

function search()
    local id = nil;
    local lookup = rednet.lookup(protocol);
    local destinations = {};
    local size = #lookup;
    if (type(lookup) == "table") then
        for i=1, size do
            rednet.send(lookup[i], true, protocol)
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
    oldSize, oldLookup, oldMessages = size, lookup, destinations;
    repeat
        local success, size, lookup, destinations = search();
        if (success) then
            if (size > oldSize) then
                return size, lookup, destinations;
            end
        else
            return 0, {false}, {false};
        end
        os.sleep(1)
    until (false);
end

function input()
    local keyOut = false;
    repeat
        local event, key = os.pullEvent("key_up");
        if (key == keys.up) then
            keyOut = "up";
        elseif (key == keys.down) then
            keyOut = "down";
        elseif (key == keys.enter)
            keyOut = "enter";
        end
        os.sleep(0.05)
    until (keyOut);
    return keyOut;
end

function printDisplay()
    local totalPages = math.ceil(size/18)
    local pageLength = {};
    for i=1, totalPages do
        if (i ~= totalPages) then
            pageLength[i] = 18;
        else
            pageLength[i] = size%18;
        end
    end
    term.setCursorBlink(false)
    term.setBackgroundColor(colors.black)   
    for i=1, pageLength[currentPage] do
        if (i == currentLine) then
            paintutils.setTextColor(colors.black)
        else
            term.setTextColor(colors.white)
        end
        term.setCursorPos(1, i)
        print(i .. " - " .. destinations[i+((pageLength-1)*19)])
    end
    term.setCursorPos(1, 19)
    print("Page " .. currentPage .. " of " .. totalPages)
end

function manageDisplay()
    currentPage, currentLine = 1, 1;
    printDisplay()

    
end

