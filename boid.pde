
//size of the bounding box
float zDepth = -800;

PVector orbitPoint = new PVector(400,400,-200);
//size the boids are drawn at
float boidSize = 6;
//limit on forces
float maxForce = 0.5;
float maxSpeed = 10;
class Boid{
  //data for position, vel, and acceleration
  PVector position;
  PVector velocity;
  PVector acceleration;
  //color of the boid
  color c;
  //constructor
  Boid(){
    position = new PVector(random(200,600),random(200,600),0);
    velocity = new PVector(random(-10,10),random(-10,10),random(-10,10));
    acceleration = new PVector(0,0,0);

    c = color(random(100,255),random(100,255),random(100,255));

  }
  //this will probably get replaced with another steering function
  //but for now, edges teleports boids to opposite end of screen when they leave it
  void edges(){
    if(position.x>width)
      position.x = 0;
    if(position.x<0)
      position.x = width;
    if(position.y>height)
      position.y = 0;
    if(position.y<0)
      position.y = height;
    if(position.z<zDepth)
      position.z = 0;
    if(position.z>-zDepth)
      position.z = zDepth;
  }
  
  PVector randomForce(float mag){
    PVector randomF = new PVector(random(-1,1),random(-1,1),random(-1,1));
    randomF.setMag(mag);
    return randomF;
  }
  
  //force pushing birds out of/away from floor
  PVector floorForce(){
    //new point at the bird's location on the floor
    PVector floorLocation = new PVector(position.x,floorHeight,position.z);
    PVector floorF = new PVector(0,0,0);
    float d = position.y - floorHeight;
    //if you're above the floor
    if(d<0){
      //if it can 'see' the floor
      //if(abs(d)<perceptionR){
        floorF = PVector.sub(floorLocation,position);
        floorF.mult(1/pow(d,2));
        floorF.limit(maxForce);
      //}
    }
    //if you're below the floor
    else{
        floorF = PVector.sub(floorLocation,position);
      floorF.mult(d);
      floorF.limit(maxForce);
    }
    return floorF;
  }
  
  //force that should simulate the way it's more efficient to travel perpendicular to gravity
  //for a bird
  PVector perpendicularToGravity(){
    PVector gForce = new PVector(0,0,0);
    return gForce;
  }
  
  //update the physics of the boid
  void updateLocation(){
    //position is incremented by velocity
    position.add(velocity);
    //velocity is incremented by acceleration
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    //don't need to do edges now that the boids orbit the point
    //edges();
  }
  
  PVector orbit(){
    //force steering boids to the orbit point, if they're outside the orbit R
    PVector orbitF = PVector.sub(this.position,orbitPoint);
    orbitF.setMag(1-orbitF.mag()/orbitR);
    //orbitF.setMag(maxSpeed);
    orbitF.limit(maxForce);
    return orbitF;
  }

  void updatePhysics(Boid[] boids){
    avgDiff_Position = 0;
    //force that steers boids to face the same heading as 'nearby' boids
    PVector avgOrientation = new PVector(0,0,0);
    //force that steers boids to the avg location of nearby boids
    PVector avgLocation = new PVector(0,0,0);
    //force that steers boids away from the average location of nearby boids
    PVector avoidance = new PVector(0,0,0);
    int total = 0;
    float avgDist = 0;
    //adding up the velocities of nearby voids
    for(int i = 0; i<boids.length; i++){
      float d = PVector.dist(boids[i].position,position);
      avgDist+=d;
      if(boids[i] != this && d < perceptionR){
        
        //add position to the average location vector
        avgLocation.add(boids[i].position);
        //add orientation (velocity) to the average orientation vector
        avgOrientation.add(boids[i].velocity);
        //add a vector pointing from the other boid, TO the calling boid
        //divided by the distance d
        avoidance.add(PVector.sub(position,boids[i].position).div(d));
        total++;
      }
    }
    avgDiff_Position+=avgDist/numberOfBoids;
    if(total>0){
      //divide to get the average orientation
      avgOrientation.div(total);
      //set it to maxspeed
      avgOrientation.setMag(maxSpeed);
      //turn it into a vector pointing away from the current boid, towards the new location
      avgOrientation.sub(velocity);
      //limit it
      avgOrientation.limit(maxForce);
      
      //div for average
      avgLocation.div(total);
      //turn into vector pointing away from current boid
      avgLocation.sub(position);
      //set to maxspeed
      avgLocation.setMag(maxSpeed);
      //limit
      avgLocation.limit(maxForce);
      
      avoidance.div(total);
      avoidance.setMag(maxSpeed);
      avoidance.sub(velocity);
      avoidance.limit(maxForce);
    }
    
    //adding all the forces together
    PVector force = new PVector(0,0,0);
    force.add(avgOrientation.mult(orientationModifier));
    force.add(avgLocation.mult(cohesionModifier));
    force.add(avoidance.mult(avoidanceModifier));
    force.add(randomForce(maxForce).mult(randomModifier));
    force.add(orbit().mult(orbitModifier));
    force.add(floorForce());
    acceleration = force;
  }

  //drawing the boid
  void render(){
    noStroke();
    if(colorByHeading){
      color a = color(map(velocity.x,-maxSpeed,maxSpeed,0,255),map(velocity.y,-maxSpeed,maxSpeed,0,255),map(velocity.z,0,maxSpeed,-maxSpeed,255));
      //color a = color(map(acceleration.x,0,maxForce,0,255),map(acceleration.y,0,maxForce,0,255),map(acceleration.z,0,maxForce,0,255));
    //color a = color(map(position.x,0,width,0,255),map(position.y,0,height,0,255),map(position.z,0,zDepth,0,255));
      fill(a);
    }
    else{
      fill(c);
    }
    //fill(0);
    pushMatrix();
    translate(position.x,position.y,position.z);
    PVector temp = new PVector(velocity.x,velocity.y,velocity.z);
    temp.mult(3);
    beginShape(TRIANGLE_STRIP);
    vertex(-boidSize/2,0,0);
    vertex(boidSize/2,0,0);
    vertex(temp.x,temp.y,temp.z);
    vertex(0,0,boidSize*3);
    vertex(-boidSize/2,0,0);
    endShape();
    //for rendering as a circle instead
    //ellipse(0,0,boidSize,boidSize);
    popMatrix();
  }
}
void drawFloor(){
  beginShape(QUADS);
  vertex(0,floorHeight,0);
  vertex(width,floorHeight,0);
  vertex(width,floorHeight,zDepth);
  vertex(0,floorHeight,zDepth);
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
  vertex(0,0,zDepth);
  vertex(width,0,zDepth);
  vertex(width,height,zDepth);
  vertex(0,height,zDepth);
  endShape();
  //edges
  beginShape(LINES);
  vertex(0,0,0);
  vertex(0,0,zDepth);
  vertex(width,0,0);
  vertex(width,0,zDepth);
  vertex(width,height,0);
  vertex(width,height,zDepth);
  vertex(0,height,0);
  vertex(0,height,zDepth);
  endShape();
  
  //middle plane
  stroke(125,0,125);
  beginShape(QUADS);
  vertex(0,0,orbitPoint.z);
  vertex(width,0,orbitPoint.z);
  vertex(width,height,orbitPoint.z);
  vertex(0,height,orbitPoint.z);
  endShape();
}
