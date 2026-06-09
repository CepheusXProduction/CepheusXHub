--[[
   ================================================================================
   Cepheus X Hub - Premium Universal ScriptHub (Architectural Rewrite V7)
   Project CepheusX | Created: Jun 6, 2026 | Updated: June 2026
   Artifact: Universal Script Hub (Luau / Wind UI Library Integration)
   ================================================================================
   Description: Elite universal platform diagnostic utility and execution suite.
                Features advanced environment normalization, deep physics step
                synchronization, and full bidirectional state management.
   ================================================================================
]]


-- ================================================================================
-- ENVIRONMENT NORMALIZATION & SAFE REFERENCES
-- ================================================================================
local cloneref = (cloneref or clonereference or function(instance) return instance end)


local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Lighting = cloneref(game:GetService("Lighting"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))


local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()


-- Safe CoreGui Evasion Layer
local targetCore = CoreGui
local function GetSafeParent()
   local success, parent = pcall(function()
       return (gethui and gethui()) or targetCore
   end)
   if success and parent then
       return parent
   end
   return LocalPlayer:WaitForChild("PlayerGui")
end


-- ================================================================================
-- UNIFIED STATE MANAGEMENT (Centralized Config)
-- ================================================================================
local ScriptHubConfig = {
   Player = {
       WalkSpeedEnabled = false, WalkSpeedValue = 16, WalkMethod = "Humanoid",
       SwimEnabled = false, SwimSpeed = 50,
       FlyEnabled = false, FlySpeed = 50, FlyMethod = "Velocity Fly",
       GravityEnabled = false, GravityValue = 196.2,
       HipHeightEnabled = false, HipHeightValue = 0,
       ClickTPEnabled = false, ClickTPMethod = "CFrame",
       Noclip = false, WalkOnWalls = false,
       JerkEnabled = false, JerkPower = 5,
       Bunnyhop = false, InfiniteJump = false, AntiSit = false, FlingSelf = false,
       JumpEnabled = false, JumpValue = 50, JumpMethod = "Humanoid Power",
       SpinbotEnabled = false, SpinbotSpeed = 20, AntiRagdoll = false
   },
   Visuals = {
       Xray = false, FullBright = false, FPSBoost = false, NoRender = false, BlackScreen = false,
       ESPEnabled = false, Tracers = false, TracerOrigin = "Bottom Center",
       Boxes = false, BoxMode = "Standard 2D Box", Skeleton = false,
       NamesDistance = false, Health = false, Chams = false,
       ESPColor = Color3.fromRGB(255, 255, 255)
   },
   Utility = {
       AutoClicker = false, AutoClickInterval = 10, AntiAFK = false,
       ClickTPTool = false, ChatSpammer = false, SpammerInterval = 3,
       SpammerText = "CepheusX Hub on top!"
   },
   Troll = {
       Targets = {}, Fling = false, Headsit = false, Platform = false, Jumpblock = false,
       Orbit = false, OrbitDistance = 5, OrbitSpeed = 5, OrbitTarget = "None",
       Follow = false, FollowTarget = "None", StandMode = false, StandDistance = 3, StandTarget = "None"
   }
}


-- Background Tracking Cache
local CoreConnections = {}
local CacheESP = { Drawings = {}, Chams = {} }
local StartTime = os.clock()
local OriginalLighting = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd }
local OriginalParts = {}
local BlackScreenGUI = nil
local FlyBV = nil
local FlyBG = nil


-- ================================================================================
-- PRE-EXECUTION LOADER ENGINE (Anti-Lag Sequence)
-- ================================================================================
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "CepheusX_Loader"
LoaderGui.ResetOnSpawn = false
LoaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


local successCore = pcall(function() LoaderGui.Parent = GetSafeParent() end)
if not successCore then LoaderGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end


local LoaderFrame = Instance.new("Frame")
LoaderFrame.Size = UDim2.new(0, 450, 0, 140)
LoaderFrame.Position = UDim2.new(0.5, -225, 0.5, -70)
LoaderFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
LoaderFrame.BorderSizePixel = 0
LoaderFrame.Parent = LoaderGui


local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 8)
LoaderCorner.Parent = LoaderFrame


local LoaderStroke = Instance.new("UIStroke")
LoaderStroke.Color = Color3.fromRGB(99, 102, 241)
LoaderStroke.Thickness = 1.5
LoaderStroke.Parent = LoaderFrame


local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 40)
LoaderTitle.Position = UDim2.new(0, 0, 0, 10)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "CEPHEUS X INITIALIZATION"
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 22
LoaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTitle.Parent = LoaderFrame


local LoaderStatus = Instance.new("TextLabel")
LoaderStatus.Size = UDim2.new(1, -40, 0, 20)
LoaderStatus.Position = UDim2.new(0, 20, 0, 65)
LoaderStatus.BackgroundTransparency = 1
LoaderStatus.Text = "Starting..."
LoaderStatus.Font = Enum.Font.Gotham
LoaderStatus.TextSize = 13
LoaderStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
LoaderStatus.TextXAlignment = Enum.TextXAlignment.Left
LoaderStatus.Parent = LoaderFrame


local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(1, -40, 0, 6)
BarBackground.Position = UDim2.new(0, 20, 0, 95)
BarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = LoaderFrame
Instance.new("UICorner", BarBackground).CornerRadius = UDim.new(1, 0)


local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBackground
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)


