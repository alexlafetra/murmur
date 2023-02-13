import beads.*;
import java.util.Arrays; 

AudioContext ac;
//String filename = "/Users/alex/Desktop/murmur_testing/Frédéric Chopin_ Nocturne in E-Flat Major, Op. 9, No. 2.mp3";
//String filename = "/Users/alex/Desktop/murmur_testing/7.25.22_q.mp3";
//String filename = "/Users/alex/Desktop/Music/Bounces/sr16.1.19.22.mp3";
//String filename = "/Users/alex/Desktop/Music/Bounces/test.mp3";
String filename = "/Users/alex/Desktop/Music/Bounces/7.24.22silverdollarcreek.mp3";

GranularSamplePlayer player;


void startplayer() {
   ac = AudioContext.getDefaultContext();
   Sample sample = SampleManager.sample(filename);
   player = new GranularSamplePlayer(sample);
   //loop the sample at its end points
   player.setLoopType(SamplePlayer.LoopType.LOOP_ALTERNATING);
   
   grainRate = new Glide(ac,0,100);
   grainSize = new Glide(ac,1,100);
   samplePitch = new Glide(ac,1,100);
   randomness = new Glide(ac,0,1);
   loopEnd = new Glide(ac,0,1);
   
   //control the rate of grain firing
   player.setGrainInterval(grainRate);
   player.setGrainSize(grainSize);
   player.setRandomness(randomness);
   //player.setLoopEnd(loopEnd);
   player.setPitch(samplePitch);
   
  g = new Gain(1, 0.1);
  g.addInput(player);
  ac.out.addInput(g);
  ac.start();
  

}
//"glide" objects are like knobs!
//as UGens, you can attach them to different bead objects and they'll
//pass their value into it
Glide grainRate;
Glide grainSize;
Glide samplePitch;
Glide randomness;
Glide playbackRate;
Glide loopEnd;
Glide loopType;
Gain g;
//parameters that get updated by the flock
PVector avgVel;
//set play direction based on L/R of screen
PVector avgPos;

//these two are only updated by the flock loop, to save resources
//this is a measure of the relative spatial spread
float avgDiff_Position = 0;
//need a measure of the spread in the headings
float avgDiff_Heading = 0;

//getting data from flock for music purposes
void getData(){
  avgVel = new PVector(0,0,0);
  avgPos = new PVector(0,0,0);
  for(int i = 0; i<flock.length; i++){
    avgPos.add(flock[i].position);
    avgVel.add(flock[i].velocity);
  }
  avgPos.div(flock.length);
  avgVel.div(flock.length);
}
void updateGrains(){
  if(!pause){
    getData();
  }
  float vel = avgVel.mag();
  PVector xyHeading = new PVector(avgVel.x,avgVel.y);
  float distanceToOrbit = PVector.dist(orbitPoint,avgPos);
  
  if(xyHeading.heading()>PI/2){
     player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
     forward = true;
  }
  else{
     player.setLoopType(SamplePlayer.LoopType.LOOP_BACKWARDS);
     forward = false;
  }
  //println("avg heading:"+str(degrees(xyHeading.heading())));
  //println("avgPosX:"+str(avgPos.x));
  //println("distance to orbit:"+str(distanceToOrbit));
  //println("avg vel:"+str(vel));
  //println("avg dist:"+str(avgDiff_Position));
  //println(map(distanceToOrbit,0,200000,1,1000));
  
  //blurs out sample when birds get farther away
  randomness.setValue(distanceToOrbit/10000);
  //randomness.setValue(avgDiff_Position/100);

 
  grainSize.setValue(distanceToOrbit/1000);
  samplePitch.setValue(avgDiff_Position*10);
  grainRate.setValue(vel/1000);
  
  g.setGain(1-map(vel,-maxSpeed,maxSpeed,0,1));
  

  //interesting
  //if(PVector.dist(avgPos,orbitPoint)<orbitR){
  //  grainRate.setValue(-100/avgVel.mag());
  //}
  //else{
  //  grainRate.setValue(100/avgVel.mag());
  //}
  
}
