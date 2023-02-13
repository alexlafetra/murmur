/*
a few beads tricks:
it's helpful to give the 'glide' objects a long interpolation time, in
general it sounds less choppy and looks like it sways with the shape of the flock more 
*/


//parameters for the flock sim
int numberOfBoids = 1500;
float avoidanceModifier = 1.5;
float cohesionModifier = 1.1;
float orientationModifier = 1.2;
float randomModifier = 1;
float orbitModifier = 0.7;
float perceptionR = 50;
float orbitR = 300;

float floorHeight = 800;

boolean pause = true;
boolean colorByHeading = true;
boolean forward = true;

//array of boids (holding all the boids)
Boid[] flock;

void setup(){
  avgVel = new PVector(0,0,0);
  avgPos = new PVector(0,0,0);
  //allocate memory for the flock
  flock = new Boid[numberOfBoids];
  //initialize the flock with boid objects
  for(int i = 0; i<flock.length; i++){
    flock[i] = new Boid();
  }
  size(1000,1000,P3D);
  background(0);
  startplayer();
  //just so the orb starts w/ the boids
  getData();
}
void updateOrbitPoint(){
  orbitPoint.x = mouseX;
  orbitPoint.y = mouseY;
}
void drawAvgData(){
  //to color by vel
  //color b = color(map(avgVel.x,0,maxSpeed,0,255),map(avgVel.y,0,maxSpeed,0,255),map(avgVel.z,0,maxSpeed,0,255));
  
  //to color by vel, stylishly
  color b = color(map(avgVel.x,-maxSpeed,maxSpeed,0,255),0,map(avgVel.x,-maxSpeed,maxSpeed,0,255));
  
  fill(b);

  //to color by playhead direction
  //if(forward)
  //fill(255,0,0);
  //else
  //fill(0,0,255);

  noStroke();
  //drawing average location for debugging
  pushMatrix();
  translate(avgPos.x,avgPos.y,avgPos.z);
  ellipse(0,0,100,100);
  popMatrix();
  
  //drawing orbit point
  //noFill();
  //stroke(0);
  //strokeWeight(1);
  //pushMatrix();
  //translate(orbitPoint.x,orbitPoint.y,orbitPoint.z);
  //ellipse(0,0,orbitR,orbitR);
  //popMatrix();
  
}
void draw(){
  updateOrbitPoint();
  //clear background
  background(255);
  Boid[] buffer = flock;
  //drawBounds();
  for(int i = 0; i<flock.length; i++){
    if(!pause){
      //updating physics of each boid
      buffer[i].updatePhysics(flock);
      //updating location of each boid
      buffer[i].updateLocation();
    }
    //drawing each boid
    buffer[i].render();
  }
  flock = buffer;
  if(!pause){
    updateGrains();
  }
  drawAvgData();
   
  noFill();
  stroke(255);
  drawFloor();
  //pushMatrix();
  //noFill();
  //stroke(255);
  //strokeWeight(1);
  //translate(orbitPoint.x,orbitPoint.y,orbitPoint.z);
  //ellipse(0,0,50,50);
  //popMatrix();
}

void mousePressed(){
  pause = !pause;
}
