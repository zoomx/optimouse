/*---------------------------------------------------------------------------
File: OptiMouse/examples/Server/Server.ino
Date: 09/05/2013
Author: Boris Mazic
Abstract:
	A command server that allows an optical mouse sensor to be controlled 
	over the Arduino's serial port. The command set is modelled on the
	ADNS2610 sensor's capabilities. It will probably need to be modified
	to support other sensors.

	This sketch can be used stand alone with Arduino's Serial Monitor
	(Ctrl+Shift+M) or paired up with the companion Processing library
	that provides a simple visualisation of the sensor data.

	Based on the source code by Martijn The.
	http://www.martijnthe.nl/
---------------------------------------------------------------------------*/
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

//http://playground.arduino.cc/Main/Printf
// we need fundamental FILE definitions and printf declarations
#include <stdio.h>
// create a FILE structure to reference our UART output function
static FILE uartout = {0};
// create the output function
// This works because Serial.write, although of type virtual, already exists.
static int uart_putchar(char c, FILE *stream) {
    Serial.write(c);
    return 0;
}

#include "Buffer.h"
#include "ADNS2610.h"

static int const SCLK = 3;		// Serial clock pin on the Arduino
static int const SDIO = 2;		// Serial data (I/O) pin on the Arduino
static char const WHITESPACE[] = " \t\r\n\v\f";
static int const MAX_TOKEN_SIZE = 64;

void process_command_line(Buffer const &line);
ADNS2610 optimouse = ADNS2610(SCLK, SDIO);
Buffer input;
boolean inputComplete = false;	// whether the string is complete

void setup() {
	Serial.begin(115200);
	// fill in the UART file descriptor with pointer to writer.
	fdev_setup_stream (&uartout, uart_putchar, NULL, _FDEV_SETUP_WRITE);
	// The uart is the standard output device STDOUT.
	stdout = &uartout ;
	printf("#OptiMouse Server has started and is awaiting your input.\n");
	optimouse.init();
}

void loop() {
	// process new command line
	if (inputComplete) {
		process_command_line(input); 
		// clear the input buffer
		input.truncate();
		inputComplete = false;
	}
}

/*
 SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
	char const TERMINATOR = '\n';
	while(Serial.available()) {
		char ch = (char)Serial.read();
		input += ch;
		// if the incoming character is a newline, set a flag
		// so the main loop can do something about it
		if (ch == TERMINATOR) {
			inputComplete = true;
			return;		// let the main loop process the new command line
		} 
	}
}

Buffer::Chunk read_bool(Buffer::Chunk const &token, bool &b, bool &ok) {
	ok = true;
	Buffer::Chunk p = token.next_token(WHITESPACE);
	if(0 == p.cmp("true") || 0 == p.cmp("1")) {
		b = true;
	} else if(0 == p.cmp("false") || 0 == p.cmp("0")) {
		b = false;
	} else {
		char s[MAX_TOKEN_SIZE];
		p.c_str(s);
		printf("ERROR: Invalid parameter '%s'.\n", s);
		ok = false;
	}
	return p;
}

void process_command_line(Buffer const &line) {
	Buffer::Chunk cmd = line.next_token(0, WHITESPACE);
	if(0 == cmd.cmp("frame_size")) {
		printf("frame_size %d %d\n", optimouse.frame_x(), optimouse.frame_y());
	} else if(0 == cmd.cmp("displacement")) {
		printf("displacement %d %d\n", optimouse.dx(), optimouse.dy());
	} else if(0 == cmd.cmp("reset")) {
		bool b, ok;
		Buffer::Chunk p = read_bool(cmd, b, ok);
		if(ok) {
			optimouse.reset(b);
			printf("reset %d\n", b);
		}
	} else if(0 == cmd.cmp("power_down")) {
		bool b, ok;
		Buffer::Chunk p = read_bool(cmd, b, ok);
		if(ok) {
			optimouse.power_down(b);
			printf("power_down %d\n", b);
		}
	} else if(0 == cmd.cmp("force_awake_mode")) {
		bool b, ok;
		Buffer::Chunk p = read_bool(cmd, b, ok);
		if(ok) {
			optimouse.force_awake_mode(b);
			printf("force_awake_mode %d\n", b);
		}
	} else if(0 == cmd.cmp("product_id")) {
		printf("product_id %02X %02X\n", (unsigned int)optimouse.product_id(), (unsigned int)optimouse.inverse_product());
	} else if(0 == cmd.cmp("is_awake")) {
		printf("is_awake %s\n", optimouse.is_awake() ? "1" : "0");
	} else if(0 == cmd.cmp("squal")) {
		printf("squal %02X\n", (unsigned int)optimouse.squal());
	} else if(0 == cmd.cmp("maximum_pixel")) {
		printf("maximum_pixel %02X\n", (unsigned int)optimouse.maximum_pixel());
	} else if(0 == cmd.cmp("minimum_pixel")) {
		printf("minimum_pixel %02X\n", (unsigned int)optimouse.minimum_pixel());
	} else if(0 == cmd.cmp("pixel_sum")) {
		printf("pixel_sum %02X\n", (unsigned int)optimouse.pixel_sum());
	} else if(0 == cmd.cmp("shutter")) {
		printf("shutter %04X\n", (unsigned int)optimouse.shutter());
	} else if(0 == cmd.cmp("pixel_data")) {
		int frame_size = optimouse.frame_x()*optimouse.frame_y();
		uint8_t frame[frame_size];
		optimouse.pixel_data(frame);
		printf("pixel_data ");
		for(int i=0; i < frame_size; ++i) {
			printf("%02X", (unsigned int)frame[i]);
		}
		printf("\n");
	} else if(0 == cmd.cmp("device_info")) {
		printf("product_id %02X %02X\n", (unsigned int)optimouse.product_id(), (unsigned int)optimouse.inverse_product());
		printf("frame_size %d %d\n", optimouse.frame_x(), optimouse.frame_y());
		printf("is_awake %s\n", optimouse.is_awake() ? "1" : "0");
	} else if(0 == cmd.cmp("frame_info")) {
		printf("displacement %d %d\n", optimouse.dx(), optimouse.dy());
		printf("squal %02X\n", (unsigned int)optimouse.squal());
		printf("minimum_pixel %02X\n", (unsigned int)optimouse.minimum_pixel());
		printf("maximum_pixel %02X\n", (unsigned int)optimouse.maximum_pixel());
		printf("pixel_sum %02X\n", (unsigned int)optimouse.pixel_sum());
		printf("shutter %04X\n", (unsigned int)optimouse.shutter());
		int frame_size = optimouse.frame_x()*optimouse.frame_y();
		uint8_t frame[frame_size];
		optimouse.pixel_data(frame);
		printf("pixel_data ");
		for(int i=0; i < frame_size; ++i) {
			printf("%02X", (unsigned int)frame[i]);
		}
		printf("\n");
	} else if(0 == cmd.cmp("?") || 0 == cmd.cmp("help")) {
		printf("frame_size\ndisplacement\nreset bool\npower_down bool\nforce_awake_mode bool\nproduct_id\nis_awake\nsqual\nminimum_pixel\nmaximum_pixel\npixel_sum\nshutter\npixel_data\ndevice_info\nframe_info\n");
	} else {
		char s[MAX_TOKEN_SIZE];
		cmd.c_str(s);
		printf("ERROR: Unknown command '%s'.\n", s);
	}
	printf("\n");	// terminate the response with an empty line
}

