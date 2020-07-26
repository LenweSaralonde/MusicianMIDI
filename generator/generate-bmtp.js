'use strict'

const KEY_NIBBLES = [
	'060260', // Numpad 0
	'061261', // Numpad 1
	'062262', // Numpad 2
	'063263', // Numpad 3
	'064264', // Numpad 4
	'065265', // Numpad 5
	'066266', // Numpad 6
	'067267', // Numpad 7
	'068268', // Numpad 8
	'069269', // Numpad 9
	'06E26E', // Numpad .
	'16F36F', // Numpad /
	'06A26A', // Numpad *
	'06D26D', // Numpad -
	'06B26B', // Numpad +
	'12D32D', // Insert
];

const MESSAGES_2 = [
	'C', // Cx pp      Program change
];

const MESSAGES_3 = [
	'8', // 8x nn vv   Note nn off
	'9', // 9x nn vv   Note nn on, Volume vv
	'B', // Bx nn vv   Controller
	'E', // Ex v1 v2   Pitch Bender
];

const KEYSTROKE_COMMAND = 'KAM10100KSQ10004'; // 2 keystrokes

/**
 * Set translator rule
 * @param {array} rules
 * @param {string} name
 * @param {string} input
 * @param {string} output
 * @param {boolean} [isFinal=false]
 */
function setRule(rules, name, input, output, isFinal = false) {
	rules.push([name, input, output, isFinal]);
}

/**
 * Generate BMTP for preset
 * @param {int} presetId
 * @param {string} presetName
 * @param {array} rules
 * @return {string}
 */
function getPreset(presetId, presetName, rules) {
	let bmtp =
		`[Preset.${presetId}]\n` +
		`Name=${presetName}\n` +
		`Active=1\n`;

	for (let ruleId = 0; ruleId < rules.length; ruleId++) {
		const [name, input, output, isFinal] = rules[ruleId];
		bmtp +=
			`Name${ruleId}=${name}\n` +
			`Incoming${ruleId}=MID1${input}\n` +
			`Outgoing${ruleId}=${output}\n` +
			`Options${ruleId}=Actv01Stop0${isFinal?1:0}OutO00\n`;
	}

	return bmtp;
}


/**
 * Main routine
 */
function main() {

	// status rules
	const rules_2_status = [];
	const rules_3_status = [];
	for (let channel = 0; channel < 16; channel++) {
		const channelHex = channel.toString(16).toUpperCase();
		for (let opcodeHex of MESSAGES_2) {
			const opcode = parseInt(opcodeHex, 16);
			setRule(rules_2_status, `${opcodeHex}${channelHex}`, `${opcodeHex}${channelHex}pp`, KEYSTROKE_COMMAND + KEY_NIBBLES[opcode] + KEY_NIBBLES[channel]);
		}
		for (let opcodeHex of MESSAGES_3) {
			const opcode = parseInt(opcodeHex, 16);
			setRule(rules_3_status, `${opcodeHex}${channelHex}`, `${opcodeHex}${channelHex}ppqq`, KEYSTROKE_COMMAND + KEY_NIBBLES[opcode] + KEY_NIBBLES[channel]);
		}
	}

	// data rules
	const rules_2_data = [];
	const rules_3_data1 = [];
	const rules_3_data2 = [];
	for (let value = 0; value < 256; value++) {
		const hexValue = value.toString(16).toUpperCase().padStart(2, '0');
		const b1 = Math.floor(value / 16);
		const b2 = value % 16;
		const output = KEYSTROKE_COMMAND + KEY_NIBBLES[b1] + KEY_NIBBLES[b2];
		setRule(rules_2_data, `${hexValue}`, `oo${hexValue}`, output, true);
		setRule(rules_3_data1, `${hexValue}`, `oo${hexValue}qq`, output);
		setRule(rules_3_data2, `${hexValue}`, `oopp${hexValue}`, output, true);
	}

	let bmtp =
		`[Project]\n` +
		`Version=1\n`;

	bmtp += getPreset(0, `[2] status`, rules_2_status);
	bmtp += getPreset(1, `[2] data`, rules_2_data);
	bmtp += getPreset(2, `[3] status`, rules_3_status);
	bmtp += getPreset(3, `[3] data 1`, rules_3_data1);
	bmtp += getPreset(4, `[3] data 2`, rules_3_data2);

	process.stdout.write(bmtp);
}

main();