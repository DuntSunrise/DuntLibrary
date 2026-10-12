local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local SCRIPT_URL = ""

local WHITE = Color3.new(1, 1, 1)
local BLUE = Color3.fromRGB(80, 170, 255)
local SOFT = Color3.fromRGB(140, 200, 255)
local RED = Color3.fromRGB(255, 96, 110)
local MINT = Color3.fromRGB(100, 240, 180)

local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local function kp(t, c)
    return ColorSequenceKeypoint.new(t, c)
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do
        o[k] = v
    end
    if parent then
        o.Parent = parent
    end
    return o
end

local function tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function loop(o, t, props, style, reverses)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, reverses or false), props)
    tw:Play()
    return tw
end

local _p = {}
local _K

_p[1] = function()
    return string.char(bit32.bxor(0xE2,0xA9), (0x49 + 0x2D), bit32.bxor(0xDC,0xBD))
end

local function host()
    local ok, res = pcall(function()
        if gethui then
            return gethui()
        end
        return game:GetService("CoreGui")
    end)
    if ok and res then
        return res
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local hostParent = host()
local old = hostParent:FindFirstChild("KvantLoader")
if old then
    old:Destroy()
end

local gui = new("ScreenGui", {
    Name = "KvantLoader",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, hostParent)

local dim = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = rgb(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
}, gui)

local blur = nil
pcall(function()
    blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
end)

_p[2] = function()
    return string.char(bit32.bxor(0xA8,0xC6), (0xE8 - 0x74), bit32.bxor(0x16,0x3B))
end

local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(800, 400)
local fit = math.clamp(math.min((vp.Y - 24) / 196, (vp.X - 24) / 320), 0.55, 1.1)

local win = new("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(320, 196),
    BackgroundColor3 = WHITE,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 10,
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 16)}, win)
new("UIGradient", {Rotation = 90, Color = ColorSequence.new(rgb(13, 22, 48), rgb(5, 8, 18))}, win)
local winScale = new("UIScale", {Scale = 0.6}, win)
local winStroke = new("UIStroke", {Thickness = 2, Color = WHITE}, win)
local winGrad = new("UIGradient", {
    Color = ColorSequence.new({kp(0, rgb(20, 60, 170)), kp(0.5, rgb(100, 205, 255)), kp(1, rgb(20, 60, 170))}),
}, winStroke)
loop(winGrad, 4, {Rotation = 360})

_p[3] = function()
    return string.char((0xC7 - 0x81), (0x40 + 0x32), (0x2F + 0x36), bit32.bxor(0x75,0x10), (0x01 + 0x2C))
end

local title = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 12),
    Size = UDim2.new(1, 0, 0, 30),
    Font = Enum.Font.GothamBlack,
    Text = "KvantKeySustem",
    TextColor3 = WHITE,
    TextSize = 22,
    ZIndex = 11,
}, win)
local titleGrad = new("UIGradient", {
    Offset = Vector2.new(-1, 0),
    Color = ColorSequence.new({
        kp(0, rgb(40, 110, 255)),
        kp(0.35, rgb(120, 215, 255)),
        kp(0.5, rgb(255, 255, 255)),
        kp(0.65, rgb(120, 215, 255)),
        kp(1, rgb(40, 110, 255)),
    }),
}, title)
loop(titleGrad, 2.2, {Offset = Vector2.new(1, 0)})

local inputPos = UDim2.fromOffset(16, 52)
local inputFrame = new("Frame", {
    BackgroundColor3 = rgb(6, 10, 22),
    Position = inputPos,
    Size = UDim2.new(1, -32, 0, 40),
    BorderSizePixel = 0,
    ZIndex = 11,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, inputFrame)
local inStroke = new("UIStroke", {Thickness = 1.8, Color = WHITE}, inputFrame)
local inGrad = new("UIGradient", {
    Color = ColorSequence.new({kp(0, rgb(25, 80, 220)), kp(0.5, rgb(110, 215, 255)), kp(1, rgb(25, 80, 220))}),
}, inStroke)
loop(inGrad, 2.6, {Rotation = 360})

local box = new("TextBox", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -24, 1, 0),
    Font = Enum.Font.GothamMedium,
    Text = "",
    PlaceholderText = "",
    TextColor3 = WHITE,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 13,
}, inputFrame)

