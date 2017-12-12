am = LibStub("AceAddon-3.0"):NewAddon("AddOnManager")

-- declare defaults to be used in the DB
local defaults = {
  profile = {
    PAddonTable = {}
  }
}

function am:OnInitialize()
  -- using ## SavedVariables: AddOnManagerDB
  self.db = LibStub("AceDB-3.0"):New("AddOnManagerDB")
  am:CreateAddonTable()
end

function am:OnEnable()
    self.db.profile.CharName = UnitName("player")
	self.db.profile.AddonTable = {}
end

local Addonmanager = select(2,...)

local bg = CreateFrame("Frame",nil,UIParent)
local content = CreateFrame("Frame", nil, scrollframe) 
local scrollframe = CreateFrame("ScrollFrame", nil, bg) 
local scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 

am.NumAddons = GetNumAddOns() 
am.NumActivatedAddons = 0

am.firststart = true
am.xval = 0
am.yval = 45
am.row = 0
am.isshown = false

am.Text = {}

am.AddonTable = {}

am.Text[1] = "|cff69ccf0AddOnManager >> Enable :  "
am.Text[2] = "|cff69ccf0AddOnManager << Disable :  "
am.Text[3] = " (Requires Reload)"
am.Text[4] = "Dependency: "
am.Text[5] = "Enable all"
am.Text[6] = "Disable all"
am.Text[7] = "Memory"
am.Text[8] = " Enabled, "
am.Text[9] = " Disabled"
am.Text[10] = " Hidden"
am.Text[11] = "|cff69ccf0Addon Manager : Cant do that while in combat, try again later"
am.Text[12] = "Yes"
am.Text[13] = "No"

function am:CreateAddonTable()
	for i = 1, am.NumAddons do
	local name, title, notes, enabled = GetAddOnInfo(i) 
	am.AddonTable[i] = {}
	am.AddonTable[i][0] = name
	am.AddonTable[i][1] = enabled
	end
end


function am:DrawGUI()

	local index = 0
	local pack = 0
	local default_y = 45
	local  max_size = false
	local blocks = 1
	
	content:SetSize(128, 128) 
	local texture = content:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0) 
	content.texture = texture 
	scrollframe.content = content
	scrollframe:SetScrollChild(content)

	for i = 1, am.NumAddons do
	
		local name = GetAddOnInfo(i) 
		
		if name ~= "addonmanager" then
		
			am:DrawLabels(i) 
			am:DrawCheckboxes(i) 
			index = index + 1
			
			if index < 12 then 
				
				am.yval  = am.yval  - 20
					
			elseif index ==12 then
				
				index = 0
				am.xval = am.xval + 200
				am.yval = default_y
				pack = pack + 1
				blocks = blocks + 1
					
				if pack == 5 then -- 5
					
					max_size = true
					am.xval = 0
					am.yval = am.yval - 247
					default_y = am.yval
					pack = 0
					am.row = am.row + 1
					
				end
			end
		end
end
		
		if max_size == false then
		
			bg:SetWidth(blocks*200) 
		
		elseif max_size == true then
		
			bg:SetWidth(5 *200) 
		
		end
		
		am:CreateSlider()
end
	
function am:DrawLabels(index)

	local aaa, title = GetAddOnInfo(index) 
	
	local fstring = content:CreateFontString("FSTRING", nil)
		fstring:SetParent(content)
		fstring:SetPoint("LEFT", content, "LEFT", am.xval + 50 , am.yval )
		fstring:SetFontObject("GameFontNormal")
		fstring:SetText(title)
		
end

function am:DrawCheckboxes(index)

	local name, title, notes, enabled,loadable = GetAddOnInfo(index) 
	local version = GetAddOnMetadata(name, "Version") 
	local author = GetAddOnMetadata(name, "Author") 
	local dep = GetAddOnDependencies(index or "name")
	local loadDemand = IsAddOnLoadOnDemand(index)
	
	
	local checkbutton = CreateFrame("CheckButton", index, content,"UICheckButtonTemplate");
		checkbutton:SetPoint("LEFT", content, "LEFT", am.xval, am.yval )
	
		if enabled == true then
			am.NumActivatedAddons = am.NumActivatedAddons + 1
			checkbutton:SetChecked("true") 
		end
		checkbutton:SetScript("OnClick",  function()
		local checked = checkbutton:GetChecked()

		 if checked == true then 
			  EnableAddOn(title) 

			 print(am.Text[1]..title..am.Text[3])
		 elseif checked  ~= true then
			  DisableAddOn(title)

			print(am.Text[2]..title..am.Text[3])
		  end
		  
	end);
	
	checkbutton:SetScript("OnEnter",   function()
	am:ShowAddonTooltip(title, notes, enabled, checkbutton, author, version, dep,loadDemand)
	end);
	
	checkbutton:SetScript("OnLeave",  function()
	GameTooltip:Hide()
	end);	
	