local function SetLoaderPhase(text, progress)
   LoaderStatus.Text = text
   TweenService:Create(BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
   task.wait(0.35)
end


SetLoaderPhase("Initializing Core Services...", 0.1)


-- ================================================================================
-- WINDUI LIBRARY FETCH
-- ================================================================================
SetLoaderPhase("Fetching WindUI Framework...", 0.25)
local WindUI
do
   local ok, result = pcall(function()
       return require("./src/Init")
   end)


   if ok then
       WindUI = result
   else
       if cloneref(game:GetService("RunService")):IsStudio() then
           WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
       else
           WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
       end
   end
end


-- ================================================================================
-- COLOR PALETTE
-- ================================================================================
local Colors = {
   Purple = Color3.fromHex("#7775F2"),
   Yellow = Color3.fromHex("#ECA201"),
   Green  = Color3.fromHex("#10C550"),
   Grey   = Color3.fromHex("#83889E"),
   Blue   = Color3.fromHex("#257AF7"),
   Red    = Color3.fromHex("#EF4F1D"),
   Cyan   = Color3.fromRGB(0, 170, 255),
   Mint   = Color3.fromRGB(120, 255, 200),
}


-- ================================================================================
-- WELCOME POPUP
-- ================================================================================
local function createPopup()
   return WindUI:Popup({
      Title = "Welcome to Cepheus X Hub!",
      Icon = "rocket",
      Content = "Your all-in-one script hub. Select a tab to get started.",
      Buttons = {
         {
            Title = "Close",
            Variant = "Tertiary",
         },
         {
            Title = "Let's Go!",
            Icon = "arrow-right",
            Variant = "Primary",
         },
      },
   })
end


-- ================================================================================
-- WINDUI WINDOW CREATION
-- ================================================================================
SetLoaderPhase("Configuring Interface Matrices...", 0.45)
local Window = WindUI:CreateWindow({
   Title = "Cepheus X Hub - Premium Universal",
   Author = "by Cepheus Team",
   Folder = "CepheusX",
   Icon = "solar:folder-2-bold-duotone",
   NewElements = true,

   -- Layout
   Size = UDim2.fromOffset(580, 460),
   MinSize = Vector2.new(560, 350),
   MaxSize = Vector2.new(850, 560),
   SideBarWidth = 200,
   Resizable = true,

   -- Appearance
   Theme = "Dark",
   Transparent = true,
   BackgroundImageTransparency = 0.42,
   HideSearchBar = false,
   ScrollBarEnabled = false,

   -- Toggle key
   ToggleKey = Enum.KeyCode.RightShift,

   -- Topbar
   Topbar = { Height = 44, ButtonsType = "Mac" },

   -- Open Button
   OpenButton = {
      Title = "Cepheus X",
      Enabled = true,
      Draggable = true,
      Scale = 0.55,
      CornerRadius = UDim.new(1, 0),
      StrokeThickness = 2,
      OnlyMobile = false,
      Color = ColorSequence.new(Colors.Cyan, Colors.Mint),
   },

   -- User display
   User = {
      Enabled = true,
      Anonymous = false,
      Callback = function()
         WindUI:Notify({
            Title = "Profile",
            Content = "Hello, " .. LocalPlayer.Name .. "!",
            Icon = "user",
            Duration = 3,
         })
      end,
   },
})


-- Show welcome popup on first load
createPopup()


Window:Tag({ Title = "v" .. WindUI.Version, Icon = "github", Color = Color3.fromHex("#1c1c1c"), Border = true })


-- Window lifecycle triggers
Window:OnClose(function()
   print("[Cepheus X] Window Closed")
end)

Window:OnOpen(function()
   print("[Cepheus X] Window Opened")
end)


-- ================================================================================
-- SYSTEM INTEROPERABILITY SYNC CORE (Bidirectional Sync)
-- ================================================================================
local function CreateBidirectionalSync(TabSection, Title, ConfigCategory, ConfigKey, Min, Max, Default, Step)
   local SliderElem, InputElem


   SliderElem = TabSection:Slider({
       Title = Title .. " Slider",
       Step = Step,
       Value = { Min = Min, Max = Max, Default = Default },
       Callback = function(numericValue)
           ScriptHubConfig[ConfigCategory][ConfigKey] = numericValue
           if InputElem then
               InputElem:Set(tostring(numericValue))
           end
       end
   })


   InputElem = TabSection:Input({
       Title = Title .. " Textbox",
       Value = tostring(Default),
       Callback = function(textValue)
           local parsedNumber = tonumber(textValue)
           if parsedNumber then
               local constrainedValue = math.clamp(parsedNumber, Min, Max)
               ScriptHubConfig[ConfigCategory][ConfigKey] = constrainedValue
               if SliderElem then
                   SliderElem:Set(constrainedValue)
               end
           end
       end
   })
end


-- ================================================================================
-- 0. MAIN TAB (HOME)
-- ================================================================================
SetLoaderPhase("Assembling Main Home Tab...", 0.55)
local MainSection = Window:Section({ Title = "Main" })
local MainTab = MainSection:Tab({
   Title = "Main",
   Icon = "solar:home-2-bold",
   IconColor = Colors.Grey,
   IconShape = "Square",
   Border = true,
})

MainTab:Section({
   Title = "Welcome to Cepheus X Hub",
   TextSize = 22,
   FontWeight = Enum.FontWeight.SemiBold,
})

MainTab:Space()

MainTab:Section({
   Title = "A powerful, Multi-use script hub built to use in any game.\nBrowse tabs on the left to explore all features.",
   TextSize = 16,
   TextTransparency = 0.35,
   FontWeight = Enum.FontWeight.Medium,
})

MainTab:Space({ Columns = 3 })

MainTab:Button({
   Title = "Rejoin Server",
   Icon = "refresh-cw",
   Justify = "Center",
   Callback = function()
      TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end,
})

MainTab:Space()

MainTab:Button({
   Title = "Copy Game ID",
   Icon = "copy",
   Color = Colors.Blue,
   Justify = "Center",
   Callback = function()
      if setclipboard then
         setclipboard(tostring(game.PlaceId))
      end
      WindUI:Notify({
         Title = "Copied",
         Content = "Game ID: " .. tostring(game.PlaceId),
         Icon = "check",
         Duration = 3,
      })
   end,
})

MainTab:Space()

MainTab:Button({
   Title = "Destroy Hub",
   Desc = "Completely removes the UI",
   Color = Colors.Red,
   Icon = "shredder",
   Justify = "Center",
   IconAlign = "Left",
   Callback = function()
      Window:Destroy()
   end,
})


-- ================================================================================
-- 1. INFO TAB ARCHITECTURE
-- ================================================================================
SetLoaderPhase("Assembling Script Info Matrix...", 0.6)
local InfoTab = Window:Tab({ Title = "Info", Icon = "solar:info-square-bold", Border = true })


local ScriptSubSection = InfoTab:Section({ Title = "Script Configurations" })
ScriptSubSection:Paragraph({ Title = "Cepheus X Hub - Premium Universal Utility", Desc = "Platform-wide environment optimization and control matrix." })
ScriptSubSection:Button({ Title = "Copy Discord Server Invitation Link", Icon = "link", Callback = function() if setclipboard then setclipboard("https://discord.gg/cepheusx") WindUI:Notify({Title="Clipboard Updated", Content="Discord invite string saved successfully."}) end end })
local RuntimeSessionLabel = ScriptSubSection:Paragraph({ Title = "Session Runtime Monitoring: 00:00:00" })
ScriptSubSection:Paragraph({ Title = "Version Baseline: Last Updated June 2026" })
ScriptSubSection:Paragraph({ Title = "Operations Tutorial", Desc = "Toggle core execution matrices on or off using check switches. Adjust structural intensity fields with synchronized slider components or clear textual entries." })


local GameSubSection = InfoTab:Section({ Title = "Active Game Diagnostics" })
GameSubSection:Paragraph({ Title = "System Game ID: " .. tostring(game.GameId) })
GameSubSection:Button({ Title = "Place ID: " .. tostring(game.PlaceId) .. " | Job ID: " .. tostring(game.JobId) .. " (Click to Copy)", Callback = function() if setclipboard then setclipboard(tostring(game.PlaceId) .. " " .. tostring(game.JobId)) WindUI:Notify({Title="Copied", Content="Network identity codes written to clipboard."}) end end })
local ActiveDensityLabel = GameSubSection:Paragraph({ Title = "Instance Player Density Status: 0 / 0" })


-- ================================================================================
-- 2. PLAYER TAB ARCHITECTURE
-- ================================================================================
SetLoaderPhase("Assembling Physics Overrides...", 0.75)
local PlayerTab = Window:Tab({ Title = "Player", Icon = "solar:user-bold", Border = true })


local WalkSpeedControlSection = PlayerTab:Section({ Title = "WalkSpeed Control Matrix" })
WalkSpeedControlSection:Toggle({ Title = "Enable WalkSpeed Modification", Value = false, Callback = function(state) ScriptHubConfig.Player.WalkSpeedEnabled = state end })
WalkSpeedControlSection:Dropdown({ Title = "Select Physical Translation Method", Values = {"Humanoid", "CFrame", "Velocity", "TP Walk", "Pulse Walk", "Heartbeat Walk", "Tween Walk"}, Value = "Humanoid", Callback = function(selection) ScriptHubConfig.Player.WalkMethod = selection end })
CreateBidirectionalSync(WalkSpeedControlSection, "WalkSpeed Limit", "Player", "WalkSpeedValue", 0, 500, 16, 1)


local SwimOverrideSection = PlayerTab:Section({ Title = "Swim Override Configuration" })
SwimOverrideSection:Toggle({ Title = "Force Environment Swim State", Value = false, Callback = function(state) ScriptHubConfig.Player.SwimEnabled = state end })
CreateBidirectionalSync(SwimOverrideSection, "Forced Velocity Speed", "Player", "SwimSpeed", 0, 200, 50, 1)


local FlightMatrixSection = PlayerTab:Section({ Title = "Flight Engine Matrix" })
FlightMatrixSection:Toggle({ Title = "Activate Free Flight Engine", Value = false, Callback = function(state) ScriptHubConfig.Player.FlyEnabled = state end })
FlightMatrixSection:Dropdown({ Title = "Flight Simulation Routine", Values = {"Velocity Fly", "CFrame Fly", "Glide Mode"}, Value = "Velocity Fly", Callback = function(selection) ScriptHubConfig.Player.FlyMethod = selection end })
CreateBidirectionalSync(FlightMatrixSection, "Flight Speed Magnitude", "Player", "FlySpeed", 0, 500, 50, 1)


local WorldAlterationSection = PlayerTab:Section({ Title = "World Alteration Vectors" })
WorldAlterationSection:Toggle({ Title = "Override Engine Gravity Parameters", Value = false, Callback = function(state) ScriptHubConfig.Player.GravityEnabled = state end })
CreateBidirectionalSync(WorldAlterationSection, "Gravity Coordinate Force", "Player", "GravityValue", 0, 500, 196.2, 1)
WorldAlterationSection:Toggle({ Title = "Override HipHeight Scale Matrices", Value = false, Callback = function(state) ScriptHubConfig.Player.HipHeightEnabled = state end })
CreateBidirectionalSync(WorldAlterationSection, "HipHeight Displacement Scale", "Player", "HipHeightValue", -5, 100, 0, 0.1)


local TeleportationToolsSection = PlayerTab:Section({ Title = "Teleportation Tools Configuration" })
TeleportationToolsSection:Toggle({ Title = "Enable Interactive Mouse Click TP", Value = false, Callback = function(state) ScriptHubConfig.Player.ClickTPEnabled = state end })
TeleportationToolsSection:Dropdown({ Title = "Click Destination Interpolation Method", Values = {"CFrame", "Tween Linear", "Safe Raycast"}, Value = "CFrame", Callback = function(selection) ScriptHubConfig.Player.ClickTPMethod = selection end })


local UniversalUtilitiesSection = PlayerTab:Section({ Title = "Universal Traversal Utilities" })
UniversalUtilitiesSection:Toggle({ Title = "Noclip Boundary Collision Deflection", Callback = function(state) ScriptHubConfig.Player.Noclip = state end })
UniversalUtilitiesSection:Toggle({ Title = "Walk On Orthogonal Walls Normal Alignment", Callback = function(state) ScriptHubConfig.Player.WalkOnWalls = state end })
UniversalUtilitiesSection:Toggle({ Title = "Jerk Frame Interruption Routine (Anti-Aim Tracking)", Callback = function(state) ScriptHubConfig.Player.JerkEnabled = state end })
CreateBidirectionalSync(UniversalUtilitiesSection, "Jerk Interruption Power Vector", "Player", "JerkPower", 0, 50, 5, 1)
UniversalUtilitiesSection:Toggle({ Title = "Bunnyhop Automation Routine", Callback = function(state) ScriptHubConfig.Player.Bunnyhop = state end })
UniversalUtilitiesSection:Toggle({ Title = "Infinite Jump Coordinate Impulse Assertion", Callback = function(state) ScriptHubConfig.Player.InfiniteJump = state end })
UniversalUtilitiesSection:Toggle({ Title = "Anti-Sit Seat State Prevention Switch", Callback = function(state) ScriptHubConfig.Player.AntiSit = state end })
UniversalUtilitiesSection:Toggle({ Title = "Fling Self Internal Angular Disruption", Callback = function(state) ScriptHubConfig.Player.FlingSelf = state end })
UniversalUtilitiesSection:Toggle({ Title = "Anti-Ragdoll & Structural Balance Stabilization", Callback = function(state) ScriptHubConfig.Player.AntiRagdoll = state end })
UniversalUtilitiesSection:Toggle({ Title = "Spinbot Root Vector Rotation Matrix", Callback = function(state) ScriptHubConfig.Player.SpinbotEnabled = state end })
CreateBidirectionalSync(UniversalUtilitiesSection, "Spinbot Rotational Velocity Speed", "Player", "SpinbotSpeed", 1, 360, 20, 1)


local JumpControlSection = PlayerTab:Section({ Title = "Jump Impulse Controls" })
JumpControlSection:Toggle({ Title = "Override Jump Launch Forces", Callback = function(state) ScriptHubConfig.Player.JumpEnabled = state end })
JumpControlSection:Dropdown({ Title = "Jump Launch Execution Routine", Values = {"Humanoid Power", "Humanoid Height", "CFrame Launch", "Velocity Impulse"}, Value = "Humanoid Power", Callback = function(selection) ScriptHubConfig.Player.JumpMethod = selection end })
CreateBidirectionalSync(JumpControlSection, "Jump Output Power Value", "Player", "JumpValue", 0, 500, 50, 1)


-- ================================================================================
-- 3. VISUALS TAB ARCHITECTURE
-- ================================================================================
SetLoaderPhase("Configuring Graphics Pipeline...", 0.85)
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "solar:eye-bold", Border = true })


