local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local cachedRemote, cachedRemoteId = nil, nil

local function registerRemote(obj)
    if obj:IsA("RemoteEvent") and obj:GetAttribute("Id") then
        cachedRemote = obj
        cachedRemoteId = obj:GetAttribute("Id")
    end
end

for _, folder in ipairs({
    ReplicatedStorage.Util,
    ReplicatedStorage.Common,
    ReplicatedStorage.Remotes,
    ReplicatedStorage.Assets,
    ReplicatedStorage.FX,
    }) do
    for _, child in ipairs(folder:GetChildren()) do
        registerRemote(child)
    end
    folder.ChildAdded:Connect(registerRemote)
end

local function getNearbyEnemyParts(rootPart, range)
    local results = {}
    for _, folder in ipairs({ workspace.Enemies, workspace.Characters }) do
        for _, entity in ipairs(folder:GetChildren()) do
            local entityRoot = entity:FindFirstChild("HumanoidRootPart")
            local humanoid = entity:FindFirstChild("Humanoid")
            if entity ~= LocalPlayer.Character
                and entityRoot
                and humanoid
                and humanoid.Health > 0
                and (entityRoot.Position - rootPart.Position).Magnitude <= range
            then
                for _, part in ipairs(entity:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(results, { entity, part })
                    end
                end
            end
        end
    end
    return results
end

local function encryptRemoteName(name)
    return string.gsub(name, ".", function(c)
        return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
    end)
end

local function fireHit(targets)
    local character = LocalPlayer.Character
    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local weaponType = tool:GetAttribute("WeaponType")
    if weaponType ~= "Melee" and weaponType ~= "Sword" then return end

    local head = targets[1][1]:FindFirstChild("Head")
    if not head then return end

    local Net = require(ReplicatedStorage.Modules.Net)
    local uid = tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
    local seed = ReplicatedStorage.Modules.Net.seed:InvokeServer()
    local xorId = bit32.bxor(cachedRemoteId + 909090, seed * 2)

    pcall(function()
        Net:RemoteEvent("RegisterHit", true)
        ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()
        ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(head, targets, {}, uid)
        cloneref(cachedRemote):FireServer(encryptRemoteName("RE/RegisterHit"), xorId, head, targets)
    end)
end

game:GetService('StarterGui'):SetCore('SendNotification', {
    Title = 'Injecting ..',
    Text = "Waiting for seed ...",
    Duration = 3,
})

task.delay(5, function()
    game:GetService('StarterGui'):SetCore('SendNotification', {
        Title = 'Injected !',
        Text = "✅ : Operational",
        Duration = 5,
    })
end)

task.spawn(function()
    while task.wait(0.1) do
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end

        local targets = getNearbyEnemyParts(rootPart, 50)
        
        if #targets > 0 then
            fireHit(targets)
        end
    end
end)
