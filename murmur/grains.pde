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
Reverb reverb;

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
Glide gainGlide;
Glide reverbSize;

//parameters that get updated by the flock
PVector avgVel;
//set play direction based on L/R of screen
PVector avgPos;
//these two are only updated by the flock loop, to save resources
//this is a measure of the relative spatial spread
float avgDiff_Position = 0;
//need a measure of the spread in the headings
float avgDiff_Heading = 0;
float headingVariance;

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
    outputSample.write(dataPath("recordings/rec"+str(numberOfRecordings)+".wav"));
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
   player.setLoopType(SamplePlayer.LoopType.LOOP_ALTERNATING);
   //link controls to synth and link Beads together to form audio out
   player.setGrainInterval(grainRate);
   player.setGrainSize(grainSize);
   player.setRandomness(randomness);
   player.setPitch(samplePitch);
}

void startplayer() {
   ac = new AudioContext();
   ac = AudioContext.getDefaultContext();
   g = new Gain(1, 0.1);

   //glide controls
   grainRate = new Glide(ac,0,100);
   grainSize = new Glide(ac,0.1,100);
   samplePitch = new Glide(ac,1,100);
   randomness = new Glide(ac,0,1);
   pan = new Panner(ac);
   gainGlide = new Glide(ac,0.1,10);
   reverbSize = new Glide(ac,0.1,0);
   
   reverb = new Reverb(ac,2);
   reverb.pause(!reverbing);
   
   //gain that's controlled by flock
   g.setGain(gainGlide);
   //master gain, controlled by slider
   masterGain = new Gain(1,0.1);
   masterGain.setGain(volumeSlider.max-volumeSlider.currentVal);
   
  loadSample();

   g.addInput(player);//player feeds into g
   pan.addInput(g);//g feed into pan
   reverb.addInput(pan);//pan feeds into reverb
   masterGain.addInput(pan);//pan feeds into masterGain
   masterGain.addInput(reverb);
   ac.out.addInput(masterGain);//masterGain feeds into ac
   
   ac.start();
}

//getting data from flock for music purposes
void getData(){
  //getting the avg vel and the avg position
  avgVel = new PVector(0,0,0);
  avgPos = new PVector(0,0,0);
  for(int i = 0; i<flock.length; i++){
    avgPos.add(flock[i].position);
    avgVel.add(flock[i].velocity);
  }
  avgPos.div(flock.length);
  avgVel.div(flock.length);
  
  //getting variances
  PVector headingVar = new PVector(0,0,0);
  for(int i = 0; i<flock.length; i++){
    headingVar.x += sq(flock[i].velocity.x - avgVel.x);
    headingVar.y += sq(flock[i].velocity.x - avgVel.x);
    headingVar.z += sq(flock[i].velocity.x - avgVel.x);
  }
  headingVar.div(flock.length);
  headingVariance = headingVar.mag();
}

void toggleReverb(){
  reverbing = !reverbing;
  reverb.pause(!reverbing);
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
    //randomness.setValue(distanceToOrbit/10000);
    randomness.setValue(headingVariance/300);
  }
  else{
    randomness.setValue(0);
  }
  if(pitch){
    samplePitch.setValue(avgDiff_Position*10);
    //samplePitch.setValue(headingVariance*100);
  }
  else{
    samplePitch.setValue(1);
  }
  if(gSize){
    //grainSize.setValue(distanceToOrbit/1000);
    //println(distanceToOrbit/1000);
    //grainSize.setValue(avgDiff_Position/1000);
    //grainSize.setValue(map(headingVariance,0,40,0.01,0.9));
    grainSize.setValue(map(headingVariance,0,40,0,1));
  }
  else{
    grainSize.setValue(0.1);
  }
  if(gRate){
    //grainRate.setValue(vel/1000);
    grainRate.setValue(1/map(headingVariance,0,60,0,10));
    //grainRate.setValue(10/pow(headingVariance,3));
    //grainRate.setValue(avgDiff_Position/500);
  }
  else{
    grainRate.setValue(0);
  }
  if(gain){
    gainGlide.setValue(map(vel,-maxSpeed/2,maxSpeed,0,0.1));
    //g.setGain(1-map(vel,-maxSpeed,maxSpeed,0,1));
  }
  else{
    //g.setGain(0.1);
    gainGlide.setValue(0.1);
  }
  if(stereo){
    pan.setPos(map(avgPos.x,-width,3*width/2,-1,1));
  }
  else{
    pan.setPos(0);
  }
  if(reverbing){
    //reverb.setSize(map(avgDiff_Position,100,400,0,1));
    //averageing so you don't get as many reverb clicks
    reverb.setSize(reverb.getSize()+(map(avgDiff_Position,0,1000,0,1)-reverb.getSize()/4));
    //reverb.setSize(reverb.getSize()+(map(headingVariance,0,60,0,1)-reverb.getSize()/4));
  }
  else{
    reverb.setSize(0);
  }
}
