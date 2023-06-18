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
      buttonText = txt;
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
        rect(w/2+buttonOffset,h/2,w+4,h+4,10);
      }
      else{
        rect(w/2+buttonOffset,h/2,w,h,10);
      }
    }
    else if(type == 1){
      strokeWeight(7);
      rectMode(CENTER);
      if(isMousedOver()){
        rect(w/2,h/2-buttonOffset,w+4,h+4,10);
      }
      else{
        rect(w/2,h/2-buttonOffset,w,h,10);
      }
    }
    //rec button, since it's a circle
    else{
      strokeWeight(7);
      //if it's not pressed, or if it is and it's been 500 frames
      if(type == 4){
        if(state || (frameCount%60)>30){
          fill(c);
        }
        else{
          fill(0,0,0,0);
        }
      }
      else{
        if(state)
          fill(c);
        else
          fill(0,0,0,0);
      }
      if(type == 3){
        if(isMousedOver()){
          ellipse(w/2-buttonOffset,h/2,w+4,h+4);
        }
        else{
          ellipse(w/2-buttonOffset,h/2,w,h);
        }
      }
      else{
        if(isMousedOver()){
          ellipse(w/2+buttonOffset,h/2,w+4,h+4);
        }
        else{
          ellipse(w/2+buttonOffset,h/2,w,h);
        }
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
      //textSize(25);
      //side buttons
      if(type != 1){
        translate(x+12,510);
        rotateZ(PI/2);
      }
      //top buttons
      else{
        translate(width-320-textWidth(txt),38);
      }
      //text(txt,0,0);
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
Button resetParams;
Button randomizeParams;

Button reverbButton;

Button jumpToRandom;


Button[] buttons;

void makeButtons(){
  reset = new Button(width-50,10,40,40, color(255,50,50), true, "Reset",1);
  ptch = new Button(width-50,60,40,40, color(0,233,28), pitch, "Pitch",0);
  streo = new Button(width-50,110,40,40, color(#FF5ACE), stereo, "Pan",0);
  grnRate = new Button(width-50,160,40,40, color(150,150,200), gRate, "Grain Rate",0);
  grnSize = new Button(width-50,210,40,40, color(#674DFF), gSize, "Grain Size",0);
  vol = new Button(width-50,260,40,40, color(200,55,100), gain, "Gain",0);
  rndm = new Button(width-50,310,40,40, color(255,200,200), gRandom, "Noise",0);
  rev = new Button(width-50,360,40,40, color(200,100,255), paused, "Direction",0);
  reverbButton = new Button(width-50,410,40,40, color(200,200,255), reverbing, "Reverb",0);
  loadSample = new Button(width-50,460,40,40,color(255,150,50), true, "Load New Sample",0);
  rec = new Button(width-50,560,40,40, color(222,22,29), paused, "Record",4);
  jumpToRandom = new Button(width-50,510,40,40,color(255,255,255), true, "Randomize Playhead",0);
  
  //display controls
  bg = new Button(width-100,10,40,40,color(255,255,255), color(0,0,0), blackOrWhite_bg, "Swap Background",1);
  byHeading = new Button(width-150,10,40,40,color(100,200,255), true, "Color Style",1);
  showOrbit = new Button(width-200,10,40,40,color(200,155,155), showOrbitPoint, "Enable Walls",1);
  showAvg = new Button(width-250,10,40,40,color(200,55,100), showAvgPos, "Show Average",1);
  tails = new Button(width-300,10,40,40,color(100,200,200), showAvgPos, "Toggle Screen Refresh",1);

  //buttons for flock parameters
  resetParams = new Button(20,height-60,40,40, color(255,200,200), true, "Reset",0);
  randomizeParams = new Button(80,height-60,40,40, color(200,200,255), true, "Randomize Flock",0);
    
  //putting all the buttons into an array
  buttons = new Button[19];
  buttons[0] = reset;
  buttons[1] = ptch;
  buttons[2] = streo;
  buttons[3] = grnRate;
  buttons[4] = grnSize;
  buttons[5] = vol;
  buttons[6] = rndm;
  buttons[7] = rev;
  buttons[8] = loadSample;
  buttons[9] = rec;
  buttons[10] = bg;
  buttons[11] = byHeading;
  buttons[12] = showOrbit;
  buttons[13] = showAvg;
  buttons[14] = tails;
  buttons[15] = resetParams;
  buttons[16] = randomizeParams;
  //buttons[17] = avgGroupData;
  //buttons[18] = usingGroups;
  buttons[17] = reverbButton;
  buttons[18] = jumpToRandom;
}

//resets the flock parameters
void resetParameters(){
  avoidanceModifier = 1.5;
  cohesionModifier = 1.1;
  orientationModifier = 1.2;
  randomModifier = 1;
  perceptionR = 50;
  orbitR = 300;
  makeSliders();
}
// Java program to demonstrate working of
// Math.random() to generate random numbers
import java.util.*;
   
void jumpToRandomLocation(){
  double sampleLength = player.getSample().getLength();
  double randomValue = (sampleLength) * Math.random();
  player.setPosition(randomValue);
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
  //makeSliders();
  background(0);
  startplayer();
  //just so the orb starts w/ the boids
  getData();
  masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
}

void displayButtons(){
  for(int i = 0; i<buttons.length; i++){
    buttons[i].display();
  }
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
    colorStyle++;
    colorStyle %= 4;
    byHeading.c = color(255/3*colorStyle,200,200);
    atLeastOne = true;
  }
  if(showOrbit.isMousedOver()){
    walls = !walls;
    showOrbit.state = walls;
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
    //showingControls = !showTails;
    atLeastOne = true;
  }
  if(rec.isMousedOver()){
    if(recStarted){
      endRecording();
    }
    else{
      if(outputPath == null){
        selectFolder("Select a folder to record into","gotFolder");
      }
      else{
        startRecording();
      }
    }
    atLeastOne = true;
  }
  if(resetParams.isMousedOver()){
    resetParameters();
    atLeastOne = true;
  }
  if(randomizeParams.isMousedOver()){
    randomizeSliders();
    atLeastOne = true;
  }
  if(reverbButton.isMousedOver()){
    toggleReverb();
    reverbButton.state = reverbing;
    atLeastOne = true;
  }
  if(jumpToRandom.isMousedOver()){
    jumpToRandomLocation();
    atLeastOne = true;
  }
  return atLeastOne;
}
