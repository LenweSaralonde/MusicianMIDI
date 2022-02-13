MusicianMIDI.KEY_NIBBLES = {
	['NUMPAD0'] = '0',
	['NUMPAD1'] = '1',
	['NUMPAD2'] = '2',
	['NUMPAD3'] = '3',
	['NUMPAD4'] = '4',
	['NUMPAD5'] = '5',
	['NUMPAD6'] = '6',
	['NUMPAD7'] = '7',
	['NUMPAD8'] = '8',
	['NUMPAD9'] = '9',
	['A'] = 'A',
	['B'] = 'B',
	['C'] = 'C',
	['D'] = 'D',
	['E'] = 'E',
	['F'] = 'F',
}

-- Supported MIDI messages size in nibbles
MusicianMIDI.SUPPORTED_MESSAGE_SIZE = {
	[0x8] = 6, -- Note Off
	[0x9] = 6, -- Note On
	[0xB] = 6, -- Control change
	[0xC] = 4, -- Program change
	[0xE] = 6, -- Pitch bender
}

MusicianMIDI.Locale = {}