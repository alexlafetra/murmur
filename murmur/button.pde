int buttonOffset = 0;
class Button{
  int x;
  int y;
  int w;
  int h;
  boolean state;
  String txt;
  int type;
  //boolean clickFlag;
  color c;
  color c2;
  Button(int xPos, int yPos, int wth, int ht, color a, boolean s, String t, int pl){
    x = xPos;
    y = yPos;
    w = wth;
    h = ht;
    c = a;
    c2 = a;
    state = s;
    txt = t;
    type = pl;
  }
  Button(int xPos, int yPos, int wth, int ht, color a, color b, boolean s, String t, int pl){
    x = xPos;
    y = yPos;
    w = wth;
    h = ht;
    c = a;
    c2 = b;
    state = s;
    txt = t;
    type = pl;
  }
  Boolean isMousedOver(){
    if(mouseX>=x && mouseX<= x+w && mouseY>=y && mouseY<=y+h){
      cursor(HAND);
      return true;
    }
    else{
      return false;
    }
  }
  void display(){
    pushMatrix();
    translate(x,y,0);
    if(state){
      fill(c);
      stroke(c);
    }
    else{
      if(c == c2){
        noFill();
        stroke(c);
      }
      else{
       fill(c2);
       stroke(c2);
      }
    }
    if(type == 0){
      strokeWeight(7);
      rectMode(CENTER);
      if(isMousedOver()){
        rect(w/2+buttonOffset,h/2,w+4,h+4,5);
      }
      else{
        rect(w/2+buttonOffset,h/2,w,h,5);
      }
    }
    else if(type == 1){
      strokeWeight(7);
      rectMode(CENTER);
      if(isMousedOver()){
        rect(w/2,h/2-buttonOffset,w+4,h+4,5);
      }
      else{
        rect(w/2,h/2-buttonOffset,w,h,5);
      }
    }
    //rec button, since it's a circle
    else{
      strokeWeight(7);
      //if it's not pressed, or if it is and it's been 500 frames
      if(state || (frameCount%60)>30){
        fill(c);
      }
      else{
        fill(0,0,0,0);
      }
      if(isMousedOver()){
        ellipse(w/2+buttonOffset,h/2,w+4,h+4);
      }
      else{
        ellipse(w/2+buttonOffset,h/2,w,h);
      }
      if(state){
        txt = "stop recording";
      }
      else{
        txt = "start recording";
      }
    }
    popMatrix();
    if(isMousedOver()){
      if(c==c2)
        fill(c);
      else{
        if(state){
          fill(c);
        }
        else{
          fill(c2);
        }
      }
      pushMatrix();
      textSize(25);
      //side buttons
      if(type != 1){
        translate(x+12,510);
        rotateZ(PI/2);
      }
      //top buttons
      else{
        translate(width-320-textWidth(txt),y+40-12);
      }
      text(txt,0,0);
      popMatrix();
    }
  }
}
Button ptch;
Button streo;
Button grnRate;
Button grnSize;
Button vol;
Button rndm;
Button rev;
Button reset;
Button bg;
Button byHeading;
Button showOrbit;
Button showAvg;
Button loadSample;
Button rec;
Button tails;
void makeButtons(){
  reset = new Button(width-50,10,40,40, color(255,50,50), false, "reset",1);
  ptch = new Button(width-50,60,40,40, color(255,233,28), pitch, "pitch",0);
  streo = new Button(width-50,110,40,40, color(#FF5ACE), stereo, "pan",0);
  grnRate = new Button(width-50,160,40,40, color(0,255,200), gRate, "grain Rate",0);
  grnSize = new Button(width-50,210,40,40, color(#674DFF), gSize, "grain Size",0);
  vol = new Button(width-50,260,40,40, color(200,55,100), gain, "gain",0);
  rndm = new Button(width-50,310,40,40, color(0,255,100), gRandom, "noise",0);
  rev = new Button(width-50,360,40,40, color(75,157,255), paused, "direction",0);
  loadSample = new Button(width-50,410,40,40,color(255,150,50), true, "load new sample",0);
  rec = new Button(width-50,460,40,40, color(222,22,29), paused, "record",2);
  
  //display controls
  bg = new Button(width-100,10,40,40,color(255,255,255), color(0,0,0), blackOrWhite_bg, "swap background",1);
  byHeading = new Button(width-150,10,40,40,color(100,200,255), colorByHeading, "color by orientation",1);
  showOrbit = new Button(width-200,10,40,40,color(200,155,155), showOrbitPoint, "show orbit point",1);
  showAvg = new Button(width-250,10,40,40,color(200,55,100), showAvgPos, "show average position",1);
  tails = new Button(width-300,10,40,40,color(100,200,200), showAvgPos, "show tails",1);

}
void reset(){
  player.kill();
  paused = true;
  avgVel = new PVector(0,0,0);
  avgPos = new PVector(0,0,0);
  //allocate memory for the flock
  flock = new Boid[numberOfBoids];
  //initialize the flock with boid objects
  for(int i = 0; i<flock.length; i++){
    flock[i] = new Boid();
  }
  makeButtons();
  makeSliders();
  background(0);
  startplayer();
  //just so the orb starts w/ the boids
  getData();
  masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
}

void displayButtons(){
  ptch.display();
  streo.display();
  grnRate.display();
  grnSize.display();
  vol.display();
  rndm.display();
  rev.display();
  reset.display();
  bg.display();
  byHeading.display();
  showAvg.display();
  showOrbit.display();
  loadSample.display();
  rec.display();
  tails.display();
}
boolean checkButtons(){
  boolean atLeastOne = false;
  if(ptch.isMousedOver()){
    pitch = !pitch;
    ptch.state = pitch;
    atLeastOne = true;
  }
  if(streo.isMousedOver()){
    stereo = !stereo;
    streo.state = stereo;
    atLeastOne = true;
  }
  if(grnRate.isMousedOver()){
    gRate = !gRate;
    grnRate.state = gRate;
    atLeastOne = true;
  }
  if(grnSize.isMousedOver()){
    gSize = !gSize;
    grnSize.state = gSize;
    atLeastOne = true;
  }
  if(vol.isMousedOver()){
    gain = !gain;
    vol.state = gain;
    atLeastOne = true;
  }
  if(rndm.isMousedOver()){
    gRandom = !gRandom;
    rndm.state = gRandom;
    atLeastOne = true;
  }
  if(rev.isMousedOver()){
    reverse = !reverse;
    rev.state = reverse;
    atLeastOne = true;
  }
  if(reset.isMousedOver()){
    reset();
    atLeastOne = true;
  }
  if(bg.isMousedOver()){
    blackOrWhite_bg = !blackOrWhite_bg;
    bg.state = blackOrWhite_bg;
    atLeastOne = true;
  }
  if(byHeading.isMousedOver()){
    colorByHeading = !colorByHeading;
    byHeading.state = colorByHeading;
    atLeastOne = true;
  }
  if(showOrbit.isMousedOver()){
    showOrbitPoint = !showOrbitPoint;
    showOrbit.state = showOrbitPoint;
    atLeastOne = true;
  }
  if(showAvg.isMousedOver()){
    showAvgPos = !showAvgPos;
    showAvg.state = showAvgPos;
    atLeastOne = true;
  }
  if(loadSample.isMousedOver()){
    loadSample.state = false;
    getNewSample();
    atLeastOne = true;
  }
  if(tails.isMousedOver()){
    showTails = !showTails;
    tails.state = showTails;
    showingControls = !showTails;
    atLeastOne = true;
  }
  if(rec.isMousedOver()){
    if(recStarted){
      endRecording();
      recStarted = false;
    }
    else{
      startRecording();
      recStarted = true;
    }
    rec.state = !recStarted;
    atLeastOne = true;
  }
  return atLeastOne;
}
