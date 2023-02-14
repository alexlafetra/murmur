
# murmur
 Murmur is a digital instrument built around collective flocking behavior and granular synthesis. With it, you can utilize a murmuration of simulated birds to synthesize and record sound. The engine currently supports .mp3 and .wav samples. 
 
 ![An image of murmur in-action](/resources/images/img1_header.png)
 
 Murmur is being written in Java and is built using [Processing](https://processing.org/) (which I literally cannot recommend enough). It uses the [Beads](http://www.beadsproject.net/) library to work with audio files and to mess with granular audio synthesis.
 
 # Instructions
 ## Running the Application
 To run murmur from within the [Processing IDE](https://processing.org/download), download the "murmur" folder and open any of the .pde files inside of it.  Once you've opened the sketch in the IDE, you might need to download the Beads library using Processing's library loader before you can run it as a normal processing sketch.
 
 To run murmur without downloading the IDE, dm me! Unfortunately, bundled with Java, the app is too large to host on Github. It's free (of course), so if you're interested and don't have any experience using Processing/just want a standalone app drop me a line and I'll send you a link to a packaged application. If enough people want a copy, I'll definitely look into hosting it on dropbox.
 
 You can email me at alexlafetrathompson@gmail.com or message me on instagram @alexlafetra. 
 
 ## Controls
 ![An image of murmur's controls](/resources/images/img4.png)
 Murmur is controlled by the (admittedly confusing) buttons in the top right corner of the window. Buttons along the right edge of the screen connect the murmuration to murmur's granular sample engine. 
 Clicking each button toggle's the corresponding connection between the sampler and the murmuration:
 - pitch
 - pan
 - grain rate
 - grain size
 - gain
 - noise
 - sample direction
The last orange button, and the round red button, allow you to load and save recorded samples respectively. Murmur currently can load in .mp3 and .wav files, and records to .wav files by default.

Buttons along the top of the screen control 
 
 
 ## Tips
 Basically, experiment! Before you do, turn the volume down in the app and *to be safe* on any speakers your computer's attached to.
 
 Two tips that I think are helpful:
 
 ### Audio
 
 You'll get the most dramatic/unique results 
 
 ### Pitch
 
 # Murmuration Engine
 
The murmuration behavior is totally stolen from Craig Reynold's 1986 [Boids](http://www.red3d.com/cwr/boids/) algorithm, a 2D version of which is also behind the front page of my website.
