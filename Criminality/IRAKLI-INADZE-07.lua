--[[
	// Author: @incognito.tab > Discord
	// Description: We live, We love, We lie. RVVZ is my beloved.

	// Time: 07/25/2024 7:57 AM
	// Extra: Discord.gg/qVJJu5TPUW
]]

-- // Luraph
if not LPH_OBFUSCATED then
LPH_JIT = function(...) return ... end
LPH_JIT_MAX = function(...) return ... end
LPH_NO_UPVALUES = function(...) return ... end
LPH_NO_VIRTUALIZE = function(...) return ... end
end

-- // Setup
local Game                                                                      = game
local Services                                                                  = setmetatable({}, {
    __index = function(Self, Service)               
		local Cache    											                = Game.GetService(Game, Service)

		rawset(Self, Service, Cache)

		return Cache
    end
})

local Hooks 																	= {}
local Connections 																= {}
local Functions																	= {}

-- // Vars
local IsA                                                      					= game.IsA
local GetChildren                                              					= game.GetChildren
local GetDescendants                                              				= game.GetDescendants

local WaitForChild                                             					= game.WaitForChild
local FindFirstChild                                           					= game.FindFirstChild
local FindFirstChildWhichIsA                                   					= game.FindFirstChildWhichIsA

local NewVector2                                                				= Vector2.new
local NewVector3                                                				= Vector3.new

local Random																	= Random.new()
local NextInteger                                               				= Random.NextInteger
local NextNumber                                                				= Random.NextNumber

local Client 																	= Services.Players.LocalPlayer
local Camera 																	= Services.Workspace.CurrentCamera
local Mouse 																	= Client.GetMouse(Client)

local Character 																= Client.Character or Client.CharacterAdded:Wait()
local HumanoidRootPart															= nil
local Humanoid																	= nil
local Torso																		= nil

local Library																 	= loadstring(game:HttpGet("https://raw.githubusercontent.com/Incognito-Tabs/ROBLOX/main/Rayfield.lua"))()
local Flags 																	= Library.Flags
local Vars																		= {}

