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

local splitKey
local splitMode

local mouseKeysDown = {}
local keyboardKeysDown = {}
local currentMouseKey = nil -- Current virtual keyboard button active by the mouse

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
	transposeSelector.tooltipText = MusicianMIDI.Msg.INSTRUMENT_OCTAVE

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
		Musician.Live.EnableLive(not(Musician.Live.IsLiveEnabled()))
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

--- Init piano keyboard
--
local function initPianoKeyboard()
	local frame = MusicianMIDIKeyboard
	local container = MusicianMIDIKeyboard.pianoKeys

	frame.pianoKeyButtons = {}

	-- Get bounds and count white keys
	local from, to
	local whites = 0
	for keyValue, key in pairs(MusicianMIDI.KEY_BINDINGS) do
		from = from and min(from, key) or key
		to = to and max(to, key) or key
		local octaveKey = key % 12
		-- Not a black key
		if not(octaveKey == 1 or octaveKey == 3 or octaveKey == 6 or octaveKey == 8 or octaveKey == 10) then
			whites = whites + 1
		end
	end

	-- Create piano keys as buttons
	local x = 0
	local w = container:GetWidth() / whites
	for key = from, to do
		local button = CreateFrame('Button', nil, container, 'MusicianMIDIPianoKey')
		frame.pianoKeyButtons[key] = button
		button:SetWidth(w)
		button:SetHeight(container:GetHeight())
		button:SetPoint('TOPLEFT', x, 0)
		button.key = key
		button.isFirst = key == from
		button.isLast = key == to
		if key % 12 == 4 or key % 12 == 11 then -- No black key between E-F and B-C
			x = x + w
		else
			x = x + w / 2
		end
		MusicianMIDI.Keyboard.SetVirtualKeyDown(key, button.down)
		button:HookScript('OnMouseDown', MusicianMIDI.Keyboard.OnVirtualKeyMouseDown)
		button:HookScript('OnMouseUp', MusicianMIDI.Keyboard.OnVirtualKeyMouseUp)
		button:HookScript('OnEnter', MusicianMIDI.Keyboard.OnVirtualKeyEnter)
		button:HookScript('OnLeave', MusicianMIDI.Keyboard.OnVirtualKeyLeave)
	end
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
	initLayerControls(LAYER.LOWER)
	MusicianMIDI.Keyboard.SetSplit(false)

	-- Init piano keyboard
	initPianoKeyboard()
end

--- OnPhysicalKeyDown
-- @param event (string)
-- @param keyValue (string)
function MusicianMIDI.Keyboard.OnPhysicalKeyDown(event, keyValue)
	MusicianMIDI.Keyboard.OnPhysicalKey(keyValue, true)
end

--- OnPhysicalKeyUp
-- @param event (string)
-- @param keyValue (string)
function MusicianMIDI.Keyboard.OnPhysicalKeyUp(event, keyValue)
	MusicianMIDI.Keyboard.OnPhysicalKey(keyValue, false)
end

--- Key up/down handler, from physical keyboard
-- @param keyValue (string)
-- @param down (boolean)
function MusicianMIDI.Keyboard.OnPhysicalKey(keyValue, down)
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
		MusicianMIDI.Keyboard.OnKeyboardKey(noteKey, down)
		MusicianMIDIKeyboard:SetPropagateKeyboardInput(false)
		return
	end

	-- Default: propagate
	MusicianMIDIKeyboard:SetPropagateKeyboardInput(true)
end

--- Key up/down handler, from MIDI piano keyboard
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.OnKeyboardKey(noteKey, down)
	local wasDown = keyboardKeysDown[noteKey] and not(mouseKeysDown[noteKey])
	local wasUp = not(keyboardKeysDown[noteKey]) and not(mouseKeysDown[noteKey])
	keyboardKeysDown[noteKey] = down and true or nil
	if not(down) and wasDown or down and wasUp then
		MusicianMIDI.Keyboard.SetNote(noteKey, down)
		MusicianMIDI.Keyboard.SetVirtualKeyDown(noteKey, down)
	end
end

--- Key up/down handler, from virtual piano keyboard
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.OnVirtualKey(noteKey, down)
	local wasDown = not(keyboardKeysDown[noteKey]) and mouseKeysDown[noteKey]
	local wasUp = not(keyboardKeysDown[noteKey]) and not(mouseKeysDown[noteKey])
	mouseKeysDown[noteKey] = down and true or nil
	if not(down) and wasDown or down and wasUp then
		local splitKeyEditBox = MusicianMIDIKeyboard.splitKeyEditBox
		-- Setting split point using the virtual keyboard
		if down and splitKeyEditBox.isSettingSplitPoint then
			splitKeyEditBox.isSettingSplitPoint = false
			mouseKeysDown[noteKey] = nil
			MusicianMIDI.Keyboard.SetSplitKey(noteKey)
		else
			MusicianMIDI.Keyboard.SetNote(noteKey, down)
			MusicianMIDI.Keyboard.SetVirtualKeyDown(noteKey, down)
		end
	end
end

--- Virtual keyboard button mouse down handler
-- @param button (Button)
-- @param mouseButton (string)
function MusicianMIDI.Keyboard.OnVirtualKeyMouseDown(button, mouseButton)
	MusicianMIDI.Keyboard.OnVirtualKey(button.key, true)
end

--- Virtual keyboard button mouse up handler
-- @param button (Button)
-- @param mouseButton (string)
function MusicianMIDI.Keyboard.OnVirtualKeyMouseUp(button, mouseButton)
	if currentMouseKey then
		MusicianMIDI.Keyboard.OnVirtualKey(currentMouseKey, false)
	end
