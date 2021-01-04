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

local refreshPianoKeyboardColors
local refreshPianoKeyboardLayout

--- Init controls for a layer
-- @param layer (int)
local function initLayerControls(layer)
	local varNamePrefix = "MusicianMIDIKeyboard" .. LayerNames[layer]

	-- Instrument selector
	local instrumentSelector = _G[varNamePrefix .. "Instrument"]
	instrumentSelector.OnChange = function(i)
		Musician.Live.AllNotesOff(layer)
		instrument[layer] = i
		refreshPianoKeyboardColors(layer)
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
	local button = MusicianMIDIKeyboardLiveModeButton

	if Musician.Live.IsLiveEnabled() and Musician.Live.CanStream() then
		button.led:SetAlpha(1)
		button.tooltipText = Musician.Msg.ENABLE_SOLO_MODE
	else
		button.led:SetAlpha(0)
		button.tooltipText = Musician.Msg.ENABLE_LIVE_MODE
	end

	if Musician.Live.IsLiveEnabled() and Musician.Live.CanStream() then
		MusicianKeyboardTitle:SetText(Musician.Msg.PLAY_LIVE)
		MusicianKeyboardTitleIcon:SetText(ICON.LIVE_MODE)
	else
		MusicianKeyboardTitle:SetText(Musician.Msg.PLAY_SOLO)
		MusicianKeyboardTitleIcon:SetText(ICON.SOLO_MODE)
	end

	if not(Musician.Live.CanStream()) then
		button:Disable()
		button.tooltipText = Musician.Msg.LIVE_MODE_DISABLED
	else
		button:Enable()
	end
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

--- Refresh whole piano keyboard layout
--
function refreshPianoKeyboardLayout()

	local frame = MusicianMIDIKeyboard
	local container = MusicianMIDIKeyboard.pianoKeys

	-- Get bounds and count white keys
	local minKey, maxKey = Musician.MIN_KEY, Musician.MAX_KEY
	local from, to
	local whites = 0
	for _, button in pairs(frame.pianoKeyButtons) do
		local key = button.key
		button:Hide()
		if key >= minKey and key <= maxKey then
			from = from and min(from, key) or key
			to = to and max(to, key) or key
			local octaveKey = key % 12
			-- Not a black key
			if not(octaveKey == 1 or octaveKey == 3 or octaveKey == 6 or octaveKey == 8 or octaveKey == 10) then
				whites = whites + 1
			end
		end
	end

	-- Set piano keys layout
	local x = 0
	local w = container:GetWidth() / whites
	local h = container:GetHeight()
	for key = from, to do
		local button = frame.pianoKeyButtons[key]
		if key < from or key > to then
			button:Hide()
		else
			local octaveKey = key % 12
			button:SetWidth(w)
			button:SetHeight(container:GetHeight())
			button:SetPoint('TOPLEFT', x, 0)
			button.isFirst = key == from
			button.isLast = key == to
			if octaveKey == 4 or octaveKey == 11 then -- No black key between E-F and B-C
				x = x + w
			else
				x = x + w / 2
			end

			-- Black key
			if octaveKey == 1 or octaveKey == 3 or octaveKey == 6 or octaveKey == 8 or octaveKey == 10 then
				-- Only a part of the black key is clickable
				button:SetHitRectInsets(0.2 * w, 0.2 * w, 0, .42 * h)

				-- Resize textures to clickable area
				button.color:SetSize(10, 46)
				button.glowColor:SetSize(12, 80)
				button.glowColor:SetPoint('CENTER', -2, 16)
				button.highlight:SetSize(0.6 * w, .58 * h)
				button.highlight:SetPoint('TOP', -2, -6)

				-- Black keys are on top of the white ones
				button:SetFrameLevel(button:GetParent():GetFrameLevel() + 2)
			else -- White key
				-- The whole key is clickable
				button:SetHitRectInsets(0, 0, 0, 0)

				-- Resize textures to clickable area
				button.color:SetSize(16, 80)
				button.glowColor:SetSize(22, 160)
				button.glowColor:SetPoint('CENTER', 0, -2.5)
				button.highlight:SetSize(w, h)
				button.highlight:SetPoint('TOP', 0, -10)

				-- White keys are under the black ones
				button:SetFrameLevel(button:GetParent():GetFrameLevel() + 1)
			end

			-- Set status texture status and show
			MusicianMIDI.Keyboard.SetVirtualKeyDown(key, button.down)
			button:Show()
		end
	end

	-- Set colors
	refreshPianoKeyboardColors()
