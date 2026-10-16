local ADDON_NAME = ...

-- Sections shown in the panel. Each row is a list of itemIDs; `quality` (optional)
-- draws the crafting quality marker at the start of the row and on each icon.
local SECTIONS = {
	{
		title = "Flasks",
		rows = {
			-- Crit (Shattered Sun), Haste (Blood Knights), Mastery (Magisters), Versatility (Thalassian Resistance)
			{ quality = 1, items = { 241327, 241325, 241323, 241321 } },
			{ quality = 2, items = { 241326, 241324, 241322, 241320 } },
		},
	},
	{
		title = "Food",
		rows = {
			-- Royal Roast, Impossibly Royal Roast, Blooming Feast, Harandar Celebration
			{ items = { 242275, 255847, 242273, 255846 } },
		},
	},
	{
		title = "Pots",
		rows = {
			-- Recklessness, Light's Potential, Liquid Luster, Lightfused Mana Potion,
			-- Silvermoon Health Potion, Concentrated Silvermoon Health Potion
			{ quality = 1, items = { 241289, 241309, 271886, 241301, 241305, 271883 } },
			{ quality = 2, items = { 241288, 241308, 271887, 241300, 241304, 271884 } },
		},
	},
}

local ICON_SIZE = 36
local ICON_GAP = 6
local PADDING = 12
local QUALITY_COL = 22
local maxIcons = 0
for _, section in ipairs(SECTIONS) do
	for _, row in ipairs(section.rows) do
		maxIcons = math.max(maxIcons, #row.items)
	end
end
local PANEL_WIDTH = PADDING * 2 + QUALITY_COL + maxIcons * ICON_SIZE + (maxIcons - 1) * ICON_GAP

local panel, toggle

local function QualityAtlas(quality)
	if not quality then return end
	for _, fmt in ipairs({ "Professions-Icon-Quality-12-Tier%d-Small", "Professions-Icon-Quality-Tier%d-Small" }) do
		local atlas = fmt:format(quality)
		if C_Texture.GetAtlasInfo(atlas) then
			return atlas
		end
	end
end

-- Open the default UI's commodity buy view for this item; the player then enters
-- a quantity and confirms with "Buy Now" as usual.
local function OpenBuyView(itemID)
	local ahf = AuctionHouseFrame
	if not ahf or not ahf:IsShown() then return end
	local itemKey = C_AuctionHouse.MakeItemKey(itemID)
	local info = C_AuctionHouse.GetItemKeyInfo(itemKey)
	if info and not info.isCommodity then
		ahf:SelectBrowseResult({ itemKey = itemKey, minPrice = 0, totalQuantity = 0 })
	else
		ahf:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesBuy)
		ahf.CommoditiesBuyFrame:SetItemIDAndPrice(itemID, 0)
	end
	-- Opening the buy view alone does not query the server; the view fills in
	-- once the search results arrive.
	local sorts = { { sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false } }
	C_AuctionHouse.SendSearchQuery(itemKey, sorts, (info and not info.isCommodity) or false)
end

local function ItemButton_OnClick(self)
	local link = select(2, C_Item.GetItemInfo(self.itemID))
	if link and HandleModifiedItemClick(link) then return end
	OpenBuyView(self.itemID)
end

local function ItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetItemByID(self.itemID)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Klick: im Auktionshaus kaufen", 0.4, 0.8, 1)
	GameTooltip:Show()
end

local function CreateItemButton(parent, itemID, quality)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(ICON_SIZE, ICON_SIZE)
	b.itemID = itemID

	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetAllPoints()
	b.icon:SetTexture(C_Item.GetItemIconByID(itemID) or 134400)

	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")

	local atlas = QualityAtlas(quality)
	if atlas then
		b.quality = b:CreateTexture(nil, "OVERLAY")
		b.quality:SetAtlas(atlas, true)
		b.quality:SetPoint("TOPLEFT", -2, 2)
	end

	b:SetScript("OnClick", ItemButton_OnClick)
	b:SetScript("OnEnter", ItemButton_OnEnter)
	b:SetScript("OnLeave", GameTooltip_Hide)

	-- Icon may not be cached on first login; refresh once the item data arrives.
	Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
		b.icon:SetTexture(C_Item.GetItemIconByID(itemID))
	end)
	return b
end

local function BuildPanel(ahf)
	panel = CreateFrame("Frame", "AuctionQuickLookPanel", ahf, "BackdropTemplate")
	panel:SetPoint("TOPLEFT", ahf, "TOPRIGHT", 2, 0)
	panel:SetWidth(PANEL_WIDTH)
	panel:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	panel:SetBackdropColor(0.05, 0.05, 0.05, 0.92)
	panel:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -PADDING)
	title:SetText("AuctionQuickLook")

	local y = -PADDING - 28
	for _, section in ipairs(SECTIONS) do
		local header = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		header:SetPoint("TOPLEFT", PADDING, y)
		header:SetText(section.title)
		y = y - 20

		for _, row in ipairs(section.rows) do
			if row.quality then
				local atlas = QualityAtlas(row.quality)
				local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				label:SetPoint("TOPLEFT", PADDING, y - (ICON_SIZE - 12) / 2)
				label:SetText(atlas and CreateAtlasMarkup(atlas, 18, 18) or ("Q" .. row.quality))
			end

			for i, itemID in ipairs(row.items) do
				local b = CreateItemButton(panel, itemID, row.quality)
				b:SetPoint("TOPLEFT", PADDING + QUALITY_COL + (i - 1) * (ICON_SIZE + ICON_GAP), y)
			end
			y = y - ICON_SIZE - ICON_GAP
		end
		y = y - 6
	end
	panel:SetHeight(-y + PADDING - ICON_GAP)
