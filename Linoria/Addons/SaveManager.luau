local HttpService 						= game:GetService"HttpService"
local RunService 						= game:GetService"RunService"
local Stats 							= game:GetService"Stats"

local SaveManager = {} do
	SaveManager.Folder 					= "Fondra/Games/Criminality"
	SaveManager.Ignore 					= {}
	SaveManager.Parser 					= {
		Toggle = {
			Save = function(Index, Object) 
				return { Type = "Toggle", Index = Index, Value = Object.Value } 
			end,
			
			Load = function(Index, Data)
				if Toggles[Index] then 
					Toggles[Index]:SetValue(Data.Value)
				end
			end
		},

		Slider = {
			Save = function(Index, Object)
				return { Type = "Slider", Index = Index, Value = tostring(Object.Value) }
			end,

			Load = function(Index, Data)
				if Options[Index] then 
					Options[Index]:SetValue(Data.Value)
				end
			end
		},

		Dropdown = {
			Save = function(Index, Object)
				return { Type = "Dropdown", Index = Index, Value = Object.Value, Multi = Object.Multi }
			end,

			Load = function(Index, Data)
				if Options[Index] then 
					Options[Index]:SetValue(Data.Value)
				end
			end
		},

		ColorPicker = {
			Save = function(Index, Object)
				return { Type = "ColorPicker", Index = Index, Value = Object.Value:ToHex(), Transparency = Object.Transparency }
			end,

			Load = function(Index, Data)
				if Options[Index] then
					Options[Index]:SetValueRGB(Color3.fromHex(Data.Value), Data.Transparency)
				end
			end
		},

		KeyPicker = {
			Save = function(Index, Object)
				return { Type = "KeyPicker", Index = Index, Mode = Object.Mode, Key = Object.Value }
			end,

			Load = function(Index, Data)
				if Options[Index] then 
					Options[Index]:SetValue({ Data.Key, Data.Mode })
				end
			end
		},

		Input = {
			Save = function(Index, Object)
				return { Type = "Input", Index = Index, Text = Object.Value }
			end,

			Load = function(Index, Data)
				if Options[Index] and type(Data.Text) == "string" then
					Options[Index]:SetValue(Data.Text)
				end
			end,
		}
	}

	function SaveManager:SetIgnoreIndexes(List)
		for _, Key in next, List do
			self.Ignore[Key] 			= true
		end
	end

	function SaveManager:SetFolder(Folder)
		self.Folder 					= Folder
		self:BuildFolderTree()
	end

	function SaveManager:DeleteConfig(Name)
		if Name == nil or Name == "" then return self.Library:Notify("[SaveManager]: Invalid Selection.", 3) end
		if not isfile(string.format("%s/%s.json", self.Folder, Name)) then return self.Library:Notify("[SaveManager]: Invalid file. [Does not exist]", 3) end
				
		delfile(string.format("%s/%s.json", self.Folder, Name))

		return self.Library:Notify(string.format("[SaveManager]: Deleted Config %q", Name), 3)
	end

	function SaveManager:SaveConfig(Name)
		if Name:gsub(" ", "") == "" then return self.Library:Notify("[SaveManager]: Invalid file name for config. [Empty]", 3) end
		if isfile(string.format("%s/%s.json", self.Folder, Name)) then return self.Library:Notify("[SaveManager]: Config already exists.", 3) end

		local Path 						= string.format("%s/%s.json", self.Folder, Name)
		local Data 						= { Objects = {} }

		for Index, Toggle in next, Toggles do
			if self.Ignore[Index] then continue end

			table.insert(Data.Objects, self.Parser[Toggle.Type].Save(Index, Toggle))
		end

		for Index, Option in next, Options do
			if not self.Parser[Option.Type] then continue end
			if self.Ignore[Index] then continue end

			table.insert(Data.Objects, self.Parser[Option.Type].Save(Index, Option))
		end	

		local Success, Encoded 			= pcall(HttpService.JSONEncode, HttpService, Data)
		
		if not Success then return self.Library:Notify("[SaveManager]: Failed to encode Data.", 3) end
		writefile(Path, Encoded)

		return self.Library:Notify(string.format("[SaveManager]: Saved Config %q", Name), 3)
	end

	function SaveManager:OverrideConfig(Name)
		if Name == nil or Name == "" then return self.Library:Notify("[SaveManager]: Invalid Selection.", 3) end
		if not isfile(string.format("%s/%s.json", self.Folder, Name)) then return self.Library:Notify("[SaveManager]: Config does not exist.", 3) end

		local Path 						= string.format("%s/%s.json", self.Folder, Name)
		local Data 						= { Objects = {} }

		for Index, Toggle in next, Toggles do
			if self.Ignore[Index] then continue end

			table.insert(Data.Objects, self.Parser[Toggle.Type].Save(Index, Toggle))
		end

		for Index, Option in next, Options do
			if not self.Parser[Option.Type] then continue end
			if self.Ignore[Index] then continue end

			table.insert(Data.Objects, self.Parser[Option.Type].Save(Index, Option))
		end	

		local Success, Encoded 			= pcall(HttpService.JSONEncode, HttpService, Data)
		
		if not Success then return self.Library:Notify("[SaveManager]: Failed to encode Data.", 3) end
		writefile(Path, Encoded)

		return self.Library:Notify(string.format("[SaveManager]: Overrided config %q", Name), 3)
	end

	function SaveManager:LoadConfig(Name, Button)
		if Name == nil or Name == "" then return self.Library:Notify("[SaveManager]: Invalid Selection.", 3) end
		
		local File 						= string.format("%s/%s.json", self.Folder, Name)

		if not isfile(File) then return self.Library:Notify("[SaveManager]: Invalid Invalid file. [Does not exist]", 3) end

		local Success, Decoded 			= pcall(HttpService.JSONDecode, HttpService, readfile(File))

		if not Success then return self.Library:Notify("[SaveManager]: Decode Error", 3) end

		for _, Option in next, Decoded.Objects do
			if self.Parser[Option.Type] then
				task.spawn(function() self.Parser[Option.Type].Load(Option.Index, Option) end)
			end
		end

		return Button and self.Library:Notify(string.format("Loaded Config %q", Name), 3) or nil
	end

	function SaveManager:SaveAutoLoad(Name)
		if Name == nil or Name == "" then return self.Library:Notify("[SaveManager]: Invalid Selection.", 3) end

		writefile(string.format("%s/AutoLoad.txt", self.Folder), Name)
		self.Library:Notify(string.format("[SaveManager]: Set default config to %q", Name), 3)
	end

	function SaveManager:RemoveAutoLoad()
		if not isfile(string.format("%s/AutoLoad.txt", self.Folder)) then return self.Library:Notify("[SaveManager]: There is no default config.", 3) end

		delfile(string.format("%s/AutoLoad.txt", self.Folder), Theme)
		self.Library:Notify("[SaveManager]: Removed the default config.", 3)
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
			"ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName",
		})
	end

	function SaveManager:BuildFolderTree()
		local Directorys 				= {}

		self.Folder:gsub("([^/]+)", function(Directory)
			table.insert(Directorys, Directory)
		end)

		for _, Directory in next, Directorys do
			local Directory             = table.concat(Directorys, "/", 1, _)

			if isfolder(Directory) then continue end

			makefolder(Directory)
		end
	end

	function SaveManager:RefreshConfigList()
		local List 						= listfiles(self.Folder)
		local Output			 		= {}

		for i = 1, #List do
			local File  				= List[i]

			if File:sub(-5) == ".json" then
				local Position 			= File:find(".json", 1, true)
				local Start 			= Position
				local Character 		= File:sub(Position, Position)

				while Character ~= "/" and Character ~= "\\" and Character ~= "" do
					Position 			= Position - 1
					Character 			= File:sub(Position, Position)
				end

				if Character == "/" or Character == "\\" then
					table.insert(Output, File:sub(Position + 1, Start - 1))
				end
			end
		end
		
		return Output
	end

	function SaveManager:SetLibrary(Library)
		self.Library 					= Library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(string.format("%s/AutoLoad.txt", self.Folder)) then
			self:LoadConfig(readfile(string.format("%s/AutoLoad.txt", self.Folder)))
		end
	end

	function SaveManager:BuildConfigSection(Tab)
		assert(self.Library, "Must set SaveManager.Library")

		local Menu = Tab:AddRightGroupbox("Fondra Settings") do
			Menu:AddToggle("FondraTelemetry", {
				Text                    = "Telemetry",
				Default                 = false
			})

			Menu:AddToggle("FondraKeybindUI", {
				Text                    = "Keybinds UI",
				Default                 = false
			})
		
			Menu:AddToggle("FondraMainUI", {
				Text                    = "Main UI",
				Default                 = true
			}):AddKeyPicker("FondraMainUIKey", {
				Default 				= "Insert",
				SyncToggleState 		= true,
				Mode 					= "Toggle",
			
				Text 					= "UI Toggle",
				NoUI 					= false,
			})

			Menu:AddDivider()

			Menu:AddToggle("FondraWatermarkUI", {
				Text                    = "Watermark UI",
				Default                 = false
			})

			Menu:AddDropdown("FondraWatermarkData", {
				Values                  = { "Version", "FPS", "Ping" }, 
				Default                 = 1,
				Multi                   = true,
				Text                    = "Watermark Data"
			})

			Menu:AddButton("Unload", function()
				Library:Unload()
			end)

			Menu:AddButton("Join Discord", function()
				request({
					Url             	= "http://127.0.0.1:6463/rpc?v=1",
					Method              = "POST",
	
					Headers = {
						["Content-Type"]= "application/json",
						["Origin"]      = "https://discord.com"
					},
	
					Body = HttpService:JSONEncode({
						cmd             = "INVITE_BROWSER",
						args            = { code = "PfXgy5Nq34" },
						nonce           = HttpService:GenerateGUID(false)
					}),
				})
			end)

			Toggles.FondraWatermarkUI:OnChanged(function(V)
				Library:SetWatermarkVisibility(V)
			end)

			Toggles.FondraMainUI:OnChanged(function(V)
				task.spawn(self.Library.Toggle)
			end)

			Toggles.FondraKeybindUI:OnChanged(function(V)
				self.Library.KeybindFrame.Visible = V
			end)
		end

		local Configuration = Tab:AddRightGroupbox("Configuration") do
			Configuration:AddInput("SaveManager_ConfigName", { Text = "Config name" })
			Configuration:AddDropdown("SaveManager_ConfigList", { Text = "Config list", Values = self:RefreshConfigList(), AllowNull = true })
	
			Configuration:AddDivider()
	
			Configuration:AddButton("Create config", function()
				self:SaveConfig(Options.SaveManager_ConfigName.Value)
	
				Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
				Options.SaveManager_ConfigList:SetValue(nil)
			end):AddButton("Delete config", function()
				self:DeleteConfig(Options.SaveManager_ConfigList.Value)
	
				Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
				Options.SaveManager_ConfigList:SetValue(nil)
			end)
	
			Configuration:AddButton("Load config", function()
				self:LoadConfig(Options.SaveManager_ConfigList.Value, true)
			end)
	
			Configuration:AddButton("Override config", function()
				self:OverrideConfig(Options.SaveManager_ConfigList.Value)
			end)
	
			Configuration:AddButton("Refresh list", function()
				Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
				Options.SaveManager_ConfigList:SetValue(nil)
	
				self.Library:Notify("[SaveManager]: Refreshed the list.")
			end)
	
			Configuration:AddButton("Save Autoload", function()
				self:SaveAutoLoad(Options.SaveManager_ConfigList.Value)
			end):AddButton("Remove Autoload", function()
				self:RemoveAutoLoad()
			end)
	
	
			if isfile(string.format("%s/AutoLoad.txt", self.Folder)) then
				local Name 					= readfile(string.format("%s/AutoLoad.txt", self.Folder))
				self:LoadConfig(Name, false)
			end
	
			SaveManager:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
		end
	end
