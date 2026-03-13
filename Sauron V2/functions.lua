local function rednetInit(label)  -- Opens rednet on the computer and returns the modem peripheral
    local modems = peripheral.find("modem", rednet.open);
    if 
    print("\nWireless modem found. Opening...")
    os.setComputerLabel(label)
    print("\nComputer Label (".. label ..") successfully set and broadcasted.")
    return {modems}
end

local function rednetHost(protocol, label) -- Hosts rednet under the given label and protocol, making the pc visible upon lookup
    print("\nHosting " .. protocol .. " rednet under the name " .. label .. "...")
    rednet.host(protocol, label)
    print("\nHosting Successful.")
end

local function monitorInit() -- Sets up monitor and readies it for use

    --finding monitor
    print("\nCreating monitor interface...")
    local monitor = peripheral.find("monitor");
    local monitor = monitor[#monitor]

    --settings
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.setTextScale(1.5)

    --clear screen
    monitor.clear();

    --calculating size and margins
    local monitorWidth, monitorHeight = monitor.getSize();
    local resolution = monitorWidth*monitorHeight;
    local marginWidth = (monitorWidth / 20);
    local marginHeight = (monitorHeight / 20);

    print("\nMonitor online.")
    return {monitor, monitorWidth, monitorHeight, resolution, marginWidth, marginHeight}
end

local function isTable(t) -- checks if t is a table, returns bool
    return (type(t) == "table")
end

local function updateTurtles(turtleProtocol, turtles, turtlesIdle) -- searches for turtles and returns a list

    -- finds list of turtles
    turtles = rednet.lookup(turtleProtocol);
        
    -- initializes idleTurtles to false
    turtlesIdle = {}
    for i=1, #turtles do 
        turtlesIdle.append(false)
    end

    -- pings idle turtles and creates a list
    rednet.broadcast("idlecheck", turtleProtocol)

    -- checking pings
    local pingIDs = {}
    do -- receive pings and add them to the list
        local id = nil
        local message = nil
        id, message = rednet.receive(turtleProtocol, 1)
        if (message == "idle") then -- if idle message was received add it to the list
            pingIDs.append(id)
        end
    while end 

    -- update idle turtle status
    for i=1, #pingIDs do
        for j=1, #turtles do
            if (pingIDs[i] == turtles[j]) then
                turtlesIdle[j] = true
            end
        end
    end

    print("\n" .. #turtles .. " turtles found.")
    return {turtles, turtlesIdle}
end

local function openOperationFile() -- opens the last file and checks if it was completed, otherwise it creates a new one
    local file = nil
    local previousOperation = false
    if (fs.exists("sauron/mining/") == false) then
        fs.makeDir("sauron/mining/")
        if (fs.exists("sauron/mining/operation.txt") == false) then
            
        else
            previousOperation = true
        end
    else

    end

    return {file, previousOperation}
end


-- function list to return
return {
    rednetInit = rednetInit,
    rednetHost = rednetHost,
    monitorInit = monitorInit,
    isTable = isTable,
    updateTurtles = updateTurtles,
    openOperationFile = openOperationFile
}