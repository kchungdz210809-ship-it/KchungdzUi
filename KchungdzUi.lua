local cloneref = cloneref or function(o) return o end

local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    local ok, gui = pcall(function() return CoreGui end)
    if ok and gui then return gui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Bộ bảng màu hồng neon phối nền đen tím tối
local Colors = {
    Background       = Color3.fromRGB(18, 12, 16),
    SidebarBg        = Color3.fromRGB(14, 9, 12),
    BorderPink       = Color3.fromRGB(244, 114, 182),
    BorderSubtle     = Color3.fromRGB(56, 28, 44),
    Divider          = Color3.fromRGB(48, 22, 38),

    PinkPrimary      = Color3.fromRGB(244, 114, 182),
    PinkAccent       = Color3.fromRGB(236, 72, 153),
    PinkMuted        = Color3.fromRGB(190, 90, 135),
    PinkDark         = Color3.fromRGB(98, 25, 60),
    PinkGlow         = Color3.fromRGB(251, 168, 212),

    RowNormal        = Color3.fromRGB(26, 16, 22),
    RowHover         = Color3.fromRGB(38, 22, 32),
    ControlBg        = Color3.fromRGB(36, 18, 28),
    InputBg          = Color3.fromRGB(22, 12, 18),

    TextWhite        = Color3.fromRGB(253, 242, 248),
    TextSubtle       = Color3.fromRGB(200, 150, 175),
    TextMuted        = Color3.fromRGB(145, 95, 120),

    AccentGreen      = Color3.fromRGB(52, 211, 153),
    AccentRed        = Color3.fromRGB(248, 113, 113),
    AccentOrange     = Color3.fromRGB(251, 146, 60),
    AccentYellow     = Color3.fromRGB(250, 204, 21),
    AccentBlue       = Color3.fromRGB(96, 165, 250),
    DropdownSelected = Color3.fromRGB(50, 22, 38)
}

local Kchungdz = {}
Kchungdz.__index = Kchungdz