end

local Cooldown = 0
RunService:BindToRenderStep("Watermark.lua", Enum.RenderPriority.Camera.Value + 1, function(Delta)
	if not getgenv().Toggles then return end
	if not getgenv().Toggles.FondraWatermarkUI then return end
	if not getgenv().Toggles.FondraWatermarkUI.Value then return end
    if (tick() - Cooldown) <= 1 then return end

    Cooldown         						= tick()

	local Original 							= {}
    local List                         		= {}
    local Result                        	= { "Fondra V4" }

	if not Options then return end
	if not Options.FondraWatermarkData then return end

	for Index, Name in next, Options.FondraWatermarkData:GetActiveValues() do
		table.insert(Original, Name)
	end

	for Index, Value in next, Original do
        List[#Original + 1 - Index] 		= Value
    end

    for Index, Value in next, List do
        if (Value == "Version") then table.insert(Result, string.format("[%s]", Fondra.Loader.Version)) continue end
        if (Value == "FPS") then table.insert(Result, string.format("%s FPS", math.floor(1 / Delta))) continue end
        if (Value == "Ping") then table.insert(Result, string.format("%s MS", math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))) continue end
    end

    Library:SetWatermark(table.concat(Result, " - "))
end)

getgenv().SaveManager = SaveManager

return SaveManager
