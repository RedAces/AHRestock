local ADDON_NAME = ...

-- Each page is its own panel with its own tab in the auction house side bar.
-- A page's sections are stacked top to bottom; `beside` places a section to the
-- right of the previous one. Each row is a list of items: a plain itemID, or a
-- { Q1, Q2 } pair for items with crafting qualities, of which only the quality
-- picked in the panel's top-left switch is shown; { itemID, badge = ... } is a
-- single item with a badge. An item table's `badge` is a short text drawn in the
-- icon's bottom edge; its `icon` is a texture fileID shown instead of the
-- item's own icon. A row's `heading` is a small caption above it.
local CONSUMABLES = {
	{
		title = "Flasks",
		rows = {
			-- Shattered Sun, Blood Knights, Magisters, Thalassian Resistance
			{ items = {
				{ 241327, 241326, badge = "C" }, { 241325, 241324, badge = "H" },
				{ 241323, 241322, badge = "M" }, { 241321, 241320, badge = "V" },
			} },
		},
	},
	{
		title = "Weapon Oils",
		rows = {
			-- Thalassian Phoenix Oil, Oil of Dawn (healers)
			{ items = { { 243733, 243734, badge = "CH" }, { 243735, 243736 } } },
		},
	},
	{
		title = "Food primary stats",
		rows = {
			-- Royal Roast, Impossibly Royal Roast (Hearty Royal Roast is bind on pickup)
			{ items = { { 242275, badge = "P" }, { 255847, badge = "P" } } },
		},
	},
	{
		title = "Food secondary stats",
		beside = true,
		rows = {
			-- Champion's Bento (highest secondary stat), Arcano Cutlets, Sun-Seared Lumifin, Fel-Kissed Filet,
			-- Warped Wise Wings, Void-Kissed Fish Rolls
			{ items = { 242274, { 242287, badge = "C" }, { 242283, badge = "C" }, { 242286, badge = "H" }, { 242285, badge = "M" }, { 242284, badge = "V" } } },
		},
	},
	{
		title = "Feasts primary stats",
		rows = {
			-- Harandar Celebration, Silvermoon Parade
			{ items = { { 255846, badge = "P" }, { 255845, badge = "P" } } },
		},
	},
	{
		title = "Feasts secondary stats",
		beside = true,
		rows = {
			-- Highest secondary stat: Blooming Feast, Quel'dorei Medley, and from 12.1
			-- Amani Cornucopia, Loa's Gathering, Feast of Knowledge
			{ items = { 242273, 242272, 275264, 275265, 275266 } },
		},
	},
	{
		title = "Pots",
		rows = {
			-- Recklessness, Light's Potential, Draught of Rampant Abandon, Liquid Luster,
			-- Lightfused Mana Potion, Potion of Devoured Dreams
			{ items = {
				{ 241289, 241288 }, { 241309, 241308, badge = "P" }, { 241293, 241292, badge = "P" }, { 271886, 271887, badge = "V" }, { 241301, 241300 }, { 241295, 241294 },
			} },
			-- Silvermoon Health Potion, Concentrated Silvermoon Health Potion
			{ items = {
				{ 241305, 241304 }, { 271883, 271884 },
			} },
		},
	},
	{
		title = "Other",
		rows = {
			-- Emergency Soul Link, Void-Touched Drums, Auto-Hammer, Inky Black Potion, Void-Touched Augment Rune,
			-- Void-Shrouded Tincture (invisibility)
			{ items = { { 248486, 269586 }, { 244639, badge = "H" }, 132514, 124640, { 259085, badge = "P" }, { 241303, 241302 } } },
		},
	},
	{
		-- Flawless gems as a grid: columns = main stat (gem color), rows = second
		-- stat, both in flask order (Crit, Haste, Mastery, Versatility); the
		-- diagonal holds the single-stat gems. Badges name the higher (main) stat
		-- first, then the lower one.
		title = "Gems",
		rows = {
			--                         Garnet                           Peridot                          Amethyst                         Lapis
			{ items = { { 240903, 240904, badge = "C" },  { 240889, 240890, badge = "HC" }, { 240897, 240898, badge = "MC" }, { 240913, 240914, badge = "VC" } } }, -- Deadly
			{ items = { { 240905, 240906, badge = "CH" }, { 240887, 240888, badge = "H" },  { 240899, 240900, badge = "MH" }, { 240915, 240916, badge = "VH" } } }, -- Quick
			{ items = { { 240907, 240908, badge = "CM" }, { 240891, 240892, badge = "HM" }, { 240895, 240896, badge = "M" },  { 240917, 240918, badge = "VM" } } }, -- Masterful
			{ items = { { 240909, 240910, badge = "CV" }, { 240893, 240894, badge = "HV" }, { 240901, 240902, badge = "MV" }, { 240911, 240912, badge = "V" } } },  -- Versatile
			-- Eversong Diamonds: Indecipherable (primary stat only), Powerful (+crit
			-- effectiveness), Stoic (+armor), Telluric (+max mana)
			{ heading = "Diamonds", items = {
				{ 240982, 240983, badge = "P" }, { 240966, 240967, badge = "C%" },{ 240970, 240971 }, { 240968, 240969 },
			} },
		},
	},
}

