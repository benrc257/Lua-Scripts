-- libs
func = require("turtlefunctions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "MinionMiner")

repeat
    print("\nTriangulating position...")
    x, y, z = func.triangulate() 
    print("\nPosition found.")

    print("\nWaiting for coordinates...")
    repeat
        local received = false
        id, message = rednet.receive(turtleProtocol, 10) -- {"coords", x, y, z, depth, length, width}
        if message == idlecheck then
            rednet.send(id, idleresponse, turtleProtocol)
        elseif func.isTable(message) == true then
            received == true
        end
    until received == true end
    print ("\nCoordinates received...")
    turtle.refuel()

    print ("\nFueled. Ascending...")
    for i=y, (maxheight-label) do
        repeat turtle.digUp() until (turtle.up()) 
        y=y+1 
    end

    oldX = x 
    oldZ = z 
    repeat turtle.dig() until (turtle.forward()) 
    x, y, z = triangulate() 
    if (oldX ~= x) then -- 1 = north, 2 = east, 3 = south, 4 = west
        if (x > oldX) then facing = 2  else facing = 4  end
    else
        if (z > oldZ) then facing = 3  else facing = 1  end
    end
    turtle.back()

    if (x ~= coords[2]) then -- going to destination X
        if (coords[2] < x) then facing = face(facing, 4)  else facing = face(facing, 2)  end
        while (x ~= coords[2]) do
            repeat turtle.dig() until (turtle.forward()) 
            if (facing == 4) then
                x=x-1 
            else
                x=x+1 
            end
        end
    end

    if (z ~= coords[4]) then -- going to destination Z
        if (coords[4] < z) then facing = face(facing, 1)  else facing = face(facing, 3)  end
        while (z ~= coords[4]) do
            repeat turtle.dig() until (turtle.forward()) 
            if (facing == 1) then
                z=z-1 
            else
                z=z+1 
            end
        end
    end

    if (y ~= coords[3]) then -- going to destination Y
        while (y ~= coords[3]) do
            repeat turtle.digDown() until (turtle.down()) 
            y=y-1 
        end
    end

    
    for i=1, coords[5] do -- {"coords", x, y, z, depth, length, width}
        refuel(x, y, z)
        for j=1, coords[6] do
            for k=2, coords[7] do
                if (j%2) then
                    facing = face(facing, 3)  -- odd
                    z=z+1 
                else
                    facing = face(facing, 1)  -- even
                    z=z-1 
                end
                fillLiquid()
                repeat turtle.dig() until (turtle.forward()) 
            end
            if (j~=coords[6]) then
                facing = face(facing, 4) 
                repeat turtle.dig() until (turtle.forward()) 
                x=x-1 
            end
        end
        if (coords[6]%2) then
            facing = face(facing, 1) 
            for i=1, coords[7] do
                turtle.forward()
                z=z-1 
            end
            facing = face(facing, 2) 
            for i=1, coords[6] do 
                turtle.forward()
                x=x+1 
            end
        else
            facing = face(facing, 2) 
            for i=1, coords[6] do 
                turtle.forward()
                x=x+1 
            end
        end
        if (i~=coords[5]) then
            repeat turtle.digDown() until (turtle.down()) 
            y=y-1 
        end
        dropOff(x, y, z)
    end
    local gemstone = rednet.lookup(protocol, "gemstone")
    rednet.send(gemstone, "free")
until (false) 