local Fly                                                      				 	= { Directions = { Forward = 0, Backward = 0, Left = 0, Right = 0, Upward = 0, Downward = 0 }, Current = { BodyVelocity = nil, BodyGyro = nil, Start = nil, Last = nil, Target = nil } }
local Presets 																	= {
	["Cube"]																	= {
		["Left Arm"]															= CFrame.new(0.5, 0, 0.5),
		["Right Arm"]															= CFrame.new(0.5, 0, -0.5),
		["Left Leg"]															= CFrame.new(-0.5, 0, 0.5),
		["Right Leg"]															= CFrame.new(-0.5, 0, -0.5),
		["Offset"]																= CFrame.new(0, -0.5, 0)
	},

	["Somehow Good"]															= {
		["Left Arm"]															= CFrame.new(0, 2, 0),
		["Right Arm"]															= CFrame.new(1.5, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Left Leg"]															= CFrame.new(1, -1.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Right Leg"]															= CFrame.new(-1.5, -1.5, 0),
		["Offset"]																= CFrame.new(0, -0.5, 0)
	},

	["Male Member"]																= {
		["Left Arm"]															= CFrame.new(0, 2, 0),
		["Right Arm"]															= CFrame.new(0, 0, 0),
		["Left Leg"]															= CFrame.new(1, -1.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Right Leg"]															= CFrame.new(-1, -1.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Offset"]																= CFrame.new(0, -0.5, 0)
	},

	["Spinner"]																	= {
		["Left Arm"]															= CFrame.new(0, 0, 1.5) * CFrame.Angles(0, math.rad(90), math.rad(90)),
		["Right Arm"]															= CFrame.new(0, 0, -1.5) * CFrame.Angles(0, math.rad(90), math.rad(90)),
		["Left Leg"]															= CFrame.new(1.5, 0, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Right Leg"]															= CFrame.new(-1.5, 0, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Offset"]																= CFrame.new(0, 0, 0)
	},

	["L"]																		= {
		["Left Arm"]															= CFrame.new(0, 2, 0),
		["Right Arm"]															= CFrame.new(0, 0, 0),
		["Left Leg"]															= CFrame.new(0.5, -1.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Right Leg"]															= CFrame.new(1.5, -1.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
		["Offset"]																= CFrame.new(0, -0.5, 0)
	},

	["W"]																		= {
		["Left Arm"]															= CFrame.new(-1.15, 0, 0) * CFrame.Angles(0, 0, math.rad(30)),
		["Right Arm"]															= CFrame.new(-0.35, 0, 0) * CFrame.Angles(0, 0, math.rad(-30)),
		["Left Leg"]															= CFrame.new(0.35, 0, 0) * CFrame.Angles(0, 0, math.rad(30)),
		["Right Leg"]															= CFrame.new(1.15, 0, 0) * CFrame.Angles(0, 0, math.rad(-30)),
		["Offset"]																= CFrame.new(0, -0.5, 0)
	}
}

-- // Utility Functions
Functions.ClearHooks            												= LPH_NO_VIRTUALIZE(function(Table)
	local MT                            										= getrawmetatable(game)

    setreadonly(MT, false)

    if Table.NewIndex then MT.__newindex = Table.NewIndex end
    if Table.Namecall then MT.__namecall = Table.Namecall end
    if Table.Index then MT.__index = Table.Index end

    setreadonly(MT, true)
end)

Functions.ClearConnections 														= LPH_NO_VIRTUALIZE(function(Table)
	for Name, Connection in next, Table do
        Functions.ClearConnection(Name, Table)
	end
end)

Functions.ClearConnection 														= LPH_NO_VIRTUALIZE(function(Name, Table)
	if Table[Name] then
		Table[Name]:Disconnect()
		Table[Name] = nil

		return true
	end

	return false
end)

Functions.NewConnection		    												= LPH_NO_VIRTUALIZE(function(Name, Table, Type, Callback)
    local Connection 															= Type:Connect(Callback)

    Table[Name]                         										= Connection

	return Connection
end)

Functions.Unload 																= LPH_NO_VIRTUALIZE(function()
	Functions.Fling()
	Functions.Automation()

	Functions.ClearHooks(Hooks)
	Functions.ClearConnections(Connections)

	table.clear(Hooks)
	table.clear(Functions)
	table.clear(Connections)
end)

-- // Main Functions
Functions.Fling 																= LPH_JIT_MAX(function(Bool)
	if not Client then return end
	if not Character then return end

	if not Torso then return end
	if not Humanoid then return end
	if not HumanoidRootPart then return end
	
	if Bool then
		Fly.Current.Instance.Parent												= Character
		Fly.Current.Instance.CFrame 											= HumanoidRootPart.CFrame
		Fly.Current.Start														= HumanoidRootPart.CFrame

		local Hidden 															= Instance.new("Animation")
		Hidden.AnimationId                      								= "rbxassetid://282574440"
		Humanoid:LoadAnimation(Hidden):Play(0.01, 1, 0.01)

		for Index, Object in next, GetChildren(Character) do
			if not IsA(Object, "BasePart") then continue end
		
			if Object.Name == "HumanoidRootPart" then continue end
			if Object.Name == "Torso" then continue end

			Object["CanCollide"]												= false
			Object["Massless"]													= true

			Client.CameraMinZoomDistance										= 0
			Client.CameraMaxZoomDistance										= 200
			Camera.CameraSubject												= Fly.Current.Instance
			Humanoid.AutoRotate													= false
		end
		
		for Index, Object in next, GetDescendants(Character) do
			if not IsA(Object, "BallSocketConstraint") then continue end
		
			Object.UpperAngle 													= 0
			Object.TwistLowerAngle												= 0
			Object.TwistUpperAngle												= 0
		end

		return
	end

	if not Bool then
		Camera.CameraSubject													= Humanoid
		Fly.Current.Instance.Parent												= Services.CoreGui
		Fly.Current.Instance.CFrame 					           				= Fly.Current.Last or Fly.Current.Start or CFrame.new()
		Fly.Current.BodyGyro.CFrame 					           				= Fly.Current.Last or Fly.Current.Start or CFrame.new()
		Fly.Current.Target														= nil
		Fly.Current.Break 														= true
		Client.CameraMinZoomDistance											= 0
		Client.CameraMaxZoomDistance											= 200

		for Index, Track in next, Humanoid:GetPlayingAnimationTracks() do
			Track:Stop()
		end

		for Index, Object in next, GetDescendants(Character) do
			if not IsA(Object, "BasePart") then continue end

			Object["Velocity"]													= NewVector3()
			Object["Rotation"]													= NewVector3()
		end

		task.wait(0.2)

		if HumanoidRootPart and Torso and Fly.Current.Start then
			Torso.Part.Weld.C0													= CFrame.new(0, 1.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)			
			Torso.Part.Weld.C1													= CFrame.new(0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 1, 0)			
			HumanoidRootPart.CamShakePart.Motor6D.C1							= CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
			HumanoidRootPart.CamShakePart.Motor6D.C0							= CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
			HumanoidRootPart.RootJoint.C1										= CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
			HumanoidRootPart.CFrame												= Fly.Current.Start * CFrame.new(0, 2, 0)
			Camera.CameraSubject 												= Humanoid
			Fly.Current.Start													= nil
		end

		task.wait(0.2)

		for Index, Object in next, GetDescendants(Character) do
			if not IsA(Object, "BasePart") then continue end
			if not FindFirstChild(Object, "RagdollAttachment") then continue end 

			Object["RagdollAttachment"].CFrame									= CFrame.new(0, string.find(Object.Name, "Arm") and 0.5 or string.find(Object.Name, "Leg") and 1 or -0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			Object["CFrame"]													= HumanoidRootPart.CFrame
		end
	end
end)

Functions.Automation															= LPH_JIT_MAX(function(Bool)
	
end)

--// Main Functions
Functions.CharacterAdded														= LPH_NO_VIRTUALIZE(function(New)
	Character 																	= New
	HumanoidRootPart															= FindFirstChild(Character, "HumanoidRootPart") or WaitForChild(Character, "HumanoidRootPart")
	Humanoid																	= FindFirstChild(Character, "Humanoid") or WaitForChild(Character, "Humanoid")
	Torso																		= FindFirstChild(Character, "Torso") or WaitForChild(Character, "Torso")

    task.wait(0.15)

	if not Client then return end
	if not Character then return end

	if not Torso then return end
	if not Humanoid then return end
	if not HumanoidRootPart then return end

	Functions.ClearConnection("HUMANOID DIED", Connections)
	Functions.ClearConnection("DOWNED CHANGED", Connections)
	
	Functions.NewConnection("DOWNED CHANGED", Connections, Services.ReplicatedStorage.CharStats[New.Name].Downed.Changed, function(Value)
		task.wait(0.2)

		local Hidden 															= Instance.new("Animation")
		Hidden.AnimationId                      								= "rbxassetid://282574440"
		Humanoid:LoadAnimation(Hidden):Play(0.01, 1, 0.01)
	end)

	Functions.NewConnection("HUMANOID DIED", Connections, Humanoid.Died, function()
		Flags["Fling"]:Set(false)

		task.wait(0.5)

		Torso																	= nil
		Humanoid																= nil
		HumanoidRootPart														= nil
		Character																= nil
	end)
end)

-- ? // Bypass
for Index, Data in next, getgc(true) do
    if typeof(Data) == "table" and typeof(rawget(Data, "CX1")) == "function" then
        hookfunction(Data.CX1, function() 
			return task.wait(9e9) 
		end)

		continue
    end

    if typeof(Data) == "table" and rawget(Data, "Detected") and typeof(rawget(Data, "Detected")) == "function" then    
		hookfunction(Data["Detected"], LPH_NO_UPVALUES(function(Action, Info, NoCrash)
            if rawequal(Action, "_") then return true end
            if rawequal(Info, "_") then return true end

            return task.wait(9e9)
        end))

		continue
    end
end

-- ? // Hooks
local Namecall; Namecall                                        				= hookmetamethod(game, "__namecall", LPH_NO_UPVALUES(function(Self, ...)
	if checkcaller() then return Namecall(Self, ...) end

    local Name                                                  				= tostring(Self)
    local Method                                                				= getnamecallmethod()

    if Method == "FireServer" then 
        if Name == "TK_DGM" then return task.wait(math.huge) end
        if Name == "__DFfDD" then return task.wait(math.huge) end
	end

    return Namecall(Self, ...)
end))

local NewIndex; NewIndex														= hookmetamethod(game, "__newindex", LPH_NO_UPVALUES(function(Self, Index, Value)
	if not Character then return NewIndex(Self, Index, Value) end

	local Name 																	= tostring(Self)
	local Method 																= tostring(Index)
	local Result 																= tostring(Value)

    if (Name == "Humanoid") and (Method == "HipHeight") and (Self.Parent == Character) and (Flags["Fling"].CurrentValue) then
		return NewIndex(Self, Index, -1.975)
	end

	return NewIndex(Self, Index, Value)
end))

Hooks.Namecall 																	= Namecall
Hooks.NewIndex 																	= NewIndex

-- ? // Setup
local Cube 																		= Instance.new("Part")
Cube.Size 																		= NewVector3(2.1, 2.1, 2.1)
Cube.Anchored																	= false
Cube.CanCollide																	= false
Cube.Velocity 																	= NewVector3(0, 0, 0)
Cube.Parent 																	= Services.CoreGui
Cube.Transparency																= 1

local Highlight 																= Instance.new("Highlight")
Highlight.Adornee																= Cube
Highlight.Parent 																= Cube

local BV 											    						= Instance.new("BodyVelocity")
BV.MaxForce 										    						= NewVector3(1e9, 1e9, 1e9)
BV.Velocity 										    						= NewVector3()
BV.Parent 																		= Cube

local BG 											    						= Instance.new("BodyGyro")
BG.D 												    						= 200
BG.P 												    						= 5000
BG.MaxTorque 										    						= NewVector3(1e4, 1e4, 1e4)
BG.Parent 																		= Cube

Fly.Current.BodyVelocity					    								= BV
Fly.Current.BodyGyro						    								= BG
Fly.Current.Instance							    							= Cube
Fly.Current.Start 																= nil

-- ? // UI
local Window 																	= Library:CreateWindow({
	Name 																		= "IRAKLI INADZE 07",
	LoadingTitle 																= "IRAKLI INADZE 07",
	LoadingSubtitle 															= "by @incognito.tab on Discord",
	LoadingImage																= nil,

	ConfigurationSaving 														= {
		Enabled 																= true,
		FolderName 																= nil,
		FileName 																= "IRAKLI-INADZE-07"
	},
	
	Discord 																	= {
		Enabled 																= false,
		Invite 																	= "",
		RememberJoins 															= false
	}
})

LPH_NO_VIRTUALIZE(function()
local Main 																		= Window:CreateTab("Main") do
	Main:CreateSection("Main")

	Main:CreateToggle({
		Name 																	= "Enable Fling",
		CurrentValue 															= false,
		Flag 																	= "Fling",
		Callback 																= Functions.Fling,
	})

	Main:CreateKeybind({
		Name 																	= "Fling Keybind",
		CurrentKeybind 															= "L",
		HoldToInteract 															= false,
		Flag 																	= "Fling Key",
		Callback 																= function(Value)
			Flags["Fling"]:Set(not Flags["Fling"].CurrentValue)
		end,
	})

	Main:CreateSlider({
		Name 																	= "Fling Fly Speed",
		Range 																	= {0, 500},
		Increment 																= 1,
		Suffix 																	= "",
		CurrentValue 															= 100,
		Flag 																	= "Fling Fly Speed",
		Callback 																= function(Value)

		end,
 	})

	Main:CreateDropdown({
		Name 																	= "Fling Type",
		Options 																= {"Cube", "Somehow Good", "Male Member", "Spinner", "L", "W"},
		CurrentOption 															= {"Cube"},
		MultipleOptions 														= false,
		Flag	 																= "Fling Type",
		Callback 																= function(Options)

		end,
	})
end

local Theme 																	= Window:CreateTab("Brick Theme") do
	Theme:CreateSection("Colors")

	Theme:CreateColorPicker({
		Name 																	= "Highlight Fill Color",
		Color 																	= Color3.fromRGB(255, 0, 0),
		Flag 																	= "Highlight Fill Color",
		Callback 																= function(Value)
			Highlight.FillColor													= Value
		end
	})

	Theme:CreateColorPicker({
		Name 																	= "Highlight Outline Color",
		Color 																	= Color3.fromRGB(255,255,255),
		Flag 																	= "Highlight Outline Color",
		Callback 																= function(Value)
			Highlight.OutlineColor												= Value
		end
	})

	Theme:CreateSection("Transparencies")

	Theme:CreateSlider({
		Name 																	= "Highlight Fill Transparency",
		Range 																	= {0, 1},
		Increment 																= 0.01,
		Suffix 																	= "",
		CurrentValue 															= 0,
		Flag 																	= "Highlight Fill Transparency",
		Callback 																= function(Value)
			Highlight.FillTransparency											= Value
		end,
 	})

	Theme:CreateSlider({
		Name 																	= "Highlight Outline Transparency",
		Range 																	= {0, 1},
		Increment 																= 0.01,
		Suffix 																	= "",
		CurrentValue 															= 0,
		Flag 																	= "Highlight Outline Transparency",
		Callback 																= function(Value)
			Highlight.OutlineTransparency										= Value
		end,
 	})
end

local Automation 																= Window:CreateTab("Automation") do
	Automation:CreateSection("Selection")

	local Target; Target 														= Automation:CreateInput({
		Name			 														= "Target Player",
		PlaceholderText 														= "Player Name",
		RemoveTextAfterFocusLost 												= false,
		Flag																	= "Target Name",
		Callback 																= function(Text)
			for Index, Player in next, Services.Players:GetPlayers() do
				if string.find(Player.Name:lower(), Text:lower(), 1, true) then
					Library:Notify({
						Title 													= "IRAKLI INADZE 07",
						Content 												= string.format("Found user named %q with display name as %q in the server.", Player.Name, Player.DisplayName),
						Duration 												= 5,
						Image 													= 17173102472
					})

					return Target:Set(Player.Name)
				end
			end

			return Library:Notify({
				Title 															= "IRAKLI INADZE 07",
				Content 														= string.format("The user named %q is not available in the server.", Text),
				Duration 														= 5,
				Image 															= 17173037446
			})
		end
	})

	Automation:CreateDropdown({
		Name 																	= "Automatic Fling Method",
		Options 																= {"V1 Prediction", "V2 Prediction", "Orbit"},
		CurrentOption 															= {"V1 Prediction"},
		MultipleOptions 														= false,
		Flag	 																= "Automatic Fling Method",
		Callback																= function()
			
		end
	})

	Automation:CreateSection("Actions")

	Automation:CreateButton({
		Name 																	= "Start Fling",
		Callback 																= function()
			if not Flags["Fling"].CurrentValue then return end

			Fly.Current.Break													= true
			Fly.Current.Break													= false

			if Fly.Current.Target then 
				return Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= "You are already targetting a user, please cancel the current fling to proceed.",
					Duration 													= 5,
					Image 														= 17173037446
				}) 
			end

			if not FindFirstChild(Services.Players, Flags["Target Name"].CurrentValue) then
				return Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= "This player does not exist.",
					Duration 													= 5,
					Image 														= 17173037446
				}) 
			end

			if not Services.Players[Flags["Target Name"].CurrentValue].Character then
				return Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= "This player has died, please wait till they respawn.",
					Duration 													= 5,
					Image 														= 17172998738
				}) 
			end

			if Services.Players[Flags["Target Name"].CurrentValue].Character.Humanoid.Health <= 0 then
				return Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= "This player has died, please wait till they respawn.",
					Duration 													= 5,
					Image 														= 17172998738
				}) 
			end

			Fly.Current.Last													= Fly.Current.Instance.CFrame
			Fly.Current.Target													= Services.Players[Flags["Target Name"].CurrentValue].Character
			Camera.CameraSubject												= Fly.Current.Target.Humanoid

			Library:Notify({
				Title 															= "IRAKLI INADZE 07",
				Content 														= "Targetting started.",
				Duration 														= 5,
				Image 															= 17173102472
			}) 

			repeat task.wait() until not Fly.Current.Target or not Services.Players[Flags["Target Name"].CurrentValue]:IsDescendantOf(Services.Players) or Fly.Current.Target.Humanoid.Health <= 0 or Fly.Current.Break

			if not Services.Players[Flags["Target Name"].CurrentValue]:IsDescendantOf(Services.Players) then
				Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= "Player Left",
					Duration 													= 5,
					Image 														= 17173102472
				}) 
			end

			if Fly.Current.Target.Humanoid.Health <= 0 then
				Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= "Successfully Killed targeted player.",
					Duration 													= 5,
					Image 														= 17173028708
				}) 
			end

			Camera.CameraSubject												= Fly.Current.Instance
			Fly.Current.Instance.CFrame 					           			= Fly.Current.Last or Fly.Current.Start
			Fly.Current.BodyGyro.CFrame 					           			= Fly.Current.Last or Fly.Current.Start
			Fly.Current.Target													= nil
			Fly.Current.Break 													= true
		end,
	})

	Automation:CreateButton({
		Name 																	= "Cancel Fling",
		Callback 																= function()
			if not Flags["Fling"].CurrentValue then return end

			Camera.CameraSubject												= Fly.Current.Instance
			Fly.Current.Instance.CFrame 					           			= Fly.Current.Last or Fly.Current.Start
			Fly.Current.BodyGyro.CFrame 					           			= Fly.Current.Last or Fly.Current.Start
			Fly.Current.Target													= nil
			Fly.Current.Break 													= true
		end,
	})

	Automation:CreateButton({
		Name 																	= "Fling All Players",
		Callback 																= function()
			if not Flags["Fling"].CurrentValue then return end

			if Fly.Current.Target then 
				return Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= "You are already targetting a user, please cancel the current fling to proceed.",
					Duration 													= 5,
					Image 														= 17173037446
				}) 
			end

			local List 															= Services.Players:GetPlayers()
			local Total 														= 0

			Fly.Current.Last													= Fly.Current.Instance.CFrame
			Fly.Current.Break													= true
			Fly.Current.Break													= false

			for i, Player in next, List do
				if Player == Client then continue end
				if Fly.Current.Break then break end

				if not Player then continue end
				if not Player.Character then continue end

				local Target													= Player.Character
				local Torso														= FindFirstChild(Target, "Torso")
				local Humanoid													= FindFirstChild(Target, "Humanoid")
				local HumanoidRootPart											= FindFirstChild(Target, "HumanoidRootPart")

				if not Torso then continue end
				if not Humanoid then continue end
				if not HumanoidRootPart then continue end

				if FindFirstChild(Target, "ProtectionFF") then continue end
				if (Humanoid.Health) <= 0 then continue end
				if (Torso.Position - HumanoidRootPart.Position).Magnitude > 2 then continue end

				Fly.Current.Target												= Target
				Camera.CameraSubject											= Humanoid
				
				Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= string.format("Targetting started on player named %q", Player.Name),
					Duration 													= 2.5,
					Image 														= 17173102472
				}) 

				repeat task.wait() until not Player:IsDescendantOf(Services.Players) or Humanoid.Health <= 0 or Fly.Current.Break or FindFirstChild(Target, "ProtectionFF")
				if not Player:IsDescendantOf(Services.Players) or Fly.Current.Break or FindFirstChild(Target, "ProtectionFF") then continue end

				Library:Notify({
					Title 														= "IRAKLI INADZE 07",
					Content 													= string.format("Successfully killed player named %q", Player.Name),
					Duration 													= 2.5,
					Image 														= 17173028708
				}) 

				Total															+= 1
			end

			Library:Notify({
				Title 															= "IRAKLI INADZE 07",
				Content 														= string.format("Killed %s/%s players", Total, #List - 1),
				Duration 														= 7.5,
				Image 															= 17173028708
			}) 

			Camera.CameraSubject												= Fly.Current.Instance
			Fly.Current.Instance.CFrame 					           			= Fly.Current.Last or Fly.Current.Start
			Fly.Current.BodyGyro.CFrame 					           			= Fly.Current.Last or Fly.Current.Start
			Fly.Current.Target													= nil
			Fly.Current.Break 													= true
		end,
	})
