# MusicianMIDI
Play live with Musician using a MIDI keyboard.

## Installation
This add-on requires the external **Bome MIDI Translator** software to convert incoming MIDI messages from your controller into keystrokes that can be captured by the add-on.

Install [Bome MIDI Translator Classic](https://www.bome.com/products/mtclassic) (Windows) or [Bome MIDI Translator Pro](https://www.bome.com/products/miditranslator) (Windows & macOS) then open the provided `Musician preset.bmtp` file.

The __Classic__ version is recommended if you run Windows because it's easier to use than the Pro version and it works without paid license. The __Pro__ version is more complex and should be restarted every 20 minutes in trial mode. You can get a free license for any version if you [send a postcard to the developers](https://www.bome.com/postcardware).

## Configuration for MacOS
Some extra configuration steps are required for the setup to properly work on MacOS.

### 1. Function keys configuration
MusicianMIDI needs to the function keys to be enabled. Also make sure you don't have any shortcut using them.

1. Go to **System Preferences** > **Keyboard**.
2. Check **Use F1, F2, etc. keys as standard function keys**.
![Function keys](https://raw.githubusercontent.com/LenweSaralonde/MusicianMIDI/master/img/macos-keyboard-function-keys-configuration.png)
3. Go to the **Shortcuts** tab.
4. Click **Mission Control** and uncheck the **Show Desktop** shortcut if the **F11** key is set (default).
![Shortcuts](https://raw.githubusercontent.com/LenweSaralonde/MusicianMIDI/master/img/macos-keyboard-shortcuts-configuration.png)

### 2. Permissions
Bome MIDI Translator needs accessibility permissions to send keystrokes.

1. Go to **System Preferences** > **Security & Privacy**.
2. Click on **Accessibility**.
3. Click on the padlock 🔒 to allow modifications.
4. Check **MIDI Translator Pro** in the list.

## Configure the MIDI input device


### For Bome MIDI Translator __Classic__:
1. Connect your MIDI controller.
2. Open the **Midi In** menu.
3. Select your MIDI input device.

![MIDI Translator Classic configuration](https://raw.githubusercontent.com/LenweSaralonde/MusicianMIDI/master/img/bome-midi-translator-classic-configuration.png)

### For Bome MIDI Translator __Pro__:
1. Connect your MIDI controller.
2. Open the `Musician preset.bmtp` file that is provided in the `Interface/AddOns/MusicianMIDI` folder.
3. Open the **MIDI** menu option then click **Project Default MIDI Ports**.
4. Select your **MIDI INPUT** device in the right column under **MIDI IN Port**.

![MIDI Translator Pro configuration](https://raw.githubusercontent.com/LenweSaralonde/MusicianMIDI/master/img/bome-midi-translator-pro-configuration.png)

## How to play
![MIDI keyboard UI](https://raw.githubusercontent.com/LenweSaralonde/MusicianMIDI/master/img/musician-midi-keyboard-ui.png)

In WoW, click on the Musician minimap icon then **Open MIDI keyboard** or type `/mus midi`. You can play live using your MIDI keyboard as long as the MIDI keyboard window is focused in game.

The keyboard can be splitted in 2 layers to set a different instrument and/or octave on each side. Click the **Split** button to activate split mode. To change the split point, click on the split point text field then press the piano key you want as a new split point.

The keyboard can also be activated by clicking the on-screen keyboard keys.

Since MusicianMIDI relies on computer keyboard keystroke emulation, almost all the keyboard keys will trigger a note, including Esc and Enter. The MIDI keyboard window should remain open and the WoW application focused to work. Press the **X** button when you're finished to close the MIDI keyboard.

The piano keyboard range goes from E1 (28) to G7 (103) which corresponds to a standard 76-key piano. Playing out of range keys has no effect.

## Deal with latency
As with the regular live keyboard interface, you may experience some latency between the moment you press a key and when the sound actually starts playing, which can be awkward for a live performance. Unlike music applications, the WoW client does not support low latency ASIO drivers.

If your keyboard can make its own sound (for example a digital piano) in addition to sending MIDI messages, do a right click on the Musician minimap icon to mute it entirely and use your instrument's audio for playing.

If your keyboard is a controller only, you can connect it to a software synthesizer (in addition to Bome MIDI Translator) and use it for audio feedback while playing with Musician.

Each Musician instrument has a soundfont version in SFZ format, located under Musician's `soundfonts` folder.

[Sforzando](https://www.plogue.com/products/sforzando.html) is a free SFZ soundfont player you can use as a standalone software synth to play Musician's instruments. Just assign the same **Input MIDI device** in Sforzando as in Bome MIDI Translator (under **Tools** > **Settings**) and you're ready to go.

To play an instrument, select it in game then drag and drop its `.sfz` file into Sforzando. Don't forget to mute Musician's audio in game by right clicking on the minimap icon to avoid hearing the sound twice.
