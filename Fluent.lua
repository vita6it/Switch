local Library = {}

local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')

local Mobile = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then true else false

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

function Library:Parent()
    if not RunService:IsStudio() then
        return (gethui and gethui()) or CoreGui
    end
    return PlayerGui
end

function Library:Create(Class, Properties)
    local Creations = Instance.new(Class)
    for prop, value in Properties do
        Creations[prop] = value
    end
    return Creations
end

function Library:Draggable(a)
    local Dragging, DragInput, DragStart, StartPosition = nil, nil, nil, nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(a, TweenInfo.new(0.3), {Position = pos}):Play()
    end

    a.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = a.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    a.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Library:Button(Parent): TextButton
    return Library:Create("TextButton", {
        Name = "Click",
        Parent = Parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        ZIndex = Parent.ZIndex + 3
    })
end

function Library:Tween(info)
    return TweenService:Create(info.v, TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]), info.g)
end

function Library:Asset(rbx)
    if typeof(rbx) == 'number' then
        return "rbxassetid://" .. rbx
    end
    if typeof(rbx) == 'string' and rbx:find('rbxassetid://') then
        return rbx
    end
    return rbx
end

function Library:LockOption(Parent, Text)
    local Locked_1 = Instance.new("Frame")
    local Title_1 = Instance.new("TextLabel")

    Locked_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Locked_1.BackgroundTransparency = 0.5
    Locked_1.Name = "Locked"
    Locked_1.Parent = Parent
    Locked_1.Size = UDim2.new(1, 0, 1, 0)
    Locked_1.Selectable = false
    Locked_1.BorderSizePixel = 0

    Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Title_1.AutomaticSize = Enum.AutomaticSize.Y
    Title_1.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Title_1.BackgroundTransparency = 1
    Title_1.BorderColor3 = Color3.fromRGB(27, 42, 53)
    Title_1.BorderSizePixel = 1
    Title_1.Name = "Title"
    Title_1.Parent = Locked_1
    Title_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Title_1.Size = UDim2.new(1, 0, 0, 0)
    Title_1.Selectable = false
    Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title_1.Text = Text or "Option has been Locked."
    Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title_1.TextSize = 13
    Title_1.TextWrapped = true
    
    for _, v in Parent:GetDescendants() do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            v.Visible = false
        elseif v:IsA('TextBox') then
            v.Interactable = false
            v.ClearTextOnFocus = false
            v.TextEditable = false
        end
    end
end

