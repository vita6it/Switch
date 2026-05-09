local _ENV = (getgenv or getrenv or getfenv)()

local Utils = {}
local Settings = {}
local Threads = {}
local Fallback = {}

local THREAD_HASH = tostring(os.clock() + math.random()) do
    _ENV.__THREAD_HASH = THREAD_HASH
    _ENV.GLOBALS_SETTINGS = {}
end

local function AddModule(Name, Module)
    do Utils[Name] = Module()
        return Utils[Name]
    end
end

_G.Config_Ui = {
    Name = "Aqua",
    Accent = Color3.fromRGB(32, 228, 180),
    AcrylicMain = Color3.fromRGB(30, 30, 30),
    AcrylicBorder = Color3.fromRGB(60, 60, 60),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(25, 25, 25), Color3.fromRGB(15, 15, 15)),
    AcrylicNoise = 0.94,
    TitleBarLine = Color3.fromRGB(65, 65, 65),
    Tab = Color3.fromRGB(100, 100, 100),
    Element = Color3.fromRGB(70, 70, 70),
    ElementBorder = Color3.fromRGB(25, 25, 25),
    InElementBorder = Color3.fromRGB(55, 55, 55),
    ElementTransparency = 0.7,
    DropdownFrame = Color3.fromRGB(120, 120, 120),
    DropdownHolder = Color3.fromRGB(35, 35, 35),
    DropdownBorder = Color3.fromRGB(25, 25, 25),
    Dialog = Color3.fromRGB(35, 35, 35),
    DialogHolder = Color3.fromRGB(25, 25, 25),
    DialogHolderLine = Color3.fromRGB(20, 20, 20),
    DialogButton = Color3.fromRGB(35, 35, 35),
    DialogButtonBorder = Color3.fromRGB(55, 55, 55),
    DialogBorder = Color3.fromRGB(50, 50, 50),
    DialogInput = Color3.fromRGB(45, 45, 45),
    DialogInputLine = Color3.fromRGB(120, 120, 120)
}

local Dowload = "londnee/code/main/right.lua"
local Overload = string.format("https://raw.githubusercontent.com/%s", Dowload)
local Fluent = loadstring(game:HttpGet(Overload))()

local UserInputService = game:GetService('UserInputService')
local TeleportService = game:GetService('TeleportService')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer
local Heartbeat = RunService.Heartbeat
local PlaceId = game.PlaceId
local JobId = game.JobId

AddModule("Connections", function()
    local Connections = {}
    local Cached = _ENV.Connections or {}

    do
        _ENV.Connections = Cached

        for i = 1, #Cached do
            Cached[i]:Disconnect()
        end

        table.clear(Cached)
    end

    function Connections.Connect(Instance, Callback)
        local Connection = Instance:Connect(Callback)

        table.insert(Cached, Connection)

        return Connection
    end 

    return Connections
end)

AddModule("Configurations", function()
    local Configurations = {}
    local Files = "Switch"

    local makefolder = makefolder or function( ... ) return ... end
    local writefile = writefile or function( ... ) return ... end
    local isfolder = isfolder or function( ... ) return ... end
    local readfile = readfile or function( ... ) return ... end
    local isfile = isfile or function( ... ) return ... end

    Configurations.FullPaths = `{Configurations.Set}/{PlaceId}.json`
    Configurations.Paths = { Files, Configurations.Set }
    Configurations.Files = Files or "Unknow"
    Configurations.Set = `{Files}/settings`

    do
        function Configurations:Folder()
            for i = 1, #self.Paths do
                local str = self.Paths[i]

                if not isfolder(str) then
                    makefolder(str)
                end
            end
        end

        function Configurations:Default(index, value)
            if Settings[index] == nil then
                Settings[index] = value
            end
        end

        function Configurations:Save(index, value)
            if index ~= nil then
                Settings[index] = value
            end

            if not isfolder(Files) then
                makefolder(Files)
            end

            if not isfolder(Configurations.Set) then
                makefolder(Configurations.Set)
            end

            writefile(Configurations.FullPaths, HttpService:JSONEncode(Settings))
        end

        function Configurations:Load()
            if not isfile(Configurations.FullPaths) then
                self:Save()
            end

            local Reader = readfile(Configurations.FullPaths) do
                return HttpService:JSONDecode(Reader) 
            end
        end 
    end

    do Configurations:Folder()
        Configurations:Default("Success", true)
    end

    return Configurations
end)

