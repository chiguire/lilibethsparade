/***************************************************
  This sketch the Bitmap drawing example for the 
  Adafruit ILI9341 Breakout and Shield from Adafruit
  ----> http://www.adafruit.com/products/1651

  Requires an Arduino Uno or similar to make it work.
 ****************************************************/

#include <Adafruit_GFX.h>    // Core graphics library
#include "Adafruit_ILI9341.h" // Hardware-specific library
#include <SPI.h>
#include <SD.h>

// TFT display and SD card will share the hardware SPI interface.
// Hardware SPI pins are specific to the Arduino board type and
// cannot be remapped to alternate pins.  For Arduino Uno,
// Duemilanove, etc., pin 11 = MOSI, pin 12 = MISO, pin 13 = SCK.

#define TFT_DC 6
#define TFT_CS 5
Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC);

#define SD_CS 4

#define IDLE_WAITING 0
#define ONE_HAND_WAITING 1
#define TWO_HANDS_WAITING 2
#define CLOSE_HAND_WAITING 3
#define READY_STARTING 4
#define SET_STARTING 5
#define GO_STARTING 6
#define PLAYING 7
#define WINNER_PLAYER_LEFT 8
#define WINNER_PLAYER_RIGHT 9

int imageDrawn = 0;
int lastImageDrawn = -1;
int animFrame = 0;

const int f_x = 0;
const int f_y = 40;

void setup(void) {
  Serial.begin(9600);
  tft.begin();
  tft.setRotation(0);
  tft.fillScreen(ILI9341_BLACK);
  SD.begin(SD_CS);
}

void loop() {
  if (imageDrawn != lastImageDrawn)
  {
    Serial.print("Drawing image ");
    Serial.println(imageDrawn);
    switch (imageDrawn)
    {
        case IDLE_WAITING:     idle_waiting(); break;
        case ONE_HAND_WAITING: one_hand_waiting(); break;
        case TWO_HANDS_WAITING: two_hands_waiting(); break;
        case CLOSE_HAND_WAITING: close_hand_waiting(); break;
        case READY_STARTING: ready_starting(); break;
        case SET_STARTING: set_starting(); break;
        case GO_STARTING: go_starting(); break;
        case PLAYING: playing(); break;
        case WINNER_PLAYER_LEFT: winner_player_left(); break;
        case WINNER_PLAYER_RIGHT: winner_player_right(); break;
    }
    lastImageDrawn = imageDrawn;
    Serial.println("Done");
  }
  else
  {
    updateCurrentImage();
  }
  delay(50);

  //bmpDraw("queen2.bmp", f_x, f_y);
  //bmpDraw("queen.bmp", 0, 40);
  //bmpDraw("queen2.bmp", 0, 40);
  //bmpDraw("philip.bmp", 0, 40);
  //bmpDraw("bigben.bmp", 0, 40);
  //bmpDraw("bigbenne.bmp", 0, 40);
}

void serialEvent()
{
  while (Serial.available()) {
    
    char inChar = (char)Serial.read();
    if (inChar == '0')
    {
      imageDrawn = IDLE_WAITING;
      Serial.println("IDLE_WAITING");
    }
    else if (inChar == '1')
    {
      imageDrawn = ONE_HAND_WAITING;
      Serial.println("ONE_HAND_WAITING");
    }
    else if (inChar == '2')
    {
      imageDrawn = TWO_HANDS_WAITING;
      Serial.println("TWO_HANDS_WAITING");
    }
    else if (inChar == '3')
    {
      imageDrawn = CLOSE_HAND_WAITING;
      Serial.println("CLOSE_HAND_WAITING");
    }
    else if (inChar == '4')
    {
      imageDrawn = READY_STARTING;
      Serial.println("READY_STARTING");
    }
    else if (inChar == '5')
    {
      imageDrawn = SET_STARTING;
      Serial.println("SET_STARTING");
    }
    else if (inChar == '6')
    {
      imageDrawn = GO_STARTING;
      Serial.println("GO_STARTING");
    }
    else if (inChar == '7')
    {
      imageDrawn = PLAYING;
      Serial.println("PLAYING");
    }
    else if (inChar == '8')
    {
      imageDrawn = WINNER_PLAYER_LEFT;
      Serial.println("WINNER_PLAYER_LEFT");
    }
    else if (inChar == '9')
    {
      imageDrawn = WINNER_PLAYER_RIGHT;
      Serial.println("WINNER_PLAYER_RIGHT");
    }
  }
}

void one_hand_waiting()
{
  
}

void two_hands_waiting()
{

}

void close_hand_waiting()
{

}

void ready_starting()
{

}

void set_starting()
{

}

void go_starting()
{

}

void playing()
{

}

void winner_player_left()
{

}

void winner_player_right()
{

}

// This function opens a Windows Bitmap (BMP) file and
// displays it at the given coordinates.  It's sped up
// by reading many pixels worth of data at a time
// (rather than pixel by pixel).  Increasing the buffer
// size takes more of the Arduino's precious RAM but
// makes loading a little faster.  20 pixels seems a
// good balance.

#define BUFFPIXEL 40

