modem = peripheral.find("modem")
protocol = "moria"; 

function istable(t)
    return (type(t) == "table")
end

print("Tanker relay active!")
repeat
    local id, message = rednet.receive(protocol)
    if (istable(message)) then
        if ((#message) == 3) then
            os.queueEvent("coordinates", message)
            print("Message from computer " .. id .. " containing \"coordinates\"")
        end
    end
    os.sleep(0.05)
until (message == "end")

os.reboot()