function Kchungdz.new(titleText, subtitleText)
    local self = setmetatable({}, Kchungdz)

    if getgenv and getgenv()._KchungdzUnload then
        pcall(getgenv()._KchungdzUnload)
    end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Kchungdz"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = getGuiParent()

    if getgenv then
        getgenv()._KchungdzUnload = function()
            pcall(function() self.ScreenGui:Destroy() end)
        end
    end

    self.RowSearchIndex = {}
    self.TabFrames = {}
    self.TabButtons = {}
    self.ActiveConnections = {}
    self.IsMinimized = false
    self.UiVisible = true

    -- Notification container
    self.NotifContainer = Instance.new("Frame")
    self.NotifContainer.Name = "Notifications"
    self.NotifContainer.Size = UDim2.new(0, 300, 1, -40)
    self.NotifContainer.Position = UDim2.new(1, -315, 0, 20)
    self.NotifContainer.BackgroundTransparency = 1
    self.NotifContainer.ZIndex = 1000
    self.NotifContainer.Parent = self.ScreenGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.Parent = self.NotifContainer

    -- Floating logo (Nút mở lại menu khi đóng)
    self.FloatingCrescent = Instance.new("ImageButton")
    self.FloatingCrescent.Name = "FloatingCrescent"
    self.FloatingCrescent.Size = UDim2.new(0, 44, 0, 44)
    self.FloatingCrescent.Position = UDim2.new(0, 20, 0, 20)
    self.FloatingCrescent.BackgroundColor3 = Colors.Background
    self.FloatingCrescent.BorderSizePixel = 0
    self.FloatingCrescent.Visible = false
    self.FloatingCrescent.ZIndex = 1000
    self.FloatingCrescent.Parent = self.ScreenGui

    local fcCorner = Instance.new("UICorner")
    fcCorner.CornerRadius = UDim.new(1, 0)
    fcCorner.Parent = self.FloatingCrescent

    local fcStroke = Instance.new("UIStroke")
    fcStroke.Color = Colors.PinkAccent
    fcStroke.Thickness = 1.5
    fcStroke.Parent = self.FloatingCrescent

    local fcIconContainer = Instance.new("Frame")
    fcIconContainer.Name = "Icon"
    fcIconContainer.Size = UDim2.new(0, 24, 0, 24)
    fcIconContainer.Position = UDim2.new(0.5, -12, 0.5, -12)
    fcIconContainer.BackgroundTransparency = 1
    fcIconContainer.ClipsDescendants = true
    fcIconContainer.Parent = self.FloatingCrescent

    local fcOuter = Instance.new("Frame")
    fcOuter.Name = "Outer"
    fcOuter.Size = UDim2.new(0, 24, 0, 24)
    fcOuter.BackgroundColor3 = Colors.PinkPrimary
    fcOuter.BorderSizePixel = 0
    fcOuter.Parent = fcIconContainer
    Instance.new("UICorner", fcOuter).CornerRadius = UDim.new(1, 0)

    local fcCutout = Instance.new("Frame")
    fcCutout.Name = "Cutout"
    fcCutout.Size = UDim2.new(0, 20, 0, 20)
    fcCutout.Position = UDim2.new(0, 6, 0, -3)
    fcCutout.BackgroundColor3 = Colors.Background
    fcCutout.BorderSizePixel = 0
    fcCutout.Parent = fcOuter
    Instance.new("UICorner", fcCutout).CornerRadius = UDim.new(1, 0)

    local fcDragging = false
    local fcDragInput, fcDragStart, fcStartPos

    self.FloatingCrescent.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            fcDragging = true
            fcDragStart = input.Position
            fcStartPos = self.FloatingCrescent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then fcDragging = false end
            end)
        end
    end)

    self.FloatingCrescent.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then fcDragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == fcDragInput and fcDragging then
            local delta = input.Position - fcDragStart
            self.FloatingCrescent.Position = UDim2.new(fcStartPos.X.Scale, fcStartPos.X.Offset + delta.X, fcStartPos.Y.Scale, fcStartPos.Y.Offset + delta.Y)
        end
    end)

    self.FloatingCrescent.MouseEnter:Connect(function()
        TweenService:Create(self.FloatingCrescent, TweenInfo.new(0.15), { BackgroundColor3 = Colors.PinkDark }):Play()
        TweenService:Create(fcStroke, TweenInfo.new(0.15), { Color = Colors.PinkGlow }):Play()
        fcCutout.BackgroundColor3 = Colors.PinkDark
    end)

    self.FloatingCrescent.MouseLeave:Connect(function()
        TweenService:Create(self.FloatingCrescent, TweenInfo.new(0.15), { BackgroundColor3 = Colors.Background }):Play()
        TweenService:Create(fcStroke, TweenInfo.new(0.15), { Color = Colors.PinkAccent }):Play()
        fcCutout.BackgroundColor3 = Colors.Background
    end)

    self.FloatingCrescent.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)

    -- Main UI Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 680, 0, 460)
    self.MainFrame.Position = UDim2.new(0.5, -340, 0.5, -230)
    self.MainFrame.BackgroundColor3 = Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = self.MainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Colors.BorderPink
    mainStroke.Thickness = 1.5
    mainStroke.Parent = self.MainFrame

    -- Titlebar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 38)
    self.TitleBar.BackgroundColor3 = Colors.SidebarBg
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar

    local titleBottomFill = Instance.new("Frame")
    titleBottomFill.Name = "BottomFill"
    titleBottomFill.Size = UDim2.new(1, 0, 0, 10)
    titleBottomFill.Position = UDim2.new(0, 0, 1, -10)
    titleBottomFill.BackgroundColor3 = Colors.SidebarBg
    titleBottomFill.BorderSizePixel = 0
    titleBottomFill.Parent = self.TitleBar

    local titleDiv = Instance.new("Frame")
    titleDiv.Size = UDim2.new(1, 0, 0, 1)
    titleDiv.Position = UDim2.new(0, 0, 1, -1)
    titleDiv.BackgroundColor3 = Colors.Divider
    titleDiv.BorderSizePixel = 0
    titleDiv.Parent = self.TitleBar

    local brandTitle = Instance.new("TextLabel")
    brandTitle.Name = "BrandTitle"
    brandTitle.Size = UDim2.new(0, 150, 1, 0)
    brandTitle.Position = UDim2.new(0, 16, 0, 0)
    brandTitle.BackgroundTransparency = 1
    brandTitle.Font = Enum.Font.GothamBold
    brandTitle.Text = titleText or "Kchungdz"
    brandTitle.TextColor3 = Colors.PinkPrimary
    brandTitle.TextSize = 14
    brandTitle.TextXAlignment = Enum.TextXAlignment.Left
    brandTitle.Parent = self.TitleBar

    local gameSubtitle = Instance.new("TextLabel")
    gameSubtitle.Name = "GameSubtitle"
    gameSubtitle.Size = UDim2.new(0, 150, 1, 0)
    gameSubtitle.Position = UDim2.new(0, 100, 0, 0)
    gameSubtitle.BackgroundTransparency = 1
    gameSubtitle.Font = Enum.Font.Gotham
    gameSubtitle.Text = subtitleText or "HUB"
    gameSubtitle.TextColor3 = Colors.PinkMuted
    gameSubtitle.TextSize = 10
    gameSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    gameSubtitle.Parent = self.TitleBar

    local winControls = Instance.new("Frame")
    winControls.Size = UDim2.new(0, 60, 1, 0)
    winControls.Position = UDim2.new(1, -65, 0, 0)
    winControls.BackgroundTransparency = 1
    winControls.Parent = self.TitleBar

    self.MinBtn = Instance.new("TextButton")
    self.MinBtn.Size = UDim2.new(0, 24, 0, 24)
    self.MinBtn.Position = UDim2.new(0, 4, 0.5, -12)
    self.MinBtn.BackgroundColor3 = Colors.ControlBg
    self.MinBtn.Font = Enum.Font.GothamBold
    self.MinBtn.Text = "[-]"
    self.MinBtn.TextColor3 = Colors.PinkPrimary
    self.MinBtn.TextSize = 11
    self.MinBtn.BorderSizePixel = 0
    self.MinBtn.Parent = winControls
    Instance.new("UICorner", self.MinBtn).CornerRadius = UDim.new(0, 4)

    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    self.CloseBtn.Position = UDim2.new(0, 32, 0.5, -12)
    self.CloseBtn.BackgroundColor3 = Colors.ControlBg
    self.CloseBtn.Font = Enum.Font.GothamBold
    self.CloseBtn.Text = "[X]"
    self.CloseBtn.TextColor3 = Colors.AccentRed
    self.CloseBtn.TextSize = 11
    self.CloseBtn.BorderSizePixel = 0
    self.CloseBtn.Parent = winControls
    Instance.new("UICorner", self.CloseBtn).CornerRadius = UDim.new(0, 4)

    -- Window Dragging
    local dragging = false
    local dragInput, dragStart, startPos

    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Body & Navigation
    self.BodyFrame = Instance.new("Frame")
    self.BodyFrame.Name = "Body"
    self.BodyFrame.Size = UDim2.new(1, 0, 1, -62)
    self.BodyFrame.Position = UDim2.new(0, 0, 0, 38)
    self.BodyFrame.BackgroundTransparency = 1
    self.BodyFrame.Parent = self.MainFrame

    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 140, 1, 0)
    self.Sidebar.BackgroundColor3 = Colors.SidebarBg
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.BodyFrame

    local sideDiv = Instance.new("Frame")
    sideDiv.Size = UDim2.new(0, 1, 1, 0)
    sideDiv.Position = UDim2.new(1, -1, 0, 0)
    sideDiv.BackgroundColor3 = Colors.Divider
    sideDiv.BorderSizePixel = 0
    sideDiv.Parent = self.Sidebar

    self.SearchBox = Instance.new("TextBox")
    self.SearchBox.Name = "SearchBar"
    self.SearchBox.Size = UDim2.new(1, -16, 0, 26)
    self.SearchBox.Position = UDim2.new(0, 8, 0, 8)
    self.SearchBox.BackgroundColor3 = Colors.InputBg
    self.SearchBox.Font = Enum.Font.Gotham
    self.SearchBox.PlaceholderText = "Search..."
    self.SearchBox.PlaceholderColor3 = Colors.TextMuted
    self.SearchBox.Text = ""
    self.SearchBox.TextColor3 = Colors.TextWhite
    self.SearchBox.TextSize = 11
    self.SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    self.SearchBox.BorderSizePixel = 0
    self.SearchBox.ClearTextOnFocus = false
    self.SearchBox.Parent = self.Sidebar

    local searchPad = Instance.new("UIPadding")
    searchPad.PaddingLeft = UDim.new(0, 8)
    searchPad.Parent = self.SearchBox
    Instance.new("UICorner", self.SearchBox).CornerRadius = UDim.new(0, 4)

    self.NavList = Instance.new("ScrollingFrame")
    self.NavList.Name = "NavList"
    self.NavList.Size = UDim2.new(1, 0, 1, -44)
    self.NavList.Position = UDim2.new(0, 0, 0, 42)
    self.NavList.BackgroundTransparency = 1
    self.NavList.BorderSizePixel = 0
    self.NavList.ScrollBarThickness = 2
    self.NavList.ScrollBarImageColor3 = Colors.BorderSubtle
    self.NavList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.NavList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.NavList.Parent = self.Sidebar

    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 4)
    navLayout.Parent = self.NavList

    local navPad = Instance.new("UIPadding")
    navPad.PaddingTop = UDim.new(0, 6)
    navPad.PaddingLeft = UDim.new(0, 8)
    navPad.PaddingRight = UDim.new(0, 8)
    navPad.Parent = self.NavList

    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, -140, 1, 0)
    self.ContentArea.Position = UDim2.new(0, 140, 0, 0)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.BodyFrame

    -- Footer
    self.FooterBar = Instance.new("Frame")
    self.FooterBar.Name = "FooterBar"
    self.FooterBar.Size = UDim2.new(1, 0, 0, 24)
    self.FooterBar.Position = UDim2.new(0, 0, 1, -24)
    self.FooterBar.BackgroundColor3 = Colors.SidebarBg
    self.FooterBar.BorderSizePixel = 0
    self.FooterBar.Parent = self.MainFrame

    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 8)
    footerCorner.Parent = self.FooterBar

    local footerTopFill = Instance.new("Frame")
    footerTopFill.Name = "TopFill"
    footerTopFill.Size = UDim2.new(1, 0, 0, 10)
    footerTopFill.Position = UDim2.new(0, 0, 0, 0)
    footerTopFill.BackgroundColor3 = Colors.SidebarBg
    footerTopFill.BorderSizePixel = 0
    footerTopFill.Parent = self.FooterBar

    local footerDiv = Instance.new("Frame")
    footerDiv.Size = UDim2.new(1, 0, 0, 1)
    footerDiv.BackgroundColor3 = Colors.Divider
    footerDiv.BorderSizePixel = 0
    footerDiv.Parent = self.FooterBar

    self.FooterBrand = Instance.new("TextLabel")
    self.FooterBrand.Size = UDim2.new(0, 200, 1, 0)
    self.FooterBrand.Position = UDim2.new(0, 12, 0, 0)
    self.FooterBrand.BackgroundTransparency = 1
    self.FooterBrand.Font = Enum.Font.Gotham
    self.FooterBrand.Text = (titleText or "Kchungdz") .. " - Ready"
    self.FooterBrand.TextColor3 = Colors.TextMuted
    self.FooterBrand.TextSize = 10
    self.FooterBrand.TextXAlignment = Enum.TextXAlignment.Left
    self.FooterBrand.Parent = self.FooterBar

    self.FooterKey = Instance.new("TextLabel")
    self.FooterKey.Size = UDim2.new(0, 200, 1, 0)
    self.FooterKey.Position = UDim2.new(1, -212, 0, 0)
    self.FooterKey.BackgroundTransparency = 1
    self.FooterKey.Font = Enum.Font.Gotham
    self.FooterKey.Text = "[L-CTRL] Menu"
    self.FooterKey.TextColor3 = Colors.TextMuted
    self.FooterKey.TextSize = 10
    self.FooterKey.TextXAlignment = Enum.TextXAlignment.Right
    self.FooterKey.Parent = self.FooterBar

    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = self.SearchBox.Text:lower():gsub("^%s*(.-)%s*$", "%1")
        for _, item in ipairs(self.RowSearchIndex) do
            local row = item.frame
            if q == "" or item.query:find(q, 1, true) then
                row.Visible = true
            else
                row.Visible = false
            end
        end
    end)

    self.MinBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    table.insert(self.ActiveConnections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            self:ToggleVisibility()
        end
    end))

    return self