local ScreenModifiersSection = VisualsTab:Section({ Title = "Screen Pipeline Modifiers" })
ScreenModifiersSection:Toggle({ Title = "Xray Structural Transparency Override", Callback = function(state) ScriptHubConfig.Visuals.Xray = state end })
ScreenModifiersSection:Toggle({ Title = "FullBright Environment Full Illumination", Callback = function(state) ScriptHubConfig.Visuals.FullBright = state end })
ScreenModifiersSection:Toggle({ Title = "FPS Boost Structural De-rendering Optimizer", Callback = function(state) ScriptHubConfig.Visuals.FPSBoost = state end })
ScreenModifiersSection:Toggle({ Title = "No Render (Deactivate 3D Drawing Pipelines)", Callback = function(state) ScriptHubConfig.Visuals.NoRender = state RunService:Set3dRenderingEnabled(not state) end })
ScreenModifiersSection:Toggle({ Title = "Black Screen Background Farming Overlay", Callback = function(state)
   ScriptHubConfig.Visuals.BlackScreen = state
   if state then
       if not BlackScreenGUI then
           BlackScreenGUI = Instance.new("ScreenGui")
           BlackScreenGUI.IgnoreGuiInset = true
           BlackScreenGUI.DisplayOrder = 9998
           local FrameElement = Instance.new("Frame", BlackScreenGUI)
           FrameElement.Size = UDim2.new(1,0,1,0)
           FrameElement.BackgroundColor3 = Color3.new(0,0,0)
           local pcallSuccess, _ = pcall(function() BlackScreenGUI.Parent = GetSafeParent() end)
           if not pcallSuccess then BlackScreenGUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end
       end
   else
       if BlackScreenGUI then BlackScreenGUI:Destroy() BlackScreenGUI = nil end
   end
end })


local ESPCoreEngineSection = VisualsTab:Section({ Title = "ESP Core Graphic Drawing Engine" })
ESPCoreEngineSection:Toggle({ Title = "Master Activation Switch", Callback = function(state) ScriptHubConfig.Visuals.ESPEnabled = state end })
ESPCoreEngineSection:Toggle({ Title = "Tracers Rendering", Callback = function(state) ScriptHubConfig.Visuals.Tracers = state end })
ESPCoreEngineSection:Dropdown({ Title = "Tracer Line Origin Point Coordinate", Values = {"Cursor", "Bottom Center", "Screen Center"}, Value = "Bottom Center", Callback = function(selection) ScriptHubConfig.Visuals.TracerOrigin = selection end })
ESPCoreEngineSection:Toggle({ Title = "Bounding Boxes Rendering", Callback = function(state) ScriptHubConfig.Visuals.Boxes = state end })
ESPCoreEngineSection:Dropdown({ Title = "Box Projection Calculation Mode", Values = {"Standard 2D Box", "3D Bounding Box", "Face-Cam Locked 2D"}, Value = "Standard 2D Box", Callback = function(selection) ScriptHubConfig.Visuals.BoxMode = selection end })
ESPCoreEngineSection:Toggle({ Title = "Multi-Joint Skeleton Framework Rendering", Callback = function(state) ScriptHubConfig.Visuals.Skeleton = state end })
ESPCoreEngineSection:Toggle({ Title = "Player Name & Vector Distance Overlays", Callback = function(state) ScriptHubConfig.Visuals.NamesDistance = state end })
ESPCoreEngineSection:Toggle({ Title = "Numeric Health & Performance Bars", Callback = function(state) ScriptHubConfig.Visuals.Health = state end })
ESPCoreEngineSection:Toggle({ Title = "Chams / Object Core Highlight Effects", Callback = function(state) ScriptHubConfig.Visuals.Chams = state end })
ESPCoreEngineSection:Colorpicker({ Title = "Master System ESP Color Tint Configuration", Default = Color3.fromRGB(255,255,255), Callback = function(selectedColor) ScriptHubConfig.Visuals.ESPColor = selectedColor end })


-- ================================================================================
-- 4. UTILITY TAB ARCHITECTURE
-- ================================================================================
SetLoaderPhase("Assembling System Automations...", 0.9)
local UtilityTab = Window:Tab({ Title = "Utility", Icon = "solar:settings-bold", Border = true })


local AutoClickerEngineSection = UtilityTab:Section({ Title = "Virtual Controller AutoClicker Engine" })
AutoClickerEngineSection:Toggle({ Title = "Enable Background Action Clicks", Callback = function(state) ScriptHubConfig.Utility.AutoClicker = state end })
CreateBidirectionalSync(AutoClickerEngineSection, "Input Actions Per Second Interval", "Utility", "AutoClickInterval", 1, 100, 10, 1)


local AntiAFKSystemSection = UtilityTab:Section({ Title = "Anti-AFK Network Connection Keeper" })
AntiAFKSystemSection:Toggle({ Title = "Deactivate Server Idle Detection Timeout", Value = false, Callback = function(state) ScriptHubConfig.Utility.AntiAFK = state end })


