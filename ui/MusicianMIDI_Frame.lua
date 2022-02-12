--- Live MIDI keyboard window
-- @module MusicianMIDI.Frame

MusicianMIDI.Frame = LibStub("AceAddon-3.0"):NewAddon("MusicianMIDI.Frame", "AceEvent-3.0")

local MODULE_NAME = "MIDI"

local ICON = {
	["SOLO_MODE"] = Musician.Icons.Headphones,
	["LIVE_MODE"] = Musician.Icons.Speaker
}

--- Update texts and icons for live and solo modes
--
local function updateLiveModeButton()
	local button = MusicianMIDI_FrameLiveModeButton

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
	local button = MusicianMIDI_FrameLiveModeButton

	MusicianMIDI_FrameLiveModeButton:SetScript("OnClick", function()
		Musician.Live.EnableLive(not(Musician.Live.IsLiveEnabled()))
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	end)

	MusicianMIDI.Frame:RegisterMessage(Musician.Events.LiveModeChange, updateLiveModeButton)

	updateLiveModeButton()
end

--- Update texts and icons for band play
--
local function updateBandSyncButton()
	local sourceButton = MusicianKeyboardBandSyncButton
	local button = MusicianMIDI_FrameBandSyncButton
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
function MusicianMIDI.Frame.Init()
	MusicianMIDI.Frame.InitGamepadBindings()

	MusicianMIDI_Frame:EnableGamePadStick(true)
	MusicianMIDI_Frame:EnableGamePadButton(true)

	MusicianMIDI_Frame:SetScript("OnGamePadButtonDown", MusicianMIDI.Frame.OnGamePadButtonDown)

	-- Init controls
	initLiveModeButton()
	initBandSyncButton()
end


function MusicianMIDI.Frame.InitGamepadBindings()
	-- Clear all gamepad bindings for the frame
	local numBindings = GetNumBindings()
	for i = 1, numBindings do
		local command, category = GetBinding(i)
		local keys = { select(3, GetBinding(i)) }
		for _, key in pairs(keys) do
			if string.find(key, "PAD") ~= nil and string.find(key, "NUMPAD") == nil then
				SetOverrideBinding(MusicianMIDI_Frame, true, key, nil)
			end
		end
	end

	-- Disable gamepad cursor control
	SetGamePadCursorControl(false)

	-- Disabled gaamepad free look
	SetGamePadFreeLook(false)

	-- Disable directional pad
	local config = {
		configID = {}, -- TODO: set dynamic
		name = "MusicianMIDI",
		rawButtonMappings = {},
		rawAxisMappings = {},
		axisConfigs = {
			{ axis = "LStickY", scale = 0 },
			{ axis = "LStickX", scale = 0 }
		},
		stickConfigs = {},
	}
	C_GamePad.SetConfig(config)
	C_GamePad.ApplyConfigs()
end

function MusicianMIDI.Frame.ResetGamePadConfig()
	C_GamePad.DeleteConfig(C_GamePad.GetConfig({}))
	C_GamePad.ApplyConfigs()
end

local lastStatus
function MusicianMIDI.Frame.OnGamePadButtonDown(self, button)
	if button == 'PADDUP' then
		for _, deviceId in pairs(C_GamePad.GetAllDeviceIDs()) do
			if C_GamePad.GetDeviceRawState(deviceId).name == 'vJoy Device' then
				local newStatus = debugprofilestop()
				if lastStatus == nil then
					lastStatus = newStatus
				end
				local delta = newStatus - lastStatus
				lastStatus = newStatus

				local state = C_GamePad.GetDeviceRawState(deviceId)
				local axis1 = 128 + floor(state.rawAxes[1] * 128)
				local axis2 = 128 + floor(state.rawAxes[2] * 128)
				local axis3 = 128 + floor(state.rawAxes[3] * 128)
				print(axis1, axis2, axis3, delta)
				MusicianMIDI.processMIDIMessage(axis1, axis2, axis3)
				return
			end
		end
	end
end