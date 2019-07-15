lib_nrf24
=========

## Modified for FHEM Sprinkler
## see send.py and receive.py

Python2/3 library for NRF24L01+ Transceivers

# Installation for Python3
1. enable SPI in raspi-config
2. sudo apt-get install python3-dev -y
3. wget https://github.com/Gadgetoid/py-spidev/archive/master.zip
4. unzip master.zip
5. rm master.zip
6. cd ./py-spidev-master
7. sudo python3 setup.py install
8. mkdir /home/pi/NRF24L01
9. sudo apt-get install git -y
10. cd /home/pi/NRF24L01
11. git clone https://github.com/Syrex-o/lib_nrf24
12. cd ./lib_nrf24/
13. cp lib_nrf24.py /home/pi/NRF24L01/
14. sudo apt-get install python3-rpi.gpio -y


## Autostart receiver.py
1. sudo nano /etc/rc.local
2. python3 /home/pi/NRF24L01/receiveSwitch.py &