local CustomToolsSection = UtilityTab:Section({ Title = "Interactive Tools & Chat Telemetry Modules" })
CustomToolsSection:Toggle({ Title = "Instantiate Local Click-Teleport Tool Item", Callback = function(state) ScriptHubConfig.Utility.ClickTPTool = state end })
CustomToolsSection:Toggle({ Title = "Activate Server Channel Chat Spammer Engine", Callback = function(state) ScriptHubConfig.Utility.ChatSpammer = state end })
CreateBidirectionalSync(CustomToolsSection, "Broadcast Delay Interval Timing (s)", "Utility", "SpammerInterval", 0.5, 60, 3, 0.5)
CustomToolsSection:Input({ Title = "Chat Message String Payload", Value = ScriptHubConfig.Utility.SpammerText, Callback = function(textInput) ScriptHubConfig.Utility.SpammerText = textInput end })


-- ================================================================================
-- 5. TROLL TAB ARCHITECTURE
-- ================================================================================
SetLoaderPhase("Assembling Troll Features...", 0.95)
local TrollTab = Window:Tab({ Title = "Troll", Icon = "solar:ghost-bold", Border = true })


local TargetConfigurationSection = TrollTab:Section({ Title = "Target Identification Configuration" })
local DiscoveredPlayerNamesCache = {}
local function SynchronizeServerPlayerDictionary()
   DiscoveredPlayerNamesCache = {}
   for _, discoveredPlayer in ipairs(Players:GetPlayers()) do
       if discoveredPlayer ~= LocalPlayer then
           table.insert(DiscoveredPlayerNamesCache, discoveredPlayer.Name)
       end
   end
end
SynchronizeServerPlayerDictionary()


local TargetDropdownMulti = TargetConfigurationSection:Dropdown({ Title = "Target Evaluation Roster (Multi-Choice Selection)", Values = DiscoveredPlayerNamesCache, Multi = true, Callback = function(selectedList) ScriptHubConfig.Troll.Targets = selectedList end })
local TargetDropdownSingle = TargetConfigurationSection:Dropdown({ Title = "Target Evaluation Entity (Single Choice Selection)", Values = DiscoveredPlayerNamesCache, Value = "None", Callback = function(selection) ScriptHubConfig.Troll.OrbitTarget = selection; ScriptHubConfig.Troll.FollowTarget = selection; ScriptHubConfig.Troll.StandTarget = selection end })


TargetConfigurationSection:Button({ Title = "Forcibly Re-Poll Instance Player Array Roster", Callback = function()
   SynchronizeServerPlayerDictionary()
   TargetDropdownMulti:Refresh(DiscoveredPlayerNamesCache)
   TargetDropdownSingle:Refresh(DiscoveredPlayerNamesCache)
end })


local FlingAttacksSection = TrollTab:Section({ Title = "Fling Disruption Vector Attacks" })
FlingAttacksSection:Toggle({ Title = "Execute Fling Vector Cycles On Target Roster", Callback = function(state) ScriptHubConfig.Troll.Fling = state end })


local InteractionsSection = TrollTab:Section({ Title = "Positional Coordinate Interceptions & Stalking Systems" })
InteractionsSection:Toggle({ Title = "Headsit Structural Mount Coordinate Overlay", Callback = function(state) ScriptHubConfig.Troll.Headsit = state end })
InteractionsSection:Toggle({ Title = "Platform Target Pathing Construction Block", Callback = function(state) ScriptHubConfig.Troll.Platform = state end })
InteractionsSection:Toggle({ Title = "Jumpblock Target Cap Acceleration Suspension", Callback = function(state) ScriptHubConfig.Troll.Jumpblock = state end })


InteractionsSection:Toggle({ Title = "Orbit Player Coordinate Loop Routine", Callback = function(state) ScriptHubConfig.Troll.Orbit = state end })
CreateBidirectionalSync(InteractionsSection, "Orbit Radius Displacement Distance", "Troll", "OrbitDistance", 1, 50, 5, 1)
CreateBidirectionalSync(InteractionsSection, "Orbit Rotational Speed Vector Velocity", "Troll", "OrbitSpeed", 1, 50, 5, 1)


InteractionsSection:Toggle({ Title = "Follow & Mirror Vector Mechanics", Callback = function(state) ScriptHubConfig.Troll.Follow = state end })
InteractionsSection:Toggle({ Title = "Stand Mode Guardian Entity Entity Emulation", Callback = function(state) ScriptHubConfig.Troll.StandMode = state end })
CreateBidirectionalSync(InteractionsSection, "Stand Rear Offset Spatial Axis Distance", "Troll", "StandDistance", 1, 20, 3, 1)


-- ================================================================================
-- 5b. TELEPORT TAB
-- ================================================================================
local TeleportSection = Window:Section({ Title = "Teleport" })
local TeleportTab = TeleportSection:Tab({
   Title = "Teleport",
   Icon = "map-pin",
   IconColor = Colors.Yellow,
   IconShape = "Square",
   Border = true,
})

-- Dropdown for location selection
TeleportTab:Dropdown({
   Title = "Teleport Location",
   Desc = "Select a place to teleport",
   Values = {
      {
         Title = "Spawn Point",
         Icon = "home",
         Callback = function()
            local spawnLocation = workspace:FindFirstChild("SpawnLocation")
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
               char.HumanoidRootPart.CFrame = spawnLocation and spawnLocation.CFrame or CFrame.new(0, 5, 0)
            end
            WindUI:Notify({ Title = "Teleported", Content = "Moved to Spawn Point", Icon = "home", Duration = 2 })
         end,
      },
      {
         Title = "Shop",
         Icon = "shopping-cart",
         Callback = function()
            WindUI:Notify({ Title = "Teleport", Content = "No shop location defined for this game.", Icon = "shopping-cart", Duration = 2 })
         end,
      },
      { Type = "Divider" },
      {
         Title = "Secret Area",
         Icon = "lock",
         Locked = true,
         Callback = function()
            WindUI:Notify({ Title = "Locked", Content = "Secret area not available.", Icon = "lock", Duration = 2 })
         end,
      },
   },
})

TeleportTab:Space()

local TpCustomSection = TeleportTab:Section({
   Title = "Custom Teleport",
   Box = true,
   BoxBorder = true,
   Opened = true,
})

local tpCoordX, tpCoordY, tpCoordZ = 0, 0, 0

TpCustomSection:Input({
   Title = "X Coordinate",
   Placeholder = "Enter X...",
   Callback = function(v) tpCoordX = tonumber(v) or 0 end,
})

TpCustomSection:Space()

TpCustomSection:Input({
   Title = "Y Coordinate",
   Placeholder = "Enter Y...",
   Callback = function(v) tpCoordY = tonumber(v) or 0 end,
})

TpCustomSection:Space()

TpCustomSection:Input({
   Title = "Z Coordinate",
   Placeholder = "Enter Z...",
   Callback = function(v) tpCoordZ = tonumber(v) or 0 end,
})

TpCustomSection:Space()

TpCustomSection:Button({
   Title = "Teleport to Coordinates",
   Icon = "navigation",
   Color = Colors.Blue,
   Justify = "Center",
   Callback = function()
      local char = LocalPlayer.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         char.HumanoidRootPart.CFrame = CFrame.new(tpCoordX, tpCoordY, tpCoordZ)
         WindUI:Notify({
            Title = "Teleported",
            Content = string.format("Moved to (%.0f, %.0f, %.0f)", tpCoordX, tpCoordY, tpCoordZ),
            Icon = "map-pin",
            Duration = 3,
         })
      end
   end,
})


-- ================================================================================
-- 6. SETTINGS TAB ARCHITECTURE
-- ================================================================================
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "solar:file-cog-bold", Border = true })
-- UI Settings section
local UISettingsSection = SettingsTab:Section({
   Title = "UI Settings",
   Box = true,
   BoxBorder = true,
   Opened = true,
})

UISettingsSection:Keybind({
   Title = "Toggle Key",
   Desc = "Keybind to open/close the hub",
   Value = "RightShift",
   Callback = function(v)
      Window:SetToggleKey(Enum.KeyCode[v])
      WindUI:Notify({
         Title = "Toggle Key",
         Content = "Set to " .. v,
         Icon = "keyboard",
         Duration = 2,
      })
   end,
})

UISettingsSection:Space()

UISettingsSection:Toggle({
   Title = "Transparency",
   Desc = "Enable glassmorphism effect",
   Value = true,
   Callback = function(state)
      Window:ToggleTransparency(state)
   end,
})

UISettingsSection:Space()

UISettingsSection:Toggle({
   Title = "Resizable Window",
   Value = true,
   Callback = function(state)
      Window:IsResizable(state)
   end,
})

UISettingsSection:Space()

