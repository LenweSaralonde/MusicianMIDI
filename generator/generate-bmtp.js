'use strict'

const NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

const MAPPING = [
	'1008', // BACKSPACE
	'1009', // TAB
	'106E', // NUMPADDECIMAL
	'106B', // NUMPADPLUS
	'106D', // NUMPADMINUS
	'106A', // NUMPADMULTIPLY
	'116F', // NUMPADDIVIDE
	'1060', // NUMPAD0
	'1061', // NUMPAD1
	'1062', // NUMPAD2
	'1063', // NUMPAD3
	'1064', // NUMPAD4
	'1065', // NUMPAD5
	'1066', // NUMPAD6
	'1067', // NUMPAD7
	'1068', // NUMPAD8
	'1069', // NUMPAD9
	'1041', // A
	'1042', // B
	'1043', // C
	'1044', // D
	'1045', // E
	'1046', // F
	'1047', // G
	'1048', // H
	'1049', // I
	'104A', // J
	'104B', // K
	'104C', // L
	'104D', // M
	'104E', // N
	'104F', // O
	'1050', // P
	'1051', // Q
	'1052', // R
	'1053', // S
	'1054', // T
	'1055', // U
	'1056', // V
	'1057', // W
	'1058', // X
	'1059', // Y
	'105A', // Z
	'1031', // 1
	'1032', // 2
	'1033', // 3
	'1034', // 4
	'1035', // 5
	'1036', // 6
	'1037', // 7
	'1038', // 8
	'1039', // 9
	'1030', // 0
	'1070', // F1
	'1071', // F2
	'1072', // F3
	'1073', // F4
	'1074', // F5
	'1075', // F6
	'1076', // F7
	'1077', // F8
	'1078', // F9
	'1079', // F10
	'107A', // F11
	'107B', // F12
	'1124', // HOME
	'1123', // END
	'1122', // PAGEDOWN
	'1121', // PAGEUP
	'1125', // LEFT
	'1126', // UP
	'1127', // RIGHT
	'1128', // DOWN
];

const START = 29;

let bmtp =
	`[Project]\n` +
	`Version=1\n`;

let c;
for (c = 0; c < 16; c++) {
	bmtp +=
		`\n[Preset.${c}]\n` +
		`Name=Musician MIDI (channel ${c + 1})\n` +
		`Active=1\n`;

	const cHex = c.toString(16).toUpperCase();
	let rule = 0;
	let i;
	for (i in MAPPING) {
		const compKeyCode = MAPPING[i];
		const midiKey = START + parseInt(i, 10);
		const midiKeyCode = midiKey.toString(16).toUpperCase();
		const octave = Math.floor((midiKey - 12) / 12);
		const note = (midiKey - 12) % 12;
		const midiKeyName = NOTE_NAMES[note] + octave;

		bmtp +=
			`Name${rule}=${midiKeyName} up\n` +
			`Incoming${rule}=MID18${cHex}${midiKeyCode}pp\n` +
			`Outgoing${rule}=KAM12100KSQ1000${compKeyCode}\n` +
			`Options${rule}=Actv01Stop00OutO00\n`;
		rule++;
		bmtp +=
			`Name${rule}=${midiKeyName} up (alternate)\n` +
			`Incoming${rule}=MID19${cHex}${midiKeyCode}00\n` +
			`Outgoing${rule}=KAM12100KSQ1000${compKeyCode}\n` +
			`Options${rule}=Actv01Stop01OutO00\n`;
		rule++;
		bmtp +=
			`Name${rule}=${midiKeyName} down\n` +
			`Incoming${rule}=MID19${cHex}${midiKeyCode}pp\n` +
			`Outgoing${rule}=KAM11000KSQ1000${compKeyCode}\n` +
			`Options${rule}=Actv01Stop00OutO00\n`;
		rule++;
	}

	bmtp +=
		`Name${rule}=Pedal down\n` +
		`Incoming${rule}=MID1B${cHex}407F\n` +
		`Outgoing${rule}=KAM11000KSQ10001020\n` +
		`Options${rule}=Actv01Stop00OutO00\n`;
	rule++;
	bmtp +=
		`Name${rule}=Pedal up\n` +
		`Incoming${rule}=MID1B${cHex}4000\n` +
		`Outgoing${rule}=KAM12100KSQ10001020\n` +
		`Options${rule}=Actv01Stop00OutO00\n`;
}

process.stdout.write(bmtp);