end

function Kchungdz:SendNotification(title, text, duration)
    duration = duration or 3
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Colors.Background
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = self.NotifContainer

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.PinkAccent
    stroke.Thickness = 1.2
    stroke.Parent = card

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 20)
    topBar.BackgroundTransparency = 1
    topBar.Position = UDim2.new(0, 10, 0, 6)
    topBar.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -20, 1, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.Text = title
    tLabel.TextColor3 = Colors.PinkPrimary
    tLabel.TextSize = 13
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = topBar

    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -20, 0, 26)
    mLabel.Position = UDim2.new(0, 10, 0, 26)
    mLabel.BackgroundTransparency = 1
    mLabel.Font = Enum.Font.Gotham
    mLabel.Text = text
    mLabel.TextColor3 = Colors.TextSubtle
    mLabel.TextSize = 11
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.TextWrapped = true
    mLabel.Parent = card

    task.delay(duration, function()
        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
            Position = card.Position + UDim2.new(1, 20, 0, 0)
        }):Play()
        task.wait(0.35)
        card:Destroy()
    end)
end

function Kchungdz:ToggleVisibility()
    self.UiVisible = not self.UiVisible
    self.MainFrame.Visible = self.UiVisible
    self.FloatingCrescent.Visible = not self.UiVisible
