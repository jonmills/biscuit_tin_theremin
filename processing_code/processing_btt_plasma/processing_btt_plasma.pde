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
int pixelSize=2;
PGraphics pg;
float min_value = 1000;
float max_value = 10000;

void setup () 
{
    size(512, 512);
	// Create buffered image for plasma effect
  	pg = createGraphics(160, 90, P2D);
  	colorMode(HSB);
  	noSmooth();
    
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
		freq_scalar = mouseX/512.0;
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
  	
 	float  xc = 25;

  // Enable this to control the speed of animation regardless of CPU power
  // int timeDisplacement = millis()/30;

  // This runs plasma as fast as your computer can handle
  int timeDisplacement = frameCount;
  
  if (use_mouse)
  {
    timeDisplacement = mouseX;    
  }  
  else
  {
    timeDisplacement = int(freq_scalar * 512.0);
  }

  // No need to do this math for every pixel
  float calculation1 = sin( radians(timeDisplacement * 0.61655617));
  float calculation2 = sin( radians(timeDisplacement * -3.6352262));
  
  // Output into a buffered image for reuse
  pg.beginDraw();
  pg.loadPixels();

  // Plasma algorithm
  for (int x = 0; x < pg.width; x++, xc += pixelSize)
  {
    float  yc    = 25;
    float s1 = 128 + 128 * sin(radians(xc) * calculation1 );

    for (int y = 0; y < pg.height; y++, yc += pixelSize)
    {
      float s2 = 128 + 128 * sin(radians(yc) * calculation2 );
      float s3 = 128 + 128 * sin(radians((xc + yc + timeDisplacement * 5) / 2));  
      float s  = (s1+ s2 + s3) / 3;
      pg.pixels[x+y*pg.width] = color(s, 255 - s / 2.0, 255);
    }
  }   
  pg.updatePixels();
  pg.endDraw();

  // display the results
  image(pg,0,0,width,height); 
    	
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
        freq_scalar = ((new_freq  - min_value)/ (max_value - min_value));    
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
