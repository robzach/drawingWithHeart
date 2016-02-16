# drawingWithHeart

Draws a live pulse on a US Cutter MH871-MK2 pen plotter.
 
 Live plots freehand mouse drawings and/or pulse-based drawings on US Cutter MH871-MK2 plotter.
 Draws your live pulse along a straight line, in a circle, in a spiral, or in a heart shape.
 Pulse data comes via Arduino, read from World Famous Electronics's pulse oximeter. This sketch includes code
 provided by World Famous Electronics (in serialEvent) to read data off the device directly.
 
 ## Talking with the plotter via HPGL
 
 The US Cutter plotter talks in serial via the fairly ancient HPGL language. (This stands for Hewlett Packard Graphics
 Language. It's old, and it's simple.) Here are the commands this plotter understands:
 
 `IN;`    initializes the machine
 `PU;`    raises the pen
 `PD;`    lowers the pen
 `PAx,y;`  moves to x,y position, absolute from origin
 `PRx,y;`  moves to x,y position, relative from current position
 
 The plotter is not case sensitive. It does not send any acknowledge, buffer full, or ready signal as far as I've seen.
 One x or y unit is 1/1000 inch. The origin is where the pen starts after pushing the Reset button, on the right of the machine.
 Facing the machine, a leftward pen movement is postive along Y, and a paper feed towards you is positive along X.
 
 Pulse sensor is running on Arduino, using code provided by the manufacturer. Confirm that line 30
 of the Arduino code sets variable serialVisual to false before uploading to Arduino. Other than that
 the code is unchanged from that which is available at 
 <https://github.com/WorldFamousElectronics/PulseSensor_Amped_Arduino>.
 
 Code released to the public domain by the author.
 
  For Golan Levin's Interactive Art and Computational Design class at Carnegie Mellon University, 2/15/16