-- Stat icons for the tertiary stat enchants, whose own icons all look alike:
-- Sprint (Speed), Drain Life (Leech), Feint (Avoidance).
local SPEED_ICON, LEECH_ICON, AVOIDANCE_ICON = 132307, 136169, 132294

local ENCHANTS = {
	{
		-- No section title: the page title already says "Enchants".
		rows = {
			-- Empowered Blessing of Speed, Empowered Hex of Leeching, Empowered Rune of Avoidance
			{ heading = "Helms", items = {
				{ 243980, 243981, badge = "S", icon = SPEED_ICON }, { 243950, 243951, badge = "L", icon = LEECH_ICON },
				{ 244006, 244007, badge = "A", icon = AVOIDANCE_ICON },
			} },
			-- Akil'zon's Swiftness, Silvermoon's Mending, Amirdrassil's Grace
			{ heading = "Shoulders", items = {
				{ 243962, 243963, badge = "S", icon = SPEED_ICON }, { 244020, 244021, badge = "L", icon = LEECH_ICON },
				{ 243990, 243991, badge = "A", icon = AVOIDANCE_ICON },
			} },
			-- Mark of Nalorakk (Str), Mark of the Magister (Int), Mark of the Rootwarden (Agi),
			-- Mark of the Worldsoul (primary stat)
			{ heading = "Chests", items = { { 243946, 243947, badge = "Str" }, { 244002, 244003, badge = "Int" }, { 243974, 243975, badge = "Agi" },{ 243976, 243977, badge = "P" } } },
			-- Forest Hunter's Armor Kit (Agi/Str + Stamina), Blood Knight's Armor Kit (Agi/Str + Armor),
			-- Sunfire Silk Spellthread (Int + Stamina), Arcanoweave Spellthread (Int + max Mana)
			{ heading = "Legs", items = {
				{ 244640, 244641, badge = "Agi\nStr" }, { 244642, 244643, badge = "Agi\nStr" },
				{ 240094, 240133, badge = "Int" }, { 240154, 240155, badge = "Int" },
			} },
			-- Farstrider's Hunt, Shaladrassil's Roots, Lynx's Dexterity
			{ heading = "Boots", items = {
				{ 244008, 244009, badge = "S", icon = SPEED_ICON }, { 243982, 243983, badge = "L", icon = LEECH_ICON },
				{ 243952, 243953, badge = "A", icon = AVOIDANCE_ICON },
			} },
			-- Nature's Fury, Silvermoon's Alacrity, Zul'jin's Mastery, Silvermoon's Tenacity,
			-- Eyes of the Eagle (critical strike effectiveness)
			{ heading = "Rings", items = {
				{ 243986, 243987, badge = "C" }, { 244014, 244015, badge = "H" }, { 243958, 243959, badge = "M" },
				{ 244016, 244017, badge = "V" }, { 243956, 243957, badge = "C%" },
			} },
			-- Stat procs: Jan'alai's Precision, Berserker's Rage, Arcane Mastery, Worldsoul Tenacity,
			-- Acuity of the Ren'dorei (primary stat), Rite of the Hash'ey (random secondary)
			{ heading = "Weapons", items = {
				{ 243970, 243971, badge = "C" }, { 243972, 243973, badge = "H" }, { 244030, 244031, badge = "M" },
				{ 244000, 244001, badge = "V" }, { 244028, 244029, badge = "P" }, { 273071, 273072 },
			} },
			-- Flames of the Sin'dorei, Strength of Halazzi, Worldsoul Aegis, Worldsoul Cradle
			{ items = { { 244026, 244027 }, { 243968, 243969 }, { 243998, 243999 }, { 243996, 243997 } } },
		},
	},
}

