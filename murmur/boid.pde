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
    PVector floorLocation = new PVector(position.x,settings.floorHeight,position.z);
    PVector floorF = new PVector(0,0,0);
    float d = position.y - settings.floorHeight;
    //if you're below the floor
    if(d>=0){
      floorF = PVector.sub(floorLocation,position);
      floorF.mult(d);
      floorF.limit(settings.maxForce);
    }
    return floorF;
  }
  PVector wallForce(){
    PVector wallF = new PVector(0,0,0);
    PVector floorF = new PVector(0,0,0);
    PVector frontF = new PVector(0,0,0);
    if(position.x>settings.rightWall){
      wallF = new PVector(settings.rightWall-position.x,0,0);
    }
    else if(position.x<settings.leftWall){
      wallF = new PVector(settings.leftWall-position.x,0,0);
    }
    if(position.y<settings.ceiling){
      floorF = new PVector(0,settings.ceiling-position.y,0);
    }
    else if(position.y>settings.floorHeight){
      floorF = new PVector(0,settings.floorHeight-position.y,0);
    }
    if(position.z<settings.zDepth){
      frontF = new PVector(0,0,settings.zDepth-position.z);
    }
    else if(position.z>settings.frontWall){
      frontF = new PVector(0,0,settings.frontWall-position.z);
    }
    wallF.add(floorF);
    wallF.add(frontF);
    wallF.limit(settings.maxForce);
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
    velocity.limit(settings.maxSpeed);
  }
  
  PVector orbit(){
    //force steering boids to the orbit point, if they're outside the orbit R
    PVector orbitF = PVector.sub(this.position,flock.orbitPoint);
    orbitF.setMag(1-orbitF.mag()/settings.orbitRadius);
    //orbitF.setMag(settings.maxSpeed);
    orbitF.limit(settings.maxForce);
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
      if(boids[i] != this && d < settings.perceptionRadius){
        
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
      //set it to settings.maxSpeed
      avgOrientation.setMag(settings.maxSpeed);
      //turn it into a vector pointing away from the current boid, towards the new location
      avgOrientation.sub(velocity);
      //limit it
      avgOrientation.limit(settings.maxForce);
      
      //div for average
      avgLocation.div(total);
      //turn into vector pointing away from current boid
      avgLocation.sub(position);
      //set to settings.maxSpeed
      avgLocation.setMag(settings.maxSpeed);
      //limit
      avgLocation.limit(settings.maxForce);
      
      avoidance.div(total);
      avoidance.setMag(settings.maxSpeed);
      avoidance.sub(velocity);
      avoidance.limit(settings.maxForce);
    }
    
    //adding all the forces together
    PVector force = new PVector(0,0,0);
    force.add(avgOrientation.mult(settings.orientationModifier));
    force.add(avgLocation.mult(settings.cohesionModifier));
    force.add(avoidance.mult(settings.avoidanceModifier));
    force.add(randomForce(settings.maxForce).mult(settings.randomModifier));
     
    //flock is either constrained by settings.walls, or attracted to the cursor
    if(settings.walls)
      force.add(wallForce());
    else
      force.add(orbit().mult(settings.orbitModifier));
    acceleration = force;
  }

  //drawing the boid
  void render(String txt){
    flockGraphics.noStroke();
    //color by c
    if(settings.colorStyle == 0){
      //color a = color(map(acceleration.x,0,settings.maxForce,0,255),map(acceleration.y,0,settings.maxForce,0,255),map(acceleration.z,0,settings.maxForce,0,255));
      flockGraphics.fill(c);
    }
    //color by vel
    else if(settings.colorStyle == 1){
      color a = color(map(velocity.x,-settings.maxSpeed,settings.maxSpeed,0,255),map(velocity.y,-settings.maxSpeed,settings.maxSpeed,0,255),map(velocity.z,0,settings.maxSpeed,-settings.maxSpeed,255));
      flockGraphics.fill(a);
    }
    //color b/w
    else if(settings.colorStyle == 2){
      flockGraphics.stroke(0);
      flockGraphics.strokeWeight(1);
      flockGraphics.fill(255);
    }
    //color by pos
    else if(settings.colorStyle == 3){
      color a = color(map(position.x,0,width,0,255),map(position.y,0,height,0,255),map(position.z,0,settings.zDepth,0,255));
      flockGraphics.fill(a);
    }
    flockGraphics.pushMatrix();
    flockGraphics.translate(position.x,position.y,position.z);
    //debug numbers (not really useful for debugging, but it looks kinda cool
    if(settings.colorStyle == 4){
      flockGraphics.fill(c);
      flockGraphics.text(txt,0,0);
    }
    //normal arrow
    else{
      PVector temp = new PVector(velocity.x,velocity.y,velocity.z);
      temp.mult(4);
      flockGraphics.beginShape(TRIANGLE_STRIP);
      flockGraphics.vertex(-settings.boidSize/2,0,0);
      flockGraphics.vertex(settings.boidSize/2,0,0);
      flockGraphics.vertex(temp.x,temp.y,temp.z);
      flockGraphics.vertex(0,0,settings.boidSize*3);
      flockGraphics.vertex(-settings.boidSize/2,0,0);
      flockGraphics.endShape();
    }
    flockGraphics.popMatrix();
  }
}