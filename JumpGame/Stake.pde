class Stake {
  float x, y, len;

  // Constructor
  Stake(float x, float y, float len) {
    this.x = x;
    this.y = y;
    this.len = len;
  }
  
  void set(float x, float y, float len) {
    this.x = x;
    this.y = y;
    this.len = len;
  }
  
  void display() {
    fill(127);
    beginShape();
    vertex(x - len/2, height);
    vertex(x - len/2, y);
    vertex(x + len/2, y);
    vertex(x + len/2, height);
    endShape(CLOSE);
  }
}
