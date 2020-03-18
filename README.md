# Electribe to Ableton Drum Rack Mapper

Arduino/Teensy code for remapping the nprn crippled output of a Korg Electribe ES into note and CC messages (that Ableton and other DAWs understand)

So you've got one of these: 

![alt text](/electribe.png "Electribe ES")

And you want to hook it up to: 

![alt text](/drumrack.png "Ableton Drum Rack")

For some sweet XOX drum sequencing with cc control over filter sweeps and beat destruction.  You plug it in, and it just doesn't work.

## I can help

The reason it doesn't work is Korg made the Electribe transmit nprn messages rather than cc messages, and a pretty odd selection of midi on/off notes, which renders the box unusable as an external sequencer.  With a little bit of hacking this can be fixed in hardware using an arduino mini, a couple of diodes, 4 resistors and an optocoupler.

TODO: Add wiring diagram, and simple instructions
