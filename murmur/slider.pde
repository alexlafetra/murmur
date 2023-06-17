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
  boolean colorByVal;
  int type;
  //can be 1 (just a val between 0 and 100) or 0 (actual value)
  int textType;
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
    textType = 0;
    colorByVal = false;
  }
  void randomize(){
    currentVal = random(min,max);
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
    //for horizontal sliders
    else if(type == -1){
      translate(x-buttonOffset,y);
      rotate(radians(90));
    }
    noStroke();
    //fill based on background color
    color c;
    if(colorByVal){
      c = color(map(currentVal,min,max,red(c2),red(c1)),map(currentVal,min,max,green(c2),green(c1)),map(currentVal,min,max,blue(c2),blue(c1)));
    }
    else{
      c = blackOrWhite_bg ? color(255,255,255):color(0,0,0);
    }
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
      //textSize(20);
      //if(blackOrWhite_bg)
      // fill(255);
      //else
      // fill(0);
      //pushMatrix();
      //if(type >= 0)//rotate for vertical sliders
      //  rotateZ(radians(90));
      //else
      //  rotateZ(-radians(90));
      //text(txt,0,w+5);
      buttonText = txt;
      //popMatrix();
    }
    //if it's being moved, draw the current val
    if(isBeingMoved){
      if(textType == 1)
        buttonText = str(round(100-100*currentVal/max))+"%";
        //text(str(round(100-100*currentVal/max))+"%",0,-h/2-10);
      else
        //text(max-currentVal,0,-h/2-10);
        buttonText = str(max-currentVal);
    }
    popMatrix();
    textAlign(LEFT);
  }
  //checks if the slider is being grabbed
  boolean isGrabbed(){
    boolean state = false;
    //vertical sliders
    if(type>=0){
      if(mouseX>(x-w/2) && mouseX<(x+w/2) && mouseY>(y-h/2) && mouseY<(y+h/2)){
        state = true;
        cursor(HAND);
      }
    }
    //horizontal sliders
    else{
       if(mouseX>(x-h/2) && mouseX<(x+h/2) && mouseY>(y-w/2) && mouseY<(y+w/2)){
        state = true;
        cursor(HAND);
      }
    }
    return state;
  }
  void setVal(float v){
    //vertical sliders
    if(type >= 0)
      currentVal = map(v,y-h/2,y+h/2,min,max);
    //horizontal sliders
    //don't really know why you need the max - map() form! something to look into
    else
      currentVal = max - map(v,x-h/2,x+h/2,min,max);
  }
}

Slider volumeSlider;
Slider avoidanceSlider;
Slider cohesionSlider;
Slider orientationSlider;
Slider randomSlider;
Slider orbitSlider;
Slider perceptionSlider;

Slider playbackSpeedSlider;

Slider groupPositionToleranceSlider;
Slider groupHeadingToleranceSlider;

Slider[] sliders;
void makeSliders(){
  volumeSlider = new Slider(width-30,890,30,200,0,2,1,"Volume",0);
  volumeSlider.textType = 1;
  
  //playbackSpeedSlider = new Slider(width-60,890,30,200,0,2,1,"Playback Speed",0);
  //playbackSpeedSlider.textType = 1;
  
  avoidanceSlider = new Slider(70,height-120,30,100,0,5,5-1.5,"Avoidance",-1);
  avoidanceSlider.colorByVal = true;
  avoidanceSlider.c1 = color(0,255,100);
  avoidanceSlider.c2 = color(255,0,0);
  
  cohesionSlider = new Slider(70,height-180,30,100,0,5,5-1.1,"Cohesion",-1);
  cohesionSlider.colorByVal = true;
  cohesionSlider.c1 = color(255,0,0);
  cohesionSlider.c2 = color(0,0,255);
  
  orientationSlider = new Slider(70,height-240,30,100,0,5,5-1.2,"Orientation",-1);
  orientationSlider.colorByVal = true;
  orientationSlider.c1 = color(255,255,0);
  orientationSlider.c2 = color(255,0,0);
  
  randomSlider = new Slider(70,height-300,30,100,0,5,5-1,"Breeze",-1);
  randomSlider.colorByVal = true;
  randomSlider.c1 = color(0,0,255);
  randomSlider.c2 = color(0,255,0);
  
  orbitSlider = new Slider(70,height-360,30,100,1,500,500-300,"Orbit",-1);
  orbitSlider.colorByVal = true;
  orbitSlider.c1 = color(0,255,255);
  orbitSlider.c2 = color(255,255,0);
  
  perceptionSlider = new Slider(70,height-420,30,100,0,200,200-50,"Perception Radius",-1);
  perceptionSlider.colorByVal = true;
  perceptionSlider.c1 = color(255,255,100);
  perceptionSlider.c2 = color(200,200,200);
  
  //groupPositionToleranceSlider = new Slider(70,550,30,100,0,1000,1000-100,"Position Tolerance",-1);
  //groupHeadingToleranceSlider = new Slider(70,610,30,100,0,360,270,"Heading Tolerance",-1);
  
  sliders = new Slider[7];
  sliders[0] = volumeSlider;
  sliders[1] = avoidanceSlider;
  sliders[2] = cohesionSlider;
  sliders[3] = orientationSlider;
  sliders[4] = randomSlider;
  sliders[5] = orbitSlider;
  sliders[6] = perceptionSlider;
  //sliders[7] = playbackSpeedSlider;
}
void displaySliders(){
  for(int i = 0; i<sliders.length; i++){
    sliders[i].display();
  }
}
boolean clickSliders(){
  boolean atLeastOne = false;
  for(int i = 0; i<sliders.length; i++){
    if(sliders[i].isGrabbed()){
      sliders[i].isBeingMoved = true;
      atLeastOne = true;
    }
  }
  return atLeastOne;
}

void moveSliders(){
  for(int i = 0; i<sliders.length; i++){
    if(sliders[i].isBeingMoved){
      //vertical sliders
      if(sliders[i].type>=0){
        sliders[i].setVal(constrain(mouseY,sliders[i].y-sliders[i].h/2,sliders[i].y+sliders[i].h/2));
      }
      else{
        int val = constrain(mouseX,sliders[i].x-sliders[i].h/2,sliders[i].x+sliders[i].h/2);
        sliders[i].setVal(val);
      }
    }
  }
  masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
  avoidanceModifier = avoidanceSlider.max-avoidanceSlider.currentVal;
  cohesionModifier = cohesionSlider.max-cohesionSlider.currentVal;
  orientationModifier = orientationSlider.max-orientationSlider.currentVal;
  randomModifier = randomSlider.max-randomSlider.currentVal;
  orbitR = orbitSlider.max - orbitSlider.currentVal;
  perceptionR = perceptionSlider.max - perceptionSlider.currentVal;
}

void releaseSliders(){
  for(int i = 0; i<sliders.length; i++){
    sliders[i].isBeingMoved = false;
  }
}

void randomizeSliders(){
  //starting at 1 so you skip the volume slider
  for(int i = 1; i<sliders.length; i++){
    sliders[i].randomize();
  }
}
