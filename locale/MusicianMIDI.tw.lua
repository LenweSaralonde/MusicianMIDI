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

local msg = MusicianMIDI.InitLocale("tw", "繁體中文", "zhTW")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "啟動MIDI鍵盤"
msg.COMMAND_LIVE_KEYBOARD = "啟動MIDI鍵盤"
msg.MIDI_KEYBOARD_TITLE = "MIDI鍵盤"
msg.SELECT_INSTRUMENT = "選擇樂器"
msg.INSTRUMENT_OCTAVE = "八度移調"

msg.SPLIT_KEYBOARD = "分割"
msg.SET_SPLIT_KEY_HINT = "按MIDI鍵盤左半部分的第一個鍵。"

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "你的Musician版本太舊以致不能使用Musician MIDI，請升級。"
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "您的 Musician MIDI 版本太舊。 請更新它。"
