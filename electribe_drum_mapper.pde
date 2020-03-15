// Electribe ES to Ableton Drum Rack Mapper

#include "WProgram.h"
#include "Midi.h"

// This defines what the lowest CC number will be
const byte ccOffset = 8;

// Remaps c,d,e,f to c,c#,d,d# etc
const byte noteMap[18] = {36,0,37,0,38,39,0,40,0,41,0,42,43,0,44,0,45,46};

// Mutes are sent using note on/off data
// Maps parts to note numbers (part number is implicit as index)
const byte partLow[4] = {60,61,62,63};

// Maps parts to note numbers
const byte partHigh[5] = {64,65,66,67,68};

// Keep track of whether parts are active or muted (active = 1)
byte partActive[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1};
byte partActiveBuffer[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1};

boolean nprnStarted = false;  // Track whether we've received the first part of a NPRN change message
int nprnData = 0;  // Stores the second part of an NPRN change message

// Intercept the midi messages here
class MyMidi : public Midi
{
  public:
  
  // Need this to compile; it just hands things off to the Midi class.
  MyMidi(HardwareSerial &s) : Midi(s) {}
  
  void handleNoteOn(unsigned int channel, unsigned int note, unsigned int velocity)
  {
    sendNoteOn(channel, remapNote(note), velocity);
  }

  void handleNoteOff(unsigned int channel, unsigned int note, unsigned int velocity)
  {
    sendNoteOff(channel, remapNote(note), velocity);
  }
  
  void handleVelocityChange(unsigned int channel, unsigned int note, unsigned int velocity)
  {
    sendVelocityChange(channel, note, velocity);
  }
  
  void handleControlChange(unsigned int channel, unsigned int controller, unsigned int value)
  {
    if (controller == 99 && value == 5)
    {
      nprnStarted = true;
    }
    else if (controller == 98)
    {
      nprnData = value;
    }

    // mutes 
    else if (controller == 6 && nprnStarted == true && nprnData == 107)
    {
      partActiveBuffer[0] = value & 1;
      partActiveBuffer[1] = value & 2;
      partActiveBuffer[2] = value & 4;
      partActiveBuffer[3] = value & 8;
      for (int index = 0; index < 4; index++)
      {
        if (partActiveBuffer[index] != partActive[index])
        {
          sendNoteOn(channel, partLow[index], 127);
          sendNoteOff(channel, partLow[index], 127);
        }
        partActive[index] = partActiveBuffer[index];
      }
    }     
    else if (controller == 6 && nprnStarted == true && nprnData == 108)
    {
      partActiveBuffer[4] = value & 1;
      partActiveBuffer[5] = value & 2;
      partActiveBuffer[6] = value & 4;
      partActiveBuffer[7] = value & 8;
      partActiveBuffer[8] = value & 16;
      for (int index = 0; index < 5; index++)
      {
        if (partActiveBuffer[index+4] != partActive[index+4])
        {
          sendNoteOn(channel, partHigh[index], 127);
          sendNoteOff(channel, partHigh[index], 127);
        }
        partActive[index+4] = partActiveBuffer[index+4];
      }      
    }
   
    // A knob tweak or button press
    else if (controller == 6 && nprnStarted == true)
    {
      nprnStarted = false;
      unsigned int controlChannel = nprnData - (nprnData/8) + ccOffset;
      if (((nprnData + 8) % 8) > 3)
      {
        value = value * 127;
      }
      sendControlChange(channel, controlChannel, value);
    } 
  }
  
  byte remapNote(byte noteNumber)
  {
    return noteNumber >= 60 ? noteNumber : noteMap[noteNumber - 36];  
  }
  
  void handleProgramChange(unsigned int channel, unsigned int program)
  {
    // Disabled to stop pattern change (from main data wheel) from switching patches in VSTs
    // sendProgramChange(channel, program);
  }
  
  void handleAfterTouch(unsigned int channel, unsigned int velocity)
  {
    sendAfterTouch(channel, velocity);
  }
  
  void handlePitchChange(unsigned int pitch)
  {
    sendPitchChange(pitch);
  }
  
  void handleSongPosition(unsigned int position)
  {
    sendSongPosition(position);
  }
  
  void handleSongSelect(unsigned int song)
  {
    sendSongSelect(song);
  }
  
  void handleTuneRequest(void)
  {
    sendTuneRequest();
  }
  
  void handleSync(void)
  {
    sendSync();
  }
  
  void handleStart(void)
  {
    sendStart();
  }
  
  void handleContinue(void)
  {
    sendContinue();
  }
  
  void handleStop(void)
  {
    sendStop();
  }
  
  void handleActiveSense(void)
  {
    // Disabled, but probably unused anyway
    // sendActiveSense();
  }
  
  void handleReset(void)
  {
    sendReset();
  }
};

// Create an instance of the MyMidi class.
MyMidi midi(Serial);

void setup()
{
  pinMode(13, OUTPUT);
  midi.begin(0);
}

void loop()
{
  midi.poll();
}
