MusicianMIDI = LibStub("AceAddon-3.0"):NewAddon("MusicianMIDI", "AceEvent-3.0")

local MODULE_NAME = "MIDI"
Musician.AddModule(MODULE_NAME)

local MusicianGetCommands
local MusicianButtonGetMenu

local channelPrograms = {}
local buffer = {} -- Current MIDI message buffer

--- OnEnable
--
function MusicianMIDI:OnEnable()
	Musician.Utils.Debug(MODULE_NAME, 'MusicianMIDI', 'OnInitialize')

	-- Incompatible Musician version
	if Musician.Live.SetSustain == nil then
		Musician.Utils.Error(MusicianMIDI.Msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION)
		return
	end

	-- Initialize keyboard
	MusicianMIDI.Frame.Init()

	-- Hook Musician functions
	MusicianButtonGetMenu = MusicianButton.GetMenu
	MusicianButton.GetMenu = MusicianMIDI.GetMenu
	MusicianGetCommands = Musician.GetCommands
	Musician.GetCommands = MusicianMIDI.GetCommands
end

--- Return main menu elements
-- @return menu (table)
function MusicianMIDI.GetMenu()
	local menu = MusicianButtonGetMenu()

	-- Show MIDI keyboard
	local index, row
	for index, row in pairs(menu) do
		-- Insert after the standard "Show keyboard" option
		if row.text == Musician.Msg.MENU_SHOW_KEYBOARD then
			table.insert(menu, index + 1, {
				notCheckable = true,
				text = MusicianMIDI.Msg.MENU_LIVE_MIDI,
				func = function()
					MusicianMIDI_Frame:Show()
				end
			})
		end
	end

	return menu
end

--- Get command definitions
-- @return commands (table)
function MusicianMIDI.GetCommands()
	local commands = MusicianGetCommands()

	local liveIndex, index, command
	for index, command in pairs(commands) do
		if command.text == Musician.Msg.COMMAND_LIVE_KEYBOARD then
			table.insert(commands, index + 1, {
				command = { "midi", "livemidi", "midilive", "midikeyboard" },
				text = MusicianMIDI.Msg.COMMAND_LIVE_MIDI,
				func = function()
					MusicianMIDI_Frame:Show()
				end
			})
			break
		end
	end

	return commands
end

--- Read incoming MIDI nibble
-- @param nibble (int) 0x0 - 0xF
function MusicianMIDI.readNibble(nibble)
	if nibble >= 0x0 and nibble <= 0xF then
		-- Initiating a new unsupported MIDI message
		if #buffer == 0 and MusicianMIDI.SUPPORTED_MESSAGE_SIZE[nibble] == nil then
			return
		end

		-- Add nibble to buffer
		table.insert(buffer, nibble)

		-- Process message when buffer is complete
		if MusicianMIDI.SUPPORTED_MESSAGE_SIZE[buffer[1]] == #buffer then
			local strBuffer = string.format(strrep('%X%X ', #buffer / 2), unpack(buffer))
			Musician.Utils.Debug(MODULE_NAME, "incoming message", strBuffer)
			MusicianMIDI.processMIDIMessage(buffer)
			buffer = {}
		end
	end
end

--- Process incoming MIDI message
-- @param msg (table)
function MusicianMIDI.processMIDIMessage(msg)
	local opcode = msg[1]
	local channel = msg[2]
	local value1, value2
	local layer = MusicianMIDI.getLayer(channel)

	if #msg >= 4 then value1 = 16 * msg[3] + msg[4] end
	if #msg >= 6 then value2 = 16 * msg[5] + msg[6] end

	-- Note on
	if opcode == 0x9 and value2 > 0 then
		Musician.Live.NoteOn(value1, layer, MusicianMIDI.getInstrument(channel), false)
		Musician.Utils.Debug(MODULE_NAME, "Note ON", channel, value1, value2)
	-- Note off
	elseif opcode == 0x8 or opcode == 0x9 and value2 == 0 then
		Musician.Live.NoteOff(value1, layer, MusicianMIDI.getInstrument(channel), false)
		Musician.Utils.Debug(MODULE_NAME, "Note OFF", channel, value1, value2)
	-- Sustain
	elseif opcode == 0xB and value1 == 0x40 then
		Musician.Live.SetSustain(value2 >= 64, layer)
		Musician.Utils.Debug(MODULE_NAME, "Sustain", channel, value2)
	-- Program change
	elseif opcode == 0xC then
		Musician.Live.AllNotesOff(layer)
		MusicianMIDI.setProgram(channel, value1)
		Musician.Utils.Debug(MODULE_NAME, "Program change", channel, value1, MusicianMIDI.getInstrument(channel))
	end
end

--- Set MIDI program number to channel
-- @param channel (int) 0-15
-- @param program (int) 0-127
function MusicianMIDI.setProgram(channel, program)
	channelPrograms[channel] = program
end

--- Return current MIDI program for channel
-- @param channel (int) 0-15
-- @return program (int) 0-127
function MusicianMIDI.getProgram(channel)
	return channelPrograms[channel] or 0
end

--- Return current Musician instrument number for channel
-- @param channel (int) 0-15
-- @return program (int) 0-255
function MusicianMIDI.getInstrument(channel)
	-- Percussions
	if channel == 9 then
		return MusicianMIDI.getProgram(channel) + 128
	end

	-- Melodic
	return MusicianMIDI.getProgram(channel)
end

--- Return the live layer corresponding to the provided MIDI channel
-- @param channel (int) 0-15
-- @return layer (int)
function MusicianMIDI.getLayer(channel)
	-- Keep MIDI channel layers out of the 2 live keyboard layers to avoid unexpected side effects
	return channel + 2
end

