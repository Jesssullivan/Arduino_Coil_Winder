/*
   An Arduino sketch to wind a coil with two bipolar stepper motors
   Currently testing with DRV8825
   :)
   A WIP by Jess Sullivan
*/

// wire width in mm
const float WireWidth = .1;
// coil width in mm - wind back and forth
const int CoilWidth = 7;


// arduino pin connections
#define Y_dir 2  // guide
#define Y_step 3
#define X_dir 4  // coil
#define X_step 5

// microstepping arduino pin connections
#define X_M0 6
#define X_M1 7
#define X_M2 8
#define Y_M0 9
#define Y_M1 10
#define Y_M2 11

// motor definitions
#define rev 200;

// motor definitions
const float rate = .01;

// winder guide pitch in mm
const int pitch = 2;

// winder guide ratio
const float reduction = pitch / WireWidth;
const float Y_ratio = rate * reduction;

// winder back and forth counting
const int OneWind = CoilWidth / WireWidth * 32;  // 70
long HaveWound = 0;  // start counter at zero
int dir = LOW;

void setup()
{
  // setup outputs
  pinMode(X_dir, OUTPUT);
  pinMode(X_step, OUTPUT);
  pinMode(Y_dir, OUTPUT);
  pinMode(Y_step, OUTPUT);

  // microstepping pins
  pinMode(X_M0, OUTPUT);
  pinMode(X_M1, OUTPUT);
  pinMode(X_M2, OUTPUT);
  pinMode(Y_M0, OUTPUT);
  pinMode(Y_M1, OUTPUT);
  pinMode(Y_M2, OUTPUT);
  // 1/32 microstepping enable
  digitalWrite(X_M0, HIGH);
  digitalWrite(X_M1, HIGH);
  digitalWrite(X_M2, HIGH);
  digitalWrite(Y_M0, HIGH);
  digitalWrite(Y_M1, HIGH);
  digitalWrite(Y_M2, HIGH);
}

// start timers
unsigned long X_time = millis();
unsigned long Y_time = millis();

void loop()
{
  // motor directions
  digitalWrite(X_dir, LOW);
  digitalWrite(Y_dir, dir);
  // pulse motors
  {
      digitalWrite(X_step, LOW);
    if (millis() - X_time > rate)
    {
      digitalWrite(X_step, HIGH);
      X_time = millis();
      HaveWound++;  // counter
    }
    digitalWrite(Y_step, LOW);
    if (millis() - Y_time > rate)
    {
      digitalWrite(Y_step, HIGH);
      Y_time = millis();
    }
    if (HaveWound >= OneWind) {
      HaveWound = 0;  // reset counter
      if (dir == LOW)
      {
        dir = HIGH;
      } else {
        dir = LOW;
      }
    }
  }
}
