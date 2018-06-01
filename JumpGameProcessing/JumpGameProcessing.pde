/**
 * Awesome Jump Game.
 * by Jack Wan,
 * May 29th, 2018.
 *
 * Based on Ira Greenberg's Solution in
 * Non-orthogonal Collision with Multiple Ground Segments 
 */

import processing.serial.*;

Ball ball;

// Constant Variables
int minStakeWidth = 30;
int maxStakeWidth = 100;
PVector gravity = new PVector(0, 0.05);
// Orb radius
float r = 5;
// Construct an array of 2 "Stake" objects
int segments = 2;
// Relevant to the stake height
int h = 60;
int MIN_VEL = 1;

Stake[] stakes = new Stake[segments];

// Serial Communication Variables
Serial myPort;      // Create object from Serial class
String portMessage; // Data received from the serial port

// User Params
int defaultRemainingLife = 3;
int score = 0;
int remainingLife = defaultRemainingLife;

void setup(){
  size(640, 360);
  //TODO To show initializing page before serial setup.
  //showInitializing();
  
  //Uncomment the following line to get information about your devices.
  //println((Object[])Serial.list());
  //change the index to match your port.
  String portName = Serial.list()[3];
  myPort = new Serial(this, portName, 9600);
  // Don't generate a serialEvent() unless you get a newline character.
  myPort.bufferUntil('\n');
  
  initGame();
  
  // TODO Make sure the DMP filter is stabled.
  // Wait a while for the DMP filter to stablize and then clear the serial.
  //myPort.clear();
}

void draw(){
  // Background
  noStroke();
  fill(0, 15);
  rect(0, 0, width, height);
  
  displayScore();
  
  // Ball stay still if it's on stake[0] and its velocity is 0.
  // TODO To solve the serialEvent() causing interrupt issue(remaininglife is always decreasing).
  // if(!(ball.isOnStake(stakes[0]) && ball.velocity.x < MIN_VEL))
  ball.move();
  
  if(ball.checkWallCollision(stakes[0]))
    remainingLife--;
  // Check against all the stake
  for (int i = 0; i < segments; i++){
    if(ball.checkStakeCollision(stakes[i], stakes[0]))
      remainingLife--;
  }

  // Draw stakes
  for (int i = 0; i < segments; i++){
    stakes[i].display();
  }
  ball.display();
  
  if(ball.isOnStake(stakes[1])) {
    continueGame();
  }
  
  checkLives();
}

void showInitializing() {
  println("Initializing...");
  // Show initail page
  noStroke();
  fill(0);
  rect(0, 0, width, height);
  textSize(25);
  fill(200);
  text("Initializing...", 250, 170);
}

void displayScore() {
  textSize(15);
  fill(200);
  text("Score: " + score, 290, 30);
  text("Lives:  " + remainingLife, 290, 50);
}

// Override the method.
void serialEvent(Serial myPort) {
  // get the ASCII string:
  try {
    String inString = myPort.readStringUntil('\n');
    println(inString);
    if(inString == "Sitting still...") {
      return;
    }

    if (inString != null) {
      // Trim off any whitespace:
      inString = trim(inString);
      // Convert to an float.
      float val = float(inString);
      ball.jump(val, -2);
    }
  }catch(Exception e){
    println("caught error parsing data:");
    e.printStackTrace();
  }
}

void initGame() {
  stakes[0] = new Stake(width/4, height - h, random(minStakeWidth, maxStakeWidth));
  float w = random(minStakeWidth, maxStakeWidth);
  float x = random(width/2 + w/2, width - w/2);
  stakes[1] = new Stake(x, height - h, w);
  
  ball = new Ball(stakes[0].x, stakes[1].y - r, r);
}

void continueGame() {
  if(ball.isOnStake(stakes[1])) {
    stakes[0].set(width/4, height - h, stakes[1].len);
    ball.reset(stakes[0]);
  
    float nextWidth = random(minStakeWidth, maxStakeWidth);
    float nextX = random(width/2 + nextWidth/2, width - nextWidth/2);
    stakes[1].set(nextX, height - h, nextWidth);
    // Score 1 points.
    score++;
  } else {
    ball.reset(stakes[0]);
  }
}

void checkLives() {
  if(remainingLife < 1) {
    remainingLife = 3;
    score = 0;
  }
}