end

local TAB_OFFSET_Y = -52
local TAB_SPACING = 52

-- Shared addon tab bar on the right edge of the auction house, the convention
-- AllTheThings uses: sideBar.Tabs lists the tab buttons, sideBar.selTab is the
-- index of the open one (0 = none), and the bar is re-anchored to the right of
-- whichever panel is open so the tabs stay reachable.
local function GetSideBar()
	if not AuctionHouseFrameTabSideBar then
		local sideBar = CreateFrame("Frame", nil, AuctionHouseFrame)
		sideBar:SetWidth(1)
		sideBar:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT")
		sideBar:SetPoint("BOTTOMLEFT", AuctionHouseFrame, "BOTTOMRIGHT")
		sideBar.Tabs = {}
		sideBar.selTab = 0
		AuctionHouseFrameTabSideBar = sideBar
	end
	return AuctionHouseFrameTabSideBar
end

local function AnchorSideBar(anchor)
	local sideBar = GetSideBar()
	sideBar:ClearAllPoints()
	sideBar:SetPoint("TOPLEFT", anchor, "TOPRIGHT")
	sideBar:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT")
end

local function SetExpanded(expanded)
	local sideBar = GetSideBar()
	if expanded then
		local other = sideBar.Tabs[sideBar.selTab]
		if other and other ~= toggle then
			-- Let the other addon close its own panel first.
			other:GetScript("OnMouseUp")(other)
		end
		sideBar.selTab = toggle.tabIndex
		AnchorSideBar(panel)
	elseif sideBar.selTab == toggle.tabIndex then
		sideBar.selTab = 0
		AnchorSideBar(AuctionHouseFrame)
	end
	panel:SetShown(expanded)
	toggle:SetChecked(expanded)
end

local function OnTabClicked()
	AuctionQuickLookDB.expanded = not panel:IsShown()
	SetExpanded(AuctionQuickLookDB.expanded)
end

local function CreateTab(sideBar)
	local ok, tab = pcall(CreateFrame, "Frame", nil, sideBar, "QuestLogTabButtonTemplate")
	if ok and tab.SetCustomOnMouseUpHandler then
		if QuestLogDisplayMode then
			tab.displayMode = QuestLogDisplayMode.Quests
		end
		tab.tooltipText = "AuctionQuickLook"
		tab:SetCustomOnMouseUpHandler(OnTabClicked)
	else
		-- Fallback if the quest log tab template is unavailable.
		tab = CreateFrame("Button", nil, sideBar)
		tab:SetSize(32, 32)
		tab.Icon = tab:CreateTexture(nil, "ARTWORK")
		tab.Icon:SetPoint("CENTER")
		tab:SetHighlightTexture("Interface\Buttons\ButtonHilight-Square", "ADD")
		tab.SetChecked = nop
		tab:SetScript("OnMouseUp", OnTabClicked)
	end
	tab.Icon:SetTexture(C_Item.GetItemIconByID(241326) or 134400)
	tab.Icon:SetSize(24, 24)
	return tab
end

-- Register the tab after other addons have added theirs on the same show, so
-- AllTheThings keeps tab index 1, which it assumes for itself.
local function OnAuctionHouseShown()
	local sideBar = GetSideBar()
	if not toggle then
		toggle = CreateTab(sideBar)
		table.insert(sideBar.Tabs, toggle)
		toggle.tabIndex = #sideBar.Tabs
		toggle:SetPoint("TOPLEFT", sideBar, "TOPRIGHT", -2, TAB_OFFSET_Y - (toggle.tabIndex - 1) * TAB_SPACING)
	end
	SetExpanded(AuctionQuickLookDB.expanded and (sideBar.selTab == 0 or sideBar.selTab == toggle.tabIndex))
end

local function Setup()
	BuildPanel(AuctionHouseFrame)
	panel:Hide()
	AuctionHouseFrame:HookScript("OnShow", function()
		C_Timer.After(0, OnAuctionHouseShown)
	end)
	if AuctionHouseFrame:IsShown() then
		C_Timer.After(0, OnAuctionHouseShown)
	end
end

EventUtil.ContinueOnAddOnLoaded(ADDON_NAME, function()
	AuctionQuickLookDB = AuctionQuickLookDB or { expanded = false }
	EventUtil.ContinueOnAddOnLoaded("Blizzard_AuctionHouseUI", Setup)
end)
