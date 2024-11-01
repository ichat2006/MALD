import time
import threading
import RPi.GPIO as GPIO
import cv2
import numpy as np
import json

# GPIO setup
GPIO.setmode(GPIO.BCM)
GPIO_Ain1, GPIO_Ain2, GPIO_Apwm = 17, 27, 22
GPIO_Bin1, GPIO_Bin2, GPIO_Bpwm = 5, 6, 13
GPIO.setup([GPIO_Ain1, GPIO_Ain2, GPIO_Apwm, GPIO_Bin1, GPIO_Bin2, GPIO_Bpwm], GPIO.OUT)

# Motor and PWM setup
pwm_frequency = 50
pwmA, pwmB = GPIO.PWM(GPIO_Apwm, pwm_frequency), GPIO.PWM(GPIO_Bpwm, pwm_frequency)
pwmA.start(0)
pwmB.start(0)
SPEED = 100

# Initialize camera
cap = cv2.VideoCapture(0)

# HSV tracking variables
hue_range, sat_range, val_range = 3, 30, 8
center_x = 320  # Assuming 640x480 frame resolution
current_instruction = None  # Shared variable for latest instruction

# Motor control functions
def move_forward():
    GPIO.output([GPIO_Ain1, GPIO_Bin1], False)
    GPIO.output([GPIO_Ain2, GPIO_Bin2], True)
    pwmA.ChangeDutyCycle(SPEED)
    pwmB.ChangeDutyCycle(SPEED)

def stop_movement():
    GPIO.output([GPIO_Ain1, GPIO_Ain2, GPIO_Bin1, GPIO_Bin2], False)
    pwmA.ChangeDutyCycle(0)
    pwmB.ChangeDutyCycle(0)

def turn_left():
    GPIO.output(GPIO_Ain1, False)
    GPIO.output(GPIO_Ain2, True)
    GPIO.output(GPIO_Bin1, True)
    GPIO.output(GPIO_Bin2, False)
    pwmA.ChangeDutyCycle(SPEED)
    pwmB.ChangeDutyCycle(SPEED)

def turn_right():
    GPIO.output(GPIO_Ain1, True)
    GPIO.output(GPIO_Ain2, False)
    GPIO.output(GPIO_Bin1, False)
    GPIO.output(GPIO_Bin2, True)
    pwmA.ChangeDutyCycle(SPEED)
    pwmB.ChangeDutyCycle(SPEED)

# Color calibration function
def calibrate_hsv():
    ret, frame = cap.read()
    if ret:
        center_region = frame[460:480, 300:340]
        hsv_frame = cv2.cvtColor(center_region, cv2.COLOR_BGR2HSV)
        h, s, v = np.median(hsv_frame[:, :, 0]), np.median(hsv_frame[:, :, 1]), np.median(hsv_frame[:, :, 2])
        return (h, s, v)
    return None

# Track and center robot based on HSV mask
def track_and_center(target_hsv):
    h, s, v = target_hsv
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        hsv_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        lower_bound = np.array([h - hue_range, s - sat_range, v - val_range])
        upper_bound = np.array([h + hue_range, s + sat_range, v + val_range])
        mask = cv2.inRange(hsv_frame, lower_bound, upper_bound)

        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if contours:
            c = max(contours, key=cv2.contourArea)
            leftmost = tuple(c[c[:, :, 0].argmin()][0])
            rightmost = tuple(c[c[:, :, 0].argmax()][0])
            target_x = (leftmost[0] + rightmost[0]) // 2

            if target_x < center_x - 20:
                turn_left()
            elif target_x > center_x + 20:
                turn_right()
            else:
                move_forward()
        else:
            stop_movement()

        # Check for any new instruction to execute based on distance
        if current_instruction and current_instruction["distance"] == "0":
            execute_direction(current_instruction)
            # Clear the instruction after executing
            global current_instruction
            current_instruction = None

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

# Initial API response parsing
def receive_initial_direction():
    # Placeholder for actual API integration
    json_response = '''
    {
        "instruction": "Turn left onto Main Street.",
        "distance": "500 feet",
        "duration": "10 seconds",
        "location": {
            "lat": 34.0522,
            "lng": -118.2437
        },
        "road_name": "Main Street"
    }
    '''
    return parse_direction_data(json.loads(json_response))

