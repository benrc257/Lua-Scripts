protocol = "supply";
label = "tank";
print("\nHosting supply rednet as tank...")
rednet.host(protocol, label)
print("\nHosting Successful.")

function triangulate()
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

function refuel(x, y, z)
    if (turtle.getFuelLevel <= 3000) then
        turtle.select(1)
        turtle.refuel()
    end
end

repeat