# MusicianMIDI
Play live with Musician using a MIDI keyboard.

## Installation
This add-on requires the external **Bome MIDI Translator** software to convert incoming MIDI messages from your controller into keystrokes that can be captured by the add-on.

Install [Bome MIDI Translator Classic](https://www.bome.com/products/mtclassic) (Windows) or [Bome MIDI Translator Pro](https://www.bome.com/products/miditranslator) (Windows & macOS) then open the provided `Musician preset.bmtp` file.

The __Classic__ version is easy to use and works without paid license while the __Pro__ version is more complex and should be restarted every 20 minutes in trial mode. You can get a free license for any version if you [send a postcard to the developers](https://www.bome.com/postcardware).

## Configure MIDI input device
> ### Important notice
> Make sure your MIDI keyboard is set on the ___MIDI channel 1___ otherwise it won't work.

### For Bome MIDI Translator __Classic__:
1. Open the **Midi In** menu
2. Select your MIDI input device

### For Bome MIDI Translator __Pro__:
1. Open the provided `Musician preset.bmtp` file
2. Click on __Musician preset.bmtp__ on the left column
3. Open the **MIDI** menu then click **Project Default MIDI Ports**
4. Select your MIDI input device on the right column

## How to play
In WoW, click on the Musician minimap icon then **Open MIDI keyboard** or type `/mus midi`. You can play live using your MIDI keyboard as long as the MIDI keyboard window is focused in game.

## Deal with latency
As with the regular live keyboard interface, you may experience some latency between the moment you press a key and when the sound actually starts playing, which can be awkward for a live performance. Unlike music applications, the WoW client does not support low latency ASIO drivers.

As a workaround, you can connect your MIDI keyboard to a software synthesizer (in addition to Bome MIDI Translator) and use it for audio feedback while playing with Musician.

Every instrument in Musician has a soundfont version in SFZ format, located under Musician's `soundfonts` folder.

[Sforzando](https://www.plogue.com/products/sforzando.html) is a free SFZ soundfont player you can use as a standalone software synth to play Musician's instruments. Just assign the same **Input MIDI device** in Sforzando as in Bome MIDI Translator (under **Tools** > **Settings**) and you're ready to go.

To play an instrument, select it in game then drag and drop its .sfz file into Sforzando. Don't forget to mute Musician's audio in game by right clicking on the minimap icon to avoid hearing the sound twice.