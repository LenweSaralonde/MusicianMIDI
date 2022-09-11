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

local msg = MusicianMIDI.InitLocale("fr", "Français", "frFR")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "Ouvrir le clavier MIDI"
msg.COMMAND_LIVE_KEYBOARD = "Ouvrir le clavier MIDI"
msg.MIDI_KEYBOARD_TITLE = "Clavier MIDI"
msg.SELECT_INSTRUMENT = "Changer d'instrument"
msg.INSTRUMENT_OCTAVE = "Octave"

msg.SPLIT_KEYBOARD = "Diviser"
msg.SET_SPLIT_KEY_HINT = "Appuyez sur la touche correspondant à la première note de la section supérieure sur votre clavier MIDI."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "Votre version de Musician est trop ancienne pour Musician MIDI. Veuillez mettre à jour."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "Votre version de Musician MIDI est trop ancienne. Veuillez mettre à jour."
