/**
 * Awesome Jump Game.
 * by Jack Wan,
 * May 29th, 2018.
 *
 * Based on Ira Greenberg's Solution in
 * Non-orthogonal Collision with Multiple Ground Segments 
 */

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

Stake[] stakes = new Stake[segments];

void setup(){
  size(640, 360);
  initGame();
}

void draw(){
  // Background
  noStroke();
  fill(0, 15);
  rect(0, 0, width, height);
  

  ball.move();
  ball.display();
  // Check walls
  ball.checkWallCollision(stakes[0]);

  // Check against all the stake
  for (int i = 0; i < segments; i++){
    ball.checkStakeCollision(stakes[i], stakes[0]);
  }

  
  // Draw stakes
  for (int i = 0; i < segments; i++){
    stakes[i].display();
  }
}

void mouseClicked() {
  continueGame();
  ball.jump(random(3, 8), -1.5);
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
  } else {
    ball.reset(stakes[0]);
  }
}
