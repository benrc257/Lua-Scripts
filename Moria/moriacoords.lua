print("\nSearching for disk drive...")
repeat -- opening disk drive
    drive = peripheral.find("drive");
    os.sleep(2);
until (drive);
print("\nDisk drive found.")
print("\nSearching for disk...")
if (not drive.isDiskPresent()) then
    print("\nNo disk found. Please insert the disk...")
    repeat
        os.sleep(2)
    until (drive.isDiskPresent())
end
disk = drive.getDiskLabel();
print("Disk found.")

print("\nRequesting coordinates...")
print("\nEnter the first X coordinate: ")
x1 = read();
print("\nEnter the first Y coordinate: ")
y1 = read();
print("\nEnter the first Z coordinate: ")
z1 = read();
print("\nEnter the second X coordinate: ")
x2 = read();
print("\nEnter the second Y coordinate: ")
y2 = read();
print("\nEnter the second Z coordinate: ")
z2 = read();
print("\nEnter the minimum ascension height for turtles.\nThis should be no greater than [318 - # of turtles]:")
mah = read();

print("\nWriting to disk...")
file = fs.open("/disk/coords.txt", "w");
file.write(x1)
file.write("\n")
file.write(y1)
file.write("\n")
file.write(z1)
file.write("\n")
file.write(x2)
file.write("\n")
file.write(y2)
file.write("\n")
file.write(z2)
file.write("\n")
file.write(mah)
file.close()
print("\nWriting complete.")

file = fs.open("/disk/coords.txt", "r");
print(file.readLine())
print(file.readLine())
print(file.readLine())
print(file.readLine())
print(file.readLine())
print(file.readLine())
print(file.readLine())
file.close()