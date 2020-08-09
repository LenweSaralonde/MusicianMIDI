MusicianMIDI = LibStub("AceAddon-3.0"):NewAddon("MusicianMIDI", "AceEvent-3.0")

local MODULE_NAME = "MIDI"
Musician.AddModule(MODULE_NAME)

local MusicianGetCommands
local MusicianButtonGetMenu

--- OnEnable
--
function MusicianMIDI:OnEnable()
	Musician.Utils.Debug(MODULE_NAME, 'MusicianMIDI', 'OnInitialize')

	-- Incompatible Musician version
	if Musician.Live.SetSustain == nil or Musician.Utils.VersionCompare(GetAddOnMetadata("Musician", "Version"), '1.6.0.5') < 0 then
		Musician.Utils.Error(MusicianMIDI.Msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION)
		return
	end

	-- Initialize keyboard
	MusicianMIDI.Keyboard.Init()

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
				text = MusicianMIDI.Msg.MENU_MIDI_KEYBOARD,
				func = function()
					MusicianMIDIKeyboard:Show()
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
				text = MusicianMIDI.Msg.COMMAND_LIVE_KEYBOARD,
				func = function()
					MusicianMIDIKeyboard:Show()
				end
			})
			break
		end
	end

	return commands
end
