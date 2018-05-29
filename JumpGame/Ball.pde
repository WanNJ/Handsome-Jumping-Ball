class Ball {
  // Ball has position and velocity
  PVector position;
  PVector velocity;
  float r;

  Ball(float x, float y, float r_) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    r = r_;
  }

  void jump(float x, float y) {
    this.velocity.x = x;
    this.velocity.y = y;
  }

  void move() {
    // Move ball
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
    if (position.x > width - r || position.x < r || position.y > height || position.y < 0) {
      this.reset(stake);
    } 
  }

  void checkStakeCollision(Stake stake, Stake resetStake) {
    // Get distance between ball and ground
    float deltaY = position.y - stake.y;

    /* Ground collision - check for surface 
     collision and also that ball is within 
     left/rights bounds of stake.*/
    
    if (deltaY > -r &&
      position.x > stake.x - stake.len/2 &&
      position.x < stake.x + stake.len/2
      ) {
      if(deltaY >= r)
        reset(resetStake);
      else {
        // Keep the ball from going into ground
        position.y = stake.y - r;
        stopMoving();
      }
    }
  }
  
  private void stopMoving() {
    velocity.x = 0;
    velocity.y = 0;
  }
  
  private void reset(Stake stake) {
    stopMoving();
    position.x = stake.x;
    position.y = stake.y - r;
  }
}