end

--- Refresh piano keyboard colors
-- @param[opt] onlyForLayer (number)
function refreshPianoKeyboardColors(onlyForLayer)
	local frame = MusicianMIDIKeyboard
	for _, button in pairs(frame.pianoKeyButtons) do
		-- Set instrument color according to layer
		local layer = LAYER.UPPER
		if MusicianMIDI.Keyboard.IsSplit() and button.key < MusicianMIDI.Keyboard.GetSplitKey() then
			layer = LAYER.LOWER
		end

		if onlyForLayer == nil or onlyForLayer == layer then
			local instrumentName = Musician.Sampler.GetInstrumentName(instrument[layer])
			local r, g, b = unpack(Musician.INSTRUMENTS[instrumentName].color)
			if r > .5 then r = r * .8 end
			if g > .5 then g = g * .8 end
			if b > .5 then b = b * .8 end
			button.color:SetColorTexture(r, g, b, 1)

			-- Reset volume meter glow
			button.volumeMeter:Reset()
			button.glowColor:SetAlpha(0)
		end
	end
end

--- Init piano keyboard
--
local function initPianoKeyboard()
	local frame = MusicianMIDIKeyboard
	local container = MusicianMIDIKeyboard.pianoKeys

	frame.pianoKeyButtons = {}

	-- Create key buttons
	for keyValue, key in pairs(MusicianMIDI.KEY_BINDINGS) do
		local button = CreateFrame('Button', nil, container, 'MusicianMIDIPianoKey')
		button.key = key
		button.volumeMeter = Musician.VolumeMeter.create()
		frame.pianoKeyButtons[key] = button
		button:HookScript('OnMouseDown', MusicianMIDI.Keyboard.OnVirtualKeyMouseDown)
		button:HookScript('OnMouseUp', MusicianMIDI.Keyboard.OnVirtualKeyMouseUp)
		button:HookScript('OnEnter', MusicianMIDI.Keyboard.OnVirtualKeyEnter)
		button:HookScript('OnLeave', MusicianMIDI.Keyboard.OnVirtualKeyLeave)
		button:HookScript('OnUpdate', MusicianMIDI.Keyboard.OnVirtualKeyUpdate)
	end

	refreshPianoKeyboardLayout()

	MusicianMIDI.Keyboard:RegisterMessage(Musician.Events.LiveNoteOn, MusicianMIDI.Keyboard.OnLiveNoteOn)
	MusicianMIDI.Keyboard:RegisterMessage(Musician.Events.LiveNoteOff, MusicianMIDI.Keyboard.OnLiveNoteOff)
end

--- Initialize MIDI keyboard
--
function MusicianMIDI.Keyboard.Init()
	-- Init virtual piano keyboard
	initPianoKeyboard()

	-- Global key bindings
	MusicianMIDIKeyboard:SetScript("OnKeyDown", MusicianMIDI.Keyboard.OnPhysicalKeyDown)
	MusicianMIDIKeyboard:SetScript("OnKeyUp", MusicianMIDI.Keyboard.OnPhysicalKeyUp)

	-- Init controls
	initLiveModeButton()
	initBandSyncButton()
	initLayerControls(LAYER.UPPER)
	initLayerControls(LAYER.LOWER)
	MusicianMIDI.Keyboard.SetSplit(false)
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

	MusicianMIDIKeyboard:SetPropagateKeyboardInput(false)

	-- Close window
	if keyValue == 'ESCAPE' and down then
		MusicianMIDIKeyboard:Hide()
		return
 	end

	-- Sustain (pedal)
	if keyValue == 'SPACE' then
		MusicianMIDI.Keyboard.SetSustain(down)
		return
	end

	-- Note on/note off
	local noteKey = MusicianMIDI.KEY_BINDINGS[keyValue]
	if noteKey ~= nil then
		MusicianMIDI.Keyboard.OnKeyboardKey(noteKey, down)
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
			-- mouseKeysDown[noteKey] = nil
			MusicianMIDI.Keyboard.SetVirtualKeyDown(noteKey, false)
			MusicianMIDI.Keyboard.SetSplitKey(noteKey)
		else
			MusicianMIDI.Keyboard.SetNote(noteKey, down)
			MusicianMIDI.Keyboard.SetVirtualKeyDown(noteKey, down)
		end
	end
