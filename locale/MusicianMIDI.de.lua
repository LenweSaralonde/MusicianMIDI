------------------------------------------------------------------------
-- Please read the localization guide in the Wiki:
-- https://github.com/LenweSaralonde/Musician/wiki/Localization
--
-- * Commented out msg lines need to be translated.
-- * Do not translate anything on the left hand side of the = sign.
-- * Do not translate placeholders in curly braces ({variable}).
-- * Keep the text as a single line. Use \n for carriage return.
-- * Escape double quotes (") with a backslash (\").
-- * Check the result in game to make sure your text fits the UI.
------------------------------------------------------------------------

local msg = MusicianMIDI.InitLocale("de", "Deutsch", "deDE")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "Öffnen Sie das MIDI-Keyboard"
msg.COMMAND_LIVE_KEYBOARD = "Öffnen Sie das MIDI-Keyboard"
msg.MIDI_KEYBOARD_TITLE = "MIDI-Keyboard"
msg.SELECT_INSTRUMENT = "Wählen Sie ein Instrument"
msg.INSTRUMENT_OCTAVE = "Oktave"

msg.SPLIT_KEYBOARD = "Teilt"
msg.SET_SPLIT_KEY_HINT = "Drücken Sie die erste Taste im oberen Bereich Ihres MIDI-Piano-Keyboards."

msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION = "Ihre Version von Musician ist zu alt für Musician MIDI. Bitte aktualisieren Sie es."
