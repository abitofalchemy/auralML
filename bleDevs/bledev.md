# BLE Development

## Development (IDE)

System Workbench for STM32 [OpenSTM32](http://www.openstm32.org)

Documentation:
- [SensorTile](./en.steval-stlkt01v1_quick_start_guide.pdf)


- [STM32F401 Nucleo 64](http://www.st.com/en/evaluation-tools/nucleo-f401re.html)

- [F401RE User manual](http://www.st.com/content/ccc/resource/technical/document/user_manual/1b/03/1b/b4/88/20/4e/cd/DM00105928.pdf/files/DM00105928.pdf/jcr:content/translations/en.DM00105928.pdf)

## HW Setup 

![my setup](https://flic.kr/p/UDMSQA)


As shown on page 8 and page 14:
- Remove the CN2 jumpers from the Nucleo board and connect the SWD interfaces using the ribbon jumper wires.

## Getting OpenOCD up and running

The cradle expansion board cannot be used to program the SensorTile module. The USB port on this board connects directly to the module -- it's there so that you can program the module to behave as a USB device, and connect it to a computer.

You will need a separate SWD programmer to program and debug this part. Many of ST's evaluation boards, including most Discovery and Nucleo boards, have an integrated ST-Link programmer which will work perfectly. Remove the ST-Link jumpers on the other board, then connect the SWD pins between the two boards with jumper wires. (If you aren't sure of the pinout, check the schematics!)

DO NOT plug the Cradle Expansion Board directly into a Nucleo board using the Arduino shield connector. This won't work, and it might damage one or both boards.


Q:
Should OpenSTM and the Nucleo programmer board work on a macOS system? – sAguinaga Apr 21 at 18:47   

Yes. I've worked with ST Discovery boards extensively using OpenOCD. – duskwuff Apr 21 at 18:48

Q:
I have a NUCLEO-f401reT6 64 pins + a Nucleo Expansion board (X-Nucleo-IDB05A1) and a development Mac mini. What is the "Arduino shield connector?" I have a 5pin ribbon cable I can connect SWD between the CradleExpansionBoard (CEB) to SWD connector on the Nucleo-64, right? Only connect the Nucleo to my mac mini and not the CEB, right? Next, do I need to figure out if my OpenOCD can detect this Nucleo board? – sAguinaga just now   edit   