end
end)()

-- ? // Connections
-- ! // I needed to do 3+ different connections, -523523532523 FPS 😔
Functions.CharacterAdded(Client.Character)
Functions.NewConnection("CHARACTER APPEARANCE LOADED", Connections, Client.CharacterAppearanceLoaded, Functions.CharacterAdded)
Functions.NewConnection("CHARACTER ADDED", Connections, Client.CharacterAdded , Functions.CharacterAdded)

Functions.NewConnection("INPUT BEGAN", Connections, Services.UserInputService.InputBegan, LPH_NO_VIRTUALIZE(function(Key, Processed)
	if Processed then return end

	if Key.KeyCode == Enum.KeyCode.W then Fly.Directions.Forward = 1 end
	if Key.KeyCode == Enum.KeyCode.S then Fly.Directions.Backward = 1 end
	if Key.KeyCode == Enum.KeyCode.D then Fly.Directions.Right = 1 end
	if Key.KeyCode == Enum.KeyCode.A then Fly.Directions.Left = 1 end

	if Key.KeyCode == Enum.KeyCode.E then Fly.Directions.Upward = 1 end
	if Key.KeyCode == Enum.KeyCode.Q then Fly.Directions.Downward = 1 end
end))

Functions.NewConnection("INPUT ENDED", Connections, Services.UserInputService.InputEnded, LPH_NO_VIRTUALIZE(function(Key)
	if Key.KeyCode == Enum.KeyCode.W then Fly.Directions.Forward = 0 end
	if Key.KeyCode == Enum.KeyCode.S then Fly.Directions.Backward = 0 end
	if Key.KeyCode == Enum.KeyCode.D then Fly.Directions.Right = 0 end
	if Key.KeyCode == Enum.KeyCode.A then Fly.Directions.Left = 0 end

	if Key.KeyCode == Enum.KeyCode.E then Fly.Directions.Upward = 0 end
	if Key.KeyCode == Enum.KeyCode.Q then Fly.Directions.Downward = 0 end
end))