end

function Kchungdz:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    self.BodyFrame.Visible = not self.IsMinimized
    self.FooterBar.Visible = not self.IsMinimized
    self.MainFrame.Size = self.IsMinimized and UDim2.new(0, 680, 0, 38) or UDim2.new(0, 680, 0, 460)
    self.MinBtn.Text = self.IsMinimized and "[+]" or "[-]"
end

function Kchungdz:Destroy()
    for _, conn in ipairs(self.ActiveConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self.ActiveConnections)
    self.ScreenGui:Destroy()
    if getgenv then getgenv()._Kchungdz = nil end
end

function Kchungdz:SwitchTab(tabName)
    for name, frame in pairs(self.TabFrames) do
        frame.Visible = (name == tabName)
    end
    for name, btn in pairs(self.TabButtons) do
        if name == tabName then
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Colors.PinkDark,
                TextColor3 = Colors.TextWhite
            }):Play()
            local pill = btn:FindFirstChild("ActivePill")
            if pill then pill.Visible = true end
        else
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Colors.SidebarBg,
                TextColor3 = Colors.TextSubtle
            }):Play()
            local pill = btn:FindFirstChild("ActivePill")
            if pill then pill.Visible = false end
        end
    end
end

function Kchungdz:CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Name = "TabBtn_" .. name
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Colors.SidebarBg
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextColor3 = Colors.TextSubtle
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = self.NavList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 12)
    btnPad.Parent = btn

    local pill = Instance.new("Frame")
    pill.Name = "ActivePill"
    pill.Size = UDim2.new(0, 3, 0, 16)
    pill.Position = UDim2.new(0, -9, 0.5, -8)
    pill.BackgroundColor3 = Colors.PinkAccent
    pill.BorderSizePixel = 0
    pill.Visible = false
    pill.Parent = btn
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 2)

    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)

    local page = Instance.new("ScrollingFrame")
    page.Name = "TabPage_" .. name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Colors.BorderPink
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = self.ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 12)
    pagePad.PaddingBottom = UDim.new(0, 16)
    pagePad.PaddingLeft = UDim.new(0, 14)
    pagePad.PaddingRight = UDim.new(0, 14)
    pagePad.Parent = page

    self.TabFrames[name] = page
    self.TabButtons[name] = btn

    local tab = {}
    tab.Page = page

    function tab:CreateCategoryHeader(text)
        local hdr = Instance.new("Frame")
        hdr.Size = UDim2.new(1, 0, 0, 22)
        hdr.BackgroundTransparency = 1
        hdr.Parent = page

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = string.upper(text)
        lbl.TextColor3 = Colors.PinkPrimary
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = hdr
        return hdr
    end

    function tab:CreateCardGroup()
        local group = Instance.new("Frame")
        group.Size = UDim2.new(1, 0, 0, 0)
        group.AutomaticSize = Enum.AutomaticSize.Y
        group.BackgroundColor3 = Colors.RowNormal
        group.BorderSizePixel = 0
        group.Parent = page

        local stroke = Instance.new("UIStroke")
        stroke.Color = Colors.BorderSubtle
        stroke.Thickness = 1
        stroke.Parent = group

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = group

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 0)
        layout.Parent = group

        return group
    end

    return tab
