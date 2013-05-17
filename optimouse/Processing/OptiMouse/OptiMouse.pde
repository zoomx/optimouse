/*
Date: 14/05/2013
Author: Boris Mazic
Abstract:
	This application is designed to interface with an
	Arduino board running the OptiMouse library.
	Visualisation of the data coming from an optical mouse.
	Must be paired up with the Arduino sketch Optimouse/examples/Server/Server.ino

References:
	[1] ADNS-2610__AV02-1184EN.pdf
*/
/*
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
import processing.serial.*; 
 
Serial myPort;	// The serial port
PFont myFont;	// The display font
String input = "";	// Input string from serial port
Device device = new Device();
Frame frame;
int BGCOLOR = 255;
int FGCOLOR = 0;
int LABELS = 150;
int PIXEL_SIZE = 8;
int VIDEO_WIDTH;
int VIDEO_HEIGHT;
int BOT = millis();
int LAST_FRAME = millis();
boolean server_on = false;
boolean command_processed = false;

String WHITESPACE = " \t\r\n\f";
String EOL = "\n";
char TERMINATOR = '\n';
char COMMENT = '#';


void initialise_frame(Serial port) {
	println(str(millis()-BOT) + ":initialise_frame()");
	while(!server_on) {
		try {Thread.sleep(500);} catch (InterruptedException e) {}
	}

	println(str(millis()-BOT) + ":initialise_frame() frame_size");
	port.write("frame_size\n");
	while(!command_processed) {
		try {Thread.sleep(500);} catch (InterruptedException e) {}
	}
	VIDEO_WIDTH = frame.frame_x*PIXEL_SIZE;
	VIDEO_HEIGHT = frame.frame_y*PIXEL_SIZE;
/*
	println(str(millis()-BOT) + ":initialise_frame() force_awake_mode true");
	port.write("force_awake_mode true\n");
	while(!command_processed) {
		try {Thread.sleep(500);} catch (InterruptedException e) {}
	}
*/
}

void request_new_frame(Serial port) {
	//println(str(millis()-BOT) + ":request_new_frame()");
	port.write("frame_info\n");
	//port.write("pixel_data\n");
}

void initialise_canvas() {
	println(str(millis()-BOT) + ":initialise_canvas()");
	size(LABELS + VIDEO_WIDTH, VIDEO_HEIGHT); 
	// set initial background
	background(BGCOLOR);
	myFont = loadFont("LucidaBright-12.vlw");
	textFont(myFont);
}

void setup() {
	println(str(millis()-BOT) + ":setup()");
	//frameRate(120);
	// List all the available serial ports: 
	println(Serial.list()); 
	myPort = new Serial(this, Serial.list()[1], 115200); // COM4
	myPort.bufferUntil(TERMINATOR); 
	initialise_frame(myPort);
	initialise_canvas();
	// initiate the frame grabbing
	request_new_frame(myPort);
} 
 
void draw() {
	// nothing to do here -> see serialEvent()
} 
 
