storage = args[1];

protocolInt = "supply";
protcolExt = "mining"
label = "fueler";
print("\nHosting supply and mining rednet as commander...")
rednet.host(protocolInt, label)
rednet.host(protocolExt, label)
print("\nHosting Successful.")

print("\nScanning for turtles...")
repeat
    tankID = rednet.lookup(protocolInt, "tank"); -- fuel turtle is named "tank"
until (tankID ~= nil);
print("\nTank found.")

rednet.send(tankID, storage, protocol)

messages = []
repeat
    local id, message = rednet.receive(protocolExt, 3);
    if (id ~= nil) then 
        if (message[1] == "fuel") then
            
        end
    end
    repeat 
        rednet.send(tankID, message, protocol)
        local id, message = rednet.receive(protocolInt, 3);
    until (message == "receivedFuel"); -- send back "receivedFuel" when receiving coords
until (message == "end");