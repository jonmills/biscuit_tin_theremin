#include "Wire.h"

unsigned long next_tx_time = 0;

//#define RAW_OUTPUT
#define LPF
#define CLAMP

#define SENSOR_1_ID			(0x71)
#define SENSOR_2_ID			(0x71)

#define MODE				(0x51)
#define MIN_VALUE			(15)
#define MAX_VALUE			(90)
#define MAX_RATE_OF_CHANGE	(1000)
#define PAUSE_MS			(50)

#define LPF_COEFFICIENT		(0.1)

static void start_sample(uint8_t device_id)
{
	Wire.beginTransmission(device_id);
	Wire.send(0);
	Wire.send(MODE);
	Wire.endTransmission();	
}

static boolean sample_ready(uint8_t device_id)
{
	uint8_t software_rev;

	Wire.beginTransmission(device_id);
	Wire.send(0);
	Wire.endTransmission();
	Wire.requestFrom((uint8_t)device_id, (uint8_t)1);
	software_rev = Wire.receive();	
	return (software_rev != 0xff);  
}

static unsigned long get_result(uint8_t device_id)
{
	unsigned long temp_val = 0;

	Wire.beginTransmission(device_id);
	Wire.send(2);
	Wire.endTransmission();
	Wire.requestFrom(device_id, (uint8_t) 2);
	temp_val = ((unsigned long) Wire.receive()) << 8;
	temp_val += (unsigned long) Wire.receive();
	
	return (temp_val);
}

void setup()
{
	Serial.begin(9600);
	Wire.begin();
}

void loop()
{
	static enum
	{
		IDLE,
		SAMPLE_CHANNEL1,
		PAUSE_CHANNEL1
	} sample_state = IDLE;
		
	static float new_input = 0;
	static float previous_input = 0;
	static float new_output = 0;
	static float previous_output = 0;		
	static unsigned long timer = 0;	
	
  	while (true)  
  	{
  		switch (sample_state)
  		{
  			case IDLE:
  				start_sample(SENSOR_1_ID);
  				sample_state = SAMPLE_CHANNEL1; 
  				break;
  				
  			case SAMPLE_CHANNEL1:
			  	if (sample_ready(SENSOR_1_ID))
			  	{
			  		previous_input = new_input;
			  		previous_output = new_output;
			  		new_input = (float)get_result(SENSOR_1_ID);
#ifdef CLAMP
					if (new_input > MAX_VALUE) new_input = MAX_VALUE;
					if (new_input < MIN_VALUE) new_input = MIN_VALUE;
#endif			  		
			  					  	
#ifndef RAW_OUTPUT
					//Implement a low-pass filter
					// y[i] := y[i-1] + α * (x[i] - y[i-1])					
					new_output = previous_output + 0.1 * (new_input - previous_output); 
					//new_input * 0.9 + previous_input * 0.1;			  		
#else
					new_output = new_input;
#endif
					timer = millis();
					sample_state = PAUSE_CHANNEL1;			  		  
			  	}  			
  				break;
  				
  			case PAUSE_CHANNEL1:
  				//Wait a little while to allow the sensor to settle
  				if ((millis() - timer) > 50)
  				{
			  		start_sample(SENSOR_1_ID);	
			  		sample_state = SAMPLE_CHANNEL1;  			  				
  				}
  				break;  				
  		}
  			  	
	  	if (next_tx_time <= millis())
	  	{
			Serial.print((unsigned long)new_output);
			Serial.print("\n");
			next_tx_time = millis() + 100;	  	
	  	}	  		  		  	
  	}
}
