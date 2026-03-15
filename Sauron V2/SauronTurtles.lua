-- this file:
-- updates turtle tables
-- assigns turtles a job

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronTurtles")

-- vars
local broadcasted = "employed?"
local responded = "needjob"
local miner = "miner"
local supplier = "supplier"
local tanker = "tanker"
turtleJobs = {} -- 1 - miner, 2 - tanker, 3 - supplier
local newTurtles = {}
local newTurtlesIdle = {}
local newTurtleJobs = {}

-- constantly checking for new turtles or idle turtles
repeat
    newTurtles, newTurtlesIdle = updateTurtles(turtleProtocol, turtles, turtlesIdle)

    if #turtleJobs ~= #turtles then -- realign the jobs list with turtles list
        for i, #turtles do
            for j, #newTurtles do
                if turtles[i] == newTurtles[j] then
                    newTurtleJobs[j] = turtleJobs[i]
                    break
                end
            end
        end
    end
    turtleJobs = newTurtleJobs
    turtles = newTurtles
    turtlesIdle = newTurtlesIdle

    -- checking for idle turtles without jobs
    rednet.broadcast(broadcasted, turtleProtocol)
    local id, message = nil
    do -- assigns each of the turtles jobs
        ::receiving::
        id, message = rednet.receive(turtleProtocol, 10)
        if message == responded then

            if (tankerjobs == 0) then -- 0 tankers
                rednet.send(id, tanker)
                turtleJobs[matchID(turtles, id, 1)] = 2

            elseif (supplyingjobs == 0) then -- 0 suppliers
                rednet.send(id, supplier)
                turtleJobs[matchID(turtles, id, 1)] = 3

            elseif (miningjobs == 0) then -- 0 miners
                rednet.send(id, mining)
                turtleJobs[matchID(turtles, id, 1)] = 1

            elseif (miningjobs/3 > tankerjobs) then -- add a new tanker for a set
                rednet.send(id, tanker)
                turtleJobs[matchID(turtles, id, 1)] = 2

            elseif (miningjobs/3 > supplyingjobs) then -- add a new supplier for a set
                rednet.send(id, supplier)
                turtleJobs[matchID(turtles, id, 1)] = 3

            else -- adds up miners until the next new set of three
                rednet.send(id, mining)
                turtleJobs[matchID(turtles, id, 1)] = 1
                
            end


        elseif message ~= nil then
            goto receiving
        end
    until id == nil end
until completed == true end