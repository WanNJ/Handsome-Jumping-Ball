class Orb {
  // Orb has positio and velocity
  PVector position;
  PVector velocity;
  float r;

  Orb(float x, float y, float r_) {
    position = new PVector(x, y);
    velocity = new PVector(.5, 0);
    r = r_;
  }

  void jump(PVector v) {
    this.velocity = v;
  }

  void move() {
    // Move orb
    velocity.add(gravity);
    position.add(velocity);
  }

  void display() {
    noStroke();
    fill(200);
    ellipse(position.x, position.y, r*2, r*2);
  }
  
  // Check boundaries of window
  void checkWallCollision(Stake stake) {
    if (position.x > width - r || position.x < r) {
      this.reset(stake);
    } 
  }

  //void checkStakeCollision(Stake stake) {

  //  // Get difference between orb and ground
  //  float deltaX = position.x - groundSegment.x;
  //  float deltaY = position.y - groundSegment.y;

  //  // Precalculate trig values
  //  float cosine = cos(groundSegment.rot);
  //  float sine = sin(groundSegment.rot);

  //  /* Rotate ground and velocity to allow 
  //   orthogonal collision calculations */
  //  float groundXTemp = cosine * deltaX + sine * deltaY;
  //  float groundYTemp = cosine * deltaY - sine * deltaX;
  //  float velocityXTemp = cosine * velocity.x + sine * velocity.y;
  //  float velocityYTemp = cosine * velocity.y - sine * velocity.x;

  //  /* Ground collision - check for surface 
  //   collision and also that orb is within 
  //   left/rights bounds of ground segment */
  //  if (groundYTemp > -r &&
  //    position.x > groundSegment.x1 &&
  //    position.x < groundSegment.x2 ) {
  //    // keep orb from going into ground
  //    groundYTemp = -r;
  //    // bounce and slow down orb
  //    velocityYTemp *= -1.0;
  //    velocityYTemp *= damping;
  //  }

  //  // Reset ground, velocity and orb
  //  deltaX = cosine * groundXTemp - sine * groundYTemp;
  //  deltaY = cosine * groundYTemp + sine * groundXTemp;
  //  velocity.x = cosine * velocityXTemp - sine * velocityYTemp;
  //  velocity.y = cosine * velocityYTemp + sine * velocityXTemp;
  //  position.x = groundSegment.x + deltaX;
  //  position.y = groundSegment.y + deltaY;
  //}
  
  private void reset(Stake stake) {
    velocity.x = 0;
    velocity.y = 0;
    position.x = stake.x;
    position.y = stake.y - r;
  }
}
