local Limbo = {}
Limbo._resetCallbacks = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer.PlayerGui
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local ConfigFolder = "LimboFishIt"

local function CircleClick(Button, X, Y)
    spawn(
        function()
            Button.ClipsDescendants = true
            local Circle = Instance.new("ImageLabel")
            Circle.Image = "rbxassetid://266543268"
            Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
            Circle.ImageTransparency = 0.9
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.BackgroundTransparency = 1
            Circle.ZIndex = 10
            Circle.Name = "Circle"
            Circle.Parent = Button

            local NewX = X - Circle.AbsolutePosition.X
            local NewY = Y - Circle.AbsolutePosition.Y
            Circle.Position = UDim2.new(0, NewX, 0, NewY)
            local Size = 0
            if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.X * 1.5
            elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.Y * 1.5
            elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.X * 1.5
            end

            local Time = 0.5
            Circle:TweenSizeAndPosition(
                UDim2.new(0, Size, 0, Size),
                UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
                "Out",
                "Quad",
                Time,
                false,
                nil
            )
            for i = 1, 10 do
                Circle.ImageTransparency = Circle.ImageTransparency + 0.01
                wait(Time / 10)
            end
            Circle:Destroy()
        end
    )
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos =
            UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position

                input.Changed:Connect(
                    function()
                        if input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                        end
                    end
                )
            end
        end
    )

    topbarobject.InputChanged:Connect(
        function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch
             then
                DragInput = input
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end
    )
end

local function MakeDraggableMobileButton(button, object, screenGui)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    local ClickStartPos = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local newX = StartPosition.X + Delta.X
        local newY = StartPosition.Y + Delta.Y

        local screenSize = screenGui.AbsoluteSize
        local buttonSize = object.AbsoluteSize

        local padding = 10
        newX = math.clamp(newX, padding, screenSize.X - buttonSize.X - padding)
        newY = math.clamp(newY, padding, screenSize.Y - buttonSize.Y - padding)

        object.Position = UDim2.new(0, newX, 0, newY)
    end

    pcall(function() button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            ClickStartPos = input.Position
            DragStart = input.Position
            pcall(function()
                StartPosition = Vector2.new(object.AbsolutePosition.X, object.AbsolutePosition.Y)
            end)
            if not StartPosition then
                StartPosition = Vector2.new(object.Position.X.Offset, object.Position.Y.Offset)
            end
        end
    end) end)

    pcall(function() UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end) end)

    pcall(function() button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if not Dragging and ClickStartPos then
                local dragDistance = (input.Position - ClickStartPos).Magnitude
                if dragDistance > 5 then Dragging = true end
            end
            DragInput = input
        end
    end) end)

    pcall(function() UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end) end)

    return function()
        return Dragging
    end
end

local function MakeResizable(resizeHandle, targetObject, minSize, maxSize, onResize)
    minSize = minSize or Vector2.new(300, 200)
    maxSize = maxSize or Vector2.new(1000, 800)

    local isResizing = false
    local resizeStartPos = nil
    local startSize = nil
    local startMousePos = nil

    resizeHandle.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = true
                resizeStartPos = targetObject.Position
                startSize = Vector2.new(targetObject.Size.X.Offset, targetObject.Size.Y.Offset)
                startMousePos = input.Position

                input.Changed:Connect(function()
                    if not isResizing then return end
                    if input.UserInputState == Enum.UserInputState.End then
                        isResizing = false
                        return
                    end
                    local delta = input.Position - startMousePos
                    local newWidth  = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
                    local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
                    targetObject.Size = UDim2.new(0, newWidth, 0, newHeight)
                    if onResize then onResize(Vector2.new(newWidth, newHeight)) end
                end)
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = false
            end
        end
    )
end

local ConfigSystem = {
    CurrentConfig = nil,
    Configs = {},
    ThemeColors = {
        ["Darker"] = Color3.fromRGB(150, 150, 170),
    },
    CurrentTheme = "Darker",
    ThemeElements = {},
    ToggleElements = {},
    SliderElements = {},
    DropdownElements = {},
    TabElements = {},
    AllElements = {},
    DropdownOptionFrames = {}
}

function ConfigSystem:SetTheme(themeName)
    if self.ThemeColors[themeName] then
        self.CurrentTheme = themeName
        local newColor = self.ThemeColors[themeName]
        self:UpdateAllThemeElements(newColor)
        return true, newColor
    end
    return false, nil
end

function ConfigSystem:UpdateAllThemeElements(newColor)
    for _, toggle in pairs(self.ToggleElements) do
        if toggle and toggle:IsA("Frame") then
            local featureFrame = toggle:FindFirstChild("FeatureFrame")
            local toggleCircle = toggle:FindFirstChild("ToggleCircle")
            local frameStroke = featureFrame and featureFrame:FindFirstChild("UIStroke")
            local toggleTitle = toggle:FindFirstChild("ToggleTitle")

            if toggleCircle then
                local isOn = toggleCircle.Position == UDim2.new(0, 15, 0, 0)
                if isOn then
                    toggleCircle.BackgroundColor3 = newColor
                    if frameStroke then
                        frameStroke.Color = newColor
                    end
                    if featureFrame then
                        featureFrame.BackgroundColor3 = newColor
                    end
                    if toggleTitle then
                        toggleTitle.TextColor3 = newColor
                    end
                end
            end
        end
    end

    for _, slider in pairs(self.SliderElements) do
        if slider and slider:IsA("Frame") then
            local sliderFill = slider:FindFirstChild("SliderFill")

            if sliderFill then
                sliderFill.BackgroundColor3 = newColor
            end
        end
    end

    for _, dropdown in pairs(self.DropdownElements) do
        if dropdown and dropdown:IsA("Frame") then
            local dropdownList = dropdown:FindFirstChild("DropdownList")
            if dropdownList then
                local listScroll = dropdownList:FindFirstChild("ListScroll")
                if listScroll then
                    for _, option in listScroll:GetChildren() do
                        if option:IsA("Frame") and option.Name == "Option" then
                            local chooseFrame = option:FindFirstChild("ChooseFrame")
                            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
                            local optionText = option:FindFirstChild("OptionText")

                            if chooseFrame then
                                chooseFrame.BackgroundColor3 = newColor
                            end
                            if chooseStroke then
                                chooseStroke.Color = newColor
                            end
                            if optionText and optionText.TextColor3 ~= Color3.fromRGB(230, 230, 230) then
                                optionText.TextColor3 = newColor
                            end
                        end
                    end
                end
            end
        end
    end

    for _, optionData in pairs(self.DropdownOptionFrames) do
        if optionData.Frame and optionData.Frame.Parent then
            local chooseFrame = optionData.Frame:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
            local optionText = optionData.Frame:FindFirstChild("OptionText")

            if optionData.IsSelected then
                if chooseFrame then
                    chooseFrame.BackgroundColor3 = newColor
                end
                if chooseStroke then
                    chooseStroke.Color = newColor
                end
                if optionText then
                    optionText.TextColor3 = newColor
                end
            end
        end
    end

    for _, tab in pairs(self.TabElements) do
        if tab and tab:IsA("Frame") then
            local chooseFrame = tab:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")

            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
            end
            if chooseStroke then
                chooseStroke.Color = newColor
            end
        end
    end

    for _, element in pairs(self.ThemeElements) do
        if element and element:IsA("Frame") and element:FindFirstChild("ChooseFrame") then
            local chooseFrame = element.ChooseFrame
            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
                local stroke = chooseFrame:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = newColor
                end
            end
        elseif type(element) == "table" and element.Update then
            element.Update(newColor)
        end
    end

    return newColor
end

function ConfigSystem:EnsureFolder()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

function ConfigSystem:SaveConfig(name, data)
    self:EnsureFolder()

    local success, encoded =
        pcall(
        function()
            return HttpService:JSONEncode(data or {})
        end
    )

    if success then
        writefile(ConfigFolder .. "/" .. name .. ".json", encoded)
        self.CurrentConfig = name

        return {
            Title = "Config",
            Description = "Saved",
            Content = "Config '" .. name .. "' saved successfully!",
            Color = self.ThemeColors[self.CurrentTheme],
            Delay = 3
        }
    else
        return {
            Title = "Config",
            Description = "Error",
            Content = "Failed to save config: " .. tostring(encoded),
            Color = Color3.fromRGB(150, 150, 170),
            Delay = 3
        }
    end
end

function ConfigSystem:LoadConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"

    if isfile(filePath) then
        local success, content =
            pcall(
            function()
                return readfile(filePath)
            end
        )

        if success then
            local decodeSuccess, decoded =
                pcall(
                function()
                    return HttpService:JSONDecode(content)
                end
            )

            if decodeSuccess and decoded then
                self.CurrentConfig = name
                -- support both flat format and legacy {Data=...} format
                local configData = decoded.Data or decoded
                return {
                    Title = "Config",
                    Description = "Loaded",
                    Content = "Config '" .. name .. "' loaded successfully!",
                    Color = self.ThemeColors[self.CurrentTheme],
                    Delay = 3
                }, configData
            end
        end
    end

    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found or corrupted!",
        Color = Color3.fromRGB(150, 150, 170),
        Delay = 3
    }, nil
end

function ConfigSystem:DeleteConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"

    if isfile(filePath) then
        local success =
            pcall(
            function()
                delfile(filePath)
            end
        )

        if success then
            if self.CurrentConfig == name then
                self.CurrentConfig = nil
            end

            return {
                Title = "Config",
                Description = "Deleted",
                Content = "Config '" .. name .. "' deleted successfully!",
                Color = self.ThemeColors[self.CurrentTheme],
                Delay = 3
            }
        end
    end

    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found!",
        Color = Color3.fromRGB(150, 150, 170),
        Delay = 3
    }
end

function ConfigSystem:GetConfigList()
    self:EnsureFolder()
    local configs = {}

    local success, files =
        pcall(
        function()
            return listfiles(ConfigFolder)
        end
    )

    if success and files then
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/\\]+)%.json$")
            if fileName then
                table.insert(configs, fileName)
            end
        end
    end

    return configs
end

local function MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Notification"
    NotifyConfig.Description = NotifyConfig.Description or ""
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(150, 150, 170)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5

    local NotifyFunction = {}

    spawn(
        function()
            if not CoreGui:FindFirstChild("NotifyGui") then
                local NotifyGui = Instance.new("ScreenGui")
                NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                NotifyGui.Name = "NotifyGui"
                NotifyGui.Parent = (gethui and gethui()) or CoreGui
            end

            if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
                local NotifyLayout = Instance.new("Frame")
                NotifyLayout.AnchorPoint = Vector2.new(1, 1)
                NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                NotifyLayout.BackgroundTransparency = 0.999
                NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
                NotifyLayout.BorderSizePixel = 0
                NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
                NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
                NotifyLayout.Name = "NotifyLayout"
                NotifyLayout.Parent = CoreGui.NotifyGui

                local Count = 0
                CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(
                    function()
                        Count = 0
                        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                            TweenService:Create(
                                v,
                                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                                {Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))}
                            ):Play()
                            Count = Count + 1
                        end
                    end
                )
            end

            local NotifyPosHeigh = 0
            for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
            end

            local NotifyFrame = Instance.new("Frame")
            local NotifyFrameReal = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local DropShadowHolder = Instance.new("Frame")
            local DropShadow = Instance.new("ImageLabel")
            local Top = Instance.new("Frame")
            local TextLabel = Instance.new("TextLabel")
            local UIStroke = Instance.new("UIStroke")
            local UICorner1 = Instance.new("UICorner")
            local TextLabel1 = Instance.new("TextLabel")
            local UIStroke1 = Instance.new("UIStroke")
            local Close = Instance.new("TextButton")
            local ImageLabel = Instance.new("ImageLabel")
            local TextLabel2 = Instance.new("TextLabel")

            NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrame.BorderSizePixel = 0
            NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
            NotifyFrame.Name = "NotifyFrame"
            NotifyFrame.BackgroundTransparency = 1
            NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
            NotifyFrame.AnchorPoint = Vector2.new(0, 1)
            NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

            NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrameReal.BorderSizePixel = 0
            NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
            NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
            NotifyFrameReal.Name = "NotifyFrameReal"
            NotifyFrameReal.Parent = NotifyFrame

            UICorner.Parent = NotifyFrameReal

            -- Accent pill kiri
            local AccentPill = Instance.new("Frame")
            AccentPill.BackgroundColor3 = NotifyConfig.Color
            AccentPill.Size = UDim2.new(0, 3, 1, 0)
            AccentPill.Position = UDim2.new(0, 0, 0, 0)
            AccentPill.BorderSizePixel = 0
            AccentPill.ZIndex = 4
            AccentPill.Parent = NotifyFrameReal
            UICorner.CornerRadius = UDim.new(0, 8)

            DropShadowHolder.BackgroundTransparency = 1
            DropShadowHolder.BorderSizePixel = 0
            DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
            DropShadowHolder.ZIndex = 0
            DropShadowHolder.Name = "DropShadowHolder"
            DropShadowHolder.Parent = NotifyFrameReal

            DropShadow.Image = "rbxassetid://6015897843"
            DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            DropShadow.ImageTransparency = 0.5
            DropShadow.ScaleType = Enum.ScaleType.Slice
            DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
            DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            DropShadow.BackgroundTransparency = 1
            DropShadow.BorderSizePixel = 0
            DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            DropShadow.Size = UDim2.new(1, 47, 1, 47)
            DropShadow.ZIndex = 0
            DropShadow.Name = "DropShadow"
            DropShadow.Parent = DropShadowHolder

            Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Top.BackgroundTransparency = 0.999
            Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Top.BorderSizePixel = 0
            Top.Size = UDim2.new(1, 0, 0, 36)
            Top.Name = "Top"
            Top.Parent = NotifyFrameReal

            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.Text = NotifyConfig.Title
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 14
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 0.999
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.Size = UDim2.new(0, 0, 1, 0)
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            TextLabel.Parent = Top
            TextLabel.Position = UDim2.new(0, 10, 0, 0)

            if NotifyConfig.Subtitle and NotifyConfig.Subtitle ~= "" then
                local SubLabel = Instance.new("TextLabel")
                SubLabel.Font = Enum.Font.GothamBold
                SubLabel.Text = NotifyConfig.Subtitle
                SubLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
                SubLabel.TextSize = 14
                SubLabel.TextXAlignment = Enum.TextXAlignment.Left
                SubLabel.BackgroundTransparency = 0.999
                SubLabel.BorderSizePixel = 0
                SubLabel.AutomaticSize = Enum.AutomaticSize.X
                SubLabel.Size = UDim2.new(0, 0, 1, 0)
                SubLabel.Position = UDim2.new(0, 10, 0, 0)
                SubLabel.Parent = Top
                local tw = TextService:GetTextSize(NotifyConfig.Title or "", 14, Enum.Font.GothamBold, Vector2.new(math.huge, math.huge)).X
                SubLabel.Position = UDim2.new(0, tw + 18, 0, 0)
            end

            UIStroke.Color = Color3.fromRGB(255, 255, 255)
            UIStroke.Thickness = 0.3
            UIStroke.Parent = TextLabel

            UICorner1.Parent = Top
            UICorner1.CornerRadius = UDim.new(0, 5)

            TextLabel1.Font = Enum.Font.GothamBold
            TextLabel1.Text = NotifyConfig.Description
            TextLabel1.TextColor3 = NotifyConfig.Color
            TextLabel1.TextSize = 14
            TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel1.BackgroundTransparency = 0.999
            TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel1.BorderSizePixel = 0
            TextLabel1.Size = UDim2.new(1, 0, 1, 0)
            TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
            TextLabel1.Parent = Top

            UIStroke1.Color = NotifyConfig.Color
            UIStroke1.Thickness = 0.4
            UIStroke1.Parent = TextLabel1

            Close.Font = Enum.Font.SourceSans
            Close.Text = ""
            Close.TextColor3 = Color3.fromRGB(0, 0, 0)
            Close.TextSize = 14
            Close.AnchorPoint = Vector2.new(1, 0.5)
            Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Close.BackgroundTransparency = 0.999
            Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Close.BorderSizePixel = 0
            Close.Position = UDim2.new(1, -5, 0.5, 0)
            Close.Size = UDim2.new(0, 25, 0, 25)
            Close.Name = "Close"
            Close.Parent = Top

            ImageLabel.Image = "rbxassetid://9886659671"
            ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageLabel.BackgroundTransparency = 0.999
            ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ImageLabel.BorderSizePixel = 0
            ImageLabel.Position = UDim2.new(0.49, 0, 0.5, 0)
            ImageLabel.Size = UDim2.new(1, -8, 1, -8)
            ImageLabel.Parent = Close

            TextLabel2.Font = Enum.Font.GothamBold
            TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel2.TextSize = 13
            TextLabel2.Text = NotifyConfig.Content
            TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
            TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel2.BackgroundTransparency = 0.999
            TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel2.TextTransparency = 0.35
            TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel2.BorderSizePixel = 0
            TextLabel2.Position = UDim2.new(0, 10, 0, 27)
            TextLabel2.Parent = NotifyFrameReal
            TextLabel2.Size = UDim2.new(1, -20, 0, 13)

            TextLabel2.Size = UDim2.new(1, -20, 0, 13 + (13 * (TextLabel2.TextBounds.X // TextLabel2.AbsoluteSize.X)))
            TextLabel2.TextWrapped = true

            if TextLabel2.AbsoluteSize.Y < 27 then
                NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
            else
                NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
            end

            local waitbruh = false
            function NotifyFunction:Close()
                if waitbruh then
                    return false
                end
                waitbruh = true
                TweenService:Create(
                    NotifyFrameReal,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    {Position = UDim2.new(0, 400, 0, 0)}
                ):Play()
                task.wait(tonumber(NotifyConfig.Time) / 1.2)
                NotifyFrame:Destroy()
            end

            Close.Activated:Connect(
                function()
                    NotifyFunction:Close()
                end
            )

            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}
            ):Play()
            task.wait(tonumber(NotifyConfig.Delay))
            NotifyFunction:Close()
        end
    )

    return NotifyFunction
end


