--- Live MIDI keyboard window
-- @module MusicianMIDI.Keyboard

MusicianMIDI.Keyboard = LibStub("AceAddon-3.0"):NewAddon("MusicianMIDI.Keyboard", "AceEvent-3.0")

local MODULE_NAME = "MIDIKeyboard"
Musician.AddModule(MODULE_NAME)

local LAYER = Musician.KEYBOARD_LAYER

local LayerNames = {
	[LAYER.UPPER] = "Upper",
	[LAYER.LOWER] = "Lower",
}

local ICON = {
	["SOLO_MODE"] = Musician.Icons.Headphones,
	["LIVE_MODE"] = Musician.Icons.Speaker
}

local transpose = {
	[LAYER.UPPER] = 0,
	[LAYER.LOWER] = 0,
}

local instrument = {
	[LAYER.UPPER] = 0,
	[LAYER.LOWER] = 0,
}

local sustain = false

--- Init controls for a layer
-- @param layer (int)
local function initLayerControls(layer)
	local varNamePrefix = "MusicianMIDIKeyboard" .. LayerNames[layer]

	-- Instrument selector
	local instrumentSelector = _G[varNamePrefix .. "Instrument"]
	instrumentSelector.OnChange = function(i)
		Musician.Live.AllNotesOff(layer)
		instrument[layer] = i
	end

	instrumentSelector.SetValue(instrument[layer])
	instrumentSelector.tooltipText = MusicianMIDI.Msg.SELECT_INSTRUMENT

	-- Transpose selector
	local transposeSelector = _G[varNamePrefix .. "Transpose"]
	local transposeValues = {"+3", "+2", "+1", "0", "-1", "-2", "-3"}
	transposeSelector.tooltipText = MusicianMIDI.Msg.TRANSPOSE_INSTRUMENT

	transposeSelector.SetValue = function(value)
		transposeSelector.SetIndex(4 - floor(value / 12))
	end

	transposeSelector.SetIndex = function(index)
		transposeSelector.index = index
		Musician.Live.AllNotesOff(layer)
		transpose[layer] = (-index + 4) * 12
		MSA_DropDownMenu_SetText(transposeSelector, transposeValues[index])
	end

	transposeSelector.OnClick = function(self, arg1, arg2, checked)
		transposeSelector.SetIndex(arg1)
	end

	transposeSelector.GetItems = function(frame, level, menuList)
		local info = MSA_DropDownMenu_CreateInfo()
		info.func = transposeSelector.OnClick

		local index, label
		for index, label in pairs(transposeValues) do
			info.text = label
			info.arg1 = index
			info.checked = transposeSelector.index == index
			MSA_DropDownMenu_AddButton(info)
		end
	end

	MSA_DropDownMenu_Initialize(transposeSelector, transposeSelector.GetItems)
	transposeSelector.SetValue(transpose[layer])
end

--- Update texts and icons for live and solo modes
--
local function updateLiveModeButton()
	local sourceButton = MusicianKeyboardLiveModeButton
	local button = MusicianMIDIKeyboardLiveModeButton

	button.icon:SetText(sourceButton.icon:GetText())
	button:SetText(sourceButton:GetText())
	button.tooltipText = sourceButton.tooltipText
	button:SetEnabled(sourceButton:IsEnabled())
end

--- Init live mode button
--
local function initLiveModeButton()
	local button = MusicianMIDIKeyboardLiveModeButton

	MusicianMIDIKeyboardLiveModeButton:SetScript("OnClick", function()
		Musician.Live.Enable(not(Musician.Live.IsEnabled()))
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	end)

	MusicianMIDI.Keyboard:RegisterMessage(Musician.Events.LiveModeChange, updateLiveModeButton)

	updateLiveModeButton()
end

--- Update texts and icons for band play
--
local function updateBandSyncButton()
	local sourceButton = MusicianKeyboardBandSyncButton
	local button = MusicianMIDIKeyboardBandSyncButton
	local syncedPlayersCount = #Musician.Live.GetSyncedBandPlayers()

	button:SetShown(IsInGroup())
	button:SetEnabled(sourceButton:IsEnabled())
	button:SetChecked(sourceButton.checked)
	button.count.text:SetText(syncedPlayersCount)
	button.count:SetShown(syncedPlayersCount > 0)
	button:SetTooltipText(sourceButton.tooltipText)
end

--- Init band sync button
--
local function initBandSyncButton()
	hooksecurefunc(MusicianKeyboardBandSyncButton, "SetShown", updateBandSyncButton)
	hooksecurefunc(Musician.Keyboard, "UpdateBandSyncButton", updateBandSyncButton)
	updateBandSyncButton()
end

--- Initialize MIDI keyboard
--
function MusicianMIDI.Keyboard.Init()
	MusicianMIDIKeyboard:SetScript("OnKeyDown", MusicianMIDI.Keyboard.OnPhysicalKeyDown)
	MusicianMIDIKeyboard:SetScript("OnKeyUp", MusicianMIDI.Keyboard.OnPhysicalKeyUp)

	-- Init controls
	initLiveModeButton()
	initBandSyncButton()
	initLayerControls(LAYER.UPPER)
end

--- OnPhysicalKeyDown
-- @param event (string)
-- @param keyValue (string)
MusicianMIDI.Keyboard.OnPhysicalKeyDown = function(event, keyValue)
	MusicianMIDI.Keyboard.OnPhysicalKey(keyValue, true)
end

--- OnPhysicalKeyUp
-- @param event (string)
-- @param keyValue (string)
MusicianMIDI.Keyboard.OnPhysicalKeyUp = function(event, keyValue)
	MusicianMIDI.Keyboard.OnPhysicalKey(keyValue, false)
end

--- Key up/down handler, from physical keyboard
-- @param keyValue (string)
-- @param down (boolean)
MusicianMIDI.Keyboard.OnPhysicalKey = function(keyValue, down)
	local layer = LAYER.UPPER

	-- Close window
	if keyValue == 'ESCAPE' and down then
		MusicianMIDIKeyboard:Hide()
		MusicianMIDIKeyboard:SetPropagateKeyboardInput(false)
		return
 	end

	-- Sustain (pedal)
	if keyValue == 'SPACE' then
		Musician.Live.SetSustain(down, LAYER.UPPER)
		Musician.Live.SetSustain(down, LAYER.LOWER)
		MusicianMIDIKeyboard:SetPropagateKeyboardInput(false)
		return
	end

	-- Note on/note off
	local noteKey = MusicianMIDI.KEY_BINDINGS[keyValue]
	if noteKey ~= nil then
		noteKey = noteKey + transpose[layer]
		local noteId = layer .. noteKey .. instrument[layer]
		if down then
			Musician.Live.NoteOn(noteKey, layer, instrument[layer], false)
		else
			Musician.Live.NoteOff(noteKey, layer, instrument[layer], false)
		end

		MusicianMIDIKeyboard:SetPropagateKeyboardInput(false)
		return
	end

	-- Default: propagate
	MusicianMIDIKeyboard:SetPropagateKeyboardInput(true)
end

