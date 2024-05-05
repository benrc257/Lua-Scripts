protocol = "supply";
label = "haul";
print("\nHosting supply rednet as hauler...")
rednet.host(protocol, label)
print("\nHosting Successful.")

function triangulate()
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

function refuel(x, y, z)
    if (turtle.getFuelLevel <= 2000) then
        turtle.select(1)
        if (turtle.refuel(0)) then
            turtle.drop()
            local message = []
            message[1] = "fuel";
            table.insert(message, x)
            table.insert(message, y)
            table.insert(message, z)
            local supplyID = nil;
            repeat
                supplyID = rednet.lookup(protocol, "fueler")
            until (supplyID);
            rednet.send(supplyID, message, protocol)

            repeat
                time.sleep(1)
            until (turtle.getItemCount());
        end
        turtle.refuel()
    end
end