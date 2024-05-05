protocol = "mining";
label = "tankercommand";
os.setComputerLabel(label)
print("\nComputer Label (\"tankercommand\") successfully set and broadcasted. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

storage = [];
print("\nRequesting fuel storage coordinates...")
print("\nEnter the fuel storage X coordinate: ")
storage[1] = read();
print("\nEnter the fuel storage Y coordinate: ")
storage[2] = read();
print("\nEnter the fuel storage Z coordinate: ")
storage[3] = read();

repeat
    tankerID = rednet.lookup(protocol, "tanker")
until (tankerID ~= nil);
message = [];
message[1] = "coords";
table.insert(message, storage[1])
table.insert(message, storage[2])
table.insert(message, storage[3])
rednet.send(tankerID, message, protocol)

queue = [];
count = 1;
lastSent = 1;
free = false;
repeat
    local id, received = rednet.receive(protocol, 10);
    if (id ~= nil and istable(received)) then
        if (received[1] == "fuel") then
            queue[count] = received;
            count = count+1;
        end
    elseif (received == "tanker free") then
        free = true;
    end
    
    if (free and lastSent < count) then
        rednet.send(tankerID, queue[lastSent], protocol)
        lastSent = lastSent+1;
        free = false;
    end
until (received == "end")