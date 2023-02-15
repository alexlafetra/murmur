# murmur
 Murmur is a digital instrument built around collective flocking behavior, it gets its name from "murmuration" and the google definition for 'murmur' -- 
 
 "a soft, indistinct sound made by a person or group of people speaking quietly or at a distance."
 
Inside murmur, a community of simulated birds continually updates the parameters of a granular sampler engine, synthesizing and recording sound from an audio sample that you feed it.
 
 Murmur is being written in Java and is built using [Processing](https://processing.org/) (which I literally cannot recommend enough). It uses the [Beads](http://www.beadsproject.net/) library to work with audio files and to mess with granular audio synthesis.
 
  ![An image of murmur in-action](/resources/images/img1_header.png)
 
 # Instructions
 ## Running the Application
 To run murmur from within the [Processing IDE](https://processing.org/download), download the "murmur" folder and open any of the .pde files inside of it.  Once you've opened the sketch in the IDE, download the Beads library using Processing's library loader, and you should be able to run it as a normal processing sketch.
 
 To run murmur without downloading the IDE, dm me! Unfortunately, bundled with Java, the app is too large to host on Github. It's free (of course), so if you're interested and don't have any experience using Processing/just want a standalone app drop me a line and I'll send you a link to a packaged application. If enough people want a copy, I'll definitely look into hosting it on dropbox.
 
 You can email me at alexlafetrathompson@gmail.com or message me on instagram [@alexlafetra](https://www.instagram.com/alexlafetra/). 
 
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
 
 ![An image of murmur's controls](/resources/images/img2_header.png)
 
 ### Screen Recording on Mac
 
 If you want simultaneous audio and video from Murmur, and you have quicktime installed (which you probably do), simply 

