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

local msg = MusicianMIDI.InitLocale("pt", "Português", "ptBR")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "Abra o teclado MIDI"
msg.COMMAND_LIVE_KEYBOARD = "Abra o teclado MIDI"
msg.MIDI_KEYBOARD_TITLE = "Teclado MIDI"
msg.SELECT_INSTRUMENT = "Selecione o instrumento"
msg.INSTRUMENT_OCTAVE = "Oitava"

msg.SPLIT_KEYBOARD = "Dividir"
msg.SET_SPLIT_KEY_HINT = "Pressione a primeira tecla da seção superior do teclado de piano MIDI."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "Sua versão do Musician é muito antiga para o Musician MIDI. Por favor, atualize-o."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "Sua versão de Musician MIDI é muito antiga. Por favor, atualize-o."
