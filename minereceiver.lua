print("Scanning for wireless modems...")
if (peripheral.isPresent("top")) then
    modem1 = peripheral.find("modem", rednet.open)
    print("\nWireless modem found. Opening...")
    message = ("\nMining monitoring starting on computer...")
    rednet.broadcast(message, "mining")
    repeat
        id, message = rednet.receive("mining");
        print("\nMining Turtle ", id, ": ", message)
    until (false)
else
    print("\nNo wireless modem found. Ensure modem is on top of PC.")
end