end

function am:DrawMainFrame()
	
	bg:SetClampedToScreen( true )
	bg:SetHeight(300) 
	bg:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	local bt = bg:CreateTexture(nil,"BACKGROUND")
	bt:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background.png")
	bt:SetAllPoints(bg)
	bg.texture = t

	bg:SetMovable(true)
	bg:EnableMouse(true)
	
	bg:SetScript("OnMouseDown", function(self, button)
	 if not self.isMoving then
		self:StartMoving();
	    self.isMoving = true;
	 end
	end)
	
	bg:SetScript("OnMouseUp", function(self, button)
	  if self.isMoving then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	  end
	end)
	
	bg:SetScript("OnHide", function(self)
	  if ( self.isMoving ) then
	   self:StopMovingOrSizing();
	   self.isMoving = false;
	  end
	end)
	
	  bg:EnableMouseWheel(true)
	  bg:SetScript("OnMouseWheel", function(self, delta)
      local current = scrollbar:GetValue()
	   
       if (delta < 0) and (current < 6000) then
			scrollbar:SetValue(current + 20)
       elseif (delta > 0) and (current > 1) then
			scrollbar:SetValue(current - 20)
       end
 end)
	
end

function am:ShowAddonTooltip(title, notes, enabled, owner, author, version, dep, lod)

	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT");
	
	if version ~= nil then
		GameTooltip:AddLine(title.." ("..version..")");
	else
		GameTooltip:AddLine(title);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(notes);

	if dep ~= nil then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(am.Text[4]..dep);
	end
	
	GameTooltip:AddLine(" ");
	if lod ~= false then
			GameTooltip:AddLine("|cff69ccf0Load on Demand : |r"..am.Text[12]);
	else
			GameTooltip:AddLine("|cff69ccf0Load on Demand : |r"..am.Text[13]);
	end

	
	if author ~=  nil then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("|cff69ccf0Author: "..author);
	end

	
		GameTooltip:Show();
		
end
	
function am:CreateFont(name, anchor, x, y, fontobject, direction, text)

		local font = bg:CreateFontString(name, nil, bg)
			font:SetPoint(anchor, bg, direction, x , y)
			font:SetFontObject(fontobject)
			font:SetText(text)
			
end

function am:CreateButton(name, anchor, x, y, text, func)

	local b = CreateFrame("Button", name, bg,"UIPanelButtonTemplate")
		b:SetPoint(anchor, x  , y)
		b:SetWidth(80)
		b:SetHeight(22)
		b:SetText(text)
		local block = {
			method = func
		}
		b:SetScript("OnClick",   function()
			block.method()
		end);
		
end

function am:CreateObjectButton(name, anchor, x, y, texture, width, height, func)

	local b = CreateFrame("Button", name, bg,"UIPanelCloseButton")
		b:SetPoint(anchor, x  , y)
		b:SetWidth(width)
		b:SetHeight(height)

		local ntex = b:CreateTexture()
		ntex:SetTexture(texture)
		ntex:SetAllPoints()	
		b:SetNormalTexture(ntex)
	
		local block = {
			method = func
		}
		b:SetScript("OnClick",   function()
			block.method()
		end);
		
end


function Hide()

		bg:Hide()
		GameMenuFrame:Show()
		am.isshown = false
		
end

function am:Toggle()

	if am.isshown  == true then
		Hide()
	else
		if am.firststart == true then

			am:DrawMainFrame()
			am:CreateFont(nil, "CENTER", 0, 158, "GameFontNormalLarge", "CENTER", "Addon Manager")
			am:CreateButton(nil, "CENTER", 0, -160, "ReloadUI",  ReloadUI)
			am:CreateButton(nil, "CENTER", 100, -160, am.Text[5],  EnableAllAddOns)
			am:CreateButton(nil, "CENTER", -100, -160, am.Text[6],  DisableAllAddOns)
			am:CreateObjectButton(nil, "TOPRIGHT", 6, 10, "Interface\\BUTTONS\\UI-Panel-MinimizeButton-Up.png", 32, 32,  Hide)
			am:CreateButton(nil, "LEFT",  0, -160, am.Text[7], GetMemoryUsage)
			am:CreateButton(nil, "LEFT",  80, -160, "Table", am.Debug)
			am:CreateButton(nil, "LEFT",  160, -160, "Save", am.Save)
			am:DrawGUI()
			am:CreateFont(nil, "CENTER", 0, 130, "GameFontNormal", "CENTER", am.NumAddons.." Addons ("..(am.NumActivatedAddons-1)..am.Text[8]..(am.NumAddons - am.NumActivatedAddons)..am.Text[9]..", 1 "..am.Text[10]..")")
			am.isshown = true
			am.firststart = false
		else
			bg:Show()
		end
	end
