const { vJoy, vJoyDevice } = require('vjoy');
const midi = require('midi');

///////////////////// Initialize Joystick /////////////////////
let deviceId = 1;

if (process.argv.length > 2) {
	deviceId = Number(process.argv[2]);
}

if (!vJoy.isEnabled()) {
	console.log("vJoy is not enabled.");
	process.exit();
}

let device = vJoyDevice.create(deviceId);

if (device == null) {
	console.log(`Could not initialize the device. Status: ${vJoyDevice.status(deviceId)}`);
	process.exit();
}

///////////////////// Initialize MIDI /////////////////////

// Set up a new input.
const input = new midi.Input();

// Count the available input ports.
console.log("getPortCount", input.getPortCount());

// Get the name of a specified input port.
for (let port = 0; port < input.getPortCount(); port++) {
	console.log("Available MIDI port", port, input.getPortName(port));
}

input.openPort(3); // Use port 3

///////////////////// MIDI input handler /////////////////////

device.axes.X.set(1);
device.axes.Y.set(1);
device.axes.Z.set(1);

input.on('message', (deltaTime, message) => {
	const val1 = Math.round((message[0] || 0) / 0xFF * 0x8000) + 1;
	const val2 = Math.round((message[1] || 0) / 0xFF * 0x8000) + 1;
	const val3 = Math.round((message[2] || 0) / 0xFF * 0x8000) + 1;
	console.log(message, val1, val2, val3);
	device.axes.X.set(val1);
	device.axes.Y.set(val2);
	device.axes.Z.set(val3);
	device.resetButtons();
	device.buttons[1].set(true);
});