-- Close confirmation modal (module-level: avoids CreateWindow local limit)
local function setupCloseModal(closeBtn, main, screenGui)
    local overlay = Instance.new("Frame")
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.ZIndex = 50
    overlay.Active = true
    overlay.Visible = false
    overlay.Parent = main
    local dialog = Instance.new("Frame")
    dialog.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    dialog.BorderSizePixel = 0
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.Size = UDim2.new(0, 300, 0, 155)
    dialog.ZIndex = 51
    dialog.Parent = overlay
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(0, 10)
    dc.Parent = dialog
    local ds = Instance.new("UIStroke")
    ds.Color = Color3.fromRGB(150, 150, 170)
    ds.Thickness = 1.5
    ds.Parent = dialog
    local dt = Instance.new("TextLabel")
    dt.Font = Enum.Font.GothamBold
    dt.Text = "Close Window"
    dt.TextColor3 = Color3.fromRGB(255, 255, 255)
    dt.TextSize = 24
    dt.BackgroundTransparency = 1
    dt.Size = UDim2.new(1, 0, 0, 36)
    dt.Position = UDim2.new(0, 0, 0, 10)
    dt.TextXAlignment = Enum.TextXAlignment.Center
    dt.ZIndex = 52
    dt.Parent = dialog
    local body = Instance.new("TextLabel")
    body.Font = Enum.Font.Gotham
    body.Text = "Are you sure you want to close this window?"
    body.TextColor3 = Color3.fromRGB(150, 150, 170)
    body.TextSize = 15
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, -20, 0, 28)
    body.Position = UDim2.new(0, 10, 0, 52)
    body.TextXAlignment = Enum.TextXAlignment.Center
    body.TextWrapped = true
    body.ZIndex = 52
    body.Parent = dialog
    local sub = Instance.new("TextLabel")
    sub.Font = Enum.Font.Gotham
    sub.Text = "You will not be able to open it again"
    sub.TextColor3 = Color3.fromRGB(150, 150, 170)
    sub.TextSize = 15
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, -20, 0, 18)
    sub.Position = UDim2.new(0, 10, 0, 82)
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.ZIndex = 52
    sub.Parent = dialog
    local btnYes = Instance.new("TextButton")
    btnYes.Font = Enum.Font.GothamBold
    btnYes.Text = "Yes"
    btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnYes.TextSize = 14
    btnYes.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btnYes.BorderSizePixel = 0
    btnYes.Size = UDim2.new(0, 120, 0, 32)
    btnYes.Position = UDim2.new(0, 16, 1, -44)
    btnYes.ZIndex = 52
    btnYes.AutoButtonColor = false
    btnYes.Parent = dialog
    local yc = Instance.new("UICorner")
    yc.CornerRadius = UDim.new(0, 6)
    yc.Parent = btnYes
    local btnCancel = Instance.new("TextButton")
    btnCancel.Font = Enum.Font.GothamBold
    btnCancel.Text = "Cancel"
    btnCancel.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCancel.TextSize = 14
    btnCancel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btnCancel.BorderSizePixel = 0
    btnCancel.Size = UDim2.new(0, 120, 0, 32)
    btnCancel.Position = UDim2.new(1, -136, 1, -44)
    btnCancel.ZIndex = 52
    btnCancel.AutoButtonColor = false
    btnCancel.Parent = dialog
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = btnCancel
    btnCancel.Activated:Connect(function() overlay.Visible = false end)
    btnYes.Activated:Connect(function()
        for _, fn in pairs(Limbo._resetCallbacks) do
            pcall(fn)
        end
        task.wait(0.1)
        screenGui:Destroy()
    end)
    closeBtn.Activated:Connect(function()
        CircleClick(closeBtn, Mouse.X, Mouse.Y)
        overlay.Visible = true
    end)
end

