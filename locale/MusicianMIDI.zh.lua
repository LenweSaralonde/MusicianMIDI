MusicianMIDI.Locale.zh = Musician.Utils.DeepCopy(MusicianMIDI.Locale.en)
local msg = MusicianMIDI.Locale.zh

msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION = "你的Musician版本太旧以致不能使用Musician MIDI，请升级。"

if (GetLocale() == "zhCN" or GetLocale() == "zhTW") then
	MusicianMIDI.Msg = msg
end
