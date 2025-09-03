import serial
import time

ser = serial.Serial(
    port='COM10',
    baudrate=115200,
    timeout=1
)

print("Wait for data...")
last_data_time = time.time()
INPUT_TRIGGER = 127

while True:
    data = ser.read(1)  # read 1 byte
    if data:
        last_data_time = time.time()
        byte_val = data[0]

        if byte_val == INPUT_TRIGGER:
            print("\n[CPU REQUEST] Please enter input: ")
            mode = input("Select mode (s=string, n=number): ").strip().lower()

            if mode == "n":  # numeric mode
                try:
                    num = int(input("Enter number (-128..127): "))
                    if -128 <= num <= 127:
                        val = (num + 256) % 256  # two's complement encode
                        ser.write(bytes([val]))
                        print(f"[Sent DEC] {num} -> {val}")
                    else:
                        print("Out of range! Must be -128..127")
                except ValueError:
                    print("Invalid number!")
            else:  # default: string mode
                user_text = input("Enter text: ")
                ser.write(user_text.encode("ascii"))
                ser.write(b"\n")  # end
                print(f"[Sent STR] {user_text}")
            continue  # skip normal printing

        
        try:
            text = data.decode('ascii')
        except UnicodeDecodeError:
            text = '.'

        hex_str = data.hex()
        bin_str = format(byte_val, '08b')
        dec_str = str(byte_val)

        print(f"Text: {text} | Hex: {hex_str} | Bin: {bin_str} | Dec: {dec_str}")

    else:
        if time.time() - last_data_time > 15:
            print("No data for 15 seconds, maybe CPU halted. Closing serial...")
            ser.close()
            break