UISettingsSection:Toggle({
   Title = "Panel Background",
   Value = not Window.HidePanelBackground,
   Callback = function(state)
      Window:SetPanelBackground(state)
   end,
})

SettingsTab:Space()

-- Config section
local RuntimeConfigStorageManager = Window.ConfigManager
local ActiveProfileFileName = "CepheusXDefaultProfile"

local ConfigSection = SettingsTab:Section({
   Title = "Config System",
   Box = true,
   BoxBorder = true,
   Opened = true,
})

if not RunService:IsStudio() and writefile then
   local ConfigNameInput = ConfigSection:Input({
      Title = "Config Name",
      Icon = "file-cog",
      Placeholder = "Enter config name...",
      Value = ActiveProfileFileName,
      Callback = function(value)
         ActiveProfileFileName = value
      end,
   })

   ConfigSection:Space()

   local AllConfigs = RuntimeConfigStorageManager:AllConfigs()
   local DefaultValue = table.find(AllConfigs, ActiveProfileFileName) and ActiveProfileFileName or nil

   local ProfileListingDropdown = ConfigSection:Dropdown({
      Title = "Saved Configs",
      Desc = "Select an existing config",
      Values = AllConfigs,
      Value = DefaultValue,
      Callback = function(value)
         ActiveProfileFileName = value
         ConfigNameInput:Set(value)
      end,
   })

   ConfigSection:Space()

   ConfigSection:Button({
      Title = "Save",
      Icon = "",
      Color = Colors.Green,
      Justify = "Center",
      Callback = function()
         Window.CurrentConfig = RuntimeConfigStorageManager:Config(ActiveProfileFileName)
         if Window.CurrentConfig:Save() then
            WindUI:Notify({
               Title = "Config Saved",
               Content = "'" .. ActiveProfileFileName .. "' saved successfully",
               Icon = "check",
               Duration = 3,
            })
         end
         ProfileListingDropdown:Refresh(RuntimeConfigStorageManager:AllConfigs())
      end,
   })

   ConfigSection:Space()

   ConfigSection:Button({
      Title = "Load",
      Icon = "",
      Color = Colors.Blue,
      Justify = "Center",
      Callback = function()
         Window.CurrentConfig = RuntimeConfigStorageManager:CreateConfig(ActiveProfileFileName)
         if Window.CurrentConfig:Load() then
            WindUI:Notify({
               Title = "Config Loaded",
               Content = "'" .. ActiveProfileFileName .. "' loaded",
               Icon = "refresh-cw",
               Duration = 3,
            })
         end
      end,
   })
else
   ConfigSection:Section({
      Title = "Config system requires an executor with file system support.",
      TextSize = 14,
      TextTransparency = 0.4,
   })
end

SettingsTab:Space()

-- Destroy confirmation dialog
local DestroyDialog = Window:Dialog({
   Icon = "alert-triangle",
   Title = "Destroy Hub?",
   Content = "This will completely remove the UI. Are you sure?",
   Buttons = {
      {
         Title = "Cancel",
         Callback = function() end,
      },
      {
         Title = "Destroy",
         Callback = function()
            Window:Destroy()
         end,
      },
   },
})

SettingsTab:Button({
   Title = "Destroy Hub (with confirmation)",
   Icon = "shredder",
   Color = Colors.Red,
   Justify = "Center",
   Callback = function()
      DestroyDialog:Show()
   end,
})


-- ================================================================================
-- 7. CREDITS TAB ARCHITECTURE
-- ================================================================================
local CreditsSection = Window:Section({ Title = "Credits" })
local CreditsTab = CreditsSection:Tab({
   Title = "Credits",
   Icon = "solar:stars-bold",
   IconColor = Colors.Grey,
   IconShape = "Square",
   Border = true,
})

CreditsTab:Section({
   Title = "Cepheus X Hub",
   TextSize = 24,
   FontWeight = Enum.FontWeight.SemiBold,
})

CreditsTab:Space()

CreditsTab:Section({
   Title = "Built with WindUI — a modern, open-source UI library for Roblox.\nDeveloped by the Cepheus Team.",
   TextSize = 16,
   TextTransparency = 0.35,
   FontWeight = Enum.FontWeight.Medium,
})

CreditsTab:Space({ Columns = 3 })

CreditsTab:Paragraph({
   Title = "WindUI",
   Desc = "UI Library by Footagesus (.ftgs)",
})

CreditsTab:Space()

CreditsTab:Paragraph({
   Title = "Lucide Icons",
   Desc = "Open source icon set used throughout the hub",
})

CreditsTab:Space()

CreditsTab:Paragraph({ Title = "Project CepheusX Core Systems Architect Crew", Desc = "Execution framework standardization and clean multi-module loop development routines." })

CreditsTab:Space()

CreditsTab:Paragraph({ Title = "WindUI Visual Framework UI Engine Contributors", Desc = "Open source graphical design asset pipelines and core components framework." })

CreditsTab:Space({ Columns = 3 })

CreditsTab:Button({
   Title = "Made with ❤ using WindUI",
   Icon = "star",
   Color = Colors.Cyan,
   Justify = "Center",
   Callback = function()
      WindUI:Notify({
         Title = "Credits",
         Content = "Cepheus X Hub — Powered by WindUI v" .. (WindUI.Version or "1.0"),
         Icon = "star",
         Duration = 5,
      })
   end,
})


-- ================================================================================
-- SYSTEM EXECUTION LOOPS & BACKGROUND PROCESS ENGINES (Zero Bug Specifications)
-- ================================================================================


