tesseract = args[1];

protocolInt = "supply";
protcolExt = "mining"
label = "supplier";
print("\nHosting supply and mining rednet as commander...")
rednet.host(protocolInt, label)
rednet.host(protocolExt, label)
print("\nHosting Successful.")

print("\nScanning for turtles...")
repeat
    haulID = rednet.lookup(protocolInt, "haul"); -- storage turtle is named "haul"
until (haulID ~= nil);
print("\nHauler found.")

rednet.send(haulID, tesseract, protocol)

repeat
    local id, message = rednet.receive(protocolExt, 3);
    if (id ~= nil) then 
        if (message[1] == "full") then
            repeat 
                rednet.send(haulID, message, protocol)
                local id, message = rednet.receive(protocolInt, 3);
            until (message == "receivedFull"); -- send back "receivedFull" when receiving coords
        end
    end
until (message == "end");