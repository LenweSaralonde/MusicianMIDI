var { KeyTap } = require("./lib/keytap.js");
const keycode = require("keycode");
const midi = require('midi');

const MAPPING = {
	'0': keycode.codes['numpad 0'],
	'1': keycode.codes['numpad 1'],
	'2': keycode.codes['numpad 2'],
	'3': keycode.codes['numpad 3'],
	'4': keycode.codes['numpad 4'],
	'5': keycode.codes['numpad 5'],
	'6': keycode.codes['numpad 6'],
	'7': keycode.codes['numpad 7'],
	'8': keycode.codes['numpad 8'],
	'9': keycode.codes['numpad 9'],
	'a': keycode.codes['a'],
	'b': keycode.codes['b'],
	'c': keycode.codes['c'],
	'd': keycode.codes['d'],
	'e': keycode.codes['e'],
	'f': keycode.codes['f'],
};

///////////////////// Initialize MIDI /////////////////////

// Set up a new input.
const input = new midi.Input();

// Count the available input ports.
console.log("getPortCount", input.getPortCount());

// Get the name of a specified input port.
for (let port = 0; port < input.getPortCount(); port++) {
	console.log("Available MIDI port", port, input.getPortName(port));
}

input.openPort(0);

// setTimeout(() => {
// 	for (let i = 0; i < 16; i++) {
// 		KeyTap(MAPPING[i.toString(16)]);
// 	}
// }, 3000);

///////////////////// MIDI input handler /////////////////////

input.on('message', async (deltaTime, message) => {
	let hex = '';
	for (let num of message) {
		hex += num.toString(16).padStart(2, '0');
	}

	console.log(message, hex);

	for (let n of hex) {
		KeyTap(MAPPING[n], { async: true });
	}
});