function Library:Rows(Parent, Args)
    local Title = Args.Title
    local Desc = Args.Desc

    local Template_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Template",
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, 0),          -- เปลี่ยน Y เป็น 0
        AutomaticSize = Enum.AutomaticSize.Y,   -- เพิ่ม AutomaticSize
        Selectable = false,
    })

    local Scale_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Scale",
        Parent = Template_1,
        Size = UDim2.new(1, 0, 0, 0),          -- เปลี่ยน Y เป็น 0
        AutomaticSize = Enum.AutomaticSize.Y,   -- เพิ่ม AutomaticSize
        Selectable = false,
    })

    local Left_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Left",
        Parent = Scale_1,
        Size = UDim2.new(1, 0, 0, 0),          -- เปลี่ยน Y เป็น 0
        AutomaticSize = Enum.AutomaticSize.Y,   -- เพิ่ม AutomaticSize
        Selectable = false,
    })

    Library:Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        Parent = Left_1,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    Library:Create("UIPadding", {
        Parent = Left_1,
        PaddingBottom = UDim.new(0, 8),         -- เพิ่ม padding บน/ล่างให้มี breathing room
        PaddingTop = UDim.new(0, 8),            -- เพิ่ม
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 50),
    })

    local Text_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Text",
        Parent = Left_1,
        Position = UDim2.new(0.07010302692651749, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),          -- เปลี่ยน Y เป็น 0
        AutomaticSize = Enum.AutomaticSize.Y,   -- เพิ่ม AutomaticSize
        Selectable = false,
    })

    Library:Create("UIListLayout", {
        Parent = Text_1,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    local Title_1 = Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Name = "Title",
        Parent = Text_1,
        Size = UDim2.new(1, 0, 0, 0),          -- เปลี่ยนให้ Width เต็ม, Y เป็น 0
        AutomaticSize = Enum.AutomaticSize.Y,   -- เพิ่ม AutomaticSize
        Selectable = false,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = Title,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,                     -- เพิ่ม TextWrapped
    })

    local Sub_1

    if Desc then
        Sub_1 = Library:Create("TextLabel", {
            BackgroundTransparency = 1,
            Name = "Sub",
            Parent = Text_1,
            Size = UDim2.new(1, -40, 0, 0),    -- เปลี่ยน Y เป็น 0
            AutomaticSize = Enum.AutomaticSize.Y, -- เพิ่ม AutomaticSize
            Selectable = false,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Text = Desc,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 9,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,                 -- เปลี่ยน TextTruncate → TextWrapped
        })
    end

    local Right_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Right",
        Parent = Scale_1,
        Size = UDim2.new(1, 0, 1, 0),
        Selectable = false,
    })

    Library:Create("UIListLayout", {
        Parent = Right_1,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    Library:Create("UIPadding", {
        Parent = Right_1,
        PaddingRight = UDim.new(0, 10),
    })

    local Line_1 = Library:Create("Frame", {
        BackgroundTransparency = 0.9700000286102295,
        Name = "Line",
        Parent = Template_1,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Selectable = false,
    })

    return {
        Template = Template_1,
        Right = Right_1,
        Line_1 = Line_1,
        Title = Title_1,
        Desc = Sub_1
    }
end

function Library:UpdateLine(Rows)
    for i, row in Rows do
        if row.Line_1 then
            row.Line_1.Visible = (i ~= #Rows)
        end
    end
end

function Library:CreateWindow(Args)
    local Banner = Args.Banner and Library:Asset(Args.Banner) or ""
	local Logo = Args.Logo and Library:Asset(Args.Logo) or ""
	local Fetch = Args.Fetch or function()
		return true
	end
    
    local HIDDEN_PARENT = Library:Parent()

    local Switch_1 = Instance.new("ScreenGui")
    local Background_1 = Instance.new("Frame")
    local UICorner_1 = Instance.new("UICorner")
    local UICorner_2 = Instance.new("UICorner")
    local UIStroke_1 = Instance.new("UIStroke")
    local Shadow_1 = Instance.new("ImageLabel")
    local Pages_1 = Instance.new("Frame")
    
    function Library:IsDropdownOpen()
        for _, v in pairs(Background_1:GetChildren()) do
            if v.Name == "Dropdown" and v.Visible then
                return true
            end
        end
    end

    Switch_1.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    Switch_1.IgnoreGuiInset = true
    Switch_1.Name = "Switch"
    Switch_1.Parent = HIDDEN_PARENT

    Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Background_1.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Background_1.Name = "Background"
    Background_1.Parent = Switch_1
    Background_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Background_1.Size = UDim2.new(0, 500, 0, 120)
    Background_1.Selectable = false
    Background_1.BackgroundTransparency = Args.Transparent and 0.03 or 0
    Background_1.Visible = false
    
    Library:Draggable(Background_1)
    
    UICorner_1.CornerRadius = UDim.new(0, 10)
    UICorner_1.Parent = Background_1

    UIStroke_1.Thickness = 0.5
    UIStroke_1.Transparency = 0.75
    UIStroke_1.Parent = Background_1

    Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow_1.BackgroundTransparency = 1
    Shadow_1.Name = "Shadow"
    Shadow_1.Parent = Background_1
    Shadow_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow_1.Size = UDim2.new(1, 120, 1, 120)
    Shadow_1.ZIndex = -999
    Shadow_1.Image = "rbxassetid://8992230677"
    Shadow_1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow_1.ImageContent = Content.fromUri("rbxassetid://8992230677")
    Shadow_1.ImageTransparency = 0.5
    Shadow_1.ScaleType = Enum.ScaleType.Slice
    Shadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

    Pages_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Pages_1.BackgroundTransparency = 1
    Pages_1.Name = "Pages"
    Pages_1.Parent = Background_1
    Pages_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Pages_1.Size = UDim2.new(1, 0, 1, 0)
    Pages_1.Selectable = false
    Pages_1.ClipsDescendants = true
    
    local PageLayout = Instance.new('UIPageLayout') do
        PageLayout.TweenTime = 0.375
        PageLayout.GamepadInputEnabled = false
        PageLayout.ScrollWheelInputEnabled = false
        PageLayout.TouchInputEnabled = false
        PageLayout.Parent = Pages_1
        PageLayout.EasingStyle = Enum.EasingStyle.Exponential
    end
    
    local Inner_1 = Instance.new("ImageLabel") do
        local UICorner_1 = Instance.new("UICorner")

        Inner_1.BackgroundTransparency = 1
        Inner_1.AnchorPoint = Vector2.new(0, 1)
        Inner_1.Position = UDim2.new(0, 0, 1, 0)
        Inner_1.Name = "Inner"
        Inner_1.Parent = Background_1
        Inner_1.Size = UDim2.new(0, 500, 0, 440)
        Inner_1.Image = "rbxassetid://122898596888502"
        Inner_1.ImageColor3 = Color3.fromRGB(15, 15, 15)
        
        UICorner_1.CornerRadius = UDim.new(0, 10)
        UICorner_1.Parent = Inner_1
        

        local Lights_1 = Instance.new("Frame")
        local UIListLayout_1 = Instance.new("UIListLayout")
        local Frame_1 = Instance.new("Frame")
        local UICorner_1 = Instance.new("UICorner")
        local UIStroke_1 = Instance.new("UIStroke")
        local UIPadding_1 = Instance.new("UIPadding")
        local Frame_2 = Instance.new("Frame")
        local UICorner_2 = Instance.new("UICorner")
        local UIStroke_2 = Instance.new("UIStroke")
        local Frame_3 = Instance.new("Frame")
        local UICorner_3 = Instance.new("UICorner")
        local UIStroke_3 = Instance.new("UIStroke")

        Lights_1.AnchorPoint = Vector2.new(0, 1)
        Lights_1.BackgroundTransparency = 1
        Lights_1.Name = "Lights"
        Lights_1.Parent = Background_1
        Lights_1.Position = UDim2.new(0, 0, 1, 0)
        Lights_1.Size = UDim2.new(1, 0, 0, 20)
        Lights_1.Selectable = false

        UIListLayout_1.Padding = UDim.new(0, 3)
        UIListLayout_1.Parent = Lights_1
        UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
        UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

        Frame_1.BackgroundColor3 = Color3.fromRGB(40, 200, 64)
        Frame_1.Parent = Lights_1
        Frame_1.Size = UDim2.new(0, 5, 0, 5)
        Frame_1.Selectable = false

        UICorner_1.CornerRadius = UDim.new(1, 0)
        UICorner_1.Parent = Frame_1

        UIStroke_1.Thickness = 0.75
        UIStroke_1.Transparency = 0.30000001192092896
        UIStroke_1.Parent = Frame_1

        UIPadding_1.Parent = Lights_1
        UIPadding_1.PaddingRight = UDim.new(0, 7)

        Frame_2.BackgroundColor3 = Color3.fromRGB(254, 188, 46)
        Frame_2.Parent = Lights_1
        Frame_2.Size = UDim2.new(0, 5, 0, 5)
        Frame_2.Selectable = false

        UICorner_2.CornerRadius = UDim.new(1, 0)
        UICorner_2.Parent = Frame_2

        UIStroke_2.Thickness = 0.75
        UIStroke_2.Transparency = 0.30000001192092896
        UIStroke_2.Parent = Frame_2

        Frame_3.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
        Frame_3.Parent = Lights_1
        Frame_3.Size = UDim2.new(0, 5, 0, 5)
        Frame_3.Selectable = false

        UICorner_3.CornerRadius = UDim.new(1, 0)
        UICorner_3.Parent = Frame_3

        UIStroke_3.Thickness = 0.75
        UIStroke_3.Transparency = 0.30000001192092896
        UIStroke_3.Parent = Frame_3
    end
    
    local Home_1 = Instance.new("Frame")
    local UIListLayout_1 = Instance.new("UIListLayout")
    local Banner_1 = Instance.new("Frame")
    local UIListLayout_2 = Instance.new("UIListLayout")
    local Logo_1 = Instance.new("ImageLabel")
    local UIPadding_1 = Instance.new("UIPadding")
    local BannerImage_1 = Instance.new("ImageLabel")
    local UICorner_1 = Instance.new("UICorner")
    local Tabs_1 = Instance.new("Frame")
    local Scrolling_1 = Instance.new("ScrollingFrame")
    local UIListLayout_3 = Instance.new("UIListLayout")
    local UIPadding_2 = Instance.new("UIPadding")
    local UIPadding_3 = Instance.new("UIPadding")
    local Horizon_1 = Instance.new("Frame")

    Home_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Home_1.BackgroundTransparency = 1
    Home_1.Name = "Home"
    Home_1.Parent = Pages_1
    Home_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Home_1.Size = UDim2.new(1, 0, 1, 0)
    Home_1.Selectable = false

    UIListLayout_1.Parent = Home_1
    UIListLayout_1.SortOrder = Enum.SortOrder.Name
    UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Banner_1.BackgroundTransparency = 1
    Banner_1.LayoutOrder = -999
    Banner_1.Name = "Banner"
    Banner_1.Parent = Home_1
    Banner_1.Size = UDim2.new(1, 0, 0, 120)
    Banner_1.Selectable = false

    UIListLayout_2.Padding = UDim.new(0, 30)
    UIListLayout_2.Parent = Banner_1
    UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

    Logo_1.BackgroundTransparency = 1
    Logo_1.Name = "Logo"
    Logo_1.Parent = Banner_1
    Logo_1.Image = Logo
    Logo_1.Size = UDim2.new(0, 100, 0 ,100)
    
    UIPadding_1.Parent = Banner_1
    UIPadding_1.PaddingLeft = UDim.new(0, 20)

    BannerImage_1.BackgroundTransparency = 1
    BannerImage_1.Name = "BannerImage"
    BannerImage_1.Parent = Banner_1
    BannerImage_1.Position = UDim2.new(0.20449897646903992, 0, 0.0833333358168602, 0)
    BannerImage_1.Size = UDim2.new(0, 340, 0, 100)
    BannerImage_1.Image = Banner
    
    UICorner_1.CornerRadius = UDim.new(0, 5)
    UICorner_1.Parent = BannerImage_1

    Tabs_1.BackgroundTransparency = 1
    Tabs_1.LayoutOrder = -997
    Tabs_1.Name = "Tabs"
    Tabs_1.Parent = Home_1
    Tabs_1.Size = UDim2.new(1, 0, 0, 240)
    Tabs_1.Selectable = false
    Tabs_1.Visible = false

    Scrolling_1.BackgroundTransparency = 1
    Scrolling_1.Name = "Scrolling"
    Scrolling_1.Parent = Tabs_1
    Scrolling_1.Size = UDim2.new(1, 0, 1, 0)
    Scrolling_1.ScrollBarImageTransparency = 1
    Scrolling_1.ScrollBarThickness = 0

    UIListLayout_3.Padding = UDim.new(0, 6)
    UIListLayout_3.Parent = Scrolling_1
    UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_3.SortOrder = Enum.SortOrder.Name
    UIListLayout_3.Wraps = true
    
    UIListLayout_3:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        Scrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_3.AbsoluteContentSize.Y + 15)
    end)

    UIPadding_2.Parent = Scrolling_1
    UIPadding_2.PaddingBottom = UDim.new(0, 1)
    UIPadding_2.PaddingLeft = UDim.new(0, 2)
    UIPadding_2.PaddingRight = UDim.new(0, 2)
    UIPadding_2.PaddingTop = UDim.new(0, 1)

    UIPadding_3.Parent = Tabs_1
    UIPadding_3.PaddingBottom = UDim.new(0, 10)
    UIPadding_3.PaddingLeft = UDim.new(0, 10)
    UIPadding_3.PaddingRight = UDim.new(0, 10)
    UIPadding_3.PaddingTop = UDim.new(0, 10)

    Horizon_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Horizon_1.LayoutOrder = -998
    Horizon_1.Name = "Horizon"
    Horizon_1.Parent = Home_1
    Horizon_1.Size = UDim2.new(1, 0, 0, 1)
    Horizon_1.Selectable = false
    Horizon_1.BackgroundTransparency = 1
    
    local Window = {}
    local Transcendants = {}
    
    local function TranscendantsInit()
        for Instancer, Properties in Transcendants do
            for Index, Value in Properties do
                Library:Tween({
                    v = Instancer,
                    t = 0.5,
                    s = "Linear",
                    d = "Out",
                    g = {
                        [ Index ] = Value
                    }
                }):Play()
            end
        end
    end
    
    Window.Options = setmetatable({}, {
        __index = function(t, k)
            t[k] = { Value = nil }
            return t[k]
        end,
    })
    
    function Window:AddTab(Args)
        local Title = Args.Title or "Unknow"
        local Desc = Args.Desc or "Automation"
        local Icon = Args.Icon or 72381052356914
        local Template = Args.Banner or 89792855299474
        
        local NewTab_1 = Instance.new("Frame")
        local UICorner_1 = Instance.new("UICorner")
        local UIStroke_1 = Instance.new("UIStroke")
        local UICorner_2 = Instance.new("UICorner")
        local InnerTab_1 = Instance.new("Frame")
        local Colors_1 = Instance.new("Frame")
        local UICorner_3 = Instance.new("UICorner")
        local Asset_1 = Instance.new("ImageLabel")
        local UIGradient_1 = Instance.new("UIGradient")
        local UIListLayout_1 = Instance.new("UIListLayout")
        local Text_1 = Instance.new("Frame")
        local UIListLayout_2 = Instance.new("UIListLayout")
        local Title_1 = Instance.new("TextLabel")
        local Sub_1 = Instance.new("TextLabel")
        local UIPadding_1 = Instance.new("UIPadding")
        
        NewTab_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NewTab_1.Name = "NewTab"
        NewTab_1.Parent = Scrolling_1
        NewTab_1.BackgroundTransparency = 1
        NewTab_1.Size = UDim2.new(0, 235, 0, 60)
		NewTab_1.Selectable = false
		NewTab_1.BackgroundTransparency = 1

        UICorner_1.CornerRadius = UDim.new(0, 5)
        UICorner_1.Parent = NewTab_1

        UIStroke_1.Color = Color3.fromRGB(255, 255, 255)
        UIStroke_1.Thickness = 1
        UIStroke_1.Transparency = 1
        UIStroke_1.Parent = NewTab_1
        
        Transcendants[UIStroke_1] = {
            ["Transparency"] = 0.95
        }
        
        UICorner_2.CornerRadius = UDim.new(0, 5)
        UICorner_2.Parent = Banner_1

        InnerTab_1.BackgroundTransparency = 1
        InnerTab_1.Name = "InnerTab"
        InnerTab_1.Parent = NewTab_1
        InnerTab_1.Size = UDim2.new(1, 0, 1, 0)
        InnerTab_1.Selectable = false

        Colors_1.BackgroundColor3 = Color3.fromRGB(82, 255, 212)
        Colors_1.Name = "Colors"
        Colors_1.Parent = InnerTab_1
        Colors_1.Size = UDim2.new(0, 70, 0, 60)
        Colors_1.Selectable = false
        Colors_1.BackgroundTransparency = 1

        UICorner_3.CornerRadius = UDim.new(0, 5)
        UICorner_3.Parent = Colors_1

        Asset_1.AnchorPoint = Vector2.new(0.5, 0.5)
        Asset_1.BackgroundTransparency = 1
        Asset_1.Name = "Asset"
        Asset_1.Parent = Colors_1
        Asset_1.Position = UDim2.new(0.5, 0, 0.5, 0)
        Asset_1.Size = UDim2.new(0, 35, 0, 35)
        Asset_1.Image = Library:Asset(Icon)
        Asset_1.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Asset_1.ImageTransparency = 1

        Transcendants[Asset_1] = {
            ["ImageTransparency"] = 0.15
        }

        UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 75, 75)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)), }
        UIGradient_1.Rotation = 45
        UIGradient_1.Parent = Colors_1

        UIListLayout_1.Padding = UDim.new(0, 0)
        UIListLayout_1.Parent = InnerTab_1
        UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout_1.SortOrder = Enum.SortOrder.Name

        Text_1.BackgroundTransparency = 1
        Text_1.Name = "Text"
        Text_1.Parent = InnerTab_1
        Text_1.Position = UDim2.new(0.07010302692651749, 0, 0, 0)
        Text_1.Size = UDim2.new(1, -90, 1, 0)
        Text_1.Selectable = false

        UIListLayout_2.Padding = UDim.new(0, 2)
        UIListLayout_2.Parent = Text_1
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

        Title_1.BackgroundTransparency = 1
        Title_1.Name = "Title"
        Title_1.Parent = Text_1
        Title_1.Size = UDim2.new(0, 42, 0, 20)
        Title_1.Selectable = false
        Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        Title_1.Text = Title
        Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title_1.TextSize = 18
        Title_1.TextTransparency = 1
        Title_1.TextXAlignment = Enum.TextXAlignment.Left

        Transcendants[Title_1] = {
            ["TextTransparency"] = 0
        }

        Sub_1.BackgroundTransparency = 1
        Sub_1.Name = "Sub"
        Sub_1.Parent = Text_1
        Sub_1.Size = UDim2.new(0, 72, 0, 9)
        Sub_1.Selectable = false
        Sub_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        Sub_1.Text = Desc
        Sub_1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Sub_1.TextSize = 10
        Sub_1.TextTransparency = 1
        Sub_1.TextXAlignment = Enum.TextXAlignment.Left
        Sub_1.TextYAlignment = Enum.TextYAlignment.Top

        Transcendants[Sub_1] = {
            ["TextTransparency"] = 0.5
        }

        UIPadding_1.Parent = Text_1
        UIPadding_1.PaddingBottom = UDim.new(0, 3)
        
        local NewPage_1 = Instance.new("Frame")
        local Header_1 = Instance.new("Frame")
        local Left_1 = Instance.new("Frame")
        local UIListLayout_1 = Instance.new("UIListLayout")
        local Text_1 = Instance.new("Frame")
        local UIListLayout_2 = Instance.new("UIListLayout")
        local Title_1 = Instance.new("TextLabel")
        local Sub_1 = Instance.new("TextLabel")
        local Asset_1 = Instance.new("ImageLabel")
        local UIPadding_1 = Instance.new("UIPadding")
        local Right_1 = Instance.new("Frame")
        local UIListLayout_3 = Instance.new("UIListLayout")
        local UIPadding_2 = Instance.new("UIPadding")
        local Back_1 = Instance.new("ImageLabel")
        local Next_1 = Instance.new("ImageLabel")
        local UIListLayout_4 = Instance.new("UIListLayout")
        local Horizon_1 = Instance.new("Frame")
        local Index_1 = Instance.new("Frame")
        
        local Scrolling_1 = Instance.new("ScrollingFrame")
        local UIPadding_3 = Instance.new("UIPadding")
        local UIListLayout_5 = Instance.new("UIListLayout")

        NewPage_1.BackgroundTransparency = 1
        NewPage_1.Name = "NewPage"
        NewPage_1.Parent = Pages_1
        NewPage_1.Size = UDim2.new(1, 0, 1, 0)
        NewPage_1.Selectable = false
        
        Header_1.BackgroundTransparency = 1
        Header_1.Name = "Header"
        Header_1.Parent = NewPage_1
        Header_1.Size = UDim2.new(1, 0, 0, 50)
        Header_1.Selectable = false
        
        Left_1.BackgroundTransparency = 1
        Left_1.Name = "Left"
        Left_1.Parent = Header_1
        Left_1.Size = UDim2.new(1, 0, 1, 0)
        Left_1.Selectable = false

        UIListLayout_1.Padding = UDim.new(0, 10)
        UIListLayout_1.Parent = Left_1
        UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout_1.SortOrder = Enum.SortOrder.Name
        UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

        Text_1.BackgroundTransparency = 1
        Text_1.Name = "Text"
        Text_1.Parent = Left_1
        Text_1.Position = UDim2.new(0.07010302692651749, 0, 0, 0)
        Text_1.Size = UDim2.new(-0.17319577932357788, 300, 1, 0)
        Text_1.Selectable = false

        UIListLayout_2.Parent = Text_1
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

        Title_1.BackgroundTransparency = 1
        Title_1.Name = "Title"
        Title_1.Parent = Text_1
        Title_1.Size = UDim2.new(0, 42, 0, 14)
        Title_1.Selectable = false
        Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        Title_1.Text = Title
        Title_1.TextColor3 = Color3.fromRGB(234, 234, 234)
        Title_1.TextSize = 14
        Title_1.TextXAlignment = Enum.TextXAlignment.Left

        Sub_1.BackgroundTransparency = 1
        Sub_1.Name = "Sub"
        Sub_1.Parent = Text_1
        Sub_1.Size = UDim2.new(0, 72, 0, 9)
        Sub_1.Selectable = false
        Sub_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        Sub_1.Text = Desc
        Sub_1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Sub_1.TextSize = 9
        Sub_1.TextTransparency = 0.5
        Sub_1.TextXAlignment = Enum.TextXAlignment.Left
        Sub_1.TextYAlignment = Enum.TextYAlignment.Top

        Asset_1.BackgroundColor3 = Color3.fromRGB(102, 246, 174)
        Asset_1.BackgroundTransparency = 1
        Asset_1.Name = "Asset"
        Asset_1.Parent = Left_1
        Asset_1.Size = UDim2.new(0, 25, 0, 25)
        Asset_1.Image = "rbxassetid://130391877219356"
        Asset_1.ImageTransparency = 0.5
        
        UIPadding_1.Parent = Left_1
        UIPadding_1.PaddingLeft = UDim.new(0, 15)

        Right_1.BackgroundTransparency = 1
        Right_1.Name = "Right"
        Right_1.Parent = Header_1
        Right_1.Size = UDim2.new(1, 0, 1, 0)
        Right_1.Selectable = false

        UIListLayout_3.Padding = UDim.new(0, 10)
        UIListLayout_3.Parent = Right_1
        UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout_3.SortOrder = Enum.SortOrder.Name
        UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Right
        UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

        UIPadding_2.Parent = Right_1
        UIPadding_2.PaddingRight = UDim.new(0, 15)

        Back_1.BackgroundTransparency = 1
        Back_1.Name = "Back"
        Back_1.Parent = Right_1
        Back_1.Size = UDim2.new(0, 25, 0, 25)
        Back_1.Image = "rbxassetid://104312702185319"
        Back_1.ImageColor3 = Color3.fromRGB(234, 234, 234)
        Back_1.ImageContent = Content.fromUri("rbxassetid://104312702185319")

        Next_1.BackgroundTransparency = 1
        Next_1.Name = "Next"
        Next_1.Parent = Right_1
        Next_1.Size = UDim2.new(0, 25, 0, 25)
        Next_1.Image = "rbxassetid://130050888244501"
        Next_1.ImageColor3 = Color3.fromRGB(234, 234, 234)
        Next_1.ImageContent = Content.fromUri("rbxassetid://130050888244501")

        UIListLayout_4.Parent = NewPage_1
        UIListLayout_4.SortOrder = Enum.SortOrder.Name
        UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center

        Horizon_1.BackgroundColor3 = Color3.fromRGB(165, 255, 160)
        Horizon_1.BackgroundTransparency = 0.949999988079071
        Horizon_1.LayoutOrder = -998
        Horizon_1.Name = "Horizon"
        Horizon_1.Parent = NewPage_1
        Horizon_1.Size = UDim2.new(1, 0, 0, 1)
        Horizon_1.Selectable = false

        Index_1.BackgroundTransparency = 1
        Index_1.LayoutOrder = -997
        Index_1.Name = "Index"
        Index_1.Parent = NewPage_1
        Index_1.Size = UDim2.new(1, 0, 0, 310)
        Index_1.Selectable = false

        Scrolling_1.AnchorPoint = Vector2.new(0.5, 0)
        Scrolling_1.BackgroundTransparency = 1
        Scrolling_1.Name = "Scrolling"
        Scrolling_1.Parent = Index_1
        Scrolling_1.Position = UDim2.new(0.5, 0, 0, 0)
        Scrolling_1.Size = UDim2.new(1, 0, 0, 300)
        Scrolling_1.ScrollBarImageTransparency = 1
        Scrolling_1.ScrollBarThickness = 0
        
        UIPadding_3.Parent = Scrolling_1
        UIPadding_3.PaddingBottom = UDim.new(0, 10)
        UIPadding_3.PaddingLeft = UDim.new(0, 10)
        UIPadding_3.PaddingRight = UDim.new(0, 10)
        UIPadding_3.PaddingTop = UDim.new(0, 10)

        UIListLayout_5.Parent = Scrolling_1
        UIListLayout_5.SortOrder = Enum.SortOrder.Name
		UIListLayout_5.Padding = UDim.new(0, 10)
        UIListLayout_5.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        UIListLayout_5:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Scrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_5.AbsoluteContentSize.Y + 15)
        end)
        
        local ClickSelect = Library:Button(NewTab_1)
        local ClickReturn = Library:Button(Asset_1)
        
        local ClickNext = Library:Button(Next_1)
        local ClickBack = Library:Button(Back_1)
        
        ClickReturn.MouseButton1Click:Connect(function()
            PageLayout:JumpTo(Home_1)
        end)
        
        ClickSelect.MouseButton1Click:Connect(function()
            PageLayout:JumpTo(NewPage_1)
        end)
        
        local function TweenTransparency(obj, transparency)
            Library:Tween({
                v = obj,
                t = 0.2,
                s = "Quad",
                d = "Out",
                g = {
                    ImageTransparency = transparency
                }
            }):Play()
        end

        local function GetPages()
            local pages = {}

            for _, page in ipairs(Pages_1:GetChildren()) do
                if page:IsA("Frame") and page.Name == "NewPage" then
                    table.insert(pages, page)
                end
            end

            return pages
        end

        local function UpdateNavButtons()
            local pages = GetPages()
            local index = table.find(pages, PageLayout.CurrentPage)

            if not index then
                return
            end

            TweenTransparency(Next_1, index >= #pages and 0.75 or 0)
            TweenTransparency(Back_1, index <= 1 and 0.75 or 0)
        end

        ClickNext.MouseButton1Click:Connect(function()
            if Next_1.ImageTransparency ~= 0 then return end
            PageLayout:Next()
        end)

        ClickBack.MouseButton1Click:Connect(function()
            if Back_1.ImageTransparency ~= 0 then return end
            PageLayout:Previous()
        end)

        PageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(UpdateNavButtons)

        UpdateNavButtons()
        
        local Tab = {}
        
        function Tab:AddSection(Title)
            local Section = {}
            local Rows = {}
            
            local Section_1 = Instance.new("Frame")
            local UIStroke_1 = Instance.new("UIStroke")
            local UICorner_1 = Instance.new("UICorner")
            local UIListLayout_1 = Instance.new("UIListLayout")
            local Header_1 = Instance.new("Frame")
            local UICorner_2 = Instance.new("UICorner")
            local Sqr_1 = Instance.new("Frame")
            local Title_1 = Instance.new("TextLabel")
            local Pattern_1 = Instance.new("ImageLabel")

            Section_1.AutomaticSize = Enum.AutomaticSize.Y
            Section_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Section_1.BackgroundTransparency = 0.99
            Section_1.Name = "Section"
            Section_1.Parent = Scrolling_1
            Section_1.Size = UDim2.new(1, 0, 0, 0)
            Section_1.Selectable = false

            UIStroke_1.Color = Color3.fromRGB(255, 255, 255)
            UIStroke_1.Transparency = 0.9700000286102295
            UIStroke_1.Parent = Section_1

            UICorner_1.CornerRadius = UDim.new(0, 5)
            UICorner_1.Parent = Section_1

            UIListLayout_1.Parent = Section_1
            UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center

            Header_1.BackgroundColor3 = Color3.fromRGB(82, 255, 212)
            Header_1.LayoutOrder = -999
            Header_1.Name = "Header"
            Header_1.Parent = Section_1
            Header_1.Size = UDim2.new(1, 0, 0, 30)
            Header_1.Selectable = false

            UICorner_2.CornerRadius = UDim.new(0, 5)
            UICorner_2.Parent = Header_1

            Sqr_1.AnchorPoint = Vector2.new(0, 1)
            Sqr_1.BackgroundColor3 = Color3.fromRGB(65, 203, 162)
            Sqr_1.Name = "Sqr"
            Sqr_1.Parent = Header_1
            Sqr_1.Position = UDim2.new(0, 0, 1, 0)
            Sqr_1.Size = UDim2.new(1, 0, 0, 4)
            Sqr_1.Selectable = false
            Sqr_1.BorderSizePixel = 0

            Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
            Title_1.BackgroundTransparency = 1
            Title_1.Name = "Title"
            Title_1.Parent = Header_1
            Title_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title_1.Size = UDim2.new(1, -30, 1, 0)
            Title_1.Selectable = false
            Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            Title_1.Text = Title
            Title_1.TextSize = 15
            Title_1.TextXAlignment = Enum.TextXAlignment.Left

            Pattern_1.AnchorPoint = Vector2.new(1, 0)
            Pattern_1.BackgroundTransparency = 1
            Pattern_1.Name = "Pattern"
            Pattern_1.Parent = Header_1
            Pattern_1.Position = UDim2.new(1, 0, 0, 0)
            Pattern_1.Size = UDim2.new(0.8500000238418579, 0, 1, 0)
            Pattern_1.Image = "rbxassetid://104439856523286"
            Pattern_1.ImageColor3 = Color3.fromRGB(0, 0, 0)
            Pattern_1.ImageContent = Content.fromUri("rbxassetid://104439856523286")
            Pattern_1.ImageTransparency = 0.30000001192092896
            Pattern_1.ScaleType = Enum.ScaleType.Crop
            
            function Section:AddParagraph(Info)
                local Title = Info.Title
                local Desc = Info.Description or Info.Content
                local Icon = Info.Icon
                local Text = Info.Text

                local Template = Library:Rows(Section_1, { Title = Title, Desc = Desc })
                table.insert(Rows, Template)
                Library:UpdateLine(Rows)
                
                

                if Icon then
                    Library:Create("ImageLabel", {
                        BackgroundTransparency = 1,
                        Name = "Asset",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 16, 0, 16),
                        Image = Library:Asset(Icon),
                        ImageTransparency = 0.5,
                        LayoutOrder = 999,
                    })
                end

                if Text then
                    local Text_1 = Library:Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Name = "Text",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 72, 0, 9),
                        Selectable = false,
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        RichText = true,
                        Text = "N/A",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 11,
                        TextTransparency = 0.5,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextYAlignment = Enum.TextYAlignment.Top,
                    })

                    function Template:Text(text)
                        Text_1.Text = text
                    end
                end

                if Text and Icon then
                    Template.Right.UIListLayout.Padding = UDim.new(0, 10)
                end
                
                function Template:SetDesc( ... )
                    if Desc then
                        Template.Desc.Text = tostring( ... ) 
                    end
                end
                
                function Template:SetTitle( ... )
                    Template.Title.Text = tostring( ... )
                end

                return Template
            end

            function Section:AddToggle(Flag, Info)
                local Title = Info.Title
                local Desc = Info.Description
                local Value = Info.Default
                local Callback = Info.Callback
                
                local Template = Library:Rows(Section_1, { Title = Title, Desc = Desc })
                table.insert(Rows, Template)
                Library:UpdateLine(Rows)

                do
                    local Toggle_1 = Library:Create("Frame", {
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                        Name = "Toggle",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 40, 0, 20),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Toggle_1,
                    })

                    Library:Create("UIStroke", {
                        Thickness = 0.5,
                        Transparency = 0.5,
                        Parent = Toggle_1,
                        BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                    })

                    Library:Create("UIStroke", {
                        Color = Color3.fromRGB(55, 55, 55),
                        Thickness = 0.5,
                        Transparency = 0.5,
                        Parent = Toggle_1,
                        BorderStrokePosition = Enum.BorderStrokePosition.Inner,
                    })

                    local Onder_1 = Library:Create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
                        BackgroundTransparency = 0.5,
                        Name = "Onder",
                        Parent = Toggle_1,
                        Position = UDim2.new(0, 5, 0.5, 0),
                        Size = UDim2.new(0, 10, 0, 10),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Onder_1,
                    })

                    local function OnChanged(value)
                        if value then
                            Onder_1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            Toggle_1.BackgroundColor3 = Color3.fromRGB(82, 255, 212)
                            Library:Tween({ v = Onder_1, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
                            Library:Tween({ v = Onder_1, t = 0.5, s = "Exponential", d = "Out", g = { Position = UDim2.new(0, 23, 0.5, 0) } }):Play()
                            Callback(Value)
                        else
                            Onder_1.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                            Toggle_1.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                            Library:Tween({ v = Onder_1, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 0.5 } }):Play()
                            Library:Tween({ v = Onder_1, t = 0.5, s = "Exponential", d = "Out", g = { Position = UDim2.new(0, 6, 0.5, 0) } }):Play()
                            Callback(Value)
                        end
                    end

                    local function Init()
                        if Library:IsDropdownOpen() then return end
                        Value = not Value
                        Window.Options[Flag].Value = Value
                        OnChanged(Value)
                    end

                    function Template:SetValue(value)
                        Value = value
                        Window.Options[Flag].Value = Value
                        OnChanged(Value)
                    end

                    local Click = Library:Button(Template.Template)
                    Click.MouseButton1Click:Connect(Init)
                    Window.Options[Flag].Value = Value
                    OnChanged(Value)
                end
                
                local Lock = Info.IsLocked or nil

                if Lock then
                    Library:LockOption(Template.Template, Lock)
                end

                return Template
            end

            function Section:AddButton(Info)
                local Title = Info.Title
                local Desc = Info.Description
                local Type = Info.Type or "Primary"
                local Callback = Info.Callback

                local Template = Library:Rows(Section_1, { Title = Title, Desc = Desc })

                do
                    local Button_1
                    if Type == "Primary" then
                        Button_1 = Library:Create("Frame", {
                            BackgroundColor3 = Color3.fromRGB(82, 255, 212),
                            Name = "Button",
                            Parent = Template.Right,
                            Size = UDim2.new(0, 60, 0, 20),
                            Selectable = false,
                        })

                        Library:Create("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                            Parent = Button_1,
                        })

                        Library:Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Name = "Title",
                            Parent = Button_1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Selectable = false,
                            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            Text = "Click",
                            TextSize = 10,
                        })

                        Library:Create("UIStroke", {
                            Thickness = 0.5,
                            Transparency = 0.5,
                            Parent = Button_1,
                            BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                        })
                    else
                        Button_1 = Library:Create("Frame", {
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Name = "Button",
                            Parent = Template.Right,
                            Size = UDim2.new(0, 60, 0, 20),
                            Selectable = false,
                        })

                        Library:Create("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                            Parent = Button_1,
                        })

                        Library:Create("UIStroke", {
                            Thickness = 0.5,
                            Transparency = 0.5,
                            Parent = Button_1,
                            BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                        })

                        Library:Create("UIStroke", {
                            Color = Color3.fromRGB(55, 55, 55),
                            Thickness = 0.5,
                            Transparency = 0.5,
                            Parent = Button_1,
                            BorderStrokePosition = Enum.BorderStrokePosition.Inner,
                        })

                        Library:Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Name = "Title",
                            Parent = Button_1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Selectable = false,
                            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            Text = "Click",
                            TextColor3 = Color3.fromRGB(234, 234, 234),
                            TextSize = 10,
                            TextStrokeTransparency = 0.6499999761581421,
                        })
                    end

                    local Click = Library:Button(Button_1)
                    Click.MouseButton1Click:Connect(function()
                        if Library:IsDropdownOpen() then return end
                        if Callback then Callback() end
                        Button_1.Title.TextSize = 12
                        task.delay(0.12, function()
                            Button_1.Title.TextSize = 10
                        end)
                    end)
                end

                table.insert(Rows, Template)
                Library:UpdateLine(Rows)
                
                local Lock = Info.IsLocked or nil

                if Lock then
                    Library:LockOption(Template.Template, Lock)
                end

                return Template
            end

            function Section:AddInput(Flag, Info)
                local Title = Info.Title
                local Desc = Info.Description
                local Text = Info.Default
                local Callback = Info.Callback


                local Template = Library:Rows(Section_1, { Title = Title, Desc = Desc })
                Template.Desc.Size = UDim2.new(1, -80, 0, 0)

                do
                    local Textbox_1 = Library:Create("Frame", {
                        BackgroundTransparency = 0.9800000190734863,
                        Name = "Textbox",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 100, 0, 20),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Textbox_1,
                    })

                    Library:Create("UIStroke", {
                        Color = Color3.fromRGB(55, 55, 55),
                        Thickness = 0.5,
                        Parent = Textbox_1,
                        BorderStrokePosition = Enum.BorderStrokePosition.Inner,
                    })

                    Library:Create("UIStroke", {
                        Thickness = 0.5,
                        Parent = Textbox_1,
                        BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                    })

                    local TextBox_1 = Library:Create("TextBox", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Parent = Textbox_1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                        PlaceholderText = "...",
                        Text = tostring(Text),
                        TextColor3 = Color3.fromRGB(150, 150, 150),
                        TextSize = 10,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    })

                    TextBox_1.FocusLost:Connect(function()
                        Text = TextBox_1.Text
                        Window.Options[Flag].Value = Text
                        if Callback then Callback(Text) end
                    end)
                    
                    Window.Options[Flag].Value = Text
                end

                table.insert(Rows, Template)
                Library:UpdateLine(Rows)
                
                local Lock = Info.IsLocked or false

                if Lock then
                    Library:LockOption(Template.Template)
                end

                return Template
            end

            function Section:AddSlider(Flag, Info)
                local Title = Info.Title
                local Desc = Info.Description
                local Min = Info.Min or 1
                local Max = Info.Max or 100
                local Rounding = Info.Rounding or 0
                local Value = Info.Default or Min
                local Callback = Info.Callback

                local Template = Library:Rows(Section_1, { Title = Title, Desc = Desc })
                Template.Right.UIListLayout.Padding = UDim.new(0, 6)
                Template.Desc.Size = UDim2.new(1, -150, 0, 0)

                do
                    local ScaleSlider_1 = Library:Create("Frame", {
                        BackgroundTransparency = 1,
                        LayoutOrder = 100,
                        Name = "ScaleSlider",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 160, 0, 40),  -- เปลี่ยน 1, 0 → 0, 40
                        Selectable = false,
                    })

                    local Slider_1 = Library:Create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                        LayoutOrder = 999,
                        Name = "Slider",
                        Parent = ScaleSlider_1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 150, 0, 3),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Slider_1,
                    })

                    local Value_1 = Library:Create("Frame", {
                        BackgroundColor3 = Color3.fromRGB(82, 255, 212),
                        Name = "Value",
                        Parent = Slider_1,
                        Size = UDim2.new(0.4609929025173187, 0, 1, 0),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Value_1,
                    })

                    local Circle_1 = Library:Create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                        Name = "Circle",
                        Parent = Value_1,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 15, 0, 15),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Circle_1,
                    })

                    local White_1 = Library:Create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(234, 234, 234),
                        Name = "White",
                        Parent = Circle_1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0.800000011920929, 0, 0.800000011920929, 0),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = White_1,
                    })

                    Library:Create("UIStroke", {
                        Color = Color3.fromRGB(22, 22, 22),
                        Thickness = 1.5,
                        Parent = Circle_1,
                    })

                    local TextValue_1 = Library:Create("TextBox", {
                        BackgroundTransparency = 1,
                        LayoutOrder = -1,
                        Name = "TextValue",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 30, 0, 20),
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                        PlaceholderColor3 = Color3.fromRGB(128, 128, 128),
                        Text = tostring(Value),
                        TextColor3 = Color3.fromRGB(100, 100, 100),
                        TextSize = 10,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    })

                    local Slide = Library:Button(ScaleSlider_1)
                    local dragging = false

                    local function Round(n, decimals)
                        local factor = 10 ^ decimals
                        return math.floor(n * factor + 0.5) / factor
                    end

                    local function UpdateSlider(val)
                        val = math.clamp(val, Min, Max)
                        val = Round(val, Rounding)
                        local ratio = (val - Min) / (Max - Min)
                        Library:Tween({ v = Value_1, t = 0.1, s = "Linear", d = "Out", g = { Size = UDim2.new(ratio, 0, 1, 0) } }):Play()
                        TextValue_1.Text = tostring(val)
                        Callback(val)
                        return val
                    end

                    local function GetValueFromInput(input)
                        local absX = Slider_1.AbsolutePosition.X
                        local absW = Slider_1.AbsoluteSize.X
                        local ratio = math.clamp((input.Position.X - absX) / absW, 0, 1)
                        return ratio * (Max - Min) + Min
                    end

                    Slide.InputBegan:Connect(function(input)
                        if Library:IsDropdownOpen() then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            UpdateSlider(GetValueFromInput(input))
                        end
                    end)

                    Slide.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if Library:IsDropdownOpen() then return end
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateSlider(GetValueFromInput(input))
                        end
                    end)

                    TextValue_1.FocusLost:Connect(function()
                        local val = tonumber(TextValue_1.Text) or Value
                        Value = UpdateSlider(val)
                        Window.Options[Flag].Value = Value
                    end)

                    UpdateSlider(Value)
                    Window.Options[Flag].Value = Value
                end

                table.insert(Rows, Template)
                Library:UpdateLine(Rows)
                
                local Lock = Info.IsLocked or nil

                if Lock then
                    Library:LockOption(Template.Template, Lock)
                end

                return Template
            end

            function Section:AddDropdown(Flag, Info)
                local Title = Info.Title
                local List = Info.Values or {}
                local Value = Info.Default or "N/A"
                local IsMulti = typeof(Value) == 'table' and true or false
                local Callback = Info.Callback

                local Template = Library:Rows(Section_1, { Title = Title, Desc = "N/A" })
                local Description = Template.Desc
                local ClickOpen = Library:Button(Template.Template)

                do
                    Library:Create("ImageLabel", {
                        BackgroundTransparency = 1,
                        Name = "Asset",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 16, 0, 16),
                        Image = Library:Asset(132291592681506),
                        ImageTransparency = 0.5,
                        LayoutOrder = 999,
                    })
                end

                do
                    local Dropdown_1 = Library:Create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                        Name = "Dropdown",
                        Parent = Background_1,
                        Position = UDim2.new(0.5, 0, 0.3, 0),
                        Size = UDim2.new(0, 250, 0, 250),
                        Visible = false,
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(0, 5),
                        Parent = Dropdown_1,
                    })

                    Library:Create("UIListLayout", {
                        Parent = Dropdown_1,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    })

                    Library:Create("UIStroke", {
                        Color = Color3.fromRGB(255, 255, 255),
                        Transparency = 0.95,
                        Parent = Dropdown_1,
                        BorderStrokePosition = Enum.BorderStrokePosition.Inner,
                    })

                    local Header_1 = Library:Create("Frame", {
                        BackgroundColor3 = Color3.fromRGB(27, 27, 27),
                        LayoutOrder = -999,
                        Name = "Header",
                        Parent = Dropdown_1,
                        Size = UDim2.new(1, 0, 0, 30),
                        Selectable = false,
                    })

                    local Text_1 = Library:Create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Name = "Text",
                        Parent = Header_1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Selectable = false,
                    })

                    Library:Create("UIListLayout", {
                        Parent = Text_1,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    })

                    Library:Create("TextLabel", {
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundTransparency = 1,
                        Name = "Title",
                        Parent = Text_1,
                        Size = UDim2.new(1, -20, 1, -4),
                        Selectable = false,
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = Title,
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(0, 5),
                        Parent = Header_1,
                    })

                    Library:Create("Frame", {
                        AnchorPoint = Vector2.new(0, 1),
                        BackgroundColor3 = Color3.fromRGB(27, 27, 27),
                        Name = "Squire",
                        Parent = Header_1,
                        Position = UDim2.new(0, 0, 1, 0),
                        Size = UDim2.new(1, 0, 0, 4),
                        Selectable = false,
                        BorderSizePixel = 0,
                    })

                    local Front_1 = Library:Create("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                        Name = "Front",
                        Parent = Header_1,
                        Position = UDim2.new(1, -5, 0.5, 0),
                        Size = UDim2.new(0, 110, 1, -10),
                        Selectable = false,
                    })

                    Library:Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = Front_1,
                    })

                    local Search_1 = Library:Create("TextBox", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Name = "Search",
                        Parent = Front_1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        PlaceholderColor3 = Color3.fromRGB(55, 55, 55),
                        PlaceholderText = "Search",
                        Text = "",
                        TextColor3 = Color3.fromRGB(100, 100, 100),
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    })

                    Library:Create("UIStroke", {
                        Thickness = 0.44999998807907104,
                        Transparency = 0.5,
                        Parent = Dropdown_1,
                        BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                    })

                    local Scrolling_1 = Library:Create("ScrollingFrame", {
                        BackgroundTransparency = 1,
                        Name = "Scrolling",
                        Parent = Dropdown_1,
                        Size = UDim2.new(1, 0, 1, -35),
                        ScrollBarImageTransparency = 1,
                        ScrollBarThickness = 0,
                    })

                    local UIListLayout_3 = Library:Create("UIListLayout", {
                        Padding = UDim.new(0, 3),
                        Parent = Scrolling_1,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    })

                    UIListLayout_3:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                        Scrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_3.AbsoluteContentSize.Y + 15)
                    end)

                    Library:Create("UIPadding", {
                        Parent = Scrolling_1,
                        PaddingBottom = UDim.new(0, 4),
                        PaddingLeft = UDim.new(0, 5),
                        PaddingRight = UDim.new(0, 5),
                        PaddingTop = UDim.new(0, 4),
                    })

                    local function GetText()
                        if IsMulti then
                            return table.concat(Value, ", ")
                        end
                        return tostring(Value)
                    end

                    Description.Text = GetText()

                    local selectedValues = {}
                    local selectedOrder = 0

                    local function isValueInTable(val, tbl)
                        if type(tbl) ~= "table" then return false end
                        for _, v in pairs(tbl) do
                            if v == val then return true end
                        end
                        return false
                    end

                    local function Settext()
                        Description.Text = GetText()
                    end

                    local isOpen = false

                    UserInputService.InputBegan:Connect(function(A)
                        if not isOpen then return end
                        local mouse = LocalPlayer:GetMouse()
                        local mx, my = mouse.X, mouse.Y
                        local DBP, DBS = Dropdown_1.AbsolutePosition, Dropdown_1.AbsoluteSize
                        if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
                            if not (mx >= DBP.X and mx <= DBP.X + DBS.X and my >= DBP.Y and my <= DBP.Y + DBS.Y) then
                                isOpen = false
                                Dropdown_1.Visible = false
                                Dropdown_1.Position = UDim2.new(0.5, 0, 0.3, 0)
                            end
                        end
                    end)

                    ClickOpen.MouseButton1Click:Connect(function()
                        if Library:IsDropdownOpen() then return end
                        isOpen = not isOpen
                        if isOpen then
                            Dropdown_1.Visible = true
                            Library:Tween({ v = Dropdown_1, t = 0.3, s = "Back", d = "Out", g = { Position = UDim2.new(0.5, 0, 0.5, 0) } }):Play()
                        else
                            Dropdown_1.Visible = false
                            Dropdown_1.Position = UDim2.new(0.5, 0, 0.3, 0)
                        end
                    end)

                    function Template:Clear(a)
                        for _, v in ipairs(Scrolling_1:GetChildren()) do
                            if v:IsA("Frame") then
                                local shouldClear = a == nil or (type(a) == "string" and v.Title.Text == a) or (type(a) == "table" and isValueInTable(v.Title.Text, a))
                                if shouldClear then v:Destroy() end
                            end
                        end
                        if a == nil then
                            Value = nil
                            Window.Options[Flag].Value = nil
                            selectedValues = {}
                            selectedOrder = 0
                            Description.Text = "None"
                        end
                    end

                    function Template:AddList(Name)
                        local NewList_1 = Library:Create("Frame", {
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 1,
                            Name = "NewList",
                            Parent = Scrolling_1,
                            Size = UDim2.new(1, 0, 0, 25),
                            ZIndex = 500,
                            Selectable = false,
                        })

                        Library:Create("UICorner", {
                            CornerRadius = UDim.new(0, 3),
                            Parent = NewList_1,
                        })

                        local Title_1 = Library:Create("TextLabel", {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundTransparency = 1,
                            LayoutOrder = -1,
                            Name = "Title",
                            Parent = NewList_1,
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(1, -15, 1, 0),
                            ZIndex = 500,
                            Selectable = false,
                            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            RichText = true,
                            Text = tostring(Name),
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            TextSize = 11,
                            TextTransparency = 0.5,
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        })

                        local function OnValue(value)
                            if value then
                                Library:Tween({ v = NewList_1, t = 0.2, s = "Linear", d = "Out", g = { BackgroundTransparency = 0.85 } }):Play()
                                Library:Tween({ v = Title_1, t = 0.2, s = "Linear", d = "Out", g = { TextTransparency = 0 } }):Play()
                            else
                                Library:Tween({ v = NewList_1, t = 0.2, s = "Linear", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                                Library:Tween({ v = Title_1, t = 0.2, s = "Linear", d = "Out", g = { TextTransparency = 0.5 } }):Play()
                            end
                        end

                        local Click = Library:Button(NewList_1)

                        local function OnSelected()
                            if IsMulti then
                                if selectedValues[Name] then
                                    selectedValues[Name] = nil
                                    NewList_1.LayoutOrder = 0
                                    OnValue(false)
                                else
                                    selectedOrder = selectedOrder - 1
                                    selectedValues[Name] = selectedOrder
                                    NewList_1.LayoutOrder = selectedOrder
                                    OnValue(true)
                                end
                                local selectedList = {}
                                for i in pairs(selectedValues) do table.insert(selectedList, i) end
                                if #selectedList > 0 then
                                    table.sort(selectedList)
                                    Value = selectedList
                                    Window.Options[Flag].Value = selectedList
                                    Settext()
                                else
                                    Description.Text = "None"
                                end
                                pcall(Callback, selectedList)
                            else
                                for _, v in pairs(Scrolling_1:GetChildren()) do
                                    if v:IsA("Frame") and v.Name == 'NewList' then
                                        Library:Tween({ v = v, t = 0.2, s = "Linear", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                                        Library:Tween({ v = v.Title, t = 0.2, s = "Linear", d = "Out", g = { TextTransparency = 0.5 } }):Play()
                                    end
                                end
                                OnValue(true)
                                Window.Options[Flag].Value = Name
                                Value = Name
                                Settext()
                                pcall(Callback, Value)
                            end
                        end

                        delay(0, function()
                            if IsMulti then
                                if isValueInTable(Name, Value) then
                                    selectedOrder = selectedOrder - 1
                                    selectedValues[Name] = selectedOrder
                                    NewList_1.LayoutOrder = selectedOrder
                                    OnValue(true)
                                    local selectedList = {}
                                    for i in pairs(selectedValues) do table.insert(selectedList, i) end
                                    if #selectedList > 0 then
                                        table.sort(selectedList)
                                        Settext()
                                    else
                                        Description.Text = "None"
                                    end
                                    pcall(Callback, selectedList)
                                end
                            else
                                if Name == Value then
                                    OnValue(true)
                                    Settext()
                                    pcall(Callback, Value)
                                end
                            end
                        end)
                        
                        Window.Options[Flag].Value = Name

                        Click.MouseButton1Click:Connect(OnSelected)
                    end

                    Search_1.Changed:Connect(function()
                        local SearchT = string.lower(Search_1.Text)
                        for _, v in pairs(Scrolling_1:GetChildren()) do
                            if v:IsA("Frame") and v.Name == 'NewList' then
                                v.Visible = string.find(string.lower(v.Title.Text), SearchT, 1, true) ~= nil
                            end
                        end
                    end)

                    for _, name in ipairs(List) do
                        Template:AddList(name)
                    end
                end

                table.insert(Rows, Template)
                Library:UpdateLine(Rows)
                
                local Lock = Info.IsLocked or nil

                if Lock then
                    Library:LockOption(Template.Template, Lock)
                end

                return Template
            end

            return Section
        end
        
        return Tab
    end
    
    do
        local ToggleScreen = Library:Create("ScreenGui", {
            Name = "Switch Pillow",
            Parent = HIDDEN_PARENT,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            IgnoreGuiInset = true,
            Enabled = false
        })

        local Pillow_1 = Library:Create("TextButton", {
            Name = "Pillow",
            Parent = ToggleScreen,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderSizePixel = 0,
            Position = UDim2.new(0.06, 0, 0.15, 0),
            Size = UDim2.new(0, 50, 0, 50),
            BackgroundTransparency = Args.Transparent and 0.03 or 0,
            Text = "",
        })

        Library:Create("UICorner", {
            Parent = Pillow_1,
            CornerRadius = UDim.new(1, 0),
        })

        Library:Create("ImageLabel", {
            Name = "Logo",
            Parent = Pillow_1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.8, 0, 0.8, 0),
            Image = Library:Asset(Logo),
        })

        Library:Draggable(Pillow_1)

        Pillow_1.MouseButton1Click:Connect(function()
            Background_1.Visible = not Background_1.Visible
        end)

        local holdingSpace = false

        UserInputService.InputBegan:Connect(function(Input, Processed)
            if Processed then return end
            if Input.KeyCode == Enum.KeyCode.Space then
                holdingSpace = true
            end
            if holdingSpace and Input.KeyCode == Enum.KeyCode.LeftShift then
                Background_1.Visible = not Background_1.Visible
            end
        end)

        UserInputService.InputEnded:Connect(function(Input)
            if Input.KeyCode == Enum.KeyCode.Space then
                holdingSpace = false
            end
        end)
        
        local StartBackground: Tween = Library:Tween({
            v = Background_1,
            t = 0.75,
            s = "Exponential",
            d = "Out",
            g = {
                Size = UDim2.new(0, 500, 0, 360)
            }
        })
        
        StartBackground.Completed:Once(function()
            delay(0.1, function()
                Library:Tween({
                    v = Horizon_1,
                    t = 0.5,
                    s = "Linear",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.95
                    }
                }):Play()

                Tabs_1.Visible = true
                TranscendantsInit()
            end)
        end)
        
        do
            local TweenService = game:GetService("TweenService")
            local RunService   = game:GetService("RunService")

            local CFG = {
                FALL_TIME     = 0.75,
                SPIN_TIME     = 2.2,
                RISE_TIME     = 1.4,
                BOUNCE_HEIGHT = 0.045,
                SPIN_DEGREES  = 1440,
                LAND_Y        = 0.5,
                STAGGER       = 0.04,
                GAP           = 24,
                DOT_PX        = 25,
            }

            local _builders = {}

            local function NewFrame(builderFn)
                assert(type(builderFn) == "function",
                    "NewFrame: ต้องส่ง function ที่ return GuiObject")
                _builders[#_builders + 1] = builderFn
            end

            local function createDot(parent, builderFn)
                local f = builderFn()
                assert(f and f:IsA("GuiObject"), "NewFrame: function ต้อง return GuiObject")
                f.AnchorPoint            = Vector2.new(0.5, 0.5)
                f.BackgroundTransparency = 0
                f.ZIndex                 = 10
                f.Parent                 = parent
                return f
            end

            local function spinFrame(frame, duration, totalDeg, onDone)
                local startTime = tick()
                local startRot  = frame.Rotation
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    local t = math.clamp((tick() - startTime) / duration, 0, 1)
                    local e = t < 0.5
                        and 4 * t^3
                        or  1 - (-2*t+2)^3 / 2
                    frame.Rotation = startRot + e * totalDeg
                    if t >= 1 then
                        conn:Disconnect()
                        if onDone then onDone() end
                    end
                end)
            end

            local function animateDot(parent, builderFn, posX, onDone)
                local dot     = createDot(parent, builderFn)
                local landY   = CFG.LAND_Y
                local bounceY = landY - CFG.BOUNCE_HEIGHT

                dot.Position = UDim2.new(posX, 0, -0.05, 0)

                local tFall = TweenService:Create(dot,
                    TweenInfo.new(CFG.FALL_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                    { Position = UDim2.new(posX, 0, landY, 0) })

                local tBounce = TweenService:Create(dot,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    { Position = UDim2.new(posX, 0, bounceY, 0) })

                local tSettle = TweenService:Create(dot,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                    { Position = UDim2.new(posX, 0, landY - CFG.BOUNCE_HEIGHT * 0.35, 0) })

                local tRise = TweenService:Create(dot,
                    TweenInfo.new(CFG.RISE_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    { Position              = UDim2.new(posX, 0, -0.1, 0),
                        BackgroundTransparency = 1 })

                tFall:Play()
                tFall.Completed:Connect(function()
                    tBounce:Play()
                    tBounce.Completed:Connect(function()
                        tSettle:Play()
                        tSettle.Completed:Connect(function()
                            spinFrame(dot, CFG.SPIN_TIME, CFG.SPIN_DEGREES, function()
                                tRise:Play()
                                tRise.Completed:Connect(function()
                                    dot:Destroy()
                                    if onDone then onDone() end
                                end)
                            end)
                        end)
                    end)
                end)
            end

            local function BoundStart(parent, onAllDone)
                local amount = #_builders
                assert(amount > 0, "BoundStart: ต้องเรียก NewFrame อย่างน้อย 1 ครั้งก่อน")

                local snapshot = {table.unpack(_builders)}
                _builders = {}

                local dotPx   = CFG.DOT_PX
                local gapPx   = CFG.GAP
                local totalPx = amount * dotPx + (amount - 1) * gapPx
                local screenW = parent.AbsoluteSize.X
                local startPx = (screenW - totalPx) / 2 + dotPx / 2

                local finished = 0
                local function onOneDone()
                    finished += 1
                    if finished >= amount and onAllDone then
                        onAllDone()
                    end
                end

                for i = 1, amount do
                    local xPx   = startPx + (i - 1) * (dotPx + gapPx)
                    local xScale = xPx / screenW
                    local delay  = (i - 1) * CFG.STAGGER

                    task.delay(delay, function()
                        animateDot(parent, snapshot[i], xScale, onOneDone)
                    end)
                    
                    task.wait(0.10)
                end
            end

            local function CreateDot(Color)
                return NewFrame(function()
                    local Frame = Instance.new("Frame")
                    local UICorner = Instance.new("UICorner")
                    local UIStroke = Instance.new("UIStroke")

                    Frame.BackgroundColor3 = Color
                    Frame.Size = UDim2.fromOffset(20, 20)
                    Frame.Selectable = false

                    UICorner.CornerRadius = UDim.new(0, 7)
                    UICorner.Parent = Frame

                    UIStroke.Thickness = 0.8
                    UIStroke.Transparency = 0.5
                    UIStroke.Parent = Frame

                    return Frame
                end)
            end
            
            Background_1.Position = UDim2.new(-0.5, 0 ,0.5 ,0)
            
            task.delay(RunService:IsStudio() and 3 or 0.1, function()
                CreateDot(Color3.fromRGB(40, 200, 64))   -- Green
                CreateDot(Color3.fromRGB(254, 188, 46))  -- Yellow
				CreateDot(Color3.fromRGB(255, 95, 87))   -- Red
				
				repeat
					task.wait(0.1)
				until Fetch()

                BoundStart(Switch_1, function()
                    Background_1.Visible = true
                    ToggleScreen.Enabled = true
                    
                    local TweenS = Library:Tween({
                        v = Background_1,
                        t = 0.5,
                        s = "Back",
                        d = "Out",
                        g = {
                            Position = UDim2.new(0.5, 0 ,0.5 ,0)
                        }
                    })
                    
                    TweenS.Completed:Connect(function()
                        task.delay(1, function()
                            StartBackground:Play()
                        end)
                    end)
                    
                    TweenS:Play()
                end)
            end)
        end
    end
    
    return Window
end

return Library
