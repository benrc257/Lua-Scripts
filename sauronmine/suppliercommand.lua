protocol = "mining";
label = "suppliercommand";
os.setComputerLabel(label)
print("\nComputer Label (\"suppliercommand\") successfully set and broadcasted. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

tesseract = {};
print("\nRequesting teserract coordinates...")
print("\nEnter the teserract X coordinate: ")
tesseract[1] = read();
print("\nEnter the teserract Y coordinate: ")
tesseract[2] = read();
print("\nEnter the teserract Z coordinate: ")
tesseract[3] = read();

function istable(t)
    return (type(t) == "table")
end

repeat
    supplierID = rednet.lookup(protocol, "supplier")
    os.sleep(0.05)
until (supplierID ~= nil);
message = {};
message[1] = "coords";
table.insert(message, tesseract[1])
table.insert(message, tesseract[2])
table.insert(message, tesseract[3])
rednet.send(supplierID, message, protocol)

queue = {};
count = 1;
lastSent = 1;
free = false;
repeat
    local id, received = rednet.receive(protocol, 10);
    if (id ~= nil and istable(received)) then
        if (received[1] == "full") then
            queue[count] = received;
            count = count+1;
        end
    elseif (id ~= nil and received == "supplier free") then
        free = true;
    end
    
    if (free and lastSent < count) then
        rednet.send(supplierID, queue[lastSent], protocol)
        lastSent = lastSent+1;
        free = false;
    end
until (false);

rednet.unhost(protocol)