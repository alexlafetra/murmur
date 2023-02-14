import beads.*;
import java.util.Arrays; 
//for writing audio files
import java.io.*;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioFileFormat.Type;

AudioContext ac;

int numberOfRecordings = 0;
Sample outputSample;
RecordToSample recorder;
GranularSamplePlayer player;

void startRecording(){
  //default is a 1-min (60,000ms) stereo sample,
  outputSample = new Sample(60000);
  //new recorder object
  recorder = new RecordToSample(ac,outputSample,RecordToSample.Mode.INFINITE);
  //adding the pan (final UGen in the chain) as an input
  recorder.addInput(masterGain);
  //adding recorder as an AC dependent, so it gets updated whenever ac makes sound
  //not 100% why this works the way it does, but this is needed to that recorder
  //keeps allocating memory for the sample
  //this ALONE tho won't record any audio
  ac.out.addDependent(recorder);
  recorder.start();
}
void endRecording(){
  //ending recorder
  recorder.kill();
  //cropping the sample, if it's shorter than 1 min
  recorder.clip();
  //writing the sample
  try{
    outputSample.write(sketchPath("recordings/") + "rec"+str(numberOfRecordings)+".wav");
    numberOfRecordings++;
  }
  catch(Exception e){
    println("oops!");
    println(e.getMessage());
    e.printStackTrace();
  }  
}

void loadSample(){
   Sample sample = SampleManager.sample(filename);
   player = new GranularSamplePlayer(sample);
}

void startplayer() {
   ac = new AudioContext();
   ac = AudioContext.getDefaultContext();
   loadSample();
   //loop the sample at its end points
   player.setLoopType(SamplePlayer.LoopType.LOOP_ALTERNATING);
   
   grainRate = new Glide(ac,0,100);
   grainSize = new Glide(ac,1,100);
   samplePitch = new Glide(ac,1,100);
   randomness = new Glide(ac,0,1);
   pan = new Panner(ac);
   g = new Gain(1, 0.1);
   masterGain = new Gain(1,0.1);
   
   //control the rate of grain firing
   player.setGrainInterval(grainRate);
   player.setGrainSize(grainSize);
   player.setRandomness(randomness);
   player.setPitch(samplePitch);
   g.addInput(player);//grains feed into gain
   pan.addInput(g);//gain feeds into pan
   masterGain.addInput(g);
   ac.out.addInput(masterGain);//pan feeds into ac
   ac.start();
}
//"glide" objects are like knobs!
//as UGens, you can attach them to different bead objects and they'll
//pass their value into it
Glide grainRate;
Glide grainSize;
Glide samplePitch;
Glide randomness;
Panner pan;
Glide panPos;
Gain g;
Gain masterGain;
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
  if(!paused){
    getData();
  }
  float vel = avgVel.mag();
  PVector xyHeading = new PVector(avgVel.x,avgVel.y);
  float distanceToOrbit = PVector.dist(orbitPoint,avgPos);
 
  if(reverse){
    if(xyHeading.heading()>PI/2){
       player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    }
    else{
       player.setLoopType(SamplePlayer.LoopType.LOOP_BACKWARDS);
    }
  }
  else{
   player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  }

  //blurs out sample when birds get farther away
  if(gRandom){
    randomness.setValue(distanceToOrbit/10000);
  }
  else{
    randomness.setValue(0);
  }
  if(gSize){
    grainSize.setValue(distanceToOrbit/1000);
  }
  else{
    grainSize.setValue(1);
  }
  if(pitch){
    samplePitch.setValue(avgDiff_Position*10);
  }
  else{
    samplePitch.setValue(1);
  }
  if(gRate){
    grainRate.setValue(vel/1000);
  }
  else{
    grainRate.setValue(0);
  }
  if(gain){
    g.setGain(1-map(vel,-maxSpeed,maxSpeed,0,1));
  }
  else{
    g.setGain(0.1);
  }
  if(stereo){
    pan.setPos(map(avgPos.x,-width,3*width/2,-1,1));
  }
  else{
    pan.setPos(0);
  }

  //interesting
  //if(PVector.dist(avgPos,orbitPoint)<orbitR){
  //  grainRate.setValue(-100/avgVel.mag());
  //}
  //else{
  //  grainRate.setValue(100/avgVel.mag());
  //}
}
