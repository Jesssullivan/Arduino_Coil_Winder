///////////////////////////////////////////////////////////////////////////
//
// added a second guide stepper to coil winding sketch.
//
// WIP by Jess Sullivan 
//
// https://github.com/Jesssullivan | https://www.transscendsurvival.org/  
//
// fork of the excellent work @ https://github.com/subatomicglue/maggen
//
///////////////////////////////////////////////////////////////////////////

#include <Arduino.h>
#define ENCODER_OPTIMIZE_INTERRUPTS
#include <Encoder.h> // https://github.com/PaulStoffregen/Encoder  // added w/ ZIP 
#include <U8g2lib.h> // https://github.com/olikraus/u8g2  // added w/ ZIP 
#include <SPI.h>
#include "MotorAnimator.h"
MotorAnimator ma; // included

// wire width in mm
// TODO: configure on display w/ encoder
const float WireWidth = .1;

// winder guide pitch in mm; using reprap syle threaded rod
const int pitch = 2;

// splash text:
const char title = "WIP by Jess";

// Width of coil bobbin:
const int CoilWidth = 7;

// RAMPS14 pins:

// stepper "E" --> winder motor
#define E_STEP_PIN         26
#define E_DIR_PIN          28
#define E_ENABLE_PIN       24

// stepper "Q" --> --> guide motor
#define Q_STEP_PIN         36
#define Q_DIR_PIN          34
#define Q_ENABLE_PIN       30

///////////////////////////////////////////////////////////////////////////
// https://reprap.org/wiki/RepRapDiscount_Full_Graphic_Smart_Controller
///////////////////////////////////////////////////////////////////////////

// encoder pins  (look in Marlin, or there is a chart here: https://github.com/MarlinFirmware/Marlin/issues/7647, or they're the same as https://reprap.org/wiki/RepRapDiscount_Smart_Controller)
#define BTN_EN1 31 //[RAMPS14-SMART-ADAPTER]
#define BTN_EN2 33 //[RAMPS14-SMART-ADAPTER]
#define BTN_ENC 35 //[RAMPS14-SMART-ADAPTER]

// beeper
#define BEEPER 37 //[RAMPS14-SMART-ADAPTER] / 37 = enabled; -1 = dissabled / (if you don't like the beep sound ;-)

// SD card detect pin
#define SDCARDDETECT 49 //[RAMPS14-SMART-ADAPTER]

#define CONFIG_STEPPER_MICROSTEPPING 32     // number of microsteps on the stepper driver
#define CONFIG_STEPPER_STEPS 200            // number of stepper steps for 1 revolution
#define CONFIG_STEPPER_TOPSPEED_DELAY 1    // number of usec to delay between steps
#define CONFIG_STEPPER_STARTSPEED_DELAY 1600 // number of usec to delay between steps
#define CONFIG_STEPPER_ACCEL_TIME 1000000   // number of usec to reach topspeed

// LCD interface:
U8G2_ST7920_128X64_1_SW_SPI u8g2(U8G2_R0, 23, 17, 16);

// Encoder interface
Encoder myEnc(BTN_EN1, BTN_EN2);

// init draw:
void drawText( char* buf ) {
  u8g2.firstPage();
  do {
    u8g2.setFont(u8g2_font_ncenB14_tr);
    u8g2.drawStr( 0, 20, buf);
  } while ( u8g2.nextPage() );
}

// included button ops, residual from @ subatomicglue/maggen
class Button {
  private:
    byte mPin;
    byte mLastVal;
    byte mCurVal;
  public:
    Button(int pin);
    void update();
    bool isEdgeHigh();
    bool isEdgeLow();
    bool isHigh();
    bool isLow();
};

Button::Button(int pin) {
  mPin = pin;
}

void Button::update() {
  mLastVal = mCurVal;
  mCurVal = digitalRead(mPin) == LOW;
}
bool Button::isEdgeHigh() {
  return mCurVal == HIGH && mLastVal == LOW;
}
bool Button::isEdgeLow() {
  return mCurVal == LOW && mLastVal == HIGH;
}
bool Button::isHigh() {
  return mCurVal == HIGH;
}
bool Button::isLow() {
  return mCurVal == LOW;
}

// included Clock ops, residual from @ subatomicglue/maggen
class WallClock {
  public:
    unsigned long starttime;
    unsigned long lasttime;
    unsigned long curtime;
    WallClock() {
      init();
    }
    void update() {
      unsigned long t = curtime;
      curtime = micros();
      lasttime = t == 0 ? curtime : t;
      starttime = starttime == 0 ? curtime : starttime;
    }
    void init() {
      starttime = curtime = lasttime = 0;
    }
    void start() {
      init();
      update();
    }
    unsigned long diff() const {
      return curtime - lasttime;
    }
    unsigned long sinceStart() const {
      return curtime - starttime;
    }
    float difff() const {
      return ((float)diff()) / 1000000.0f;
    }
    float sinceStartf() const {
      return ((float)sinceStart()) / 1000000.0f;
    }
};

