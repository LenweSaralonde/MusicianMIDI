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
	if Musician.Live.SetSustain == nil then
		Musician.Utils.Error(MusicianMIDI.Msg.ERROR_INCOMPATIBLE_MUSICIAN_VERSION)
		return
	end

	-- Initialize keyboard
	MusicianMIDI.Keyboard.Init()

	-- Hook Musician functions
	MusicianButtonGetMenu = MusicianButton.GetMenu
	MusicianButton.GetMenu = MusicianMIDI.GetMenu
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