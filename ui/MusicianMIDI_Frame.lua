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
	local sourceButton = MusicianKeyboardLiveModeButton
	local button = MusicianMIDI_FrameLiveModeButton

	button.icon:SetText(sourceButton.icon:GetText())
	button:SetText(sourceButton:GetText())
	button.tooltipText = sourceButton.tooltipText
	button:SetEnabled(sourceButton:IsEnabled())
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
	MusicianMIDI_Frame:SetScript("OnKeyDown", MusicianMIDI.Frame.OnKeyDown)

	-- Init controls
	initLiveModeButton()
	initBandSyncButton()
end

--- OnKeyDown
-- @param event (string)
-- @param keyValue (string)
MusicianMIDI.Frame.OnKeyDown = function(event, keyValue)
	local used = false

	-- Close window
	if keyValue == 'ESCAPE' and down then
		MusicianMIDI_Frame:Hide()
		used = true

	-- MIDI message nibble
	elseif MusicianMIDI.KEY_NIBBLES[keyValue] then
		MusicianMIDI.readNibble(tonumber(MusicianMIDI.KEY_NIBBLES[keyValue], 16))
		used = true
	end

	-- Default: propagate
	MusicianMIDI_Frame:SetPropagateKeyboardInput(not(used))
end