modem = peripheral.find("modem", rednet.open);
print("\nWireless modem found. Opening...")

protocol = "mining";



ID = os.computerID();
os.setComputerLabel(label)
rednet.broadcast(label, protocol)
print("\nComputer Label (\"gemstone\") successfully set and broadcasted. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")
