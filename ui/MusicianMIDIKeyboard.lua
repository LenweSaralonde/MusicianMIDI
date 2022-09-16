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

local KEY_TEXTURE_SLICE_WIDTH = 8 / 128
local KEY_TEXTURE_SLICE_HEIGHT = 80 / 128
local KEY_GLOW_TEXTURE_SLICE_WIDTH = 16 / 128
local KEY_GLOW_TEXTURE_SLICE_HEIGHT = 96 / 128
local KEY_TEXTURE_PIXEL = .5 / 128
local KEY_TEXTURE_SLICES = {
	WhiteUpLeft = { 0, 1 * KEY_TEXTURE_SLICE_WIDTH },
	WhiteUpRight = { 1 * KEY_TEXTURE_SLICE_WIDTH, 2 * KEY_TEXTURE_SLICE_WIDTH },
	WhiteDownFullLeft = { 2 * KEY_TEXTURE_SLICE_WIDTH, 3 * KEY_TEXTURE_SLICE_WIDTH },
	WhiteDownFullRight = { 3 * KEY_TEXTURE_SLICE_WIDTH, 4 * KEY_TEXTURE_SLICE_WIDTH },
	WhiteDownBlackLeft = { 4 * KEY_TEXTURE_SLICE_WIDTH, 5 * KEY_TEXTURE_SLICE_WIDTH },
	WhiteDownBlackRight = { 5 * KEY_TEXTURE_SLICE_WIDTH, 6 * KEY_TEXTURE_SLICE_WIDTH },
	BlackUpLeft = { 6 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL, 7 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL },
	BlackUpRight = { 7 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL, 8 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL },
	BlackDownLeft = { 8 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL, 9 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL },
	BlackDownRight = { 9 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL, 10 * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_PIXEL },
	WhiteGlowFullLeft = { 7 * KEY_GLOW_TEXTURE_SLICE_WIDTH, 6 * KEY_GLOW_TEXTURE_SLICE_WIDTH },
	WhiteGlowFullRight = { 6 * KEY_GLOW_TEXTURE_SLICE_WIDTH, 7 * KEY_GLOW_TEXTURE_SLICE_WIDTH },
	WhiteGlowBlackLeft = { 5 * KEY_GLOW_TEXTURE_SLICE_WIDTH, 6 * KEY_GLOW_TEXTURE_SLICE_WIDTH },
	WhiteGlowBlackRight = { 6 * KEY_GLOW_TEXTURE_SLICE_WIDTH, 5 * KEY_GLOW_TEXTURE_SLICE_WIDTH },
	BlackGlowLeft = { 7 * KEY_GLOW_TEXTURE_SLICE_WIDTH, 8 * KEY_GLOW_TEXTURE_SLICE_WIDTH },
	BlackGlowRight = { 8 * KEY_GLOW_TEXTURE_SLICE_WIDTH, 7 * KEY_GLOW_TEXTURE_SLICE_WIDTH },
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

	transposeSelector.OnClick = function(self, arg1)
		transposeSelector.SetIndex(arg1)
	end

	transposeSelector.GetItems = function()
		local info = MSA_DropDownMenu_CreateInfo()
		info.func = transposeSelector.OnClick

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
	local container = frame.pianoKeys
	local glowFrame = frame.pianoKeysGlow

	-- Raise key glow frame above the container
	glowFrame:SetFrameLevel(container:GetFrameLevel() + 10)

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

			-- No black key between E-F and B-C
			if octaveKey == 4 or octaveKey == 11 then
				x = x + w
			else
				x = x + w / 2
			end

			button.isFirst = key == from
			button.isLast = key == to
			button.isBlack = octaveKey == 1 or octaveKey == 3 or octaveKey == 6 or octaveKey == 8 or octaveKey == 10
			button.hasBlackLeft = not(button.isFirst) and (octaveKey == 2 or octaveKey == 4 or octaveKey == 7 or octaveKey == 9 or octaveKey == 11)
			button.hasBlackRight = not(button.isLast) and (octaveKey == 0 or octaveKey == 2 or octaveKey == 5 or octaveKey == 7 or octaveKey == 9)

			local glowSliceLeft, glowSliceRight

			-- Black key
			if button.isBlack then
				-- Only a part of the black key is clickable
				button:SetHitRectInsets(0.2 * w, 0.2 * w, 0, .42 * h)

				-- Resize color texture to clickable area
				button.color:SetSize(10, 46)
				button.highlight:SetSize(0.6 * w, .58 * h)
				button.highlight:SetPoint('TOP', -2, -6)

				-- Set glow texture slices
				glowSliceLeft = KEY_TEXTURE_SLICES.BlackGlowLeft
				glowSliceRight = KEY_TEXTURE_SLICES.BlackGlowRight
			else -- White key
				-- The whole key is clickable
				button:SetHitRectInsets(0, 0, 0, 0)

				-- Resize color texture clickable area
				button.color:SetSize(16, 80)
				button.highlight:SetSize(w, h)
				button.highlight:SetPoint('TOP', 0, -10)

				-- Set glow texture slices
				glowSliceLeft = button.hasBlackLeft and KEY_TEXTURE_SLICES.WhiteGlowBlackLeft or KEY_TEXTURE_SLICES.WhiteGlowFullLeft
				glowSliceRight = button.hasBlackRight and KEY_TEXTURE_SLICES.WhiteGlowBlackRight or KEY_TEXTURE_SLICES.WhiteGlowFullRight
			end

			-- Set black keys on top of the white ones
			button:SetFrameLevel(button:GetParent():GetFrameLevel() + (button.isBlack and 2 or 1))

			-- Apply glow texture slicing
			button.glowLeft:SetTexCoord(glowSliceLeft[1], glowSliceLeft[2], 0, KEY_GLOW_TEXTURE_SLICE_HEIGHT)
			button.glowRight:SetTexCoord(glowSliceRight[1], glowSliceRight[2], 0, KEY_GLOW_TEXTURE_SLICE_HEIGHT)

			-- Attach glow textures to the glow frame
			button.glowLeft:SetParent(glowFrame)
			button.glowRight:SetParent(glowFrame)

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
			button.glowLeft:SetAlpha(0)
			button.glowRight:SetAlpha(0)
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
	for _, key in pairs(MusicianMIDI.KEY_BINDINGS) do
		local button = CreateFrame('Button', nil, container, 'MusicianMIDIPianoKeyTemplate')
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
	-- Set title
	MusicianMIDIKeyboardTitle:SetText(MusicianMIDI.Msg.MIDI_KEYBOARD_TITLE)

	-- Upper instrument selector
	MusicianMIDIKeyboard.upperLabel:SetText(Musician.Msg.LAYERS[Musician.KEYBOARD_LAYER.UPPER])
	MSA_DropDownMenu_SetWidth(MusicianMIDIKeyboardUpperInstrument, 165)

	-- Lower instrument selector
	MusicianMIDIKeyboard.lowerLabel:SetText(Musician.Msg.LAYERS[Musician.KEYBOARD_LAYER.LOWER])
	MSA_DropDownMenu_SetWidth(MusicianMIDIKeyboardLowerInstrument, 165)

	-- Upper transpose selector
	MSA_DropDownMenu_SetWidth(MusicianMIDIKeyboardUpperTranspose, 40)

	-- Lower transpose selector
	MSA_DropDownMenu_SetWidth(MusicianMIDIKeyboardLowerTranspose, 40)

	-- Live play button
	MusicianMIDIKeyboardLiveModeButton:SetText(Musician.Msg.LIVE_MODE)
	MusicianMIDIKeyboardLiveModeButton.led:SetVertexColor(.33, 1, 0, 1)

	-- Band sync play button
	MusicianMIDIKeyboardBandSyncButton.count:SetPoint("CENTER", MusicianMIDIKeyboardBandSyncButton, "TOPRIGHT", -4, -4)
	MusicianMIDIKeyboardBandSyncButton.tooltipText = Musician.Msg.LIVE_SYNC
	MusicianMIDIKeyboardBandSyncButton:HookScript("OnClick", function()
		Musician.Live.ToggleBandSyncMode()
	end)

	-- Split button
	MusicianMIDIKeyboardSplitButton:SetText(MusicianMIDI.Msg.SPLIT_KEYBOARD)
	MusicianMIDIKeyboardSplitButton.led:SetVertexColor(.33, 1, 0, 1)
	MusicianMIDIKeyboardSplitButton.SetChecked = function(self, checked)
		self.checked = checked
		if checked then
			self.led:SetAlpha(1)
		else
			self.led:SetAlpha(0)
		end
	end
	MusicianMIDIKeyboardSplitButton.GetChecked = function(self)
		return self.checked
	end
	MusicianMIDIKeyboardSplitButton:HookScript("OnClick", function(self)
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
		local isSplit = not(MusicianMIDI.Keyboard.IsSplit())
		MusicianMIDI.Keyboard.SetSplit(isSplit)
		self:SetChecked(isSplit)
	end)

	-- Split point edit box
	MusicianMIDIKeyboardSplitKeyEditBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	MusicianMIDIKeyboardSplitKeyEditBox:SetScript("OnEditFocusGained", function(self)
		self.isSettingSplitPoint = true
		self:HighlightText(0)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip_SetTitle(GameTooltip, MusicianMIDI.Msg.SET_SPLIT_KEY_HINT)
	end)
	MusicianMIDIKeyboardSplitKeyEditBox:SetScript("OnEditFocusLost", function(self)
		C_Timer.After(0, function() self.isSettingSplitPoint = false end)
		GameTooltip:Hide()
		self:SetText(Musician.Sampler.NoteName(MusicianMIDI.Keyboard.GetSplitKey()))
		self:HighlightText(0, 0)
	end)
	MusicianMIDIKeyboardSplitKeyEditBox:SetScript("OnKeyDown", function(self, key)
		self.isSettingSplitPoint = false
		MusicianMIDI.Keyboard.SetSplitKeyFromKeyboard(key)
		self:ClearFocus()
	end)

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

	-- Stop all notes and remove sustain when closing the window
	MusicianMIDIKeyboard:HookScript("OnHide", function()
		MusicianMIDI.Keyboard.ResetAllKeys()
		Musician.Live.SetSustain(false, Musician.KEYBOARD_LAYER.LOWER)
		Musician.Live.SetSustain(false, Musician.KEYBOARD_LAYER.UPPER)
		Musician.Live.AllNotesOff()
	end)
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

	-- Only process key if there is no active modifier
	if not(IsModifierKeyDown()) then
		-- Sustain (pedal)
		if keyValue == 'SPACE' then
			MusicianMIDI.Keyboard.SetSustain(down)
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
	button.glowLeft:SetAlpha(button.volumeMeter:GetLevel())
	button.glowRight:SetAlpha(button.volumeMeter:GetLevel())
end

--- Reset all the keyboard keys
--
function MusicianMIDI.Keyboard.ResetAllKeys()
	currentMouseKey = nil
	wipe(keyboardKeysDown)
	wipe(mouseKeysDown)
	for _, button in pairs(MusicianMIDIKeyboard.pianoKeyButtons) do
		MusicianMIDI.Keyboard.SetVirtualKeyDown(button.key, false)
		-- Reset volume meter glow
		button.volumeMeter:Reset()
		button.glowLeft:SetAlpha(0)
		button.glowRight:SetAlpha(0)
	end
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

	local sliceLeft, sliceRight
	if button.isBlack then
		sliceLeft = down and KEY_TEXTURE_SLICES.BlackDownLeft or KEY_TEXTURE_SLICES.BlackUpLeft
		sliceRight = down and KEY_TEXTURE_SLICES.BlackDownRight or KEY_TEXTURE_SLICES.BlackUpRight
	else
		if down then
			sliceLeft = button.hasBlackLeft and KEY_TEXTURE_SLICES.WhiteDownBlackLeft or KEY_TEXTURE_SLICES.WhiteDownFullLeft
			sliceRight = button.hasBlackRight and KEY_TEXTURE_SLICES.WhiteDownBlackRight or KEY_TEXTURE_SLICES.WhiteDownFullRight
		else
			sliceLeft = KEY_TEXTURE_SLICES.WhiteUpLeft
			sliceRight = KEY_TEXTURE_SLICES.WhiteUpRight
		end
	end

	button.textureLeft:SetTexCoord(sliceLeft[1], sliceLeft[2], 0, KEY_TEXTURE_SLICE_HEIGHT)
	button.textureRight:SetTexCoord(sliceRight[1], sliceRight[2], 0, KEY_TEXTURE_SLICE_HEIGHT)
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

	local keyboardKey = key
	if transpose[layer] then
		keyboardKey = keyboardKey - transpose[layer]
	end

	local button = MusicianMIDIKeyboard.pianoKeyButtons[keyboardKey]

	if not(button) then
		return
	end

	button.volumeMeter:NoteOn(instrumentData, key)
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
	local upperIsPlucked = Musician.Sampler.IsInstrumentPlucked(instrument[LAYER.UPPER])
	local lowerIsPlucked = Musician.Sampler.IsInstrumentPlucked(instrument[LAYER.LOWER])

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

-- Widget templates
--

--- Piano key template OnLoad
--
function MusicianMIDIPianoKeyTemplate_OnLoad(self)
	self.key = 0
	self.isFirst = false
	self.isLast = true
	self.down = false
	self:SetScript("OnShow", function()
		MusicianMIDI.Keyboard.SetVirtualKeyDown(self, self.down)
	end)
end