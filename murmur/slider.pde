class Slider{
  int x;
  int y;
  int w;
  int h;
  float min;
  float max;
  float currentVal;
  boolean isBeingMoved;
  String txt;
  color c1;
  color c2;
  int type;
  Slider(int xPos, int yPos, int w1, int h1, float mn, float mx, float init, String t, int a){
    x = xPos;
    y = yPos;
    w = w1;
    h = h1;
    min = mn;
    max = mx;
    currentVal = init;
    isBeingMoved = false;
    txt = t;
    type = a;
  }
  void display(){
    
    rectMode(CENTER);
    pushMatrix();
    //for right-set sliders
    if(type == 0)
      translate(x+buttonOffset,y);
    //for left-set sliders
    else if(type == 1)
      translate(x-buttonOffset,y);
    noStroke();
    //fill based on background color
    color c = blackOrWhite_bg ? color(255,255,255):color(0,0,0);
    fill(c);
    //stick
    rect(0,0,w/3,h,5);
    //handle
    pushMatrix();
    //get the relative height
    translate(0,map(currentVal,min,max,-h/2,h/2),1);
    if(isGrabbed()){
      rect(0,0,w+5,(w+5)/2,5);
    }
    else{
      rect(0,0,w,w/2,5);
    }
    popMatrix();
    textAlign(CENTER);
    //drawing title text
    if(isGrabbed()){
      textSize(20);
      if(blackOrWhite_bg)
       fill(255);
      else
       fill(0);
      pushMatrix();
      rotateZ(radians(90));
      text(txt,0,w+5);
      popMatrix();
    }
    //if it's being moved, draw the current val
    if(isBeingMoved)
        text(str(round(100-100*currentVal/max)),0,-h/2-10);
    popMatrix();
    textAlign(LEFT);
  }
  //checks if the slider is being grabbed
  boolean isGrabbed(){
    boolean state = false;
    if(mouseX>(x-w/2) && mouseX<(x+w/2) && mouseY>(y-h/2) && mouseY<(y+h/2)){
      state = true;
      cursor(HAND);
    }
    return state;
  }
  void setVal(float v){
    currentVal = map(v,y-h/2,y+h/2,min,max);
  }
}
Slider volumeSlider;
void makeSliders(){
  volumeSlider = new Slider(width-30,890,30,200,0,2,1,"volume",0);
}
void displaySliders(){
  volumeSlider.display();
}
boolean clickSliders(){
  boolean atLeastOne = false;
  if(volumeSlider.isGrabbed()){
    volumeSlider.isBeingMoved = true;
    atLeastOne = true;
  }
  return atLeastOne;
}
void moveSliders(){
  if(volumeSlider.isBeingMoved){
    volumeSlider.setVal(constrain(mouseY,volumeSlider.y-volumeSlider.h/2,volumeSlider.y+volumeSlider.h/2));
    masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
  }
}
void releaseSliders(){
  volumeSlider.isBeingMoved = false;
}
