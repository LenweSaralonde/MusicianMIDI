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

local msg = MusicianMIDI.InitLocale("ru", "Русский", "ruRU")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "Откройте MIDI-клавиатуру"
msg.COMMAND_LIVE_KEYBOARD = "Откройте MIDI-клавиатуру"
msg.MIDI_KEYBOARD_TITLE = "MIDI клавиатура"
msg.SELECT_INSTRUMENT = "Выбрать инструмент"
msg.INSTRUMENT_OCTAVE = "Октава"

msg.SPLIT_KEYBOARD = "Расколоть"
msg.SET_SPLIT_KEY_HINT = "Нажмите первую клавишу в верхней части клавиатуры пианино MIDI."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "Ваша версия Musician слишком устарела для Musician MIDI. Пожалуйста, обновите его."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "Ваша версия Musician MIDI устарела. Пожалуйста, обновите его."