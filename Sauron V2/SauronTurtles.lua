-- this file:
-- updates turtle tables
-- assigns turtles a job

-- libs
func = require("functions")

-- name tab
multishell.setTitle(multishell.getCurrent(), "SauronTurtles")

-- vars
local broadcasted = "employed?"
local miner = "miner"
local supplier = "supplier"
local tanker = "tanker"
local newTurtles = {}
local newTurtlesIdle = {}
local newTurtleJobs = {}
newTurtles[0] = false
newTurtlesIdle[0] = false
newTurtleJobs[0] = false
local tankerjobs = 0
local supplyingjobs = 0
local miningjobs = 0
    
-- constantly checking for new turtles or idle turtles
local messageindex = 1
repeat
    newTurtles, newTurtlesIdle = func.updateTurtles(turtleProtocol, turtles, turtlesIdle)

    if #newTurtles ~= #turtles then -- realign the jobs list with turtles list
        for i=1, #turtles do
            for j=1, #newTurtles do
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
    repeat -- assigns each of the turtles jobs
        os.sleep(1)
        if (turtlesrid[messageindex] ~= nil) then
            local foundID = func.matchID(turtles, turtlesrid[messageindex], 1)
            if (foundID == 0) then
                break
            elseif (tankerjobs == 0) then -- 0 tankers
                rednet.send(turtlesrid[messageindex], tanker, turtleProtocol)
                turtleJobs[foundID] = 2
                tankerjobs = tankerjobs+1
            elseif (supplyingjobs == 0) then -- 0 suppliers
                rednet.send(turtlesrid[messageindex], supplier, turtleProtocol)
                turtleJobs[foundID] = 3
                supplyingjobs = supplyingjobs+1
            elseif (miningjobs == 0) then -- 0 miners
                rednet.send(turtlesrid[messageindex], miner, turtleProtocol)
                turtleJobs[foundID] = 1
                miningjobs = miningjobs+1
            elseif (miningjobs/3 > tankerjobs) then -- add a new tanker for a set
                rednet.send(turtlesrid[messageindex], tanker, turtleProtocol)
                turtleJobs[foundID] = 2
                tankerjobs = tankerjobs+1
            elseif (miningjobs/3 > supplyingjobs) then -- add a new supplier for a set
                rednet.send(turtlesrid[messageindex], supplier, turtleProtocol)
                turtleJobs[foundID] = 3
                supplyingjobs = supplyingjobs+1
            else -- adds up miners until the next new set of three
                rednet.send(turtlesrid[messageindex], miner, turtleProtocol)
                turtleJobs[foundID] = 1
                miningjobs = miningjobs+1
            end
            messageindex = messageindex+1
        end
    until (turtlesrid[messageindex] == nil)
until (completed == true)