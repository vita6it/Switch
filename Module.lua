return(function(Installer)
    local _ENV = (getgenv or getrenv or getfenv)()

    local Module = {}

    local Cached = {
        Bring = {},
        Enemies = {}
    }

    local Owner = "vita6it"
    local Repository = "Xynapse"

    local Configuration = Installer.Configurations
    local Settings = Installer.Settings
    local Connect = Installer.Connect

    local function fetch(file)
        local URL = string.format(
            "https://raw.githubusercontent.com/%s/%s/main/%s",
            Owner, Repository, file
        )

        return loadstring(game:HttpGet(URL))()
    end

    local function AddModule(Name, Insert)
        do Module[Name] = Insert()
            return Module[Name] 
        end
    end

    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService('UserInputService')
    local TeleportService = game:GetService("TeleportService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService('Lighting')
    local Players = game:GetService("Players")
    local CoreGui = game:GetService('CoreGui')

    local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
    local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")

    local CommF: RemoteFunction = Remotes:WaitForChild("CommF_")
    local CommE: RemoteEvent = Remotes:WaitForChild("CommE")

    local Net: Folder = Modules:WaitForChild("Net")

    local ChestModels: Folder = workspace:WaitForChild("ChestModels")
    local WorldOrigin: Folder = workspace:WaitForChild("_WorldOrigin")
    local Characters: Folder = workspace:WaitForChild("Characters")
    local SeaBeasts: Folder = workspace:WaitForChild("SeaBeasts")
    local Enemies: Folder = workspace:WaitForChild("Enemies")
    local Boats: Folder = workspace:WaitForChild("Boats")
    local Map: Folder = workspace:WaitForChild("Map")

    local NPCs: Folder = workspace:WaitForChild('NPCs')

    local ReplicatedNPCs: Folder = ReplicatedStorage:WaitForChild('NPCs')

    local EnemySpawns: Folder = WorldOrigin:WaitForChild("EnemySpawns")
    local Locations: Folder = WorldOrigin:WaitForChild("Locations")

    local RenderStepped = RunService.RenderStepped
    local Heartbeat = RunService.Heartbeat
    local Stepped = RunService.Stepped

    local LocalPlayer = Players.LocalPlayer

    local PlayerScripts: PlayerScripts = LocalPlayer.PlayerScripts
    local PlayerGui: PlayerGui = LocalPlayer.PlayerGui
    local Backpack: Backpack = LocalPlayer.Backpack

    local Data: Folder = LocalPlayer:WaitForChild("Data")

    local Fragments: IntValue = Data:WaitForChild("Fragments")
    local Level: IntValue = Data:WaitForChild("Level")
    local Money: IntValue = Data:WaitForChild("Beli")

    local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid: Humanoid = Character and Character:WaitForChild('Humanoid', 10)
    local HumanoidRootPart: Part = Character and Character:WaitForChild('HumanoidRootPart', 10)
    local Head: Part = Character and Character:WaitForChild('Head', 10)

    local StorageNPCs: Folder = ReplicatedStorage:WaitForChild('NPCs')
    local ServerOwnerId: IntValue = ReplicatedStorage:FindFirstChild("PrivateServerOwnerId")
    local IsPrivateServer: boolean = ServerOwnerId and ServerOwnerId.Value ~= 0 or true
    local Mobile: boolean = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and true) or false

    local SubmarineWorkerSpeak: RemoteFunction = Net:WaitForChild('RF/SubmarineWorkerSpeak')

    local empty = (function(...) return (...) end)

    local fireproximityprompt = fireproximityprompt or empty
    local fireclickdetector = fireclickdetector or empty
    local restorefunction = restorefunction or empty
    local hookfunction = hookfunction or empty

    local Executor = string.upper(if identifyexecutor then identifyexecutor() else "NULL")

    local BRING_TAG = _ENV._Bring_Tag or tostring(math.random(80, 2e4))
    local KILLAURA_TAG = _ENV._KillAura_Tag or tostring(math.random(120, 2e4))

    _ENV._Bring_Tag = BRING_TAG 
    _ENV._KillAura_Tag = KILLAURA_TAG

    local function GetEnemyName(strings)
        return (strings:find("Lv. ") and strings:gsub(" %pLv. %d+%p", "") or strings):gsub(" %pBoss%p", "")
    end

    local function CreateDictionary(array, value)
        local Dictionary = {}

        for _, strings in ipairs(array) do
            Dictionary[strings] = type(value) == "table" and {} or value
        end

        return Dictionary
    end

    local function ValidData(filter, enemy)
        if filter == nil then return true end

        if type(filter) == "table" then
            return table.find(filter, enemy.Name) ~= nil
        end

        if type(filter) == "string" then
            return enemy.Name == filter
        end

        return false
    end

    local function IsAlive()
        if not Character then return end

        if not Humanoid then return end

        if not HumanoidRootPart then return end

        if not Head then return end

        if not Backpack then return end

        return (Humanoid and Humanoid.Health > 0) or HumanoidRootPart ~= nil
    end

    local function IsValidSea(sea)
        return type(sea) == "number" and (sea == 1 or sea == 2 or sea == 3)
    end

    local function GetSea(fallback)
        local sea = Module.Sea

        if IsValidSea(sea) then
            return sea
        end

        return fallback or 1
    end

    do
        function Module:Unit(BasePart)
            return (BasePart.Position - HumanoidRootPart.Position).Unit
        end

        function Module:IsAlive(Character)
            return Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") and Character.Humanoid.Health > 0
        end

        function Module:Distance(Position)
            return Position and ((typeof(Position) == 'CFrame' and LocalPlayer:DistanceFromCharacter(Position.Position)) or LocalPlayer:DistanceFromCharacter(Position))
        end

        function Module:IsPortal()
            return GetSea() ~= 3 or self:HaveItem('Valkyrie Helm')
        end

        function Module:HaveItem(name)
            if not IsAlive() then return end

            local Inventory = Module:ComF("getInventoryWeapons")

            for _, v in pairs(Inventory) do
                if v.Name == name then
                    return v
                end
            end

            return Character:FindFirstChild(name) or Backpack:FindFirstChild(name)
        end

        function Module:Equip(Name, Tooltip)
            if not IsAlive() then return end

            for _, v in Backpack:GetChildren() do
                if v:IsA("Tool") and ((Tooltip and v.ToolTip == Name) or (not Tooltip and v.Name == Name)) then
                    if v:GetAttribute("Locks") then
                        v:SetAttribute("Locks", nil)
                    end

                    if Character and not Character:FindFirstChild(v.Name) then
                        Humanoid:EquipTool(v)
                    end
                end
            end
        end

        function Module:ComF( ... )
            return CommF:InvokeServer( ... )
        end

        function Module:ComE( ... )
            return CommE:FireServer( ... )
        end

        function Module:TravelTo(Sea)
            local seaName = self.SeaName and self.SeaName[Sea]
            if seaName then
                self:ComF("Travel" .. seaName)
            else
                warn("[Module:TravelTo] Invalid Sea index:", Sea)
            end
        end

        function Module:BringEnemies(ToEnemy, SuperBring, CustomCFrame, Distance)
            if not Module:IsAlive(ToEnemy) or not ToEnemy.PrimaryPart then
                return nil
            end

            pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)

            if Distance or Settings['Enabled Bring'] then
                Module.IsSuperBring = SuperBring and true or false

                local Name = ToEnemy.Name
                local BringPositionTag = SuperBring and "ALL_MOBS" or Name
                local Target = CustomCFrame or ToEnemy.PrimaryPart.CFrame
                local MaxDistance = Distance or Settings['Bring Distance']

                if not Cached.Bring[BringPositionTag] or (Target.Position - Cached.Bring[BringPositionTag].Position).Magnitude > 25 then
                    Cached.Bring[BringPositionTag] = Target
                end

                local EnemyList = (not SuperBring and self.EnemiesModule:GetTagged(Name)) or Enemies:GetChildren()

                for i = 1, #EnemyList do
                    local Enemy = EnemyList[i]

                    if (SuperBring or Enemy.Name == Name)
                        and Enemy.Parent == Enemies
                        and not Enemy:HasTag(BRING_TAG)
                        and Enemy:FindFirstChild("CharacterReady") then

                        local PrimaryPart = Enemy.PrimaryPart

                        if Module:IsAlive(Enemy) and PrimaryPart then
                            if LocalPlayer:DistanceFromCharacter(PrimaryPart.Position) < MaxDistance then
                                Enemy.Humanoid.WalkSpeed = 0
                                Enemy.Humanoid.JumpPower = 0
                                Enemy:AddTag(BRING_TAG)
                            end
                        end
                    end
                end
            else
                if not Cached.Bring[ToEnemy] then
                    Cached.Bring[ToEnemy] = ToEnemy.PrimaryPart.CFrame
                end

                ToEnemy.PrimaryPart.CFrame = Cached.Bring[ToEnemy]
            end
        end
    end

    do
        Module.PirateRaid = 0
        Module.IsSuperBring = false
        Module.EnemyLocations = {}
        Module.SpawnLocations = {}
        Module.SeaName = { "Main", "Dressrosa", "Zou" }
        Module.IsPrivateService = IsPrivateServer
        Module.IsMobile = Mobile

        Module.RaidList = (function()
            if Executor == "XENO" then
                return {
                    "Phoenix", "Dough", "Flame", "Ice", "Quake", "Light",
                    "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand",
                }
            end

            local Success, RaidModule = pcall(require, ReplicatedStorage:WaitForChild("Raids"))

            if not Success or type(RaidModule) ~= "table" then
                return {
                    "Phoenix", "Dough", "Flame", "Ice", "Quake", "Light",
                    "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand",
                }
            end

            local AdvancedRaids = RaidModule.advancedRaids or {}
            local NormalRaids = RaidModule.raids or {}

            local RaidList = {}

            for i = 1, #AdvancedRaids do table.insert(RaidList, AdvancedRaids[i]) end
            for i = 1, #NormalRaids do table.insert(RaidList, NormalRaids[i]) end

            return RaidList
        end)()

        Module.Sea = (function()
            local Current = workspace:GetAttribute('MAP') do
                if Current == 'Sea1' then return 1 end
                if Current == 'Sea2' then return 2 end
                if Current == 'Sea3' then return 3 end 
            end

            warn("[Module.Sea] MAP attribute not recognized:", tostring(workspace:GetAttribute('MAP')))
            return "N/A"
        end)()

        Module.GateList = {
            [1] = {
                Vector3.new(3860, 26, -1780), -- Gate
                Vector3.new(61163, 5, 1819), -- Under Water
                Vector3.new(-7894, 5545, -380), -- Sky 2
                Vector3.new(-4607, 872, -1667) -- Sky 1
            },
            [2] = {
                Vector3.new(923, 125, 32852), -- Ghost Ship
                Vector3.new(-288, 200, 611), -- Mansion
                Vector3.new(2283, 60, 905), -- Swan
                Vector3.new(-6505, 125, -130) -- Out Ghost Ship
            },
            [3] = {
                Vector3.new(-5100, 450, -3250), -- Castle on the Sea
                Vector3.new(5750, 1120, -338), -- Hydra
                Vector3.new(-12540, 333, -7600) -- Mansion 
            },
        }

        Module.FruitsId = {
            ["rbxassetid://15124425041"] = "Rocket",
            ["rbxassetid://15123685330"] = "Spin",
            ["rbxassetid://15123613404"] = "Blade",
            ["rbxassetid://15123689268"] = "Spring",
            ["rbxassetid://15123595806"] = "Bomb",
            ["rbxassetid://15123677932"] = "Smoke",
            ["rbxassetid://15124220207"] = "Spike",
            ["rbxassetid://121545956771325"] = "Flame",
            ["rbxassetid://15123673019"] = "Sand",
            ["rbxassetid://15123618591"] = "Dark",
            ["rbxassetid://77885466312115"] = "Eagle",
            ["rbxassetid://15112600534"] = "Diamond",
            ["rbxassetid://15123640714"] = "Light",
            ["rbxassetid://15123668008"] = "Rubber",
            ["rbxassetid://15123662036"] = "Ghost",
            ["rbxassetid://15123645682"] = "Magma",
            ["rbxassetid://15123606541"] = "Quake",
            ["rbxassetid://15123643097"] = "Love",
            ["rbxassetid://15123681598"] = "Spider",
            ["rbxassetid://116828771482820"] = "Creation",
            ["rbxassetid://15123679712"] = "Sound",
            ["rbxassetid://15123654553"] = "Phoenix",
            ["rbxassetid://15123656798"] = "Portal",
            ["rbxassetid://15123670514"] = "Rumble",
            ["rbxassetid://15123652069"] = "Pain",
            ["rbxassetid://15123587371"] = "Blizzard",
            ["rbxassetid://15123633312"] = "Gravity",
            ["rbxassetid://15123648309"] = "Mammoth",
            ["rbxassetid://15694681122"] = "T-Rex",
            ["rbxassetid://15123624401"] = "Dough",
            ["rbxassetid://15123675904"] = "Shadow",
            ["rbxassetid://10773719142"] = "Venom",
            ["rbxassetid://15123616275"] = "Control",
            ["rbxassetid://11911905519"] = "Spirit",
            ["rbxassetid://15123638064"] = "Leopard",
            ["rbxassetid://15487764876"] = "Kitsune",
            ["rbxassetid://115276580506154"] = "Yeti",
            ["rbxassetid://118054805452821"] = "Gas",
            ["rbxassetid://95749033139458"] = "Dragon East"
        }
    end

    AddModule("Aimbot", function()
        local Aimbot = {
            _index = {}
        }

        _ENV.Target = Vector3.new(0, 0, 0)

        function Aimbot:Check()
            for _,v in pairs(self._index) do
                if _ENV.GLOBALS_SETTINGS[v] == true then
                    return true 
                end 
            end 

            return false 
        end

        function Aimbot:Import(Name)
            if not self._index[Name] then
                table.insert(self._index, Name)
            end
        end

        function Aimbot:SetTarget(v3)
            _ENV.Target = (typeof(v3) == 'CFrame' and v3.Position) or v3
        end

        return Aimbot
    end)

    AddModule("Combat", function()
        local Combat = {
            RANGE = 50,
            HIT_FUNCTION = nil
        }

        local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
        local RegisterHit = Net:WaitForChild("RE/RegisterHit")
        
        local GunModule = Executor ~= "XENO" and fetch('Utils/GunModule.lua') or nil

        local Hash coroutine.wrap(function()
            Hash = tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
        end)()

        task.defer(function()
            pcall(function()
                local LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")

                while not LocalScript do
                    LocalPlayer.PlayerScripts.ChildAdded:Wait()
                    LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")
                end

                if getsenv then
                    local Success, Environtment = pcall(getsenv, LocalScript)

                    if Success and Environtment then
                        if Environtment._G.SendHitsToServer then
                            Combat.HIT_FUNCTION = Environtment._G.SendHitsToServer
                        end
                    end
                end
            end)
        end)

        local function ProcessEnemy(Closet)
            local BladeHits = {}

            for _, Enemy in ipairs(Enemies:GetChildren()) do
                if Enemy ~= Closet and Module:IsAlive(Enemy) then
                    local HumanoidRootPart = Enemy:FindFirstChild("HumanoidRootPart")

                    if HumanoidRootPart then
                        table.insert(BladeHits, { Enemy, HumanoidRootPart })
                    end
                end
            end

            if Settings['Attack Players'] then
                for _, Enemy in ipairs(Characters:GetChildren()) do
                    if Enemy ~= Closet and Module:IsAlive(Enemy) then
                        local HumanoidRootPart = Enemy:FindFirstChild("HumanoidRootPart")

                        if HumanoidRootPart then
                            table.insert(BladeHits, { Enemy, HumanoidRootPart })
                        end
                    end
                end
            end

            return BladeHits
        end

        local function Fired(target, enemyData)
            RegisterAttack:FireServer(0.5)

            if Combat.HIT_FUNCTION then
                return Combat.HIT_FUNCTION(target, enemyData, nil, Hash)
            end

            RegisterHit:FireServer(target, enemyData, nil, Hash)
        end

        Combat.ATTACK = Fired

        local function Attack()
            local Folders = { Enemies, Settings['Attack Players'] and Characters or nil }

            for _, folder in ipairs(Folders) do
                if not folder then continue end

                for _, target in pairs(folder:GetChildren()) do
                    if target == Character then continue end
                    if not Module:IsAlive(target) then continue end
                    if Module:Distance(target:GetPivot()) >= Combat.RANGE then continue end

                    local rootPart = target:FindFirstChild("HumanoidRootPart")
                    if not rootPart then continue end

                    Fired(rootPart, ProcessEnemy(target))
                end
            end
        end

        Connect(Stepped, function()
            if not Settings['Fast Attack'] then return end

            if not IsAlive() then return end

            local Equiped = Character and Character:FindFirstChildOfClass("Tool")

            if not Equiped then return end

            local Name = tostring(Equiped)
            
            if Equiped.ToolTip == 'Gun' and typeof(GunModule) == 'table' then
                return GunModule:FireTarget(Equiped, Character)
            end

            if Name == 'Ice-Ice' or Name == 'Light-Light' then
                return pcall(Attack)
            end

            if Equiped.ToolTip == 'Blox Fruit' then
                local LeftClickRemote = Equiped:FindFirstChild("LeftClickRemote")
                if not LeftClickRemote then return end

                LeftClickRemote:FireServer(Vector3.new(0, -500, 0), 1, true)
                LeftClickRemote:FireServer(false)
            end

            local Type = Equiped and (Equiped.ToolTip == 'Melee' or Equiped.ToolTip == 'Sword')
            if not Type then return end

            pcall(Attack)
        end)

        return Combat
    end)

    AddModule("Quest", function()
        local Quest = {
            Blacklist = { "BartiloQuest", "MarineQuest", "CitizenQuest", "ImpelQuest" },
            GuideModule = {}
        }

        Quest.Quests = (function()
            if Executor == "XENO" then
                return fetch("Utils/Quests.lua")
            end

            local Success, Quests = pcall(require, ReplicatedStorage:WaitForChild('Quests'))

            if not Success or type(Quests) ~= "table" then
                return fetch("Utils/Quests.lua")
            end

            return Quests
        end)()

        Quest.GuideModule = (function()
            local sea = GetSea()

            if Executor == "XENO" then
                return fetch("Utils/GuideModule.lua")[sea]
            end

            local Success, GuideModule = pcall(require, ReplicatedStorage:WaitForChild('GuideModule'))

            if not Success or type(GuideModule) ~= "table" then
                return fetch("Utils/GuideModule.lua")[sea]
            end

            return GuideModule['Data']['NPCList']
        end)()

        function Quest:GetMonster(CurrentLevel)
            local Data, Levels = {}, {}
            local sea = GetSea()
            local Maximum = ({ {0, 700}, {700, 1500}, {1500, math.huge} })[sea]

            if not Maximum then
                warn("[Quest:GetMonster] Invalid sea:", tostring(Module.Sea))
                return nil
            end

            for name, task in pairs(Quest.Quests) do

                if table.find(Quest.Blacklist, name) then
                    continue
                end

                for num, mission in pairs(task) do
                    local Level = mission.LevelReq
                    local Monster, Value = next(mission.Task)

                    if Level >= Maximum[1] and Level < Maximum[2] and CurrentLevel >= Level and Value > 1 then

                        table.insert(Levels, Level)

                        Data[tostring(Level)] = {
                            Name = mission.Name,
                            Level = num,
                            Monster = Monster,
                        }
                    end
                end
            end

            if #Levels == 0 then return nil end

            return Data[tostring(math.max(unpack(Levels)))]
        end

        function Quest:NPCsData(CurrentLevel)
            local Data, Levels = {}, {}

            for _, Npcs in pairs(Quest.GuideModule) do
                if not Npcs.InternalQuestName then
                    continue
                end

                if table.find(Quest.Blacklist, Npcs.InternalQuestName) then
                    continue
                end

                local Level = Npcs.Levels[1]

                if CurrentLevel >= Level then

                    table.insert(Levels, Level)

                    Data[tostring(Level)] = {
                        ['Position'] = Npcs.Position,
                        ['Quest'] = Npcs.InternalQuestName,
                    }
                end
            end

            if #Levels == 0 then return nil end

            return Data[tostring(math.max(unpack(Levels)))]
        end

        function Quest:GetQuest(CurrentLevel)
            local Level = CurrentLevel.Value

            if Level == 1 and Level <= 9 then
                if tostring(LocalPlayer.Team) == "Marines" then
                    return {
                        ['Name'] = "Trainees",
                        ['Monster'] = "Trainee",
                        ['Level'] = 1,
                        ['Quest'] = "MarineQuest",
                        ['Position'] = CFrame.new(-2711, 24, 2104),
                    }
                elseif tostring(LocalPlayer.Team) == "Pirates" then
                    return {
                        ['Name'] = "Bandits",
                        ['Monster'] = "Bandit",
                        ['Level'] = 1,
                        ['Quest'] = "BanditQuest1",
                        ['Position'] = CFrame.new(1059, 15, 1550),
                    }
                end

                return
            end

            local Data = self:GetMonster(Level)

            if not Data then
                warn("[Quest:GetQuest] GetMonster returned nil for level:", Level)
                return nil
            end

            local NPCsData = self:NPCsData(Level)

            if not NPCsData then
                warn("[Quest:GetQuest] NPCsData returned nil for level:", Level)
                return nil
            end

            Data['Quest'] = NPCsData.Quest
            Data['Position'] = CFrame.new(NPCsData.Position)

            return Data
        end

        return Quest
    end)

    AddModule("EnemiesModule", function()
        local EnemiesModule = CreateDictionary({
            "__CakePrince", "__PirateRaid", "__RaidBoss", "__TyrantSkies", "__Bones", "__Elite", "__Others", 
        }, {})

        local SeaCastle = CFrame.new(-5556, 314, -2988)

        local TagsMobs = {
            __Elite = CreateDictionary({ "Deandre", "Diablo", "Urban", "Tyrant of the skies" }, true),
            __Bones = CreateDictionary({ "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy" }, true),
            __CakePrince = CreateDictionary({ "Head Baker", "Baking Staff", "Cake Guard", "Cookie Crafter" }, true),
            __TyrantSkies = CreateDictionary({ "Sun-kissed Warrior", "Skull Slayer", "Isle Champion", "Serpent Hunter" }, true)
        }

        local Attachment = Instance.new("Attachment") do
            local AlignPosition = Instance.new("AlignPosition")
            AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
            AlignPosition.Position = Vector3.new(0, 20, 0)
            AlignPosition.Responsiveness = 200
            AlignPosition.MaxForce = math.huge
            AlignPosition.Parent = Attachment
            AlignPosition.Attachment0 = Attachment
        end

        local function New(list, NewEnemy)
            if table.find(list, NewEnemy) then return end

            local Humanoid = NewEnemy:WaitForChild("Humanoid")

            if Humanoid and Humanoid.Health > 0 then
                table.insert(list, NewEnemy)
                Humanoid.Died:Wait()
                local index = table.find(list, NewEnemy)
                if index then table.remove(list, index) end
            end
        end

        local function IsFromPiratesSea(Enemy)
            if not Enemy:WaitForChild("Humanoid") or Enemy.Humanoid.Health <= 0 then return end

            local HumanoidRootPart = Enemy:WaitForChild("HumanoidRootPart")

            if HumanoidRootPart and (Enemy.Name ~= "rip_indra True Form" and Enemy.Name ~= "Blank Buddy") then
                if (HumanoidRootPart.Position - SeaCastle.Position).Magnitude <= 750 then
                    task.spawn(New, EnemiesModule.__PirateRaid, Enemy)
                    Module.PirateRaid = tick()
                end
            end
        end

        local function NewEnemyAdded(Enemy)
            local EnemyName = Enemy.Name
            local Others = EnemiesModule.__Others

            Others[EnemyName] = Others[EnemyName] or {}
            task.spawn(New, Others[EnemyName], Enemy)

            if GetSea() == 3 then
                task.spawn(IsFromPiratesSea, Enemy)
            end

            if Enemy:GetAttribute("RaidBoss") then
                task.spawn(New, EnemiesModule.__RaidBoss, Enemy)
            elseif EnemiesModule["__" .. EnemyName] then
                task.spawn(New, EnemiesModule["__" .. EnemyName], Enemy)
            else
                for Tag, Mobs in pairs(TagsMobs) do
                    if Mobs[EnemyName] then
                        task.spawn(New, EnemiesModule[Tag], Enemy)
                        break
                    end
                end
            end
        end

        function EnemiesModule:IsSpawned(EnemyName)
            local Cached = Module.SpawnLocations[EnemyName]

            if Cached and Cached.Parent then
                return (Cached:GetAttribute("Active") or EnemiesModule:GetEnemyByTag(EnemyName)) and true or false
            end

            return EnemiesModule:GetEnemyByTag(EnemyName) and true or false
        end

        function EnemiesModule:GetTagged(TagName)
            return self["__" .. TagName] or self.__Others[TagName]
        end

        function EnemiesModule:GetEnemyByTag(TagName)
            local CachedEnemy = Cached.Enemies[TagName]

            if CachedEnemy and IsAlive(CachedEnemy) then
                return CachedEnemy
            end

            local Enemies = self:GetTagged(TagName)

            if Enemies and #Enemies > 0 then
                for i = 1, #Enemies do
                    local Enemy = Enemies[i]

                    if Module:IsAlive(Enemy) then
                        Cached.Enemies[TagName] = Enemy
                        return Enemy
                    end
                end
            end
        end

        function EnemiesModule:GetClosest(Enemies)
            local SpecialTag = table.concat(Enemies, ".")
            local CachedEnemy = Cached.Enemies[SpecialTag]

            if CachedEnemy and Module:IsAlive(CachedEnemy) then
                return CachedEnemy
            end

            local Distance, Nearest = math.huge, nil

            for i = 1, #Enemies do
                local Enemy = self:GetClosestByTag(Enemies[i])
                local Magnitude = Enemy and LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

                if Enemy and Magnitude <= Distance then
                    Distance, Nearest = Magnitude, Enemy
                end
            end

            if Nearest then
                Cached.Enemies[SpecialTag] = Nearest
                return Nearest
            end
        end

        function EnemiesModule:GetClosestByTag(TagName)
            local CachedEnemy = Cached.Enemies[TagName]

            if CachedEnemy and Module:IsAlive(CachedEnemy) then
                return CachedEnemy
            end

            local Enemies = self:GetTagged(TagName)

            if Enemies and #Enemies > 0 then
                local Distance, Nearest = math.huge, nil

                local Position = Character and Character:GetPivot().Position

                for i = 1, #Enemies do
                    local Enemy = Enemies[i]
                    local PrimaryPart = Enemy.PrimaryPart

                    if PrimaryPart and Module:IsAlive(Enemy) then
                        local Magnitude = (Position - PrimaryPart.Position).Magnitude

                        if Magnitude <= 15 then
                            Cached.Enemies[TagName] = Enemy
                            return Enemy
                        elseif Magnitude <= Distance then
                            Distance, Nearest = Magnitude, Enemy
                        end
                    end
                end

                if Nearest then
                    Cached.Enemies[TagName] = Nearest
                    return Nearest
                end
            end
        end

        function EnemiesModule:GetReplicated(name)
            local Nearest, Distance = nil, math.huge
            local EnemiesList = ReplicatedStorage:GetChildren()

            for i = 1, #EnemiesList do
                local Enemy = EnemiesList[i]

                if not Enemy:IsA('Model') then continue end
                if not Enemy.PrimaryPart then continue end
                if not ValidData(name, Enemy) then continue end

                if Module:IsAlive(Enemy) then
                    local Magnitude = LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

                    if Enemy and Magnitude <= Distance then
                        Distance, Nearest = Magnitude, Enemy
                    end
                end
            end

            return Nearest
        end

        function EnemiesModule:GetEnemies(range, name)
            local Nearest, Distance = nil, math.huge
            local EnemiesList = Enemies:GetChildren()

            for i = 1, #EnemiesList do
                local Enemy = EnemiesList[i]

                if not Enemy.PrimaryPart then continue end
                if not ValidData(name, Enemy) then continue end

                if Module:IsAlive(Enemy) then
                    local Magnitude = LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

                    if Enemy and (not range or Magnitude < range) and Magnitude < Distance then
                        Distance, Nearest = Magnitude, Enemy
                    end
                end
            end

            return Nearest
        end

        local function Bring(Enemy)
            local RootPart = Enemy:WaitForChild("HumanoidRootPart")
            local Humanoid = Enemy:WaitForChild("Humanoid")
            local EnemyName = Enemy.Name

            local CloneAttachment = Attachment:Clone()
            local AlignPosition = CloneAttachment.AlignPosition
            CloneAttachment.Parent = RootPart

            while Enemy and Enemy.Parent == Enemies and Enemy:HasTag(BRING_TAG) do
                if not Humanoid or Humanoid.Health <= 0 then break end
                if not RootPart or RootPart.Parent ~= Enemy then break end

                local Target = Cached.Bring[Module.IsSuperBring and "ALL_MOBS" or EnemyName]

                if Target and (Target.Position - RootPart.Position).Magnitude <= Settings["Bring Distance"] then
                    if AlignPosition.Position ~= Target.Position then
                        AlignPosition.Position = Target.Position
                    end
                else
                    break
                end;task.wait()
            end

            if Enemy and Enemy:HasTag(BRING_TAG) then Enemy:RemoveTag(BRING_TAG) end
            if CloneAttachment then CloneAttachment:Destroy() end
        end

        local function KillAura(Enemy)
            local Humanoid = Enemy:FindFirstChild("Humanoid")
            local RootPart = Enemy:FindFirstChild("HumanoidRootPart")

            pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)

            if Humanoid and RootPart then
                RootPart.CanCollide = false
                RootPart.Size = Vector3.new(60, 60, 60)
                Humanoid:ChangeState(15)
                Humanoid.Health = 0
                task.wait()
                Enemy:RemoveTag(KILLAURA_TAG)
            end
        end

        for _, Enemy in CollectionService:GetTagged("BasicMob") do NewEnemyAdded(Enemy) end
        Connect(CollectionService:GetInstanceAddedSignal("BasicMob"), NewEnemyAdded)
        Connect(CollectionService:GetInstanceAddedSignal(KILLAURA_TAG), KillAura)
        Connect(CollectionService:GetInstanceAddedSignal(BRING_TAG), Bring)

        return EnemiesModule
    end)

    AddModule("Signal", function()
        local Signal = {}
        local Connection = {}

        Connection.__index = Connection
        Signal.__index = Signal

        function Connection:Disconnect()
            if not self.Connected then
                return
            end

            local find = table.find(self.Signal._connections, self)
            if find then
                table.remove(self.Signal._connections, find)
            end

            self.Function = nil
            self.Connected = false
        end

        function Connection:Fire(...)
            if self.Function then
                task.spawn(self.Function, ...)
            end
        end

        function Signal.new()
            return setmetatable({
                _connections = {}
            }, Signal)
        end

        function Signal:Connect(fn)
            local connection = setmetatable({
                Signal = self,
                Function = fn,
                Connected = true
            }, Connection)

            table.insert(self._connections, connection)
            return connection
        end

        function Signal:Fire(...)
            for _, connection in ipairs(self._connections) do
                connection:Fire(...)
            end
        end

        return Signal
    end)

    AddModule("BodyVelocity", function()
        local BodyVelocity = Instance.new("BodyVelocity") do
            BodyVelocity.Velocity = Vector3.zero
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyVelocity.P = 1000
        end

        BodyVelocity.Parent = HumanoidRootPart

        local Highlight = Instance.new("Highlight") do
            Highlight.FillColor = Color3.fromRGB(255, 255, 255)
            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            Highlight.FillTransparency = 0.3
        end

        if _ENV.tween_bodyvelocity then
            _ENV.tween_bodyvelocity:Destroy()
        end

        if _ENV.highlight then
            _ENV.highlight:Destroy()
        end

        _ENV.highlight = Highlight
        _ENV.tween_bodyvelocity = BodyVelocity

        local CanCollideObjects = {}

        local function AddObjectToBaseParts(Object)
            if Object:IsA("BasePart") and Object.CanCollide then
                table.insert(CanCollideObjects, Object)
            end
        end

        local function RemoveObjectsFromBaseParts(BasePart)
            local index = table.find(CanCollideObjects, BasePart)

            if index then
                table.remove(CanCollideObjects, index)
            end
        end

        local function NewCharacter(Character)
            if not Character then return end

            table.clear(CanCollideObjects)

            for _, Object in Character:GetDescendants() do AddObjectToBaseParts(Object) end
            Character.DescendantAdded:Connect(AddObjectToBaseParts)
            Character.DescendantRemoving:Connect(RemoveObjectsFromBaseParts)
        end

        Connect(LocalPlayer.CharacterAdded, NewCharacter)
        task.spawn(NewCharacter, Character)

        local function NoClipOnStepped(Character)
            if _ENV.OnFarm then
                for i = 1, #CanCollideObjects do
                    CanCollideObjects[i].CanCollide = false
                end
            elseif Character.PrimaryPart and not Character.PrimaryPart.CanCollide then
                for i = 1, #CanCollideObjects do
                    CanCollideObjects[i].CanCollide = true
                end
            end
        end

        local function UpdateVelocityOnStepped(Character)
            local BasePart = Character:FindFirstChild("UpperTorso")
            local Humanoid = Character:FindFirstChild("Humanoid")
            local BodyVelocity = _ENV.tween_bodyvelocity
            local Highlight = _ENV.highlight

            if _ENV.OnFarm and BasePart and Humanoid and Humanoid.Health > 0 then
                if BodyVelocity.Parent ~= BasePart then
                    BodyVelocity.Parent = BasePart
                end

                if Highlight.Parent ~= Character then
                    Highlight.Parent = Character
                end
            elseif BodyVelocity.Parent then
                BodyVelocity.Parent = nil
                Highlight.Parent = nil
            end

            if BodyVelocity.Velocity ~= Vector3.zero and (not Humanoid or not Humanoid.SeatPart or not _ENV.OnFarm) then
                BodyVelocity.Velocity = Vector3.zero
                Highlight.Parent = nil
            end
        end

        Connect(RunService.RenderStepped, function()
            if IsAlive() then
                UpdateVelocityOnStepped(Character)
                NoClipOnStepped(Character)
            end
        end)

        return BodyVelocity
    end)

    AddModule("Inventory", function()
        local Cache = {
            ['Unlocked'] = setmetatable({}, { __index = function() return false end }),
            ['Mastery'] = setmetatable({}, { __index = function() return 0 end }),
            ['MasteryRequirements'] = {},
            ['Items'] = {},
        }

        do 
            Cache._CountSignals = {}
            Cache._CountData = {}

            Cache.Count = setmetatable({}, {
                __index = function(_, key)
                    return Cache._CountData[key] or 0
                end,
                __newindex = function(_, key, value)
                    local old = Cache._CountData[key] or 0

                    if old ~= value then
                        Cache._CountData[key] = value

                        local signal = Cache._CountSignals[key]

                        if signal then
                            signal:Fire(value, old)
                        end
                    end
                end
            })

            function Cache:GetInventoryChanged(key)
                if not self._CountSignals[key] then
                    self._CountSignals[key] = Module.Signal.new()
                end

                return self._CountSignals[key]
            end

            function Cache:Counts(str)
                return self.Count[str]
            end
        end

        function Cache:HaveFruit()
            if not IsAlive() then return end

            for _, v in Backpack:GetChildren() do
                if string.find(v.Name,"Fruit") then
                    return true
                end
            end

            for _, v in Character:GetChildren() do
                if string.find(v.Name,"Fruit") then
                    return true
                end
            end

            return false
        end

        function Cache:Fruit(High)
            local Fruits = {}

            for _, v in next, Module:ComF("GetFruits") do
                if High and v.Price >= 999999 or v.Price <= 999999 then
                    Fruits[v.Name] = v.Price
                end
            end

            return Fruits
        end 

        function Cache:Search(High)
            local MaxValue, Fruits = math.huge, nil
            local List = self:Fruit(High)

            for _, v in Module:ComF("getInventory") do
                if v['Type'] ~= "Blox Fruit" then continue end

                for Name, Value in List do
                    if v.Name ~= Name then continue end

                    if tonumber(Value) < tonumber(MaxValue) then
                        MaxValue = Value
                        Fruits = Name
                    end
                end
            end

            return Fruits
        end

        function Cache:UnStore(IsHigh)
            local Fruits = self:Search(IsHigh)

            if self:HaveFruit() or not Fruits then return end

            return Module:ComF("LoadFruit", Fruits)
        end

        function Cache:UpdateItem(item)
            if type(item) == "table" then
                if item.Type == "Wear" then
                    item.Type = "Accessory"
                end

                local Name = item.Name

                self.Items[Name] = item

                if not self.Unlocked[Name] then self.Unlocked[Name] = true end
                if item.Count then self.Count[Name] = item.Count end
                if item.Mastery then self.Mastery[Name] = item.Mastery end
                if item.MasteryRequirements then self.MasteryRequirements[Name] = item.MasteryRequirements end
            end
        end

        function Cache:RemoveItem(ItemName)
            if type(ItemName) == "string" then
                self.Unlocked[ItemName] = nil
                self.Mastery[ItemName] = nil
                self.Count[ItemName] = nil
                self.Items[ItemName] = nil
            end
        end

        local function OnClientEvent(Method, ...)
            if Method == "ItemChanged" then
                Cache:UpdateItem(...)
            elseif Method == "ItemAdded" then
                Cache:UpdateItem(...)
            elseif Method == "ItemRemoved" then
                Cache:RemoveItem(...)
            end
        end

        task.spawn(function()
            Connect(CommE.OnClientEvent, OnClientEvent)

            local InventoryItems = nil

            repeat
                task.wait(1)
                InventoryItems = Module:ComF("getInventory")
            until type(InventoryItems) == "table"

            for index = 1, #InventoryItems do
                Cache:UpdateItem(InventoryItems[index])
            end
        end)

        return Cache
    end)

    AddModule("Workspace", function()
        local Workspace = {}

        local ColorMap = {
            ["Really red"] = "Pure Red",
            ["Oyster"]    = "Snow White",
            ["Hot pink"]  = "Winter Sky"
        }

        function Workspace:Chest()
            local Chests = CollectionService:GetTagged("_ChestTagged")
            local Distance, Nearest = math.huge, nil

            for i = 1, #Chests do
                local Chest = Chests[i]
                local Magnitude = (Chest:GetPivot().Position - HumanoidRootPart.Position).Magnitude

                if not Chest:GetAttribute("IsDisabled") and Magnitude < Distance then
                    Distance, Nearest = Magnitude, Chest
                end
            end

            return Nearest
        end

        function Workspace:Berry()
            local Position = HumanoidRootPart.Position
            local BerryBush = CollectionService:GetTagged("BerryBush")

            local Distance = math.huge
            local Nearest = nil

            for i = 1, #BerryBush do
                local Bush = BerryBush[i]

                for _, BerryName in pairs(Bush:GetAttributes()) do
                    local BushPosition = Bush.Parent:GetPivot().Position
                    local Magnitude = Module:Distance(BushPosition)

                    if Magnitude < Distance then
                        Nearest = Bush
                        Distance = Magnitude
                    end
                end
            end

            return Nearest
        end

        function Workspace:Raid()
            for i = 5, 1, -1 do
                local Name = "Island " .. i

                for _, Island in ipairs(Locations:GetChildren()) do
                    if Island.Name ~= Name then continue end

                    if Module:Distance(Island.Position) < 3500 then
                        return Island
                    end
                end
            end
        end

        function Workspace:Tree(EagleBossArena)
            local Nearest = nil
            local Distance = math.huge

            for _, v in EagleBossArena:GetChildren() do
                if v.Name ~= "Tree" then continue end

                if not v:IsA("Model") then continue end

                if not v.PrimaryPart then continue end

                local Magnitude = Module:Distance(v.PrimaryPart.Position)

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        function Workspace:Players(MaxDistance)
            local Nearest = nil
            local Distance = math.huge

            for _, v in Characters:GetChildren() do
                if v == Character then continue end

                if not Module:IsAlive(v) then continue end

                local Magnitude = Module:Distance(v:GetPivot())

                if (not MaxDistance or Magnitude < MaxDistance) and Magnitude < Distance then
                    Nearest = v
                    Distance = Magnitude
                end
            end

            return Nearest
        end

        function Workspace:GetShip(name)
            for _, v in Boats:GetChildren() do
                if v.Name == name and v.Name ~= LocalPlayer.Name then
                    return v
                end
            end
        end

        function Workspace:GetLavaRocks(VolcanoRocks)
            local Nearest = nil
            local Distance = math.huge

            for _, v in VolcanoRocks:GetChildren() do
                local LavaEffect = v:FindFirstChild("At1Beam", true)

                if not v:IsA("Model") then continue end

                if not LavaEffect then continue end

                if not LavaEffect.Enabled then continue end

                local Magnitude = Module:Distance(v:GetPivot())

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        function Workspace:GetGift()
            for _, v in WorldOrigin:GetChildren() do
                if v.Name ~= "Present" then continue end

                local Name = v:FindFirstChild('Value', true)

                if not Name then continue end

                if tostring(Name.Value) == LocalPlayer.Name then
                    return v
                end
            end
        end

        function Workspace:ParseTime(timeText)
            local hours, minutes, seconds = timeText:match("(%d+):(%d+):(%d+)")

            if hours and minutes and seconds then
                return tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)
            end

            local mins, secs = timeText:match("(%d+):(%d+)")

            if mins and secs then
                return tonumber(mins) * 60 + tonumber(secs)
            end

            return 0
        end

        function Workspace:ValidColors(Part)
            if Part and Part.BrickColor then
                return tostring(Part.BrickColor) == "Lime green"
            end

            return false
        end

        function Workspace:CalculateColors(Part)
            if Part and Part.BrickColor then
                return ColorMap[tostring(Part.BrickColor)]
            end
        end

        function Workspace:GetPartColors(Circle)
            for _, v in Circle:GetChildren() do
                if v:IsA("Part") and not self:ValidColors(v) then
                    return v
                end
            end
        end

        return Workspace
    end)

    AddModule("Ocean", function()
        local Ocean = {}

        local ZoneCoordinates = {
            ['Infinite - ∞'] = {-9999999, 9999999},
            ['Low - 1'] = {-21227, 4047},
            ['Meduim - 2'] = {-24237, 6381},
            ['High - 3'] = {-27105, 8959},
            ['Extreme - 4'] = {-29350, 11744},
            ['Crazy - 5'] = {-32404, 16208},
            ['??? - 6'] = {-35611, 20548},
        }

        local TargetAnims = {
            "rbxassetid://8708225668",
            "rbxassetid://8708223619",
            "rbxassetid://8708222938"
        }

        function Ocean:Zone()
            local Coords = ZoneCoordinates[Settings['Select Zone']]

            if Coords then
                return CFrame.new(Coords[1], 100, Coords[2])
            end

            return CFrame.new(-9999999, 100, 9999999)
        end

        function Ocean:IsAlive(v)
            return v:FindFirstChild("Health") and v.Health.Value > 0
        end

        function Ocean:RemoveBoatCollision(Boat)
            local Objects = Boat:GetDescendants()

            for i = 1, #Objects do
                local BasePart = Objects[i]

                if BasePart:IsA("BasePart") and BasePart.CanCollide then
                    BasePart.CanCollide = false
                end
            end
        end

        local function IsOwnerShip(Model)
            local Owner = Model:FindFirstChild("Owner")

            if not Owner or not Owner:IsA("ObjectValue") then
                return
            end

            if tostring(Owner.Value) ~= LocalPlayer.Name then
                return
            end

            return true
        end

        function Ocean:Ship(name)
            local Nearest = nil
            local Distance = 5000

            for _, v in Boats:GetChildren() do
                if v.Name ~= name then continue end

                if not v:GetAttribute("IsBoat") then continue end

                if not IsOwnerShip(v) then continue end

                local Humanoid = v:FindFirstChild("Humanoid")

                if not Humanoid then continue end

                if tonumber(Humanoid.Value) <= 0 then continue end

                local Magnitude = Module:Distance(v:GetPivot())

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        function Ocean:Drive(Ship, Target, High)
            local Seat = Ship:FindFirstChild("VehicleSeat")
            if not Seat then return end

            local BodyPosition = Seat:FindFirstChild("BodyPosition")
            local BodyVelocity = Seat:FindFirstChild("BodyVelocity")
            if not BodyPosition or not BodyVelocity then return end

            local Origin   = Seat.Position
            local Distance = (Target.Position - Ship:GetPivot().Position).Magnitude

            BodyPosition.MaxForce = Vector3.zero
            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity.P        = 0

            Seat.CFrame = CFrame.new(Origin.X, High or 100, Origin.Z)

            local Tween = TweenService:Create(
                Seat,
                TweenInfo.new(Distance / 250, Enum.EasingStyle.Linear),
                { CFrame = Target }
            )

            _ENV.StopShip = function() Tween:Cancel() end
            Tween:Play()
        end

        function Ocean:Seabeast()
            local closest = nil
            local shortestDistance = 5000

            for _, seabeast in pairs(SeaBeasts:GetChildren()) do
                if not seabeast:IsA("Model") or not self:IsAlive(seabeast) then continue end

                local hrp = seabeast:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                local distance = Module:Distance(hrp.Position)

                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = seabeast
                end
            end

            return closest
        end

        function Ocean:IsSeaBeastHiding(Animator)
            for _, Track in Animator:GetPlayingAnimationTracks() do
                if TargetAnims[Track.Animation.AnimationId] then
                    return true
                end
            end
        end

        function Ocean:GetEnemiesShip(Name)
            local Nearest = nil
            local Distance = 5000

            for _, v in Enemies:GetChildren() do
                if not table.find(Name, v.Name) then continue end

                if not self:IsAlive(v) then continue end

                if not v:FindFirstChild("Seat", true) then continue end

                local Magnitude = Module:Distance(v:GetPivot().Position)

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        return Ocean
    end)

    AddModule("Skill", function()
        local SkillModule = {}

        local CurrentTool, LastSkillUse = nil, 0
        local Skills = PlayerGui.Main.Skills
        local IsReloading = false
        local OnFirstTime = true

        local function GetEnabledSkills()
            return {
                ['Melee'] = Settings['Melee'] or { "Z", "X", "C" },
                ['Sword'] = Settings['Sword'] or { "Z", "X" },
                ['Gun'] = Settings['Gun'] or { "Z", "X" },
                ['Blox Fruit'] = Settings['Blox Fruit'] or { "Z", "X", "C" }
            }
        end

        local function GetEnabledList(ToolName)
            local Tool = Backpack:FindFirstChild(ToolName) or Character:FindFirstChild(ToolName)

            return Tool and GetEnabledSkills()[Tool.ToolTip] or {}
        end

        local function IsToolValid(ToolFrame)
            if not ToolFrame or not ToolFrame:IsA("Frame") then return false end

            local Tool = Backpack:FindFirstChild(ToolFrame.Name) or Character:FindFirstChild(ToolFrame.Name)

            if not Tool then return false end

            local EnabledList = GetEnabledSkills()[Tool.ToolTip]

            return EnabledList and #EnabledList > 0
        end

        local function IsSkillUnlocked(Skill)
            local Title = Skill:FindFirstChild("Title")

            return Title and Title.TextColor3 == Color3.fromRGB(255, 255, 255)
        end

        local function IsSkillOnCooldown(Skill)
            local Cooldown = Skill:FindFirstChild("Cooldown")

            return Cooldown and Cooldown.Size.X.Scale > 0
        end

        local function IsSkillReady(Skill, ToolName)
            return table.find(GetEnabledList(ToolName), Skill.Name) and IsSkillUnlocked(Skill) and not IsSkillOnCooldown(Skill)
        end

        local function FindReadySkill(ToolContainer, ToolName)
            for _, Skill in ToolContainer:GetChildren() do
                if not Skill:IsA("Frame") or Skill.Name == "Template" then continue end

                if IsSkillReady(Skill, ToolName) then
                    return Skill.Name
                end
            end
        end

        local function FindLowestCooldownSkill(ToolContainer, ToolName)
            local SelectedSkill, LowestCooldown = nil, math.huge
            local EnabledList = GetEnabledList(ToolName)

            for _, Skill in ToolContainer:GetChildren() do
                if not Skill:IsA("Frame") or Skill.Name == "Template" then continue end

                if not IsSkillUnlocked(Skill) or not table.find(EnabledList, Skill.Name) then continue end

                local Cooldown = Skill:FindFirstChild("Cooldown")

                if not Cooldown or Cooldown.Size.X.Scale >= LowestCooldown then continue end

                LowestCooldown, SelectedSkill = Cooldown.Size.X.Scale, Skill.Name
            end

            return SelectedSkill
        end

        local function GetBestSkill(CurrentToolName)
            if CurrentToolName then
                local ToolContainer = Skills:FindFirstChild(CurrentToolName)

                if ToolContainer and IsToolValid(ToolContainer) then
                    local SkillName = FindReadySkill(ToolContainer, CurrentToolName)

                    if SkillName then
                        return CurrentToolName, SkillName
                    end
                end
            end

            local BestTool, BestSkill, LowestCooldown = nil, nil, math.huge

            for _, Tool in Skills:GetChildren() do
                if not Tool:IsA("Frame") or Tool.Name == "Container" then continue end

                if not IsToolValid(Tool) then continue end

                if Tool.Name == CurrentToolName then continue end

                local SkillName = FindReadySkill(Tool, Tool.Name)

                if SkillName then return Tool.Name, SkillName end

                local LowestSkill = FindLowestCooldownSkill(Tool, Tool.Name)

                if not LowestSkill then continue end

                local SkillFrame = Tool:FindFirstChild(LowestSkill)
                local Cooldown = SkillFrame and SkillFrame:FindFirstChild("Cooldown")

                if not Cooldown or Cooldown.Size.X.Scale >= LowestCooldown then continue end

                LowestCooldown, BestTool, BestSkill = Cooldown.Size.X.Scale, Tool.Name, LowestSkill
            end

            if not BestTool and CurrentToolName then
                local ToolContainer = Skills:FindFirstChild(CurrentToolName)

                if ToolContainer and IsToolValid(ToolContainer) then
                    local LowestSkill = FindLowestCooldownSkill(ToolContainer, CurrentToolName)

                    if LowestSkill then
                        return CurrentToolName, LowestSkill
                    end
                end
            end

            return BestTool, BestSkill
        end

        local function EquipTool(ToolName)
            if not IsAlive() then return false end

            local Tool = Backpack:FindFirstChild(ToolName)

            if not Tool then return false end

            if Tool:GetAttribute("Locks") then
                Tool:SetAttribute("Locks", nil)
            end

            if not Character:FindFirstChild(ToolName) then
                Humanoid:EquipTool(Tool)

                local Timeout = tick() + 1

                while not Character:FindFirstChild(ToolName) and tick() < Timeout do
                    task.wait()
                end
            end

            return Character:FindFirstChild(ToolName) ~= nil
        end

        local function OnToolAdded(Tool)
            if not Tool:IsA("Tool") then return end

            local EnabledSkills = GetEnabledSkills()

            if not EnabledSkills[Tool.ToolTip] then return end

            if Skills:FindFirstChild(Tool.Name) then return end

            IsReloading = true

            task.wait(0.5)

            Humanoid:UnequipTools()

            CurrentTool = nil

            Module:Equip(Tool.ToolTip, true)

            Humanoid:UnequipTools()

            IsReloading = false
        end

        local function BindBackpack()
            if _ENV.Reload then _ENV.Reload:Disconnect() end
            _ENV.Reload = Connect(Backpack.ChildAdded, OnToolAdded)
        end

        function SkillModule:Use()
            if not Character then return end
            
            if OnFirstTime then
                OnFirstTime = false do
                    return Module:Equip("Melee", true) 
                end
            end

            if IsReloading then return end
            if tick() - LastSkillUse < 0.2 then return end

            local ToolName, SkillName = GetBestSkill(CurrentTool)

            if not ToolName or not SkillName then return end

            if CurrentTool ~= ToolName then
                if not EquipTool(ToolName) then
                    Humanoid:UnequipTools()
                    task.wait(0.25)

                    for _, ToolType in pairs({"Melee", "Sword", "Gun", "Blox Fruit"}) do
                        Module:Equip(ToolType, true)
                        task.wait(0.15)
                    end

                    return
                end

                CurrentTool = ToolName
                task.wait(0.15)
            end

            if not Character:FindFirstChild(ToolName) then
                CurrentTool = nil
                return
            end

            LastSkillUse = tick()

            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[SkillName], false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[SkillName], false, game)
        end
        
        local function GetUnCooldownSkill(Name, Select)
            local ToolContainer = Skills:FindFirstChild(Name)
            if not ToolContainer then return nil end

            for _, KeyName in ipairs(Select) do
                local Skill = ToolContainer:FindFirstChild(KeyName)
                if not Skill or not Skill:IsA("Frame") then continue end
                if not IsSkillUnlocked(Skill) then continue end
                if IsSkillOnCooldown(Skill) then continue end

                return KeyName
            end

            return nil
        end

        local LAST_SIMPLE = 0

        function SkillModule:Skill(Select)
            if not Character then return end
            
            if not Select or #Select == 0 then return end

            if tick() - LAST_SIMPLE < 0.2 then return end

            local Equipped = Character:FindFirstChildOfClass("Tool")
            
            if not Equipped then return end

            local Skill = GetUnCooldownSkill(Equipped.Name, Select)
            
            if not Skill then return end

            LAST_SIMPLE = tick()

            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[Skill], false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[Skill], false, game)
        end

        task.spawn(BindBackpack)

        Connect(LocalPlayer.CharacterAdded, function(v)
            Character = v
            Head = v:WaitForChild("Head", 10)
            Humanoid = v:WaitForChild("Humanoid", 10)
            HumanoidRootPart = v:WaitForChild("HumanoidRootPart", 10)
            Backpack = LocalPlayer.Backpack

            CurrentTool = nil
            IsReloading = false

            warn("Spawn", Character, Humanoid, HumanoidRootPart, Backpack)

            BindBackpack()
        end)

        return SkillModule
    end)

    AddModule("TweenCreator", function()
        local TweenCreator = {}
        TweenCreator.__index = TweenCreator

        local tweens = {}
        local EasingStyle = Enum.EasingStyle.Linear

        function TweenCreator.new(obj, time, prop, value)
            local self = setmetatable({}, TweenCreator)

            self.tween = TweenService:Create(obj, TweenInfo.new(time, EasingStyle), { [prop] = value })
            self.tween:Play()
            self.value = value
            self.object = obj

            if tweens[obj] then
                tweens[obj]:destroy()
            end

            tweens[obj] = self
            return self
        end

        function TweenCreator:destroy()
            self.tween:Pause()
            self.tween:Destroy()

            tweens[self.object] = nil
            setmetatable(self, nil)
        end

        function TweenCreator:stopTween(obj)
            if obj and tweens[obj] then
                tweens[obj]:destroy()
            end
        end

        return TweenCreator
    end)

    AddModule("Colors", function()
        return function(text, color)
            if type(text) == "string" and typeof(color) == "Color3" then
                local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

                return string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text)
            end

            return text
        end
    end)

    AddModule("Data", function()
        local Data = {}

        Data['Island'] = {
            {
                ['Pirate Starter'] = CFrame.new(1077, 16, 1439),
                ['Marine Starter'] = CFrame.new(-2922, 41, 2111),
                ['Jungle'] = CFrame.new(-1439, 62, 8),
                ['Colosseum'] = CFrame.new(-1664, 151, -3245),
                ['Frozen Village'] = CFrame.new(1221, 138, -1487),
                ['Desert'] = CFrame.new(1058, 52, 4491),
                ['Fountain City'] = CFrame.new(5269, 56, 4061),
                ['Marine Fortress'] = CFrame.new(-5094, 263, 4414),
                ['Middle Town'] = CFrame.new(-849, 74, 1625),
                ['Pirate Village'] = CFrame.new(-1151, 65, 4160),
                ['Underwater City'] = CFrame.new(61318, 19, 1525),
                ['Whirlpool'] = CFrame.new(4344, 21, -1883),
                ['Prison'] = CFrame.new(5316, 89, 699),
                ['Lower Skyland'] = CFrame.new(-5050, 278, -2732),
                ['Middle Skyland'] = CFrame.new(-4654, 873, -1762),
                ['Upper Skyland'] = CFrame.new(-7654, 5623, -1071)
            },
            {
                ['Kingdom of Rose'] = CFrame.new(-385, 319, 463),
                ['Green Zone'] = CFrame.new(-2435, 73, -3250),
                ['Hot and Cold'] = CFrame.new(-5507, 82, -5165),
                ['Cursed Ship'] = CFrame.new(916, 126, 33073),
                ['Snow Mountain'] = CFrame.new(1008, 446, -4906),
                ['Ice Castle'] = CFrame.new(6146, 484, -6729),
                ['Dark Arena'] = CFrame.new(3892, 14, -3616),
                ['Graveyard Island'] = CFrame.new(-5722, 9, -963),
                ['Forgotten Island'] = CFrame.new(-3026, 319, -10083),
                ['North Pole'] = CFrame.new(-5397, 12, 1454),
            },
            {
                ['Submerged Island'] = CFrame.new(9952, -1887, 9678),
                ['Tiki Outpost'] = CFrame.new(-16928, 9, 437),
                ['Castle on the Sea'] = CFrame.new(-5086, 315, -2974),
                ['Hydra Island'] = CFrame.new(5164, 1174, 222),
                ['Peanut Island'] = CFrame.new(-2111, 193, -10243),
                ['Ice Cream Island'] = CFrame.new(-801, 210, -10999),
                ['Cake Loaf'] = CFrame.new(-1748, 489, -12360),
                ['Chocolate Island'] = CFrame.new(256, 124, -12549),
                ['North Pole'] = CFrame.new(-906, 89, -14666),
                ['Port Town'] = CFrame.new(-390, 11, 5244),
                ['Great Tree'] = CFrame.new(3295, 776, -6281),
                ['Haunted Castle'] = CFrame.new(-9499, 500, 6009),
                ['Floating Turtle'] = CFrame.new(-12310, 1163, -9968)
            },
            {}
        }

        local IslandString = {} do
            local seaIslands = Data['Island'][GetSea()]
            if seaIslands then
                for name, _ in pairs(seaIslands) do
                    table.insert(IslandString, name)
                end
            else
                warn("[Data] Island table not found for sea:", tostring(Module.Sea))
            end
        end

        Module.IslandString = IslandString

        Data['Place'] = {
            {
                ["Cyborg's Domain"] = CFrame.new(6271, 71, 4000),
                ["Thunder God's Domain"] = CFrame.new(-7989, 5814, -2030),
                ["Saber Expert's Domain"] = CFrame.new(-1425, 30, -14)
            },
            {
                ['Cafe'] = CFrame.new(-377, 73, 290),
                ['Basement Cafe'] = CFrame.new(-350, 16, 242),
                ['Mansion'] = CFrame.new(-392, 374, 720),
                ["Swan's Room"] = CFrame.new(2462, 15, 695),
                ['Raid'] = CFrame.new(-6535, 310, -4745),
                ['Labs'] = CFrame.new(-5548, 224, -5899),
                ['Colosseum'] = CFrame.new(-1822, 46, 1411),
            },
            {
                ["Beautiful Pirate's Domain"] = CFrame.new(5339, 22, -328),
                ['Head Castle on the Sea'] = CFrame.new(-5421, 1090, -2666),
                ['Mansion'] = CFrame.new(-12552, 337, -7504),
                ['Dragon Dojo'] = CFrame.new(5701, 1207, 924),
                ['Friendly Arena'] = CFrame.new(5012, 59, -1571),
                ['Waterfall'] = CFrame.new(5174, 8, 1191),
                ['Head of Great Tree'] = CFrame.new(3070, 2281, -7335)
            },
            {}
        }

        local PlaceString = {} do
            local seaPlaces = Data['Place'][GetSea()]
            if seaPlaces then
                for name, _ in pairs(seaPlaces) do
                    table.insert(PlaceString, name)
                end
            else
                warn("[Data] Place table not found for sea:", tostring(Module.Sea))
            end
        end

        Module.PlaceString = PlaceString

        Data['Material'] = {
            [1] = {
                ["Magma Ore"]      = { "Military Soldier", "Military Spy" },
                ["Leather"]        = { "Brute" },
                ["Scrap Metal"]    = { "Brute" },
                ["Angel Wings"]    = { "God's Guard" },
                ["Fish Tail"]      = { "Fishman Warrior", "Fishman Commando" },
                ["GunPowder"]      = { "Brute", "Pirate" }
            },
            [2] = {
                ["Magma Ore"]              = { "Magma Ninja" },
                ["Scrap Metal"]            = { "Swan Pirate" },
                ["Radioactive Material"]   = { "Factory Staff" },
                ["Vampire Fang"]           = { "Vampire" },
                ["Mystic Droplet"]         = { "Water Fighter", "Sea Soldier" },
                ["Ectoplasm"]              = { 'Ship Steward', 'Ship Officer', 'Ship Engineer', 'Ship Deckhand' }
            },
            [3] = {
                ["Mini Tusk"]      = { "Mythological Pirate" },
                ["Fish Tail"]      = { "Fishman Raider", "Fishman Captain" },
                ["Scrap Metal"]    = { "Jungle Pirate" },
                ["Dragon Scale"]   = { "Dragon Crew Archer", "Dragon Crew Warrior" },
                ["Conjured Cocoa"] = { "Cocoa Warrior", "Chocolate Bar Battler", "Sweet Thief", "Candy Rebel" },
                ["Demonic Wisp"]   = { "Demonic Soul" },
                ["Gunpowder"]      = { "Pistol Billionaire" }
            },
            [4] = {}
        }

        Data['Material List'] = (function(v)
            if v == 1 then
                return { "Magma Ore", "Leather", "Scrap Metal", "Angel Wings", "Fish Tail", 'GunPowder' }
            end

            if v == 2 then
                return { "Magma Ore", "Scrap Metal", "Radioactive Material", "Vampire Fang", "Mystic Droplet", "Ectoplasm" }
            end

            if v == 3 then
                return { "Mini Tusk", "Fish Tail", "Scrap Metal", "Dragon Scale", "Conjured Cocoa", "Demonic Wisp", "Gunpowder" }
            end

            warn("[Data] Material List: unrecognized sea:", tostring(Module.Sea))
            return {}
        end)(GetSea())

        Data['Shop'] = {
            ["Ability"] = {
                ["Buy Geppo"] = { "BuyHaki", "Geppo" },
                ["Buy Buso"] = { "BuyHaki", "Buso" },
                ["Buy Soru"] = { "BuyHaki", "Soru" },
                ["Buy Ken"] = { "KenTalk", "Buy" },
            },

            ["Sword"] = {
                ["Buy Katana"] = { "BuyItem", "Katana" },
                ["Buy Cutlass"] = { "BuyItem", "Cutlass" },
                ["Buy Dual Katana"] = { "BuyItem", "Dual Katana" },
                ["Buy Iron Mace"] = { "BuyItem", "Iron Mace" },
                ["Buy Triple Katana"] = { "BuyItem", "Triple Katana" },
                ["Buy Pipe"] = { "BuyItem", "Pipe" },
                ["Buy Dual-Headed Blade"] = { "BuyItem", "Dual-Headed Blade" },
                ["Buy Soul Cane"] = { "BuyItem", "Soul Cane" },
                ["Buy Bisento"] = { "BuyItem", "Bisento" },
            },

            ["Gun"] = {
                ["Buy Musket"] = { "BuyItem", "Musket" },
                ["Buy Slingshot"] = { "BuyItem", "Slingshot" },
                ["Buy Flintlock"] = { "BuyItem", "Flintlock" },
                ["Buy Refined Slingshot"] = { "BuyItem", "Refined Slingshot" },
                ["Buy Dual Flintlock"] = { "BuyItem", "Dual Flintlock" },
                ["Buy Cannon"] = { "BuyItem", "Cannon" },
                ["Buy Kabucha"] = { "BlackbeardReward", "Slingshot", "2" },
            },

            ["Accessories"] = {
                ["Buy Black Cape"] = { "BuyItem", "Black Cape" },
                ["Buy Swordsman Hat"] = { "BuyItem", "Swordsman Hat" },
                ["Buy Tomoe Ring"] = { "BuyItem", "Tomoe Ring" },
            },

            ["Race"] = {
                ["Ghoul Race"] = { "Ectoplasm", "Change", 4 },
                ["Cyborg Race"] = { "CyborgTrainer", "Buy" },
            },
        }

        function Data:GetMaterail(a)
            return self['Material'][GetSea()][a]
        end

        return Data
    end)

    AddModule("Bosses", function()
        local sea = GetSea()

        if sea == 1 then
            return {
                "The Gorilla King",
                "Chef",
                "Yeti",
                "Mob Leader",
                "Vice Admiral",
                "Warden",
                "Chief Warden",
                "Swan",
                "Magma Admiral",
                "Fishman Lord",
                "Wysper",
                "Thunder God",
                "Cyborg",
                "Saber Expert"
            }
        elseif sea == 2 then
            return {
                "Diamond",
                "Jeremy",
                "Orbitus",
                "Don Swan",
                "Smoke Admiral",
                "Cursed Captain",
                "Darkbeard",
                "Order",
                "Awakened Ice Admiral",
                "Tide Keeper"
            }
        elseif sea == 3 then
            return {
                "Stone",
                "Hydra Leader",
                "Kilo Admiral",
                "Captain Elephant",
                "Beautiful Pirate",
                "rip_indra True Form",
                "Longma",
                "Soul Reaper",
                "Cake Queen"
            }
        end

        warn("[Bosses] Unknown sea:", tostring(Module.Sea))

        return {}
    end)

    AddModule('EspManager', function()
        local EspManager = {}

        EspManager.__index = EspManager

        EspManager.__newindex = function(self, index, value)
            if index == "Enabled" then
                task.spawn(self.ToggleEsp, self, value)
            else
                rawset(self, index, value)
            end
        end

        local CoreGuiEspFolder = Instance.new("Folder", CoreGui) do
            CoreGuiEspFolder.Name = "XYN-EspFolder"

            local _EspFolder = CoreGui:FindFirstChild(CoreGuiEspFolder.Name)

            if _EspFolder and _EspFolder ~= CoreGuiEspFolder then
                _EspFolder:Destroy()
            end
        end

        local EspTemplate = Instance.new("BoxHandleAdornment") do
            local BoxHandleAdornment = EspTemplate
            BoxHandleAdornment.Size = Vector3.new(1, 0, 1, 0)
            BoxHandleAdornment.AlwaysOnTop = true
            BoxHandleAdornment.ZIndex = 10
            BoxHandleAdornment.Transparency = 0

            local BillboardGui = Instance.new("BillboardGui", BoxHandleAdornment)
            BillboardGui.Size = UDim2.new(0, 100, 0, 150)
            BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
            BillboardGui.AlwaysOnTop = true

            local TextLabel = Instance.new("TextLabel", BillboardGui)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Position = UDim2.new(0, 0, 0, -50)
            TextLabel.Size = UDim2.new(0, 100, 0, 100)
            TextLabel.TextSize = 10
            TextLabel.TextStrokeTransparency = 0
            TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
            TextLabel.Text = "..."
            TextLabel.ZIndex = 15
            TextLabel.RichText = true
        end

        local DefaultEspColor = Color3.fromRGB(255, 255, 255)
        local HumHealth = "%s<font color='rgb(160, 160, 160)'> [ %im ]</font>\n<font color='rgb(25, 240, 25)'>[%i/%i]</font>"
        local CreatedEsps = {}

        local function GetBasePart(Instance)
            if Instance:IsA("BasePart") then
                return Instance
            elseif Instance:IsA("Model") then
                return Instance.PrimaryPart or Instance:GetPivot()
            elseif Instance.Parent:IsA("Model") then
                return Instance.Parent.PrimaryPart or Instance.Parent:GetPivot()
            end
        end

        function EspManager:SetCustomEspDisplay(Action)
            self.CustomEspDisplay = Action
            return self
        end

        function EspManager:SetObjects(Objects)
            self.GetObjectsAction = Objects
            return self
        end

        function EspManager:GetInstance(Action)
            self.OnlyOneInstanceAction = Action
            return self
        end

        function EspManager:SetInstanceName(Instance, Name)
            self.EspsNames[Instance] = Name
            return self
        end

        function EspManager:SetAllInstancesName(Name)
            self.CustomInstanceName = Name
            return self
        end

        function EspManager:WaitChildsAdded()
            self._WaitChildsAdded = true
            return self
        end

        function EspManager:SetEspColor(Action)
            self.EspColor = Action
            return self
        end

        function EspManager:SetAlwaysValidate()
            self.AlwaysValidateInstance = true
            return self
        end

        function EspManager:Validator(Action)
            self.ValidateInstance = Action
            return self
        end

        function EspManager:ChangeEspSize(Size)
            self.EspSize = Size

            for i = 1, #CreatedEsps do
                for _, Esp in pairs(CreatedEsps[i].EspObjects) do
                    Esp.BoxHandleAdornment.BillboardGui.TextLabel.TextSize = Size
                end
            end

            return self
        end

        local BaseESP = "%s<font color='rgb(160, 160, 160)'> [ %im ]</font>"

        function EspManager:StartRunningEsp(Esp)
            local Instance = Esp.Instance
            local BoxHandleAdornment = Esp.BoxHandleAdornment
            local TextLabel = BoxHandleAdornment.BillboardGui.TextLabel
            local Folder = self.EspFolder
            local IsModel = Instance:IsA("Model")
            local CachedBasePart = nil

            while task.wait(Settings.SmoothMode and 0.25 or 0) do
                if not BoxHandleAdornment or not BoxHandleAdornment.Parent then
                    return self:Clear(Esp)
                elseif self.AlwaysValidateInstance and not self.ValidateInstance(Instance) then
                    return self:Clear(Esp)
                elseif not Instance:IsDescendantOf(workspace) and not Instance:IsDescendantOf(ReplicatedStorage) then
                    return self:Clear(Esp)
                end

                CachedBasePart = CachedBasePart or GetBasePart(Instance)

                if not CachedBasePart then
                    return self:Clear(Esp)
                end

                local DistanceValue = math.floor((Module:Distance(CachedBasePart.Position)) / 5)
                local Humanoider = IsModel and Instance:FindFirstChildOfClass("Humanoid")

                if Humanoider then
                    TextLabel.Text = HumHealth:format(Instance.Name, DistanceValue, math.floor(Humanoider.Health), math.floor(Humanoider.MaxHealth))
                elseif self.CustomEspDisplay then
                    TextLabel.Text = self.CustomEspDisplay(Instance, DistanceValue)
                else
                    local Name = self.CustomInstanceName or self.EspsNames[Instance] or Instance.Name
                    TextLabel.Text = BaseESP:format(Name, DistanceValue)
                end
            end
        end

        function EspManager:Create(Instance)
            if self.EspObjects[Instance] then return end

            local Esp = {
                Instance = Instance,
                BoxHandleAdornment = nil
            }

            local BoxHandleAdornment = EspTemplate:Clone()
            local BillboardGui = BoxHandleAdornment.BillboardGui
            local TextLabel = BillboardGui.TextLabel

            BillboardGui.Adornee = (Instance:IsA("BasePart") or Instance:IsA("Model")) and Instance or Instance.Parent
            TextLabel.TextColor3 = type(self.EspColor) == "function" and self.EspColor(Instance) or self.EspColor or DefaultEspColor
            TextLabel.Text = self.CustomInstanceName or "..."
            TextLabel.TextSize = self.EspSize or TextLabel.TextSize
            BoxHandleAdornment.Parent = self.EspFolder

            self.EspObjects[Instance] = Esp
            Esp.BoxHandleAdornment = BoxHandleAdornment

            task.spawn(self.StartRunningEsp, self, Esp)

            return Esp
        end

        function EspManager:Clear(Esp)
            if Esp then
                self.EspObjects[Esp.Instance] = nil
                if Esp.BoxHandleAdornment then Esp.BoxHandleAdornment:Destroy() end
            else
                table.clear(self.EspObjects)
                self.EspFolder:ClearAllChildren()
            end
        end

        function EspManager:ToggleEsp(Value)
            local Environment = "Xyn_Esp_" .. self.SpecialTag
            _ENV[Environment] = Value

            if not Value then
                return self:Clear()
            end

            while _ENV[Environment] do
                local ObjectsAction = self.GetObjectsAction
                local CreatedNew = false

                if self.OnlyOneInstanceAction then
                    local Instance = self.OnlyOneInstanceAction()

                    if Instance then
                        self:Create(Instance)
                    end
                elseif ObjectsAction then
                    local Instances

                    if typeof(ObjectsAction) == "function" then
                        Instances = ObjectsAction()
                    elseif typeof(ObjectsAction) == "Instance" then
                        Instances = ObjectsAction:GetChildren()
                    else
                        Instances = ObjectsAction
                    end

                    local Validate = self.ValidateInstance
                    local CreatedEsps = self.EspObjects

                    for i = 1, #Instances do
                        local Instance = Instances[i]

                        if not CreatedEsps[Instance] and (not Validate or Validate(Instance)) then
                            CreatedNew = true
                            self:Create(Instance)
                        end
                    end
                end

                if not CreatedNew and self._WaitChildsAdded then
                    ObjectsAction.ChildAdded:Wait()
                end

                task.wait(0.25)
            end
        end

        function EspManager.new(Tag)
            local EspFolder = Instance.new("Folder", CoreGuiEspFolder)
            EspFolder.Name = Tag

            local self = setmetatable({
                SpecialTag = Tag,
                EspObjects = {},
                EspsNames = {},
                EspFolder = EspFolder
            }, EspManager)

            table.insert(CreatedEsps, self)

            return self
        end

        return EspManager
    end)

    AddModule('IndicatorHandler', function()
        local IndicatorHandler = {}
        local EspManager = Module.EspManager

        local FLOWERS = {
            Flower1 = "Blue Flower",
            Flower2 = "Red Flower",
        }

        local BERRIES = {
            "Pink Pig Berry", "Purple Jelly Berry", "Red Cherry Berry",
            "Blue Icicle Berry", "Green Toad Berry", "Orange Berry",
            "White Cloud Berry", "Yellow Star Berry",
        }

        local SPACIALS_ISLAND = {
            PrehistoricIsland = "Prehistoric Island",
            KitsuneIsland = "Kitsune Island",
            MysticIsland = "Mirage Island",
            FrozenDimension = "Frozen Dimension"
        }

        local FRUIT_SPAWNERS = { "AppleSpawner", "PineappleSpawner", "BananaSpawner" }

        local function GetText(Text, Dist)
            if Settings["Distance Indicator"] then
                return string.format("%s<font color='rgb(160, 160, 160)'> [ %im ]</font>", Text, Dist)
            end

            return Text
        end

        local function GetBerryName(Bush)
            for _, v in Bush:GetAttributes() do
                if typeof(v) == "string" and table.find(BERRIES, v) then
                    return v
                end
            end

            return "Unknown Berry"
        end

        local function GetBloxFruitName(Fruit)
            local Current = Fruit.Name
            if not Fruit:IsA('Model') then return Current end

            local Idle = Fruit:FindFirstChild('Idle', true)
            if not Idle then return Current end

            local Id = tostring(Idle.AnimationId)
            if not Id then return Current end

            local Name = Module.FruitsId[Id]
            if not Name then return Current end

            return Name .. " [ Spawned ]"
        end

        local function NewChests()
            local List = {}

            for _, Chest in CollectionService:GetTagged("_ChestTagged") do
                if not Chest:GetAttribute("IsDisabled") then
                    table.insert(List, Chest)
                end
            end

            return List
        end

        local function NewBerry()
            local List = {}

            for _, Bush in CollectionService:GetTagged("BerryBush") do
                if next(Bush:GetAttributes()) then
                    table.insert(List, Bush)
                end
            end

            return List
        end

        local function NewFruits()
            local List = {}

            for _, SpawnerName in FRUIT_SPAWNERS do
                local Spawner = workspace:FindFirstChild(SpawnerName)

                if not Spawner then continue end

                for _, v in Spawner:GetChildren() do
                    if v:IsA("Tool") then
                        table.insert(List, v)
                    end
                end
            end

            return List
        end

        local function NewGear()
            local Gears = {}

            local Mirage = Map:FindFirstChild('MysticIsland')

            if not Mirage then return Gears end

            for _, v in Mirage:GetChildren() do
                if v:IsA("MeshPart") and v.BrickColor == BrickColor.new('Pastel Blue')  then
                    table.insert(Gears, v)
                end
            end

            return Gears
        end

        local COLORS = {
            ["Spacial Island"] = {
                Colors = Color3.fromRGB(255, 0, 127),
                Folder = Map,
                Valid = function(v)
                    return SPACIALS_ISLAND[v.Name] ~= nil
                end,
                CustomName = function(v, Dist)
                    return GetText(SPACIALS_ISLAND[v.Name] or v.Name, Dist)
                end,
            },
            ["Devil Fruits"] = {
                Colors = Color3.fromRGB(255, 0, 0),
                Folder = workspace,
                Valid = function(v)
                    return v.Name:find("Fruit") ~= nil
                end,
                CustomName = function(v, Dist)
                    return GetText(GetBloxFruitName(v), Dist)
                end
            },
            ["Sea Beast"] = {
                Colors = Color3.fromRGB(0, 85, 127),
                Folder = function()
                    return SeaBeasts:GetChildren()
                end,
                Valid = function(v)
                    if not v:IsA("Model") then return false end
                    
                    local Health = v:FindFirstChild("Health")
                    
                    return Health ~= nil and Health.Value > 0
                end,
                CustomName = function(v, Dist)
                    local Health = v:FindFirstChild("Health")
                    
                    if not Health then
                        return GetText("Sea Beast", Dist)
                    end
                    
                    return GetText(string.format("Sea Beast [ %i ]", Health.Value), Dist)
                end,
            },
            ["Flowers"] = {
                Colors = Color3.fromRGB(255, 170, 255),
                Folder = workspace,
                Valid = function(v)
                    return v.Name:find("Flower") ~= nil
                end,
                CustomName = function(v, Dist)
                    return GetText(FLOWERS[v.Name] or v.Name, Dist)
                end,
            },
            ["Players"] = {
                Colors = Color3.fromRGB(255, 255, 255),
                Folder = Characters,
                Valid = function(v)
                    local Player = Players:GetPlayerFromCharacter(v)
                    return Player and Player ~= LocalPlayer
                end,
            },
            ["Chest"] = {
                Colors = Color3.fromRGB(255, 255, 127),
                Folder = NewChests,
                Valid = function(v)
                    return not v:GetAttribute("IsDisabled")
                end,
                CustomName = function(v, Dist)
                    return GetText("Chest", Dist)
                end,
            },
            ["Berries"] = {
                Colors = Color3.fromRGB(101, 104, 255),
                Folder = NewBerry,
                Valid = function(v)
                    return next(v:GetAttributes()) ~= nil
                end,
                CustomName = function(v, Dist)
                    return GetText(GetBerryName(v), Dist)
                end,
            },
            ["Fruits"] = {
                Colors = Color3.fromRGB(0, 255, 127),
                Folder = NewFruits,
                Valid = function(v)
                    return v:IsA("Tool") and v.Parent ~= nil
                end,
                CustomName = function(v, Dist)
                    return GetText(v.Name, Dist)
                end,
            },
            ["Gear"] = {
                Colors = Color3.fromRGB(85, 255, 255),
                Folder = NewGear,
                Valid = function(v)
                    return v:IsA("MeshPart") and v.Parent ~= nil
                end,
                CustomName = function(v, Dist)
                    return GetText("Gear", Dist)
                end,
            },
            ["Ship"] = {
                Colors = Color3.fromRGB(115, 169, 255),
                Folder = Boats,
                Valid = function(v)
                    return v.Parent ~= nil
                end,
                CustomName = function(v, Dist)
                    local Owner = v:FindFirstChild("Owner")

                    if Owner and Owner.Value then
                        return GetText(string.format("%s [ %s ]", v.Name, tostring(Owner.Value)), Dist)
                    end

                    return GetText(v.Name, Dist)
                end,
            },
        }

        local ESP_HANDLERS = {}

        for Name, Data in COLORS do
            local Handler = EspManager.new(Name)

            Handler:SetEspColor(Data.Colors)

            if type(Data.Folder) == "function" then
                Handler:SetObjects(Data.Folder)
            else
                Handler:SetObjects(function()
                    return Data.Folder:GetChildren()
                end)
            end

            if Data.Valid then
                Handler:Validator(Data.Valid)
                Handler:SetAlwaysValidate()
            end

            if Data.CustomName then
                Handler:SetCustomEspDisplay(Data.CustomName)
            end

            ESP_HANDLERS[Name] = Handler
        end

        IndicatorHandler["Change"] = function(Value, Select)
            for Name, Handler in ESP_HANDLERS do
                Handler.Enabled = Value and table.find(Select, Name) ~= nil
            end
        end

        return IndicatorHandler
    end)

    task.spawn(function()
        local SpawnLocations = Module.SpawnLocations
        local EnemyLocations = Module.EnemyLocations
        local EnemiesModule = Module.EnemiesModule

        local function NewIslandAdded(Island)
            if Island.Name:find("Island") then
                Cached.RaidIsland = nil
            end
        end

        local function NewSpawn(Part)
            local EnemyName = GetEnemyName(Part.Name)
            EnemyLocations[EnemyName] = EnemyLocations[EnemyName] or {}

            local EnemySpawn = Part.CFrame + Vector3.new(0, 25, 0)
            SpawnLocations[EnemyName] = Part

            if not table.find(EnemyLocations[EnemyName], EnemySpawn) then
                table.insert(EnemyLocations[EnemyName], EnemySpawn)
            end
        end

        for _, Spawn in EnemySpawns:GetChildren() do NewSpawn(Spawn) end
        Connect(EnemySpawns.ChildAdded, NewSpawn)
        Connect(Locations.ChildAdded, NewIslandAdded)
    end)

    task.defer(function()
        if Executor ~= "XENO" then

            local function Log(code, message, context)
                return warn(string.format("[ Forbidden ] [ %03d ] [ %s ] \n%s",code,context,message))
            end

            if not _ENV.xyn_original then
                local _Old

                local safehook = hookmetamethod and clonefunction(hookmetamethod)
                local safegetnamecall = getnamecallmethod and clonefunction(getnamecallmethod)

                _Old = safehook(game, "__namecall", function(self, ...)
                    local method = safegetnamecall()

                    if tostring(self) == "PlayerGui" then
                        if method == "Destroy" or method == "Remove" or method == "ClearAllChildren" then
                            return Log(
                                403,
                                "Access denied - PlayerGui:Destroy()",
                                "PlayerGui was locked."
                            )
                        end
                    end

                    if method == "FireServer" or method == "InvokeServer" then
                        local arg1, arg2 = ...

                        if method == "InvokeServer" and arg1 == 'X' and typeof(arg2) == 'Vector3' and self.Name == "" then
                            if Module.Aimbot:Check() or (_ENV.GLOBALS_SETTINGS['Skill Usage'] and _ENV.__XYN_TARGETER) then
                                return _Old(self, arg1, _ENV.Target)
                            end

                            return _Old(self, ...)
                        end

                        if method == "FireServer" and self.Name == "RemoteEvent" and typeof(arg1) == "Vector3" and arg2 == nil then
                            if Module.Aimbot:Check() or (_ENV.GLOBALS_SETTINGS['Skill Usage'] and _ENV.__XYN_TARGETER) then
                                return _Old(self, _ENV.Target)
                            end

                            return _Old(self, ...)
                        end
                    end

                    return _Old(self, ...)
                end)

                _ENV.xyn_original = _Old
            end
        end
    end)

    return Module
end)
