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
  boolean display(){
    boolean grabbed = isGrabbed();
    rectMode(CENTER);
    pushMatrix();
    //for right-set sliders
    if(type == 0)
      translate(x+buttonOffset,y);
    //for top-set sliders
    else if(type == 1)
      translate(x,y-buttonOffset);
    //for horizontal L sliders
    else if(type == -1){
      translate(x-buttonOffset,y);
      rotate(radians(90));
    }
    //for horizontal R sliders
    else if(type == -2){
      translate(x+buttonOffset,y);
      rotate(radians(90));
    }
      
    noStroke();
    //fill based on background color
    color c;
    if(colorByVal){
      c = color(map(currentVal,min,max,red(c2),red(c1)),map(currentVal,min,max,green(c2),green(c1)),map(currentVal,min,max,blue(c2),blue(c1)));
    }
    else{
      //println(brightness(backgroundColor));
      c = settings.blackOrWhite_bg ? color(255,255,255):color(0,0,0);
    }
    fill(c);
    //stick
    rect(0,0,w/3,h,5);
    //handle
    pushMatrix();
    //get the relative height
    translate(0,map(currentVal,min,max,-h/2,h/2),1);
    if(grabbed){
      rect(0,0,w+5,(w+5)/2,10);
      childWindow.text = txt;
    }
    else{
      rect(0,0,w,w/2,10);
    }
    popMatrix();
    textAlign(CENTER);
    //if it's being moved, draw the current val
    if(isBeingMoved){
      if(textType == 1)
        childWindow.text = str(round(100-100*currentVal/max))+"%";
      else
        childWindow.text = str(max-currentVal);
    }
    popMatrix();
    textAlign(LEFT);
    return grabbed;
  }
  //checks if the slider is being grabbed
  boolean isGrabbed(){
    boolean state = false;
    //vertical sliders
    if(type>=0){
      if(mouseX>(x-w/2) && mouseX<(x+w/2) && mouseY>(y-h/2) && mouseY<(y+h/2)){
        state = true;
      }
    }
    //horizontal sliders
    else{
       if(mouseX>(x-h/2) && mouseX<(x+h/2) && mouseY>(y-w/2) && mouseY<(y+w/2)){
        state = true;
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
Slider boidSlider;
Slider rSlider,gSlider,bSlider;

Slider[] sliders;
void makeSliders(){
  volumeSlider = new Slider(width-30,840,30,200,0,10,7,"Volume",0);
  volumeSlider.textType = 1;
  
  rSlider = new Slider(width-30,640,20,40,0,255,255,"color - red",-2);
  gSlider = new Slider(width-30,665,20,40,0,255,255,"color - green",-2);
  bSlider = new Slider(width-30,690,20,40,0,255,255,"color - blue",-2);
  
  rSlider.colorByVal = true;
  rSlider.c1 = color(255,255,255);
  rSlider.c2 = color(255,0,0);
  gSlider.colorByVal = true;
  gSlider.c1 = color(255,255,255);
  gSlider.c2 = color(0,255,0);
  bSlider.colorByVal = true;
  bSlider.c1 = color(255,255);
  bSlider.c2 = color(0,0,255);
  
  
  boidSlider = new Slider(70,height-460,30,100,1,2000,2000-settings.numberOfBoids,"Number of Boids",-1);
  boidSlider.colorByVal = true;
  boidSlider.c1 = color(0,200,200);
  boidSlider.c2 = color(255,200,255);
  
  cohesionSlider = new Slider(70,height-400,30,100,0,5,5-1.1,"Cohesion",-1);
  cohesionSlider.colorByVal = true;
  cohesionSlider.c1 = color(255,200,200);
  cohesionSlider.c2 = color(200,200,255);
  
  avoidanceSlider = new Slider(70,height-340,30,100,0,5,5-1.5,"Avoidance",-1);
  avoidanceSlider.colorByVal = true;
  avoidanceSlider.c1 = color(200,255,100);
  avoidanceSlider.c2 = color(255,200,200);
  
  randomSlider = new Slider(70,height-280,30,100,0,5,5-1,"Breeze",-1);
  randomSlider.colorByVal = true;
  randomSlider.c1 = color(200,200,255);
  randomSlider.c2 = color(200,25520,0);
  
  orientationSlider = new Slider(70,height-220,30,100,0,5,5-1.2,"Orientation",-1);
  orientationSlider.colorByVal = true;
  orientationSlider.c1 = color(255,255,200);
  orientationSlider.c2 = color(255,200,200);
  
  perceptionSlider = new Slider(70,height-160,30,100,0,200,200-50,"Perception Radius",-1);
  perceptionSlider.colorByVal = true;
  perceptionSlider.c1 = color(255,255,100);
  perceptionSlider.c2 = color(200,200,255);
  
  orbitSlider = new Slider(70,height-100,30,100,1,500,500-300,"Orbit",-1);
  orbitSlider.colorByVal = true;
  orbitSlider.c1 = color(200,255,255);
  orbitSlider.c2 = color(255,255,200);
  
  
  //groupPositionToleranceSlider = new Slider(70,550,30,100,0,1000,1000-100,"Position Tolerance",-1);
  //groupHeadingToleranceSlider = new Slider(70,610,30,100,0,360,270,"Heading Tolerance",-1);
  
  sliders = new Slider[11];
  sliders[0] = volumeSlider;
  sliders[1] = avoidanceSlider;
  sliders[2] = cohesionSlider;
  sliders[3] = orientationSlider;
  sliders[4] = randomSlider;
  sliders[5] = orbitSlider;
  sliders[6] = perceptionSlider;
  sliders[7] = boidSlider;
  sliders[8] = rSlider;
  sliders[9] = gSlider;
  sliders[10] = bSlider;

}
boolean displaySliders(){
  boolean isOne = false;
  for(int i = 0; i<sliders.length; i++){
    if(sliders[i].display()){
      isOne = true;
    }
  }
  return isOne;
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
  
  //if it's not muted
  if(!settings.isMuted)
    masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
  settings.avoidanceModifier = avoidanceSlider.max-avoidanceSlider.currentVal;
  settings.cohesionModifier = cohesionSlider.max-cohesionSlider.currentVal;
  settings.orientationModifier = orientationSlider.max-orientationSlider.currentVal;
  settings.randomModifier = randomSlider.max-randomSlider.currentVal;
  settings.orbitRadius = orbitSlider.max - orbitSlider.currentVal;
  settings.perceptionRadius = perceptionSlider.max - perceptionSlider.currentVal;
  
  checkBoidCount();
  backgroundColor = color(rSlider.max-rSlider.currentVal,gSlider.max-gSlider.currentVal,bSlider.max-bSlider.currentVal);
  if(red(backgroundColor)>180&&green(backgroundColor)>180&&blue(backgroundColor)>180){
    settings.blackOrWhite_bg = false;
  }
  else{
    settings.blackOrWhite_bg = true;
  }
}

void releaseSliders(){
  for(int i = 0; i<sliders.length; i++){
    sliders[i].isBeingMoved = false;
  }
}

void randomizeSliders(){
  //starting at 1 so you skip the volume slider, and end before the color sliders
  for(int i = 1; i<sliders.length-3; i++){
    //also skip the boid slider
    if(i != 7)
      sliders[i].randomize();
  }
  checkBoidCount();
}
