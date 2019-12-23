# Missions
[![N|ukaton](https://media.licdn.com/dms/image/C560BAQESGFkJ-AljCg/company-logo_200_200/0?e=1584576000&v=beta&t=bhU_ZiDPbMbRL_WuzcMuNvGd3cwVGXOonh1hyz5ZpK0)](https://ukaton.com)

Missions is an iOS companion application that enables users use a pair of bluetooth enabled smart shoe insoles to detect posture and weight changes in real time. It's also a tool to help users collect posture and weight training data, which can be airdropped or emailed to a local machine to create Machine Learning models out of. 

# Available

  - Navigate to the home screen to collect posture training data
  - Navigate to the activity prediction screen to your current stance based on a machine learning stance classifier model prediction.
  - Play a song and get corrective audio feedback in real-time about your posture changes (i.e. lean too much to the left, hearing audio coming mainly from your right ear. This will force the user to stand neutrally to hear music evenly from both ears.)

# Coming Soon

  - Send collected training data to a server that will return a response with generated machine learning classifier or regressor model, depending on the training task.
  - Collect both weight training data from the smart shoe insoles in conjunction with a weight measurements from a smart scale to get an accurate and calibrated representation of the user's body weight.
  - Receive push notifications detailing constructive and critical feedback about weight fluctuations and posture changes.
  - View a graphical summary that digests of all the weight fluctuations and posture changes in an easy-to-read format (similar to iOS's screen time feature)


### Tech

The Missions app uses the following to work properly

* [ESP32] - An embedded microcontroller that contains a Wifi+Bluetooth LE Module
* [Flexible PCB Insoles] - A pair of thin, flexible PCBs in the shape of a shoe insole that contains a spatial arrangement of sensors used to detect foot pressure changes.
* [FSR] - Force Sensitive Resistors made of mylar material that sit on top of each sensor to smoothen out the pressure signal.
* [PlatformIO] - an easy to use IDE that enables a developer to write code for many different types of microcontrollers ranging from ESP32 to Arduino.
* [CreateML] - is an iOS/Mac framework that enables developers to create machine learning models ranging from classifiers to regressors.
* [CoreML] - is an iOS/Mac framework that enables developers to make machine learning predictions within an application given a model.
* [BLE] - otherwise known as Bluetooth Low-Energy, is the required transmission control protocol to communicate between devices.

### Todos

License
----

MIT


**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [Flexible PCB Insoles]: <http://www.stevenlabel.com/products/membrane-switches>
   [ESP32]: <https://www.espressif.com/en/products/hardware/esp32/overview>
   [FSR]: <https://www.sensitronics.com/products-xactfsr-family.php>
   [PlatformIO]: <https://docs.platformio.org/en/latest/platforms/espressif32.html>
   [CreateML]: <https://developer.apple.com/documentation/createml>
   [CoreML]: <https://developer.apple.com/documentation/coreml>
   [BLE]: <https://docs.espressif.com/projects/esp-idf/en/latest/api-reference/bluetooth/>
   
