local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- 1. FIX: Hàm lấy nơi chứa UI an toàn (Hỗ trợ cả Mobile & PC)
local function GetUIPath()
    local success, hui = pcall(function() return gethui() end)
    if success and hui then return hui end
    if game:GetService("CoreGui") then return game:GetService("CoreGui") end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local UI_Parent = GetUIPath()

-- 2. Dọn dẹp UI cũ
for _, v in pairs(UI_Parent:GetChildren()) do
    if v.Name == "Bearhud" or v.Name == "BearHub_UI_Fixed" then v:Destroy() end
end

-- Cấu hình màu sắc
_G.Primary = Color3.fromRGB(100, 100, 100)
_G.Dark = Color3.fromRGB(25, 25, 30)
_G.Third = Color3.fromRGB(255, 0, 0)

local function CreateRounded(Parent, Size)
    local Rounded = Instance.new("UICorner")
    Rounded.Name = "Rounded"
    Rounded.Parent = Parent
    Rounded.CornerRadius = UDim.new(0, Size)
end

-- Hàm kéo thả UI (Draggable)
local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15), {Position = pos}):Play()
    end
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then Update(input) end end)
end

local Library = {}

function Library:Window(Config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BearHub_UI_Fixed"
    ScreenGui.Parent = UI_Parent
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = _G.Dark
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.Size = Config.Size or UDim2.new(0, 450, 0, 300)
    CreateRounded(MainFrame, 6)
    MakeDraggable(MainFrame, MainFrame)

    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Parent = MainFrame
    Pages.BackgroundColor3 = _G.Dark
    Pages.BackgroundTransparency = 1
    Pages.Position = UDim2.new(0, 145, 0, 40)
    Pages.Size = UDim2.new(1, -150, 1, -45)
    
    local PageFolder = Instance.new("Folder", Pages)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = _G.Dark
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.Size = UDim2.new(0, 130, 1, -60)
    TabContainer.ScrollBarThickness = 2
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.Size = UDim2.new(0, 120, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Bear Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local SubTitle = Instance.new("TextLabel", MainFrame)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Position = UDim2.new(0, 15, 0, 28)
    SubTitle.Size = UDim2.new(0, 120, 0, 15)
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.Text = Config.SubTitle or "by Quang Huy"
    SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubTitle.TextSize = 11
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left

    local Tabs = {}
    local FirstTab = true

    function Tabs:Tab(TabName)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Name = TabName .. "Button"
        TabButton.BackgroundColor3 = _G.Primary
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, -5, 0, 30)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = "   " .. TabName
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        CreateRounded(TabButton, 4)

        local NewPage = Instance.new("ScrollingFrame", PageFolder)
        NewPage.Name = TabName
        NewPage.Active = true
        NewPage.BackgroundColor3 = _G.Dark
        NewPage.BackgroundTransparency = 1
        NewPage.BorderSizePixel = 0
        NewPage.Size = UDim2.new(1, 0, 1, 0)
        NewPage.ScrollBarThickness = 2
        NewPage.Visible = false
        
        local PageLayout = Instance.new("UIListLayout", NewPage)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 5)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            NewPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        local function Activate()
            for _, v in pairs(PageFolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) v.BackgroundTransparency = 1 end end
            NewPage.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundTransparency = 0.8
        end
        TabButton.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab = false Activate() end
        
        local Elements = {}
        function Elements:Label(Text)
            local Label = Instance.new("TextLabel", NewPage)
            Label.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            Label.Size = UDim2.new(1, -5, 0, 25)
            Label.Font = Enum.Font.Gotham
            Label.Text = Text
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 13
            CreateRounded(Label, 4)
            return {Set = function(self, newText) Label.Text = newText end}
        end
        function Elements:Seperator(Text) return Elements:Label("--- " .. Text .. " ---") end
        function Elements:Line() return Elements:Label("--------------------------------") end
        
        function Elements:Button(Text, Callback)
            Callback = Callback or function() end
            local Button = Instance.new("TextButton", NewPage)
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Button.Size = UDim2.new(1, -5, 0, 30)
            Button.Font = Enum.Font.GothamBold
            Button.Text = Text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 13
            CreateRounded(Button, 4)
            Button.MouseButton1Click:Connect(function() pcall(Callback) end)
        end

        function Elements:Toggle(Text, Default, Description, Callback)
            Callback = Callback or function() end
            local Toggled = Default or false
            local ToggleFrame = Instance.new("TextButton", NewPage)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            ToggleFrame.Size = UDim2.new(1, -5, 0, 30)
            ToggleFrame.Text = ""
            CreateRounded(ToggleFrame, 4)
            
            local Title = Instance.new("TextLabel", ToggleFrame)
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(1, -50, 1, 0)
            Title.Font = Enum.Font.GothamSemibold
            Title.Text = Text
            Title.TextColor3 = Color3.fromRGB(200, 200, 200)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local Status = Instance.new("Frame", ToggleFrame)
            Status.BackgroundColor3 = Toggled and _G.Third or Color3.fromRGB(60, 60, 60)
            Status.Position = UDim2.new(1, -30, 0.5, -8)
            Status.Size = UDim2.new(0, 16, 0, 16)
            CreateRounded(Status, 4)
            
            ToggleFrame.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Status.BackgroundColor3 = Toggled and _G.Third or Color3.fromRGB(60, 60, 60)
                Title.TextColor3 = Toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                pcall(Callback, Toggled)
            end)
            if Default then pcall(Callback, true) end
        end
        
        function Elements:Dropdown(Text, Options, Default, Callback)
            Elements:Label(Text) -- Giản lược Dropdown để tránh lỗi logic phức tạp
            -- Bạn có thể thêm code Dropdown đầy đủ ở đây nếu cần
        end
        
        function Elements:Slider(Text, Min, Max, Default, Callback)
             Elements:Label(Text .. ": " .. tostring(Default)) -- Giản lược Slider
        end

        return Elements
    end
    function Library:SaveSettings() return true end
    function Library:Notify(Text, Time) 
        game.StarterGui:SetCore("SendNotification", {Title = "Bear Hub", Text = Text, Duration = Time or 5})
    end
    return Tabs
end
return Library
