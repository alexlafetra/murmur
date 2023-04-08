import drop.*;
/*
a few beads tricks:
it's helpful to give the 'glide' objects a long interpolation time, in
general it sounds less choppy and looks like it sways with the shape of the flock more 
*/

//initial audio file vv
//String filename = "test1_sdc.mp3";
String filename = "test2_q.mp3";
//String filename = "test3_chopin.mp3";
String buttonText;
//parameters for the flock sim

//number of birds
int numberOfBoids = 1500;
//avoidance weight
float avoidanceModifier = 1.5;
//attraction/cohesion weight
//float cohesionModifier = 1.1;
float cohesionModifier = 1.1;

//orientation/alignment weight
float orientationModifier = 1.2;
//random force weight
float randomModifier = 1;
//mouse cursor pull
float orbitModifier = 0.7;

//radius that bird is 'sensitive' to other birds
float perceptionR = 50;

//radius around the cursor that the birds are attracted to
float orbitR = 300;

//floor that the birds are repelled from
float floorHeight = 800;//DEPRECATED

int rightWall = 900;
int leftWall = 100;
int floor = 900;
int ceiling = 100;
int frontWall = 50;
int backWall = -1000;

//display controls
boolean paused = true;
int colorStyle = 1;
boolean showOrbitPoint = false;
boolean showAvgPos = false;
boolean blackOrWhite_bg = true;
boolean showingControls = true;
boolean showTails = false;
boolean walls = false;

boolean recStarted = false;

//granular synth controls
boolean stereo = true;
boolean gRate = false;
boolean pitch = true;
boolean gSize = true;
boolean gain = true;
boolean gRandom = true;
boolean reverse = true;

boolean secondWindowOpen = false;
ChildApplet childWindow;

//array of boids (holding all the boids)
Boid[] flock;

void setup(){
  size(1000,1000,P3D);
  background(0);
  //drop = new SDrop(this);
  filename = dataPath("samples/"+filename);
  numberOfRecordings = countRecordings();
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

  startplayer();
  //just so the orb starts w/ the boids
  getData();
}
//counts the recordings in the "recordings" folder
int countRecordings(){
  File f = dataFile("recordings");
  return f.list().length;
}
void drawPause(){
  int x = width/2;
  int y = height/2;
  int w = 20;
  int h = w*4;
  int gap = 40;
  //for pulsing transparency
  float alpha = map(sin(frameCount/3),-1,1,0,255);
  fill(200,200,255,alpha);
  noStroke();
  rectMode(CENTER);
  rect(x-gap/2,y-h/2,w,h,10);
  rect(x+gap/2,y-h/2,w,h,10);
}
void updateOrbitPoint(){
  orbitPoint.x = mouseX;
  orbitPoint.y = mouseY;
}
void drawControls(){
  fill(200,200,200);
  noStroke();
  rect(width-200,0,200,height);
}
void drawWalls(){
  stroke(blackOrWhite_bg ? 255:0);
  strokeWeight(3);
  
  line(leftWall,ceiling,backWall,rightWall,ceiling,backWall);
  line(leftWall,floor,backWall,rightWall,floor,backWall);
  line(leftWall,ceiling,backWall,leftWall,floor,backWall);
  line(rightWall,ceiling,backWall,rightWall,floor,backWall);
  
  line(leftWall,ceiling,frontWall,rightWall,ceiling,frontWall);
  line(leftWall,floor,frontWall,rightWall,floor,frontWall);
  line(leftWall,ceiling,frontWall,leftWall,floor,frontWall);
  line(rightWall,ceiling,frontWall,rightWall,floor,frontWall);
  
  line(leftWall,ceiling,frontWall,leftWall,ceiling,backWall);
  line(leftWall,floor,frontWall,leftWall,floor,backWall);
  line(rightWall,ceiling,frontWall,rightWall,ceiling,backWall);
  line(rightWall,floor,frontWall,rightWall,floor,backWall);
}
void drawAvgData(){
  //to color by vel, only in r/b channels (so that color represents direction in the x/y plane)
  PVector xyVel = new PVector(avgVel.x,avgVel.y);
  float angle = xyVel.heading();
  float r = map(angle,(-2)*PI,2*PI,0,255);
  color b = color(255-r,0,r);
  
  fill(b);

  noStroke();
  //drawing average location for debugging
  if(showAvgPos){
    pushMatrix();
    translate(avgPos.x,avgPos.y,avgPos.z);
    ellipse(0,0,100,100);
    popMatrix();
  }
  
  //drawing orbit point
  if(showOrbitPoint){
    fill(255);
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(orbitPoint.x,orbitPoint.y,orbitPoint.z);
    ellipse(0,0,orbitR,orbitR);
    popMatrix();
  }
  
}

