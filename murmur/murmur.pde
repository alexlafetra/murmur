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

class FlockSettings{
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
  float perceptionRadius = 50;
  //radius around the cursor that the birds are attracted to
  float orbitRadius = 300;

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
  boolean simulationPaused = true;
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
  boolean reverbIsActive = false;
  boolean recStarted = false;
  boolean isMuted = false;
  
  FlockSettings(){}
}

FlockSettings settings;

class Flock{
  //array holding all the birds
  Boid[] birds;
  //Vector holding the orbit point
  PVector orbitPoint;

  Flock(int numberOfBirds){
    //allocate memory for the flock
    birds = new Boid[numberOfBirds];
    orbitPoint = new PVector(400,400,-200);

    //initialize the flock with boid objects
    for(int i = 0; i<birds.length; i++){
      birds[i] = new Boid();
    }
  }
  void updateOrbitPoint(){
    orbitPoint.x = mouseX;
    orbitPoint.y = mouseY;
  }
}

Flock flock;

//---------------------------------
//miscellaneous murmur variables
//---------------------------------
//drop window object
ChildApplet childWindow;
boolean secondWindowOpen = false;
//logo and font objects
PShape logo;
PFont garamond;

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
color otherBackgroundColor = color(255,255,255);
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
    childWindow.text = "github";
  }
  if(settings.blackOrWhite_bg){
    fill(255);
  }
  else{
    fill(0);
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

void drawFloor(){
  beginShape(QUADS);
  vertex(0,settings.floorHeight,0);
  vertex(width,settings.floorHeight,0);
  vertex(width,settings.floorHeight,settings.zDepth);
  vertex(0,settings.floorHeight,settings.zDepth);
  endShape();
}
//draws bounds around the "edges" box
void drawBounds(){
  stroke(0);
  strokeWeight(1);
  beginShape(QUADS);
  //front face
  vertex(0,0,0);
  vertex(width,0,0);
  vertex(width,height,0);
  vertex(0,height,0);
  
  //back face
  vertex(0,0,settings.zDepth);
  vertex(width,0,settings.zDepth);
  vertex(width,height,settings.zDepth);
  vertex(0,height,settings.zDepth);
  endShape();
  //edges
  beginShape(LINES);
  vertex(0,0,0);
  vertex(0,0,settings.zDepth);
  vertex(width,0,0);
  vertex(width,0,settings.zDepth);
  vertex(width,height,0);
  vertex(width,height,settings.zDepth);
  vertex(0,height,0);
  vertex(0,height,settings.zDepth);
  endShape();
  
  //middle plane
  stroke(125,0,125);
  beginShape(QUADS);
  vertex(0,0,flock.orbitPoint.z);
  vertex(width,0,flock.orbitPoint.z);
  vertex(width,height,flock.orbitPoint.z);
  vertex(0,height,flock.orbitPoint.z);
  endShape();
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
  if(settings.showAvgPos){
    pushMatrix();
    translate(avgPos.x,avgPos.y,avgPos.z);
    ellipse(0,0,100,100);
    popMatrix();
  }
  //drawing orbit point
  if(settings.showOrbitPoint){
    fill(255);
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(flock.orbitPoint.x,flock.orbitPoint.y,flock.orbitPoint.z);
    ellipse(0,0,settings.orbitRadius,settings.orbitRadius);
    popMatrix();
  }
}

//opens a file selection window so the user can select a new sample
void getNewSample(){
  settings.simulationPaused = true;
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
  if(s.endsWith(".mp3")|s.endsWith(".wav")|s.endsWith(".m4a")){
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
  if(settings.showingControls){
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
      settings.simulationPaused = !settings.simulationPaused;
    if(!settings.simulationPaused)
      updateGrains();
  }
  //if not, just pause
  else{
    settings.simulationPaused = !settings.simulationPaused;
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
    settings.simulationPaused = !settings.simulationPaused;
  }
  else if(key == 'r'){
    randomizeSliders();
  }
  else{
    settings.showingControls = !settings.showingControls;
  }
}
//adds and subtracts boids as needed
void checkBoidCount(){
  int targetNumber = int(boidSlider.max-boidSlider.currentVal) - flock.birds.length;
  //return if you don't need to add any boids
  if(targetNumber == 0)
    return;
  
  Flock newFlock = new Flock(flock.birds.length+targetNumber);

  //you need to remove targetNumber boids
  if(targetNumber<0){
    for(int i = 0; i<newFlock.birds.length; i++){
      newFlock.birds[i] = flock.birds[i];
    }
  }
  //you need to add targetNumber boids
  else if(targetNumber>0){
    for(int i = 0; i<newFlock.birds.length;i++){
      newFlock.birds[i] = (i<flock.birds.length)?flock.birds[i]:(new Boid());
    }
  }
  flock = newFlock;
}

//updates physics and renders each boid
void runSim(){
  flockGraphics.beginDraw();
  if(settings.updateScreen){
    flockGraphics.background(backgroundColor);
  }
  for(int i = 0; i<flock.birds.length; i++){
    if(!settings.simulationPaused){
      //updating physics of each boid
      avgDiff_Position = 0;
      flock.birds[i].updatePhysics(flock.birds);
      avgDiff_Position/=flock.birds.length;
      //updating location of each boid
      flock.birds[i].updateLocation();
    }
    //drawing each boid
    flock.birds[i].render(str(i));
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
  
  settings = new FlockSettings();
  flock = new Flock(settings.numberOfBoids);
  
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
  //smooth(8);
}

void draw(){
  //check to see if you need to open the second window
  if(!secondWindowOpen){
    //NEEDS to be initialized within draw!
    /*
    not sure why. running multiple PApplets with different renderers is really buggy,
    my guess is it has something to do with when "settings" is run.
    initializing the object here seems to force all the 'setup' for the main applet to take place first,
    THEN canvas() the second one
    */
    PVector loc = getLocationOnScreen();
    childWindow = new ChildApplet(loc.x+1000,loc.y-53);
    secondWindowOpen = true;
  }
  //clear background
  runSim();
  background(settings.blackOrWhite_bg?0:255);
  image(flockGraphics,0,0);
  flock.updateOrbitPoint();
  if(!settings.simulationPaused){
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
    cursor(HAND);
  }
  drawLogo();
  
  //if the controls are being shown
  if(settings.showingControls){
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
  // if(settings.walls)
  //   drawWalls();
}
