 //------------------------------------------------------------------
 /*
   __    __     __  __     ______     __    __     __  __     ______    
  /\ "-./  \   /\ \/\ \   /\  == \   /\ "-./  \   /\ \/\ \   /\  == \   
  \ \ \-./\ \  \ \ \_\ \  \ \  __<   \ \ \-./\ \  \ \ \_\ \  \ \  __<   
   \ \_\ \ \_\  \ \_____\  \ \_\ \_\  \ \_\ \ \_\  \ \_____\  \ \_\ \_\ 
    \/_/  \/_/   \/_____/   \/_/ /_/   \/_/  \/_/   \/_____/   \/_/ /_/
  
*/
//------------------------------------------------------------------

//drop library for file dropping
import drop.*;

//---------------------------------
//parameters for the flock sim
//---------------------------------
//Vector holding the orbit point
PVector orbitPoint = new PVector(400,400,-200);

//size the boids are drawn at
float boidSize = 10;

//limit on forces
float maxForce = 0.5;
float maxSpeed = 10;

//number of birds
int numberOfBoids = 1000;
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
//---------------------------------
//wall dimensions
//---------------------------------
int rightWall = 1000;
int leftWall = 0;
float floorHeight = 800;
int ceiling = 0;
int frontWall = 50;
int zDepth = -800;
//---------------------------------
//display controls
//---------------------------------
boolean paused = true;
int colorStyle = 0;
boolean showOrbitPoint = false;
boolean showAvgPos = false;
boolean blackOrWhite_bg = true;
boolean showingControls = true;
boolean updateScreen = true;
boolean walls = false;
//---------------------------------
//granular synth controls
//---------------------------------
boolean stereo = true;
boolean gRate = false;
boolean pitch = true;
boolean gSize = true;
boolean gain = true;
boolean gRandom = true;
boolean reverse = true;
boolean reverbing = false;
boolean recStarted = false;
boolean isMuted = false;
//---------------------------------
//miscellaneous murmur variables
//---------------------------------
//drop window object
ChildApplet childWindow;
boolean secondWindowOpen = false;
//logo and font objects
PShape logo;
PFont garamond;
//array that holds the birds
Boid[] flock;
//initial audio file name (from the demo folder)
String filename = "demoSamples/demo1_chopin.mp3";
//path to record into
String outputPath = null;
//link to website
String website = "https://github.com/alexlafetra/murmur";

//boids are drawn to the flock sim, which is then displayed behind the buttons/everything else
//so that no frame refresh doesn't redraw the buttons
PGraphics flockGraphics;

color backgroundColor = color(0,0,0);
//---------------------------------

//draws svg logo in top left corner
void drawLogo(){
  //logo
  pushMatrix();
  translate(logo.height/2-40,logo.width/2-40);
  rotateZ(-PI/2);
  noStroke();
  boolean highlight = false;
  if(isOverLogo()){
    highlight = true;
    childWindow.text = "Info";
  }
  if(blackOrWhite_bg){
    if(highlight)
      fill(250);
    else
      fill(100);
  }
  else{
    if(highlight)
      fill(50);
    else
      fill(200);
  }
  shape(logo,0,-buttonOffset);
  popMatrix();
}

//checks to see if mouse is over the logo
boolean isOverLogo(){
  if(mouseX>(20) && mouseX<(40+logo.height*0.4) && mouseY>(20-buttonOffset) && mouseY < (20-buttonOffset+logo.width*0.4)){
    cursor(HAND);
    return true;
  }
  else{
    return false;
  }
}

//draws pause symbol to screen
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

//updates the orbit point with mouse location
void updateOrbitPoint(){
  orbitPoint.x = mouseX;
  orbitPoint.y = mouseY;
}

//draws lines representing the sim walls
void drawWalls(){
  //stroke(blackOrWhite_bg ? 255:0);
  //strokeWeight(3);
  
  //line(leftWall,ceiling,zDepth,rightWall,ceiling,zDepth);
  //line(leftWall,floorHeight,zDepth,rightWall,floorHeight,zDepth);
  //line(leftWall,ceiling,zDepth,leftWall,floorHeight,zDepth);
  //line(rightWall,ceiling,zDepth,rightWall,floorHeight,zDepth);
  
  //line(leftWall,ceiling,frontWall,rightWall,ceiling,frontWall);
  //line(leftWall,floorHeight,frontWall,rightWall,floorHeight,frontWall);
  //line(leftWall,ceiling,frontWall,leftWall,floorHeight,frontWall);
  //line(rightWall,ceiling,frontWall,rightWall,floorHeight,frontWall);
  
  //line(leftWall,ceiling,frontWall,leftWall,ceiling,zDepth);
  //line(leftWall,floorHeight,frontWall,leftWall,floorHeight,zDepth);
  //line(rightWall,ceiling,frontWall,rightWall,ceiling,zDepth);
  //line(rightWall,floorHeight,frontWall,rightWall,floorHeight,zDepth);
}

//draws a sphere at the location of the average data
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

//opens a file selection window so the user can select a new sample
void getNewSample(){
  paused = true;
  player.kill();
  selectInput("feed me an mp3 file!", "loadFile");
}

//loads a selected file into the granular sampler
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