local hint = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -24, 1, 0),
    Font = Enum.Font.GothamMedium,
    Text = "Enter your key...",
    TextColor3 = rgb(110, 180, 255),
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
}, inputFrame)

local blink = nil

local function startBlink()
    if blink then
        blink:Cancel()
    end
    hint.Visible = true
    hint.TextTransparency = 0.05
    blink = TweenService:Create(hint, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.85})
    blink:Play()
end

local function stopBlink()
    if blink then
        blink:Cancel()
        blink = nil
    end
    hint.Visible = false
end

startBlink()

box.Focused:Connect(function()
    stopBlink()
    tween(inStroke, 0.2, {Thickness = 2.6})
end)

box.FocusLost:Connect(function()
    tween(inStroke, 0.2, {Thickness = 1.8})
    if box.Text == "" then
        startBlink()
    end
end)

local status = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(16, 98),
    Size = UDim2.new(1, -32, 0, 34),
    Font = Enum.Font.GothamMedium,
    Text = "Press Get Key, paste the key and tap Activate.",
    TextColor3 = SOFT,
    TextSize = 13,
    TextWrapped = true,
    ZIndex = 11,
}, win)

local function setStatus(text, color)
    status.Text = text
    status.TextColor3 = color
end

local row = new("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(16, 138),
    Size = UDim2.new(1, -32, 0, 38),
    ZIndex = 11,
}, win)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, row)

local function makeButton(order, text, fill, textColor)
    local holder = new("Frame", {
        BackgroundColor3 = fill,
        Size = UDim2.new(0.5, -5, 1, 0),
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 12,
    }, row)
    new("UICorner", {CornerRadius = UDim.new(0, 10)}, holder)
    local sc = new("UIScale", {}, holder)
    local btn = new("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = textColor,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 13,
    }, holder)
    local function release()
        tween(sc, 0.12, {Scale = 1})
    end
    btn.MouseButton1Down:Connect(function()
        tween(sc, 0.08, {Scale = 0.94})
    end)
    btn.MouseButton1Up:Connect(release)
    btn.MouseLeave:Connect(release)
    return holder, btn
end

local actHolder, actBtn = makeButton(1, "Activate", WHITE, WHITE)
new("UIGradient", {Rotation = 0, Color = ColorSequence.new(rgb(30, 100, 255), rgb(80, 190, 255))}, actHolder)

local keyHolder, keyBtn = makeButton(2, "Get Key", rgb(10, 18, 40), BLUE)
new("UIStroke", {Thickness = 1.6, Color = rgb(50, 130, 255), ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, keyHolder)

_p[4] = function()
    return string.char(bit32.bxor(0x1E,0x27), (0x4B - 0x1A), (0x20 + 0x18), (0x24 + 0x0C), (0x1F + 0x12))
end

_K = function()
    return _p[1]() .. _p[2]() .. _p[3]() .. _p[4]()
end

local barBack = new("Frame", {
    BackgroundColor3 = rgb(14, 24, 52),
    Position = UDim2.new(0, 16, 1, -12),
    Size = UDim2.new(1, -32, 0, 3),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 11,
}, win)
new("UICorner", {CornerRadius = UDim.new(1, 0)}, barBack)
local barFill = new("Frame", {
    BackgroundColor3 = WHITE,
    Size = UDim2.fromScale(0, 1),
    BorderSizePixel = 0,
    ZIndex = 12,
}, barBack)
new("UICorner", {CornerRadius = UDim.new(1, 0)}, barFill)
new("UIGradient", {Color = ColorSequence.new(rgb(30, 100, 255), rgb(120, 220, 255))}, barFill)

local function shake()
    for _, dx in ipairs({7, -7, 5, -5, 2, 0}) do
        tween(inputFrame, 0.04, {Position = UDim2.new(inputPos.X.Scale, inputPos.X.Offset + dx, inputPos.Y.Scale, inputPos.Y.Offset)})
        task.wait(0.04)
    end
end

local busy = false

keyBtn.MouseButton1Click:Connect(function()
    if busy then
        return
    end
    local k = _K()
    local copied = false
    if setclipboard then
        copied = pcall(setclipboard, k)
    elseif toclipboard then
        copied = pcall(toclipboard, k)
    end
    if copied then
        setStatus("Key copied to clipboard. Paste it above.", BLUE)
    else
        stopBlink()
        box.Text = k
        setStatus("Clipboard unavailable. Key inserted into the field.", BLUE)
    end
end)

actBtn.MouseButton1Click:Connect(function()
    if busy then
        return
    end
    local entered = (box.Text:gsub("^%s*(.-)%s*$", "%1"))
    if entered == "" then
        setStatus("Enter your key first.", RED)
        return
    end
    if entered ~= _K() then
        setStatus("Invalid key. Press Get Key to copy a valid one.", RED)
        shake()
        return
    end
    busy = true
    setStatus("Success! Please wait for the script to load. Thank you for choosing us.", MINT)
    barBack.Visible = true
    tween(barFill, 2.4, {Size = UDim2.fromScale(1, 1)}, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    task.wait(2.6)
    tween(winScale, 0.35, {Scale = 0.01}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tween(dim, 0.4, {BackgroundTransparency = 1})
    if blur then
        tween(blur, 0.4, {Size = 0})
    end
    task.wait(0.45)
    if blur then
        blur:Destroy()
    end
    gui:Destroy()
    pcall(function()
        getgenv().KVANT_KEY_OK = true
    end)
    if SCRIPT_URL ~= "" then
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet(SCRIPT_URL))()
            end)
            if not ok then
                warn(err)
            end
        end)
    end
end)

