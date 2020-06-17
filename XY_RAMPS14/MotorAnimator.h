#include <assert.h>
#include <stdint.h>
#include <math.h>

#define FORCE_INLINE inline __attribute__((always_inline))

FORCE_INLINE float interp( const float i, const float val1, const float val2 )  {
  return (val2 - val1) * i + val1;
}

FORCE_INLINE float interp( const float number, const float lo, const float hi, const float val1, const float val2 )  {
  //assert( lo <= hi && "lo should be < hi" );
  const float i = (number - lo) / (hi-lo);
  return interp( i, val1, val2 );
}

FORCE_INLINE float interp_preComputeHILO( const float lo, const float hi )  {
  return 1.0f / (hi-lo);
}
FORCE_INLINE float interpHILO( const float number, const float lo, const float HILO, const float val1, const float val2 )  {
  //assert( lo <= hi && "lo should be < hi" );
  const float i = (number - lo) * HILO;
  return interp( i, val1, val2 );
}

FORCE_INLINE float clamp( float val, float lo, float hi )  {
  return val < lo ? lo : hi < val ? hi : val;
}

/*
inline uint32_t round( float val ) {
  return uint32_t(val + 0.5f);
}
*/

// simulate it forward until S1 is known
uint32_t calcS1( float t1, const float LO_DELAY, const float HI_DELAY ) {
  uint32_t steps = 0;
  float time_elapsed = 0.0f; // t0
  float delay = 0.0f;
  const float t0t1HILO = interp_preComputeHILO( 0.0f, t1 );
  while (1) {
    if (/*t0 <= time_elapsed && */time_elapsed < t1)
      delay = interpHILO( time_elapsed, 0.0f, t0t1HILO, LO_DELAY, HI_DELAY );

    time_elapsed += delay;
    ++steps;

    if (t1 <= time_elapsed) {
      return steps+1; // next step
    }
  }
}

// ramp up a motor, run at full speed, then ramp back down
struct MotorAnimator {
  uint32_t STEPS_PER_REV;
  uint32_t MICROSTEPPING;
  uint32_t HI_DELAY;
  uint32_t LO_DELAY;
  uint32_t ACCEL_TIME;

  float turns;
  uint32_t steps_needed;

  // linearly ramp velocity (accelerate from s0-s1, then decelerate from s2-s3)
  // interpolate from lo to hi speed as a function of time
  //   ______________
  //  /              \
  //s0 s1          s2 s3
  uint32_t s0;
  uint32_t s1;
  uint32_t s2;
  uint32_t s3;
  float t0;
  float t1;
  float t2;
  float t3;
  float t0t1HILO;
  float t1t2HILO;
  float t2t3HILO;
  void precacheHILO() {
    t0t1HILO = interp_preComputeHILO( t0, t1 );
    t1t2HILO = interp_preComputeHILO( t1, t2 );
    t2t3HILO = interp_preComputeHILO( t2, t3 );
  }
 
  bool needs_adjusting_midflight;

  uint32_t steps;
  float time_elapsed;
  float delay;
  float lo;
  float hi;

  void init(const uint32_t STEPS_PER_REV = 200, // Stepper configuration
            const uint32_t MICROSTEPPING = 32,  // Stepper configuration
            const uint32_t HI_DELAY = 40,       // usecs (high speed delay between steps)
            const uint32_t LO_DELAY = 800,      // usecs (low  speed delay between steps)
            const uint32_t ACCEL_TIME = 4000000 // usecs (amount of time to ramp from LO to HIGH)
            ) {
    this->STEPS_PER_REV = STEPS_PER_REV;
    this->MICROSTEPPING = MICROSTEPPING;
    this->HI_DELAY = HI_DELAY;
    this->LO_DELAY = LO_DELAY;
    this->ACCEL_TIME = ACCEL_TIME;
  }

  void start( float turns ) {
    this->turns = turns;
    steps_needed = uint32_t( turns * float( STEPS_PER_REV * MICROSTEPPING ) );

    // linearly ramp velocity (accelerate from s0-s1, then decelerate from s2-s3)
    // interpolate from lo to hi speed as a function of time
    //   ______________
    //  /              \
    //s0 s1          s2 s3
    t0 = 0;
    t1 = ACCEL_TIME;
    s0 = 0;
    s1 = calcS1( t1, LO_DELAY, HI_DELAY );
    s2 = steps_needed - s1;
    s3 = steps_needed;
    t2 = t1 + (s2-s1) * HI_DELAY;
    t3 = t2 + t1;
    precacheHILO();

    // if we dont have enough runway to get up to speed, the step stages will be off.
    // correct s1 & s2 for this now, and then later (on the fly) we'll correct t1 & t2 & t3 at the midpoint of steps elapsed
    needs_adjusting_midflight = false;
    if (s3 < s1 || s2 < s1 || s3 < s2) {
      s1 = s2 = s3/2;
      needs_adjusting_midflight = true;
    }

    steps = 0;
    time_elapsed = 0;
    delay = LO_DELAY;
    lo = LO_DELAY;
    hi = HI_DELAY;
  }

  // call once after each motor step
  // arduino is SLOW.   Speed of code here really matters!
  FORCE_INLINE void next() {
    //if (steps <= steps_needed) {
      time_elapsed += delay; // = clamp( time_elapsed + delay, 0.0f, t3 );
      ++steps;

      if (time_elapsed < t1)
        delay = interpHILO( time_elapsed, t0, t0t1HILO, lo, hi );
      else if (time_elapsed < t2)
        delay = interpHILO( time_elapsed, t1, t1t2HILO, hi, hi );
      else if (time_elapsed <= t3)
        delay = interpHILO( time_elapsed, t2, t2t3HILO, hi, lo );

      // if (t2 <= time_elapsed && time_elapsed <= t3)
      //   printf( " - %f, %f, %f, %f, %d, %d\n", delay, time_elapsed, t2, t3, hi, lo );

      // debug:
      //if (steps % 100 == 0)
      //  printf( "%d, %f, %f\n", steps, time_elapsed, speed );

      // if the span was too small (s1 == s2), and we had to adjust
      // end it early when we pass step s1
      if (needs_adjusting_midflight && s1 < steps) {
        t1 = t2 = time_elapsed;
        t3 = time_elapsed * 2.0f;
        precacheHILO();
        hi = delay;
        needs_adjusting_midflight = false;
      }
    //}
  }

  // get the delay in usecs to wait between stepper steps
  // before calling next(), wait between steps with:
  //   delay( getDelay() )
  FORCE_INLINE uint32_t getDelay() const  {
    //return round( this->delay ); /// correct
    return delay;                /// fast
  }

  // get the delay in usecs to wait between stepper steps
  FORCE_INLINE float getDelayf() const  {
    return this->delay;
  }

  FORCE_INLINE bool isRunning() const {
    return steps <= steps_needed;
  }

  float amtLeft() const {
    return float((steps_needed - steps) / float(STEPS_PER_REV * MICROSTEPPING));
  }
};
