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

msg.MENU_MIDI_KEYBOARD = "Öffne das MIDI-Keyboard"
msg.COMMAND_LIVE_KEYBOARD = "Öffne das Live MIDI-Keyboard"
msg.MIDI_KEYBOARD_TITLE = "MIDI-Keyboard"
msg.SELECT_INSTRUMENT = "Wähle ein Instrument"
msg.INSTRUMENT_OCTAVE = "Oktave"

msg.SPLIT_KEYBOARD = "Teilen"
msg.SET_SPLIT_KEY_HINT = "Drücke die erste Taste im oberen Bereich des MIDI-Piano-Keyboards."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "Deine Version von Musician ist zu alt für Musician MIDI. Bitte aktualisieren."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "Ihre Version von Musician MIDI ist zu alt. Bitte aktualisieren Sie es."