end

--- Virtual keyboard button mouse down handler
--
function MusicianMIDI.Keyboard.OnVirtualKeyMouseDown()
	if currentMouseKey and IsMouseButtonDown() then
		MusicianMIDI.Keyboard.OnVirtualKey(currentMouseKey, true)
	end
end

--- Virtual keyboard button mouse up handler
--
function MusicianMIDI.Keyboard.OnVirtualKeyMouseUp()
	if currentMouseKey and not(IsMouseButtonDown()) then
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

--- Virtual keyboard button on update
-- @param button (Button)
-- @param elapsed (number)
function MusicianMIDI.Keyboard.OnVirtualKeyUpdate(button, elapsed)
	button.volumeMeter:AddElapsed(elapsed)
	button.glowColor:SetAlpha(button.volumeMeter:GetLevel() * 1)
end

--- Set note event
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.SetNote(noteKey, down)

	-- Handle keyboard splitting
	local layer = LAYER.UPPER
	if MusicianMIDI.Keyboard.IsSplit() and noteKey < MusicianMIDI.Keyboard.GetSplitKey() then
		layer = LAYER.LOWER
	end

	-- Handle transposition
	noteKey = noteKey + transpose[layer]

	-- Send note event
	if down then
		Musician.Live.NoteOn(noteKey, layer, instrument[layer], false, MusicianMIDI.Keyboard)
	else
		Musician.Live.NoteOff(noteKey, layer, instrument[layer])
	end
end

--- Set piano key down on the virtual keyboard
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.SetVirtualKeyDown(noteKey, down)

	local button = MusicianMIDIKeyboard.pianoKeyButtons[noteKey]

	if not(button) then return end

	button.down = down

	local octaveKey = button.key % 12
	local texturePosition = 0

	-- Black key
	if octaveKey == 1 or octaveKey == 3 or octaveKey == 6 or octaveKey == 8 or octaveKey == 10 then
		if down then
			texturePosition = 5
		else
			texturePosition = 6
		end
		button.texture:SetTexCoord(.125 * texturePosition + .0078, .125 * texturePosition + .125, 0, .625)
	else -- White key
		local hasBlackLeft = not(button.isFirst) and (octaveKey == 2 or octaveKey == 4 or octaveKey == 7 or octaveKey == 11)
		local hasBlackRight = not(button.isLast) and (octaveKey == 0 or octaveKey == 2 or octaveKey == 5 or octaveKey == 7 or octaveKey == 9)

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
		button.texture:SetTexCoord(.125 * texturePosition + 0, .125 * texturePosition + .125, 0, .625)
	end
end

--- Enable or disable split keyboard mode
-- @param isSplit (boolean)
function MusicianMIDI.Keyboard.SetSplit(isSplit)
	splitMode = isSplit
	local frame = MusicianMIDIKeyboard

	frame.splitButton:SetChecked(isSplit)
	Musician.Live.AllNotesOff()
	Musician.Live.SetSustain(false, LAYER.UPPER)
	Musician.Live.SetSustain(false, LAYER.LOWER)
	if isSplit then
		MSA_DropDownMenu_EnableDropDown(frame.lowerInstrumentDropdown)
		MSA_DropDownMenu_EnableDropDown(frame.lowerTransposeDropdown)
		frame.lowerLabel:SetFontObject(GameFontHighlight)
		frame.splitKeyEditBox:SetText(Musician.Sampler.NoteName(MusicianMIDI.Keyboard.GetSplitKey()))
		frame.splitKeyEditBox:Enable()
	else
		MSA_DropDownMenu_DisableDropDown(frame.lowerInstrumentDropdown)
		MSA_DropDownMenu_DisableDropDown(frame.lowerTransposeDropdown)
		frame.lowerLabel:SetFontObject(GameFontDisable)
		frame.splitKeyEditBox:SetText('--')
		frame.splitKeyEditBox:Disable()
	end
	refreshPianoKeyboardColors()
