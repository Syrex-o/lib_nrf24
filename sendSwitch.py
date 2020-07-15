import RPi.GPIO as GPIO
from lib_nrf24 import NRF24
import time
import spidev
from threading import Timer
import sys
import os

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

radio.setAutoAck(0)
radio.enableDynamicPayloads()

radio.openWritingPipe(pipes[0])
radio.openReadingPipe(1,pipes[1])

message = list(sys.argv[1]+sys.argv[2]+sys.argv[3])
role = "TX"

tries = 0
listenTries = 10
maxTries = 40

def send(): radio.write(message)

def evaluate(msg):
    result = ""
    for n in msg:
        if(n >= 32 and n <= 126):
            result += chr(n)
    if result == "".join(message):
        command = "true" if sys.argv[2] == "1" else "false"
        # writing callback to fhem
        os.system('perl /opt/fhem/fhem.pl 7072 "set '+sys.argv[4]+' callbackState '+command+'"')
    sys.exit()

def loop():
    global tries
    global listenTries
    global maxTries
    global role
    tries += 1
    if tries <= maxTries:
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
            evaluate(receivedMessage)
    else:
        os.system('perl /opt/fhem/fhem.pl 7072 "set '+sys.argv[4]+' callbackState false"')
        os.system('perl /opt/fhem/fhem.pl 7072 "set '+sys.argv[4]+' lastError noReply"')
        sys.exit()
loop()
