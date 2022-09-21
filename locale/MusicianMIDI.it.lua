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

local msg = MusicianMIDI.InitLocale("it", "Italiano", "itIT")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "Apri la tastiera MIDI"
msg.COMMAND_LIVE_KEYBOARD = "Apri la tastiera MIDI"
msg.MIDI_KEYBOARD_TITLE = "Tastiera MIDI"
msg.SELECT_INSTRUMENT = "Seleziona lo strumento"
msg.INSTRUMENT_OCTAVE = "Ottava"

msg.SPLIT_KEYBOARD = "Diviso"
msg.SET_SPLIT_KEY_HINT = "Premere il primo tasto della sezione superiore sulla tastiera del pianoforte MIDI."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "La tua versione di Musician è troppo vecchia per Musician MIDI. Per favore aggiornalo."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "La tua versione di Musician MIDI è troppo vecchia. Si prega di aggiornarlo."