local black = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = WHITE,
    BorderSizePixel = 0,
    ZIndex = 50,
}, gui)
new("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({kp(0, rgb(0, 0, 0)), kp(0.5, rgb(16, 16, 22)), kp(1, rgb(0, 0, 0))}),
}, black)
local scam = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0, 0.4),
    Size = UDim2.fromScale(1, 0.2),
    Font = Enum.Font.GothamBold,
    Text = "",
    TextColor3 = WHITE,
    TextSize = 34,
    ZIndex = 51,
}, black)

local msg = "You Get Scamm"
for i = 1, #msg do
    scam.Text = string.sub(msg, 1, i)
    task.wait(0.07)
end
for i = 1, 3 do
    scam.Text = msg .. string.rep(".", i)
    task.wait(0.35)
end
task.wait(0.55)

black:Destroy()

local blue = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = WHITE,
    BorderSizePixel = 0,
    ZIndex = 60,
}, gui)
local blueGrad = new("UIGradient", {
    Rotation = 35,
    Color = ColorSequence.new({kp(0, rgb(2, 6, 30)), kp(0.5, rgb(8, 42, 140)), kp(1, rgb(0, 10, 54))}),
}, blue)
loop(blueGrad, 5, {Rotation = 125}, Enum.EasingStyle.Sine, true)

local fade = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.2, 0),
    NumberSequenceKeypoint.new(0.8, 0),
    NumberSequenceKeypoint.new(1, 1),
})

local PERIOD = 160
local HEIGHT = 72
local MID = 36
local ECG = {
    {0, 0}, {48, 0}, {54, -4}, {60, 0}, {70, 0},
    {74, 5}, {80, -28}, {86, 12}, {91, 0},
    {104, 0}, {111, -7}, {118, 0}, {160, 0},
}

local function ecgLine(yOffset, flip, phase)
    local group = new("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, yOffset),
        Size = UDim2.fromOffset(340, HEIGHT),
        BackgroundTransparency = 1,
        ZIndex = 61,
    }, blue)
    new("UIGradient", {Transparency = fade}, group)
    local strip = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(-phase, 0),
        Size = UDim2.fromOffset(PERIOD * 4, HEIGHT),
        ZIndex = 62,
    }, group)
    local sign = flip and -1 or 1
    for p = 0, 3 do
        for i = 1, #ECG - 1 do
            local ax = p * PERIOD + ECG[i][1]
            local ay = MID + ECG[i][2] * sign
            local bx = p * PERIOD + ECG[i + 1][1]
            local by = MID + ECG[i + 1][2] * sign
            local dx = bx - ax
            local dy = by - ay
            local len = math.sqrt(dx * dx + dy * dy)
            local seg = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromOffset((ax + bx) / 2, (ay + by) / 2),
                Size = UDim2.fromOffset(len + 1.5, 2.4),
                Rotation = math.deg(math.atan2(dy, dx)),
                BackgroundColor3 = rgb(190, 232, 255),
                BorderSizePixel = 0,
                ZIndex = 63,
            }, strip)
            new("UICorner", {CornerRadius = UDim.new(1, 0)}, seg)
            new("UIStroke", {
                Thickness = 3,
                Color = rgb(40, 120, 255),
                Transparency = 0.6,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            }, seg)
        end
    end
    loop(strip, 1.1, {Position = UDim2.fromOffset(-phase - PERIOD, 0)})
    return group