void getNewSample(){
  paused = true;
  player.kill();
  selectInput("feed me an mp3 file!", "loadFile");
}

void loadFile(File selectedFile){
  if(selectedFile != null){
    String name = selectedFile.getAbsolutePath();
    //load in file path, if it's an mp3
    if(isValidAudioFileType(name)){
      filename = selectedFile.getAbsolutePath();
    }
  }
  //start the sampler
  startplayer();
  loadSample.state = true;
}
boolean isValidAudioFileType(String s){
  if(s.endsWith(".mp3")|s.endsWith(".wav")){
    return true;
  }
  else{
    return false;
  }
}
//getting x/y coord of screen
PVector getLocationOnScreen(){
  PVector location = new PVector();
  com.jogamp.newt.opengl.GLWindow window = (com.jogamp.newt.opengl.GLWindow)(((PSurfaceJOGL)surface).getNative());
  com.jogamp.nativewindow.util.Point point = window.getLocationOnScreen(new com.jogamp.nativewindow.util.Point());
  location.set(point.getX(),point.getY());
  return location;
}

void draw(){
  //NEEDS to be initialized within draw!
  /*
  not sure why. running multiple PApplets with different renderers is really buggy,
  my guess is it has something to do with when "settings" is run.
  initializing the object here seems to force all the 'setup' for the main applet to take place first,
  THEN canvas() the second one
  */
  //colorMode(HSB,400);
  //pointLight(400, 0, 400, mouseX, mouseY, 0);
  //colorMode(RGB);
  if(!secondWindowOpen){
    PVector loc = getLocationOnScreen();
    childWindow = new ChildApplet(loc.x+1000,loc.y-53);
    secondWindowOpen = true;
  }
  updateOrbitPoint();
  //clear background
  if(!showTails){
    if(blackOrWhite_bg)
      background(0);
    else
      background(255);
  }
  Boid[] buffer = flock;
  //drawBounds();
  for(int i = 0; i<flock.length; i++){
    if(!paused){
      //updating physics of each boid
      buffer[i].updatePhysics(flock);
      //updating location of each boid
      buffer[i].updateLocation();
    }
    //drawing each boid
    buffer[i].render();
  }
  flock = buffer;
  if(!paused){
    updateGrains();
  }
  else{
    drawPause();
  }
  drawAvgData();
   
  noFill();
  stroke(255);  
  cursor(ARROW);
  //if the controls are being shown
  if(showingControls){
    displayButtons();
    displaySliders();
    moveSliders();
    if(buttonOffset>0){
      buttonOffset-=5;
    }
  }
  else{
    if(buttonOffset<60){
      displayButtons();
      displaySliders();
      buttonOffset+=5;
    }
  }
  if(walls)
    drawWalls();
}

void mousePressed(){
  boolean anyInteractions = false;
  //if controls are onscreen, let them be clicked
  if(showingControls){
    if(checkButtons())
      anyInteractions = true;
    if(clickSliders())
      anyInteractions = true;
      
    //if there are no button presses/slider grabs, toggle pause
    if(!anyInteractions)
      paused = !paused;
    if(!paused)
      updateGrains();
  }
  //if not, just pause
  else{
    paused = !paused;
  }
}

void mouseReleased(){
  releaseSliders();
}

void keyPressed(){
  if(key == 'c'){
    background(0);
  }
  //pause on space
  else if(key == ' '){
    paused = !paused;
  }
  else{
    showingControls = !showingControls;
  }
}
String getFormattedFileName(){
  String text = "";
  //step back thru string until you find a "/"
  for(int i = filename.length()-1; i>=0; i--){
    if(filename.charAt(i) == '/'){
      text = filename.substring(i+1);
      return text;
    }
  }
  text = "Feed me an MP3/WAV pls";
  return text;
}