AddModule("Parallels", function()
    local Parallels = {}

    local Options = {}
    local clonedEnabled = {}
    local Functions = _ENV.FUNCTIONS or {}
    local FarmFunctions = _ENV.FARM_FUNCTIONS or {}

    local Enabled_Toggle_Debounce = false
    local Enabled_New_Values = {}

    do
        local function ShowErrorMessage(ErrorMessage)
            _ENV.OnFarm = false

            Fluent:Notify({
                Title = `Error Occurred [ { _ENV.RunningOption or "Null" } ]`,
                Content = ErrorMessage,
                Duration = 8
            })
        end

        local function RunQueue(Options)
            local Success, ErrorMessage = pcall(function()
                local function GetQueue()
                    for _, Option in Options do

                        _ENV.RunningOption = Option.Name

                        local Method = Option.Function()

                        if Method then
                            if type(Method) == "string" then
                                _ENV.RunningMethod = Method
                            end

                            return Method
                        end
                    end

                    _ENV.RunningOption, _ENV.RunningMethod = nil, nil
                end

                while task.wait(0) do
                    if _ENV.__THREAD_HASH ~= THREAD_HASH or Fluent.Unloaded then
                        _ENV.RunningOption, _ENV.RunningMethod = nil, nil
                        _ENV.OnFarm = false
                        break
                    end

                    _ENV.OnFarm = if GetQueue() then true else false
                end
            end)

            if not Success then
                ShowErrorMessage(ErrorMessage)

                task.delay(2, function()
                    if _ENV.RunningOption and Fallback[_ENV.RunningOption] then
                        Fallback[_ENV.RunningOption]:SetValue(false)

                        Fluent:Notify({
                            Title = 'Switch Guard',
                            Content = "Has been Disabled " .. _ENV.RunningOption,
                            Duration = 5
                        })
                        
                        task.spawn(RunQueue, FarmFunctions)
                    end
                end)
            end
        end

        local function UpdateEnabledOptions()
            table.clear(FarmFunctions)

            for index, value in pairs(Enabled_New_Values) do
                clonedEnabled[index] = value or nil
                Enabled_New_Values[index] = nil
            end

            for i = 1, #Functions do
                local funcData = Functions[i]
                if clonedEnabled[funcData.Name] then
                    table.insert(FarmFunctions, funcData)
                end
            end
        end

        local Enabled = _ENV.ENABLED_OPTIONS or setmetatable({}, {
            __newindex = function(self, index, value)
                Enabled_New_Values[index] = value or false

                if not Enabled_Toggle_Debounce then
                    Enabled_Toggle_Debounce = false
                    task.spawn(UpdateEnabledOptions)
                end
            end,
            __index = clonedEnabled
        })

        do
            _ENV.FUNCTIONS = Functions
            _ENV.ENABLED_OPTIONS = Enabled
            _ENV.FARM_FUNCTIONS = FarmFunctions

            task.spawn(RunQueue, FarmFunctions)
        end

        do table.clear(Functions) end

        local index = {}

        local function While(a, b, c, d)
            while a do
                local t = tick()

                if c then c() end
                if d and d() then break end
                if Fluent.Unloaded then break end

                repeat
                    Heartbeat:Wait()
                until tick() - t >= (b or 0.1)
            end
        end

        local function NewOption(Tag, Function, Time)
            if Time then
                Threads[Tag] = function(Value)
                    While(Value, Time or 0.1, Function, function()
                        return not Value or _ENV.__THREAD_HASH ~= THREAD_HASH
                    end)
                end
            else
                local Data = { 
                    ["Name"] = Tag,
                    ["Function"] = Function
                }

                index[ Tag ] = Function
                table.insert(Functions, Data)
            end
        end

        Parallels.NewOption = NewOption
        Parallels.Options = function()
            return Enabled, Options
        end
    end

    return Parallels
end)

