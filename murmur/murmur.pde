/*
a few beads tricks:
it's helpful to give the 'glide' objects a long interpolation time, in
general it sounds less choppy and looks like it sways with the shape of the flock more 
*/

//initial audio file vv
//String filename = "test1_sdc.mp3";
//String filename = "test2_q.mp3";
String filename = "test3_chopin.mp3";

//parameters for the flock sim

//number of birds
int numberOfBoids = 1500;
//avoidance weight
float avoidanceModifier = 1.5;
//attraction/cohesion weight
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
float floorHeight = 800;

//display controls
boolean paused = true;
boolean colorByHeading = true;
boolean showOrbitPoint = false;
boolean showAvgPos = false;
boolean blackOrWhite_bg = false;
boolean showingControls = true;
boolean showTails = false;

boolean recStarted = false;

//granular synth controls
boolean stereo = true;
boolean gRate = true;
boolean pitch = true;
boolean gSize = true;
boolean gain = true;
boolean gRandom = true;
boolean reverse = true;
//array of boids (holding all the boids)
Boid[] flock;

void setup(){
  numberOfRecordings = countRecordings();
  //PFont font;
  //font = createFont("LetterGothicStd.otf",128);
  //textFont(font,128);
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
  size(1000,1000,P3D);
  background(0);
  String path = sketchPath("samples/");
  filename = path+filename;
  startplayer();
  //just so the orb starts w/ the boids
  getData();
  masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
}

//counts the recordings in the "recordings" folder
int countRecordings(){
  File f = dataFile(sketchPath("recordings/"));
  println(f.list().length);
  return f.list().length;
  //return 0;
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
    if(name.endsWith(".mp3") || name.endsWith(".wav")){
      filename = selectedFile.getAbsolutePath();
    }
  }
  //start the sampler
  startplayer();
  loadSample.state = true;
}
void draw(){
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
    //noCursor();
  }
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
  background(0);
  showingControls = !showingControls;
}
