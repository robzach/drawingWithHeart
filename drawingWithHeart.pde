/*

 Drawing With Heart
 by Robert Zacharias <rz@rzach.me> for Golan Levin's Interactive Art and Computational Design
 class at Carnegie Mellon Unversity, 2/15/16
 
 Live plots freehand mouse drawings and/or pulse-based drawings on US Cutter MH871-MK2 plotter.
 Draw live pulse along a straight line, in a circle, in a spiral, or in a heart shape.
 Pulse data comes via Arduino, read from World Famous Electronics's pulse oximeter. This sketch includes code
 provided by World Famous Electronics (in serialEvent) to read data off the device directly.
 
 The US Cutter plotter talks in serial via the fairly ancient HPGL language. Here are the commands it understands:
 IN;    initializes the machine
 PU;    raises the pen
 PD;    lowers the pen
 PAx,y;  moves to x,y position, absolute from origin
 PRx,y;  moves to x,y position, relative from current position
 The plotter is not case sensitive. It does not send any acknowledge, buffer full, or ready signal as far as I've seen.
 One x or y unit is 1/1000 inch. The origin is where the pen starts after pushing Reset button, on the right of the machine.
 Facing the machine, a leftward pen movement is postive along Y, and a paper feed towards you is positive along X.
 
 Pulse sensor is running on Arduino, using code provided by the manufacturer. Confirm that line 30
 of the Arduino code sets variable serialVisual to false before uploading to Arduino. Other than that
 the code is unchanged from that which is available at 
 <https://github.com/WorldFamousElectronics/PulseSensor_Amped_Arduino>.
 
 Code released to the public domain by the author.
 
 */

import processing.serial.*;
Serial plotterPort; // to talk to US Cutter MH871-MK2
Serial arduinoPort; // to talk to Arduino Uno with pulse sensor

long timer;
int wait = 20; // milliseconds between sending commands to plotter. Works fine for short distances between points.

// variables for drawing straight-line pulses
long distBetweenRows = 500;
long rowNumber = 0;
int y;

// variables for use with pulse sensor (see serialEvent tab)
Boolean drawPulse = false;
String inString;
int Sensor, BPM, IBI;
Boolean beat;

void setup() {

  size(800, 800);

  //println(Serial.list()); // for finding serial devices' names. Can also look in /dev/tty.*
  String portName = "/dev/cu.KeySerial1"; // fixed alias for US Cutter MH871-MK2 via Keyspan USA-19HS serial adapter
  plotterPort = new Serial(this, portName, 19200); // set this speed on the plotter's interface!
  println("plotterPort = " + plotterPort); // diagnostic, to confirm connection
  arduinoPort = new Serial(this, "/dev/cu.usbmodem1421", 115200); // Arduino with pulse sensor
  println("arduinoPort = " + arduinoPort); // diagnostic, to confirm connection

  plotterPort.write("IN;PU;PA0,0;"); // start communication, go to home position, raise pen
  println("homed");
  timer = millis();
}

void draw() {


  // TO DRAW LIVE FREEHAND WITH THE MOUSE, UNCOMMENT THIS BLOCK:
  //int sideToSideScale = int(map(mouseX,0,800,24000,0));
  //int upDownScale = int(map(mouseY,0,800,24000,0));
  //plotterPort.write("PA" + upDownScale + "," + sideToSideScale + ";");
  //delay(5);


  // block below is activated only when drawPulse is true (see keyPressed section)
  if ( y < 23000) { // don't run off the edge of the 24" paper
    if (millis() - timer > wait && drawPulse) {
      int xDeflection = int(constrain(map(Sensor, 400, 800, 0, 250), 0, 250));
      y += 10; // move 1/100 of an inch down the value
      long xWithRow = xDeflection  + (distBetweenRows * rowNumber);
      String pulseMessage = "PA" + xWithRow + "," + y + ";";
      plotterPort.write(pulseMessage);
      timer = millis();
      //println(xWithRow);
    }
  } else if (y >= 23000) {
    rowNumber++; // move one row up
    long xRowDisplacement = (distBetweenRows * rowNumber);
    plotterPort.write("PU;PA" + xRowDisplacement + ",0;");
    delay(2000); // give it time to get back to the start of the row;
    plotterPort.write("PD");
    y = 0;
  }
}

// keyboard commands
void keyPressed() {
  if (key == 'u') plotterPort.write("PU;"); // raise pen
  if (key == 'd') plotterPort.write("PD;"); // lower pen
  
  if (key == 'h') heart();
  if (key == 's') spiralMakerPlusPulse();
  if (key == 'l') pulseCircle();
  if (key == 'p') { // toggle straight-line pulse drawing on and off
    drawPulse = !drawPulse;
    if (drawPulse) plotterPort.write("PD;");
    else plotterPort.write("PU;");
  }

  if (key == 'c') circleMaker();
  if (key == 't') linearBufferTest();
  if (key == '2') circleMakerPlusPulse();
}

