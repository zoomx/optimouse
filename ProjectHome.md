# OptiMouse #
## Visualising optical mouse sensor data using Arduino and Processing ##

### Introduction ###
If you open a common optical mouse you will most likely find two chips inside -- one being a general purpose micro-controller and the other an optical mouse senor. The sensor captures images of the surface below the mouse at high frame rate (1500 frames per second in the Avago ADNS2610 sensor). It uses captured images to calculate the displacement the mouse is moved over time. Incidentally, it is also able to provide the raw image data.

### System Overview ###

![https://optimouse.googlecode.com/svn/wiki/images/optimouse-system-overview.jpg](https://optimouse.googlecode.com/svn/wiki/images/optimouse-system-overview.jpg)

This is a two part project. One part is code that runs on the Arduino board (library+sketch). The other part is software that runs on a PC and communicates with the Arduino board.

The Arduino code serves as a bridge between the optical mouse sensor and the PC. The Processing sketch communicates to the Arduino over the serial port and implements visualisation of the sensor data.

### Software Installation ###

From the Arduino folder, copy OptiMouse subfolder to the Arduino's _libraries_ folder (e.g. c:\arduino-1.0.3\libraries\).

From the Processing folder, copy OptiMouse subfolder to the Processing's _sketchbook/tools_ folder (e..g. c:\Processing\sketchbook\tools).

### Hardware Configuration ###

I used the mouse's USB cable to connect it to the Arduino board. First, I had to cut the existing connections and re-solder the USB signal wires directly to the optical chip, in my case ADNS2610.

![https://optimouse.googlecode.com/svn/wiki/images/ADNS2610-hookup-labelled.jpg](https://optimouse.googlecode.com/svn/wiki/images/ADNS2610-hookup-labelled.jpg)

Also, I made sure the optical chip is not connected to the mouse's own microcontroller by cutting traces for the SCKL and SDIO signals.

![https://optimouse.googlecode.com/svn/wiki/images/ADNS2610-hookup-traces.jpg](https://optimouse.googlecode.com/svn/wiki/images/ADNS2610-hookup-traces.jpg)

I made a simple shield for my Arduino Uno [R3](https://code.google.com/p/optimouse/source/detail?r=3) board out of a perf board. There is a USB A socket mounted on and the pins are connected to the Ardiuno board as follows:

![https://optimouse.googlecode.com/svn/wiki/images/arduino-board-setup.jpg](https://optimouse.googlecode.com/svn/wiki/images/arduino-board-setup.jpg)

Notice that I have SCLK signal connected to the pin 3 on the Arduino board and SDIO signal goes to the pin 2. I you have a different hardware setup, you'll have to modify two lines in the source code in Arduino\OptiMouse\examples\Server\Server.ino:

```cpp

49: #error Make sure you specify SCLK and SDIO pins that reflect your hardware configuration! Then, just comment out or delete this line.
50: static int const SCLK = 3;		// Serial clock pin on the Arduino
51: static int const SDIO = 2;		// Serial data (I/O) pin on the Arduino
```

### Running ###

In the Arduino PDE open the File|Examples|OptiMouse|Server example, compile and upload it to the Arduino board.

![https://optimouse.googlecode.com/svn/wiki/images/optimouse-arduino-open.jpg](https://optimouse.googlecode.com/svn/wiki/images/optimouse-arduino-open.jpg)

Fire up Serial Monitor (Ctrl+Shift+M) and type in **?** or **help** and then press the ENTER key to get a list of supported commands.

![https://optimouse.googlecode.com/svn/wiki/images/optimouse-arduino-server-co.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-arduino-server-co.png)

This is a sample output after issuing the **device\_info** followed by the **frame\_info** commands.

![https://optimouse.googlecode.com/svn/wiki/images/optimouse-arduino-server.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-arduino-server.png)


In the Processing PDE open the File|Sketchbook|tools|OptiMouse sketch and run it.

![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-open.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-open.png)

The sketch should start streaming images from the sensor.

|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_381um-dot_63.5um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_381um-dot_63.5um.png)|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_508um-dot_84.7um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_508um-dot_84.7um.png)|
|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|381μm raster with 63.5μm black dots on white paper                                                                                                                                                     |508μm raster with 84.7μm black dots on white paper                                                                                                                                                     |
|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_635um-dot_105.8um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_635um-dot_105.8um.png)|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_762um-dot_127um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_762um-dot_127um.png)  |
|635μm raster with 105.8μm black dots on white paper                                                                                                                                                    |762μm raster with 127μm black dots on white paper                                                                                                                                                      |
|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_889um-dot_148.2um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_889um-dot_148.2um.png)|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1016um-dot_169.3um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1016um-dot_169.3um.png)|
|889μm raster with 148.2μm black dots on white paper                                                                                                                                                    |1016μm raster with 169.3μm black dots on white paper                                                                                                                                                   |
|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1143um-dot_190.5um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1143um-dot_190.5um.png)|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1270um-dot_211.7um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1270um-dot_211.7um.png)|
|1143μm raster with 190.5μm black dots on white paper                                                                                                                                                   |1270μm raster with 211.7μm black dots on white paper                                                                                                                                                   |
|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1397um-dot_232.8um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1397um-dot_232.8um.png)|![https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1397um-dot_465.7um.png](https://optimouse.googlecode.com/svn/wiki/images/optimouse-processing-raster_1397um-dot_465.7um.png)|
|1397μm raster with 232.8μm black dots on white paper                                                                                                                                                   |1397μm raster with 465.7μm black dots on white paper                                                                                                                                                   |


### Similar stuff elsewhere ###
  * [Interfacing an optical mouse sensor to your Arduino](http://www.martijnthe.nl/2009/07/interfacing-an-optical-mouse-sensor-to-your-arduino/)
  * [Optical mouse hacking, part 1](http://conorpeterson.wordpress.com/2010/06/04/optical-mouse-hacking-part-1/)
  * [Optical Mouse Hacks: 2D Micropositioning using cheap mouse cameras](http://tim.cexx.org/?p=613)
  * [Optical Mouse Cam](http://www.bidouille.org/hack/mousecam)
  * [Hacked Optical Mouse](http://hackteria.org/wiki/index.php/Hacked_Optical_Mouse)
  * [Cody's Robot Optical Motion Sensor #1 (CROMS-1)](http://home.roadrunner.com/~maccody/robotics/croms-1/croms-1.html)
  * [BTC Optical Mouse Hack](http://home.roadrunner.com/~maccody/robotics/mouse_hack/mouse_hack.html)
  * [2D positioning: hacking an optical mouse!](http://pickandplace.wordpress.com/2012/05/16/2d-positioning-hacking-an-optical-mouse/)