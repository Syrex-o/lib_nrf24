import RPi.GPIO as GPIO
from lib_nrf24 import NRF24
import time
import spidev
from threading import Timer
import sys

# Define Board GPIOs
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

pipes = [[0xe7, 0xe7, 0xe7, 0xe7, 0xe7], [0xc2, 0xc2, 0xc2, 0xc2, 0xc2]]

radio = NRF24(GPIO, spidev.SpiDev())

# initialization
radio.begin(0, 17)
radio.setRetries(15,15)

radio.setPayloadSize(8)
radio.setChannel(120)
radio.setDataRate(NRF24.BR_250KBPS)
radio.setPALevel(NRF24.PA_MAX)

radio.setAutoAck(1)
radio.enableDynamicPayloads()
radio.enableAckPayload()

radio.openWritingPipe(pipes[0])
radio.openReadingPipe(1,pipes[1])

message = list(sys.argv[1]+sys.argv[2]+sys.argv[3])
role = "TX"

tries = 0
listenTries = 10
maxTries = 100
receivedCounter = 0

def send(): radio.write(message)

def loop():
    global tries
    global listenTries
    global maxTries
    global receivedCounter
    global role
    tries += 1
    if tries <= maxTries:
        print("Try No.: {}".format(tries))
        if role == "TX":
            radio.stopListening()
            send()
            role = "RX"
            loop()
        if role == "RX":
            radio.startListening()
            counter = 0
            while not radio.available():
                if counter <= listenTries:
                    counter += 1
                    time.sleep(1/1000)
                else:
                    role = "TX"
                    loop()
            receivedMessage = []
            radio.read(receivedMessage, radio.getDynamicPayloadSize())
            # print("received message: {}".format(receivedMessage))
            receivedCounter += 1
            # sys.exit()
            role = "TX"
            loop()
    else:
        percentage = str((receivedCounter / (maxTries/2)) * 100) + "%"
        print("Result: {}/{} ({})".format(receivedCounter, (maxTries / 2), percentage))
        sys.exit()
loop()
