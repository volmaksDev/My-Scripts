-- // RH Logger Console Module - Linoria Style (Black & Red)

local Console = {}

function Console:Create(parent)
    local ConsoleFrame = Instance.new("Frame")
    ConsoleFrame.Name = "Console"
    ConsoleFrame.Size = UDim2.new(1, 0, 1, 0)
    ConsoleFrame.BackgroundTransparency = 1
    ConsoleFrame.Parent = parent

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Header.BorderSizePixel = 0
    Header.Parent = ConsoleFrame

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -120, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 16, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "Console"
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Font = Enum.Font.GothamSemibold
    HeaderTitle.TextSize = 15
    HeaderTitle.Parent = Header

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 200, 0, 28)
    SearchBox.Position = UDim2.new(1, -216, 0.5, -14)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.PlaceholderText = "Search logs..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = Header

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    local LogScroll = Instance.new("ScrollingFrame")
    LogScroll.Size = UDim2.new(1, 0, 1, -36)
    LogScroll.Position = UDim2.new(0, 0, 0, 36)
    LogScroll.BackgroundTransparency = 1
    LogScroll.BorderSizePixel = 0
    LogScroll.ScrollBarThickness = 6
    LogScroll.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 40)
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LogScroll.Parent = ConsoleFrame

    local LogLayout = Instance.new("UIListLayout")
    LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LogLayout.Padding = UDim.new(0, 2)
    LogLayout.Parent = LogScroll

    local LogPadding = Instance.new("UIPadding")
    LogPadding.PaddingLeft = UDim.new(0, 12)
    LogPadding.PaddingRight = UDim.new(0, 12)
    LogPadding.PaddingTop = UDim.new(0, 8)
    LogPadding.PaddingBottom = UDim.new(0, 8)
    LogPadding.Parent = LogScroll

    local Logs = {}
    local AutoScroll = true
    local FilterText = ""

    function Console:AddLog(message, logType)
        logType = logType or "Info"

        local LogEntry = Instance.new("Frame")
        LogEntry.Size = UDim2.new(1, 0, 0, 22)
        LogEntry.BackgroundTransparency = 1
        LogEntry.LayoutOrder = #Logs + 1
        LogEntry.Parent = LogScroll

        local TimeLabel = Instance.new("TextLabel")
        TimeLabel.Size = UDim2.new(0, 70, 1, 0)
        TimeLabel.BackgroundTransparency = 1
        TimeLabel.Text = os.date("[%H:%M:%S]")
        TimeLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        TimeLabel.Font = Enum.Font.Gotham
        TimeLabel.TextSize = 13
        TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
        TimeLabel.Parent = LogEntry

        local TypeLabel = Instance.new("TextLabel")
        TypeLabel.Size = UDim2.new(0, 80, 1, 0)
        TypeLabel.Position = UDim2.new(0, 75, 0, 0)
        TypeLabel.BackgroundTransparency = 1
        TypeLabel.Font = Enum.Font.GothamSemibold
        TypeLabel.TextSize = 13
        TypeLabel.TextXAlignment = Enum.TextXAlignment.Left
        TypeLabel.Parent = LogEntry

        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Size = UDim2.new(1, -170, 1, 0)
        MessageLabel.Position = UDim2.new(0, 160, 0, 0)
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Text = message
        MessageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextWrapped = true
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.TextSize = 13
        MessageLabel.Parent = LogEntry

        if logType == "Loadstring" then
            TypeLabel.Text = "[LOADSTRING]"
            TypeLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
        elseif logType == "Remote" then
            TypeLabel.Text = "[REMOTE]"
            TypeLabel.TextColor3 = Color3.fromRGB(180, 80, 220)
        elseif logType == "Http" or logType == "Request" then
            TypeLabel.Text = "[HTTP]"
            TypeLabel.TextColor3 = Color3.fromRGB(60, 160, 255)
        elseif logType == "Warning" then
            TypeLabel.Text = "[WARNING]"
            TypeLabel.TextColor3 = Color3.fromRGB(255, 180, 60)
            MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        elseif logType == "Error" then
            TypeLabel.Text = "[ERROR]"
            TypeLabel.TextColor3 = Color3.fromRGB(220, 50, 50)
            MessageLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif logType == "Success" then
            TypeLabel.Text = "[SUCCESS]"
            TypeLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
        else
            TypeLabel.Text = "[INFO]"
            TypeLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
        end

        table.insert(Logs, LogEntry)

        if AutoScroll then
            task.defer(function()
                LogScroll.CanvasPosition = Vector2.new(0, LogScroll.AbsoluteCanvasSize.Y)
            end)
        end

        LogEntry.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                print("Clicked log: " .. message)
            end
        end)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        FilterText = SearchBox.Text:lower()
        for _, log in ipairs(Logs) do
            local msg = log:FindFirstChildWhichIsA("TextLabel", true)
            if msg and msg.Text then
                log.Visible = FilterText == "" or msg.Text:lower():find(FilterText)
            end
        end
    end)

    function Console:Clear()
        for _, log in ipairs(Logs) do
            log:Destroy()
        end
        Logs = {}
    end

    function Console:ToggleAutoScroll(state)
        AutoScroll = state
    end

    getgenv().RH_Console = Console

    return Console
end

return Console