# Check for new direction messages (simulated here)
def check_for_new_direction():
    # Replace this with actual API polling or WebSocket update
    json_response = '''
    {
        "instruction": "Turn right onto Oak Street.",
        "distance": "0",
        "duration": "5 seconds",
        "location": {
            "lat": 34.0523,
            "lng": -118.2439
        },
        "road_name": "Oak Street"
    }
    '''
    return parse_direction_data(json.loads(json_response))

def parse_direction_data(data):
    return {
        "instruction": data.get("instruction", ""),
        "distance": data.get("distance", ""),
        "duration": data.get("duration", ""),
        "location": data.get("location", {"lat": None, "lng": None}),
        "road_name": data.get("road_name", "")
    }

# Execute the direction based on JSON data
def execute_direction(data):
    instruction = data["instruction"]
    print(f"Executing instruction: {instruction}")
    
    if "Turn left" in instruction:
        turn_left()
        time.sleep(2)
    elif "Turn right" in instruction:
        turn_right()
        time.sleep(2)
    stop_movement()

# Direction listener to update `current_instruction` if there's a new message
def direction_listener():
    global current_instruction
    # Load initial directions
    current_instruction = receive_initial_direction()

    # Continuously check for new instructions
    while True:
        new_direction = check_for_new_direction()
        if new_direction and new_direction != current_instruction:
            current_instruction = new_direction
        time.sleep(1)  # Polling interval

# Main function
def main():
    target_hsv = calibrate_hsv()
    if target_hsv:
        # Start the direction listener thread
        listener_thread = threading.Thread(target=direction_listener, daemon=True)
        listener_thread.start()
        
        # Start the centering and movement control
        track_and_center(target_hsv)

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Program interrupted.")
    finally:
        pwmA.stop()
        pwmB.stop()
        GPIO.cleanup()



















Alternate code (do not know if it works but Chatgpt says is better)
import time
import asyncio
import RPi.GPIO as GPIO
import cv2
import numpy as np
import json

# GPIO setup
GPIO.setmode(GPIO.BCM)
GPIO_Ain1, GPIO_Ain2, GPIO_Apwm = 17, 27, 22
GPIO_Bin1, GPIO_Bin2, GPIO_Bpwm = 5, 6, 13
GPIO.setup([GPIO_Ain1, GPIO_Ain2, GPIO_Apwm, GPIO_Bin1, GPIO_Bin2, GPIO_Bpwm], GPIO.OUT)

# Motor and PWM setup
pwm_frequency = 50
pwmA, pwmB = GPIO.PWM(GPIO_Apwm, pwm_frequency), GPIO.PWM(GPIO_Bpwm, pwm_frequency)
pwmA.start(0)
pwmB.start(0)
SPEED = 100

# Initialize camera
cap = cv2.VideoCapture(0)

# HSV tracking variables
hue_range, sat_range, val_range = 3, 30, 8
center_x = 320  # Assuming 640x480 frame resolution
current_instruction = None  # Shared variable for latest instruction

# Motor control functions
def move_forward():
    GPIO.output([GPIO_Ain1, GPIO_Bin1], False)
    GPIO.output([GPIO_Ain2, GPIO_Bin2], True)
    pwmA.ChangeDutyCycle(SPEED)
    pwmB.ChangeDutyCycle(SPEED)

def stop_movement():
    GPIO.output([GPIO_Ain1, GPIO_Ain2, GPIO_Bin1, GPIO_Bin2], False)
    pwmA.ChangeDutyCycle(0)
    pwmB.ChangeDutyCycle(0)

def turn_left():
    GPIO.output(GPIO_Ain1, False)
    GPIO.output(GPIO_Ain2, True)
    GPIO.output(GPIO_Bin1, True)
    GPIO.output(GPIO_Bin2, False)
    pwmA.ChangeDutyCycle(SPEED)
    pwmB.ChangeDutyCycle(SPEED)

