
/* Sweep
 by BARRAGAN <http://barraganstudio.com>
 This example code is in the public domain.

 modified 8 Nov 2013
 by Scott Fitzgerald
 http://www.arduino.cc/en/Tutorial/Sweep

 This is the code that moves the cars and lights neopixels.
 Requires two servos, 2 rows of 4 Adafruit neopixels, and an Arduino board.
*/

#include <Servo.h>
#include <Adafruit_NeoPixel.h>

#ifdef __AVR__
#include <avr/power.h>
#endif

#define PIN0 2
#define PIN1 5

Servo myservo;  
Servo myservo2;

Adafruit_NeoPixel strip0 = Adafruit_NeoPixel(4, PIN0, NEO_GRB + NEO_KHZ800);
Adafruit_NeoPixel strip1 = Adafruit_NeoPixel(4, PIN1, NEO_GRB + NEO_KHZ800);

int pos = 0;
int pos2 = 0; // variable to store the servo position

int oldpos = 0;
int oldpos2 = 0;

byte inputbuffer[2];

void setup() {
  Serial.begin(9600);
  myservo.attach(9);
  myservo2.attach(7);  // attaches the servo on pin 9 to the servo object
  myservo.write(90);
  myservo2.write(90);
  delay(3000);

  myservo.write(30);
  myservo2.write(30);
  delay(3000);

  myservo.write(120);
  myservo2.write(120);
  delay(3000);
  
  strip0.begin();
  strip0.show(); // Initialize all pixels to 'off'
  strip1.begin();
  strip1.show(); // Initialize all pixels to 'off'

  inputbuffer[0] = -100;
  inputbuffer[1] = -100;
  pos = 0;
  pos2 = 0;
  myservo.write(30);
  myservo2.write(30);
}

void colorWipe(uint32_t c, uint8_t wait) {
  for (uint16_t i = 0; i < strip1.numPixels(); i++) {
    strip0.setPixelColor(i, c);
    strip0.show();
    strip1.setPixelColor(i, c);
    strip1.show();
    //strip2.setPixelColor(i, c);
    //strip2.show();
    delay(wait);
  }
}

void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for (j = 0; j < 256 * 5; j++) { // 5 cycles of all colors on wheel
    for (i = 0; i < strip1.numPixels(); i++) {
      strip0.setPixelColor(i, Wheel((0   + (i * 256 / strip0.numPixels()) + j) & 255));
      strip1.setPixelColor(i, Wheel((85  + (i * 256 / strip1.numPixels()) + j) & 255));
      //strip2.setPixelColor(i, Wheel((170 + (i * 256 / strip2.numPixels()) + j) & 255));
    }
    strip0.show();
    strip1.show();
    //strip2.show();
    delay(wait);
  }
}

void loop() {
  //Commented code was used for input tests
  //int chance = random(0, 100);
  //int chance2 = random(0, 100);

  //if (chance > 90)
  //{
  //  pos += 1;
  //}
  //if (chance2 > 90)
  //{
  //  pos2 += 1;
  //}

  if (pos >= 120)
  {
    pos = 120;
  }
  if (pos2 >= 120)
  {
    pos2 = 120;
  }

  strip0.setPixelColor(0,0,0,0);
  strip0.setPixelColor(1,0,0,0);
  strip0.setPixelColor(2,0,0,0);
  strip0.setPixelColor(3,0,0,0);
  strip1.setPixelColor(0,0,0,0);
  strip1.setPixelColor(1,0,0,0);
  strip1.setPixelColor(2,0,0,0);
  strip1.setPixelColor(3,0,0,0);
  if (pos > 52)
  {
    strip0.setPixelColor(0, Wheel(21));
  }
  if (pos > 74)
  {
    strip0.setPixelColor(1, Wheel(42));
  }
  if (pos > 96)
  {
    strip0.setPixelColor(2, Wheel(63));
  }
  if (pos >= 120)
  {
    strip0.setPixelColor(3, Wheel(42));
  }
  strip0.show();

  if (pos2 > 52)
  {
    strip1.setPixelColor(0, Wheel(255));
  }
  if (pos2 > 74)
  {
    strip1.setPixelColor(1, Wheel(234));
  }
  if (pos2 > 96)
  {
    strip1.setPixelColor(2, Wheel(213));
  }
  if (pos2 >= 120)
  {
    strip1.setPixelColor(3, Wheel(192));
  }
  strip1.show();

  if (oldpos != pos)
  {
    myservo.write(pos);
  }
  if (oldpos2 != pos2)
  {
    myservo2.write(pos2);
  }
  delay(10);

  oldpos = pos;
  oldpos2 = pos2;

  //if (pos == 120 && pos2 == 120)
  //{
  //  delay(7000);
  //  pos = 0;
  //  pos2 = 0;
  //  myservo.write(0);
  //  myservo2.write(0);
  //  strip0.setPixelColor(0, 0, 0, 0);
  //  strip1.setPixelColor(0, 0, 0, 0);
  //  strip0.setPixelColor(1, 0, 0, 0);
  //  strip1.setPixelColor(1, 0, 0, 0);
  //  strip0.setPixelColor(2, 0, 0, 0);
  //  strip1.setPixelColor(2, 0, 0, 0);
  //  strip0.setPixelColor(3, 0, 0, 0);
  //  strip1.setPixelColor(3, 0, 0, 0);
  //  strip0.show();
  //  strip1.show();
  //  
  //}
}

void serialEvent()
{
  while (Serial.available() >= 2) {
    Serial.readBytes(inputbuffer, 2);
    pos = scaleProgress(inputbuffer[0]);
    pos2 = scaleProgress(inputbuffer[1]);
  }
}

int scaleProgress(byte b)
{
  return b;
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if (WheelPos < 85) {
    return strip1.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  }
  if (WheelPos < 170) {
    WheelPos -= 85;
    return strip1.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
  WheelPos -= 170;
  return strip1.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
}

