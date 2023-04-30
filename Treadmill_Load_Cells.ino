#include "HX711.h"  // HX711 library for Arduino: https://github.com/bogde/HX711

// This script was written newly for the 22-23 capstone team to interface with the ANYLOAD Load Cells.

// HX711 circuit wiring (scaleA - front left)
const int LOADCELL_DOUT_PINA = 8;
const int LOADCELL_SCK_PINA = 4;

// (scaleB - front right)
const int LOADCELL_DOUT_PINB = 9;
const int LOADCELL_SCK_PINB = 5;

// (scaleC - back right)
const int LOADCELL_DOUT_PINC = 10;
const int LOADCELL_SCK_PINC = 3;

// (scaleD - back left)
const int LOADCELL_DOUT_PIND = 11;
const int LOADCELL_SCK_PIND = 7;

HX711 scaleA;
HX711 scaleB;
HX711 scaleC;
HX711 scaleD;

bool startFlag = false;
bool tareFlag = false;

void setup() {
  Serial.begin(9600);
  scaleA.begin(LOADCELL_DOUT_PINA, LOADCELL_SCK_PINA);
  scaleA.tare();  // assuming there is no weight on the force sensor
  scaleB.begin(LOADCELL_DOUT_PINB, LOADCELL_SCK_PINB);
  scaleB.tare();
  scaleC.begin(LOADCELL_DOUT_PINC, LOADCELL_SCK_PINC);
  scaleC.tare();
  scaleD.begin(LOADCELL_DOUT_PIND, LOADCELL_SCK_PIND);
  scaleD.tare();
  Serial.println("Send START to read scales");
}

void loop() {
  // Wait for START command from MATLAB
  while (Serial.available() > 0) {
    String str = Serial.readString();
    if (str.indexOf("START") > -1) {
      startFlag = true;
    } else if (str.indexOf("TARE") > -1) {
      tareFlag = true;
      Serial.println("TARE");
    } else if (str.indexOf("END") > -1) {
      startFlag = false;
      // Serial.println("Ending...");
      Serial.println("Send START to read scales");
    }
  }
  if (startFlag) {
    // a number inside get_units() is an average of that many values
    // 0.01377888 is the calibration factor that converts the load cell output into lb.
    // This can be converted back into newtons in post-processing 
    long readingA = scaleA.get_units() * 0.01377888;
    long readingB = scaleB.get_units() * 0.01377888;
    long readingC = scaleC.get_units() * 0.01377888;
    long readingD = scaleD.get_units() * 0.01377888;

    Serial.print(readingA);
    Serial.print(",");
    Serial.print(readingB);
    Serial.print(",");
    Serial.print(readingC);
    Serial.print(",");
    Serial.println(readingD);
  }
  if (tareFlag) {
    startFlag = false;
    setup();
    tareFlag = false;
  }
}
