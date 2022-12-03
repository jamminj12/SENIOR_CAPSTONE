#include "HX711.h" // HX711 library for Arduino: https://github.com/bogde/HX711


// This script was written newly for the 22-23 capstone team to interface with the AnyLoad Load Cells. 
// No full documentation was left with the previous team's work.
// All wiring connections remained unchanged from the 2021-2022 capstone team, but needed to be remapped and documented.


// HX711 circuit wiring (scaleA)
const int LOADCELL_DOUT_PINA = 8;
const int LOADCELL_SCK_PINA = 4;

// (scaleB)
const int LOADCELL_DOUT_PINB = 9;
const int LOADCELL_SCK_PINB = 5;

// (scaleC)
const int LOADCELL_DOUT_PINC = 10;
const int LOADCELL_SCK_PINC = 3;

// (scaleD)
const int LOADCELL_DOUT_PIND = 11;
const int LOADCELL_SCK_PIND = 7;

HX711 scaleA;
HX711 scaleB;
HX711 scaleC;
HX711 scaleD;

// this value is used to convert the raw data to "human readable" data (measure units)
// current calibration factors all set to 1 because the exact needed values for the load cells has not yet been determined.
float calibration_factorA = 1;
float calibration_factorB = 1;
float calibration_factorC = 1;
float calibration_factorD = 1;

void setup() {
  Serial.begin(57600);
  scaleA.begin(LOADCELL_DOUT_PINA, LOADCELL_SCK_PINA);
  scaleA.set_scale(calibration_factorA); //Certain value for each sensor
  scaleA.tare(); // assuming there is no weight on the force sensor
  scaleB.begin(LOADCELL_DOUT_PINB, LOADCELL_SCK_PINB);
  scaleB.set_scale(calibration_factorB); 
  scaleB.tare(); 
  scaleC.begin(LOADCELL_DOUT_PINC, LOADCELL_SCK_PINC);
  scaleC.set_scale(calibration_factorC); 
  scaleC.tare(); 
  scaleD.begin(LOADCELL_DOUT_PIND, LOADCELL_SCK_PIND);
  scaleD.set_scale(calibration_factorD); 
  scaleD.tare();

  // BTSerial.println("Send START to read scales")
  Serial.println("Send START to read scales");

}



void loop() {

  // if (scaleA.is_ready()) {
    long readingA = scaleA.get_units(); // a number inside get_units() is an average of that many values
    long readingB = scaleB.get_units();
    long readingC = scaleC.get_units();
    long readingD = scaleD.get_units();
    Serial.print(readingA);
    Serial.print(",");
    Serial.print(readingB);
    Serial.print(",");
    Serial.print(readingC);
    Serial.print(",");
    Serial.println(readingD);

  // } else {
  //   Serial.println("HX711 not found. Something bad happened!");
  // }

  delay(100); // in milliseconds, 1000 milliseconds in a second.
  
}
