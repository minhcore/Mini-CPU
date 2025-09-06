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
RESET_MODE_TRIGGER = 128  

mode = None

while True:
    data = ser.read(1)
    if data:
        last_data_time = time.time()
        byte_val = data[0]

        if byte_val == RESET_MODE_TRIGGER:
            print("\n[CPU NOTICE] Please select new mode:")
            mode = input("Select mode (s=string, n=number): ").strip().lower()
            continue

        if byte_val == INPUT_TRIGGER:
            print("\n[CPU REQUEST] Please enter input: ")
            if mode is None:
                mode = input("Select mode (s=string, n=number): ").strip().lower()

            if mode == "n":
                try:
                    num = int(input("Enter number (-128..127): "))
                    if -128 <= num <= 127:
                        val = (num + 256) % 256
                        ser.write(bytes([val]))
                    else:
                        print("Out of range! Must be -128..127")
                except ValueError:
                    print("Invalid number!")
            else:
                user_text = input("Enter text: ")
                ser.write(user_text.encode("ascii"))
                ser.write(b"\n")
            continue

        if mode == "n":
            print(byte_val, end=" ", flush=True)
        else:
            try:
                text = data.decode('ascii')
            except UnicodeDecodeError:
                text = '.'
            print(text, end="", flush=True)

    else:
        if time.time() - last_data_time > 15:
            print("No data for 15 seconds, maybe CPU halted. Closing serial...")
            ser.close()
            break
