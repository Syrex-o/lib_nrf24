import RPi.GPIO as GPIO
from lib_nrf24 import NRF24
import time
import spidev
from threading import Timer
import sys

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
radio.setChannel(120)
radio.setDataRate(NRF24.BR_250KBPS)
radio.setPALevel(NRF24.PA_MAX)

radio.setAutoAck(0)
radio.enableDynamicPayloads()

radio.openWritingPipe(pipes[0])
radio.openReadingPipe(1,pipes[1])

radio.stopListening()
radio.startListening()

# timer status
isTimerActive = False

def pinOff(pin):
    global isTimerActive
    GPIO.output(pin, GPIO.HIGH)
    isTimerActive = False

while True:
    while not radio.available():
        time.sleep(1/100)
    receivedMessage = []
    radio.read(receivedMessage, radio.getDynamicPayloadSize())
    radio.stopListening()
    radio.write(receivedMessage)
    radio.startListening()
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
