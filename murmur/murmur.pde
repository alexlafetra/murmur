import drop.*;
/*
a few beads tricks:
it's helpful to give the 'glide' objects a long interpolation time, in
general it sounds less choppy and looks like it sways with the shape of the flock more 
*/

//initial audio file vv
//String filename = "test1_sdc.mp3";
//String filename = "test2_q.mp3";
String filename = "test3_chopin.mp3";
String outputPath = null;
String buttonText;
//parameters for the flock sim

//number of birds
int numberOfBoids = 1000;
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

int rightWall = 1000;
int leftWall = 0;
int floor = 1000;
int ceiling = 0;
int frontWall = 50;
int backWall = -1000;

//display controls
boolean paused = true;
int colorStyle = 0;
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
boolean reverbing = false;

boolean isMuted = false;

boolean secondWindowOpen = false;
ChildApplet childWindow;

PShape logo;
//array of boids (holding all the boids)
Boid[] flock;

void drawLogo(){
  //logo
  pushMatrix();
  translate(logo.height/2-40,logo.width/2-40);
  rotateZ(-PI/2);
  colorMode(HSB,400);
  noStroke();
  if(blackOrWhite_bg){
    fill(155);
    shape(logo,0,-buttonOffset);
  }
  else{
    fill(155);
    shape(logo,0,-buttonOffset);
  }
  colorMode(RGB,255);
  popMatrix();
}

void setup(){
  //init canvas
  size(1000,1000,P3D);
  background(0);
  
  logo = loadShape("logo/murmur_logo_transparent.svg");
  logo.disableStyle();
  logo.scale(0.4);
  //black_logo.setStroke(255);
  //white_logo.disableStyle();
  //black_logo.enableStyle();
  
  //grabbing mp3 and setting the rec count
  filename = dataPath("samples/"+filename);
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

//stores a group of boids at a certain heading and location
class Group{
  PVector heading;
  PVector location;
  ArrayList<Boid> homies;
  color c;
  public Group(Boid b){
    heading = b.velocity;
    location = b.position;
    homies = new ArrayList<Boid>();
    homies.add(b);
    c = b.c;
  }
}

float headingTolerance = 10;
int positionTolerance = 100;
ArrayList<Group>groups;
boolean createGroups = false;
boolean averageGroupData = false;
boolean updateWithinGroups = false;

void updateGroups(){
  groups = new ArrayList<Group>();
  Group firstGroup = new Group(flock[0]);
  groups.add(firstGroup);
  //println("making groups...");
  for(int i = 1; i<flock.length; i++){
    boolean foundGroup = false;
    for(int j = 0; j<groups.size(); j++){
      PVector differenceInPos = PVector.sub(flock[i].position,groups.get(j).location);
      float differenceInHeading = PVector.angleBetween(flock[i].velocity,groups.get(j).heading);
      //if the boid is in the group, add it
      if(differenceInPos.mag() < positionTolerance && abs(differenceInHeading)<headingTolerance){
        //add boid
        groups.get(j).homies.add(flock[i]);
        
        if(averageGroupData){
        //average the group position
          groups.get(j).location = PVector.add(flock[i].position,groups.get(j).location);
          groups.get(j).location.div(2);
        //average the group heading
          groups.get(j).heading= PVector.add(flock[i].velocity,groups.get(j).heading);
          groups.get(j).heading.div(2);
        }
        foundGroup = true;
        break;
      }
    }
    //if the bird doesn't fit in to any of the groups, make a new group with the boid in it and add it to the list
    if(!foundGroup){
      //println("making new group");
      Group newGroup = new Group(flock[i]);
      groups.add(newGroup);
    }
  }
  //println("number of groups:" + str(groups.size()));
  //go thru each group and update the boids in it
  float tempDiff = 0;
  for(int i = 0; i<groups.size(); i++){
    if(updateWithinGroups){
      avgDiff_Position = 0;
      updatePhysicsOfGroup(groups.get(i));
      tempDiff += avgDiff_Position;
      tempDiff = tempDiff/groups.get(i).homies.size();
    }
    //println(groups.get(i).homies.size());
      
    //drawing a group if it's more than just one boid
    //if(groups.get(i).homies.size()>1)
    drawSubGroups(groups.get(i));
  }
  avgDiff_Position = (tempDiff/groups.size());
  //sampleList.update();
}

void updatePhysicsOfGroup(Group g){
  for(int i = 0; i<g.homies.size(); i++){
    Boid[] tempArray = new Boid[g.homies.size()];
    tempArray = g.homies.toArray(tempArray);
    g.homies.get(i).updatePhysics(tempArray);
  }
}

void drawSubGroups(Group g){
  //color groupColor = color(random(0,255),random(0,255),random(0,255));
  for(int i = 0; i<g.homies.size(); i++){
    color tempC = g.homies.get(i).c;
    g.homies.get(i).c = g.c;
    g.homies.get(i).render("hey");
    g.homies.get(i).c = tempC;
  }
  //fill(g.c);
  stroke(g.c);
  noFill();
  if(g.homies.size()>1){
    pushMatrix();
    //ellipse(g.location.x,g.location.y,g.homies.size(),g.homies.size());
    translate(g.location.x,g.location.y,g.location.z);
    sphere(map(g.homies.size(),0,flock.length,0,200));
    popMatrix();
  }
}

void draw(){
  //println(avgDiff_Position);
  //NEEDS to be initialized within draw!
  /*
  not sure why. running multiple PApplets with different renderers is really buggy,
  my guess is it has something to do with when "settings" is run.
  initializing the object here seems to force all the 'setup' for the main applet to take place first,
  THEN canvas() the second one
  */
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
  drawLogo();
  for(int i = 0; i<flock.length; i++){
    if(!paused){
      //updating physics of each boid
      //buffer[i].updatePhysics(flock);
      avgDiff_Position = 0;
      flock[i].updatePhysics(flock);
      avgDiff_Position/=flock.length;
      //updating location of each boid
      flock[i].updateLocation();
    }
    //drawing each boid
    flock[i].render(str(i));
  }
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
      buttonOffset-=10;
    }
  }
  else{
    if(buttonOffset<120){

      displayButtons();
      displaySliders();
      buttonOffset+=10;
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
