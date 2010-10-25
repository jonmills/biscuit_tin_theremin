import processing.serial.*;
import ddf.minim.*;
import ddf.minim.signals.*;

static boolean use_mouse = true;
 
//Globals
Minim minim;
AudioOutput out;
SineWave sine;
float minFreq = 20;
float maxFreq = 3000;
float f = 0;
float a = 0;
int prev_good_f = 0;
Serial myPort;

void setup () 
{
    size(512, 512);
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

    // List all the available serial ports
    //  println(Serial.list());
	
	if ( ! use_mouse)
	{
    	myPort = new Serial(this, Serial.list()[0], 9600);	
	}
}

void draw()
{
	if (use_mouse)
	{
		f = mouseX/512.0;
		a = mouseY/512.0;
	}
	
    float freqScalar = f;
    float freq = minFreq + ((maxFreq - minFreq) * freqScalar);
    sine.setFreq(freq);
  
    sine.setAmp(a);
}

void serialEvent (Serial myPort) 
{
    // get the ASCII string:
    String inString = myPort.readStringUntil('\n');

    if (inString != null) 
    {
        // Split the string by commas
        int[] nums = int(split(inString, ','));
        // Scale the values into a 0.0 to 1.0 range
        if (nums[0]>4000)
        {
            nums[0]=prev_good_f;            
        }
        else
        {
            prev_good_f = nums[0]; 
        }
        
        f = (nums[0] / 4000.0);
        a = (nums[1] / 255.0);    
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