-- Info Monitoring Loop
task.spawn(function()
   while task.wait(1) do
       local runClockSeconds = os.clock() - StartTime
       local calcHours = math.floor(runClockSeconds / 3600)
       local calcMinutes = math.floor((runClockSeconds % 3600) / 60)
       local calcSeconds = math.floor(runClockSeconds % 60)
       if RuntimeSessionLabel then
           RuntimeSessionLabel:SetTitle(string.format("Session Runtime Monitoring: %02d:%02d:%02d", calcHours, calcMinutes, calcSeconds))
       end
       if ActiveDensityLabel then
           ActiveDensityLabel:SetTitle("Instance Player Density Status: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)
       end
   end
end)


-- Heartbeat Physics Frame Synchronization Connection
table.insert(CoreConnections, RunService.Heartbeat:Connect(function(deltaTime)
   local activeCharacter = LocalPlayer.Character
   if not activeCharacter then return end
   local rootPart = activeCharacter:FindFirstChild("HumanoidRootPart")
   local humanoidObject = activeCharacter:FindFirstChildOfClass("Humanoid")
   if not rootPart or not humanoidObject then return end


   -- Anti-Ragdoll & Fall Prevention Mechanics
   if ScriptHubConfig.Player.AntiRagdoll then
       humanoidObject:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
       humanoidObject:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
       if humanoidObject:GetState() == Enum.HumanoidStateType.Ragdoll or humanoidObject:GetState() == Enum.HumanoidStateType.FallingDown then
           humanoidObject:ChangeState(Enum.HumanoidStateType.GettingUp)
       end
   end


   -- WalkSpeed Physics Manipulations Matrix
   if ScriptHubConfig.Player.WalkSpeedEnabled then
       local targetedSpeed = ScriptHubConfig.Player.WalkSpeedValue
       local activeWalkMethod = ScriptHubConfig.Player.WalkMethod
       local directionVector = humanoidObject.MoveDirection


       if activeWalkMethod == "Humanoid" then
           humanoidObject.WalkSpeed = targetedSpeed
       elseif activeWalkMethod == "Velocity" then
           if directionVector.Magnitude > 0 then
               rootPart.Velocity = Vector3.new(directionVector.X * targetedSpeed, rootPart.Velocity.Y, directionVector.Z * targetedSpeed)
           end
       elseif activeWalkMethod == "CFrame" then
           if directionVector.Magnitude > 0 then
               rootPart.CFrame = rootPart.CFrame + (directionVector * (targetedSpeed * deltaTime))
           end
       elseif activeWalkMethod == "TP Walk" then
           if directionVector.Magnitude > 0 then
               rootPart.CFrame = rootPart.CFrame + (directionVector * (targetedSpeed * 0.1))
               task.wait(0.02)
           end
       elseif activeWalkMethod == "Pulse Walk" then
           if directionVector.Magnitude > 0 then
               rootPart.Velocity = directionVector * (targetedSpeed * 1.8)
               task.wait(0.01)
               rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
           end
       elseif activeWalkMethod == "Heartbeat Walk" then
           if directionVector.Magnitude > 0 then
               rootPart.Position = rootPart.Position + (directionVector * (targetedSpeed * deltaTime))
           end
       elseif activeWalkMethod == "Tween Walk" then
           if directionVector.Magnitude > 0 then
               TweenService:Create(rootPart, TweenInfo.new(deltaTime, Enum.EasingStyle.Linear), {CFrame = rootPart.CFrame + (directionVector * targetedSpeed * deltaTime)}):Play()
           end
       end
   end


   -- Swimming State Override Process
   if ScriptHubConfig.Player.SwimEnabled then
       humanoidObject:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
       humanoidObject:ChangeState(Enum.HumanoidStateType.Swimming)
       local movingDirection = humanoidObject.MoveDirection
       if movingDirection.Magnitude > 0 then
           rootPart.Velocity = movingDirection * ScriptHubConfig.Player.SwimSpeed
       else
           rootPart.Velocity = Vector3.new(0,0,0)
       end
   end


   -- Advanced Flight Simulation Matrix Handler
   if ScriptHubConfig.Player.FlyEnabled then
       local viewingAngleLook = Camera.CFrame.LookVector
       local viewingAngleRight = Camera.CFrame.RightVector
       local viewingAngleUp = Camera.CFrame.UpVector
       local compiledFlightVector = Vector3.new(0,0,0)
      
       if UserInputService:IsKeyDown(Enum.KeyCode.W) then compiledFlightVector = compiledFlightVector + viewingAngleLook end
       if UserInputService:IsKeyDown(Enum.KeyCode.S) then compiledFlightVector = compiledFlightVector - viewingAngleLook end
       if UserInputService:IsKeyDown(Enum.KeyCode.A) then compiledFlightVector = compiledFlightVector - viewingAngleRight end
       if UserInputService:IsKeyDown(Enum.KeyCode.D) then compiledFlightVector = compiledFlightVector + viewingAngleRight end
       if UserInputService:IsKeyDown(Enum.KeyCode.Space) then compiledFlightVector = compiledFlightVector + viewingAngleUp end
       if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then compiledFlightVector = compiledFlightVector - viewingAngleUp end


       local typeFlightMethod = ScriptHubConfig.Player.FlyMethod
       if typeFlightMethod == "Velocity Fly" then
           if not FlyBV then
               FlyBV = Instance.new("BodyVelocity", rootPart)
               FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
           end
           if not FlyBG then
               FlyBG = Instance.new("BodyGyro", rootPart)
               FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
               FlyBG.P = 1e4
           end
           FlyBV.Velocity = compiledFlightVector.Magnitude > 0 and (compiledFlightVector.Unit * ScriptHubConfig.Player.FlySpeed) or Vector3.new(0,0,0)
           FlyBG.CFrame = Camera.CFrame
       elseif typeFlightMethod == "CFrame Fly" or typeFlightMethod == "Glide Mode" then
           if FlyBV then FlyBV:Destroy() FlyBV = nil end
           if FlyBG then FlyBG:Destroy() FlyBG = nil end
           rootPart.Velocity = (typeFlightMethod == "Glide Mode") and Vector3.new(0, 0.1, 0) or Vector3.new(0,0,0)
           if compiledFlightVector.Magnitude > 0 then
               rootPart.CFrame = rootPart.CFrame + (compiledFlightVector.Unit * ScriptHubConfig.Player.FlySpeed * deltaTime)
           end
       end
   else
       if FlyBV then FlyBV:Destroy() FlyBV = nil end
       if FlyBG then FlyBG:Destroy() FlyBG = nil end
   end


   -- Dynamic Jump Power Execution Routines
   if ScriptHubConfig.Player.JumpEnabled then
       humanoidObject.UseJumpPower = (ScriptHubConfig.Player.JumpMethod == "Humanoid Power")
       if ScriptHubConfig.Player.JumpMethod == "Humanoid Power" then
           humanoidObject.JumpPower = ScriptHubConfig.Player.JumpValue
       elseif ScriptHubConfig.Player.JumpMethod == "Humanoid Height" then
           humanoidObject.JumpHeight = ScriptHubConfig.Player.JumpValue
       end
   end


   if ScriptHubConfig.Player.Bunnyhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and humanoidObject.FloorMaterial ~= Enum.Material.Air then
       humanoidObject:ChangeState(Enum.HumanoidStateType.Jumping)
   end


   -- Base World Attributes Modifications
   if ScriptHubConfig.Player.HipHeightEnabled then humanoidObject.HipHeight = ScriptHubConfig.Player.HipHeightValue end
   workspace.Gravity = ScriptHubConfig.Player.GravityEnabled and ScriptHubConfig.Player.GravityValue or 196.2


   -- Interaction Prevention Routines & Deflections
   if ScriptHubConfig.Player.AntiSit and humanoidObject.Sit then humanoidObject.Sit = false end
   if ScriptHubConfig.Player.FlingSelf then rootPart.RotVelocity = Vector3.new(0, 9e9, 0) rootPart.Velocity = Vector3.new(9e9, 0, 9e9) end
   if ScriptHubConfig.Player.SpinbotEnabled then rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(ScriptHubConfig.Player.SpinbotSpeed), 0) end
   if ScriptHubConfig.Player.JerkEnabled then
       rootPart.CFrame = rootPart.CFrame * CFrame.new(math.random(-ScriptHubConfig.Player.JerkPower, ScriptHubConfig.Player.JerkPower)/10, 0, math.random(-ScriptHubConfig.Player.JerkPower, ScriptHubConfig.Player.JerkPower)/10)
   end


   -- Walk on Walls Orientation Vectors Calculations
   if ScriptHubConfig.Player.WalkOnWalls then
       local wallRayParams = RaycastParams.new()
       wallRayParams.FilterDescendantsInstances = {activeCharacter}
       local detectedSurfaceRay = workspace:Raycast(rootPart.Position, rootPart.CFrame.LookVector * 5 + Vector3.new(0, -4, 0), wallRayParams)
       if detectedSurfaceRay then
           rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + rootPart.CFrame.LookVector, detectedSurfaceRay.Normal)
       end
   end


   -- Advanced Target Disruption Loop Implementations
   local evaluatedSingleTargetName = ScriptHubConfig.Troll.OrbitTarget
   local resolvedTargetPlayer = (evaluatedSingleTargetName ~= "None" and Players:FindFirstChild(evaluatedSingleTargetName)) or nil
   if resolvedTargetPlayer and resolvedTargetPlayer.Character and resolvedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
       local targetRootPart = resolvedTargetPlayer.Character.HumanoidRootPart
      
       if ScriptHubConfig.Troll.Orbit then
           local calculatedOrbitSpeed = ScriptHubConfig.Troll.OrbitSpeed
           local calculatedOrbitRadius = ScriptHubConfig.Troll.OrbitDistance
           local timeTrackingTick = os.clock() * calculatedOrbitSpeed
           rootPart.CFrame = targetRootPart.CFrame * CFrame.new(math.sin(timeTrackingTick) * calculatedOrbitRadius, 0, math.cos(timeTrackingTick) * calculatedOrbitRadius)
       elseif ScriptHubConfig.Troll.Follow then
           rootPart.CFrame = rootPart.CFrame:Lerp(targetRootPart.CFrame * CFrame.new(0, 0, 3), deltaTime * 12)
       elseif ScriptHubConfig.Troll.StandMode then
           local calculationStandOffsetDistance = ScriptHubConfig.Troll.StandDistance
           rootPart.CFrame = targetRootPart.CFrame * CFrame.new(2, 2, calculationStandOffsetDistance)
       elseif ScriptHubConfig.Troll.Headsit then
           local targetedHeadPart = resolvedTargetPlayer.Character:FindFirstChild("Head")
           if targetedHeadPart then rootPart.CFrame = targetedHeadPart.CFrame * CFrame.new(0, 1.6, 0) end
       end


       -- Pathing Intervention Spawning Blocks
       if ScriptHubConfig.Troll.Platform then
           local searchPlatform = workspace:FindFirstChild("CepheusTrollPlatform_" .. resolvedTargetPlayer.Name)
           if not searchPlatform then
               searchPlatform = Instance.new("Part", workspace)
               searchPlatform.Name = "CepheusTrollPlatform_" .. resolvedTargetPlayer.Name
               searchPlatform.Size = Vector3.new(6, 0.5, 6)
               searchPlatform.Anchored = true
               searchPlatform.Transparency = 0.6
               searchPlatform.Material = Enum.Material.Glass
           end
           searchPlatform.Position = targetRootPart.Position - Vector3.new(0, 3.2, 0)
       end


       if ScriptHubConfig.Troll.Jumpblock then
           local searchJumpblock = workspace:FindFirstChild("CepheusTrollJumpblock_" .. resolvedTargetPlayer.Name)
           if not searchJumpblock then
               searchJumpblock = Instance.new("Part", workspace)
               searchJumpblock.Name = "CepheusTrollJumpblock_" .. resolvedTargetPlayer.Name
               searchJumpblock.Size = Vector3.new(5, 0.5, 5)
               searchJumpblock.Anchored = true
               searchJumpblock.Transparency = 0.8
               searchJumpblock.Color = Color3.fromRGB(255, 0, 0)
           end
           searchJumpblock.Position = targetRootPart.Position + Vector3.new(0, 4.5, 0)
       end
   else
       -- Teardown platform artifacts if single target cleared
       for _, oldEntity in ipairs(workspace:GetChildren()) do
           if oldEntity.Name:sub(1, 21) == "CepheusTrollPlatform_" or oldEntity.Name:sub(1, 22) == "CepheusTrollJumpblock_" then
               oldEntity:Destroy()
           end
       end
   end


   -- Multi-Target Loop Configuration For Fling Operations
   if ScriptHubConfig.Troll.Fling then
       for _, activeSelectedName in ipairs(ScriptHubConfig.Troll.Targets) do
           local matchedPlayerEntity = Players:FindFirstChild(activeSelectedName)
           if matchedPlayerEntity and matchedPlayerEntity.Character and matchedPlayerEntity.Character:FindFirstChild("HumanoidRootPart") then
               rootPart.CFrame = matchedPlayerEntity.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1,1)/10, 0, math.random(-1,1)/10)
               rootPart.Velocity = Vector3.new(math.huge,math.huge,math.huge)
               rootPart.RotVelocity = Vector3.new(math.huge,math.huge,math.huge)
           end
       end
   end
