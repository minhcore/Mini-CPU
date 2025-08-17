import serial


PORT = "COM10"      
BAUD = 115200      


ser = serial.Serial(PORT, BAUD)



count = 0
with open("G:/Other computers/My Computer/study_folder_sh/design cpu/Mini-CPU/program.hex") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        word = int(line, 16)
        high = (word >> 8) & 0xFF
        low  = word & 0xFF
        ser.write(bytes([low, high]))
        count += 1

        print(f"Sent word {count}: {high:02X} {low:02X}")

ser.close()
print(f"Sent {count} words")
