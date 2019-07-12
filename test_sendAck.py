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
radio.setChannel(124)
radio.setDataRate(NRF24.BR_250KBPS)
radio.setPALevel(NRF24.PA_MAX)

radio.setAutoAck(1)
radio.enableDynamicPayloads()
radio.enableAckPayload()

radio.openWritingPipe(pipes[1])

radio.stopListening()

message = list(sys.argv[1]+sys.argv[2]+sys.argv[3])

tries = 0

def send(): radio.write(message)

def loop():
    global tries
    tries += 1
    print(tries)
    if tries <= 30:
        send()
        if radio.isAckPayloadAvailable():
            returnedPL = []
            radio.read(returnedPL, radio.getDynamicPayloadSize())
            print("received message: {}".format(returnedPL))
            time.sleep(0.1)
            loop()
        else:
            time.sleep(0.1)
            loop()
    else:
        sys.exit()
loop()
