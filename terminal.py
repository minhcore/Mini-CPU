import serial

ser = serial.Serial(
    port='COM10',   
    baudrate=115200,
    timeout=1
)

print("Wait for data...")

while True:
    data = ser.read(1)  # read 1 byte
    if data:
        
        try:
            text = data.decode('ascii')
        except UnicodeDecodeError:
            text = '.'

        # print hex
        hex_str = data.hex()

        # print binary
        binary_str = format(data[0], '08b')

        print(f"Text: {text} | Hex: {hex_str} | Bin: {binary_str}")