void mousePressed() { // put pen down when mouse clicked (for freehand drawing)
  plotterPort.write("PD;");
}

void mouseReleased() { // raise pen when mouse released (for freehand drawing)
  plotterPort.write("PU;");
}

void heart() {
  //cardioid math: r = t { 2 - 2*sin(theta) + [(sqrt(abs(cos(theta))) / (sin(theta) + 1.8)] * sin(theta) } , use t as a multiplier
  // at t = 2000, draws heart about 10" in diameter

  int xCircleCenter = 12000; // center of circle in x
  int yCircleCenter = 12000; // center of circle in y
  int xStart = xCircleCenter; // radius
  int yStart = yCircleCenter; // diameter
  int circleSegments = 5000; // how many pieces to cut the drawing path in to
  //segments: 5000/5" radius worked well, so 1000 segments per inch of radius seems reasonable

  plotterPort.write("PU;PA" + xStart + "," + yStart + ";"); // center the pen
  delay(1000); // give it time to get there
  int x, y;

  Boolean firstRun = true;
  for (int i = 0; i < circleSegments + 1; i++) {
    while ((millis() - timer) < wait) { // hold until wait time has passed
      ;
    }
    float theta = map(i, 0, circleSegments, 0, TWO_PI);
    int t = 2000; // multiplier
    int radius = int( t * ( 2 - (2*sin(theta)) + (((sqrt(abs(cos(theta))) / (sin(theta) + 1.8))) * sin(theta)))); // heart shape
    int radiusDeflection = int(constrain(map(Sensor, 400, 1000, 0, 250), 0, 250));
    radius += radiusDeflection;
    x = int(xCircleCenter + (radius * sin(theta)));
    y = int(yCircleCenter + (radius * cos(theta)));
    String pulseMessage = "PA" + x + "," + y + ";";
    plotterPort.write(pulseMessage);
    if (firstRun) { // put pen down when already hovering over first point
      plotterPort.write("PD;");
      firstRun = false;
    }
    //println(pulseMessage); // debugging
    timer = millis();
  }
  plotterPort.write("PU;PA18000,0;"); // present drawing when done
}

void pulseCircle() {
  int xCircleCenter = 12000; // center of circle in x
  int yCircleCenter = 12000; // center of circle in y
  int xStart = xCircleCenter; // radius
  int yStart = yCircleCenter * 2; // diameter
  int circleSegments = 12000; // how many pieces to cut the circle in to (at 5000, had errors, probably from buffer overflow)
  //segments: 5000/5" radius worked well, so 1000 segments per inch of radius
  // this 12" radius circle should be drawn with 12000 segments

  plotterPort.write("PU;PA" + xStart + "," + yStart + ";"); // center the pen
  delay(1000); // give it time to get there
  plotterPort.write("PD;"); // lower the pen
  int x, y;

  for (int i = 0; i < circleSegments + 1; i++) {
    while ((millis() - timer) < wait) {
      ;
    } // hold until wait time has passed
    int radius = 10000; // radius of circle
    float theta = map(i, 0, circleSegments, 0, TWO_PI);
    int radiusDeflection = int(constrain(map(Sensor, 400, 1000, 0, 250), 0, 250));
    radius += radiusDeflection;
    x = int(xCircleCenter + (radius * sin(theta)));
    y = int(yCircleCenter + (radius * cos(theta)));
    String pulseMessage = "PA" + x + "," + y + ";";
    plotterPort.write(pulseMessage);
    timer = millis();
  }
}


void spiralMakerPlusPulse() {
  int xOffset = 12000; // center of circle in x
  int yOffset = 12000; // center of circle in y
  int maxRadius = 10000; // outer radius of circle
  float radius = 250.0; // inner
  float radiusIncrement = 0.5; // how much radius will increase per circleSegment

  plotterPort.write("PU;PA" + xOffset + "," + yOffset + ";"); // center the pen
  delay(1000); // give it time to get there
  plotterPort.write("PD;"); // lower the pen
  int x, y;
  int circleSegments = 3000; // how many pieces to cut each circle in to. Trying 3000 as a compromise for a spiral
  for (int i = 0; i < int(circleSegments * ((maxRadius - radius)/radiusIncrement)); i++) {
    int radiusDeflection = int(constrain(map(Sensor, 400, 800, 0, 250), 0, 250));
    radius += radiusDeflection;
    if (radius < maxRadius) radius += radiusIncrement;
    //int intRadius = int(radius);
    float theta = map(i, 0, circleSegments, 0, TWO_PI);
    x = int(xOffset + (radius * sin(theta)));
    y = int(yOffset + (radius * cos(theta)));
    String circleMessage = "PA" + x + "," + y + ";";
    plotterPort.write(circleMessage);
    println(circleMessage);
    radius -= radiusDeflection; // subtract the heartbeat waveform back out so it doesn't spiral the radius out
    delay(wait);
  }
}