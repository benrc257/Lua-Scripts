print("\nSearching for modem...")
repeat -- opening modem
    modem = peripheral.find("modem");
    os.sleep(0.05)
until (modem)
modemName = peripheral.getName(modem);
rednet.open(modemName)
print("\nWireless modem found. Opening...")
protocol = "aurora";
print("\nHosting aurora rednet...")
rednet.host(protocol, "" .. os.getComputerID());
print("\nHosting successful.")

print("\nSearching for file named \"station.txt\" with this station's name...")
file = fs.open("station.txt", "r")
if (not file) then
    print("\nFile \"station.txt\" could not be opened. Returning...")
    return;
end
print("\nFile opened. Reading...")
stationName = file.readLine();

if (not stationName) then
    print("\nFile \"station.txt\" is empty. Returning...")
    return;
end
print("\nStation name found. Closing file...")
file.close()

os.setComputerLabel(stationName);

function tpsound()
    local dfpwm = require("cc.audio.dfpwm")
    local speaker = peripheral.find("speaker")

    local decoder = dfpwm.make_decoder()
    for chunk in io.lines("tpsound.dfpwm", 16 * 1024) do
        local buffer = decoder(chunk)

        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

repeat
    local id, message = nil;
    repeat
        id, message = rednet.receive(protocol)
    until (message == "request" or message == "warp");

    if (message == "request") then
        rednet.send(id, stationName, protocol)
    else
        repeat
            turtle.select(1)
            turtle.suck()
        until (turtle.getItemCount() > 0);
        turtle.dropDown()
        redstone.setOutput("bottom", true)
        os.sleep(0.5)
        redstone.setOutput("bottom", false)
        repeat
            turtle.suckDown()
        until (turtle.getItemCount() > 0);
        turtle.drop()
        os.sleep(0.5)
        tpsound()
    end
until false;