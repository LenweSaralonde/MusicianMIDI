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

local KEY_WIDTH = 16
local KEY_HEIGHT = 80
local KEY_PADDING = 8
local KEY_GLOW_WIDTH = KEY_WIDTH + 2 * KEY_PADDING
local KEY_GLOW_HEIGHT = KEY_HEIGHT + 2 * KEY_PADDING
local KEY_TEXTURE_WIDTH = KEY_WIDTH / 256
local KEY_TEXTURE_HEIGHT = KEY_HEIGHT / 256
local KEY_TEXTURE_GLOW_WIDTH = KEY_GLOW_WIDTH / 256
local KEY_TEXTURE_GLOW_HEIGHT = KEY_GLOW_HEIGHT / 256
local KEY_TEXTURE_SLICE_WIDTH = KEY_TEXTURE_GLOW_WIDTH
local KEY_TEXTURE_SLICE_HEIGHT = KEY_TEXTURE_GLOW_HEIGHT
local KEY_TEXTURE_SLICE_PADDING = KEY_PADDING / 256
local KEY_TEXTURE_SLICES = {
	Black_Up = { 0, 1 },
	Black_Down = { 1, 0 },
	Black_Glow = { 1, 1 },
	White_Up = { 0, 0 },
	WhiteFull_Down = { 2, 0 },
	WhiteFull_Glow = { 2, 1 },
	WhiteCF_Down = { 3, 0 },
	WhiteCF_Glow = { 3, 1 },
	WhiteD_Down = { 4, 0 },
	WhiteD_Glow = { 4, 1 },
	WhiteEB_Down = { 5, 0 },
	WhiteEB_Glow = { 5, 1 },
	WhiteG_Down = { 6, 0 },
	WhiteG_Glow = { 6, 1 },
	WhiteA_Down = { 7, 0 },
	WhiteA_Glow = { 7, 1 },
}
local KEY_X_OFFSETS = {
	[1] = (3 - 7) / 16 / 2,
	[3] = (7 - 3) / 16 / 2,
	[6] = (3 - 7) / 16 / 2,
	[10] = (7 - 3) / 16 / 2,
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
	local transposeValues = { "+3", "+2", "+1", "0", "-1", "-2", "-3" }
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
			if not (octaveKey == 1 or octaveKey == 3 or octaveKey == 6 or octaveKey == 8 or octaveKey == 10) then
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
			local xOffset = KEY_X_OFFSETS[octaveKey] or 0 -- Offset for black keys
			button:SetPoint('TOPLEFT', x + xOffset * w, 0)

			-- No black key between E-F and B-C
			if octaveKey == 4 or octaveKey == 11 then
				x = x + w
			else
				x = x + w / 2
			end

			-- Determine key shape
			local keyUpShape = "White" -- Shape when key is up
			local keyDownShape -- Shape when key is down. Left part shape when the key needs to be split
			local keyDownShape2 -- Right part shape when key is down and needs to be split

			local isBlackKey = octaveKey == 1 or octaveKey == 3 or octaveKey == 6 or octaveKey == 8 or octaveKey == 10
			if isBlackKey then -- Black keys
				keyUpShape = "Black"
				keyDownShape = "Black"
			else -- White keys
				local isFirst = key == from
				local isLast = key == to

				if octaveKey == 0 then -- C
					keyDownShape = isLast and "WhiteFull" or "WhiteCF"
				elseif octaveKey == 2 then -- D
					if isFirst then
						keyDownShape = "WhiteFull"
						keyDownShape2 = "WhiteD"
					elseif isLast then
						keyDownShape = "WhiteD"
						keyDownShape2 = "WhiteFull"
					else
						keyDownShape = "WhiteD"
					end
				elseif octaveKey == 4 then -- E
					keyDownShape = isFirst and "WhiteFull" or "WhiteEB"
				elseif octaveKey == 5 then -- F
					keyDownShape = isLast and "WhiteFull" or "WhiteCF"
				elseif octaveKey == 7 then -- G
					if isFirst then
						keyDownShape = "WhiteFull"
						keyDownShape2 = "WhiteG"
					elseif isLast then
						keyDownShape = "WhiteG"
						keyDownShape2 = "WhiteFull"
					else
						keyDownShape = "WhiteG"
					end
				elseif octaveKey == 9 then -- A
					if isFirst then
						keyDownShape = "WhiteFull"
						keyDownShape2 = "WhiteA"
					elseif isLast then
						keyDownShape = "WhiteA"
						keyDownShape2 = "WhiteFull"
					else
						keyDownShape = "WhiteA"
					end
				elseif octaveKey == 11 then -- B
					keyDownShape = isFirst and "WhiteFull" or "WhiteEB"
				end
			end

			-- Set clickable area and color texture sizes
			if isBlackKey then -- Black key
				-- Only a part of the black key is clickable
				button:SetHitRectInsets(0.2 * w, 0.2 * w, 0, .42 * h)

				-- Resize color texture to clickable area
				button.color:SetSize(10, 46)
				button.highlight:SetSize(0.6 * w, .58 * h)
				button.highlight:SetPoint('TOP', -2, -6)
			else -- White key
				-- The whole key is clickable
				button:SetHitRectInsets(0, 0, 0, 0)

				-- Resize color texture clickable area
				button.color:SetSize(16, 80)
				button.highlight:SetSize(w, h)
				button.highlight:SetPoint('TOP', 0, -10)
			end

			-- Set black keys on top of the white ones
			button:SetFrameLevel(button:GetParent():GetFrameLevel() + (isBlackKey and 2 or 1))

			-- Calculate textures coordinates
			local sliceUp = KEY_TEXTURE_SLICES[keyUpShape .. '_Up']
			local upLeft = sliceUp[1] * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_SLICE_PADDING
			local upRight = upLeft + KEY_TEXTURE_WIDTH
			local upTop = sliceUp[2] * KEY_TEXTURE_SLICE_HEIGHT + KEY_TEXTURE_SLICE_PADDING
			local upBottom = upTop + KEY_TEXTURE_HEIGHT

			local sliceDown = KEY_TEXTURE_SLICES[keyDownShape .. '_Down']
			local downLeft = sliceDown[1] * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_SLICE_PADDING
			local downRight = downLeft + KEY_TEXTURE_WIDTH
			local downTop = sliceDown[2] * KEY_TEXTURE_SLICE_HEIGHT + KEY_TEXTURE_SLICE_PADDING
			local downBottom = downTop + KEY_TEXTURE_HEIGHT

			local sliceGlow = KEY_TEXTURE_SLICES[keyDownShape .. '_Glow']
			local glowLeft = sliceGlow[1] * KEY_TEXTURE_SLICE_WIDTH
			local glowRight = glowLeft + KEY_TEXTURE_GLOW_WIDTH
			local glowTop = sliceGlow[2] * KEY_TEXTURE_SLICE_HEIGHT
			local glowBottom = glowTop + KEY_TEXTURE_GLOW_HEIGHT

			-- The key has 2 "down" shapes
			if keyDownShape2 ~= nil then
				-- Split main and glow textures in 2 parts
				-- keyDownShape is for the left part and keyDownShape2 for the right part

				button.texture:ClearAllPoints()
				button.texture:SetPoint("RIGHT", button, "CENTER")
				button.texture:SetPoint("TOPLEFT", button, "TOPLEFT")
				button.texture:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT")

				button.texture2 = button:CreateTexture(nil, "BACKGROUND")
				button.texture2:SetTexture("Interface\\AddOns\\MusicianMIDI\\ui\\textures\\piano-keys")
				button.texture2:ClearAllPoints()
				button.texture2:SetPoint("LEFT", button, "CENTER")
				button.texture2:SetPoint("TOPRIGHT", button, "TOPRIGHT")
				button.texture2:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")

				button.glow:ClearAllPoints()
				button.glow:SetPoint("RIGHT", button, "CENTER")
				button.glow:SetPoint("TOPLEFT", button, "TOPLEFT", -6, 8)
				button.glow:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -6, -8)

				button.glow2 = button:CreateTexture(nil, "BACKGROUND")
				button.glow2:SetBlendMode("BLEND")
				button.glow2:SetAlpha(0)
				button.glow2:SetVertexColor(button.glow:GetVertexColor())
				button.glow2:SetTexture("Interface\\AddOns\\MusicianMIDI\\ui\\textures\\piano-keys")
				button.glow2:ClearAllPoints()
				button.glow2:SetPoint("LEFT", button, "CENTER", 0, 0)
				button.glow2:SetPoint("TOPRIGHT", button, "TOPRIGHT", 6, 8)
				button.glow2:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 6, -8)

				-- Calculate new textures coordinates
				upRight = upLeft + KEY_TEXTURE_WIDTH / 2
				downRight = downLeft + KEY_TEXTURE_WIDTH / 2
				glowRight = glowLeft + KEY_TEXTURE_GLOW_WIDTH / 2

				local sliceDown2 = KEY_TEXTURE_SLICES[keyDownShape2 .. '_Down']
				local downLeft2 = sliceDown2[1] * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_SLICE_PADDING + KEY_TEXTURE_WIDTH / 2
				local downRight2 = downLeft2 + KEY_TEXTURE_WIDTH / 2
				local downTop2 = sliceDown2[2] * KEY_TEXTURE_SLICE_HEIGHT + KEY_TEXTURE_SLICE_PADDING
				local downBottom2 = downTop2 + KEY_TEXTURE_HEIGHT

				local sliceGlow2 = KEY_TEXTURE_SLICES[keyDownShape2 .. '_Glow']
				local glowLeft2 = sliceGlow2[1] * KEY_TEXTURE_SLICE_WIDTH + KEY_TEXTURE_GLOW_WIDTH / 2
				local glowRight2 = glowLeft2 + KEY_TEXTURE_GLOW_WIDTH / 2
				local glowTop2 = sliceGlow2[2] * KEY_TEXTURE_SLICE_HEIGHT
				local glowBottom2 = glowTop2 + KEY_TEXTURE_GLOW_HEIGHT

				-- Set coordinates for the second (right) part
				button.texture2UpCoord = { upLeft + KEY_TEXTURE_WIDTH / 2, upRight + KEY_TEXTURE_WIDTH / 2, upTop, upBottom }
				button.texture2DownCoord = { downLeft2, downRight2, downTop2, downBottom2 }
				button.glow2:SetTexCoord(glowLeft2, glowRight2, glowTop2, glowBottom2)
				button.glow2:SetParent(glowFrame) -- Attach glow texture to the glow frame
			end

			button.textureUpCoord = { upLeft, upRight, upTop, upBottom }
			button.textureDownCoord = { downLeft, downRight, downTop, downBottom }
			button.glow:SetTexCoord(glowLeft, glowRight, glowTop, glowBottom)
			button.glow:SetParent(glowFrame) -- Attach glow texture to the glow frame

			-- Set texture status and show
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
			button.glow:SetAlpha(0)
			if button.glow2 then
				button.glow2:SetAlpha(0)
			end
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
		local isSplit = not MusicianMIDI.Keyboard.IsSplit()
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
	if not IsModifierKeyDown() then
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
	end

	-- Allow to use the MIDI keyboard toggle binding to close it
	if down and GetBindingFromClick(keyValue) == "MUSICIANMIDITOGGLE" then
		MusicianMIDIKeyboard:Toggle()
		return
	end
