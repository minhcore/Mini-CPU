import serial


PORT = "COM10"      
BAUD = 115200
SYNC = 0xFF       


ser = serial.Serial(PORT, BAUD)


ser.write(bytes([SYNC]))

count = 0
with open("program.hex") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        word = int(line, 16)
        high = (word >> 8) & 0xFF
        low  = word & 0xFF
        ser.write(bytes([high, low]))
        count += 1

ser.close()
print(f"Sent {count} words ({count*2} bytes)")