void bmpDraw(char *filename, uint8_t x, uint16_t y) {

  File     bmpFile;
  int      bmpWidth, bmpHeight;   // W+H in pixels
  uint8_t  bmpDepth;              // Bit depth (currently must be 24)
  uint32_t bmpImageoffset;        // Start of image data in file
  uint32_t rowSize;               // Not always = bmpWidth; may have padding
  uint8_t  sdbuffer[3*BUFFPIXEL]; // pixel buffer (R+G+B per pixel)
  uint8_t  buffidx = sizeof(sdbuffer); // Current position in sdbuffer
  boolean  goodBmp = false;       // Set to true on valid header parse
  boolean  flip    = true;        // BMP is stored bottom-to-top
  int      w, h, row, col;
  uint8_t  r, g, b;
  uint32_t pos = 0, startTime = millis();

  if((x >= tft.width()) || (y >= tft.height())) return;

  Serial.println();
  Serial.print(F("Loading image '"));
  Serial.print(filename);
  Serial.println('\'');

  // Open requested file on SD card
  if ((bmpFile = SD.open(filename)) == NULL) {
    //Serial.print(F("File not found"));
    return;
  }

  // Parse BMP header
  if(read16(bmpFile) == 0x4D42) { // BMP signature
    Serial.print(F("File size: ")); Serial.println(read32(bmpFile));
    (void)read32(bmpFile); // Read & ignore creator bytes
    bmpImageoffset = read32(bmpFile); // Start of image data
    Serial.print(F("Image Offset: ")); Serial.println(bmpImageoffset, DEC);
    // Read DIB header
    Serial.print(F("Header size: ")); Serial.println(read32(bmpFile));
    bmpWidth  = read32(bmpFile);
    bmpHeight = read32(bmpFile);
    if(read16(bmpFile) == 1) { // # planes -- must be '1'
      bmpDepth = read16(bmpFile); // bits per pixel
      Serial.print(F("Bit Depth: ")); Serial.println(bmpDepth);
      if((bmpDepth == 24) && (read32(bmpFile) == 0)) { // 0 = uncompressed

        goodBmp = true; // Supported BMP format -- proceed!
        Serial.print(F("Image size: "));
        Serial.print(bmpWidth);
        Serial.print('x');
        Serial.println(bmpHeight);

        // BMP rows are padded (if needed) to 4-byte boundary
        rowSize = (bmpWidth * 3 + 3) & ~3;

        // If bmpHeight is negative, image is in top-down order.
        // This is not canon but has been observed in the wild.
        if(bmpHeight < 0) {
          bmpHeight = -bmpHeight;
          flip      = false;
        }

        // Crop area to be loaded
        w = bmpWidth;
        h = bmpHeight;
        if((x+w-1) >= tft.width())  w = tft.width()  - x;
        if((y+h-1) >= tft.height()) h = tft.height() - y;

        // Set TFT address window to clipped image bounds
        tft.setAddrWindow(x, y, x+w-1, y+h-1);

        for (row=0; row<h; row++) { // For each scanline...

          // Seek to start of scan line.  It might seem labor-
          // intensive to be doing this on every line, but this
          // method covers a lot of gritty details like cropping
          // and scanline padding.  Also, the seek only takes
          // place if the file position actually needs to change
          // (avoids a lot of cluster math in SD library).
          if(flip) // Bitmap is stored bottom-to-top order (normal BMP)
            pos = bmpImageoffset + (bmpHeight - 1 - row) * rowSize;
          else     // Bitmap is stored top-to-bottom
            pos = bmpImageoffset + row * rowSize;
          if(bmpFile.position() != pos) { // Need seek?
            bmpFile.seek(pos);
            buffidx = sizeof(sdbuffer); // Force buffer reload
          }

          for (col=0; col<w; col++) { // For each pixel...
            // Time to read more pixel data?
            if (buffidx >= sizeof(sdbuffer)) { // Indeed
              bmpFile.read(sdbuffer, sizeof(sdbuffer));
              buffidx = 0; // Set index to beginning
            }

            // Convert pixel from BMP to TFT format, push to display
            b = sdbuffer[buffidx++];
            g = sdbuffer[buffidx++];
            r = sdbuffer[buffidx++];
            tft.pushColor(tft.color565(r,g,b));
          } // end pixel
        } // end scanline
        Serial.print(F("Loaded in "));
        Serial.print(millis() - startTime);
        Serial.println(" ms");
      } // end goodBmp
    }
  }

  bmpFile.close();
  if(!goodBmp) Serial.println(F("BMP format not recognized."));
}

// These read 16- and 32-bit types from the SD card file.
// BMP data is stored little-endian, Arduino is little-endian too.
// May need to reverse subscript order if porting elsewhere.

uint16_t read16(File &f) {
  uint16_t result;
  ((uint8_t *)&result)[0] = f.read(); // LSB
  ((uint8_t *)&result)[1] = f.read(); // MSB
  return result;
}

uint32_t read32(File &f) {
  uint32_t result;
  ((uint8_t *)&result)[0] = f.read(); // LSB
  ((uint8_t *)&result)[1] = f.read();
  ((uint8_t *)&result)[2] = f.read();
  ((uint8_t *)&result)[3] = f.read(); // MSB
  return result;
}

