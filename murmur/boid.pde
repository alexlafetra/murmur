class Boid{
  //data for position, vel, and acceleration
  PVector position;
  PVector velocity;
  PVector acceleration;
  //color of the boid
  color c;
  //constructor
  Boid(){
    position = new PVector(random(0,width),random(0,width),0);
    velocity = new PVector(random(-10,10),random(-10,10),random(-10,10));
    acceleration = new PVector(0,0,0);

    c = color(random(100,255),random(100,255),random(100,255));

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
    //if you're below the floor
    if(d>=0){
      floorF = PVector.sub(floorLocation,position);
      floorF.mult(d);
      floorF.limit(maxForce);
    }
    return floorF;
  }
  PVector wallForce(){
    PVector wallF = new PVector(0,0,0);
    PVector floorF = new PVector(0,0,0);
    PVector frontF = new PVector(0,0,0);
    if(position.x>rightWall){
      wallF = new PVector(rightWall-position.x,0,0);
    }
    else if(position.x<leftWall){
      wallF = new PVector(leftWall-position.x,0,0);
    }
    if(position.y<ceiling){
      floorF = new PVector(0,ceiling-position.y,0);
    }
    else if(position.y>floorHeight){
      floorF = new PVector(0,floorHeight-position.y,0);
    }
    if(position.z<zDepth){
      frontF = new PVector(0,0,zDepth-position.z);
    }
    else if(position.z>frontWall){
      frontF = new PVector(0,0,frontWall-position.z);
    }
    wallF.add(floorF);
    wallF.add(frontF);
    wallF.limit(maxForce);
    return wallF;
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
    //force that steers boids to face the same heading as 'nearby' boids
    PVector avgOrientation = new PVector(0,0,0);
    //force that steers boids to the avg location of nearby boids
    PVector avgLocation = new PVector(0,0,0);
    //force that steers boids away from the average location of nearby boids
    PVector avoidance = new PVector(0,0,0);
    int total = 0;
    float totalDist = 0;
    //adding up the velocities of nearby voids
    for(int i = 0; i<boids.length; i++){
      float d = PVector.dist(boids[i].position,position);
      totalDist+=d;
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
    avgDiff_Position+=totalDist;
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
     
    //flock is either constrained by walls, or attracted to the cursor
    if(walls)
      force.add(wallForce());
    else
      force.add(orbit().mult(orbitModifier));
    acceleration = force;
  }

  //drawing the boid
  void render(String txt){
    flockGraphics.noStroke();
    //color by c
    if(colorStyle == 0){
      //color a = color(map(acceleration.x,0,maxForce,0,255),map(acceleration.y,0,maxForce,0,255),map(acceleration.z,0,maxForce,0,255));
      flockGraphics.fill(c);
    }
    //color by vel
    else if(colorStyle == 1){
      color a = color(map(velocity.x,-maxSpeed,maxSpeed,0,255),map(velocity.y,-maxSpeed,maxSpeed,0,255),map(velocity.z,0,maxSpeed,-maxSpeed,255));
      flockGraphics.fill(a);
    }
    //color b/w
    else if(colorStyle == 2){
      flockGraphics.stroke(0);
      flockGraphics.strokeWeight(1);
      flockGraphics.fill(255);
    }
    //color by pos
    else if(colorStyle == 3){
      color a = color(map(position.x,0,width,0,255),map(position.y,0,height,0,255),map(position.z,0,zDepth,0,255));
      flockGraphics.fill(a);
    }
    flockGraphics.pushMatrix();
    flockGraphics.translate(position.x,position.y,position.z);
    //debug numbers (not really useful for debugging, but it looks kinda cool
    if(colorStyle == 4){
      flockGraphics.fill(c);
      flockGraphics.text(txt,0,0);
    }
    //normal arrow
    else{
      PVector temp = new PVector(velocity.x,velocity.y,velocity.z);
      temp.mult(4);
      flockGraphics.beginShape(TRIANGLE_STRIP);
      flockGraphics.vertex(-boidSize/2,0,0);
      flockGraphics.vertex(boidSize/2,0,0);
      flockGraphics.vertex(temp.x,temp.y,temp.z);
      flockGraphics.vertex(0,0,boidSize*3);
      flockGraphics.vertex(-boidSize/2,0,0);
      flockGraphics.endShape();
    }
    flockGraphics.popMatrix();
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