local CRAFTING = {
	{
		-- No section title; each heading names the embellishment group.
		rows = {
			-- Grouped by the gear they can go on.
			-- Blessed Pango Charm, Adorned Fang, Prismatic Focusing Iris, Stabilizing Gemstone Bandolier
			-- (doubles Jewelcrafting embellishments), Lucky Keychain (recrafting with it removes the embellishment)
			{ heading = "Embellishments: Most equipment", items = {
				{ 244603, 244604 }, { 273068, 273069 }, { 251487, 251488 }, { 251489, 251490 }, 248130,
			} },
			-- Devouring Banding, Primal Spore Binding
			{ heading = "Embellishments: Weapons and armor", items = { { 244674, 244675 }, { 244607, 244608 } } },
			-- Arcanoweave Lining, Sunfire Silk Lining, Snakeskin Lining
			{ heading = "Embellishments: Armor", items = { { 240166, 240167 }, { 240164, 240165 }, { 270898, 270899 } } },
			-- Darkmoon Sigils: Blood, Hunt, Rot, Void
			{ heading = "Embellishments: Weapons and offhands", items = { { 245871, 245872 }, { 245875, 245876 }, { 245877, 245878 }, { 245873, 245874 } } },
			-- Hunter's Ritual Stone
			{ heading = "Embellishments: Blacksmithing weapons", items = { { 273059, 273060 } } },
			-- Polished Ammolite
			{ heading = "Embellishments: Accessories", items = { { 273065, 273066 } } },
			-- Coiled Snake-Eye
			{ heading = "Embellishments: Guns", items = { { 273062, 273063 } } },
		},
	},
	{
		-- Thalassian missives as a triangle grid in flask order: rows = second stat
		-- (H, M, V), columns = first stat (C, H, M).
		title = "Missives",
		rows = {
			-- Fireflash
			{ items = { { 245785, 245786, badge = "CH" } } },
			-- Peerless, Feverflare
			{ items = { { 245789, 245790, badge = "CM" }, { 245783, 245784, badge = "HM" } } },
			-- Quickblade, Aurora, Harmonious
			{ items = { { 245791, 245792, badge = "CV" }, { 245781, 245782, badge = "HV" }, { 245787, 245788, badge = "MV" } } },
		},
	},
}

-- `icon` is the itemID whose icon the side bar tab shows.
local PAGES = {
	{ key = "consumables", title = "Consumables", icon = 241326, sections = CONSUMABLES, smallHeaders = true },
	{ key = "enchants", title = "Enchants", icon = 243981, sections = ENCHANTS },
	{ key = "crafting", title = "Crafting", icon = 245786, sections = CRAFTING, smallHeaders = true },
}

local ICON_SIZE = 36
local ICON_GAP = 6
local PADDING = 12
local GROUP_GAP = 16
local BADGE_FONT = "Interface\\AddOns\\EllesmereUI\\media\\fonts\\Expressway Bold.ttf"

-- Buttons showing a { Q1, Q2 } pair and the quality checkboxes of all pages.
local pairButtons, qualityChecks = {}, {}

