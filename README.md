<p align="center">
  <img src="https://github.com/alexlafetra/murmur/blob/main/resources/images/murmur_logo.svg" />
</p>
 
 
 <p align = "center">
  "a soft, indistinct sound made by a person or group of people speaking quietly or at a distance."
 </p>


 
 Murmur is a digital instrument built around collective flocking behavior. It gets its name from "murmuration"-- a group of starlings flocking together, and from the concept of many voices speaking indistinctly.

 ![An image of murmur in-action](/resources/images/img1_header.png)

Murmur is a statistical engine that runs a simulation of a community of "birds" and updates the parameters of a granular synthesizer with data from the flock.
Murmur doesn't make sound on its own--you need to feed it a sound it can digest and resample.
 
 Murmur is written in Java using [Processing](https://processing.org/). It uses the [Beads](http://www.beadsproject.net/) library to work with audio files and to mess with granular audio synthesis. The logic behind the flocking sim is heavily inspired  from Craig Reynold's original 1986 ["Boids"](https://www.red3d.com/cwr/boids/) algorithm, implemented in Murmur in 3D with 3000 birds. Reynold's website has a great description of the mathematics and the biological significant of the algorithm, and it does a really great job of creating unexpected and rule-based chaos in a musical system.
 
 # Instructions
 ## Running the Application
 The Window's .exe and OSX .app can both be downloaded [here](https://drive.google.com/drive/folders/1RTlT_pMIr7A4LObX3EDhMFMRy6rMbsHC?usp=share_link).
 The OSX app comes packaged with java, but to run the window's executable you'll need to download [OpenJDK](https://jdk.java.net/) *(I haven't actually tested this, at all. If you do, please let me know if it does/does not work!)*
 
 Because I'm not an identified Apple developer, murmur is a self-signed app and might not be trusted by your mac. If your computer won't run it, it may be because Apple's being extra-cautious. [Here's](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unidentified-developer-mh40616/mac) Apple's how-to for opening unidentified software anyway.
 
 To run murmur from within the [Processing IDE](https://processing.org/download) as a Processing sketch, download the "murmur" folder and open any of the .pde files inside of it.  Once you've opened the sketch in the IDE, download the Beads library using Processing's library loader, and you should be able to run it as a normal processing sketch.
 
 You can email me at alexlafetrathompson@gmail.com or message me on instagram [@alexlafetra](https://www.instagram.com/alexlafetra/) with any questions (or comments,examples)
 
 ## Controls
 The murmuration is attracted to a radius surrounding your cursor. Moving it around the screen instigates the flock to chase you down to maintain a certain distance from you, while also aligning, avoiding, and moving towards one another.
  Murmur is controlled by the (admittedly confusing) buttons in the top right corner of the window, and your mouse. Buttons along the right edge of the screen connect the murmuration to murmur's granular sample engine, and buttons along the top affect the way the flock is visualized. Each button displays a tooltip telling you what parameter it controls.
 
 Clicking anywhere on the screen "freezes" the flock simulation, pressing any key shows/hides the button layout.
 
 # Quick Tips
 - Start with your system volume **low!** Use the slider in the lower right hand corner to adjust murmur's volume as it plays.
 - Choose rich audio, in volume, texture, and structure. The more varied your source sample is, the more complex murmur's output can be.
 - Turn **pitch** off for more melodic sounds. It's on by default, and I love it, but it crunches up any melodic character fed into the murmuration. If you want more ambient, harmonically-sane sounds I recommend keeping it off.
 - **Record!** You can record yourself playing with murmur, do it. Mess around with freezing the sim, and linking/unlinking parameters, and loading different audio files. If you want to record both audio and video, you can use screen recording software like Quicktime or [OBS](https://obsproject.com/) paired with a loopback audio port like [BlackHole](https://github.com/ExistentialAudio/BlackHole). Again, message me if you need any help!
 
 ### Audio engine
  Clicking each button toggle's the corresponding connection between the sampler and the murmuration:
 - space between birds --> sample pitch
 - position --> L/R pan
 - speed --> grain rate
 - distance from cursor --> grain size
 - speed --> gain
 - distance from cursor --> noise
 - L/R velocity --> temporal direction (fwd/rev)

 ![An image of murmur's controls](/resources/images/img4.png)

On the right, the last orange and the round red button allow you to load and save recorded samples, respectively. Murmur currently can load in .mp3 and .wav files, and records to .wav files by default.

### Murmuration
Buttons along the top of the screen control murmur's visual appearance. From left to right, these buttons let you:
- freeze redrawing, giving each bird a trail.
- show the average position of the murmuration, colored by the average direction of all birds within it.
- show the orbit radius around the cursor.
- color each bird by its unique color, or by its velocity vector. Velocity by default, which *usually* helps visually highlight the subflocks within the group.
- toggle between a black and white background, *_night mode baby_*.
 
 ![A Pretty Pic](/resources/images/img2_header.png)