function Limbo:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Limbo UI"
    local Theme = config.Theme or "Darker"
    local Size = config.Size or UDim2.fromOffset(470, 270)
    local Center = config.Center ~= false
    local Draggable = config.Draggable ~= false
    local Resizable = config.Resizable or config.Resize or false
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    if config.ConfigFolder then ConfigFolder = config.ConfigFolder end
    local MinimizeButton = config.MinimizeButton or false
    local MinimizeButtonImage = config.MinimizeButton_Image or "rbxassetid://16932740082"
    local Badges = config.Badges or {}
    local Icon = config.Icon or "rbxthumb://type=Asset&id=93432513909214&w=420&h=420"
    local TitleImage = config.TitleImage or ""
    local ConfigData = config.Config or {}
    local Watermark = config.Watermark or "https://raw.githubusercontent.com/aleyn6969/limbo/refs/heads/main/assets/limbo-watermark-v2.png"
    local WatermarkTransparency = config.WatermarkTransparency or 0.94
    local WatermarkSize = config.WatermarkSize or 285

    if ConfigSystem.ThemeColors[Theme] then
        ConfigSystem.CurrentTheme = Theme
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Name = "LimboUI"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = Size
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = ScreenGui
    DropShadowHolder.Visible = false

    if Center then
        DropShadowHolder.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    end

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    local Main = Instance.new("Frame")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BackgroundTransparency = 0.1
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Main

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(50, 50, 50)
    UIStroke.Thickness = 1.6
    UIStroke.Parent = Main

    -- Background image (customizable, shown only on selected theme)
    local BgImageId    = config.BackgroundImage       or "rbxthumb://type=Asset&id=93432513909214&w=420&h=420"
    local BgImageTheme = config.BackgroundImage_Theme or "Darker"

    local ImageWrapper = Instance.new("Frame")
    ImageWrapper.Name = "ImageWrapper"
    ImageWrapper.Size = UDim2.new(1, 0, 1, 0)
    ImageWrapper.Position = UDim2.new(0, 0, 0, 0)
    ImageWrapper.BackgroundTransparency = 1
    ImageWrapper.ClipsDescendants = true
    ImageWrapper.ZIndex = 0
    ImageWrapper.Parent = Main

    local ImageWrapperCorner = Instance.new("UICorner")
    ImageWrapperCorner.CornerRadius = UDim.new(0, 8)
    ImageWrapperCorner.Parent = ImageWrapper

    -- Resolve Watermark
    local WatermarkAsset = nil
    if typeof(Watermark) == "string" and Watermark ~= "" then
        if Watermark:match("^rbxasset") then
            WatermarkAsset = Watermark
        elseif Watermark:match("^https?://") then
            pcall(function()
                local assetPath = "LimboHUB/assets/.limbo_watermark.png"
                if makefolder and isfolder and not isfolder("LimboHUB") then makefolder("LimboHUB") end
                if makefolder and isfolder and not isfolder("LimboHUB/assets") then makefolder("LimboHUB/assets") end
                if isfile and not isfile(assetPath) then
                    local reqFn = (syn and syn.request) or (http and http.request) or request or http_request
                    local body = (game.HttpGet and game:HttpGet(Watermark)) or (reqFn and reqFn({Url = Watermark, Method = "GET"}).Body)
                    if body and writefile then writefile(assetPath, body) end
                end
                if getcustomasset and isfile and isfile(assetPath) then
                    WatermarkAsset = getcustomasset(assetPath)
                end
            end)
        end
    end

    if WatermarkAsset then
        local WMLabel = Instance.new("ImageLabel")
        WMLabel.Name = "Watermark"
        WMLabel.Size = UDim2.fromOffset(WatermarkSize, math.floor(WatermarkSize * 496 / 512 + 0.5))
        WMLabel.Position = UDim2.new(0.5, 0, 1, 7)
        WMLabel.AnchorPoint = Vector2.new(0.5, 1)
        WMLabel.BackgroundTransparency = 1
        WMLabel.Image = WatermarkAsset
        WMLabel.ImageTransparency = WatermarkTransparency
        WMLabel.ScaleType = Enum.ScaleType.Fit
        WMLabel.ZIndex = 0
        WMLabel.Parent = ImageWrapper
    end

    local ThemeImage = Instance.new("ImageLabel")
    ThemeImage.Name = "ThemeImage"
    ThemeImage.Size = UDim2.new(1, 0, 1, 0)
    ThemeImage.Position = UDim2.new(0, 0, 0, 0)
    ThemeImage.BackgroundTransparency = 1
    ThemeImage.ImageTransparency = 0.92
    ThemeImage.ScaleType = Enum.ScaleType.Crop
    ThemeImage.Image = BgImageId
    ThemeImage.ZIndex = 0
    ThemeImage.Visible = (ConfigSystem.CurrentTheme == BgImageTheme)
    ThemeImage.Parent = ImageWrapper


    table.insert(ConfigSystem.ThemeElements, {
        Update = function()
            ThemeImage.Visible = (ConfigSystem.CurrentTheme == BgImageTheme)
        end
    })

    local Top = Instance.new("Frame")
    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.999
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main

    local DecideFrame = Instance.new("Frame")
    DecideFrame.Name = "DecideFrame"
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.BackgroundTransparency = 0.85
    DecideFrame.Position = UDim2.new(0, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 1)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.ZIndex = 2
    DecideFrame.Parent = Main

    local TitleWrapper = Instance.new("Frame")
    TitleWrapper.BackgroundTransparency = 1
    TitleWrapper.AutomaticSize = Enum.AutomaticSize.X
    TitleWrapper.Size = UDim2.new(0, 0, 1, 0)
    TitleWrapper.Position = UDim2.new(0, 6, 0, 0)
    TitleWrapper.Parent = Top

    local TitleWrapLayout = Instance.new("UIListLayout")
    TitleWrapLayout.FillDirection = Enum.FillDirection.Horizontal
    TitleWrapLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TitleWrapLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TitleWrapLayout.Padding = UDim.new(0, 8)
    TitleWrapLayout.Parent = TitleWrapper

    -- Icon (optional)
    if Icon ~= "" then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Image = Icon
        IconImg.BackgroundTransparency = 1
        IconImg.Size = UDim2.new(0, 15, 0, 15)
        IconImg.LayoutOrder = 0
        IconImg.Parent = TitleWrapper
    end

    -- TitleImage (optional, replaces text title)
    if TitleImage ~= "" then
        local TitleImg = Instance.new("ImageLabel")
        TitleImg.Image = TitleImage
        TitleImg.BackgroundTransparency = 1
        -- FishIT is ~3:1 ratio, height matches top bar (~24px inner)
        TitleImg.Size = UDim2.new(0, 60, 0, 20)
        TitleImg.LayoutOrder = 1
        TitleImg.Parent = TitleWrapper

        local Sep = Instance.new("TextLabel")
        Sep.Font = Enum.Font.GothamBold
        Sep.Text = "|"
        Sep.TextColor3 = Color3.fromRGB(80, 80, 100)
        Sep.TextSize = 12
        Sep.AutomaticSize = Enum.AutomaticSize.X
        Sep.BackgroundTransparency = 1
        Sep.BorderSizePixel = 0
        Sep.Size = UDim2.new(0, 0, 0, 20)
        Sep.LayoutOrder = 2
        Sep.Parent = TitleWrapper
    end

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.Gotham
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    TitleLabel.TextSize = 14
    TitleLabel.AutomaticSize = Enum.AutomaticSize.X
    TitleLabel.BackgroundTransparency = 0.999
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Size = UDim2.new(0, 0, 1, 0)
    TitleLabel.LayoutOrder = TitleImage ~= "" and 3 or 1
    TitleLabel.Parent = TitleWrapper

    local Subtitle = config.Subtitle or ""
    if Subtitle ~= "" then
        local SubtitleLabel = Instance.new("TextLabel")
        SubtitleLabel.Font = Enum.Font.Gotham
        SubtitleLabel.Text = Subtitle
        SubtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
        SubtitleLabel.TextSize = 14
        SubtitleLabel.AutomaticSize = Enum.AutomaticSize.X
        SubtitleLabel.BackgroundTransparency = 0.999
        SubtitleLabel.BorderSizePixel = 0
        SubtitleLabel.Size = UDim2.new(0, 0, 1, 0)
        SubtitleLabel.LayoutOrder = 2
        SubtitleLabel.Parent = TitleWrapper
    end

    local BadgeContainer = Instance.new("Frame")
    BadgeContainer.Name = "BadgeContainer"
    BadgeContainer.AnchorPoint = Vector2.new(1, 0.5)
    BadgeContainer.BackgroundTransparency = 1
    BadgeContainer.Size = UDim2.new(0, 160, 1, 0)
    BadgeContainer.Position = UDim2.new(1, -77, 0.5, 0)
    BadgeContainer.Parent = Top

    local BadgeLayout = Instance.new("UIListLayout")
    BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
    BadgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BadgeLayout.Padding = UDim.new(0, 6)
    BadgeLayout.Parent = BadgeContainer

    for _, badgeText in ipairs(Badges) do
        local Badge = Instance.new("TextLabel")
        Badge.Name = "Badge"
        Badge.Font = Enum.Font.GothamBold
        Badge.Text = badgeText
        Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
        Badge.TextSize = 14
        Badge.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        Badge.BackgroundTransparency = 0.3
        Badge.BorderSizePixel = 0
        Badge.Size =
            UDim2.new(
            0,
            TextService:GetTextSize(badgeText, 14, Enum.Font.GothamBold, Vector2.new(999, 999)).X + 18,
            0,
            24
        )

        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(1, 0)
        BadgeCorner.Parent = Badge

        Badge.Parent = BadgeContainer

        table.insert(
            ConfigSystem.ThemeElements,
            {
                Update = function(color)
                    Badge.BackgroundColor3 = color
                end
            }
        )
    end

    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.999
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://9886659671"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseIcon.BackgroundTransparency = 0.999
    CloseIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseIcon.BorderSizePixel = 0
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(1, -8, 1, -8)
    CloseIcon.Parent = Close

    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.999
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -42, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = "rbxassetid://9886659276"
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinIcon.BackgroundTransparency = 0.999
    MinIcon.ImageTransparency = 0.2
    MinIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MinIcon.BorderSizePixel = 0
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.Size = UDim2.new(1, -9, 1, -9)
    MinIcon.Parent = Min



    local ResizeHandle = nil
    if Resizable then
        ResizeHandle = Instance.new("TextButton")
        ResizeHandle.Name = "ResizeHandle"
        ResizeHandle.Text = ""
        ResizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ResizeHandle.BackgroundTransparency = 1
        ResizeHandle.BorderSizePixel = 0
        ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
        ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
        ResizeHandle.AutoButtonColor = false
        ResizeHandle.Parent = Main

        local ResizeCorner = Instance.new("UICorner")
        ResizeCorner.CornerRadius = UDim.new(0, 3)
        ResizeCorner.Parent = ResizeHandle

        local ResizeIcon = Instance.new("ImageLabel")
        ResizeIcon.Name = "ResizeIcon"
        ResizeIcon.Image = "rbxassetid://76259878130194"
        ResizeIcon.BackgroundTransparency = 1
        ResizeIcon.AnchorPoint = Vector2.new(1, 1)
        ResizeIcon.Size = UDim2.new(0, 10, 0, 10)
        ResizeIcon.Position = UDim2.new(1, 0, 1, 0)
        ResizeIcon.Parent = ResizeHandle

        MakeResizable(
            ResizeHandle,
            DropShadowHolder,
            Vector2.new(250, 150),
            Vector2.new(1200, 900),
            function(newSize)
                Main.Size = UDim2.new(1, -47, 1, -47)
            end
        )
    end

    local TabFrame = Instance.new("Frame")
    TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabFrame.BackgroundTransparency = 0.999
    TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabFrame.BorderSizePixel = 0
    TabFrame.Position = UDim2.new(0, 9, 0, 39)
    TabFrame.Size = UDim2.new(0, 120, 1, -39)
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = Main

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 2)
    TabCorner.Parent = TabFrame

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.ScrollBarThickness = 0
    TabScroll.Active = true
    TabScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabScroll.BackgroundTransparency = 0.999
    TabScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.BorderSizePixel = 0
    TabScroll.Position = UDim2.new(0, 0, 0, 36)
    TabScroll.Size = UDim2.new(1, 0, 1, -86)
    TabScroll.Name = "TabScroll"
    TabScroll.Parent = TabFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    local TabTopPadding = Instance.new("UIPadding")
    TabTopPadding.PaddingTop = UDim.new(0, 4)
    TabTopPadding.Parent = TabScroll

    -- Search bar
    local SearchBar = Instance.new("Frame")
    SearchBar.Name = "SearchBar"
    SearchBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBar.BackgroundTransparency = 0.93
    SearchBar.BorderSizePixel = 0
    SearchBar.Position = UDim2.new(0, 0, 0, 6)
    SearchBar.Size = UDim2.new(1, 0, 0, 30)
    SearchBar.ZIndex = 20
    SearchBar.Active = true
    SearchBar.Parent = TabFrame

    local SearchBarCorner = Instance.new("UICorner")
    SearchBarCorner.CornerRadius = UDim.new(0, 4)
    SearchBarCorner.Parent = SearchBar

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Image = "rbxassetid://109869955247116"
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 5, 0.5, 0)
    SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.ZIndex = 22
    SearchIcon.Parent = SearchBar

    local SearchTextBox = Instance.new("TextBox")
    SearchTextBox.Font = Enum.Font.Gotham
    SearchTextBox.PlaceholderText = "Search Features..."
    SearchTextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    SearchTextBox.Text = ""
    SearchTextBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    SearchTextBox.TextSize = 11
    SearchTextBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchTextBox.BackgroundTransparency = 1
    SearchTextBox.BorderSizePixel = 0
    SearchTextBox.Position = UDim2.new(0, 22, 0, 0)
    SearchTextBox.Size = UDim2.new(1, -24, 1, 0)
    SearchTextBox.ClearTextOnFocus = false
    SearchTextBox.ZIndex = 21
    SearchTextBox.Parent = SearchBar

    local SearchResults = Instance.new("ScrollingFrame")
    local SearchResultsLayout = nil  -- forward, assigned below
    SearchResults.Name = "SearchResults"
    SearchResults.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    SearchResults.BorderSizePixel = 0
    SearchResults.Position = UDim2.new(0, 9, 0, 75)
    SearchResults.Size = UDim2.new(0, 120, 0, 0)
    SearchResults.ScrollBarThickness = 2
    SearchResults.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 170)
    SearchResults.ClipsDescendants = true
    SearchResults.ZIndex = 50
    SearchResults.Visible = false
    SearchResults.CanvasSize = UDim2.new(0, 0, 0, 0)
    SearchResults.Parent = Main

    local SearchResultsCorner = Instance.new("UICorner")
    SearchResultsCorner.CornerRadius = UDim.new(0, 4)
    SearchResultsCorner.Parent = SearchResults

    SearchResultsLayout = Instance.new("UIListLayout")
    SearchResultsLayout.Padding = UDim.new(0, 2)
    SearchResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SearchResultsLayout.Parent = SearchResults

    SearchResultsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SearchResults.CanvasSize = UDim2.new(0, 0, 0, SearchResultsLayout.AbsoluteContentSize.Y + 4)
    end)

    local searchResultsOpen = false
    local NoResultsLabel = nil
    local SearchSections = {}
    local TabContents = {}
    local TabSwitchFns = {}
    local ContentScroll = nil
    -- helper: sum Size.Y.Offset of children above stopAt (reliable, no render needed)
    local function sumChildH(container, stopAt)
        local y = 0
        for _, ch in ipairs(container:GetChildren()) do
            if ch == stopAt then break end
            if ch:IsA("Frame") then y = y + ch.Size.Y.Offset + 8 end
        end
        return y
    end

    local function flashElem(elem)
        task.spawn(function()
            local s = Instance.new("UIStroke")
            s.Color = Color3.fromRGB(180, 180, 210)
            s.Thickness = 2.5
            s.Transparency = 0
            s.Parent = elem
            task.wait(0.8)
            if s and s.Parent then s:Destroy() end
        end)
    end

    local function closeSearchResults()
        searchResultsOpen = false
        SearchResults.Visible = false
        for _, child in ipairs(SearchResults:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        if NoResultsLabel then NoResultsLabel.Visible = false end
    end

    local function buildSearchResults(query)
        if not NoResultsLabel then return end
        -- fresh destroy old buttons
        for _, child in ipairs(SearchResults:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        NoResultsLabel.Visible = false

        if query == "" then
            closeSearchResults()
            return
        end

        local q = string.lower(query)
        local found = 0

        for _, sec in ipairs(SearchSections) do
            pcall(function()
                local inner = sec.secFrame and sec.secFrame:FindFirstChild("InnerContainer")
                if not inner then return end
                for _, elem in ipairs(inner:GetChildren()) do
                    for _, lname in ipairs({"ToggleTitle","ButtonTitle","InputTitle","DropdownTitle","SliderTitle","ParagraphTitle"}) do
                        local lbl = elem:FindFirstChild(lname)
                        if lbl and lbl.Text and lbl.Text ~= "" then
                            if string.find(string.lower(lbl.Text), q, 1, true) then
                                found = found + 1
                                local displayText = lbl.Text
                                local subtitleText = (sec.tabName or "") .. " \xE2\x80\xA2 " .. (sec.title or "")
                                local capSec = sec
                                local capElem = elem

                                local Item = Instance.new("TextButton", SearchResults)
                                Item.Font = Enum.Font.GothamBold
                                Item.Text = ""
                                Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Item.BackgroundTransparency = 0.92
                                Item.BorderSizePixel = 0
                                Item.Size = UDim2.new(1, 0, 0, 40)
                                Item.ZIndex = 51
                                Item.AutoButtonColor = true
                                Item.Visible = true
                                Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 3)

                                -- pill indicator left
                                local Pill = Instance.new("Frame", Item)
                                Pill.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
                                Pill.BorderSizePixel = 0
                                Pill.Position = UDim2.new(0, 0, 0.1, 0)
                                Pill.Size = UDim2.new(0, 2, 0.8, 0)
                                Pill.ZIndex = 52
                                Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

                                -- main text
                                local MainLabel = Instance.new("TextLabel", Item)
                                MainLabel.Font = Enum.Font.GothamBold
                                MainLabel.Text = displayText
                                MainLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                                MainLabel.TextSize = 13
                                MainLabel.TextXAlignment = Enum.TextXAlignment.Left
                                MainLabel.TextTruncate = Enum.TextTruncate.AtEnd
                                MainLabel.BackgroundTransparency = 1
                                MainLabel.BorderSizePixel = 0
                                MainLabel.Position = UDim2.new(0, 8, 0, 4)
                                MainLabel.Size = UDim2.new(1, -10, 0, 16)
                                MainLabel.ZIndex = 52

                                -- subtitle
                                local SubLabel = Instance.new("TextLabel", Item)
                                SubLabel.Font = Enum.Font.Gotham
                                SubLabel.Text = subtitleText
                                SubLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
                                SubLabel.TextSize = 9
                                SubLabel.TextXAlignment = Enum.TextXAlignment.Left
                                SubLabel.TextTruncate = Enum.TextTruncate.AtEnd
                                SubLabel.BackgroundTransparency = 1
                                SubLabel.BorderSizePixel = 0
                                SubLabel.Position = UDim2.new(0, 8, 0, 22)
                                SubLabel.Size = UDim2.new(1, -10, 0, 12)
                                SubLabel.ZIndex = 52

                                Item.MouseButton1Click:Connect(function()
                                    task.spawn(function()
                                        local sf = TabSwitchFns[capSec.tabName]
                                        if sf then pcall(sf) end
                                        pcall(capSec.openFn)
                                        task.wait(0.2)
                                        -- reliable scroll: sum child heights
                                        local cont = TabContents[capSec.tabName]
                                        local inner3 = capSec.secFrame and capSec.secFrame:FindFirstChild("InnerContainer")
                                        local secOffset = cont and sumChildH(cont, capSec.secFrame) or 0
                                        local elemOffset = inner3 and sumChildH(inner3, capElem) or 0
                                        local scrollTo = secOffset + 34 + elemOffset
                                        ContentScroll.CanvasPosition = Vector2.new(0, scrollTo)
                                        flashElem(capElem)
                                    end)
                                    SearchTextBox.Text = ""
                                    closeSearchResults()
                                end)
                            end
                            break
                        end
                    end
                end
            end)
        end

        -- second pass: scan elements directly in tabs (outside collapsibles)
        for tabName, container in pairs(TabContents or {}) do
            for _, elem in ipairs(container:GetChildren()) do
                if elem.Name ~= "Collapsible" then
                    for _, lname in ipairs({"ToggleTitle","ButtonTitle","InputTitle","DropdownTitle","SliderTitle","ParagraphTitle"}) do
                        local lbl = elem:FindFirstChild(lname)
                        if lbl and lbl.Text and lbl.Text ~= "" then
                            if string.find(string.lower(lbl.Text), q, 1, true) then
                                found = found + 1
                                local displayText = lbl.Text
                                local subtitleText = tabName .. " \xE2\x80\xA2 " .. tabName
                                local capTab = tabName
                                local capElem = elem

                                local Item = Instance.new("TextButton", SearchResults)
                                Item.Font = Enum.Font.GothamBold
                                Item.Text = ""
                                Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Item.BackgroundTransparency = 0.92
                                Item.BorderSizePixel = 0
                                Item.Size = UDim2.new(1, 0, 0, 40)
                                Item.ZIndex = 51
                                Item.AutoButtonColor = true
                                Item.Visible = true
                                Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 3)
                                local Pill2 = Instance.new("Frame", Item)
                                Pill2.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
                                Pill2.BorderSizePixel = 0
                                Pill2.Position = UDim2.new(0, 0, 0.1, 0)
                                Pill2.Size = UDim2.new(0, 2, 0.8, 0)
                                Pill2.ZIndex = 52
                                Instance.new("UICorner", Pill2).CornerRadius = UDim.new(1, 0)
                                local ML2 = Instance.new("TextLabel", Item)
                                ML2.Font = Enum.Font.GothamBold
                                ML2.Text = displayText
                                ML2.TextColor3 = Color3.fromRGB(220, 220, 220)
                                ML2.TextSize = 13
                                ML2.TextXAlignment = Enum.TextXAlignment.Left
                                ML2.TextTruncate = Enum.TextTruncate.AtEnd
                                ML2.BackgroundTransparency = 1
                                ML2.BorderSizePixel = 0
                                ML2.Position = UDim2.new(0, 8, 0, 4)
                                ML2.Size = UDim2.new(1, -10, 0, 16)
                                ML2.ZIndex = 52
                                local SL2 = Instance.new("TextLabel", Item)
                                SL2.Font = Enum.Font.Gotham
                                SL2.Text = subtitleText
                                SL2.TextColor3 = Color3.fromRGB(120, 120, 140)
                                SL2.TextSize = 9
                                SL2.TextXAlignment = Enum.TextXAlignment.Left
                                SL2.TextTruncate = Enum.TextTruncate.AtEnd
                                SL2.BackgroundTransparency = 1
                                SL2.BorderSizePixel = 0
                                SL2.Position = UDim2.new(0, 8, 0, 22)
                                SL2.Size = UDim2.new(1, -10, 0, 12)
                                SL2.ZIndex = 52
                                Item.MouseButton1Click:Connect(function()
                                    task.spawn(function()
                                        local sf = TabSwitchFns[capTab]
                                        if sf then pcall(sf) end
                                        task.wait(0.2)
                                        local cont = TabContents[capTab]
                                        local scrollTo = cont and sumChildH(cont, capElem) or 0
                                        ContentScroll.CanvasPosition = Vector2.new(0, scrollTo)
                                        flashElem(capElem)
                                    end)
                                    SearchTextBox.Text = ""
                                    closeSearchResults()
                                end)
                            end
                            break
                        end
                    end
                end
            end
        end

        if found == 0 then
            NoResultsLabel.Visible = true
        end

        -- defer so UIListLayout computes AbsoluteContentSize after items added
        task.defer(function()
            local contentH = SearchResultsLayout.AbsoluteContentSize.Y + 4
            if found == 0 then contentH = 30 end
            local targetH = math.max(30, math.min(contentH, 150))
            SearchResults.CanvasSize = UDim2.new(0, 0, 0, contentH)
            SearchResults.Size = UDim2.new(0, 120, 0, targetH)
            SearchResults.Visible = true
            searchResultsOpen = true
        end)
    end


    -- NoResults label (hidden by default)
    NoResultsLabel = Instance.new("TextLabel", SearchResults)
    NoResultsLabel.Name = "NoResults"
    NoResultsLabel.Text = "  No results"
    NoResultsLabel.Font = Enum.Font.Gotham
    NoResultsLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
    NoResultsLabel.TextSize = 11
    NoResultsLabel.TextXAlignment = Enum.TextXAlignment.Left
    NoResultsLabel.BackgroundTransparency = 1
    NoResultsLabel.BorderSizePixel = 0
    NoResultsLabel.Size = UDim2.new(1, 0, 0, 26)
    NoResultsLabel.ZIndex = 51
    NoResultsLabel.Visible = false

    pcall(function()
        SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
            buildSearchResults(SearchTextBox.Text)
        end)
    end)

    -- polling backup (for executors where GetPropertyChangedSignal fails)
    local _lastTxt = ""
    task.spawn(function()
        while true do
            task.wait(0.1)
            if not SearchTextBox or not SearchTextBox.Parent then break end
            local t = SearchTextBox.Text
            if t ~= _lastTxt then
                _lastTxt = t
                pcall(buildSearchResults, t)
            end
        end
    end)

    SearchTextBox.FocusLost:Connect(function()
        if SearchTextBox.Text == "" then closeSearchResults() end
    end)

    -- Player footer
    local PlayerFooter = Instance.new("Frame")
    PlayerFooter.Name = "PlayerFooter"
    PlayerFooter.BackgroundTransparency = 1
    PlayerFooter.Position = UDim2.new(0, 0, 1, -46)
    PlayerFooter.Size = UDim2.new(1, 0, 0, 42)
    PlayerFooter.BorderSizePixel = 0
    PlayerFooter.Parent = TabFrame

    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Position = UDim2.new(0, 5, 0.5, 0)
    AvatarContainer.AnchorPoint = Vector2.new(0, 0.5)
    AvatarContainer.Size = UDim2.new(0, 32, 0, 32)
    AvatarContainer.BorderSizePixel = 0
    AvatarContainer.Parent = PlayerFooter

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.Image = "rbxassetid://0"
    AvatarImg.Parent = AvatarContainer

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImg

    local AvatarStroke = Instance.new("UIStroke")
    AvatarStroke.Color = Color3.fromRGB(120, 120, 135)
    AvatarStroke.Thickness = 1.5
    AvatarStroke.Transparency = 0.2
    AvatarStroke.Parent = AvatarImg

    pcall(function()
        local lp = Players.LocalPlayer
        local content, isReady = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then AvatarImg.Image = content end
    end)

    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Name = "WelcomeLabel"
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 43, 0.5, -8)
    WelcomeLabel.AnchorPoint = Vector2.new(0, 0)
    WelcomeLabel.Size = UDim2.new(1, -47, 0, 13)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
    WelcomeLabel.TextSize = 11
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextWrapped = false
    WelcomeLabel.Text = "Welcome,"
    WelcomeLabel.Visible = false
    WelcomeLabel.Parent = PlayerFooter

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Position = UDim2.new(0, 43, 0.5, 0)
    UsernameLabel.AnchorPoint = Vector2.new(0, 0.5)
    UsernameLabel.Size = UDim2.new(1, -47, 0, 13)
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
    UsernameLabel.TextSize = 11
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextWrapped = false
    UsernameLabel.Text = "usr***"
    UsernameLabel.Parent = PlayerFooter

    local maskedName = "usr***"
    pcall(function()
        local rawName = tostring(Players.LocalPlayer.Name)
        maskedName = string.sub(rawName, 1, 3) .. "***"
        UsernameLabel.Text = maskedName
    end)

    -- Dynamic footer: 1 line when small, 2 lines when large
    local function UpdateFooterLayout()
        local h = Main.AbsoluteSize.Y
        if h > 300 then
            -- 2 labels
            WelcomeLabel.Visible = true
            WelcomeLabel.Position = UDim2.new(0, 43, 0.5, -8)
            UsernameLabel.Position = UDim2.new(0, 43, 0.5, 3)
            UsernameLabel.AnchorPoint = Vector2.new(0, 0)
            UsernameLabel.Text = maskedName
        else
            -- 1 label: "Welcome, usr***"
            WelcomeLabel.Visible = false
            UsernameLabel.Position = UDim2.new(0, 43, 0.5, 0)
            UsernameLabel.AnchorPoint = Vector2.new(0, 0.5)
            UsernameLabel.Text = "Welcome, " .. maskedName
        end
    end

    Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateFooterLayout)
    task.defer(UpdateFooterLayout)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentFrame.BackgroundTransparency = 0.999
    ContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 138, 0, 39)
    ContentFrame.Size = UDim2.new(1, -147, 1, -39)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = Main

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 2)
    ContentCorner.Parent = ContentFrame

    ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ContentScroll.ScrollBarThickness = 0
    ContentScroll.Active = true
    ContentScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentScroll.BackgroundTransparency = 0.999
    ContentScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ClipsDescendants = true
    ContentScroll.Position = UDim2.new(0, 0, 0, 6)
    ContentScroll.Size = UDim2.new(1, 0, 1, -6)
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Parent = ContentFrame



    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentScroll

    TabContents = {}
    local CurrentTab = nil
    local TabCount = 0
    local AllElements = {}
    TabSwitchFns = {}

    local function UpdateTabSize()
        local OffsetY = 0
        for _, child in TabScroll:GetChildren() do
            if child:IsA("Frame") then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end

    local function UpdateContentSize()
        if CurrentTab and TabContents[CurrentTab] then
            local OffsetY = 0
            for _, child in TabContents[CurrentTab]:GetChildren() do
                if child:IsA("Frame") then
                    OffsetY = OffsetY + 8 + child.Size.Y.Offset
                end
            end
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
        end
    end

    TabScroll.ChildAdded:Connect(UpdateTabSize)
    TabScroll.ChildRemoved:Connect(UpdateTabSize)

    setupCloseModal(Close, Main, ScreenGui)

    Min.Activated:Connect(
        function()
            CircleClick(Min, Mouse.X, Mouse.Y)
            DropShadowHolder.Visible = false
        end
    )

    UserInputService.InputBegan:Connect(
        function(input)
            if input.KeyCode == MinimizeKey then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end
    )

    if Draggable then
        MakeDraggable(Top, DropShadowHolder)
    end

    local MobileMinimizeButton = nil
    if MinimizeButton then
        MobileMinimizeButton = Instance.new("Frame")
        MobileMinimizeButton.Name = "MobileMinimizeButton"
        MobileMinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        MobileMinimizeButton.BackgroundTransparency = 0.2
        MobileMinimizeButton.BorderSizePixel = 0
        MobileMinimizeButton.Size = UDim2.new(0, 50, 0, 50)
        MobileMinimizeButton.Position = UDim2.new(0, 20, 0, 100)
        MobileMinimizeButton.ZIndex = 100
        MobileMinimizeButton.Parent = ScreenGui

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(1, 0)
        ButtonCorner.Parent = MobileMinimizeButton

        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ButtonStroke.Thickness = 0
        ButtonStroke.Parent = MobileMinimizeButton

        local ButtonImage = Instance.new("ImageLabel")
        ButtonImage.Name = "ButtonImage"
        ButtonImage.Image = MinimizeButtonImage
        ButtonImage.BackgroundTransparency = 1
        ButtonImage.Size = UDim2.new(0.7, 0, 0.7, 0)
        ButtonImage.Position = UDim2.new(0.15, 0, 0.15, 0)
        ButtonImage.ZIndex = 101
        ButtonImage.Parent = MobileMinimizeButton

        local ClickDetector = Instance.new("TextButton")
        ClickDetector.Name = "ClickDetector"
        ClickDetector.Text = ""
        ClickDetector.BackgroundTransparency = 1
        ClickDetector.Size = UDim2.new(1, 0, 1, 0)
        ClickDetector.ZIndex = 102
        ClickDetector.Parent = MobileMinimizeButton

        local isDragging = MakeDraggableMobileButton(ClickDetector, MobileMinimizeButton, ScreenGui)

        local lastClick = 0
        ClickDetector.Activated:Connect(
            function()
                local now = workspace.DistributedGameTime
                if now - lastClick < 0.3 then
                    return
                end
                lastClick = now

                if not isDragging() then
                    DropShadowHolder.Visible = not DropShadowHolder.Visible

                    TweenService:Create(MobileMinimizeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)}):Play(

                    )
                    task.wait(0.1)
                    TweenService:Create(MobileMinimizeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 50, 0, 50)}):Play(

                    )
                end
            end
        )

        table.insert(
            ConfigSystem.ThemeElements,
            {
                Update = function(color)
                    ButtonStroke.Color = color
                end
            }
        )
    end

    -- Floating toggle button (open/close UI)
    local ToggleButtonEnabled = config.ToggleButton or false
    local ToggleButtonImage   = config.ToggleButton_Image or "rbxassetid://121365062523142"

    if ToggleButtonEnabled then
        local ToggleBtn = Instance.new("Frame")
        ToggleBtn.Name = "LimboToggleButton"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ToggleBtn.BackgroundTransparency = 0.15
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
        ToggleBtn.Position = UDim2.new(0, 15, 0.5, -100)
        ToggleBtn.ZIndex = 100
        ToggleBtn.Parent = ScreenGui

        local TBCorner = Instance.new("UICorner")
        TBCorner.CornerRadius = UDim.new(0, 10)
        TBCorner.Parent = ToggleBtn

        local TBImg = Instance.new("ImageLabel")
        TBImg.Image = ToggleButtonImage
        TBImg.BackgroundTransparency = 1
        TBImg.Size = UDim2.new(1, 0, 1, 0)
        TBImg.Position = UDim2.new(0, 0, 0, 0)
        TBImg.ScaleType = Enum.ScaleType.Fit
        TBImg.ZIndex = 101
        TBImg.Active = false      -- jangan intercept input
        TBImg.Parent = ToggleBtn

        local TBSurface = Instance.new("Frame", ToggleBtn)
        TBSurface.BackgroundTransparency = 1
        TBSurface.Size = UDim2.new(1, 0, 1, 0)
        TBSurface.ZIndex = 102
        TBSurface.Active = true

        -- Drag logic via UserInputService (bukan element.InputChanged)
        -- -> mouse capture tidak putus saat cursor keluar element
        local tbDragging = false
        local tbDragged = false
        local tbDragStart = nil
        local tbStartPos = nil
        local tbClickStart = nil

        pcall(function() TBSurface.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                tbDragging = true
                tbDragged = false
                tbClickStart = input.Position
                tbDragStart = input.Position
                tbStartPos = Vector2.new(ToggleBtn.AbsolutePosition.X, ToggleBtn.AbsolutePosition.Y)
            end
        end) end)

        pcall(function() UserInputService.InputChanged:Connect(function(input)
            if not tbDragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and
               input.UserInputType ~= Enum.UserInputType.Touch then return end
            if not tbDragged and tbClickStart and (input.Position - tbClickStart).Magnitude > 5 then
                tbDragged = true
            end
            if tbDragged and tbDragStart and tbStartPos then
                local delta = input.Position - tbDragStart
                local ss = ScreenGui.AbsoluteSize
                local bs = ToggleBtn.AbsoluteSize
                local pad = 10
                ToggleBtn.Position = UDim2.new(0,
                    math.clamp(tbStartPos.X + delta.X, pad, ss.X - bs.X - pad),
                    0,
                    math.clamp(tbStartPos.Y + delta.Y, pad, ss.Y - bs.Y - pad)
                )
            end
        end) end)

        pcall(function() TBSurface.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                if tbDragging then
                    tbDragging = false
                    if not tbDragged then
                        DropShadowHolder.Visible = not DropShadowHolder.Visible
                    end
                    tbDragged = false
                end
            end
        end) end)

        pcall(function() UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tbDragging = false
            end
        end) end)
    end

    -- Element Creation Functions
    local function CreateParagraph(tabContainer, title, content)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Paragraph = Instance.new("Frame")
        Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Paragraph.BackgroundTransparency = 0.935
        Paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Paragraph.BorderSizePixel = 0
        Paragraph.Size = UDim2.new(1, 0, 0, 46)
        Paragraph.Name = "Paragraph"
        Paragraph.Parent = tabContainer

        local ParagraphCorner = Instance.new("UICorner")
        ParagraphCorner.CornerRadius = UDim.new(0, 4)
        ParagraphCorner.Parent = Paragraph

        local ParagraphTitle = Instance.new("TextLabel")
        ParagraphTitle.Font = Enum.Font.GothamBold
        ParagraphTitle.Text = title
        ParagraphTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ParagraphTitle.TextSize = 14
        ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphTitle.BackgroundTransparency = 0.999
        ParagraphTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ParagraphTitle.BorderSizePixel = 0
        ParagraphTitle.Position = UDim2.new(0, 10, 0, 10)
        ParagraphTitle.Size = UDim2.new(1, -20, 0, 13)
        ParagraphTitle.Name = "ParagraphTitle"
        ParagraphTitle.Parent = Paragraph

        local ParagraphContent = Instance.new("TextLabel")
        ParagraphContent.Font = Enum.Font.GothamBold
        ParagraphContent.Text = content
        ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphContent.TextSize = 13
        ParagraphContent.TextTransparency = 0.6
        ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ParagraphContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphContent.BackgroundTransparency = 0.999
        ParagraphContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ParagraphContent.BorderSizePixel = 0
        ParagraphContent.Position = UDim2.new(0, 10, 0, 23)
        ParagraphContent.Name = "ParagraphContent"
        ParagraphContent.Parent = Paragraph

        local scrollWidth = ContentScroll.AbsoluteSize.X
        local textWidth = scrollWidth > 0 and (scrollWidth - 40) or 290
        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(textWidth, math.huge)
        )

        ParagraphContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        ParagraphContent.TextWrapped = true
        ParagraphContent.AutomaticSize = Enum.AutomaticSize.Y
        Paragraph.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 50))
        Paragraph.AutomaticSize = Enum.AutomaticSize.Y

        UpdateContentSize()

        return Paragraph
    end

    local function CreateButton(tabContainer, title, content, iconId, callback)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 46)
        Button.Name = "Button"
        Button.Parent = tabContainer

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = Button

        local ButtonTitle = Instance.new("TextLabel")
        ButtonTitle.Font = Enum.Font.GothamBold
        ButtonTitle.Text = title
        ButtonTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ButtonTitle.TextSize = 14
        ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
        ButtonTitle.TextYAlignment = Enum.TextYAlignment.Top
        ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonTitle.BackgroundTransparency = 0.999
        ButtonTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonTitle.BorderSizePixel = 0
        ButtonTitle.Position = UDim2.new(0, 10, 0, 10)
        ButtonTitle.Size = UDim2.new(1, -100, 0, 13)
        ButtonTitle.Name = "ButtonTitle"
        ButtonTitle.Parent = Button

        local ButtonContent = Instance.new("TextLabel")
        ButtonContent.Font = Enum.Font.GothamBold
        ButtonContent.Text = content
        ButtonContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.TextSize = 13
        ButtonContent.TextTransparency = 0.6
        ButtonContent.TextXAlignment = Enum.TextXAlignment.Left
        ButtonContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ButtonContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.BackgroundTransparency = 0.999
        ButtonContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonContent.BorderSizePixel = 0
        ButtonContent.Position = UDim2.new(0, 10, 0, 23)
        ButtonContent.Name = "ButtonContent"
        ButtonContent.Parent = Button

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        ButtonContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ButtonContent.TextWrapped = true
        Button.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ButtonButton = Instance.new("TextButton")
        ButtonButton.Font = Enum.Font.SourceSans
        ButtonButton.Text = ""
        ButtonButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.TextSize = 14
        ButtonButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BackgroundTransparency = 0.999
        ButtonButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BorderSizePixel = 0
        ButtonButton.Size = UDim2.new(1, 0, 1, 0)
        ButtonButton.Name = "ButtonButton"
        ButtonButton.Parent = Button

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BackgroundTransparency = 0.999
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -17, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 18, 0, 18)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Button

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = iconId or "rbxassetid://16932740082"
        FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
        FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        FeatureImg.BackgroundTransparency = 0.999
        FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        FeatureImg.Size = UDim2.new(1, 0, 1, 0)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = FeatureFrame

        ButtonButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(ButtonButton, Mouse.X, Mouse.Y)
                if callback then
                    callback()
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        return Button
    end

    local function CreateToggle(tabContainer, title, content, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Toggle = Instance.new("Frame")
        Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.BackgroundTransparency = 0.935
        Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        Toggle.Name = "Toggle"
        Toggle.Parent = tabContainer

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = Toggle

        local ToggleTitle = Instance.new("TextLabel")
        ToggleTitle.Font = Enum.Font.GothamBold
        ToggleTitle.Text = title
        ToggleTitle.TextSize = 14
        ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
        ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.BackgroundTransparency = 0.999
        ToggleTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleTitle.BorderSizePixel = 0
        ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
        ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
        ToggleTitle.Name = "ToggleTitle"
        ToggleTitle.Parent = Toggle

        local ToggleContent = Instance.new("TextLabel")
        ToggleContent.Font = Enum.Font.GothamBold
        ToggleContent.Text = content
        ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleContent.TextSize = 13
        ToggleContent.TextTransparency = 0.6
        ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
        ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ToggleContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleContent.BackgroundTransparency = 0.999
        ToggleContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleContent.BorderSizePixel = 0
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleContent.Size = UDim2.new(1, -100, 0, 12)
        ToggleContent.Name = "ToggleContent"
        ToggleContent.Parent = Toggle

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        ToggleContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ToggleContent.TextWrapped = true
        Toggle.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.TextSize = 14
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BackgroundTransparency = 0.999
        ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Size = UDim2.new(1, 0, 1, 0)
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        FeatureFrame.BackgroundTransparency = 0.2
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -10, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 36, 0, 18)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Toggle

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.Parent = FeatureFrame

        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        ToggleCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Position = defaultValue and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 1, 0.5, -7)
        ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
        ToggleCircle.Name = "ToggleCircle"
        ToggleCircle.Parent = FeatureFrame

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(0, 15)
        CircleCorner.Parent = ToggleCircle

        table.insert(ConfigSystem.ToggleElements, Toggle)

        local state = defaultValue or false
        local activeTweens = {}

        local function CancelToggleTweens()
            for i = 1, #activeTweens do
                local tween = activeTweens[i]
                if tween then
                    pcall(function() tween:Cancel() end)
                end
            end
            table.clear(activeTweens)
        end

        local function ApplyToggleVisual(value, animated)
            CancelToggleTweens()

            local themeColor = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            local titleProps
            local circleProps
            local frameProps

            if value then
                titleProps = {TextColor3 = themeColor}
                circleProps = {
                    Position = UDim2.new(1, -15, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                }
                frameProps = {
                    BackgroundColor3 = themeColor,
                    BackgroundTransparency = 0
                }
            else
                titleProps = {TextColor3 = Color3.fromRGB(230, 230, 230)}
                circleProps = {
                    Position = UDim2.new(0, 1, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                }
                frameProps = {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BackgroundTransparency = 0.2
                }
            end

            if animated then
                local tweenInfo = TweenInfo.new(
                    0.2,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.InOut
                )
                activeTweens[1] = TweenService:Create(ToggleTitle, tweenInfo, titleProps)
                activeTweens[2] = TweenService:Create(ToggleCircle, tweenInfo, circleProps)
                activeTweens[3] = TweenService:Create(FeatureFrame, tweenInfo, frameProps)

                for i = 1, #activeTweens do
                    activeTweens[i]:Play()
                end
            else
                for property, value2 in pairs(titleProps) do
                    ToggleTitle[property] = value2
                end
                for property, value2 in pairs(circleProps) do
                    ToggleCircle[property] = value2
                end
                for property, value2 in pairs(frameProps) do
                    FeatureFrame[property] = value2
                end
            end
        end

        local function SetState(value, fireCallback)
            state = value == true
            ApplyToggleVisual(state, fireCallback ~= false)
            if fireCallback ~= false and callback then
                callback(state)
            end
        end

        SetState(state, false)

        ToggleButton.Activated:Connect(
            function()
                CircleClick(ToggleButton, Mouse.X, Mouse.Y)
                SetState(not state)
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local toggleFunc = {
            Value = state,
            _live = function() return state end,
            Type = "Toggle",
            Id = elementId
        }

        function toggleFunc:Set(value)
            state = value
            local themeColor = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            pcall(function()
                if value then
                    ToggleTitle.TextColor3 = themeColor
                    ToggleCircle.Position = UDim2.new(1, -15, 0.5, -7)
                    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    FeatureFrame.BackgroundColor3 = themeColor
                    FeatureFrame.BackgroundTransparency = 0
                else
                    ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                    ToggleCircle.Position = UDim2.new(0, 1, 0.5, -7)
                    ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    FeatureFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    FeatureFrame.BackgroundTransparency = 0.2
                end
            end)
            if callback then pcall(callback, value) end
        end

        if elementId then
            AllElements[elementId] = toggleFunc
            table.insert(Limbo._resetCallbacks, function() toggleFunc.Set(false) end)
        end

        return toggleFunc
    end

    local function CreateInput(tabContainer, title, content, placeholder, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Input = Instance.new("Frame")
        Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Input.BackgroundTransparency = 0.935
        Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Input.BorderSizePixel = 0
        Input.Size = UDim2.new(1, 0, 0, 64)
        Input.Name = "Input"
        Input.Parent = tabContainer

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 4)
        InputCorner.Parent = Input

        local InputTitle = Instance.new("TextLabel")
        InputTitle.Font = Enum.Font.GothamBold
        InputTitle.Text = title
        InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        InputTitle.TextSize = 14
        InputTitle.TextXAlignment = Enum.TextXAlignment.Left
        InputTitle.BackgroundTransparency = 0.999
        InputTitle.BorderSizePixel = 0
        InputTitle.Position = UDim2.new(0, 8, 0, 6)
        InputTitle.Size = UDim2.new(1, -16, 0, 14)
        InputTitle.Name = "InputTitle"
        InputTitle.Parent = Input
        if content and content ~= "" then
            local InputContent = Instance.new("TextLabel")
            InputContent.Font = Enum.Font.Gotham
            InputContent.Text = content
            InputContent.TextColor3 = Color3.fromRGB(180, 180, 180)
            InputContent.TextTransparency = 0.3
            InputContent.TextSize = 11
            InputContent.TextXAlignment = Enum.TextXAlignment.Left
            InputContent.BackgroundTransparency = 0.999
            InputContent.BorderSizePixel = 0
            InputContent.Position = UDim2.new(0, 8, 0, 22)
            InputContent.Size = UDim2.new(1, -16, 0, 12)
            InputContent.Name = "InputContent"
            InputContent.Parent = Input
        end
        local InputFrame = Instance.new("Frame")
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.BorderSizePixel = 0
        InputFrame.ClipsDescendants = true
        InputFrame.AnchorPoint = Vector2.new(0, 0)
        InputFrame.Position = UDim2.new(0, 6, 0, 28)
        InputFrame.Size = UDim2.new(1, -12, 0, 30)
        InputFrame.Name = "InputFrame"
        InputFrame.Parent = Input

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = InputFrame

        local InputTextBox = Instance.new("TextBox")
        InputTextBox.ClearTextOnFocus = false
        InputTextBox.CursorPosition = -1
        InputTextBox.Font = Enum.Font.GothamBold
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputTextBox.PlaceholderText = placeholder or "Write your input there"
        InputTextBox.Text = ""
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 13
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
        InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.BackgroundTransparency = 0.999
        InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
        InputTextBox.Size = UDim2.new(1, -10, 1, -4)
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = InputFrame

        local inputFunc = {
            Value = "",
            Type = "Input",
            Id = elementId
        }

        function inputFunc:Set(value)
            InputTextBox.Text = value
            inputFunc.Value = value
            if callback then
                callback(value)
            end
        end

        InputTextBox.FocusLost:Connect(function()
            inputFunc:Set(InputTextBox.Text)
        end)

        task.wait(0.1)
        UpdateContentSize()

        if elementId then
            AllElements[elementId] = inputFunc
        end

        return inputFunc
    end
    
    local function CreateDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        local Dropdown = Instance.new("Frame")
        Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dropdown.BackgroundTransparency = 0.935
        Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Dropdown.BorderSizePixel = 0
        Dropdown.Size = UDim2.new(1, 0, 0, 46)
        Dropdown.Name = "Dropdown"
        Dropdown.Parent = tabContainer

        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 4)
        DropdownCorner.Parent = Dropdown

        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Font = Enum.Font.SourceSans
        DropdownButton.Text = ""
        DropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.TextSize = 14
        DropdownButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BackgroundTransparency = 0.999
        DropdownButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
        DropdownButton.ZIndex = 13
        DropdownButton.Name = "DropdownButton"
        DropdownButton.Parent = Dropdown

        local DropdownTitle = Instance.new("TextLabel")
        DropdownTitle.Font = Enum.Font.GothamBold
        DropdownTitle.Text = title
        DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        DropdownTitle.TextSize = 14
        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
        DropdownTitle.TextYAlignment = Enum.TextYAlignment.Top
        DropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DropdownTitle.BackgroundTransparency = 0.999
        DropdownTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownTitle.BorderSizePixel = 0
        DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
        DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
        DropdownTitle.Name = "DropdownTitle"
        DropdownTitle.Parent = Dropdown

        local DropdownContent = Instance.new("TextLabel")
        DropdownContent.Font = Enum.Font.GothamBold
        DropdownContent.Text = content
        DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownContent.TextSize = 13
        DropdownContent.TextTransparency = 0.6
        DropdownContent.TextWrapped = true
        DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
        DropdownContent.TextYAlignment = Enum.TextYAlignment.Bottom
        DropdownContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DropdownContent.BackgroundTransparency = 0.999
        DropdownContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownContent.BorderSizePixel = 0
        DropdownContent.Position = UDim2.new(0, 10, 0, 23)
        DropdownContent.Size = UDim2.new(1, -180, 0, 12)
        DropdownContent.Name = "DropdownContent"
        DropdownContent.Parent = Dropdown

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 200, math.huge)
        )

        DropdownContent.Size = UDim2.new(1, -180, 0, textSize.Y)
        DropdownContent.TextWrapped = true
        Dropdown.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local SelectOptionsFrame = Instance.new("Frame")
        SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
        SelectOptionsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SelectOptionsFrame.BackgroundTransparency = 0.95
        SelectOptionsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SelectOptionsFrame.BorderSizePixel = 0
        SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
        SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
        SelectOptionsFrame.Name = "SelectOptionsFrame"
        SelectOptionsFrame.Parent = Dropdown

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = SelectOptionsFrame

        local OptionSelecting = Instance.new("TextLabel")
        OptionSelecting.Font = Enum.Font.GothamBold
        OptionSelecting.Text = "Select Option"
        OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.TextSize = 13
        OptionSelecting.TextTransparency = 0.6
        OptionSelecting.TextWrapped = true
        OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
        OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
        OptionSelecting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.BackgroundTransparency = 0.999
        OptionSelecting.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionSelecting.BorderSizePixel = 0
        OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
        OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
        OptionSelecting.Name = "OptionSelecting"
        OptionSelecting.Parent = SelectOptionsFrame

        local OptionImg = Instance.new("ImageLabel")
        OptionImg.Image = "rbxassetid://16851841101"
        OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
        OptionImg.AnchorPoint = Vector2.new(1, 0.5)
        OptionImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionImg.BackgroundTransparency = 0.999
        OptionImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionImg.BorderSizePixel = 0
        OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
        OptionImg.Size = UDim2.new(0, 25, 0, 25)
        OptionImg.Name = "OptionImg"
        OptionImg.Parent = SelectOptionsFrame

        local DropdownList = Instance.new("Frame")
        DropdownList.AnchorPoint = Vector2.new(0, 0)
        DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownList.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownList.BorderSizePixel = 0
        DropdownList.Position = UDim2.new(1, -12, 0, 35)
        DropdownList.Size = UDim2.new(0, 160, 0, 0)
        DropdownList.Name = "DropdownList"
        DropdownList.Visible = false
        DropdownList.ClipsDescendants = true
        DropdownList.ZIndex = 10
        DropdownList.Parent = Main

        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 2)
        ListCorner.Parent = DropdownList

        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Color3.fromRGB(255, 255, 255)
        ListStroke.Thickness = 2.5
        ListStroke.Transparency = 0.8
        ListStroke.Parent = DropdownList

        local ListScroll = Instance.new("ScrollingFrame")
        ListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.ScrollBarThickness = 0
        ListScroll.Active = true
        ListScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ListScroll.BackgroundTransparency = 0.999
        ListScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.BorderSizePixel = 0
        ListScroll.Size = UDim2.new(1, -10, 1, -50)
        ListScroll.Position = UDim2.new(0, 5, 0, 40)
        ListScroll.Name = "ListScroll"
        ListScroll.ZIndex = 11
        ListScroll.Parent = DropdownList

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 3)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = ListScroll

        -- ====== SEARCH INPUT ======
        local SearchFrame = Instance.new("Frame")
        SearchFrame.BackgroundTransparency = 1
        SearchFrame.BorderSizePixel = 0
        SearchFrame.Size = UDim2.new(1, 0, 0, 34)
        SearchFrame.Position = UDim2.new(0, 0, 0, 0)
        SearchFrame.ZIndex = 12
        SearchFrame.Name = "SearchFrame"
        SearchFrame.Parent = DropdownList

        local SearchInput = Instance.new("TextBox")
        SearchInput.Font = Enum.Font.Gotham
        SearchInput.PlaceholderText = "Search..."
        SearchInput.Text = ""
        SearchInput.TextSize = 12
        SearchInput.TextColor3 = Color3.fromRGB(230, 230, 230)
        SearchInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        SearchInput.TextXAlignment = Enum.TextXAlignment.Center
        SearchInput.BackgroundTransparency = 1
        SearchInput.BorderSizePixel = 0
        SearchInput.Size = UDim2.new(1, -16, 1, -8)
        SearchInput.Position = UDim2.new(0, 10, 0, 4)
        SearchInput.ZIndex = 13
        SearchInput.ClearTextOnFocus = false
        SearchInput.MultiLine = false
        SearchInput.Name = "SearchInput"
        SearchInput.Parent = SearchFrame

        local function ResetSearch()
            SearchInput.Text = ""
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    child.Visible = true
                end
            end
        end

        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local query = SearchInput.Text:lower()
            local totalH = 0
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    local optText = child:FindFirstChild("OptionText")
                    local match = query == "" or (optText and optText.Text:lower():find(query, 1, true) ~= nil)
                    child.Visible = match
                    if match then totalH = totalH + child.Size.Y.Offset + 3 end
                end
            end
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, totalH)
        end)

        table.insert(ConfigSystem.DropdownElements, Dropdown)

        local dropdownData = {
            Options = options or {},
            Value = multi and (defaultValue or {}) or defaultValue or nil,
            Multi = multi ~= false and multi ~= nil,
            MaxSelect = type(multi) == "number" and multi or math.huge,
            Open = false,
            OptionFrames = {}
        }

        local function UpdateListSize()
            local totalHeight = 0
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    totalHeight = totalHeight + child.Size.Y.Offset + 3
                end
            end
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            DropdownList.Size = UDim2.new(0, 160, 0, math.min(150, totalHeight + 10))
        end

        local function UpdateSelectedDisplay()
            if dropdownData.Multi then
                if #dropdownData.Value > 0 then
                    local displayText = ""
                    for i, v in ipairs(dropdownData.Value) do
                        if i > 3 then
                            displayText = displayText .. ", ..."
                            break
                        end
                        displayText = displayText .. (i > 1 and ", " or "") .. v
                    end
                    OptionSelecting.Text = displayText
                else
                    OptionSelecting.Text = "Select Option"
                end
            else
                OptionSelecting.Text = dropdownData.Value or "Select Option"
            end
        end


        local csConn = nil
        local function ToggleDropdown()
            dropdownData.Open = not dropdownData.Open
            if dropdownData.Open then
                local cfW    = ContentFrame.AbsoluteSize.X
                local halfCF = math.floor(cfW / 2)
                local rightW = cfW - halfCF - 4
                local targetH = math.floor(Main.AbsoluteSize.Y - 16)
                DropdownList.Position = UDim2.new(0, 138 + halfCF + rightW, 0, 8)
                DropdownList.Size = UDim2.new(0, 0, 0, targetH)
                DropdownList.Visible = true
                TweenService:Create(DropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, rightW, 0, targetH),
                    Position = UDim2.new(0, 138 + halfCF, 0, 8)
                }):Play()
                -- Close any other open dropdown first
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end

                -- Stores close fn for this dropdown
                Limbo._activeDropdownClose = function()
                    if not dropdownData.Open then return end
                    dropdownData.Open = false
                    ResetSearch()
                    DropdownList.Visible = false
                    Limbo._activeDropdownClose = nil
                    if csConn then csConn:Disconnect(); csConn = nil end
                    local dOvr = Main:FindFirstChild("DropOverlay")
                    if dOvr then dOvr:Destroy() end
                end

                -- Transparent overlay: blocks other UI + auto-closes on tap
                local overlay = Instance.new("TextButton")
                    overlay.Name = "DropOverlay"
                    overlay.BackgroundTransparency = 1
                    overlay.BorderSizePixel = 0
                    overlay.Size = UDim2.new(1, 0, 1, 0)
                    overlay.ZIndex = 9
                    overlay.Text = ""
                    overlay.AutoButtonColor = false
                    overlay.Parent = Main
                    csConn = overlay.Activated:Connect(function()
                        if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                    end)


            else
                local cfW3 = ContentFrame.AbsoluteSize.X
                local halfCF3 = math.floor(cfW3 / 2)
                local rightW3 = cfW3 - halfCF3 - 4
                ResetSearch()
                Limbo._activeDropdownClose = nil
                TweenService:Create(DropdownList, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, DropdownList.Size.Y.Offset),
                    Position = UDim2.new(0, 138 + halfCF3 + rightW3, 0, 8)
                }):Play()
                task.delay(0.18, function()
                    DropdownList.Visible = false
                    if csConn then csConn:Disconnect(); csConn = nil end
                    local dOvr = Main:FindFirstChild("DropOverlay")
                    if dOvr then dOvr:Destroy() end
                end)
            end
        end

        local function CreateOption(optionName)
            local Option = Instance.new("Frame")
            Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Option.BackgroundTransparency = 0.999
            Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Option.BorderSizePixel = 0
            Option.Size = UDim2.new(1, 0, 0, 30)
            Option.Name = "Option"
            Option.ZIndex = 12
            Option.Parent = ListScroll

            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, 3)
            OptionCorner.Parent = Option

            local OptionButton = Instance.new("TextButton")
            OptionButton.Font = Enum.Font.GothamBold
            OptionButton.Text = ""
            OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.TextSize = 13
            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
            OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.BackgroundTransparency = 0.999
            OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            OptionButton.BorderSizePixel = 0
            OptionButton.Size = UDim2.new(1, 0, 1, 0)
            OptionButton.Name = "OptionButton"
            OptionButton.ZIndex = 13
            OptionButton.Parent = Option

            local OptionText = Instance.new("TextLabel")
            OptionText.Font = Enum.Font.GothamBold
            OptionText.Text = optionName
            OptionText.TextSize = 13
            OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
            OptionText.TextXAlignment = Enum.TextXAlignment.Left
            OptionText.TextYAlignment = Enum.TextYAlignment.Top
            OptionText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionText.BackgroundTransparency = 0.999
            OptionText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            OptionText.BorderSizePixel = 0
            OptionText.Position = UDim2.new(0, 8, 0, 8)
            OptionText.Size = UDim2.new(1, -16, 0, 13)
            OptionText.Name = "OptionText"
            OptionText.ZIndex = 14
            OptionText.Parent = Option

            local ChooseFrame = Instance.new("Frame")
            ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
            ChooseFrame.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
            ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.ZIndex = 15
            ChooseFrame.Parent = Option

            local ChooseStroke = Instance.new("UIStroke")
            ChooseStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            ChooseStroke.Thickness = 1.6
            ChooseStroke.Transparency = 0.999
            ChooseStroke.ZIndex = 16
            ChooseStroke.Parent = ChooseFrame

            local ChooseCorner = Instance.new("UICorner")
            ChooseCorner.Parent = ChooseFrame

            local optionId = HttpService:GenerateGUID(false)
            ConfigSystem.DropdownOptionFrames[optionId] = {
                Frame = Option,
                IsSelected = false
            }

            local function UpdateOptionVisual()
                local isSelected = false
                if dropdownData.Multi then
                    isSelected = table.find(dropdownData.Value, optionName) ~= nil
                else
                    isSelected = dropdownData.Value == optionName
                end

                ConfigSystem.DropdownOptionFrames[optionId].IsSelected = isSelected

                if isSelected then
                    TweenService:Create(ChooseStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
                    TweenService:Create(ChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, 12)}):Play()
                    TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundTransparency = 0.935}):Play()
                    TweenService:Create(
                        OptionText,
                        TweenInfo.new(0.2),
                        {TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]}
                    ):Play()
                else
                    TweenService:Create(ChooseStroke, TweenInfo.new(0.2), {Transparency = 0.999}):Play()
                    TweenService:Create(ChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play()
                    TweenService:Create(OptionText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play(

                    )
                end
            end

            OptionButton.Activated:Connect(
                function()
                    CircleClick(OptionButton, Mouse.X, Mouse.Y)

                    if dropdownData.Multi then
                        local index = table.find(dropdownData.Value, optionName)
                        if index then
                            table.remove(dropdownData.Value, index)
                        elseif #dropdownData.Value < dropdownData.MaxSelect then
                            table.insert(dropdownData.Value, optionName)
                        end
                        UpdateOptionVisual()
                    else
                        for _, child in ListScroll:GetChildren() do
                            if child:IsA("Frame") and child.Name == "Option" then
                                local childOptionText = child:FindFirstChild("OptionText")
                                if childOptionText and childOptionText.Text ~= optionName then
                                    local childChooseFrame = child:FindFirstChild("ChooseFrame")
                                    local childChooseStroke =
                                        childChooseFrame and childChooseFrame:FindFirstChild("UIStroke")

                                    if childChooseStroke then
                                        TweenService:Create(
                                            childChooseStroke,
                                            TweenInfo.new(0.2),
                                            {Transparency = 0.999}
                                        ):Play()
                                    end
                                    if childChooseFrame then
                                        TweenService:Create(
                                            childChooseFrame,
                                            TweenInfo.new(0.2),
                                            {Size = UDim2.new(0, 0, 0, 0)}
                                        ):Play()
                                    end
                                    TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play(

                                    )
                                    TweenService:Create(
                                        childOptionText,
                                        TweenInfo.new(0.2),
                                        {TextColor3 = Color3.fromRGB(230, 230, 230)}
                                    ):Play()

                                    for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                                        if data.Frame == child then
                                            data.IsSelected = false
                                        end
                                    end
                                end
                            end
                        end

                        dropdownData.Value = optionName
                        UpdateOptionVisual()
                    end

                    UpdateSelectedDisplay()

                    if callback then
                        callback(dropdownData.Value)
                    end
                end
            )

            UpdateOptionVisual()
            return Option
        end

        for _, option in ipairs(dropdownData.Options) do
            CreateOption(option)
        end

        UpdateListSize()
        UpdateSelectedDisplay()

        DropdownButton.Activated:Connect(
            function()
                CircleClick(DropdownButton, Mouse.X, Mouse.Y)
                ToggleDropdown()
            end
        )

        Dropdown.Destroying:Connect(
            function()
                for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                    if data.Frame and data.Frame:IsDescendantOf(DropdownList) then
                        ConfigSystem.DropdownOptionFrames[id] = nil
                    end
                end
                DropdownList:Destroy()
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local dropdownFunc = {
            Value = dropdownData.Value,
            _data = dropdownData,
            Options = dropdownData.Options,
            Type = "Dropdown",
            Id = elementId
        }

        function dropdownFunc:Set(value)
            if dropdownData.Multi then
                dropdownData.Value = value or {}
            else
                dropdownData.Value = value
            end
            UpdateSelectedDisplay()

            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    local optionName = child.OptionText.Text
                    local isSelected = false
                    if dropdownData.Multi then
                        isSelected = table.find(dropdownData.Value, optionName) ~= nil
                    else
                        isSelected = dropdownData.Value == optionName
                    end

                    local chooseFrame = child:FindFirstChild("ChooseFrame")
                    local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
                    local optionText = child:FindFirstChild("OptionText")

                    if chooseFrame and chooseStroke and optionText then
                        if isSelected then
                            TweenService:Create(chooseStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
                            TweenService:Create(chooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, 12)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.935}):Play()
                            TweenService:Create(
                                optionText,
                                TweenInfo.new(0.2),
                                {TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]}
                            ):Play()
                        else
                            TweenService:Create(chooseStroke, TweenInfo.new(0.2), {Transparency = 0.999}):Play()
                            TweenService:Create(chooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play()
                            TweenService:Create(
                                optionText,
                                TweenInfo.new(0.2),
                                {TextColor3 = Color3.fromRGB(230, 230, 230)}
                            ):Play()
                        end
                    end
                end
            end
            if callback then pcall(callback, dropdownData.Value) end
        end

        function dropdownFunc:Refresh(newOptions, newValue)
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                if data.Frame and data.Frame:IsDescendantOf(ListScroll) then
                    ConfigSystem.DropdownOptionFrames[id] = nil
                end
            end

            dropdownData.Options = newOptions or {}
            dropdownData.Value = newValue or (dropdownData.Multi and {} or nil)

            for _, option in ipairs(dropdownData.Options) do
                CreateOption(option)
            end

            UpdateListSize()
            UpdateSelectedDisplay()
            dropdownFunc.Value = dropdownData.Value
            dropdownFunc.Options = dropdownData.Options
        end

        if elementId then
            AllElements[elementId] = dropdownFunc
        end

        return dropdownFunc
    end
    
    local function CreateSlider(
        tabContainer,
        title,
        content,
        minValue,
        maxValue,
        defaultValue,
        callback,
        elementId,
        showKnob)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        showKnob = showKnob ~= false

        local Slider = Instance.new("Frame")
        Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Slider.BackgroundTransparency = 0.935
        Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Slider.BorderSizePixel = 0
        Slider.Size = UDim2.new(1, 0, 0, 46)
        Slider.Name = "Slider"
        Slider.Parent = tabContainer

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 4)
        SliderCorner.Parent = Slider

        local SliderTitle = Instance.new("TextLabel")
        SliderTitle.Font = Enum.Font.GothamBold
        SliderTitle.Text = title
        SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        SliderTitle.TextSize = 14
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
        SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.BackgroundTransparency = 0.999
        SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderTitle.BorderSizePixel = 0
        SliderTitle.Position = UDim2.new(0, 10, 0, 10)
        SliderTitle.Size = UDim2.new(1, -60, 0, 13)
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Parent = Slider

        local SliderContent = Instance.new("TextLabel")
        SliderContent.Font = Enum.Font.GothamBold
        SliderContent.Text = content
        SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.TextSize = 13
        SliderContent.TextTransparency = 0.6
        SliderContent.TextXAlignment = Enum.TextXAlignment.Left
        SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
        SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.BackgroundTransparency = 0.999
        SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderContent.BorderSizePixel = 0
        SliderContent.Position = UDim2.new(0, 10, 0, 23)
        SliderContent.Size = UDim2.new(1, -60, 0, 12)
        SliderContent.Name = "SliderContent"
        SliderContent.Parent = Slider

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 80, math.huge)
        )

        SliderContent.Size = UDim2.new(1, -60, 0, textSize.Y)
        SliderContent.TextWrapped = true

        local ValueDisplay = Instance.new("TextLabel")
        ValueDisplay.Font = Enum.Font.GothamBold
        ValueDisplay.Text = tostring(defaultValue or minValue)
        ValueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueDisplay.TextSize = 14
        ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        ValueDisplay.AnchorPoint = Vector2.new(1, 0)
        ValueDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ValueDisplay.BackgroundTransparency = 0.999
        ValueDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ValueDisplay.BorderSizePixel = 0
        ValueDisplay.Position = UDim2.new(1, -10, 0, 10)
        ValueDisplay.Size = UDim2.new(0, 40, 0, 13)
        ValueDisplay.Name = "ValueDisplay"
        ValueDisplay.Parent = Slider

        Slider.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33 + 25))

        local SliderFrame = Instance.new("Frame")
        SliderFrame.AnchorPoint = Vector2.new(0, 0)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SliderFrame.BackgroundTransparency = 0.5
        SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = UDim2.new(0, 10, 0, textSize.Y + 33)
        SliderFrame.Size = UDim2.new(1, -20, 0, 3)
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = Slider

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 2)
        FrameCorner.Parent = SliderFrame

        local SliderFill = Instance.new("Frame")
        SliderFill.AnchorPoint = Vector2.new(0, 0.5)
        SliderFill.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        SliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFill.BorderSizePixel = 0
        SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
        SliderFill.Size = UDim2.new(0.5, 0, 0, 3)
        SliderFill.Name = "SliderFill"
        SliderFill.Parent = SliderFrame

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 2)
        FillCorner.Parent = SliderFill

        local SliderCircle = nil
        if showKnob then
            SliderCircle = Instance.new("Frame")
            SliderCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderCircle.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SliderCircle.BorderSizePixel = 0
            SliderCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            SliderCircle.Size = UDim2.new(0, 12, 0, 12)
            SliderCircle.Name = "SliderCircle"
            SliderCircle.Parent = SliderFrame

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(0, 6)
            CircleCorner.Parent = SliderCircle

            local CircleStroke = Instance.new("UIStroke")
            CircleStroke.Color = Color3.fromRGB(255, 255, 255)
            CircleStroke.Thickness = 1
            CircleStroke.Parent = SliderCircle
        end

        table.insert(ConfigSystem.SliderElements, SliderFrame)

        local sliderData = {
            Min = minValue or 0,
            Max = maxValue or 100,
            Value = defaultValue or minValue or 0,
            Dragging = false,
            TouchInput = nil
        }

        local function Round(num, decimalPlaces)
            local mult = 10 ^ (decimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end

        local function SetValue(value, instant)
            value = math.clamp(value, sliderData.Min, sliderData.Max)
            sliderData.Value = Round(value, 0)

            ValueDisplay.Text = tostring(sliderData.Value)

            local percentage = (sliderData.Value - sliderData.Min) / (sliderData.Max - sliderData.Min)

            if instant then
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                if SliderCircle then
                    SliderCircle.Position = UDim2.new(percentage, 0, 0.5, 0)
                end
            else
                TweenService:Create(
                    SliderFill,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(percentage, 0, 1, 0)}
                ):Play()
                if SliderCircle then
                    TweenService:Create(
                        SliderCircle,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Position = UDim2.new(percentage, 0, 0.5, 0)}
                    ):Play()
                end
            end

            if callback then
                callback(sliderData.Value)
            end
        end

        local startValue = defaultValue or minValue or 0
        SetValue(startValue, true)

        local function UpdateSliderFromInput(input)
            local inputPos
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                inputPos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch then
                inputPos = input.Position
            else
                return
            end

            local sliderPos = SliderFrame.AbsolutePosition
            local sliderSize = SliderFrame.AbsoluteSize

            local percentage = math.clamp((inputPos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = sliderData.Min + (percentage * (sliderData.Max - sliderData.Min))

            SetValue(value)
        end

        SliderFrame.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    sliderData.Dragging = true
                    sliderData.TouchInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
                    UpdateSliderFromInput(input)
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)
                if
                    sliderData.Dragging and
                        (input.UserInputType == Enum.UserInputType.MouseMovement or
                            (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and
                                input == sliderData.TouchInput))
                 then
                    UpdateSliderFromInput(input)
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)
                if
                    (input.UserInputType == Enum.UserInputType.MouseButton1 and sliderData.Dragging) or
                        (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and
                            input == sliderData.TouchInput)
                 then
                    sliderData.Dragging = false
                    sliderData.TouchInput = nil
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local sliderFunc = {
            Value = sliderData.Value,
            _data = sliderData,
            _default = defaultValue,
            Type = "Slider",
            Id = elementId
        }

        function sliderFunc:Set(value)
            SetValue(value)
            sliderFunc.Value = sliderData.Value
        end

        if elementId then
            AllElements[elementId] = sliderFunc
        end

        return sliderFunc
    end
    
    local function CreateImageBox(tabContainer, title, content, imageId, size, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        
        local ImageBox = Instance.new("Frame")
        ImageBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBox.BackgroundTransparency = 0.935
        ImageBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBox.BorderSizePixel = 0
        ImageBox.Size = UDim2.new(1, 0, 0, 46)
        ImageBox.Name = "ImageBox"
        ImageBox.Parent = tabContainer

        local ImageBoxCorner = Instance.new("UICorner")
        ImageBoxCorner.CornerRadius = UDim.new(0, 4)
        ImageBoxCorner.Parent = ImageBox

        local ImageBoxTitle = Instance.new("TextLabel")
        ImageBoxTitle.Font = Enum.Font.GothamBold
        ImageBoxTitle.Text = title
        ImageBoxTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ImageBoxTitle.TextSize = 14
        ImageBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
        ImageBoxTitle.TextYAlignment = Enum.TextYAlignment.Top
        ImageBoxTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxTitle.BackgroundTransparency = 0.999
        ImageBoxTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBoxTitle.BorderSizePixel = 0
        ImageBoxTitle.Position = UDim2.new(0, 10, 0, 10)
        ImageBoxTitle.Size = UDim2.new(1, -20, 0, 13)
        ImageBoxTitle.Name = "ImageBoxTitle"
        ImageBoxTitle.Parent = ImageBox

        local ImageBoxContent = Instance.new("TextLabel")
        ImageBoxContent.Font = Enum.Font.GothamBold
        ImageBoxContent.Text = content
        ImageBoxContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxContent.TextSize = 13
        ImageBoxContent.TextTransparency = 0.6
        ImageBoxContent.TextXAlignment = Enum.TextXAlignment.Left
        ImageBoxContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ImageBoxContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxContent.BackgroundTransparency = 0.999
        ImageBoxContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBoxContent.BorderSizePixel = 0
        ImageBoxContent.Position = UDim2.new(0, 10, 0, 23)
        ImageBoxContent.Size = UDim2.new(1, -20, 0, 12)
        ImageBoxContent.Name = "ImageBoxContent"
        ImageBoxContent.Parent = ImageBox

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 40, math.huge)
        )
        ImageBoxContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        ImageBoxContent.TextWrapped = true

        local imageSize = size or UDim2.new(0, 100, 0, 100)
        local totalHeight = textSize.Y + 33 + imageSize.Y.Offset + 10

        ImageBox.Size = UDim2.new(1, 0, 0, math.max(46, totalHeight))

        local ImageContainer = Instance.new("Frame")
        ImageContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageContainer.BackgroundTransparency = 0.95
        ImageContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageContainer.BorderSizePixel = 0
        ImageContainer.Position = UDim2.new(0, 10, 0, textSize.Y + 33)
        ImageContainer.Size = imageSize
        ImageContainer.Name = "ImageContainer"
        ImageContainer.Parent = ImageBox

        local ContainerCorner = Instance.new("UICorner")
        ContainerCorner.CornerRadius = UDim.new(0, 4)
        ContainerCorner.Parent = ImageContainer

        local ImageDisplay = Instance.new("ImageLabel")
        ImageDisplay.Image = imageId or "rbxassetid://0"
        ImageDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageDisplay.BackgroundTransparency = 0.999
        ImageDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageDisplay.BorderSizePixel = 0
        ImageDisplay.Position = UDim2.new(0, 5, 0, 5)
        ImageDisplay.Size = UDim2.new(1, -10, 1, -10)
        ImageDisplay.Name = "ImageDisplay"
        ImageDisplay.Parent = ImageContainer

        local ImageButton = Instance.new("TextButton")
        ImageButton.Font = Enum.Font.SourceSans
        ImageButton.Text = ""
        ImageButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.TextSize = 14
        ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.BackgroundTransparency = 0.999
        ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.BorderSizePixel = 0
        ImageButton.Size = UDim2.new(1, 0, 1, 0)
        ImageButton.Name = "ImageButton"
        ImageButton.Parent = ImageBox

        ImageButton.Activated:Connect(
            function()
                CircleClick(ImageButton, Mouse.X, Mouse.Y)
                if callback then
                    callback(imageId)
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local imageBoxFunc = {
            ImageId = imageId,
            Type = "ImageBox",
            Id = elementId
        }

        function imageBoxFunc:SetImage(newImageId)
            ImageDisplay.Image = newImageId
            imageBoxFunc.ImageId = newImageId
        end

        function imageBoxFunc:SetSize(newSize)
            ImageContainer.Size = newSize
            local newTotalHeight = textSize.Y + 33 + newSize.Y.Offset + 10
            ImageBox.Size = UDim2.new(1, 0, 0, math.max(46, newTotalHeight))
            UpdateContentSize()
        end

        if elementId then
            AllElements[elementId] = imageBoxFunc
        end

        return imageBoxFunc
    end

    local function CreateTextHeader(tabContainer, title)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local header = Instance.new("TextLabel")
        header.BackgroundTransparency = 1
        header.BorderSizePixel = 0
        header.Position = UDim2.new(0, 0, 0, 0)
        header.Size = UDim2.new(1, 0, 0, 28)
        header.Font = Enum.Font.GothamBold
        header.Text = title or ""
        header.TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        header.TextSize = 15
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextYAlignment = Enum.TextYAlignment.Center
        header.Name = "TextHeader"
        header.Parent = tabContainer

        local headerPadding = Instance.new("UIPadding")
        headerPadding.PaddingLeft = UDim.new(0, 10)
        headerPadding.Parent = header

        table.insert(
            ConfigSystem.ThemeElements, 
            {
                Update = function(color)
                    if header and header.Parent then
                        header.TextColor3 = color
                    end
                end
            }
        )

        return header
    end

    -- FIXED: Renamed from CreateSection to CreateDivider
    local function CreateDivider(tabContainer, title)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        
        local Divider = Instance.new("Frame")
        Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Divider.BackgroundTransparency = 0.935
        Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(1, 0, 0, 40)
        Divider.Name = "Divider"
        Divider.Parent = tabContainer

        local DividerCorner = Instance.new("UICorner")
        DividerCorner.CornerRadius = UDim.new(0, 4)
        DividerCorner.Parent = Divider

        local DividerTitle = Instance.new("TextLabel")
        DividerTitle.Font = Enum.Font.GothamBold
        DividerTitle.Text = title
        DividerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        DividerTitle.TextSize = 14
        DividerTitle.TextXAlignment = Enum.TextXAlignment.Left
        DividerTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DividerTitle.BackgroundTransparency = 0.999
        DividerTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DividerTitle.BorderSizePixel = 0
        DividerTitle.Position = UDim2.new(0, 10, 0, 0)
        DividerTitle.Size = UDim2.new(1, -20, 0, 40)
        DividerTitle.Name = "DividerTitle"
        DividerTitle.Parent = Divider

        local DividerLine = Instance.new("Frame")
        DividerLine.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        DividerLine.BackgroundTransparency = 0.5
        DividerLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DividerLine.BorderSizePixel = 0
        DividerLine.Position = UDim2.new(0, 10, 0, 35)
        DividerLine.Size = UDim2.new(1, -20, 0, 2)
        DividerLine.Name = "DividerLine"
        DividerLine.Parent = Divider

        table.insert(
            ConfigSystem.ThemeElements,
            {
                Update = function(color)
                    DividerLine.BackgroundColor3 = color
                end
            }
        )

        task.wait(0.1)
        UpdateContentSize()

        return Divider
    end

    local function CreateColorPicker(tabContainer, title, content, defaultColor, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        defaultColor = defaultColor or Color3.fromRGB(255, 0, 0)

        local ColorPicker = Instance.new("Frame")
        ColorPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorPicker.BackgroundTransparency = 0.935
        ColorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPicker.BorderSizePixel = 0
        ColorPicker.Size = UDim2.new(1, 0, 0, 46)
        ColorPicker.Name = "ColorPicker"
        ColorPicker.Parent = tabContainer

        local ColorPickerCorner = Instance.new("UICorner")
        ColorPickerCorner.CornerRadius = UDim.new(0, 4)
        ColorPickerCorner.Parent = ColorPicker

        local ColorPickerTitle = Instance.new("TextLabel")
        ColorPickerTitle.Font = Enum.Font.GothamBold
        ColorPickerTitle.Text = title
        ColorPickerTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ColorPickerTitle.TextSize = 14
        ColorPickerTitle.TextXAlignment = Enum.TextXAlignment.Left
        ColorPickerTitle.TextYAlignment = Enum.TextYAlignment.Top
        ColorPickerTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorPickerTitle.BackgroundTransparency = 0.999
        ColorPickerTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerTitle.BorderSizePixel = 0
        ColorPickerTitle.Position = UDim2.new(0, 10, 0, 10)
        ColorPickerTitle.Size = UDim2.new(1, -100, 0, 13)
        ColorPickerTitle.Name = "ColorPickerTitle"
        ColorPickerTitle.Parent = ColorPicker

        local ColorPickerContent = Instance.new("TextLabel")
        ColorPickerContent.Font = Enum.Font.GothamBold
        ColorPickerContent.Text = content
        ColorPickerContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ColorPickerContent.TextSize = 13
        ColorPickerContent.TextTransparency = 0.6
        ColorPickerContent.TextXAlignment = Enum.TextXAlignment.Left
        ColorPickerContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ColorPickerContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorPickerContent.BackgroundTransparency = 0.999
        ColorPickerContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerContent.BorderSizePixel = 0
        ColorPickerContent.Position = UDim2.new(0, 10, 0, 23)
        ColorPickerContent.Size = UDim2.new(1, -100, 0, 12)
        ColorPickerContent.Name = "ColorPickerContent"
        ColorPickerContent.Parent = ColorPicker

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        ColorPickerContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ColorPickerContent.TextWrapped = true
        ColorPicker.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ColorPreview = Instance.new("Frame")
        ColorPreview.AnchorPoint = Vector2.new(1, 0.5)
        ColorPreview.BackgroundColor3 = defaultColor
        ColorPreview.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Position = UDim2.new(1, -15, 0.5, 0)
        ColorPreview.Size = UDim2.new(0, 30, 0, 30)
        ColorPreview.Name = "ColorPreview"
        ColorPreview.Parent = ColorPicker

        local PreviewCorner = Instance.new("UICorner")
        PreviewCorner.CornerRadius = UDim.new(0, 4)
        PreviewCorner.Parent = ColorPreview

        local PreviewStroke = Instance.new("UIStroke")
        PreviewStroke.Color = Color3.fromRGB(255, 255, 255)
        PreviewStroke.Thickness = 1
        PreviewStroke.Transparency = 0.5
        PreviewStroke.Parent = ColorPreview

        local ColorPickerButton = Instance.new("TextButton")
        ColorPickerButton.Font = Enum.Font.SourceSans
        ColorPickerButton.Text = ""
        ColorPickerButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerButton.TextSize = 14
        ColorPickerButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerButton.BackgroundTransparency = 0.999
        ColorPickerButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerButton.BorderSizePixel = 0
        ColorPickerButton.Size = UDim2.new(1, 0, 1, 0)
        ColorPickerButton.Name = "ColorPickerButton"
        ColorPickerButton.Parent = ColorPicker

        local ColorPickerFrame = Instance.new("Frame")
        ColorPickerFrame.AnchorPoint = Vector2.new(1, 0)
        ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ColorPickerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerFrame.BorderSizePixel = 0
        ColorPickerFrame.Position = UDim2.new(1, -12, 0, 35)
        ColorPickerFrame.Size = UDim2.new(0, 200, 0, 0)
        ColorPickerFrame.Name = "ColorPickerFrame"
        ColorPickerFrame.Visible = false
        ColorPickerFrame.ClipsDescendants = true
        ColorPickerFrame.ZIndex = 10
        ColorPickerFrame.Parent = ScreenGui

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = ColorPickerFrame

        local FrameStroke = Instance.new("UIStroke")
        FrameStroke.Color = Color3.fromRGB(255, 255, 255)
        FrameStroke.Thickness = 2.5
        FrameStroke.Transparency = 0.8
        FrameStroke.Parent = ColorPickerFrame

        local HueFrame = Instance.new("Frame")
        HueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueFrame.BackgroundTransparency = 0.999
        HueFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        HueFrame.BorderSizePixel = 0
        HueFrame.Position = UDim2.new(0, 10, 0, 10)
        HueFrame.Size = UDim2.new(0, 180, 0, 100)
        HueFrame.Name = "HueFrame"
        HueFrame.ZIndex = 11
        HueFrame.Parent = ColorPickerFrame

        local HueGradient = Instance.new("UIGradient")
        HueGradient.Color =
            ColorSequence.new(
            {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }
        )
        HueGradient.Parent = HueFrame

        local HueCorner = Instance.new("UICorner")
        HueCorner.CornerRadius = UDim.new(0, 4)
        HueCorner.Parent = HueFrame

        local SatValFrame = Instance.new("Frame")
        SatValFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SatValFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SatValFrame.BorderSizePixel = 0
        SatValFrame.Position = UDim2.new(0, 10, 0, 120)
        SatValFrame.Size = UDim2.new(0, 180, 0, 80)
        SatValFrame.Name = "SatValFrame"
        SatValFrame.ZIndex = 11
        SatValFrame.Parent = ColorPickerFrame

        local SatValGradient = Instance.new("UIGradient")
        SatValGradient.Color =
            ColorSequence.new(
            {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }
        )
        SatValGradient.Parent = SatValFrame

        local SatValCorner = Instance.new("UICorner")
        SatValCorner.CornerRadius = UDim.new(0, 4)
        SatValCorner.Parent = SatValFrame

        local HueSlider = Instance.new("Frame")
        HueSlider.AnchorPoint = Vector2.new(0.5, 0.5)
        HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        HueSlider.BorderSizePixel = 0
        HueSlider.Position = UDim2.new(0, 0, 0.5, 0)
        HueSlider.Size = UDim2.new(0, 4, 1, 0)
        HueSlider.Name = "HueSlider"
        HueSlider.ZIndex = 12
        HueSlider.Parent = HueFrame

        local HueSliderCorner = Instance.new("UICorner")
        HueSliderCorner.CornerRadius = UDim.new(0, 2)
        HueSliderCorner.Parent = HueSlider

        local HueSliderStroke = Instance.new("UIStroke")
        HueSliderStroke.Color = Color3.fromRGB(0, 0, 0)
        HueSliderStroke.Thickness = 1
        HueSliderStroke.Parent = HueSlider

        local SatValCursor = Instance.new("Frame")
        SatValCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        SatValCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SatValCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SatValCursor.BorderSizePixel = 0
        SatValCursor.Position = UDim2.new(0.5, 0, 0.5, 0)
        SatValCursor.Size = UDim2.new(0, 8, 0, 8)
        SatValCursor.Name = "SatValCursor"
        SatValCursor.ZIndex = 12
        SatValCursor.Parent = SatValFrame

        local SatValCursorCorner = Instance.new("UICorner")
        SatValCursorCorner.CornerRadius = UDim.new(0, 4)
        SatValCursorCorner.Parent = SatValCursor

        local SatValCursorStroke = Instance.new("UIStroke")
        SatValCursorStroke.Color = Color3.fromRGB(0, 0, 0)
        SatValCursorStroke.Thickness = 1
        SatValCursorStroke.Parent = SatValCursor

        local ColorPickerData = {
            Hue = 0,
            Sat = 1,
            Val = 1,
            DraggingHue = false,
            DraggingSatVal = false,
            Open = false
        }

        local function Color3ToHSV(color)
            local r, g, b = color.R, color.G, color.B
            local max = math.max(r, g, b)
            local min = math.min(r, g, b)
            local v = max
            local s = (max == 0) and 0 or (max - min) / max
            local h = 0

            if max ~= min then
                local d = max - min
                if max == r then
                    h = (g - b) / d + (g < b and 6 or 0)
                elseif max == g then
                    h = (b - r) / d + 2
                elseif max == b then
                    h = (r - g) / d + 4
                end
                h = h / 6
            end

            return h, s, v
        end

        local function HSVToColor3(h, s, v)
            local r, g, b
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)

            i = i % 6

            if i == 0 then
                r, g, b = v, t, p
            elseif i == 1 then
                r, g, b = q, v, p
            elseif i == 2 then
                r, g, b = p, v, t
            elseif i == 3 then
                r, g, b = p, q, v
            elseif i == 4 then
                r, g, b = t, p, v
            elseif i == 5 then
                r, g, b = v, p, q
            end

            return Color3.new(r, g, b)
        end

        local function UpdateColorFromHSV()
            local color = HSVToColor3(ColorPickerData.Hue, ColorPickerData.Sat, ColorPickerData.Val)
            ColorPreview.BackgroundColor3 = color
            SatValGradient.Color =
                ColorSequence.new(
                {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, HSVToColor3(ColorPickerData.Hue, 1, 1))
                }
            )

            if callback then
                callback(color)
            end
        end

        local function SetColor(color)
            local h, s, v = Color3ToHSV(color)
            ColorPickerData.Hue = h
            ColorPickerData.Sat = s
            ColorPickerData.Val = v

            HueSlider.Position = UDim2.new(h, 0, 0.5, 0)
            SatValCursor.Position = UDim2.new(s, 0, 1 - v, 0)

            UpdateColorFromHSV()
        end

        SetColor(defaultColor)

        local function ToggleColorPicker()
            ColorPickerData.Open = not ColorPickerData.Open
            if ColorPickerData.Open then
                local pickerAbsPos = ColorPicker.AbsolutePosition
                local pickerAbsSize = ColorPicker.AbsoluteSize
                ColorPickerFrame.Position =
                    UDim2.new(0, pickerAbsPos.X + pickerAbsSize.X - 212, 0, pickerAbsPos.Y + pickerAbsSize.Y + 5)

                ColorPickerFrame.Visible = true
                TweenService:Create(ColorPickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 210)}):Play()
            else
                TweenService:Create(ColorPickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 0)}):Play()
                task.wait(0.5)
                ColorPickerFrame.Visible = false
            end
        end

        HueFrame.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    ColorPickerData.DraggingHue = true
                    local pos =
                        math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
                    ColorPickerData.Hue = pos
                    HueSlider.Position = UDim2.new(pos, 0, 0.5, 0)
                    UpdateColorFromHSV()
                end
            end
        )

        SatValFrame.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    ColorPickerData.DraggingSatVal = true
                    local sat =
                        math.clamp(
                        (input.Position.X - SatValFrame.AbsolutePosition.X) / SatValFrame.AbsoluteSize.X,
                        0,
                        1
                    )
                    local val =
                        1 -
                        math.clamp(
                            (input.Position.Y - SatValFrame.AbsolutePosition.Y) / SatValFrame.AbsoluteSize.Y,
                            0,
                            1
                        )
                    ColorPickerData.Sat = sat
                    ColorPickerData.Val = val
                    SatValCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    UpdateColorFromHSV()
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)
                if
                    ColorPickerData.DraggingHue and
                        (input.UserInputType == Enum.UserInputType.MouseMovement or
                            input.UserInputType == Enum.UserInputType.Touch)
                 then
                    local pos =
                        math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
                    ColorPickerData.Hue = pos
                    HueSlider.Position = UDim2.new(pos, 0, 0.5, 0)
                    UpdateColorFromHSV()
                elseif
                    ColorPickerData.DraggingSatVal and
                        (input.UserInputType == Enum.UserInputType.MouseMovement or
                            input.UserInputType == Enum.UserInputType.Touch)
                 then
                    local sat =
                        math.clamp(
                        (input.Position.X - SatValFrame.AbsolutePosition.X) / SatValFrame.AbsoluteSize.X,
                        0,
                        1
                    )
                    local val =
                        1 -
                        math.clamp(
                            (input.Position.Y - SatValFrame.AbsolutePosition.Y) / SatValFrame.AbsoluteSize.Y,
                            0,
                            1
                        )
                    ColorPickerData.Sat = sat
                    ColorPickerData.Val = val
                    SatValCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    UpdateColorFromHSV()
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    ColorPickerData.DraggingHue = false
                    ColorPickerData.DraggingSatVal = false
                end
            end
        )

        ColorPickerButton.Activated:Connect(
            function()
                CircleClick(ColorPickerButton, Mouse.X, Mouse.Y)
                ToggleColorPicker()
            end
        )

        local colorPickerConnection
        colorPickerConnection =
            UserInputService.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    if ColorPickerData.Open and ColorPickerFrame.Visible then
                        local mousePos = input.Position
                        local pickerPos = ColorPickerFrame.AbsolutePosition
                        local pickerSize = ColorPickerFrame.AbsoluteSize
                        local previewPos = ColorPreview.AbsolutePosition
                        local previewSize = ColorPreview.AbsoluteSize

                        if
                            not (mousePos.X >= pickerPos.X and mousePos.X <= pickerPos.X + pickerSize.X and
                                mousePos.Y >= pickerPos.Y and
                                mousePos.Y <= pickerPos.Y + pickerSize.Y) and
                                not (mousePos.X >= previewPos.X and mousePos.X <= previewPos.X + previewSize.X and
                                    mousePos.Y >= previewPos.Y and
                                    mousePos.Y <= previewPos.Y + previewSize.Y)
                         then
                            ToggleColorPicker()
                        end
                    end
                end
            end
        )
        ColorPicker.Destroying:Connect(
            function()
                if colorPickerConnection then
                    colorPickerConnection:Disconnect()
                end
                ColorPickerFrame:Destroy()
            end
        )
        task.wait(0.1)
        UpdateContentSize()

        local colorPickerFunc = {
            Value = defaultColor,
            Type = "ColorPicker",
            Id = elementId
        }

        function colorPickerFunc:Set(color)
            SetColor(color)
            colorPickerFunc.Value = color
        end

        if elementId then
            AllElements[elementId] = colorPickerFunc
        end

        return colorPickerFunc
    end

    local function CreateKeybind(tabContainer, title, content, defaultKey, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        local Keybind = Instance.new("Frame")
        Keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Keybind.BackgroundTransparency = 0.935
        Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Keybind.BorderSizePixel = 0
        Keybind.Size = UDim2.new(1, 0, 0, 46)
        Keybind.Name = "Keybind"
        Keybind.Parent = tabContainer

        local KeybindCorner = Instance.new("UICorner")
        KeybindCorner.CornerRadius = UDim.new(0, 4)
        KeybindCorner.Parent = Keybind

        local KeybindTitle = Instance.new("TextLabel")
        KeybindTitle.Font = Enum.Font.GothamBold
        KeybindTitle.Text = title
        KeybindTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        KeybindTitle.TextSize = 14
        KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
        KeybindTitle.TextYAlignment = Enum.TextYAlignment.Top
        KeybindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindTitle.BackgroundTransparency = 0.999
        KeybindTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindTitle.BorderSizePixel = 0
        KeybindTitle.Position = UDim2.new(0, 10, 0, 10)
        KeybindTitle.Size = UDim2.new(1, -100, 0, 13)
        KeybindTitle.Name = "KeybindTitle"
        KeybindTitle.Parent = Keybind

        local KeybindContent = Instance.new("TextLabel")
        KeybindContent.Font = Enum.Font.GothamBold
        KeybindContent.Text = content
        KeybindContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindContent.TextSize = 13
        KeybindContent.TextTransparency = 0.6
        KeybindContent.TextXAlignment = Enum.TextXAlignment.Left
        KeybindContent.TextYAlignment = Enum.TextYAlignment.Bottom
        KeybindContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindContent.BackgroundTransparency = 0.999
        KeybindContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindContent.BorderSizePixel = 0
        KeybindContent.Position = UDim2.new(0, 10, 0, 23)
        KeybindContent.Size = UDim2.new(1, -100, 0, 12)
        KeybindContent.Name = "KeybindContent"
        KeybindContent.Parent = Keybind

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        KeybindContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        KeybindContent.TextWrapped = true
        Keybind.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local KeybindFrame = Instance.new("Frame")
        KeybindFrame.AnchorPoint = Vector2.new(1, 0.5)
        KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindFrame.BackgroundTransparency = 0.95
        KeybindFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindFrame.BorderSizePixel = 0
        KeybindFrame.ClipsDescendants = true
        KeybindFrame.Position = UDim2.new(1, -7, 0.5, 0)
        KeybindFrame.Size = UDim2.new(0, 80, 0, 30)
        KeybindFrame.Name = "KeybindFrame"
        KeybindFrame.Parent = Keybind

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = KeybindFrame

        local KeybindText = Instance.new("TextLabel")
        KeybindText.Font = Enum.Font.GothamBold
        KeybindText.Text = defaultKey and defaultKey.Name or "None"
        KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindText.TextSize = 13
        KeybindText.TextTransparency = 0.6
        KeybindText.TextXAlignment = Enum.TextXAlignment.Center
        KeybindText.TextYAlignment = Enum.TextYAlignment.Center
        KeybindText.AnchorPoint = Vector2.new(0.5, 0.5)
        KeybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindText.BackgroundTransparency = 0.999
        KeybindText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindText.BorderSizePixel = 0
        KeybindText.Position = UDim2.new(0.5, 0, 0.5, 0)
        KeybindText.Size = UDim2.new(1, -10, 1, -8)
        KeybindText.Name = "KeybindText"
        KeybindText.Parent = KeybindFrame

        local KeybindButton = Instance.new("TextButton")
        KeybindButton.Font = Enum.Font.SourceSans
        KeybindButton.Text = ""
        KeybindButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.TextSize = 14
        KeybindButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.BackgroundTransparency = 0.999
        KeybindButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.BorderSizePixel = 0
        KeybindButton.Size = UDim2.new(1, 0, 1, 0)
        KeybindButton.Name = "KeybindButton"
        KeybindButton.Parent = Keybind

        local keybindData = {
            Key = defaultKey,
            Listening = false,
            Connection = nil
        }

        local function SetKey(key)
            keybindData.Key = key
            KeybindText.Text = key and key.Name or "None"

            if keybindData.Connection then
                keybindData.Connection:Disconnect()
                keybindData.Connection = nil
            end

            if key then
                keybindData.Connection =
                    UserInputService.InputBegan:Connect(
                    function(input, gameProcessed)
                        if not gameProcessed and input.KeyCode == key then
                            if callback then
                                callback(key)
                            end
                        end
                    end
                )
            end
        end

        KeybindButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(KeybindButton, Mouse.X, Mouse.Y)

                if keybindData.Listening then
                    return
                end
                keybindData.Listening = true

                KeybindText.Text = "..."
                KeybindText.TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]

                local listeningConnection
                listeningConnection =
                    UserInputService.InputBegan:Connect(
                    function(input, gameProcessed)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then
                                keybindData.Listening = false
                                KeybindText.Text = keybindData.Key and keybindData.Key.Name or "None"
                                KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
                                if listeningConnection then
                                    listeningConnection:Disconnect()
                                end
                                return
                            end

                            keybindData.Listening = false
                            SetKey(input.KeyCode)
                            KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)

                            if listeningConnection then
                                listeningConnection:Disconnect()
                            end
                        end
                    end
                )
            end
        )

        if defaultKey then
            SetKey(defaultKey)
        end

        Keybind.Destroying:Connect(
            function()
                if keybindData.Connection then
                    keybindData.Connection:Disconnect()
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local keybindFunc = {
            Value = defaultKey,
            Type = "Keybind",
            Id = elementId
        }

        function keybindFunc:Set(key)
            SetKey(key)
            keybindFunc.Value = key
        end

        if elementId then
            AllElements[elementId] = keybindFunc
        end

        return keybindFunc
    end
    
    local function CreateButtonGrid(tabContainer, btn1Config, btn2Config)
        if not tabContainer or not tabContainer:IsA("Frame") then return end

        local GridFrame = Instance.new("Frame")
        GridFrame.BackgroundTransparency = 1
        GridFrame.Size = UDim2.new(1, 0, 0, 36)
        GridFrame.BorderSizePixel = 0
        GridFrame.Name = "ButtonGrid"
        GridFrame.Parent = tabContainer

        local GridLayout = Instance.new("UIListLayout")
        GridLayout.FillDirection = Enum.FillDirection.Horizontal
        GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        GridLayout.Padding = UDim.new(0, 6)
        GridLayout.Parent = GridFrame

        local function makeHalfBtn(cfg, order)
            local Btn = Instance.new("TextButton")
            Btn.Font = Enum.Font.GothamBold
            Btn.Text = cfg.Title or "Button"
            Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            Btn.TextSize = 12
            Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Btn.BackgroundTransparency = 0.92
            Btn.BorderSizePixel = 0
            Btn.Size = UDim2.new(0.5, -3, 1, 0)
            Btn.LayoutOrder = order
            Btn.AutoButtonColor = true
            Btn.Name = "GridBtn"
            Btn.Parent = GridFrame

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Btn

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(80, 80, 80)
            BtnStroke.Thickness = 1
            BtnStroke.Transparency = 0.6
            BtnStroke.Parent = Btn

            if cfg.Callback then
                Btn.Activated:Connect(function()
                    if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                    CircleClick(Btn, Mouse.X, Mouse.Y)
                    cfg.Callback()
                end)
            end
            return Btn
        end

        makeHalfBtn(btn1Config or {}, 1)
        makeHalfBtn(btn2Config or {}, 2)

        task.wait(0.1)
        UpdateContentSize()
    end

    local function CreateCollapsible(tabContainer, title, defaultOpen)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        defaultOpen = defaultOpen == true

        local SectionFrame = Instance.new("Frame")
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Size = UDim2.new(1, 0, 0, 34)
        SectionFrame.BorderSizePixel = 0
        SectionFrame.ClipsDescendants = true
        SectionFrame.Name = "Collapsible"
        SectionFrame.Parent = tabContainer

        local HeaderBtn = Instance.new("TextButton")
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
        HeaderBtn.Font = Enum.Font.GothamBold
        HeaderBtn.Text = "  " .. (title or "Section")
        HeaderBtn.TextColor3 = Color3.fromRGB(170, 170, 185)
        HeaderBtn.TextSize = 14
        HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left
        HeaderBtn.BorderSizePixel = 0
        HeaderBtn.Name = "HeaderBtn"
        HeaderBtn.Parent = SectionFrame

        local SectionArrow = Instance.new("ImageLabel")
        SectionArrow.BackgroundTransparency = 1
        SectionArrow.AnchorPoint = Vector2.new(1, 0.5)
        SectionArrow.Position = UDim2.new(1, -8, 0.5, 0)
        SectionArrow.Size = UDim2.new(0, 25, 0, 25)
        SectionArrow.Image = "rbxassetid://16851841101"
        SectionArrow.ImageTransparency = 0.3
        SectionArrow.Rotation = defaultOpen and 0 or -90
        SectionArrow.Name = "SectionArrow"
        SectionArrow.Parent = HeaderBtn

        local InnerContainer = Instance.new("Frame")
        InnerContainer.BackgroundTransparency = 1
        InnerContainer.Position = UDim2.new(0, 0, 0, 34)
        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
        InnerContainer.BorderSizePixel = 0
        InnerContainer.ClipsDescendants = true
        InnerContainer.Name = "InnerContainer"
        InnerContainer.Parent = SectionFrame

        local InnerLayout = Instance.new("UIListLayout")
        InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        InnerLayout.Padding = UDim.new(0, 5)
        InnerLayout.Parent = InnerContainer



        local isOpen = defaultOpen

        local function updateSize()
            

            local contentH = InnerLayout.AbsoluteContentSize.Y + 8
            if isOpen then
                InnerContainer.Size = UDim2.new(1, 0, 0, contentH)
                SectionFrame.Size  = UDim2.new(1, 0, 0, 34 + contentH)
                TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 0}):Play()
            else
                InnerContainer.Size = UDim2.new(1, 0, 0, 0)
                SectionFrame.Size  = UDim2.new(1, 0, 0, 34)
                TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = -90}):Play()
            end
            task.wait(0.01)
            UpdateContentSize()
        end

        InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if isOpen then updateSize() end
        end)

        HeaderBtn.Activated:Connect(function()
            if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
            isOpen = not isOpen
            updateSize()
        end)



        -- register in SearchSections for live search
        local rawName = (tabContainer and tabContainer.Name) or ""
        local tabName = rawName ~= "" and rawName:gsub("Content$", "") or nil
        if tabName and title and title ~= "" then
            local secTitle = (title or ""):gsub("^%s+", "")
            table.insert(SearchSections, {
                title   = secTitle,
                tabName = tabName,
                secFrame = SectionFrame,
                openFn  = function()
                    if not isOpen then
                        isOpen = true
                        updateSize()
                    end
                end,
            })
        end

        updateSize()
        return InnerContainer
    end

    local function CreateTabButton(tabName, iconId, isConfigTab)
        TabCount = TabCount + 1
        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.BackgroundTransparency = 0.999
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderSizePixel = 0
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.LayoutOrder = isConfigTab and 999 or TabCount
        Tab.Name = "Tab"
        Tab.Parent = TabScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = Tab

        local TabButton = Instance.new("TextButton")
        TabButton.ZIndex = 10
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 0.999
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        local TabNameLabel = Instance.new("TextLabel")
        TabNameLabel.Font = Enum.Font.GothamBold
        TabNameLabel.Text = tabName
        TabNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.TextSize = 13
        TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.BackgroundTransparency = 0.999
        TabNameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabNameLabel.BorderSizePixel = 0
        TabNameLabel.Size = UDim2.new(1, 0, 1, 0)
        TabNameLabel.Position = UDim2.new(0, iconId and iconId ~= "" and 30 or 10, 0, 0)
        TabNameLabel.Name = "TabName"
        TabNameLabel.Parent = Tab

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = iconId or ""
        FeatureImg.BackgroundTransparency = 1
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Visible = iconId ~= nil and iconId ~= ""
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab



        local ChooseFrame = Instance.new("Frame")
        ChooseFrame.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ChooseFrame.BorderSizePixel = 0
        ChooseFrame.Position = UDim2.new(0, 0, 0, 9)
        ChooseFrame.Size = UDim2.new(0, 3, 0, 12)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Tab
        ChooseFrame.Visible = false

        local ChooseStroke = Instance.new("UIStroke")
        ChooseStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseStroke.Thickness = 1.6
        ChooseStroke.Parent = ChooseFrame

        local ChooseCorner = Instance.new("UICorner")
        ChooseCorner.Parent = ChooseFrame

        table.insert(ConfigSystem.TabElements, Tab)

        local TabContentContainer = Instance.new("Frame")
        TabContentContainer.BackgroundTransparency = 1
        TabContentContainer.Size = UDim2.new(1, 0, 0, 0)
        TabContentContainer.Visible = false
        TabContentContainer.LayoutOrder = isConfigTab and 999 or TabCount
        TabContentContainer.Name = tabName .. "Content"
        TabContentContainer.Parent = ContentScroll

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = TabContentContainer

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
            function()
                TabContentContainer.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
                ContentScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
            end
        )

        TabContents[tabName] = TabContentContainer
        TabContentContainer:SetAttribute("LimboTabName", tabName)

        local function SwitchToTab()
            for name, container in pairs(TabContents) do
                container.Visible = false
            end

            for _, tabFrame in TabScroll:GetChildren() do
                if tabFrame:IsA("Frame") and tabFrame.Name == "Tab" then
                    local chooseFrame = tabFrame:FindFirstChild("ChooseFrame")
                    if chooseFrame then
                        chooseFrame.Visible = false
                    end
                    tabFrame.BackgroundTransparency = 0.999
                end
            end

            TabContentContainer.Visible = true
            ChooseFrame.Visible = true
            Tab.BackgroundTransparency = 0.92
            CurrentTab = tabName
            UpdateContentSize()
        end

        TabSwitchFns[tabName] = SwitchToTab

        TabButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(TabButton, Mouse.X, Mouse.Y)
                SwitchToTab()
            end
        )

        return TabContentContainer, SwitchToTab
    end
    
    local ConfigTabContainer, SwitchToConfigTab = CreateTabButton("Configuration", "rbxassetid://140704441124047", true)
    
    -- Config tab setup
    local CurrentConfigName = ""
    local SelectedConfigName = ""
    local AutoloadFile = ConfigFolder .. "/Autoload.txt"
    local CfgSection = CreateCollapsible(ConfigTabContainer, "Configuration", true)

    -- Status header frame with gear icon + two-line status
    local CfgHeaderFrame = Instance.new("Frame", CfgSection)
    CfgHeaderFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    CfgHeaderFrame.BackgroundTransparency = 0.935
    CfgHeaderFrame.BorderSizePixel = 0
    CfgHeaderFrame.Size = UDim2.new(1, 0, 0, 56)
    CfgHeaderFrame.Name = "CfgHeader"
    Instance.new("UICorner", CfgHeaderFrame).CornerRadius = UDim.new(0, 4)

    local CfgGearIcon = Instance.new("ImageLabel", CfgHeaderFrame)
    CfgGearIcon.Image = "rbxassetid://112919034802026"
    CfgGearIcon.BackgroundTransparency = 1
    CfgGearIcon.Position = UDim2.new(0, 8, 0.5, 0)
    CfgGearIcon.AnchorPoint = Vector2.new(0, 0.5)
    CfgGearIcon.Size = UDim2.new(0, 18, 0, 18)
    CfgGearIcon.ZIndex = 2

    local CfgTitle = Instance.new("TextLabel", CfgHeaderFrame)
    CfgTitle.Font = Enum.Font.GothamBold
    CfgTitle.Text = "Config Manager"
    CfgTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    CfgTitle.TextSize = 14
    CfgTitle.TextXAlignment = Enum.TextXAlignment.Left
    CfgTitle.BackgroundTransparency = 1
    CfgTitle.BorderSizePixel = 0
    CfgTitle.Position = UDim2.new(0, 32, 0, 13)
    CfgTitle.Size = UDim2.new(1, -36, 0, 14)
    CfgTitle.ZIndex = 2

    local CfgStatusLabel = Instance.new("TextLabel", CfgHeaderFrame)
    CfgStatusLabel.Font = Enum.Font.GothamBold
    CfgStatusLabel.Text = "Current: None  |  Autoload: None"
    CfgStatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    CfgStatusLabel.TextSize = 12
    CfgStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    CfgStatusLabel.TextWrapped = true
    CfgStatusLabel.BackgroundTransparency = 1
    CfgStatusLabel.BorderSizePixel = 0
    CfgStatusLabel.Position = UDim2.new(0, 32, 0, 29)
    CfgStatusLabel.Size = UDim2.new(1, -36, 0, 24)
    CfgStatusLabel.ZIndex = 2

    local function updateCfgStatus()
        local cur = CurrentConfigName ~= "" and CurrentConfigName or "None"
        local al = "None"
        pcall(function()
            if isfile(AutoloadFile) then
                local v = readfile(AutoloadFile)
                if v and v ~= "" then al = v end
            end
        end)
        CfgStatusLabel.Text = "Current: " .. cur .. "  |  Autoload: " .. al
    end
    updateCfgStatus()



    local ConfigNameInput =
        CreateInput(
        CfgSection,
        "Config Name",
        "",
        "Write your input here...",
        function(value)
            CurrentConfigName = value
        end,
        "ConfigName"
    )

    local SelectConfigDropdown = CreateDropdown(
        CfgSection,
        "Select Config",
        "Choose from saved configs",
        ConfigSystem:GetConfigList(),
        false,
        nil,
        function(value)
            if value and value ~= "" then
                SelectedConfigName = value
                CurrentConfigName = value
                updateCfgStatus()
            end
        end,
        "SelectConfigDropdown"
    )

    local function doSaveConfig()
        local targetName = CurrentConfigName ~= "" and CurrentConfigName or SelectedConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Enter or select a config name first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local configData = {}
        for id, element in pairs(AllElements) do
            local val = nil
            if element.Type == "Toggle" then
                local live = element._live and element._live() or element.Value
                val = live
            elseif element.Type == "Slider" then
                local live = element._data and element._data.Value or element.Value
                local def = element._default
                if def == nil or live ~= def then val = live end
            elseif element.Type == "Dropdown" then
                local live = element._data and element._data.Value or element.Value
                if element._data and element._data.Multi then
                    if type(live) == "table" and #live > 0 then val = live end
                else
                    if live and live ~= "" and live ~= "Select Option" then val = live end
                end
            elseif element.Type == "Input" then
                if element.Value and element.Value ~= "" then val = element.Value end
            elseif element.Type == "ColorPicker" then
                if element.Value then val = {element.Value.R, element.Value.G, element.Value.B} end
            elseif element.Type == "Keybind" then
                if element.Value then val = element.Value.Name end
            end
            if val ~= nil then
                configData[id] = val
            end
        end
        local notifyData = ConfigSystem:SaveConfig(targetName, configData)
        MakeNotify(notifyData)
        CurrentConfigName = targetName
        updateCfgStatus()
        local configList = ConfigSystem:GetConfigList()
        SelectConfigDropdown:Refresh(configList)
    end

    local function doLoadConfig()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local _, configData = ConfigSystem:LoadConfig(targetName)
        if configData then
            for id, val in pairs(configData) do
                pcall(function()
                    if AllElements[id] then
                        if AllElements[id].Type == "Toggle" and val == false then
                            return
                        end
                        if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                            AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                        elseif AllElements[id].Type == "Keybind" and val then
                            AllElements[id]:Set(Enum.KeyCode[val])
                        else
                            AllElements[id]:Set(val)
                        end
                    end
                end)
            end
        end
        CurrentConfigName = targetName
        updateCfgStatus()
        MakeNotify({ Title = "Config", Description = "Loaded", Content = "\"" .. targetName .. "\" loaded!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
    end

    local function doDeleteConfig()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local notifyData = ConfigSystem:DeleteConfig(targetName)
        MakeNotify(notifyData)
        SelectedConfigName = ""
        CurrentConfigName = ""
        updateCfgStatus()
        local configList = ConfigSystem:GetConfigList()
        SelectConfigDropdown:Refresh(configList)
    end

    local function doSetAutoload()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        pcall(function()
            if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
            writefile(AutoloadFile, targetName)
        end)
        MakeNotify({ Title = "Config", Description = "Autoload Set", Content = "Autoload -> \"" .. targetName .. "\"", Color = Color3.fromRGB(150,150,170), Delay = 3 })
        updateCfgStatus()
    end

    local function doClearAutoload()
        pcall(function()
            if isfile(AutoloadFile) then writefile(AutoloadFile, "") end
        end)
        MakeNotify({ Title = "Config", Description = "Cleared", Content = "Autoload cleared.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
        updateCfgStatus()
    end

    CreateButtonGrid(CfgSection,
        { Title = "Save Config", Callback = doSaveConfig },
        { Title = "Load Config", Callback = doLoadConfig }
    )

    CreateButtonGrid(CfgSection,
        { Title = "Delete Config", Callback = doDeleteConfig },
        { Title = "Set Autoload",  Callback = doSetAutoload }
    )

    CreateButtonGrid(CfgSection,
        { Title = "Refresh List", Callback = function()
            local configList = ConfigSystem:GetConfigList()
            SelectConfigDropdown:Refresh(configList)
            MakeNotify({ Title = "Config", Description = "Refreshed", Content = "Config list updated.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
        end },
        { Title = "Clear Autoload", Callback = doClearAutoload }
    )

    CreateButton(CfgSection, "Reset All Elements", "Reset all elements to default", "rbxassetid://16932740082", function()
        for id, element in pairs(AllElements) do
            pcall(function()
                if element.Type == "Toggle" then
                    element:Set(false)
                elseif element.Type == "Slider" then
                    local min = element._data and element._data.MinValue or 0
                    element:Set(min)
                elseif element.Type == "Dropdown" then
                    if element._data and element._data.Multi then
                        element:Set({})
                    else
                        element:Set(nil)
                    end
                elseif element.Type == "Input" then
                    element:Set("")
                end
            end)
        end
        MakeNotify({ Title = "Config", Description = "Reset", Content = "All elements reset to default.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
    end)

    -- backward compat refs
    local LoadConfigDropdown = SelectConfigDropdown
    local DeleteConfigDropdown = SelectConfigDropdown
    
    -- Switch to first tab is handled by Window:Show()

    -- Window Methods
    local Window = {}
    
    function Window:CreateTab(tabName, iconId)
        return CreateTabButton(tabName, iconId, false)
    end
    
    function Window:AddParagraph(tabContainer, title, content)
        return CreateParagraph(tabContainer, title, content)
    end

    function Window:AddTextHeader(tabContainer, title)
        return CreateTextHeader(tabContainer, title)
    end

    function Window:AddWelcomeCard(tabContainer)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        local LP = game:GetService("Players").LocalPlayer
        local WC = Instance.new("Frame")
        WC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WC.BackgroundTransparency = 0.935
        WC.BorderSizePixel = 0
        WC.Size = UDim2.new(1, 0, 0, 88)
        WC.LayoutOrder = 0
        WC.Name = "WelcomeCard"
        WC.Parent = tabContainer
        Instance.new("UICorner", WC).CornerRadius = UDim.new(0, 4)

        local AF = Instance.new("Frame")
        AF.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        AF.BorderSizePixel = 0
        AF.Position = UDim2.new(0, 14, 0.5, -28)
        AF.Size = UDim2.new(0, 56, 0, 56)
        AF.Parent = WC
        Instance.new("UICorner", AF).CornerRadius = UDim.new(1, 0)

        local AI = Instance.new("ImageLabel")
        AI.Size = UDim2.new(1, 0, 1, 0)
        AI.BackgroundTransparency = 1
        AI.BorderSizePixel = 0
        AI.Parent = AF
        Instance.new("UICorner", AI).CornerRadius = UDim.new(1, 0)

        task.spawn(function()
            local ok, img = pcall(function()
                return game:GetService("Players"):GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and img then AI.Image = img end
        end)

        local NL = Instance.new("TextLabel")
        NL.Font = Enum.Font.GothamBold
        do
            local _n = LP.Name
            local _m = #_n > 3 and _n:sub(1, #_n - 3) .. "***" or "***"
            NL.Text = "Hey, " .. _m .. "!"
        end
        NL.TextColor3 = Color3.fromRGB(240, 240, 255)
        NL.TextSize = 14
        NL.TextXAlignment = Enum.TextXAlignment.Left
        NL.BackgroundTransparency = 1
        NL.BorderSizePixel = 0
        NL.Size = UDim2.new(1, -96, 0, 20)
        NL.Position = UDim2.new(0, 82, 0, 24)
        NL.Parent = WC

        local SL = Instance.new("TextLabel")
        SL.Font = Enum.Font.GothamBold
        SL.Text = "Welcome to Limbo Hub"
        SL.TextColor3 = Color3.fromRGB(255, 255, 255)
        SL.TextTransparency = 0.6
        SL.TextSize = 12
        SL.TextXAlignment = Enum.TextXAlignment.Left
        SL.BackgroundTransparency = 1
        SL.BorderSizePixel = 0
        SL.Size = UDim2.new(1, -96, 0, 16)
        SL.Position = UDim2.new(0, 82, 0, 50)
        SL.Parent = WC
    end
    
    function Window:AddButton(tabContainer, title, content, iconId, callback)
        return CreateButton(tabContainer, title, content, iconId, callback)
    end
    
    function Window:AddToggle(tabContainer, title, content, defaultValue, callback, elementId)
        return CreateToggle(tabContainer, title, content, defaultValue, callback, elementId)
    end
    
    function Window:AddInput(tabContainer, title, content, placeholder, callback, elementId)
        return CreateInput(tabContainer, title, content, placeholder, callback, elementId)
    end
    
    function Window:AddDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
        return CreateDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
    end
    
    function Window:AddMultiDropdown(tabContainer, title, content, options, defaultValue, callback, elementId)
        return CreateDropdown(tabContainer, title, content, options, true, defaultValue, callback, elementId)
    end
    
    function Window:AddSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId, showKnob)
        return CreateSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId, showKnob)
    end
    
    function Window:AddLineSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId)
        return CreateSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId, false)
    end

    function Window:AddImageBox(tabContainer, title, content, imageId, size, callback, elementId)
        return CreateImageBox(tabContainer, title, content, imageId, size, callback, elementId)
    end

    -- FIXED: Renamed from AddSection to AddDivider
    function Window:AddDivider(tabContainer, title)
        return CreateDivider(tabContainer, title)
    end

    function Window:AddCollapsible(tabContainer, title, defaultOpen)
        return CreateCollapsible(tabContainer, title, defaultOpen)
    end

    function Window:AddButtonGrid(tabContainer, btn1Config, btn2Config)
        return CreateButtonGrid(tabContainer, btn1Config, btn2Config)
    end

    function Window:AddColorPicker(tabContainer, title, content, defaultColor, callback, elementId)
        return CreateColorPicker(tabContainer, title, content, defaultColor, callback, elementId)
    end

    function Window:AddKeybind(tabContainer, title, content, defaultKey, callback, elementId)
        return CreateKeybind(tabContainer, title, content, defaultKey, callback, elementId)
    end
    
    function Window:Notify(notifyConfig)
        return MakeNotify(notifyConfig)
    end
    
    function Window:SetTheme(themeName)
        return ConfigSystem:SetTheme(themeName)
    end
    
    function Window:SaveConfig(name)
        local configData = {}
        for id, element in pairs(AllElements) do
            if element.Type == "Toggle" then
                configData[id] = element.Value
            elseif element.Type == "Slider" then
                configData[id] = element.Value
            elseif element.Type == "Dropdown" then
                configData[id] = element.Value
            elseif element.Type == "Input" then
                configData[id] = element.Value
            elseif element.Type == "ColorPicker" then
                configData[id] = {element.Value.R, element.Value.G, element.Value.B}
            elseif element.Type == "Keybind" then
                configData[id] = element.Value and element.Value.Name or nil
            end
        end
        local notifyData = ConfigSystem:SaveConfig(name, configData)
        MakeNotify(notifyData)
    end
    
    function Window:LoadConfig(name)
        local notifyData, configData = ConfigSystem:LoadConfig(name)
        MakeNotify(notifyData)
        if configData then
            for id, val in pairs(configData) do
                if AllElements[id] then
                    if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                        AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                    elseif AllElements[id].Type == "Keybind" and val then
                        AllElements[id]:Set(Enum.KeyCode[val])
                    else
                        AllElements[id]:Set(val)
                    end
                end
            end
        end
    end
    
    function Window:DeleteConfig(name)
        local notifyData = ConfigSystem:DeleteConfig(name)
        MakeNotify(notifyData)
    end
    
    function Window:GetConfigs()
        return ConfigSystem:GetConfigList()
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:SetActiveTab(tabName)
        if TabSwitchFns[tabName] then
            TabSwitchFns[tabName]()
        end
    end

    function Window:Show()
        DropShadowHolder.Visible = true
        task.spawn(function()
            pcall(function()
                if isfile(AutoloadFile) then
                    local autoName = readfile(AutoloadFile)
                    if autoName and autoName ~= "" then
                        local _, configData = ConfigSystem:LoadConfig(autoName)
                        if configData then
                            for id, val in pairs(configData) do
                                pcall(function()
                                    if AllElements[id] then
                                        if AllElements[id].Type == "Toggle" and val == false then
                                            return
                                        end
                                        if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                                            AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                                        elseif AllElements[id].Type == "Keybind" and val then
                                            AllElements[id]:Set(Enum.KeyCode[val])
                                        else
                                            AllElements[id]:Set(val)
                                        end
                                    end
                                end)
                            end
                            CurrentConfigName = autoName
                            updateCfgStatus()
                            MakeNotify({ Title = "Config", Description = "Autoloaded", Content = "\"" .. autoName .. "\" loaded!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
                        end
                    end
                end
            end)
        end)
    end
    
    return Window
end

function Limbo:Notify(config)
    MakeNotify(config)
end

return Limbo