end

function GetMemoryUsage()

collectgarbage("collect")

	local memory = {nil}
	local addonname = {nil}
	local temp_memory = {nil}
	local temp_name = {nil}
	
	UpdateAddOnMemoryUsage()
	
	GameTooltip:SetOwner(bg, "ANCHOR_LEFT");
	local counter = 0
	
	for u = 1, am.NumAddons do
		local aaa, title, aaa, enabled = GetAddOnInfo(u) 
		if enabled == true then
			if GetAddOnMemoryUsage(u) ~= nil  then
				memory[counter] = GetAddOnMemoryUsage(u)
				addonname[counter] = title
				counter = counter + 1
			end
		end
	end
	local x = true
	local n = table.getn(memory) 
	while x == true do
		for i = 0, n - 1 do
			x = false
			if memory[i]  > memory[i+1] then
				temp_memory[i] = memory[i]
				temp_name[i] = addonname[i]
				memory[i] = memory[i+1]
				addonname[i] = addonname[i+1]
				memory[i+1] = temp_memory[i]
				addonname[i+1] = temp_name[i]
				x = true
			end
		end
		n = n - 1
	end
	GameTooltip:AddLine(am.Text[7])
	GameTooltip:AddLine(" ")
	local g_memory = 0
	for f = 0, table.getn(memory) do
		if math.ceil(memory[f]) < 1000 then
		GameTooltip:AddLine("|cff69ccf0("..(math.ceil(memory[f])).." KB)|r   "..addonname[f])
		else
		GameTooltip:AddLine("|cff69ccf0("..(math.ceil(memory[f])/1000).." MB)|r    "..addonname[f])
		end
		g_memory = g_memory + tonumber(memory[f])
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Total: "..(math.ceil(g_memory )/1000).." MB")
GameTooltip:Show()
end

function am:Debug()
	local asd = am.db:GetCurrentProfile()
	local tbl = {}
	am.db:GetProfiles(tbl)
	table.sort(tbl)
	print(#tbl)
	--print("Aktuell:" .. asd)
	--print (am.db.profile.Test)
	
	print(am.AddonTable[1][0])
	print(am.AddonTable[1][1])
end

function am:Save()
	am.db.profile.AddonTable = am.AddonTable
end

function am:CreateSlider()

	scrollframe:SetPoint("TOPLEFT", 0, -35) 
	scrollframe:SetPoint("BOTTOMRIGHT", -40, 10) 

	local texture = scrollframe:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0) 
	bg.scrollframe = scrollframe 

	scrollbar:SetPoint("TOPLEFT", bg, "TOPRIGHT", 4, -16) 
	scrollbar:SetPoint("BOTTOMLEFT", bg, "BOTTOMRIGHT", 4, 16) 
	scrollbar:SetMinMaxValues(0, am.row * 248) 
	scrollbar:SetValueStep(2) 
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0) 
	scrollbar:SetWidth(16) 

	scrollbar:SetScript("OnValueChanged", 
	function (self, value) 
	self:GetParent():SetVerticalScroll(value) 
	end) 

	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
	scrollbg:SetAllPoints(scrollbar) 
	scrollbg:SetTexture(0, 0, 0, 0.4) 
	bg.scrollbar = scrollbar 

end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN") 
frame:SetScript("OnEvent", function(self, event, ...)
end)

local e = CreateFrame("Button", nil, GameMenuFrame,"UIPanelButtonTemplate")
	e:SetPoint("BOTTOMLEFT", 25, -20)
	e:SetWidth(144)
	e:SetHeight(21)
	
	e:SetText("|CFFffffffAddon Manager")
	e:SetScript("OnClick",   function()
	if UnitAffectingCombat("player") ~= true then
	am:Toggle()
	GameMenuFrame:Hide()
	else
	print(am.Text[11])
	end
end);
