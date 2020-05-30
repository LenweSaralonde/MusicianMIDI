MusicianMIDI.Locale.zh = Musician.Utils.DeepCopy(MusicianMIDI.Locale.en)
local msg = MusicianMIDI.Locale.zh

msg.MENU_MIDI_KEYBOARD = "启动MIDI键盘"
msg.COMMAND_LIVE_KEYBOARD = "启动MIDI键盘"
msg.MIDI_KEYBOARD_TITLE = "MIDI键盘"
msg.SELECT_INSTRUMENT = "选择乐器"
msg.INSTRUMENT_OCTAVE = "八度移调"

msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION = "你的Musician版本太旧以致不能使用Musician MIDI，请升级。"

if (GetLocale() == "zhCN" or GetLocale() == "zhTW") then
	MusicianMIDI.Msg = msg
end
