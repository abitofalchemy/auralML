# auralML

<a data-flickr-embed="true"  href="https://www.flickr.com/photos/83956760@N00/34558213346/in/dateposted-public/" title="New work"><img src="https://c1.staticflickr.com/5/4174/34558213346_8b11ca8e0a_k.jpg" width="740"  alt="New work"></a>

Resource-Limited open-source medical instruments.

**Project**

Our current project is exploring the limits of low-power wireless to build high quality, low cost medical instruments.

**Software**

Currently developing a mobile tool with a machine learning component to turn data into a signals-engine.


**Interested?** 

Contact me directly.


---
output: html_document
---

```{r setup, include=FALSE}
htmltools::tagList(rmarkdown::html_dependency_font_awesome())
```

# AuralML
Description:
AuralML (working/temporay project name) is a suite of hardware and software solutions for the healthcare and medical industry.

## Status

Date | Action                                 | Status
-----|----------------------------------------|-------
31Mar17| Waiting for the evaluation kit, UPS tracking number is: [1Z4R29Y30348087114](https://wwwapps.ups.com/WebTracking/track) | 
27Mar17| Ordered the dev kit: STEVAL-STLKT01V1 from STMicroelectronics. After reading through the docs I am more confident |
23Mar17| Local 3D printing guy made two more stethoscope heads.| done
. | Tubbing, and stamp to make the mylar-membrane ordered from Amazon.com;| done
20MAR17| Got all the parts 3D printed to build one low-cost stethoscope| done
. | Prior to this date, I found out that the other Bluetooth Low power modules with microphone cannot send audio over the air, so after discussing it with Kristin, it doesn't make sense to continue that development.| done


## Head Design
Using the head from GliaX Free Medical [Github repository](https://github.com/GliaX)
- We have prited several heads 
- We have one complete stethoscope

## Bluetooth Devices

### STMicroelectronics
This product sounds to be the most promising one. I am currently waiting for delivery of this 
device.

- [STEVAL-STLKT01V1](http://www.st.com/content/st_com/en/products/evaluation-tools/solution-evaluation-tools/sensor-solution-eval-boards/steval-stlkt01v1.html)


### DIGI PAGE
- https://www.digikey.com/en/articles/techzone/2016/nov/how-to-deploy-bluetooth-based-iot-design-under-40

### Others
- http://www.sensiedge.com
- http://www.ti.com/tool/cc2650stk
- https://www.ralfebert.de/tutorials/


### Interface potential
- http://community.silabs.com/t5/Bluetooth-Wi-Fi/Thunderboard-How-stream-data-directly-to-cloud/m-p/182060#M14745

### iOS Bluetooth
- https://developer.apple.com/bluetooth/

### Firebase (cloud services)
- https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
- [Configuring](https://firebase.google.com/docs/ios/setup)


### Bluetooth Modules
- [EasyVR-Voice-Recognition](https://developer.mbed.org/components/EasyVR-Voice-Recognition/)
- [Interactive Design (Berkeley)](https://bcourses.berkeley.edu/courses/1376830/pages/class-16-bluetooth)
- [Ti](http://www.ti.com/tool/TIDC-CC2650STK-SENSORTAG)

- [Makezine - tear down of the sensortag](http://makezine.com/2013/04/18/teardown-of-the-ti-sensortag/)


## Developer Notes

#### StackOverflow Links
- [](http://stackoverflow.com/questions/18378049/how-to-record-the-voice-from-bluetooth-device-mic-and-play-in-device-speaker)
- [Xcode or Nodejs](http://stackoverflow.com/questions/33061371/macbook-pro-2015-connecting-to-a-ti-sensortag-cc2541)

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
```
The cradle expansion board cannot be used to program the SensorTile module. The USB port on this board connects directly to the module -- it's there so that you can program the module to behave as a USB device, and connect it to a computer.

You will need a separate SWD programmer to program and debug this part. Many of ST's evaluation boards, including most Discovery and Nucleo boards, have an integrated ST-Link programmer which will work perfectly. Remove the ST-Link jumpers on the other board, then connect the SWD pins between the two boards with jumper wires. (If you aren't sure of the pinout, check the schematics!)

DO NOT plug the Cradle Expansion Board directly into a Nucleo board using the Arduino shield connector. This won't work, and it might damage one or both boards.


Q:
Should OpenSTM and the Nucleo programmer board work on a macOS system? – sAguinaga Apr 21 at 18:47   

Yes. I've worked with ST Discovery boards extensively using OpenOCD. – duskwuff Apr 21 at 18:48

Q:
I have a NUCLEO-f401reT6 64 pins + a Nucleo Expansion board (X-Nucleo-IDB05A1) and a development Mac mini. What is the "Arduino shield connector?" I have a 5pin ribbon cable I can connect SWD between the CradleExpansionBoard (CEB) to SWD connector on the Nucleo-64, right? Only connect the Nucleo to my mac mini and not the CEB, right? Next, do I need to figure out if my OpenOCD can detect this Nucleo board? – sAguinaga just now   edit   
```
## Other important folders:
- [~/Theory/Experiments/i0sDev/README.md](file:///~/Theory/Experiments/i0sDev/README.md) 

