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

local msg = MusicianMIDI.InitLocale("zh", "中文", "zhCN", "zhTW")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "启动MIDI键盘"
msg.COMMAND_LIVE_KEYBOARD = "启动MIDI键盘"
msg.MIDI_KEYBOARD_TITLE = "MIDI键盘"
msg.SELECT_INSTRUMENT = "选择乐器"
msg.INSTRUMENT_OCTAVE = "八度移调"

msg.SPLIT_KEYBOARD = "分割"
msg.SET_SPLIT_KEY_HINT = "按MIDI键盘左半部分的第一个键。"

msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION = "你的Musician版本太旧以致不能使用Musician MIDI，请升级。"