//checks if the file is an mp3 or wav file
boolean isValidAudioFileType(String s){
  if(s.endsWith(".mp3")|s.endsWith(".wav")){
    return true;
  }
  else{
    return false;
  }
}

//gets the filename from the filepath
String getFormattedFileName(){
  String text;
  //step back thru string until you find a "/"
  for(int i = filename.length()-1; i>=0; i--){
    if(filename.charAt(i) == '/'){
      text = filename.substring(i+1);
      if(text != "demo1_chopin.mp3")
        return text;
      else
        break;
    }
  }
  return "feed me an mp3 <3";
}

//getting x/y coord of screen
PVector getLocationOnScreen(){
  PVector location = new PVector();
  com.jogamp.newt.opengl.GLWindow window = (com.jogamp.newt.opengl.GLWindow)(((PSurfaceJOGL)surface).getNative());
  com.jogamp.nativewindow.util.Point point = window.getLocationOnScreen(new com.jogamp.nativewindow.util.Point());
  location.set(point.getX(),point.getY());
  return location;
}

//checks buttons and sliders whenever mouse is pressed
void mousePressed(){
  boolean anyInteractions = false;
  //if controls are onscreen, let them be clicked
  if(showingControls){
    if(checkButtons())
      anyInteractions = true;
    if(clickSliders())
      anyInteractions = true;
    if(isOverLogo()){
      anyInteractions = true;
      link(website);
    }
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

//key commands
void keyPressed(){
  //clearing the screen
  if(key == 'c'){
    flockGraphics.beginDraw();
    flockGraphics.background(backgroundColor);
    flockGraphics.endDraw();
  }
  //pause on space
  else if(key == ' '){
    paused = !paused;
  }
  else if(key == 'r'){
    randomizeSliders();
  }
  else{
    showingControls = !showingControls;
  }
}
//adds and subtracts boids as needed
void checkBoidCount(){
  int targetNumber = int(boidSlider.max-boidSlider.currentVal) - flock.length;
  //return if you don't need to add any boids
  if(targetNumber == 0)
    return;
  
  Boid[] newFlock = new Boid[flock.length+targetNumber];
  //you need to remove targetNumber boids
  if(targetNumber<0){
    for(int i = 0; i<newFlock.length; i++){
      newFlock[i] = flock[i];
    }
  }
  //you need to add targetNumber boids
  else if(targetNumber>0){
    for(int i = 0; i<newFlock.length;i++){
      newFlock[i] = (i<flock.length)?flock[i]:(new Boid());
    }
  }
  flock = newFlock;
}

//updates physics and renders each boid
void flock(){
  flockGraphics.beginDraw();
  if(updateScreen){
    flockGraphics.background(backgroundColor);
  }
  for(int i = 0; i<flock.length; i++){
    if(!paused){
      //updating physics of each boid
      avgDiff_Position = 0;
      flock[i].updatePhysics(flock);
      avgDiff_Position/=flock.length;
      //updating location of each boid
      flock[i].updateLocation();
    }
    //drawing each boid
    flock[i].render(str(i));
  }
  flockGraphics.endDraw();
}

void setup(){
  logo = loadShape("logo/murmur_logo_transparent.svg");
  logo.disableStyle();
  logo.scale(0.4);
  
  garamond = loadFont("Garamond-Italic-48.vlw");
  
  //grabbing mp3 and setting the rec count
  filename = dataPath(filename);
  numberOfRecordings = 0;
  
  avgVel = new PVector(0,0,0);
  avgPos = new PVector(0,0,0);
  
  //allocate memory for the flock
  flock = new Boid[numberOfBoids];
  
  //initialize the flock with boid objects
  for(int i = 0; i<flock.length; i++){
    flock[i] = new Boid();
  }
  
  //loading controls
  makeButtons();
  makeSliders();

  //starting audio
  startplayer();
  //just so the orb starts w/ the boids
  getData();
  
  flockGraphics = createGraphics(1000,1000,P3D);
  flockGraphics.noSmooth();
  
  //init canvas
  size(1000,1000,P3D);
  background(0);
  smooth(8);
}

void draw(){
  if(!secondWindowOpen){
    PVector loc = getLocationOnScreen();
    childWindow = new ChildApplet(loc.x+1000,loc.y-53);
    secondWindowOpen = true;
    //NEEDS to be initialized within draw!
    /*
    not sure why. running multiple PApplets with different renderers is really buggy,
    my guess is it has something to do with when "settings" is run.
    initializing the object here seems to force all the 'setup' for the main applet to take place first,
    THEN canvas() the second one
    */
  }
  //clear background
  background(blackOrWhite_bg?0:255);
  flock();
  image(flockGraphics,0,0);
  updateOrbitPoint();
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
    
  //if no buttons/sliders are hovered over
  //remove the button text
  if(!displayButtons()){
    if(!displaySliders()){
      childWindow.text = null;
    }
  }
  else{
    displaySliders();
  }
  drawLogo();
  
  //if the controls are being shown
  if(showingControls){
    moveSliders();
    if(buttonOffset>0){
      buttonOffset-=10;
    }
  }
  else{
    if(buttonOffset<130){
      buttonOffset+=10;
    }
  }
  if(walls)
    drawWalls();
}
