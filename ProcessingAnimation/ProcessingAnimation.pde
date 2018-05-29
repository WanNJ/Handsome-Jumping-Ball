/**
 * Non-orthogonal Collision with Multiple Ground Segments 
 * by Ira Greenberg. 
 * 
 * Based on Keith Peter's Solution in
 * Foundation Actionscript Animation: Making Things Move!
 */

Orb orb;

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
  
  //// Move and display the orb
  //orb.move();
  orb.display();
  //// Check walls
  //orb.checkWallCollision();

  //// Check against all the stake
  //for (int i = 0; i < segments; i++){
  //  orb.checkGroundCollision(stakes[i]);
  //}

  
  // Draw stakes
  for (int i = 0; i < segments; i++){
    stakes[i].display();
  }
}

void mouseClicked() {
  continueGame();
  orb.reset(stakes[0]);
}

void initGame() {
  stakes[0] = new Stake(width/4, height - h, random(minStakeWidth, maxStakeWidth));
  float w = random(minStakeWidth, maxStakeWidth);
  float x = random(width/2 + w/2, width - w/2);
  stakes[1] = new Stake(x, height - h, w);
  
  orb = new Orb(stakes[0].x, stakes[1].y - r, r);
}

void continueGame() {
  /* Float value required for segment width (segs)
   calculations so the ground spans the entire 
   display window, regardless of segment number. */
  
  stakes[0].set(width/4, height - h, stakes[1].len);
  float nextWidth = random(minStakeWidth, maxStakeWidth);
  float nextX = random(width/2 + nextWidth/2, width - nextWidth/2);
  stakes[1].set(nextX, height - h, nextWidth);
}