end

--- Virtual keyboard button mouse enter handler
-- @param button (Button)
function MusicianMIDI.Keyboard.OnVirtualKeyEnter(button)
	currentMouseKey = button.key
	if IsMouseButtonDown() then
		MusicianMIDI.Keyboard.OnVirtualKey(button.key, true)
	end
end

--- Virtual keyboard button mouse leave handler
-- @param button (Button)
function MusicianMIDI.Keyboard.OnVirtualKeyLeave(button)
	if currentMouseKey and IsMouseButtonDown() then
		MusicianMIDI.Keyboard.OnVirtualKey(button.key, false)
	end
	currentMouseKey = nil
end

--- Set note event
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.SetNote(noteKey, down)

	-- Handle keyboard splitting
	local layer = LAYER.UPPER
	if MusicianMIDI.Keyboard.GetSplit() and noteKey < MusicianMIDI.Keyboard.GetSplitKey() then
		layer = LAYER.LOWER
	end

	-- Handle transposition
	noteKey = noteKey + transpose[layer]

	-- Send note event
	if down then
		Musician.Live.NoteOn(noteKey, layer, instrument[layer], false)
	else
		Musician.Live.NoteOff(noteKey, layer, instrument[layer], false)
	end
end

--- Set piano key down on the virtual keyboard
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.SetVirtualKeyDown(noteKey, down)

	local button = MusicianMIDIKeyboard.pianoKeyButtons[noteKey]

	if not(button) then return end

	button.down = down

	local key = button.key % 12
	local texturePosition = 0

	-- Black key
	if key == 1 or key == 3 or key == 6 or key == 8 or key == 10 then
		if down then
			texturePosition = 5
		else
			texturePosition = 6
		end

		-- Only a part of the black key is clickable
		local w = button:GetWidth()
		local h = button:GetHeight()
		button:SetHitRectInsets(0.2 * w, 0.2 * w, 0, .42 * h)

		-- Black keys on top of the white ones
		button:SetFrameLevel(button:GetParent():GetFrameLevel() + 2)

		button.texture:SetTexCoord(.125 * texturePosition + .0078, .125 * texturePosition + .125, 0, .625)
	else -- White key
		local hasBlackLeft = not(button.isFirst) and (key == 2 or key == 4 or key == 7 or key == 11)
		local hasBlackRight = not(button.isLast) and (key == 0 or key == 2 or key == 5 or key == 7 or key == 9)

		if down then
			if not(hasBlackLeft) and hasBlackRight then
				texturePosition = 2
			elseif hasBlackLeft and hasBlackRight then
				texturePosition = 3
			elseif hasBlackLeft and not(hasBlackRight) then
				texturePosition = 4
			else
				texturePosition = 1
			end
		else
			texturePosition = 0
		end

		-- The whole key is clickable
		button:SetHitRectInsets(0, 0, 0, 0)

		-- White keys under the black ones
		button:SetFrameLevel(button:GetParent():GetFrameLevel() + 1)

		button.texture:SetTexCoord(.125 * texturePosition + 0, .125 * texturePosition + .125, 0, .625)
	end
end

--- Enable or disable split keyboard mode
-- @param isSplit (boolean)
function MusicianMIDI.Keyboard.SetSplit(isSplit)
	splitMode = isSplit
	local frame = MusicianMIDIKeyboard

	frame.splitButton:SetChecked(isSplit)

	if isSplit then
		Musician.Live.AllNotesOff(LAYER.UPPER)
		MSA_DropDownMenu_EnableDropDown(frame.lowerInstrumentDropdown)
		MSA_DropDownMenu_EnableDropDown(frame.lowerTransposeDropdown)
		frame.lowerLabel:SetFontObject(GameFontHighlight)
		frame.splitKeyEditBox:SetText(Musician.Sampler.NoteName(MusicianMIDI.Keyboard.GetSplitKey()))
		frame.splitKeyEditBox:Enable()
	else
		Musician.Live.AllNotesOff(LAYER.LOWER)
		MSA_DropDownMenu_DisableDropDown(frame.lowerInstrumentDropdown)
		MSA_DropDownMenu_DisableDropDown(frame.lowerTransposeDropdown)
		frame.lowerLabel:SetFontObject(GameFontDisable)
		frame.splitKeyEditBox:SetText('--')
		frame.splitKeyEditBox:Disable()
	end
end

--- Indicates whenever the keyboard is in split mode
-- @return isSplit (boolean)
function MusicianMIDI.Keyboard.GetSplit()
	return splitMode
end

--- Set keyboard split key
-- @param key (int)
function MusicianMIDI.Keyboard.SetSplitKey(key)
	splitKey = key
	local frame = MusicianMIDIKeyboard
	if MusicianMIDI.Keyboard.GetSplit() then
		frame.splitKeyEditBox:SetText(Musician.Sampler.NoteName(key))
	end
end

--- Get keyboard split key
-- @return key (int)
function MusicianMIDI.Keyboard.GetSplitKey()
	return splitKey or 57 -- A3
end

--- Set keyboard split key from keypress
-- @param keyValue (string)
-- @return success (boolean)
function MusicianMIDI.Keyboard.SetSplitKeyFromKeyboard(keyValue)
	local noteKey = MusicianMIDI.KEY_BINDINGS[keyValue]
	if noteKey ~= nil then
		MusicianMIDI.Keyboard.SetSplitKey(noteKey)
		return true
	end

	return false
end