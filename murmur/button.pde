int buttonOffset = 0;
class Button{
  int x;
  int y;
  int w;
  int h;
  boolean state;
  String txt;
  String type;
  //boolean clickFlag;
  color c;
  color c2;
  Button(int xPos, int yPos, int wth, int ht, color a, boolean s, String t, String ty){
    x = xPos;
    y = yPos;
    w = wth;
    h = ht;
    c = a;
    c2 = a;
    state = s;
    txt = t;
    type = ty;
  }
  Button(int xPos, int yPos, int wth, int ht, color a, color b, boolean s, String t, String ty){
    x = xPos;
    y = yPos;
    w = wth;
    h = ht;
    c = a;
    c2 = b;
    state = s;
    txt = t;
    type = ty;
  }
  Boolean isMousedOver(){
    if(mouseX>=x && mouseX<= x+w && mouseY>=y && mouseY<=y+h){
      childWindow.text = txt;
      return true;
    }
    else{
      return false;
    }
  }
  boolean display(){
    boolean hovered = isMousedOver();
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
    switch(type){
      case "RIGHT_SQUARE":
        pushMatrix();
        translate(x,y,0);
        strokeWeight(7);
        rectMode(CENTER);
        if(hovered){
          rect(w/2+buttonOffset,h/2,w+4,h+4,15);
        }
        else{
          rect(w/2+buttonOffset,h/2,w,h,15);
        }
        popMatrix();
        break;
      case "TOP_SQUARE":
        pushMatrix();
        translate(x,y,0);
        strokeWeight(7);
        rectMode(CENTER);
        if(hovered){
          rect(w/2,h/2-buttonOffset,w+4,h+4,15);
        }
        else{
          rect(w/2,h/2-buttonOffset,w,h,15);
        }
        popMatrix();
        break;
      case "RIGHT_ROUND":
      //right buttons
        pushMatrix();
        translate(x,y,0);
        strokeWeight(7);
        if(hovered){
          ellipse(w/2+buttonOffset,h/2,w+4,h+4);
        }
        else{
          ellipse(w/2+buttonOffset,h/2,w,h);
        }
        popMatrix();
        break;
      case "LEFT_SQUARE":
      //left buttons
        pushMatrix();
        translate(x,y,0);
        strokeWeight(7);
        if(hovered){
          rect(w/2-buttonOffset,h/2,w+4,h+4,15);
        }
        else{
          rect(w/2-buttonOffset,h/2,w,h,15);
        }
        popMatrix();
        break;
      //rec button
      case "REC":
        pushMatrix();
        translate(x,y,0);
        strokeWeight(7);
        if(state || (frameCount%60)>30){
          fill(c);
        }
        else{
          fill(0,0,0,0);
          noStroke();
        }
        if(hovered){
          ellipse(w/2+buttonOffset,h/2,w+4,h+4);
        }
        else{
          ellipse(w/2+buttonOffset,h/2,w,h);
        }
        popMatrix();
        break;
      //mute button
      case "MUTE":
        if(!settings.isMuted || (frameCount%60)>30){
          if(!(settings.blackOrWhite_bg) && !settings.isMuted){
            fill(0);
            stroke(0);
          }
          pushMatrix();
          translate(x+w/2+buttonOffset,y+h/2,0);
          rectMode(CENTER);
          if(hovered){
            rotate(PI/4);
            rect(0,0,w+4,h/4+4,4);
            rotate(PI/2);
            rect(0,0,w+4,h/4+4,4);
          }
          else{
            rotate(PI/4);
            rect(0,0,w,h/4,4);
            rotate(PI/2);
            rect(0,0,w,h/4,4);
          }
          popMatrix();
        }
        break;
    }
    return hovered;
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
Button muteButton;
Button[] buttons;

void makeButtons(){
  reset = new Button(width-50,10,40,40, color(255,50,50), true, "Reset","RIGHT_SQUARE");
  ptch = new Button(width-50,60,40,40, color(0,233,28), settings.pitch, "Pitch","RIGHT_SQUARE");
  streo = new Button(width-50,110,40,40, color(#FF5ACE), settings.stereo, "Pan","RIGHT_SQUARE");
  grnRate = new Button(width-50,160,40,40, color(150,150,200), settings.gRate, "Grain Rate","RIGHT_SQUARE");
  grnSize = new Button(width-50,210,40,40, color(#674DFF), settings.gSize, "Grain Size","RIGHT_SQUARE");
  vol = new Button(width-50,260,40,40, color(200,55,100), settings.gain, "Gain","RIGHT_SQUARE");
  rndm = new Button(width-50,310,40,40, color(255,200,200), settings.gRandom, "Noise","RIGHT_SQUARE");
  rev = new Button(width-50,360,40,40, color(200,100,255), settings.simulationPaused, "Direction","RIGHT_SQUARE");
  reverbButton = new Button(width-50,410,40,40, color(200,200,255), settings.reverbIsActive, "Reverb","RIGHT_SQUARE");
  loadSample = new Button(width-50,460,40,40,color(255,150,50), true, "Load New Sample","RIGHT_SQUARE");
  rec = new Button(width-50,560,40,40, color(222,22,29), settings.simulationPaused, "Record","REC");
  jumpToRandom = new Button(width-50,510,40,40,color(255,255,255), true, "Randomize Playhead","RIGHT_SQUARE");
  
  muteButton = new Button(width-50,height-50,40,40,color(255,255,255), true, "Mute","MUTE");
  
  //display controls
  bg = new Button(width-100,10,40,40,color(255,255,255), color(0,0,0), settings.blackOrWhite_bg, "Swap Background","TOP_SQUARE");
  byHeading = new Button(width-150,10,40,40,color(100,200,255), true, "Color Style","TOP_SQUARE");
  showOrbit = new Button(width-200,10,40,40,color(200,200,255), settings.walls, "Enable Walls","TOP_SQUARE");
  showAvg = new Button(width-250,10,40,40,color(200,255,255), settings.showAvgPos, "Show Average","TOP_SQUARE");
  tails = new Button(width-300,10,40,40,color(255,220,0), settings.updateScreen, "Toggle Screen Refresh","TOP_SQUARE");

  //buttons for flock parameters
  resetParams = new Button(20,height-60,40,40, color(255,200,200), true, "Reset","LEFT_SQUARE");
  randomizeParams = new Button(80,height-60,40,40, color(200,200,255), true, "Randomize Flock","LEFT_SQUARE");
    
  //putting all the buttons into an array
  buttons = new Button[20];
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
  buttons[19] = muteButton;
}

//resets the flock parameters
void resetParameters(){
  avoidanceSlider.currentVal = avoidanceSlider.max-1.5;
  cohesionSlider.currentVal = cohesionSlider.max-1.1;
  orientationSlider.currentVal = orientationSlider.max-1.2;
  randomSlider.currentVal = randomSlider.max-1;
  orbitSlider.currentVal = orbitSlider.max-300;
  perceptionSlider.currentVal = perceptionSlider.max-50;
  boidSlider.currentVal = boidSlider.max-settings.numberOfBoids;
  checkBoidCount();
}

//need this to get the Math.random() function
import java.util.*;
   
void jumpToRandomLocation(){
  double sampleLength = player.getSample().getLength();
  double randomValue = (sampleLength) * Math.random();
  player.setPosition(randomValue);
}

void reset(){
  player.kill();
  settings.simulationPaused = true;
  avgVel = new PVector(0,0,0);
  avgPos = new PVector(0,0,0);
  //allocate memory for the flock
  flock = new Flock(settings.numberOfBoids);
  //initialize the flock with boid objects
  for(int i = 0; i<flock.birds.length; i++){
    flock.birds[i] = new Boid();
  }
  makeButtons();
  //makeSliders();
  background(0);
  startplayer();
  //just so the orb starts w/ the boids
  getData();
  masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
  
  backgroundColor = color(0,0,0);
  rSlider.currentVal = 255;
  gSlider.currentVal = 255;
  bSlider.currentVal = 255;
}

boolean displayButtons(){
  boolean atLeastOneButtonHovered = false;
  for(int i = 0; i<buttons.length; i++){
    if(buttons[i].display()){
      atLeastOneButtonHovered = true;
    }
  }
  textFont(garamond);
  textSize(40);
  fill(255);
  stroke(255);
  pushMatrix();
  translate(40-buttonOffset,height-490);
  text("flock",0,0);
  popMatrix();
  
  pushMatrix();
  translate(width-410,40-buttonOffset);
  text("display",0,0);
  popMatrix();
  
  pushMatrix();
  translate(width-60+buttonOffset,360);
  rotate(-PI/2);
  text("audio",0,0);
  popMatrix();
  
  pushMatrix();
  translate(width-70+buttonOffset,730);
  rotate(-PI/2);
  textSize(30);
  text("background",0,0);
  popMatrix();
  
  pushMatrix();
  translate(width-60+buttonOffset,height-100);
  rotate(-PI/2);
  textSize(30);
  text("volume",0,0);
  popMatrix();
  
  pushMatrix();
  textSize(20);
  text("'c' to clear screen",120,30-buttonOffset);
  text("'click' or 'space' to pause sim",120,50-buttonOffset);
  text("any key to hide controls",120,70-buttonOffset);
  popMatrix();
  return atLeastOneButtonHovered;
}
boolean checkButtons(){
  boolean atLeastOne = false;
  if(ptch.isMousedOver()){
    settings.pitch = !settings.pitch;
    ptch.state = settings.pitch;
    atLeastOne = true;
  }
  if(streo.isMousedOver()){
    settings.stereo = !settings.stereo;
    streo.state = settings.stereo;
    atLeastOne = true;
  }
  if(grnRate.isMousedOver()){
    settings.gRate = !settings.gRate;
    grnRate.state = settings.gRate;
    atLeastOne = true;
  }
  if(grnSize.isMousedOver()){
    settings.gSize = !settings.gSize;
    grnSize.state = settings.gSize;
    atLeastOne = true;
  }
  if(vol.isMousedOver()){
    settings.gain = !settings.gain;
    vol.state = settings.gain;
    atLeastOne = true;
  }
  if(rndm.isMousedOver()){
    settings.gRandom = !settings.gRandom;
    rndm.state = settings.gRandom;
    atLeastOne = true;
  }
  if(rev.isMousedOver()){
    settings.reverse = !settings.reverse;
    rev.state = settings.reverse;
    atLeastOne = true;
  }
  if(reset.isMousedOver()){
    reset();
    atLeastOne = true;
  }
  if(bg.isMousedOver()){
    settings.blackOrWhite_bg = !settings.blackOrWhite_bg;
    
    color temp = backgroundColor;
    backgroundColor = otherBackgroundColor;
    otherBackgroundColor = temp;
    
    rSlider.currentVal = 255 - red(backgroundColor);
    gSlider.currentVal = 255 - green(backgroundColor);
    bSlider.currentVal = 255 - blue(backgroundColor);
    
    flockGraphics.beginDraw();
    flockGraphics.background(backgroundColor);
    flockGraphics.endDraw();
    bg.state = settings.blackOrWhite_bg;
    atLeastOne = true;
  }
  if(byHeading.isMousedOver()){
    settings.colorStyle++;
    settings.colorStyle %= 5;
    byHeading.c = color(255/5*settings.colorStyle,200,200);
    atLeastOne = true;
  }
  if(showOrbit.isMousedOver()){
    settings.walls = !settings.walls;
    showOrbit.state = settings.walls;
    atLeastOne = true;
  }
  if(showAvg.isMousedOver()){
    settings.showAvgPos = !settings.showAvgPos;
    showAvg.state = settings.showAvgPos;
    atLeastOne = true;
  }
  if(loadSample.isMousedOver()){
    loadSample.state = false;
    getNewSample();
    atLeastOne = true;
  }
  if(tails.isMousedOver()){
    settings.updateScreen = !settings.updateScreen;
    tails.state = settings.updateScreen;
    atLeastOne = true;
  }
  if(rec.isMousedOver()){
    if(settings.recStarted){
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
    reverbButton.state = settings.reverbIsActive;
    atLeastOne = true;
  }
  if(jumpToRandom.isMousedOver()){
    jumpToRandomLocation();
    atLeastOne = true;
  }
  if(muteButton.isMousedOver()){
    toggleMute();
    atLeastOne = true;
  }
  return atLeastOne;
}
