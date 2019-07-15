import RPi.GPIO as GPIO
from lib_nrf24 import NRF24
import time
import spidev
from threading import Timer

# Define Board GPIOs
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

# GPIO Relais Board Pins
PINS = [2,3,4,5,6,7]

# initializing GPIOS to HIGH
for i in PINS:
    GPIO.setup(i, GPIO.OUT, initial=GPIO.HIGH)

pipes = [[0xe7, 0xe7, 0xe7, 0xe7, 0xe7], [0xc2, 0xc2, 0xc2, 0xc2, 0xc2]]

radio = NRF24(GPIO, spidev.SpiDev())

# initialization
radio.begin(0, 17)
radio.setRetries(15,15)

radio.setPayloadSize(8)
radio.setChannel(124)
radio.setDataRate(NRF24.BR_250KBPS)
radio.setPALevel(NRF24.PA_MAX)

radio.setAutoAck(1)
radio.enableDynamicPayloads()
radio.enableAckPayload()

radio.openReadingPipe(1, pipes[1])

radio.stopListening()
radio.startListening()

# filling ackPayload
ackPL = [1]
radio.writeAckPayload(1, ackPL, len(ackPL))

# timer status
isTimerActive = False

# setting pin off
def pinOff(pin):
    global isTimerActive
    GPIO.output(pin, GPIO.HIGH)
    isTimerActive = False

# listening loop
while True:
    while not radio.available(0):
        time.sleep(1/100)
    # message income
    # writing payload
    radio.writeAckPayload(1, ackPL, len(ackPL))
    receivedMessage = []
    radio.read(receivedMessage, radio.getDynamicPayloadSize())
    # translating message
    arr = []
    for n in receivedMessage:
        # Decode into standard unicode set
        if (n >= 32 and n <= 126):
            arr.append(chr(n))
    # setting pins off
    for pin in PINS:
        if not GPIO.input(pin):
            GPIO.output(pin, GPIO.HIGH)
    # setting correct GPIO
    if arr[1] == '1':
        GPIO.output(int(arr[0]), GPIO.LOW)
        secs = int("".join(arr)[2:])
        # timer
        if isTimerActive:
            t.cancel()
            isTimerActive = False
        t = Timer(secs, pinOff, [int(arr[0])])
        t.start()
        isTimerActive = True
    else:
        GPIO.output(int(arr[0]), GPIO.HIGH)
