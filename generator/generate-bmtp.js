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
 * Generate the keystroke command for Bome MIDI Translator.
 * @param {array} nibbles
 * @return {string}
 */
function getKeystrokeCommand(nibbles) {
	return KEYSTROKE_COMMAND + KEY_NIBBLES[nibbles[0]] + KEY_NIBBLES[nibbles[1]];
}

/**
 * Main routine
 */
function main() {

	const message_rules = [];

	for (let channel = 0; channel < 16; channel++) {
		const channelHex = channel.toString(16).toUpperCase();

		// 8x nn vv   Note off
		setRule(message_rules, `Note off ch.${channel}`, `8${channelHex}ppqq`, getKeystrokeCommand([0x8, channel]));

		// 9x nn vv   Note on
		setRule(message_rules, `Note on ch.${channel}`, `9${channelHex}ppqq`, getKeystrokeCommand([0x9, channel]));

		// Bx cc vv   Control change
		setRule(message_rules, `Pedal off ch.${channel}`, `B${channelHex}ppqq`, getKeystrokeCommand([0xB, channel]));

		// Ex v1 v2   Pitch Bender
		setRule(message_rules, `Pitch bend ch.${channel}`, `E${channelHex}ppqq`, getKeystrokeCommand([0xE, channel]));

		// Cx pp      Program change
		setRule(message_rules, `Program change ch.${channel}`, `C${channelHex}pp`, getKeystrokeCommand([0xC, channel]));
	}

	const value_rules1 = [];
	const value_rules2 = [];
	for (let value = 0; value < 128; value++) {
		const hexValue = value.toString(16).toUpperCase().padStart(2, '0');
		const b1 = Math.floor(value / 16);
		const b2 = value % 16;
		const output = getKeystrokeCommand([b1, b2]);
		setRule(value_rules1, `${hexValue}`, `oo${hexValue}`, output, true);
		setRule(value_rules1, `${hexValue}`, `oo${hexValue}pp`, output);
		setRule(value_rules2, `${hexValue}`, `oopp${hexValue}`, output, true);
	}

	let bmtp =
		`[Project]\n` +
		`Version=1\n`;

	bmtp += getPreset(0, `Events`, message_rules);
	bmtp += getPreset(1, `Values 1`, value_rules1);
	bmtp += getPreset(2, `Values 2`, value_rules2);

	process.stdout.write(bmtp);
}

main();