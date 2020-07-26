# MusicianMIDI
Play live with Musician using any MIDI input.

> ## Important notice
> **This is an experimental version** of *MusicianMIDI* that allows more capability than the regular version but also requires more processing power to run properly.
>
> Ensure to reload the updated **Musician preset.bmtp** into *Bome MIDI Translator* if you used the regular version before.
>
> The regular version of MusicianMIDI translates MIDI note on / note off into single PC keyboard key down / key up actions. It's limited to 5 octaves due to the limited amount of available "safe" PC keyboard keys.
>
> Instead, this experimental version translates the whole raw MIDI message to WoW using a sequence of 6 PC keyboard keystrokes, thus requiring 6 times more processing power than the regular version.
>
> In exchange, it's now possible to control Musician using any MIDI source (keyboard, sequencer etc) and take advantage of the whole range of notes, program changes, control changes and the standard 16 MIDI channels.
>
> Unlike in the regular version where almost all the "safe" PC keyboard keys are used, the MIDI messages are transmitted using only 16 keys in the numpad and the Insert key. If you have a num pad on your keyboard, ensure that **Num lock** is always **on**.
>
> Pleae report feedback in the [Discord #development channel](https://discord.gg/276FjbJ).
>
> Have fun!

## Installation
This add-on requires the external **Bome MIDI Translator** software to convert incoming MIDI messages from your controller into keystrokes that can be captured by the add-on.

Install [Bome MIDI Translator Classic](https://www.bome.com/products/mtclassic) (Window) or [Bome MIDI Translator Pro](https://www.bome.com/products/miditranslator) (Windows & macOS) then open the provided `Musician preset.bmtp` file.

The __Classic__ version is recommended if you run Windows because it's easy to use and works without paid license while the __Pro__ version is more complex and should be restarted every 20 minutes in trial mode. You can get a free license for any version if you [send a postcard to the developers](https://www.bome.com/postcardware).

## Configure MIDI input device

### For Bome MIDI Translator __Classic__:
1. Open the **Midi In** menu
2. Select your MIDI input device

### For Bome MIDI Translator __Pro__:
1. Open the provided `Musician preset.bmtp` file
2. Click on __Musician preset.bmtp__ in the left column
3. Open the **MIDI** menu then click **Project Default MIDI Ports**
4. Select your MIDI input device in the right column

## How to play
In WoW, click on the Musician minimap icon then **Open live MIDI** or type `/mus midi`. You can play live using your MIDI keyboard as long as the MIDI keyboard window is focused in game.

## Deal with latency
As with the regular live keyboard interface, you may experience some latency between the moment you press a key and when the sound actually starts playing, which can be awkward for a live performance. Unlike music applications, the WoW client does not support low latency ASIO drivers.

As a workaround, you can connect your MIDI keyboard to a software synthesizer (in addition to Bome MIDI Translator) and use it for audio feedback while playing with Musician.

Every instrument in Musician has a soundfont version in SFZ format, located under Musician's `soundfonts` folder.

[Sforzando](https://www.plogue.com/products/sforzando.html) is a free SFZ soundfont player you can use as a standalone software synth to play Musician's instruments. Just assign the same **Input MIDI device** in Sforzando as in Bome MIDI Translator (under **Tools** > **Settings**) and you're ready to go.

To play an instrument, select it in game then drag and drop its .sfz file into Sforzando. Don't forget to mute Musician's audio in game by right clicking on the minimap icon to avoid hearing the sound twice.