void serialEvent(Serial port) {
	//println(str(millis()-BOT) + ":serialEvent()");
	input += port.readString();
	String[] lines = splitTokens(input, EOL);
	int count = lines.length;
	if(input.charAt(input.length()-1) != TERMINATOR) {
		// ignore incomplete lines
		input = lines[--count];
	} else {
		input = "";
	}
	for(int i=0; i < count; ++i) {
		String line = lines[i];
		if(line.charAt(0) == COMMENT) {
			println(line);
			if(line.startsWith("#OptiMouse Server")) {
				server_on = true;
			}
			// ignore the comment
			continue;
		}
		//println(line);
		String[] tokens = splitTokens(line, WHITESPACE);
		if(tokens[0].equals("displacement")) {
			frame.dx = int(tokens[1]);
			frame.dy = int(tokens[2]);
		} else if(tokens[0].equals("squal")) {
			frame.squal = unhex(tokens[1]);
		} else if(tokens[0].equals("minimum_pixel")) {
			frame.minimum_pixel = unhex(tokens[1]);
		} else if(tokens[0].equals("maximum_pixel")) {
			frame.maximum_pixel = unhex(tokens[1]);
		} else if(tokens[0].equals("pixel_sum")) {
			frame.pixel_sum = unhex(tokens[1]);
		} else if(tokens[0].equals("shutter")) {
			frame.shutter = unhex(tokens[1]);
		} else if(tokens[0].equals("pixel_data")) {
			String data = tokens[1];
			int pixels = data.length()/2;
			int min = 255, max = 0;
			for(int k=0; k < pixels; ++k) {
				int v = unhex(data.substring(2*k, 2*k+2));
				if(v < min) min = v;
				if(v > max) max = v;
				frame.pixel_data[k] = v;
			}
			frame.minimum_pixel = min;
			frame.maximum_pixel = max;
			
			frame.draw();
			request_new_frame(port);
		} else if(tokens[0].equals("frame_size")) {
			frame = new Frame(int(tokens[1]),int(tokens[2]));
		} else if(tokens[0].equals("reset")) {
			device.reset = int(tokens[1]);
		} else if(tokens[0].equals("power_down")) {
			device.power_down = int(tokens[1]);
		} else if(tokens[0].equals("force_awake_mode")) {
			device.force_awake_mode = int(tokens[1]);
		} else if(tokens[0].equals("is_awake")) {
			device.is_awake = int(tokens[1]);
		} else {
			println("Unsupported server response: " + line);
		}
		command_processed = true;
	}
} 


class Device {
	int reset;
	int power_down;
	int force_awake_mode;
	int is_awake;
}

class Frame {
	float frame_rate;
	int frame_x;
	int frame_y;
	
	int dx, dy;
	int squal;
	int minimum_pixel;
	int maximum_pixel;
	int pixel_sum;
	int shutter;
	int[] pixel_data;
	
	Frame(int size_x, int size_y) {
		frame_x = size_x;
		frame_y = size_y;
		pixel_data = new int[frame_x*frame_y];
	}
	
	void draw() {
		frame_rate = 1000/(millis()-LAST_FRAME);
		LAST_FRAME = millis();
		//println("frame_rate " + frame_rate + " f/s");
		draw_labels();
		draw_pixels();
	}
	
	void draw_labels() {
		int MARGIN_TOP = 15;
		int MARGIN_LEFT = 10;
		int LINE_SIZE = 15;

		fill(BGCOLOR);
		rect(0,0,LABELS,VIDEO_HEIGHT);
		fill(FGCOLOR);
		smooth();
		int x = MARGIN_LEFT;
		int y = MARGIN_TOP;
		text("frame_size: " + frame_x + " " + frame_y, x, y);
		y += LINE_SIZE;
		text("frame rate: " + frame_rate + " f/s", x, y);
		y += LINE_SIZE;
		text("displacement: " + dx + " " + dy, x, y);
		y += LINE_SIZE;
		text("squal: " + squal, x, y);
		y += LINE_SIZE;
		text("minimum_pixel: " + minimum_pixel, x, y);
		y += LINE_SIZE;
		text("maximum_pixel: " + maximum_pixel, x, y);
		y += LINE_SIZE;
		text("pixel_sum: " + pixel_sum, x, y);
		y += LINE_SIZE;
		text("shutter: " + shutter, x, y);
	}
	
	void draw_pixels() {
		for(int y=0; y < frame_y; ++y) {
			for(int x=0; x < frame_x; ++x) {
				// see Pixel Map [1] p.24 for the info how pixel data is layed out
				int v = pixel_data[x*frame_y + frame_y - 1 - y];
				int brightness = v*255/maximum_pixel;
				stroke(brightness);
				fill(brightness);
				noSmooth();
				rect(LABELS + x*PIXEL_SIZE, y*PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);
			}
		}
	}
}
