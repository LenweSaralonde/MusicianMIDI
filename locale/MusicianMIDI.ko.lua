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

local msg = MusicianMIDI.InitLocale("ko", "한국어", "koKR")

------------------------------------------------------------------------
---------------- ↑↑↑ DO NOT EDIT THE LINES ABOVE ! ↑↑↑  ----------------
------------------------------------------------------------------------

msg.MENU_MIDI_KEYBOARD = "MIDI 키보드 열기"
msg.COMMAND_LIVE_KEYBOARD = "MIDI 키보드 열기"
msg.MIDI_KEYBOARD_TITLE = "MIDI 키보드"
msg.SELECT_INSTRUMENT = "악기 선택"
msg.INSTRUMENT_OCTAVE = "옥타브"

msg.SPLIT_KEYBOARD = "스플릿"
msg.SET_SPLIT_KEY_HINT = "MIDI 피아노 키보드에서 상단 섹션의 첫 번째 건반을 누릅니다."

msg.ERROR_MUSICIAN_VERSION_TOO_OLD = "Musician 버전이 Musician MIDI에 비해 너무 오래되었습니다. 업데이트하십시오."
msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD = "Musician MIDI 버전이 너무 오래되었습니다. 업데이트하십시오."