MusicianMIDI.Locale.fr = Musician.Utils.DeepCopy(MusicianMIDI.Locale.en)
local msg = MusicianMIDI.Locale.fr

msg.MENU_LIVE_MIDI = "Ouvrir l'interface MIDI"
msg.COMMAND_LIVE_MIDI = "Ouvre l'interface MIDI"
msg.LIVE_MIDI_TITLE = "Interface MIDI"

msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION = "Votre version de Musician est trop ancienne pour Musician MIDI. Veuillez mettre à jour."

if (GetLocale() == "frFR") then
	MusicianMIDI.Msg = msg
end
