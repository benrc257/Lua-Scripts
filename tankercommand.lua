protocolExt = "mining";
protocolInt = "supply"
label = "gemstone";
ID = os.computerID();
os.setComputerLabel(label)
print("\nComputer Label (\"gemstone\") successfully set and broadcasted. Hosting mining rednet...")
rednet.host(protocol, label)
print("\nHosting Successful.")

storage = [];
print("\nRequesting fuel storage coordinates...")
print("\nEnter the fuel storage X coordinate: ")
storage[1] = read();
print("\nEnter the fuel storage Y coordinate: ")
storage[2] = read();
print("\nEnter the fuel storage Z coordinate: ")
storage[3] = read();

tankerID = rednet.lookup()
rednet.send()