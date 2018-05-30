/**
 * Arduino part for "Awesome Jump Game".
 * by Jack Wan,
 * May 30th, 2018.
 */

void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
  randomSeed(221);
}

void loop() {
  // Send Data
  float val = random(3, 8);
  Serial.println(val,5);
  // Wait a while for the analog-to-digital converter to stabilize after the last reading as well the processing game to animate.
  delay(2000);
}
