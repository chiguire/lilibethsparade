# Lilibeth's Parade
Code and assets repository for our Global Game Jam 2017 entry. Lilibeth's Parade is a physical/digital game.

Requires:

* A PC with a Leap Motion device. It requires at least 3 USB ports.
* Processing 3+
* 2 Arduino Uno
* Arduino Screen Shield
* 8 Adafruit Neopixels
* 2 Servos

# Arduinos

One Arduino controls the screen. Put the Arduino screen shield on it, and install the arduinoclock.ino sketch on it. Connect the Arduino to the PC (this one uses the port COM5).

The second Arduino controls the servos and the lights. Wire two strips of Neopixels for pins 2 and 5. Wire two servos to pins 9 and 7. Pins 2 and 9 are for the player from the left (the left of the Leap Motion device). Pins 5 and 7 are for the player from the right of the Leap Motion device. Install the arduinocars.inosketch on it. Connect the Arduino to the PC (this one uses the port COM6).

# PC

Install Leap Motion SDK and Drivers. Connect the Leap Motion device to the PC.
Install Processing 3+ and the Leap Motion Processing Library.
Run raspisketch.pde on Processing.

# Playing the Game

Once the game is running, the game will ask each player to put a hand on the Leap Motion device. Once this is done, the game will tell the players when to start.

The players must wave their hand like the Queen of England, so their car can reach the tower of Westminster Palace.

The first player to do so will be rewarded with a smiling picture of either Elizabeth or Philip, and the game will restart.

# Raspberry Pi

At some stage of this jam, the original plan was to use a Raspberry Pi with OpenCV (as the RPi is not supported by the Leap Motion developers). This proved too difficult so the plan was dropped in favor of the Leap Motion, but some parts of the code still refer to the RPi. Please ignore accordingly.