end

--- Indicates whenever the keyboard is in split mode
-- @return isSplit (boolean)
function MusicianMIDI.Keyboard.IsSplit()
	return splitMode
end

--- Set keyboard split key
-- @param key (int)
function MusicianMIDI.Keyboard.SetSplitKey(key)
	splitKey = key
	if MusicianMIDI.Keyboard.IsSplit() then
		Musician.Live.AllNotesOff()
		refreshPianoKeyboardColors()
		Musician.Live.SetSustain(false, LAYER.UPPER)
		Musician.Live.SetSustain(false, LAYER.LOWER)
		MusicianMIDIKeyboard.splitKeyEditBox:SetText(Musician.Sampler.NoteName(key))
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

--- OnLiveNoteOn
-- @param event (string)
-- @param key (number)
-- @param layer (number)
-- @param instrumentData (table)
-- @param isChordNote (boolean)
-- @param source (table)
function MusicianMIDI.Keyboard.OnLiveNoteOn(event, key, layer, instrumentData, isChordNote, source)
	if source ~= MusicianMIDI.Keyboard or instrumentData == nil then return end

	if transpose[layer] then
		key = key - transpose[layer]
	end

	local button = MusicianMIDIKeyboard.pianoKeyButtons[key]

	if not(button) then
		return
	end

	button.volumeMeter:NoteOn(instrumentData)
	button.volumeMeter.gain = isChordNote and .5 or 1 -- Make auto-chord notes dimmer
	button.volumeMeter.entropy = button.volumeMeter.entropy / 2
end

--- OnLiveNoteOff
-- @param event (string)
-- @param key (number)
-- @param layer (number)
-- @param isChordNote (boolean)
-- @param source (table)
function MusicianMIDI.Keyboard.OnLiveNoteOff(event, key, layer, isChordNote, source)
	if source ~= MusicianMIDI.Keyboard then return end

	if transpose[layer] then
		key = key - transpose[layer]
	end

	local button = MusicianMIDIKeyboard.pianoKeyButtons[key]

	if not(button) then
		return
	end

	button.volumeMeter:NoteOff()
end

--- Set sustain
-- @param value (boolean)
function MusicianMIDI.Keyboard.SetSustain(value)
	-- Always sustain upper only if not in split mode
	if not(MusicianMIDI.Keyboard.IsSplit()) then
		Musician.Live.SetSustain(value, LAYER.UPPER)
		return
	end

	-- Determine if lower and upper instruments are "plucked" like piano, guitar etc.
	local upperInstrumentName = Musician.Sampler.GetInstrumentName(instrument[LAYER.UPPER])
	local lowerInstrumentName = Musician.Sampler.GetInstrumentName(instrument[LAYER.LOWER])
	local upperIsPlucked = instrument[LAYER.UPPER] >= 128 or Musician.INSTRUMENTS[upperInstrumentName] and Musician.INSTRUMENTS[upperInstrumentName].isPlucked or false
	local lowerIsPlucked = instrument[LAYER.LOWER] >= 128 or Musician.INSTRUMENTS[lowerInstrumentName] and Musician.INSTRUMENTS[lowerInstrumentName].isPlucked or false

	-- Do not sustain the non-plucked instrument if the other one is plucked
	if upperIsPlucked ~= lowerIsPlucked then
		Musician.Live.SetSustain(value and upperIsPlucked, LAYER.UPPER)
		Musician.Live.SetSustain(value and lowerIsPlucked, LAYER.LOWER)
	else
		-- Both instruments are either plucked or not: sustain both
		Musician.Live.SetSustain(value, LAYER.UPPER)
		Musician.Live.SetSustain(value, LAYER.LOWER)
	end
end