end

function Kchungdz:CreateBaseRow(parent, labelText, descText, indexSearch)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Colors.RowNormal
    row.BorderSizePixel = 0
    row.Parent = parent

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = row

    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, -190, 1, 0)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = row

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.Position = UDim2.new(0, 0, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = labelText
    titleLbl.TextColor3 = Colors.TextWhite
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = textFrame

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, 0, 0, 14)
    descLbl.Position = UDim2.new(0, 0, 0, 22)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = descText or ""
    descLbl.TextColor3 = Colors.TextMuted
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = textFrame

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = Colors.RowHover }):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = Colors.RowNormal }):Play()
    end)

    if indexSearch ~= false then
        table.insert(self.RowSearchIndex, {
            frame = row,
            query = (labelText .. " " .. (descText or "")):lower()
        })
    end

    return row
end

function Kchungdz:CreateToggleRow(parent, labelText, descText, initialVal, callback, indexSearch)
    local row = self:CreateBaseRow(parent, labelText, descText, indexSearch)
    local state = initialVal or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = state and Colors.PinkAccent or Colors.ControlBg
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Colors.TextWhite
    knob.BorderSizePixel = 0
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function updateVisuals()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Colors.PinkAccent or Colors.ControlBg
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals()
        if callback then callback(state) end
    end)

    return {
        frame = row,
        SetState = function(val)
            state = val
            updateVisuals()
        end,
        GetState = function()
            return state
        end
    }
