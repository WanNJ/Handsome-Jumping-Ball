/**
   Arduino part for "Awesome Jump Game".
   by Jack Wan,
   May 30th, 2018.
*/

#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
  #include "Wire.h"
#endif

#define LED_PIN 13
bool blinkState = false;

MPU6050 mpu;

// MPU control/status vars
bool dmpReady = false;  // set true if DMP init was successful
uint8_t mpuIntStatus;   // holds actual interrupt status byte from MPU
uint8_t devStatus;      // return status after each device operation (0 = success, !0 = error)
uint16_t packetSize;    // expected DMP packet size (default is 42 bytes)
uint16_t fifoCount;     // count of all bytes currently in FIFO
uint8_t fifoBuffer[64]; // FIFO storage buffer

// Orientation/Motion vars
Quaternion q;           // [w, x, y, z]         quaternion container
VectorInt16 aa;         // [x, y, z]            accel sensor measurements
VectorInt16 aaReal;     // [x, y, z]            gravity-free accel sensor measurements
VectorInt16 aaWorld;    // [x, y, z]            world-frame accel sensor measurements
VectorFloat gravity;    // [x, y, z]            gravity vector


// ================================================================
// ===               INTERRUPT DETECTION ROUTINE                ===
// ================================================================

volatile bool mpuInterrupt = false;     // indicates whether MPU interrupt pin has gone high
void dmpDataReady() {
  mpuInterrupt = true;
}

// ================================================================
// ===                      INITIAL SETUP                       ===
// ================================================================

// Game related parameters
#define LOOP_NUM 200
#define ACCEL_THRESHOLD 0.25
#define MIN_VEL 1
#define SCALE_FACTOR 7

// IMU related parameters
#define COUNT_PER_GRAVITY 16384
#define MAX_ACCEL 3.4641
#define MAX_CUSTOM 2
#define X_OFFSET 1.2575
#define Y_OFFSET -1.2088
#define Z_OFFSET -254.7958

int loopCount = 0;
float maxParam = -1;

void setup() {
  // Set random seed.
  randomSeed(221);
  // Initialize serial communication
  Serial.begin(9600);
  setupIMU();
}

void loop() {
  if (loopCount < LOOP_NUM) {
    loopCount++;
    // Send Data
    float val = getJumpParam();
    if (val > maxParam)
      maxParam = val;
    // Wait a while for the analog-to-digital converter to stabilize after the last reading as well the processing game to animate.
    delay(1);
  } else {
    if (maxParam > 0) {
      Serial.println(maxParam, 5);
    }
    
    loopCount = 0;
    maxParam = -1;
  }
}

void setupIMU() {
  // join I2C bus (I2Cdev library doesn't do this automatically)
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
  Wire.begin();
  TWBR = 24; // 400kHz I2C clock (200kHz if CPU is 8MHz)
#elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
  Fastwire::setup(400, true);
#endif

  while (!Serial); // wait for Leonardo enumeration, others continue immediately

  mpu.initialize();
  devStatus = mpu.dmpInitialize();

  // Supply your own accel offsets here, scaled for min sensitivity
  mpu.setXAccelOffset(X_OFFSET);
  mpu.setYAccelOffset(Y_OFFSET);
  mpu.setZAccelOffset(Z_OFFSET);

  // make sure it worked (returns 0 if so)
  if (devStatus == 0) {
    // Turn on the DMP, now that it's ready
    mpu.setDMPEnabled(true);

    // Enable Arduino interrupt detection
    attachInterrupt(0, dmpDataReady, RISING);
    mpuIntStatus = mpu.getIntStatus();

    // set our DMP Ready flag so the main loop() function knows it's okay to use it
    dmpReady = true;

    // get expected DMP packet size for later comparison
    packetSize = mpu.dmpGetFIFOPacketSize();
  } else {
    // ERROR!
    // 1 = initial memory load failed
    // 2 = DMP configuration updates failed
    // (if it's going to break, usually the code will be 1)
    Serial.print(F("DMP Initialization failed (code "));
    Serial.print(devStatus);
    Serial.println(F(")"));
  }

  pinMode(LED_PIN, OUTPUT);
}

/**
   Return -1 if not applicable.
*/
float getJumpParam() {
  // if programming failed, don't try to do anything
  if (!dmpReady) return;

  // wait for MPU interrupt or extra packet(s) available
  while (!mpuInterrupt && fifoCount < packetSize){};

  // reset interrupt flag and get INT_STATUS byte
  mpuInterrupt = false;
  mpuIntStatus = mpu.getIntStatus();

  // get current FIFO count
  fifoCount = mpu.getFIFOCount();

  // check for overflow (this should never happen unless our code is too inefficient)
  if ((mpuIntStatus & 0x10) || fifoCount == 1024) {
    // reset so we can continue cleanly
    mpu.resetFIFO();
    Serial.println(F("FIFO overflow!"));

    // otherwise, check for DMP data ready interrupt (this should happen frequently)
  } else if (mpuIntStatus & 0x02) {
    // wait for correct available data length, should be a VERY short wait
    while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();

    // read a packet from FIFO
    mpu.getFIFOBytes(fifoBuffer, packetSize);

    // track FIFO count here in case there is > 1 packet available
    // (this lets us immediately read more without waiting for an interrupt)
    fifoCount -= packetSize;

    // display real acceleration, adjusted to remove gravity
    mpu.dmpGetQuaternion(&q, fifoBuffer);
    mpu.dmpGetAccel(&aa, fifoBuffer);
    mpu.dmpGetGravity(&gravity, &q);
    mpu.dmpGetLinearAccel(&aaReal, &aa, &gravity);
    mpu.dmpGetLinearAccelInWorld(&aaWorld, &aaReal, &q);

    // Blink LED to indicate activity
    blinkState = !blinkState;
    digitalWrite(LED_PIN, blinkState);
    
    return getVel(aaWorld.x, aaWorld.y, aaWorld.z);
  }

  return -1;
}

float getVel(float x, float y, float z) {
  // Map acceleration of IMU to parameter of the ball.
  x /= COUNT_PER_GRAVITY;
  y /= COUNT_PER_GRAVITY;
  z /= COUNT_PER_GRAVITY;

  double a = sqrt(x * x + y * y + z * z);

  if (a < ACCEL_THRESHOLD) {
    return -1;
  }

  if(a > MAX_CUSTOM)
    return MIN_VEL + SCALE_FACTOR;
  else {
    float vel = (a - ACCEL_THRESHOLD) / (MAX_CUSTOM - ACCEL_THRESHOLD) * SCALE_FACTOR + MIN_VEL;
    return vel;
  }
}

