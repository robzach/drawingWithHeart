// some programming detritus. Use or repurpose as needed.

void circleMaker() {
  println("drawing circle");
  int xOffset = 6000; // center of circle in x
  int yOffset = 6000; // center of circle in y
  int radius = 5000; // radius of circle
  plotterPort.write("PU;PA" + xOffset + "," + yOffset + ";"); // center the pen
  delay(1000); // give it time to get there
  //plotterPort.write("PD;"); // lower the pen
  int x, y;
  int circleSegments = 1000; // how many pieces to cut the circle in to (at 5000, had errors, probably from buffer overflow)
  for (int i = 0; i < circleSegments + 1; i++) {
    float theta = map(i, 0, circleSegments, 0, TWO_PI);
    x = int(xOffset + (radius * sin(theta)));
    y = int(yOffset + (radius * cos(theta)));
    String circleMessage = "PA" + x +"," + y + ";";
    plotterPort.write(circleMessage);
    println(circleMessage);
    //delay(2);
  }
  println("done drawing circle");
}


void linearBufferTest() { // schooch along, one point at a time, to see empirically where in the line the plotter's buffer overflows
  int commandsSent = 0;
  plotterPort.write("PU;PA0,0;PD;"); // pen to origin, ready to write
  delay(1000); // give it time to get there
  // tell it to go all the way across 24" paper, one little step at a time
  // while it's drawing, somewhere it'll hit a bump or change speeds
  // measure how far the line gets before that happens, in inches,
  // and divide by 1000, to find how many PAx,y; commands the buffer can hold.


  for (int y = 0; y < 23000, y++) {
    plotterPort.write("PA0," + y + ";");
  }


  // MODELING FILLING BUFFER IMMEDIATELY AND ALLOWING IT TO EMPTY ITSELF OVER TIME (didn't really work)
  //for (int x = 0; x < 1000; x+=100) {
  //  for (int y = 0; y < 23000; y+=10) {
  //    plotterPort.write("PA" + x + "," + y + ";");
  //    commandsSent++;
  //    if (commandsSent>3000) {
  //      delay(20000); // wait for the machine to do stuff if you've already sent many commands
  //      commandsSent = 0;
  //    }
  //  }
  //}
}


// spiralled out of control, literally: radius kept getting incremented with radiusDeflection pulse data but never decremented
void circleMakerPlusPulse() {
  println("drawing circle");
  int xOffset = 6000; // center of circle in x
  int yOffset = 6000; // center of circle in y
  int radius = 5000; // radius of circle
  plotterPort.write("PU;PA" + xOffset + "," + yOffset + ";"); // center the pen
  delay(1000); // give it time to get there
  int x, y;
  int circleSegments = 1000; // how many pieces to cut the circle in to (at 5000, had errors, probably from buffer overflow)
  for (int i = 0; i < circleSegments + 1; i++) {
    float theta = map(i, 0, circleSegments, 0, TWO_PI);
    int radiusDeflection = int(constrain(map(Sensor, 400, 800, 0, 250), 0, 250));
    radius += radiusDeflection;
    x = int(xOffset + (radius * sin(theta)));
    y = int(yOffset + (radius * cos(theta)));
    String circleMessage = "PA" + x +"," + y + ";";
    plotterPort.write(circleMessage);
    delay(20);
  }
  println("done drawing circle");
}