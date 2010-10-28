import processing.serial.*;
import ddf.minim.*;
import ddf.minim.signals.*;

static boolean use_mouse = false;
static boolean mute_output = false;
 
//Globals
Minim minim;
AudioOutput out;
SineWave sine;
float minFreq = 20;
float maxFreq = 3000;
float freq_scalar;
Serial myPort;
ParticleSystem ps;

int xdimension = 1024;

void setup () 
{
    size(1024, 512);
  	colorMode(RGB, 255, 255, 255, 100);
  	ps = new ParticleSystem(1, new PVector(width/2,height/2,0));
  	smooth();    
    
    // instantiate a Minim object
    minim = new Minim(this);
    // get a line out from Minim, 
    // default sample rate is 44100, bit depth is 16
    out = minim.getLineOut(Minim.STEREO, 512);
    // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, 
    // sample rate 44100 to match the line out
    sine = new SineWave(3000, 0, 44100);
    // add the oscillator to the line out
    out.addSignal(sine);

    if ( ! use_mouse)
    {	
    	myPort = new Serial(this, Serial.list()[0], 9600);
    }    		
}

void draw()
{
	if (use_mouse)
	{	
		freq_scalar = mouseX/1024.0;
	}	
	
    float freq = minFreq + ((maxFreq - minFreq) * freq_scalar);
    sine.setFreq(freq);
  
	//Mute the output if there's nothing in range  
  	if ((freq_scalar > 0.9) && mute_output)
  	{  	
  		sine.setAmp(0);
  	}
  	else
  	{
  	    sine.setAmp(0.5);
  	}
  	
  	background(0);
  	ps.run();
  	ps.addParticle(freq_scalar*1024.0,80);  	  	  	
}

void serialEvent (Serial myPort) 
{
	float new_freq;
	
    // get the ASCII string:
    String inString = myPort.readStringUntil('\n');
    
    if (inString != null) 
    {
        // Split the string by commas
        new_freq = float(inString);
        // Scale the values into a 0.0 to 1.0 range        
        freq_scalar = ((new_freq  - 15.0)/ (90.0 - 15.0));    
    }
}

void stop()
{
    // always closes audio I/O classes
    out.close();
    // always stop your Minim object
    minim.stop();
    super.stop();
}

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 
class ParticleSystem {

  ArrayList particles;    // An arraylist for all the particles
  PVector origin;        // An origin point for where particles are born

  ParticleSystem(int num, PVector v) {
    particles = new ArrayList();              // Initialize the arraylist
    origin = v.get();                        // Store the origin point
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin));    // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = (Particle) particles.get(i);
      p.run();
      if (p.dead()) {
        particles.remove(i);
      }
    }
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }
  
    void addParticle(float x, float y) {
    particles.add(new Particle(new PVector(x,y)));
  }

  void addParticle(Particle p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }
}

// A simple Particle class

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float timer;
  
  // Another constructor (the one we are using here)
  Particle(PVector l) {
    acc = new PVector(0,0.05,0);
    vel = new PVector(random(-1,1),random(-2,0),0);
    loc = l.get();
    r = 10.0;
    timer = 100.0;
  }

  void run() {
    update();
    render();
  }

  // Method to update location
  void update() {
    vel.add(acc);
    loc.add(vel);
    timer -= 1.0;
  }

  // Method to display
  void render() {
    ellipseMode(CENTER);
    stroke(255,timer);
    fill(100,timer);
    ellipse(loc.x,loc.y,r,r);
    displayVector(vel,loc.x,loc.y,10);
  }
  
  // Is the particle still useful?
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
  
   void displayVector(PVector v, float x, float y, float scayl) {
    pushMatrix();
    float arrowsize = 4;
    // Translate to location to render vector
    translate(x,y);
    stroke(255);
    // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
    rotate(v.heading2D());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = v.mag()*scayl;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    line(0,0,len,0);
    line(len,0,len-arrowsize,+arrowsize/2);
    line(len,0,len-arrowsize,-arrowsize/2);
    popMatrix();
  } 
}