WallClock wallclock;
Button encbut( BTN_ENC );

void setup() {
  u8g2.begin();
  ma.init( CONFIG_STEPPER_STEPS, CONFIG_STEPPER_MICROSTEPPING, CONFIG_STEPPER_TOPSPEED_DELAY, CONFIG_STEPPER_STARTSPEED_DELAY, CONFIG_STEPPER_ACCEL_TIME );

  pinMode(Q_STEP_PIN  , OUTPUT);
  pinMode(Q_DIR_PIN    , OUTPUT);
  pinMode(Q_ENABLE_PIN    , OUTPUT); 

  pinMode(E_STEP_PIN  , OUTPUT);
  pinMode(E_DIR_PIN    , OUTPUT);
  pinMode(E_ENABLE_PIN    , OUTPUT);

  pinMode(BTN_EN1    , INPUT_PULLUP);
  pinMode(BTN_EN2    , INPUT_PULLUP);
  pinMode(BTN_ENC    , INPUT_PULLUP);

  digitalWrite(BEEPER, LOW);

  digitalWrite(E_ENABLE_PIN    , LOW); // HIGH disable, LOW enable
  digitalWrite(Q_ENABLE_PIN    , LOW);

  encbut.update();

  // splashscreen
  const int animBufSize = 25;
  char animBuf[animBufSize];
  for (int x = 0; x < animBufSize; ++x) {
    int xx = x % animBufSize;
    memset( animBuf, ' ', animBufSize - 1 );
    animBuf[animBufSize - 1] = '\0';
    animBuf[xx] = '*';
    drawText( animBuf );
  }
  // defined @ top of doc:
  drawText(title);  
  delay(1000);
}

// residual values from @ subatomicglue/maggen
long x = 0;     // current loop count (or step count while turning)
float xt = 0.0f;     // current loop time (or step time while turning)
#define direction -1 // pos => fwd, neg => backward
boolean running = false;  // is the stepper running
long count = 0; // number of turns to take
float amt_left = 0;
int enc_left = 1;

// added values:
const float reWind = (200 * 32) / pitch * CoilWidth;  // for back and forth
// winder back and forth counting
int dir = LOW;


// counter int "c" to monitor rotation ratio between E --> Q:
int c = 0;
int tc = 0;  // total counter for back and forth
const float reduction = pitch / WireWidth;  // rotation ratio

void loop () {
  wallclock.update();
  xt = wallclock.sinceStartf();

  encbut.update();
  bool encoderbutton = encbut.isEdgeHigh();
  if (!running) {
    int enc = -myEnc.read();
    if (amt_left > 0.0f && enc_left != enc) {
      amt_left = 0.0f;
      //enc_left = 0.0f;
      enc = enc_left;
    }
    myEnc.write( -(enc >= 1 ? enc : 1) ); // change/correct the value
    if (encoderbutton) {
      running = true;
      x = 0;
      wallclock.init();
      drawText( "Computing..." );
      ma.start( amt_left > 0.0f ? amt_left : enc );
      drawText( "Running" );
      return;
    }
    if ((x % 5000) == 0) { // draw every 5000'th time
      char buf[256];
      if (amt_left > 0.0f)
        sprintf( buf, "Left: %d", (int)amt_left );
      else
        sprintf( buf, "Count: %d", enc );
      drawText( buf );
    } else {
      //delayMicroseconds(1);
    }
  } else {  
    
    // movement:
    
    digitalWrite(Q_DIR_PIN, dir);  // direction for back and forth
    digitalWrite(E_STEP_PIN, LOW);
    digitalWrite(E_STEP_PIN, HIGH); 
    
    ++c;  // increments; one "LOW --> HIGH" completed
    ++tc;
    
    if (c >= reduction) {  // steps "Q", reset "c"
      digitalWrite(Q_STEP_PIN, LOW);
      digitalWrite(Q_STEP_PIN, HIGH);
      c = 0;
    }
    if (tc >= reWind) {  // steps "Q", reset "c"
      dir = (dir == LOW) ? HIGH : LOW;
      tc = 0;
    }
  // finally-
    delayMicroseconds(ma.getDelay());
    ma.next();
      if (encoderbutton || !ma.isRunning()) {
      amt_left = encoderbutton ? ma.amtLeft() : 0.0f;
      enc_left = -myEnc.read();
      running = false;
      wallclock.init();
      return;
    }
  }
  ++x;
}