local function QualityAtlas(quality)
	if not quality then return end
	for _, fmt in ipairs({ "Professions-Icon-Quality-12-Tier%d-Small", "Professions-Icon-Quality-Tier%d-Small" }) do
		local atlas = fmt:format(quality)
		if C_Texture.GetAtlasInfo(atlas) then
			return atlas
		end
	end
end

-- Open the default UI's buy view for this item; the player then enters a
-- quantity (or picks an auction) and confirms the purchase as usual.
local keyInfoWaiter = CreateFrame("Frame")

local function OpenBuyView(itemID)
	local ahf = AuctionHouseFrame
	if not ahf or not ahf:IsShown() then
		print("|cff33ff99AHRestock|r: Open the auction house to buy items.")
		return
	end
	local itemKey = C_AuctionHouse.MakeItemKey(itemID)
	local info = C_AuctionHouse.GetItemKeyInfo(itemKey)
	if not info then
		-- Commodity or not decides which buy view to open; retry once the
		-- item key info has arrived.
		keyInfoWaiter.itemID = itemID
		keyInfoWaiter:RegisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED")
		return
	end
	if info.isCommodity then
		ahf:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesBuy)
		ahf.CommoditiesBuyFrame:SetItemIDAndPrice(itemID, 0)
	else
		ahf:SelectBrowseResult({ itemKey = itemKey, minPrice = 0, totalQuantity = 0 })
	end
	-- Opening the buy view alone does not query the server; the view fills in
	-- once the search results arrive.
	local sorts = { { sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false } }
	C_AuctionHouse.SendSearchQuery(itemKey, sorts, not info.isCommodity)
end

keyInfoWaiter:SetScript("OnEvent", function(self, _, itemID)
	if itemID ~= self.itemID then return end
	self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED")
	self.itemID = nil
	OpenBuyView(itemID)
end)

local function ItemButton_OnClick(self)
	local link = select(2, C_Item.GetItemInfo(self.itemID))
	if link and HandleModifiedItemClick(link) then return end
	OpenBuyView(self.itemID)
end

local function ItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetItemByID(self.itemID)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Click: buy at the auction house", 0.4, 0.8, 1)
	GameTooltip:Show()
end

local function SetButtonItem(b, itemID, quality)
	b.itemID = itemID
	b.icon:SetTexture(b.iconOverride or C_Item.GetItemIconByID(itemID) or 134400)

	local atlas = QualityAtlas(quality)
	if atlas then
		b.quality:SetAtlas(atlas)
		b.quality:SetSize(22, 22)
	end
	b.quality:SetShown(atlas ~= nil)

	-- Icon may not be cached on first login; refresh once the item data arrives.
	Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
		if b.itemID == itemID and not b.iconOverride then
			b.icon:SetTexture(C_Item.GetItemIconByID(itemID))
		end
	end)
end

local function CreateItemButton(parent, item)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(ICON_SIZE, ICON_SIZE)

	-- Flat 1px black border with the icon zoomed in 15%, like EllesmereUI's icons.
	local border = b:CreateTexture(nil, "BACKGROUND")
	border:SetAllPoints()
	border:SetColorTexture(0, 0, 0, 1)
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetPoint("TOPLEFT", 1, -1)
	b.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	b.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
	b.quality = b:CreateTexture(nil, "OVERLAY")
	b.quality:SetPoint("TOPLEFT", -1, 1)

	b:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
	local highlight = b:GetHighlightTexture()
	highlight:SetVertexColor(1, 1, 1, 0.15)
	highlight:SetAllPoints(b.icon)
	b:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
	local pushed = b:GetPushedTexture()
	pushed:SetVertexColor(0, 0, 0, 0.3)
	pushed:SetAllPoints(b.icon)

	b:SetScript("OnClick", ItemButton_OnClick)
	b:SetScript("OnEnter", ItemButton_OnEnter)
	b:SetScript("OnLeave", GameTooltip_Hide)

	if type(item) == "table" then
		b.iconOverride = item.icon
		-- { itemID, badge = ... } has a badge but no qualities.
		if item[2] then
			b.pair = item
			table.insert(pairButtons, b)
			SetButtonItem(b, item[AHRestockDB.quality], AHRestockDB.quality)
		else
			SetButtonItem(b, item[1])
		end
		if item.badge then
			local badge = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
			-- SetFont fails if EllesmereUI (and its font) is not installed; the
			-- template font stays then. Two-line badges get a smaller font so
			-- they don't cover the whole icon.
			local twoLines = item.badge:find("\n") ~= nil
			if not badge:SetFont(BADGE_FONT, twoLines and 10 or 14, "THICKOUTLINE") then
				local font, size = badge:GetFont()
				badge:SetFont(font, twoLines and size * 0.75 or size, "THICKOUTLINE")
			end			badge:SetPoint("BOTTOM", 0, 2)
			badge:SetText(item.badge)
		end
	else
		SetButtonItem(b, item)
	end
	return b