end))


-- Noclip Execution Frame Step Connection
table.insert(CoreConnections, RunService.Stepped:Connect(function()
   if ScriptHubConfig.Player.Noclip and LocalPlayer.Character then
       for _, characterDescendant in ipairs(LocalPlayer.Character:GetDescendants()) do
           if characterDescendant:IsA("BasePart") and characterDescendant.CanCollide then
               characterDescendant.CanCollide = false
           end
       end
   end
end))


-- User Input Vector Interceptions
table.insert(CoreConnections, UserInputService.InputBegan:Connect(function(inputEvent, contextProcessed)
   if contextProcessed then return end
  
   -- Mouse Processing Click TP Systems
   if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 and ScriptHubConfig.Player.ClickTPEnabled then
       local validationCharacter = LocalPlayer.Character
       if validationCharacter and validationCharacter:FindFirstChild("HumanoidRootPart") then
           local activeHrp = validationCharacter.HumanoidRootPart
           local worldTargetPosition = Mouse.Hit.Position
          
           if ScriptHubConfig.Player.ClickTPMethod == "CFrame" then
               activeHrp.CFrame = CFrame.new(worldTargetPosition + Vector3.new(0, 3, 0))
           elseif ScriptHubConfig.Player.ClickTPMethod == "Tween Linear" then
               TweenService:Create(activeHrp, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {CFrame = CFrame.new(worldTargetPosition + Vector3.new(0, 3, 0))}):Play()
           elseif ScriptHubConfig.Player.ClickTPMethod == "Safe Raycast" then
               local calculationRayParams = RaycastParams.new()
               calculationRayParams.FilterDescendantsInstances = {validationCharacter}
               local surfaceVerifyRay = workspace:Raycast(Camera.CFrame.Position, (worldTargetPosition - Camera.CFrame.Position).Unit * 1000, calculationRayParams)
               if surfaceVerifyRay then
                   activeHrp.CFrame = CFrame.new(surfaceVerifyRay.Position + Vector3.new(0, 3, 0))
               end
           end
       end
   end


   -- Frame Coordinate Jump Spikes (Infinite Jump Intercept)
   if inputEvent.KeyCode == Enum.KeyCode.Space and ScriptHubConfig.Player.InfiniteJump then
       local currentCharacterVerification = LocalPlayer.Character
       if currentCharacterVerification and currentCharacterVerification:FindFirstChildOfClass("Humanoid") then
           local targetHrp = currentCharacterVerification.HumanoidRootPart
           local targetHum = currentCharacterVerification:FindFirstChildOfClass("Humanoid")
          
           if ScriptHubConfig.Player.JumpMethod == "Velocity Impulse" then
               targetHrp.Velocity = Vector3.new(targetHrp.Velocity.X, ScriptHubConfig.Player.JumpValue, targetHrp.Velocity.Z)
           elseif ScriptHubConfig.Player.JumpMethod == "CFrame Launch" then
               targetHrp.CFrame = targetHrp.CFrame + Vector3.new(0, ScriptHubConfig.Player.JumpValue * 0.2, 0)
           else
               targetHum:ChangeState(Enum.HumanoidStateType.Jumping)
           end
       end
   end
end))


-- Visual Render Engine Transformations Mapping Loop
table.insert(CoreConnections, RunService.RenderStepped:Connect(function()
   if ScriptHubConfig.Visuals.FullBright then
       Lighting.Ambient = Color3.new(1, 1, 1)
       Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
       Lighting.FogEnd = math.huge
   else
       Lighting.Ambient = OriginalLighting.Ambient
       Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
       Lighting.FogEnd = OriginalLighting.FogEnd
   end


   if ScriptHubConfig.Visuals.Xray then
       for _, targetPart in ipairs(workspace:GetDescendants()) do
           if targetPart:IsA("BasePart") and not OriginalParts[targetPart] and not targetPart:IsUnderStageCheck() then
               OriginalParts[targetPart] = targetPart.Transparency
               targetPart.Transparency = 0.5
           end
       end
   else
       for originalPartReference, baselineTransparency in pairs(OriginalParts) do
           if originalPartReference and originalPartReference.Parent then
               originalPartReference.Transparency = baselineTransparency
           end
       end
       table.clear(OriginalParts)
   end
end))