Functions.NewConnection("RENDER", Connections, Services.RunService.Heartbeat, LPH_JIT_MAX(function()
    if not Client then return end
    if not Character then return end
	if not Flags["Fling"].CurrentValue then return end

	if not Fly.Current then return end
	if not Fly.Current.Start then return end
	if not Fly.Current.Instance then return end
	if not Fly.Current.BodyGyro then return end
	if not Fly.Current.BodyVelocity then return end
	
	if not Torso then return end
	if not Humanoid then return end
	if not HumanoidRootPart then return end

	Services.ReplicatedStorage.Events.__DFfDD:FireServer(
		"-r__r2", 
		HumanoidRootPart.Position, 
		HumanoidRootPart.CFrame
	)

	HumanoidRootPart["CFrame"]                       							= Fly.Current.Start * CFrame.new(0, -0.9, 0)

	if FindFirstChild(Character, "Head") then
		Character["Head"]["CFrame"] 											= Torso.CFrame
		Character["Head"]["RagdollAttachment"]["WorldCFrame"]					= Torso.CFrame
	end

	if FindFirstChild(Character, "Left Arm") then
		Character["Left Arm"]["CFrame"] 										= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Left Arm"]
		Character["Left Arm"]["RagdollAttachment"]["WorldCFrame"]				= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Left Arm"]
	end

	if FindFirstChild(Character, "Right Arm") then
		Character["Right Arm"]["CFrame"] 										= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Right Arm"]
		Character["Right Arm"]["RagdollAttachment"]["WorldCFrame"]				= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Right Arm"]
	end

	if FindFirstChild(Character, "Left Leg") then
		Character["Left Leg"]["CFrame"] 										= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Left Leg"]
		Character["Left Leg"]["RagdollAttachment"]["WorldCFrame"]				= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Left Leg"]
	end

	if FindFirstChild(Character, "Right Leg") then
		Character["Right Leg"]["CFrame"] 										= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Right Leg"]
		Character["Right Leg"]["RagdollAttachment"]["WorldCFrame"]				= Cube.CFrame * Presets[Flags["Fling Type"].CurrentOption[1]]["Right Leg"]
	end
end))