end

local function ApplyQuality()
	local q = AHRestockDB.quality
	for _, check in ipairs(qualityChecks) do
		check:SetChecked(check.quality == q)
	end
	for _, b in ipairs(pairButtons) do
		SetButtonItem(b, b.pair[q], q)
	end
end

-- Q1/Q2 checkboxes in the panel's top-left corner. They behave like radio
-- buttons and switch every { Q1, Q2 } item on all pages. Returns the width used.
local function CreateQualitySwitch(panel)
	local anchor
	for q = 1, 2 do
		local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
		check:SetSize(22, 22)
		if anchor then
			check:SetPoint("LEFT", anchor, "RIGHT", 2, 0)
		else
			check:SetPoint("TOPLEFT", PADDING - 4, -PADDING + 4)
		end
		check.quality = q
		check:SetScript("OnClick", function()
			AHRestockDB.quality = q
			ApplyQuality()
		end)
		local atlas = QualityAtlas(q)
		local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		label:SetPoint("LEFT", check, "RIGHT", 0, 0)
		label:SetText(atlas and CreateAtlasMarkup(atlas, 24, 24) or ("Q" .. q))
		table.insert(qualityChecks, check)
		anchor = label
	end
	return 2 * (22 + 24 + 2)
end

local function BuildPanel(page, index)
	local panel = CreateFrame("Frame", "AHRestockPanel" .. index, UIParent, "BackdropTemplate")
	page.panel = panel
	panel:Hide()
	panel:SetClampedToScreen(true)
	panel:SetMovable(true)
	panel:RegisterForDrag("LeftButton")
	-- Only the standalone window (opened via slash command) can be dragged.
	panel:SetScript("OnDragStart", function(self)
		if self.standalone then self:StartMoving() end
	end)
	panel:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relPoint, px, py = self:GetPoint()
		AHRestockDB.pos = { point, relPoint, px, py }
	end)
	panel.CloseButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	panel.CloseButton:SetPoint("TOPRIGHT", 0, 0)
	panel.CloseButton:Hide()
	panel:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	panel:SetBackdropColor(0.05, 0.05, 0.05, 0.92)
	panel:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

	local switchWidth = CreateQualitySwitch(panel)
	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", PADDING + switchWidth + 12, -PADDING)
	title:SetText("AHRestock: " .. page.title)
	-- Room for switch, title and the standalone close button.
	local right = PADDING + switchWidth + 12 + title:GetStringWidth() + 24

	local x, y = 0, -PADDING - 28
	local top, bottom = y, y
	for _, section in ipairs(page.sections) do
		-- `beside` sections start at the same height, right of the previous one.
		local headerX
		if section.beside then
			x, y = x + GROUP_GAP, top
			headerX = x
		else
			x, y = PADDING, bottom
			top = y
			headerX = PADDING
		end

		-- Right edge of this section's texts, so a `beside` neighbour starts after
		-- a title that is wider than the icons below it.
		local textRight = x

		-- `smallHeaders` pages use the small yellow row-heading look for section
		-- titles; a section without a title gets no header line.
		if section.title then
			local header = panel:CreateFontString(nil, "OVERLAY", page.smallHeaders and "GameFontNormalSmall" or "GameFontHighlight")
			header:SetPoint("TOPLEFT", headerX, y)
			header:SetText(section.title)
			textRight = math.max(textRight, headerX + header:GetStringWidth())
			y = y - (page.smallHeaders and 14 or 20)
		end

		local count = 0
		for _, row in ipairs(section.rows) do
			if row.heading then
				local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				heading:SetPoint("TOPLEFT", x, y)
				heading:SetText(row.heading)
				textRight = math.max(textRight, x + heading:GetStringWidth())
				y = y - 14
			end

			for i, item in ipairs(row.items) do
				if item then
					local b = CreateItemButton(panel, item)
					b:SetPoint("TOPLEFT", x + (i - 1) * (ICON_SIZE + ICON_GAP), y)
				end
			end
			count = math.max(count, #row.items)
			y = y - ICON_SIZE - ICON_GAP
		end
		y = y - 6
		x = math.max(x + count * ICON_SIZE + (count - 1) * ICON_GAP, textRight)
		right = math.max(right, x)
		bottom = math.min(bottom, y)
	end
	panel:SetWidth(right + PADDING)
	panel:SetHeight(-bottom + PADDING - ICON_GAP)
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

-- The quest log tab template resets its icon to its own atlas on SetChecked,
-- so the texture is re-applied every time (AllTheThings does the same).
local function SetTabChecked(page, checked)
	page.tab:SetChecked(checked)
	page.tab.Icon:SetTexture(C_Item.GetItemIconByID(page.icon) or 134400)
	page.tab.Icon:SetSize(24, 24)
end

local function AttachToAuctionHouse(panel)
	panel.standalone = false
	panel:SetParent(AuctionHouseFrame)
	panel:ClearAllPoints()
	panel:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", 2, 0)
	panel.CloseButton:Hide()
end

local function ShowStandalone(page)
	for _, other in ipairs(PAGES) do
		if other ~= page then other.panel:Hide() end
	end
	local panel = page.panel
	panel.standalone = true
	panel:SetParent(UIParent)
	panel:SetFrameStrata("HIGH")
	panel:ClearAllPoints()
	local pos = AHRestockDB.pos
	if pos then
		panel:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
	else
		panel:SetPoint("CENTER")
	end
	panel.CloseButton:Show()
	panel:Show()
end

local function SetPageShown(page, shown)
	local sideBar = GetSideBar()
	if shown then
		AttachToAuctionHouse(page.panel)
		local other = sideBar.Tabs[sideBar.selTab]
		if other and other ~= page.tab then
			-- Let the open tab (another addon's or another page's) close itself first.
			other:GetScript("OnMouseUp")(other)
		end
		sideBar.selTab = page.tab.tabIndex
		AnchorSideBar(page.panel)
	elseif sideBar.selTab == page.tab.tabIndex then
		sideBar.selTab = 0
		AnchorSideBar(AuctionHouseFrame)
	end
	page.panel:SetShown(shown)
	SetTabChecked(page, shown)
end

local function OnTabClicked(page)
	local shown = not page.panel:IsShown()
	SetPageShown(page, shown)
	AHRestockDB.openPage = shown and page.key or nil
end

local function CreateTab(sideBar, page)
	local function onClick() OnTabClicked(page) end
	local ok, tab = pcall(CreateFrame, "Frame", nil, sideBar, "QuestLogTabButtonTemplate")
	if ok and tab.SetCustomOnMouseUpHandler then
		if QuestLogDisplayMode then
			tab.displayMode = QuestLogDisplayMode.Quests
		end
		tab.tooltipText = "AHRestock: " .. page.title
		tab:SetCustomOnMouseUpHandler(onClick)
	else
		-- Fallback if the quest log tab template is unavailable.
		tab = CreateFrame("Button", nil, sideBar)
		tab:SetSize(32, 32)
		tab.Icon = tab:CreateTexture(nil, "ARTWORK")
		tab.Icon:SetPoint("CENTER")
		tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		tab.SetChecked = nop
		tab:SetScript("OnMouseUp", onClick)
	end
	return tab
end

local function FindPage(key)
	for _, page in ipairs(PAGES) do
		if page.key == key then return page end
	end
end

-- Register the tabs after other addons have added theirs on the same show, so
-- AllTheThings keeps tab index 1, which it assumes for itself.
local function OnAuctionHouseShown()
	local sideBar = GetSideBar()
	for _, page in ipairs(PAGES) do
		if not page.tab then
			page.tab = CreateTab(sideBar, page)
			table.insert(sideBar.Tabs, page.tab)
			page.tab.tabIndex = #sideBar.Tabs
			page.tab:SetPoint("TOPLEFT", sideBar, "TOPRIGHT", -2, TAB_OFFSET_Y - (page.tab.tabIndex - 1) * TAB_SPACING)
		end
	end

	-- A standalone window that is open when the auction house opens docks to it.
	local wanted = FindPage(AHRestockDB.openPage)
	for _, page in ipairs(PAGES) do
		if page.panel.standalone and page.panel:IsShown() then
			wanted = page
		end
	end
	if wanted and sideBar.selTab ~= 0 and sideBar.selTab ~= wanted.tab.tabIndex then
		wanted = nil -- another addon's tab is open
	end
	for _, page in ipairs(PAGES) do
		if page ~= wanted then SetPageShown(page, false) end
	end
	if wanted then SetPageShown(wanted, true) end
end

local function Setup()
	AuctionHouseFrame:HookScript("OnShow", function()
		C_Timer.After(0, OnAuctionHouseShown)
	end)
	if AuctionHouseFrame:IsShown() then
		C_Timer.After(0, OnAuctionHouseShown)
	end
end

EventUtil.ContinueOnAddOnLoaded(ADDON_NAME, function()
	local db = AHRestockDB or {}
	AHRestockDB = db
	-- Older versions kept one `expanded` flag (the only page) and a quality per section.
	if db.expanded ~= nil then
		db.openPage = db.expanded and "consumables" or nil
		db.expanded = nil
	end
	if type(db.quality) ~= "number" then
		db.quality = 2
	end
	for i, page in ipairs(PAGES) do
		BuildPanel(page, i)
	end
	-- Optional EllesmereUI look; does nothing without EllesmereUI or when the
	-- user turned third-party skinning off for this addon.
	if EllesmereUI and EllesmereUI.RegisterSkin then
		EllesmereUI.RegisterSkin(ADDON_NAME, function(S)
			for _, page in ipairs(PAGES) do
				local panel = page.panel
				S.Shell(panel, { noTopBar = true })
				S.CloseButton(panel.CloseButton)
				for _, region in ipairs({ panel:GetRegions() }) do
					if region:GetObjectType() == "FontString" then
						S.Font(region)
					end
				end
			end
			for _, check in ipairs(qualityChecks) do
				S.Checkbox(check)
			end
		end)
	end
	ApplyQuality()
	EventUtil.ContinueOnAddOnLoaded("Blizzard_AuctionHouseUI", Setup)
end)

-- /restock [page] toggles a page (by name prefix or number; default: the open one,
-- else the first): docked tab while the auction house is open, otherwise a
-- free-floating window.
SLASH_AHRESTOCK1 = "/restock"
SLASH_AHRESTOCK2 = "/ahr"
SlashCmdList.AHRESTOCK = function(msg)
	msg = strtrim(msg or ""):lower()
	local page
	if msg ~= "" then
		page = PAGES[tonumber(msg)]
		for _, p in ipairs(PAGES) do
			if not page and p.key:sub(1, #msg) == msg then page = p end
		end
		if not page then
			print("|cff33ff99AHRestock|r: Unknown page. Available: consumables, enchants, crafting")
			return
		end
	else
		for _, p in ipairs(PAGES) do
			if not page and p.panel:IsVisible() then page = p end
		end
		page = page or PAGES[1]
	end

	if AuctionHouseFrame and AuctionHouseFrame:IsShown() and page.tab then
		OnTabClicked(page)
	elseif page.panel:IsVisible() then
		page.panel:Hide()
	else
		ShowStandalone(page)
	end
end
