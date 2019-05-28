/* 
 * An Arduino sketch to wind a coil with two bipolar stepper motors
 * Currently tested with DRV8825
 *
 * WIP by Jess Sullivan   
 * 
 * TODO:
 * wind back and forth
 * auto length start/stop based on coil perimeter
 * standalone power connections
 * start stop with SPST switch
*/

// wire width in mm
const float wire = .1;
// coil width in mm - for back and fosrth
// const int width = 7;

// connections
const int X_dir = 2;
const int X_step = 3;
const int Y_dir = 4;
const int Y_step = 5;

// motor definitions
const int rev = 200;
const int rate = 5;

// winder guide pitch in mm
const int pitch = 2;

// winder guide calculations
const float reduction = pitch / wire;
const unsigned long ratio = rate * reduction;

// add microstepping pin definitions
#define M0 4
#define M1 5
#define M2 6

void setup()
{
  // setup outputs
  pinMode(X_dir, OUTPUT);
  pinMode(X_step, OUTPUT);
  pinMode(Y_dir, OUTPUT);
  pinMode(Y_step, OUTPUT);
  
  // microstepping pins
  pinMode(M0, OUTPUT);
  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);
}

// start timers
unsigned long X_time = millis();
unsigned long Y_time = millis();

void loop()
{
  // 1/1 stepper control
  digitalWrite(M0, LOW);
  digitalWrite(M1, LOW);
  digitalWrite(M2, LOW);
 
//  1/32 microstepping
//  digitalWrite(M0, HIGH);
//  digitalWrite(M1, HIGH);
//  digitalWrite(M2, HIGH);
  
  // motor directions
  digitalWrite(X_dir, LOW);
  digitalWrite(Y_dir, LOW);
  
  // pulse motors
  {
    digitalWrite(Y_step, LOW);
    if (millis() - Y_time > ratio)
    {
      digitalWrite(Y_step, HIGH);
      Y_time = millis();
    }

    digitalWrite(X_step, LOW);
    if (millis() - X_time > rate)
    {
      digitalWrite(X_step, HIGH);
      X_time = millis();
    }
  }
}
