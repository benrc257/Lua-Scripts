modem = peripheral.find("modem")
protocol = "moria"; 

print("Moria relay active!")
repeat
    local id, message = rednet.receive(protocol)
    if (message == "free") then
        os.queueEvent("turtleFree", id)
        print("Message from turtle " .. id .. "containing \"free\"")
    end
    os.sleep(0.05)
until (message == "end")