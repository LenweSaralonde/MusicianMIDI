MusicianMIDI.Locale.fr = Musician.Utils.DeepCopy(MusicianMIDI.Locale.en)
local msg = MusicianMIDI.Locale.fr

msg.MENU_MIDI_KEYBOARD = "Ouvrir le clavier MIDI"
msg.COMMAND_LIVE_KEYBOARD = "Ouvrir le clavier MIDI"
msg.MIDI_KEYBOARD_TITLE = "Clavier MIDI"
msg.SELECT_INSTRUMENT = "Changer d'instrument"
msg.INSTRUMENT_OCTAVE = "Octave"

msg.SPLIT_KEYBOARD = "Diviser"
msg.SET_SPLIT_KEY_HINT = "Appuyez sur la touche correspondant à la première note de la section supérieure sur votre clavier MIDI."

msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION = "Votre version de Musician est trop ancienne pour Musician MIDI. Veuillez mettre à jour."

if (GetLocale() == "frFR") then
	MusicianMIDI.Msg = msg
end
