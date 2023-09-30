MusicianMIDI = LibStub("AceAddon-3.0"):NewAddon("MusicianMIDI", "AceEvent-3.0")

local MODULE_NAME = "MIDI"
Musician.AddModule(MODULE_NAME)

local isInitialized = false

local MusicianGetCommands
local MusicianButtonGetMenu

--- OnEnable
--
function MusicianMIDI:OnEnable()
	Musician.Utils.Debug(MODULE_NAME, 'MusicianMIDI', 'OnInitialize')

	-- Init bindings names
	_G.BINDING_NAME_MUSICIANMIDITOGGLE = MusicianMIDI.Msg.COMMAND_LIVE_KEYBOARD

	-- Incompatible Musician version
	if MusicianMIDI.MUSICIAN_API_VERSION > (Musician.API_VERSION or 0)
		or not Musician.Utils.SetPropagateKeyboardInput
	then
		Musician.Utils.Error(MusicianMIDI.Msg.ERROR_MUSICIAN_VERSION_TOO_OLD)
		Musician.Utils.PrintError(MusicianMIDI.Msg.ERROR_MUSICIAN_VERSION_TOO_OLD)
		return
	elseif MusicianMIDI.MUSICIAN_API_VERSION < Musician.API_VERSION then
		Musician.Utils.Error(MusicianMIDI.Msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD)
		Musician.Utils.PrintError(MusicianMIDI.Msg.ERROR_MUSICIAN_MIDI_VERSION_TOO_OLD)
		return
	end

	-- Initialize keyboard
	MusicianMIDI.Keyboard.Init()

	-- Hook Musician functions
	MusicianButtonGetMenu = MusicianButton.GetMenu
	MusicianButton.GetMenu = MusicianMIDI.GetMenu
	MusicianGetCommands = Musician.GetCommands
	Musician.GetCommands = MusicianMIDI.GetCommands

	-- Initialization complete
	isInitialized = true
end

--- Indicates if the plugin is properly initialized
-- @return isInitialized (table)
function MusicianMIDI.IsInitialized()
	return isInitialized
end

--- Initialize a locale and returns the initialized message table
-- @param languageCode (string) Short language code (ie 'en')
-- @param languageName (string) Locale name (ie "English")
-- @param localeCode (string) Long locale code (ie 'enUS')
-- @param[opt] ... (string) Additional locale codes
-- @return msg (table) Initialized message table
function MusicianMIDI.InitLocale(languageCode, languageName, localeCode, ...)
	local localeCodes = { localeCode, ... }

	-- Set English (en) as base locale
	local baseLocale = languageCode == 'en' and MusicianMIDI.LocaleBase or MusicianMIDI.Locale.en

	-- Init table
	local msg = Musician.Utils.DeepCopy(baseLocale)
	MusicianMIDI.Locale[languageCode] = msg
	msg.LOCALE_NAME = languageName
	msg.LOCALE_CODES = localeCodes

	-- Set English (en) as the current language by default
	if languageCode == 'en' then
		MusicianMIDI.Msg = msg
	else
		-- Set localized messages
		for _, locale in pairs(localeCodes) do
			if GetLocale() == locale then
				MusicianMIDI.Msg = msg
				break
			end
		end
	end

	return msg
end

--- Return main menu elements
-- @return menu (table)
function MusicianMIDI.GetMenu()
	local menu = MusicianButtonGetMenu()

	-- Show MIDI keyboard
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