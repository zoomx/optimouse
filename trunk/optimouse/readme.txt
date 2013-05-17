*Summary
Arduino + Processing code for control and visualisation of data coming from the optical mouse sensor found in a common optical mouse.

*Description
If you open a common optical mouse you will most likely find two chips inside -- one being a general purpose micro-controller and the other an optical mouse senor. The sensor captures images of the surface below the mouse at high frame rate (1500 frames per second in the Avago ADNS2610 sensor). It uses captured images to calculate the displacement the mouse is moved over time. Incidentally, it is also able to provide the raw image data.

This project consists of two applications -- one is an Arduino sketch that communicates directly to the optical mouse sensor and the other is a Processing sketch that communicates to the Arduino over the serial port and implements visualisation of the sensor data.

*Installation

From the Arduino folder, copy OptiMouse subfolder to the Arduino's libraries folder (e.g. c:\arduino-1.0.3\libraries\).

From the Processing folder, copy OptiMouse subfolder to the Processing's sketchbook/tools folder (e..g. c:\Processing\sketchbook\tools).

*Running

In the Arduino PDE open the File|Examples|OptiMouse|Server example, compile and upload it to the Arduino board.

In the Processing PDE open the File|Sketchbook|tools|OptiMouse sketch and run it. The sketch should start streaming images from the sensor.
