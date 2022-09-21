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

local msg = MusicianMIDI.InitLocale('en', "English", 'enUS', 'enGB')

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "Open the MIDI keyboard"
msg.COMMAND_LIVE_KEYBOARD = "Open the MIDI keyboard"
msg.MIDI_KEYBOARD_TITLE = "MIDI keyboard"
msg.SELECT_INSTRUMENT = "Select instrument"
msg.INSTRUMENT_OCTAVE = "Octave"

msg.SPLIT_KEYBOARD = "Split"
msg.SET_SPLIT_KEY_HINT = "Press the first key of the upper section on your MIDI piano keyboard."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "Your version of Musician is too old for Musician MIDI. Please update it."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "Your version of Musician MIDI is too old. Please update it."