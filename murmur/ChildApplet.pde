//sidewindow
class ChildApplet extends PApplet{
  int tint;
  float x,y;
  SDrop drop;
  public ChildApplet(float x1, float y1){
    super();
    this.x = x1;
    this.y = y1;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  public void settings() {
    size(400, 400);
    //needs to be P2D to avoid thread error (for some reason);
  }
  public void setup() { 
    colorMode(HSB, 400);
    windowResizable(true);
    windowMove(int(this.x),int(this.y));
    tint = 400;
    drop = new SDrop(this);
  }
  public void draw() {
    //background(frameCount%400,tint,tint);
    windowTitle(getFormattedFileName());
    this.loadPixels();
    //set the background
    Arrays.fill(this.pixels, color(frameCount%400,tint,tint));
    //scan across the pixels
    for(int i = 0; i < this.width; i++) {
      //for each pixel work out where in the current audio buffer we are
      int buffIndex = i * ac.getBufferSize() / this.width;
      //then work out the pixel height of the audio data at that point
      int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) * this.height / 2);
      //draw into Processing's convenient 1-D array of pixels
      vOffset = min(vOffset, this.height);
      int index = vOffset * this.width + i;
      index = constrain(index,0,this.pixels.length-1);
      this.pixels[index] = color(400-frameCount%400,600-tint,600-tint);
    }
    this.updatePixels();
  }
  //when a file is dropped on the window
  public void dropEvent(DropEvent theEvent) {
    if(theEvent.isFile()){
      File newFile = theEvent.file();
      if(isValidAudioFileType(newFile.getAbsolutePath())){
        player.kill();
        filename = newFile.getAbsolutePath();
        startplayer();
        childWindow.tint = int(random(300,400));
        childWindow.windowTitle(getFormattedFileName());
      }
    }
  }
}