AddModule("Plugins", function()
    local Plugins = {}
    
    local Configurations = Utils.Configurations
    local Parallels = Utils.Parallels

    local Enabled, Options = Parallels.Options()
    
    function Plugins:Window(Info)
        self['Base'] = Fluent:CreateWindow({
            Title = Info[1],
            SubTitle = Info[2],
            TabWidth = Info[3] or 160,
            Size = UDim2.new(0, 470, 0, 380),
            Theme = "Darker",
            MinimizeKey = Enum.KeyCode.LeftControl
        })
        
        return self['Base']
    end
    
    function Plugins:MakeTab(Info)
        return self['Base']:AddTab({
            Title = Info[1],
            Icon = Info[2]
        })
    end
    
    function Plugins:Paragraph(Tab, Info)
        return Tab:AddParagraph({
            Title = Info[1],
            Content = Info[2]
        })
    end
    
    function Plugins:Button(Tab, Info, Callback)
        return Tab:AddButton({
            Title = Info[1],
            Description = Info[2],
            Callback = Callback
        })
    end
    
    function Plugins:Toggle(Tab, Info, Flag, Callback)
        local Thread = nil
        
        Fallback[Flag] = Tab:AddToggle(Flag, {
            Title = Info[1],
            Description = Info[2],
            Default = Settings[Flag],
            Callback = function(value)
                Settings[Flag] = value
                Configurations:Save(Flag, value)
                Enabled[Flag] = value
                
                _ENV.GLOBALS_SETTINGS[Flag] = value
                
                if value then
                    Thread = task.spawn(function()
                        if Threads[Flag] then Threads[Flag](Settings[Flag]) end
                    end)
                else
                    if Thread then task.cancel(Thread) end
                end

                if Callback then Callback(value) end
            end,
        })
        
        Fallback[Flag]:SetValue(Settings[Flag])
        
        return Fallback[Flag]
    end
    
    function Plugins:Slider(Tab, Info, Values, Flag, Callback)
        local Slider = Tab:AddSlider(Flag, {
            Title = Info[1],
            Description = Info[2],
            Default = Settings[Flag],
            Min = Values[1],
            Max = Values[2],
            Rounding = Values[3] or 0,
            Callback = function(value)
                Settings[Flag] = value
                Configurations:Save(Flag, value)
                
                _ENV.GLOBALS_SETTINGS[Flag] = value
                
                if Callback then Callback(value) end
            end
        })
        
        Slider:SetValue(Settings[Flag])
        
        return Slider
    end
    
    function Plugins:Dropdown(Tabs, Info, List, Flag, Callback)
        local Current = Settings[Flag]
        local IsMulti = typeof(Current) == 'table'

        local Dropdown = Tabs:AddDropdown(Flag, {
            Title = Info[1],
            Description = Info[2],
            Default = Current,
            Values = List,
            Multi = IsMulti,
            Callback = function(value)
                local Result

                if IsMulti then
                    Result = {}

                    for index, state in value do
                        if state then
                            table.insert(Result, index)
                        end
                    end
                else
                    Result = value
                end

                Settings[Flag] = Result
                Configurations:Save(Flag, Result)
                
                _ENV.GLOBALS_SETTINGS[Flag] = value

                if Callback then Callback(Result) end
            end,
        })

        if IsMulti then
            local NewValues = {}

            for _, value in Current do
                NewValues[value] = true
            end

            Dropdown:SetValue(NewValues)
        else
            Dropdown:SetValue(Current)
        end

        return Dropdown
    end
    
    function Plugins:Input(Tabs, Info, Flag, Callback)
        local Input = Tabs:AddInput("Input", {
            Title = Info[1],
            Description = Info[2],
            Placeholder = Info[3],
            Default = Settings[Flag],
            Callback = function(value)
                Settings[Flag] = value
                Configurations:Save(Flag, value)
                
                _ENV.GLOBALS_SETTINGS[Flag] = value

                if Callback then Callback(value) end
            end
        })
        
        Input:SetValue(Settings[Flag])
        
        return Input
    end

    return Plugins
end)

do
    Settings = Utils.Configurations:Load()
    Utils.Settings = Settings
end

return Utils