end

function Kchungdz:CreateSliderRow(parent, labelText, descText, minVal, maxVal, initialVal, isFloat, suffix, callback, indexSearch)
    local row = self:CreateBaseRow(parent, labelText, descText, indexSearch)
    local currentVal = initialVal or minVal
    suffix = suffix or ""

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 180, 0, 24)
    container.Position = UDim2.new(1, -180, 0.5, -12)
    container.BackgroundTransparency = 1
    container.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 68, 1, 0)
    valLabel.Position = UDim2.new(1, -68, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBold
    valLabel.Text = isFloat and string.format("%.2f", currentVal) .. suffix or tostring(math.floor(currentVal)) .. suffix
    valLabel.TextColor3 = Colors.PinkPrimary
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -74, 0, 6)
    track.Position = UDim2.new(0, 0, 0.5, -3)
    track.BackgroundColor3 = Colors.ControlBg
    track.BorderSizePixel = 0
    track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    local pct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Colors.PinkAccent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliding = false
    local function updateValueFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        currentVal = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLabel.Text = isFloat and string.format("%.2f", val) .. suffix or tostring(val) .. suffix
        if callback then callback(val) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateValueFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValueFromX(input.Position.X)
        end
    end)

    return {
        frame = row,
        SetValue = function(val)
            currentVal = val
            local p = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            valLabel.Text = isFloat and string.format("%.2f", val) .. suffix or tostring(math.floor(val)) .. suffix
        end,
        GetValue = function()
            return currentVal
        end
    }
end

