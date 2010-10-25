#include "Wire.h"
#include "SRF02.h"

SRF02 srf02[2] = 
{ 
  SRF02(0x70, SRF02_MICROSECONDS),
  SRF02(0x71, SRF02_MICROSECONDS)
};

static unsigned long sample_rate_ms = 100;
static unsigned long next_sample_time = 0;

void setup()
{
  Serial.begin(9600);
  Wire.begin();
//  SRF02::setInterval(sample_rate_ms);
}

void loop()
{
  while (true)  
  {
//    SRF02::configureDeviceId(0x70,0x71);    
    SRF02::update();
            
    //Wait for the next sample time and then
    //transmit the values over the USB serial port
    if (millis() > next_sample_time)
    {
      Serial.print(srf02[0].read());
      Serial.print(",");
      Serial.print(srf02[1].read());
      Serial.println();
      next_sample_time = millis () + sample_rate_ms;
    }
  }
}
