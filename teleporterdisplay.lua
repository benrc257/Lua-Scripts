protocol = "teleporter1"; -- controls channel for tp pairs
modem = peripheral.find("modem", rednet.open)
monitor = peripheral.find("monitor")

width, height = monitor.getSize()
monitor.setBackgroundColor(colors.black)
monitor.clear()
monitor.setTextScale(1)
marginW = 2;
marginH = height/1.75;
monitor.setCursorPos(marginW, marginH)

repeat
    local input = redstone.getInput("front")
    local returning = redstone.getInput("top")
    if (input) then
        monitor.setCursorPos(marginW, marginH)
        monitor.setTextColor(colors.green)
        monitor.clearLine()
        monitor.write("READY")
    elseif (returning) then
        monitor.setCursorPos(1, marginH)
        monitor.setTextColor(colors.blue)
        monitor.clearLine()
        monitor.write("RETURN")
        redstone.setOutput("bottom", true)
        rednet.broadcast(protocol, protocol)
        os.sleep(1)
        rednet.broadcast(protocol, protocol)
        os.sleep(5)
        redstone.setOutput("bottom", false)
    else
        monitor.setCursorPos(marginW, marginH)
        monitor.setTextColor(colors.red)
        monitor.clearLine()
        monitor.write("EMPTY")
    end
    os.sleep(0.5)
until false;