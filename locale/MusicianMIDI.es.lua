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

local msg = MusicianMIDI.InitLocale("es", "Español", "esES", "esMX")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "Abre el teclado MIDI"
msg.COMMAND_LIVE_KEYBOARD = "Abre el teclado MIDI"
msg.MIDI_KEYBOARD_TITLE = "Teclado MIDI"
msg.SELECT_INSTRUMENT = "Seleccionar instrumento"
msg.INSTRUMENT_OCTAVE = "Octava"

msg.SPLIT_KEYBOARD = "Separar"
msg.SET_SPLIT_KEY_HINT = "Presione la primera tecla de la sección superior de su teclado de piano MIDI."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "Su versión de Musician es demasiado antigua para Musician MIDI. Actualícelo."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "Su versión de Musician MIDI es demasiado antigua. Actualízalo."