function Kchungdz:CreateDropdownRow(parent, labelText, descText, options, initialVal, callback, indexSearch)
    local selected = initialVal or options[1]

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = Colors.RowNormal
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    row.Parent = parent

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Padding = UDim.new(0, 4)
    rowLayout.Parent = row

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundTransparency = 1
    header.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = header

    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, -145, 1, 0)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = header

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.Position = UDim2.new(0, 0, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = labelText
    titleLbl.TextColor3 = Colors.TextWhite
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = textFrame

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, 0, 0, 14)
    descLbl.Position = UDim2.new(0, 0, 0, 22)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = descText or ""
    descLbl.TextColor3 = Colors.TextMuted
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = textFrame

    local ddBtn = Instance.new("TextButton")
    ddBtn.Size = UDim2.new(0, 130, 0, 24)
    ddBtn.Position = UDim2.new(1, -130, 0.5, -12)
    ddBtn.BackgroundColor3 = Colors.ControlBg
    ddBtn.Font = Enum.Font.GothamBold
    ddBtn.Text = tostring(selected) .. "  v"
    ddBtn.TextColor3 = Colors.PinkPrimary
    ddBtn.TextSize = 11
    ddBtn.BorderSizePixel = 0
    ddBtn.Parent = header
    Instance.new("UICorner", ddBtn).CornerRadius = UDim.new(0, 4)

    local optionsContainer = Instance.new("Frame")
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.AutomaticSize = Enum.AutomaticSize.Y
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Visible = false
    optionsContainer.Parent = row

    local optPad = Instance.new("UIPadding")
    optPad.PaddingLeft = UDim.new(0, 10)
    optPad.PaddingRight = UDim.new(0, 10)
    optPad.PaddingBottom = UDim.new(0, 8)
    optPad.Parent = optionsContainer

    local optList = Instance.new("UIListLayout")
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Padding = UDim.new(0, 3)
    optList.Parent = optionsContainer

    local optButtons = {}
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = (opt == selected) and Colors.DropdownSelected or Colors.InputBg
        optBtn.Font = Enum.Font.Gotham
        optBtn.Text = (opt == selected and "> " or "   ") .. tostring(opt)
        optBtn.TextColor3 = (opt == selected) and Colors.PinkPrimary or Colors.TextWhite
        optBtn.TextSize = 11
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.BorderSizePixel = 0
        optBtn.Parent = optionsContainer
        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

        local oPad = Instance.new("UIPadding")
        oPad.PaddingLeft = UDim.new(0, 10)
        oPad.Parent = optBtn

        optButtons[opt] = optBtn

        optBtn.MouseEnter:Connect(function()
            if opt ~= selected then
                TweenService:Create(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.RowHover }):Play()
            end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= selected then
                TweenService:Create(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.InputBg }):Play()
            end
        end)

        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            ddBtn.Text = tostring(opt) .. "  v"
            optionsContainer.Visible = false
            for oName, b in pairs(optButtons) do
                b.BackgroundColor3 = (oName == opt) and Colors.DropdownSelected or Colors.InputBg
                b.TextColor3 = (oName == opt) and Colors.PinkPrimary or Colors.TextWhite
                b.Text = (oName == opt and "> " or "   ") .. tostring(oName)
            end
            if callback then callback(opt) end
        end)
    end

    ddBtn.MouseButton1Click:Connect(function()
        optionsContainer.Visible = not optionsContainer.Visible
        ddBtn.Text = tostring(selected) .. (optionsContainer.Visible and "  ^" or "  v")
    end)

    header.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = Colors.RowHover }):Play()
    end)
    header.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = Colors.RowNormal }):Play()
    end)

    if indexSearch ~= false then
        table.insert(self.RowSearchIndex, {
            frame = row,
            query = (labelText .. " " .. (descText or "")):lower()
        })
    end

    return {
        frame = row,
        SetSelected = function(opt)
            selected = opt
            ddBtn.Text = tostring(opt) .. "  v"
            for oName, b in pairs(optButtons) do
                b.BackgroundColor3 = (oName == opt) and Colors.DropdownSelected or Colors.InputBg
                b.TextColor3 = (oName == opt) and Colors.PinkPrimary or Colors.TextWhite
                b.Text = (oName == opt and "> " or "   ") .. tostring(oName)
            end
        end,
        GetSelected = function()
            return selected
        end
    }
end

function Kchungdz:CreateButtonRow(parent, labelText, btnText, descText, callback, indexSearch)
    local row = self:CreateBaseRow(parent, labelText, descText, indexSearch)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 24)
    btn.Position = UDim2.new(1, -90, 0.5, -12)
    btn.BackgroundColor3 = Colors.ControlBg
    btn.Font = Enum.Font.GothamBold
    btn.Text = btnText
    btn.TextColor3 = Colors.PinkPrimary
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.PinkDark, TextColor3 = Colors.TextWhite }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.ControlBg, TextColor3 = Colors.PinkPrimary }):Play()
    end)

    btn.MouseButton1Click:Connect(callback)
    return row
end

function Kchungdz:CreateInfoRow(parent, labelText, valueText, indexSearch)
    local row = self:CreateBaseRow(parent, labelText, "", indexSearch)
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 140, 1, 0)
    valLbl.Position = UDim2.new(1, -140, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = valueText
    valLbl.TextColor3 = Colors.PinkPrimary
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row

    return {
        frame = row,
        SetValue = function(newVal)
            valLbl.Text = newVal
        end
    }
end

-- Xuất singleton toàn cục
local env = (type(getgenv) == "function" and getgenv()) or _G
env._Kchungdz = Kchungdz

return Kchungdz
