# MusicianMIDI

Experimental version that receives MIDI messages from vJoy and controlled by a Node.js script.

Does not because joystick button inputs are handled only once per frame, most of the messages get dropped.

"MIDI is transmitted as asynchronous bytes at 31250 bits per second. One start bit, eight data bits, and one stop bit result in a maximum transmission rate of 3125 bytes per second."

MIDI messages are 2 or 3 bytes so at 60 FPS the maximum rate is only 180 bytes per second.
