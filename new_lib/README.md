# Installation Guide for new Library

1. sudo apt-get install python3-dev libboost-python-dev python3-setuptools python3-rpi.gpio 
2. sudo raspi-config --> SPI enable
3. wget http://tmrh20.github.io/RF24Installer/RPi/install.sh 
4. chmod +x install.sh
5. ./install.sh
6. cd rf24libs/RF24/pyRF24
7. python3 setup.py build 
8. sudo python3 setup.py install

WIRING:
PIN	NRF24L01	RPI	RPi -P1 Connector
1	GND	rpi-gnd	(25)
2	VCC	rpi-3v3	(17)
3	CE	rpi-gpio22	(15)
4	CSN	rpi-gpio8	(24)
5	SCK	rpi-sckl	(23)
6	MOSI	rpi-mosi	(19)
7	MISO	rpi-miso	(21)
8	IRQ	-	-