-- 2D Core ESP Vector Calculations & Highlights Operations Loop
table.insert(CoreConnections, RunService.RenderStepped:Connect(function()
   for activeCachedPlayer, internalDrawingGroup in pairs(CacheESP.Drawings) do
       if not ScriptHubConfig.Visuals.ESPEnabled or not activeCachedPlayer.Character or not activeCachedPlayer.Character:FindFirstChild("HumanoidRootPart") or activeCachedPlayer.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
           for _, vectorGraphicObject in pairs(internalDrawingGroup) do
               vectorGraphicObject.Visible = false
           end
       end
   end


   if not ScriptHubConfig.Visuals.ESPEnabled then return end


   for _, trackingPlayer in ipairs(Players:GetPlayers()) do
       if trackingPlayer ~= LocalPlayer and trackingPlayer.Character and trackingPlayer.Character:FindFirstChild("HumanoidRootPart") then
           local evaluatedHrp = trackingPlayer.Character.HumanoidRootPart
           local evaluatedHead = trackingPlayer.Character:FindFirstChild("Head")
           local evaluatedHum = trackingPlayer.Character:FindFirstChildOfClass("Humanoid")
           if not evaluatedHrp or not evaluatedHead or not evaluatedHum or evaluatedHum.Health <= 0 then continue end


           local vectorRootScreen, isObjectVisibleOnViewport = Camera:WorldToViewportPoint(evaluatedHrp.Position)
           local vectorHeadScreen = Camera:WorldToViewportPoint(evaluatedHead.Position + Vector3.new(0, 0.6, 0))
           local vectorLegsScreen = Camera:WorldToViewportPoint(evaluatedHrp.Position - Vector3.new(0, 3, 0))
           local totalHeightBounds = math.abs(vectorHeadScreen.Y - vectorLegsScreen.Y)
           local totalWidthBounds = totalHeightBounds / 1.8


           if not CacheESP.Drawings[trackingPlayer] then
               CacheESP.Drawings[trackingPlayer] = {
                   Box = Drawing.new("Square"),
                   Tracer = Drawing.new("Line"),
                   Name = Drawing.new("Text")
               }
               CacheESP.Drawings[trackingPlayer].Box.Thickness = 1
               CacheESP.Drawings[trackingPlayer].Box.Filled = false
               CacheESP.Drawings[trackingPlayer].Tracer.Thickness = 1
               CacheESP.Drawings[trackingPlayer].Name.Size = 13
               CacheESP.Drawings[trackingPlayer].Name.Center = true
               CacheESP.Drawings[trackingPlayer].Name.Outline = true
           end
          
           local activeDrawGroup = CacheESP.Drawings[trackingPlayer]
           if isObjectVisibleOnViewport then
               local currentGlobalColorTint = ScriptHubConfig.Visuals.ESPColor
              
               activeDrawGroup.Box.Visible = ScriptHubConfig.Visuals.Boxes
               if activeDrawGroup.Box.Visible then
                   activeDrawGroup.Box.Size = Vector2.new(totalWidthBounds, totalHeightBounds)
                   activeDrawGroup.Box.Position = Vector2.new(vectorRootScreen.X - totalWidthBounds/2, vectorRootScreen.Y - totalHeightBounds/2)
                   activeDrawGroup.Box.Color = currentGlobalColorTint
               end


               activeDrawGroup.Tracer.Visible = ScriptHubConfig.Visuals.Tracers
               if activeDrawGroup.Tracer.Visible then
                   activeDrawGroup.Tracer.Color = currentGlobalColorTint
                   if ScriptHubConfig.Visuals.TracerOrigin == "Cursor" then
                       activeDrawGroup.Tracer.From = UserInputService:GetMouseLocation()
                   elseif ScriptHubConfig.Visuals.TracerOrigin == "Screen Center" then
                       activeDrawGroup.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                   else
                       activeDrawGroup.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                   end
                   activeDrawGroup.Tracer.To = Vector2.new(vectorRootScreen.X, vectorRootScreen.Y + totalHeightBounds/2)
               end


               activeDrawGroup.Name.Visible = ScriptHubConfig.Visuals.NamesDistance
               if activeDrawGroup.Name.Visible then
                   local realMagnitudeDistance = math.floor((Camera.CFrame.Position - evaluatedHrp.Position).Magnitude)
                   activeDrawGroup.Name.Text = string.format("%s [%dm] HP:%d", trackingPlayer.Name, realMagnitudeDistance, math.floor(evaluatedHum.Health))
                   activeDrawGroup.Name.Position = Vector2.new(vectorRootScreen.X, vectorRootScreen.Y - totalHeightBounds/2 - 16)
                   activeDrawGroup.Name.Color = currentGlobalColorTint
               end
           else
               activeDrawGroup.Box.Visible = false
               activeDrawGroup.Tracer.Visible = false
               activeDrawGroup.Name.Visible = false
           end
          
           if ScriptHubConfig.Visuals.Chams then
               if not CacheESP.Chams[trackingPlayer] then
                   local targetHighlightInstance = Instance.new("Highlight")
                   targetHighlightInstance.FillTransparency = 0.4
                   targetHighlightInstance.OutlineTransparency = 0
                   local verifyParentPcall, _ = pcall(function() targetHighlightInstance.Parent = GetSafeParent() end)
                   if not verifyParentPcall then targetHighlightInstance.Parent = LocalPlayer:WaitForChild("PlayerGui") end
                   CacheESP.Chams[trackingPlayer] = targetHighlightInstance
               end
               CacheESP.Chams[trackingPlayer].Adornee = trackingPlayer.Character
               CacheESP.Chams[trackingPlayer].FillColor = ScriptHubConfig.Visuals.ESPColor
               CacheESP.Chams[trackingPlayer].OutlineColor = ScriptHubConfig.Visuals.ESPColor
           else
               if CacheESP.Chams[trackingPlayer] then
                   CacheESP.Chams[trackingPlayer]:Destroy()
                   CacheESP.Chams[trackingPlayer] = nil
               end
           end
       end
   end
end))


-- Background AutoClicker Virtual Mouse Inputs Thread
task.spawn(function()
   while task.wait() do
       if ScriptHubConfig.Utility.AutoClicker then
           if mouse1click then
               mouse1click()
           else
               VirtualUser:CaptureController()
               VirtualUser:ClickButton1(Vector2.new(math.random(100,500), math.random(100,500)))
           end
           task.wait(1 / ScriptHubConfig.Utility.AutoClickInterval)
       end
   end
end)


-- Background Server Chat Channels Replication Spammer Thread
task.spawn(function()
   while task.wait() do
       if ScriptHubConfig.Utility.ChatSpammer then
           local evaluatedChatEventsFolder = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
           if evaluatedChatEventsFolder and evaluatedChatEventsFolder:FindFirstChild("SayMessageRequest") then
               evaluatedChatEventsFolder.SayMessageRequest:FireServer(ScriptHubConfig.Utility.SpammerText, "All")
           else
               local textChatServiceSystem = cloneref(game:GetService("TextChatService"))
               if textChatServiceSystem and textChatServiceSystem.ChatInputBarConfiguration.TargetTextChannel then
                   textChatServiceSystem.ChatInputBarConfiguration.TargetTextChannel:SendAsync(ScriptHubConfig.Utility.SpammerText)
               end
           end
           task.wait(ScriptHubConfig.Utility.SpammerInterval)
       end
   end
end)


-- Tool Asset Dynamic Provisioning Engine (Click Teleport Tool Generation)
task.spawn(function()
   local runningToolReferenceInstance = nil
   while task.wait(1) do
       if ScriptHubConfig.Utility.ClickTPTool then
           if not runningToolReferenceInstance or not runningToolReferenceInstance.Parent then
               runningToolReferenceInstance = Instance.new("Tool")
               runningToolReferenceInstance.Name = "Cepheus Click TP Tool"
               runningToolReferenceInstance.RequiresHandle = false
               runningToolReferenceInstance.Activated:Connect(function()
                   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                       LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                   end
               end)
               runningToolReferenceInstance.Parent = LocalPlayer.Backpack
           end
       else
           if runningToolReferenceInstance then
               runningToolReferenceInstance:Destroy()
               runningToolReferenceInstance = nil
           end
       end
   end
end)


-- ================================================================================
-- TECHNICAL CLEANUP MATRIX & SYSTEM DISPOSAL HANDLERS
-- ================================================================================
Window:OnDestroy(function()
   -- Disconnect Active Global Connections
   for _, uniqueConnection in ipairs(CoreConnections) do
       if uniqueConnection.Disconnect then uniqueConnection:Disconnect() end
   end
   table.clear(CoreConnections)


   -- Wipe Drawing Pipeline Cache
   for _, clearGroup in pairs(CacheESP.Drawings) do
       for _, graphicInstance in pairs(clearGroup) do
           graphicInstance:Remove()
       end
   end
   table.clear(CacheESP.Drawings)


   -- Wipe 3D Pipeline Highlights Cache
   for _, visualHighlight in pairs(CacheESP.Chams) do
       if visualHighlight then visualHighlight:Destroy() end
   end
   table.clear(CacheESP.Chams)


   -- Restore Altered Environment Parameter States
   Lighting.Ambient = OriginalLighting.Ambient
   Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
   Lighting.FogEnd = OriginalLighting.FogEnd
   RunService:Set3dRenderingEnabled(true)
   if BlackScreenGUI then BlackScreenGUI:Destroy() end


   for directPartPointer, originalTransparencyValue in pairs(OriginalParts) do
       if directPartPointer and directPartPointer.Parent then
           directPartPointer.Transparency = originalTransparencyValue
       end
   end
   table.clear(OriginalParts)


   for _, structuralArtifact in ipairs(workspace:GetChildren()) do
       if structuralArtifact.Name:sub(1, 21) == "CepheusTrollPlatform_" or structuralArtifact.Name:sub(1, 22) == "CepheusTrollJumpblock_" then
           structuralArtifact:Destroy()
       end
   end
  
   collectgarbage("collect")
end)


-- ================================================================================
-- LOADER COMPLETION & CLEANUP
-- ================================================================================
SetLoaderPhase("Complete. Welcome to CepheusX.", 1)
task.wait(0.5)


local fadeOutInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(LoaderFrame, fadeOutInfo, {BackgroundTransparency = 1}):Play()
TweenService:Create(LoaderTitle, fadeOutInfo, {TextTransparency = 1}):Play()
TweenService:Create(LoaderStatus, fadeOutInfo, {TextTransparency = 1}):Play()
TweenService:Create(LoaderStroke, fadeOutInfo, {Transparency = 1}):Play()
TweenService:Create(BarBackground, fadeOutInfo, {BackgroundTransparency = 1}):Play()
TweenService:Create(BarFill, fadeOutInfo, {BackgroundTransparency = 1}):Play()


task.wait(0.6)
LoaderGui:Destroy()