def turn_right():
    GPIO.output(GPIO_Ain1, True)
    GPIO.output(GPIO_Ain2, False)
    GPIO.output(GPIO_Bin1, False)
    GPIO.output(GPIO_Bin2, True)
    pwmA.ChangeDutyCycle(SPEED)
    pwmB.ChangeDutyCycle(SPEED)

# Color calibration function
def calibrate_hsv():
    ret, frame = cap.read()
    if ret:
        center_region = frame[460:480, 300:340]
        hsv_frame = cv2.cvtColor(center_region, cv2.COLOR_BGR2HSV)
        h, s, v = np.median(hsv_frame[:, :, 0]), np.median(hsv_frame[:, :, 1]), np.median(hsv_frame[:, :, 2])
        return (h, s, v)
    return None

# Track and center robot based on HSV mask
async def track_and_center(target_hsv):
    h, s, v = target_hsv
    global current_instruction
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        hsv_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        lower_bound = np.array([h - hue_range, s - sat_range, v - val_range])
        upper_bound = np.array([h + hue_range, s + sat_range, v + val_range])
        mask = cv2.inRange(hsv_frame, lower_bound, upper_bound)

        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if contours:
            c = max(contours, key=cv2.contourArea)
            leftmost = tuple(c[c[:, :, 0].argmin()][0])
            rightmost = tuple(c[c[:, :, 0].argmax()][0])
            target_x = (leftmost[0] + rightmost[0]) // 2

            if target_x < center_x - 20:
                turn_left()
            elif target_x > center_x + 20:
                turn_right()
            else:
                move_forward()
        else:
            stop_movement()

        # Execute direction only if distance is zero
        if current_instruction and current_instruction["distance"] == "0":
            await execute_direction(current_instruction)
            current_instruction = None

        await asyncio.sleep(0.1)  # Small delay for async loop

# Initial API response parsing
def receive_initial_direction():
    json_response = '''
    {
        "instruction": "Turn left onto Main Street.",
        "distance": "500 feet",
        "duration": "10 seconds",
        "location": {
            "lat": 34.0522,
            "lng": -118.2437
        },
        "road_name": "Main Street"
    }
    '''
    return parse_direction_data(json.loads(json_response))

# Simulate checking for new direction messages
async def check_for_new_direction():
    global current_instruction
    await asyncio.sleep(2)  # Simulate delay before receiving new instruction
    json_response = '''
    {
        "instruction": "Turn right onto Oak Street.",
        "distance": "0",
        "duration": "5 seconds",
        "location": {
            "lat": 34.0523,
            "lng": -118.2439
        },
        "road_name": "Oak Street"
    }
    '''
    new_direction = parse_direction_data(json.loads(json_response))
    if new_direction != current_instruction:
        current_instruction = new_direction

# Parse direction data from JSON
def parse_direction_data(data):
    return {
        "instruction": data.get("instruction", ""),
        "distance": data.get("distance", ""),
        "duration": data.get("duration", ""),
        "location": data.get("location", {"lat": None, "lng": None}),
        "road_name": data.get("road_name", "")
    }

# Execute the direction based on JSON data
async def execute_direction(data):
    instruction = data["instruction"]
    print(f"Executing instruction: {instruction}")
    
    if "Turn left" in instruction:
        turn_left()
        await asyncio.sleep(2)
    elif "Turn right" in instruction:
        turn_right()
        await asyncio.sleep(2)
    stop_movement()

# Main function to run tasks concurrently
async def main():
    target_hsv = calibrate_hsv()
    if target_hsv:
        # Initial direction setup
        global current_instruction
        current_instruction = receive_initial_direction()

        # Run direction checking and centering in parallel
        await asyncio.gather(
            track_and_center(target_hsv),
            check_for_new_directions_loop()
        )

# Continuous loop to check for new directions
async def check_for_new_directions_loop():
    while True:
        await check_for_new_direction()
        await asyncio.sleep(1)  # Delay between checks

# Start asyncio event loop
if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Program interrupted.")
    finally:
        pwmA.stop()
        pwmB.stop()
        GPIO.cleanup()
        cap.release()
        cv2.destroyAllWindows()



