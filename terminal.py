import serial, time

ser = serial.Serial(
    port='COM10',   
    baudrate=115200,
    timeout=1
)

print("Wait for data...")
last_data_time = time.time()

while True:
    data = ser.read(1)  # read 1 byte
    if data:
        last_data_time = time.time()
        try:
            text = data.decode('ascii')
        except UnicodeDecodeError:
            text = '.'

        # print hex
        hex_str = data.hex()

        # print binary
        binary_str = format(data[0], '08b')

        print(f"Text: {text} | Hex: {hex_str} | Bin: {binary_str}")
    else: 
        if time.time() - last_data_time > 5: 
            print("No data for 10 seconds, maybe CPU halted. Closing serial...")
            ser.close()
            break