Functions.NewConnection("CONTROLLER", Connections, Services.RunService.RenderStepped, LPH_JIT_MAX(function(Delta)
    if not Client then return end
    if not Character then return end
	if not Flags["Fling"].CurrentValue then return end

	if not Fly.Current then return end
	if not Fly.Current.Start then return end
	if not Fly.Current.Instance then return end
	if not Fly.Current.BodyGyro then return end
	if not Fly.Current.BodyVelocity then return end
	
	if not Torso then return end
	if not Humanoid then return end
	if not HumanoidRootPart then return end

	HumanoidRootPart["CFrame"]                       							= Fly.Current.Start * CFrame.new(0, -0.9, 0)

	if Fly.Current.Target then
		if Flags["Automatic Fling Method"]["CurrentOption"][1] == "V1 Prediction" then
			local Part															= Fly.Current.Target.HumanoidRootPart
			local X, Y, Z 														= Part.CFrame:ToEulerAnglesYXZ()
			local RandomX, RandomY, RandomZ, RandomAngle 						= NextNumber(Random, 0.1, 1), NextNumber(Random, 0.1, 1), NextNumber(Random, 0.1, 1), NextNumber(Random, 0, 360)
			local Prediction													= Part.Position + (NewVector3(Part.Velocity.X, 0, Part.Velocity.Z) * (Services.Stats.PerformanceStats.Ping:GetValue() / 250))
			local Offset 														= Presets[Flags["Fling Type"].CurrentOption[1]]["Offset"]
			local CFramed 														= CFrame.new(Prediction) * CFrame.new(RandomX, RandomY, RandomZ) * Offset * CFrame.Angles(X, Y, Z) * CFrame.Angles(0, math.rad(RandomAngle), 0)

			Fly.Current.Instance.CFrame											= CFramed
			Fly.Current.BodyGyro.CFrame 					           			= CFramed
		end

		if Flags["Automatic Fling Method"]["CurrentOption"][1] == "V2 Prediction" then
			local Part 															= Fly.Current.Target.HumanoidRootPart
			local X, Y, Z 														= Part.CFrame:ToEulerAnglesYXZ()
			
			local RandomX, RandomY, RandomZ 									= NextNumber(Random, 0.1, 1), NextNumber(Random, 0.1, 1), NextNumber(Random, 0.1, 1)
			local RandomAngle 													= NextNumber(Random, 0, 360)
			local Velocity														= NewVector3(Part.Velocity.X, 0, Part.Velocity.Z)
			
			local PingFactor 													= Services.Stats.PerformanceStats.Ping:GetValue() / 250
			local VelocityFactor												= NewVector3(Part.Velocity.X, 0, Part.Velocity.Z) * PingFactor
			local Prediction 													= Part.Position + VelocityFactor + (0.5 * VelocityFactor ^ 2)
			
			local Offset 														= Presets[Flags["Fling Type"].CurrentOption[1]]["Offset"]
			local Result 														= CFrame.new(Prediction) * CFrame.new(RandomX, RandomY, RandomZ) * Offset * CFrame.Angles(X, Y, Z) * CFrame.Angles(0, math.rad(RandomAngle), 0)
		
			Fly.Current.Instance.CFrame 										= Result
			Fly.Current.BodyGyro.CFrame 										= Result
		end

		if Flags["Automatic Fling Method"]["CurrentOption"][1] == "Orbit" then
			Vars.Alpha 															= ((Vars.Alpha or 0) + Delta / 1) % 1

			local Part															= Fly.Current.Target.HumanoidRootPart
			local CFramed 														= CFrame.Angles(0, 2 * math.pi * Vars.Alpha, 0) * CFrame.new(0, 0, 5) + Part.Position
			
			Fly.Current.Instance.CFrame											= CFramed
			Fly.Current.BodyGyro.CFrame 					           			= CFramed
		end

		Fly.Current.BodyVelocity.Velocity				           				= NewVector3()
	end
	
	if not Fly.Current.Target then
		local Frame 															= Camera.CFrame
		local Horizontal 														= Frame.LookVector * (Fly.Directions.Forward - Fly.Directions.Backward)
		local Sideways 															= Frame.RightVector * (Fly.Directions.Right - Fly.Directions.Left)
		local Vertical 															= Frame.UpVector * (Fly.Directions.Upward - Fly.Directions.Downward)

		Fly.Current.BodyGyro.CFrame 					           				= Frame
		Fly.Current.Instance.Velocity											= NewVector3()
		Fly.Current.BodyVelocity.Velocity 										= (Horizontal + Sideways + Vertical) * Flags["Fling Fly Speed"].CurrentValue
	end
end))

Functions.NewConnection("FLING", Connections, Services.RunService.RenderStepped, LPH_JIT_MAX(function()
    if not Client then return end
    if not Character then return end
	if not Flags["Fling"].CurrentValue then return end

	if not Fly.Current then return end
	if not Fly.Current.Start then return end
	if not Fly.Current.Instance then return end
	if not Fly.Current.BodyGyro then return end
	if not Fly.Current.BodyVelocity then return end
	
	if not Torso then return end
	if not Humanoid then return end
	if not HumanoidRootPart then return end

	for Index, Object in next, GetChildren(Character) do	
		if not Object:IsA("BasePart") then continue end
		if not string.find(Object.Name, "Arm") and not string.find(Object.Name, "Leg") and not string.find(Object.Name, "Head") then continue end
		
		Object["Velocity"]														= NewVector3(0, 5000000, 0)
	end
end))

Library:Notify({
	Title 																		= "IRAKLI INADZE 07",
	Content 																	= "Successfully Loaded",
	Duration 																	= 10,
	Image 																		= 4483362458
})					

Library:LoadConfiguration()