end

ecgLine(-78, false, 0)
ecgLine(78, true, PERIOD / 2)

local holder = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(420, 150),
    BackgroundTransparency = 1,
    ZIndex = 62,
}, blue)
local holderScale = new("UIScale", {Scale = 0.2}, holder)
local ha = new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0.32, 0),
    Font = Enum.Font.GothamBlack,
    Text = "Ха - Ха",
    TextColor3 = WHITE,
    TextSize = 42,
    TextTransparency = 1,
    ZIndex = 63,
}, holder)
local nae = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0, 0.28),
    Size = UDim2.new(1, 0, 0.72, 0),
    Font = Enum.Font.GothamBlack,
    Text = "НАЕБАЛ)",
    TextColor3 = WHITE,
    TextSize = 78,
    TextTransparency = 1,
    ZIndex = 63,
}, holder)
local naeScale = new("UIScale", {Scale = 0.5}, nae)
new("UIStroke", {Thickness = 2, Color = rgb(0, 8, 40), Transparency = 0.35}, ha)
new("UIStroke", {Thickness = 2, Color = rgb(0, 8, 40), Transparency = 0.35}, nae)

local okFont, titleFont = pcall(function()
    return Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Italic)
end)
if okFont then
    pcall(function()
        ha.FontFace = titleFont
        nae.FontFace = titleFont
    end)
end

new("UIGradient", {
    Color = ColorSequence.new({kp(0, WHITE), kp(0.5, rgb(190, 228, 255)), kp(1, WHITE)}),
}, ha)
local naeGrad = new("UIGradient", {
    Offset = Vector2.new(-1, 0),
    Color = ColorSequence.new({kp(0, rgb(40, 120, 255)), kp(0.5, rgb(140, 220, 255)), kp(1, rgb(40, 120, 255))}),
}, nae)
loop(naeGrad, 1.8, {Offset = Vector2.new(1, 0)})

pcall(function()
    ha.MaxVisibleGraphemes = -1
    nae.MaxVisibleGraphemes = 0
end)

local flash = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = WHITE,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 90,
}, gui)
local function reveal(label, step)
    local ok = pcall(function()
        label.MaxVisibleGraphemes = 0
    end)
    if not ok then
        return
    end
    for i = 1, utf8.len(label.Text) do
        label.MaxVisibleGraphemes = i
        task.wait(step)
    end
    label.MaxVisibleGraphemes = -1
end

tween(flash, 0.5, {BackgroundTransparency = 1})
tween(holderScale, 0.5, {Scale = 1}, Enum.EasingStyle.Back)
task.wait(0.35)
pcall(function()
    ha.MaxVisibleGraphemes = -1
end)
ha.TextTransparency = 0
tween(ha, 0.25, {TextTransparency = 0})
task.wait(0.55)
pcall(function()
    nae.MaxVisibleGraphemes = -1
end)
nae.TextTransparency = 0
tween(naeScale, 0.45, {Scale = 1.15}, Enum.EasingStyle.Back)
tween(nae, 0.2, {TextTransparency = 0})
task.wait(0.15)
tween(naeScale, 0.2, {Scale = 1})
task.wait(1.3)

tween(dim, 0.7, {BackgroundTransparency = 0.4})
if blur then
    tween(blur, 0.7, {Size = 14})
end
tween(blue, 0.7, {Position = UDim2.fromScale(0, 1.15)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
task.wait(0.55)

win.Visible = true
tween(winScale, 0.55, {Scale = fit}, Enum.EasingStyle.Back)
task.wait(0.25)
blue:Destroy()
flash:Destroy()