end

--- Key up/down handler, from MIDI piano keyboard
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.OnKeyboardKey(noteKey, down)
	local wasDown = keyboardKeysDown[noteKey] and not mouseKeysDown[noteKey]
	local wasUp = not keyboardKeysDown[noteKey] and not mouseKeysDown[noteKey]
	keyboardKeysDown[noteKey] = down and true or nil
	if not down and wasDown or down and wasUp then
		MusicianMIDI.Keyboard.SetNote(noteKey, down)
		MusicianMIDI.Keyboard.SetVirtualKeyDown(noteKey, down)
	end
end

--- Key up/down handler, from virtual piano keyboard
-- @param noteKey (int) MIDI key number
-- @param down (boolean)
function MusicianMIDI.Keyboard.OnVirtualKey(noteKey, down)
	local wasDown = not keyboardKeysDown[noteKey] and mouseKeysDown[noteKey]
	local wasUp = not keyboardKeysDown[noteKey] and not mouseKeysDown[noteKey]
	mouseKeysDown[noteKey] = down and true or nil
	if not down and wasDown or down and wasUp then
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
	if currentMouseKey and not IsMouseButtonDown() then
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
	local level = button.volumeMeter:GetLevel()
	button.glow:SetAlpha(level)
	if button.glow2 then
		button.glow2:SetAlpha(level)
	end
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
		button.glow:SetAlpha(0)
		if button.glow2 then
			button.glow2:SetAlpha(0)
		end
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

	if not button then return end

	button.down = down

	button.texture:SetTexCoord(unpack(down and button.textureDownCoord or button.textureUpCoord))
	if button.texture2 then
		button.texture2:SetTexCoord(unpack(down and button.texture2DownCoord or button.texture2UpCoord))
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

	local keyboardKey = key
	if transpose[layer] then
		keyboardKey = keyboardKey - transpose[layer]
	end

	local button = MusicianMIDIKeyboard.pianoKeyButtons[keyboardKey]

	if not button then
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

	if not button then
		return
	end

	button.volumeMeter:NoteOff()
end

--- Set sustain
-- @param value (boolean)
function MusicianMIDI.Keyboard.SetSustain(value)
	-- Always sustain upper only if not in split mode
	if not MusicianMIDI.Keyboard.IsSplit() then
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