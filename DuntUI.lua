local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")

local Themes = {
	Orange = {
		Bg = Color3.fromRGB(245, 246, 250),
		Panel = Color3.fromRGB(252, 252, 253),
		Accent = Color3.fromRGB(255, 122, 24),
		AccentSoft = Color3.fromRGB(255, 228, 205),
		Text = Color3.fromRGB(30, 30, 38),
		SubText = Color3.fromRGB(120, 122, 135),
		Track = Color3.fromRGB(215, 218, 227),
		Stroke = Color3.fromRGB(232, 234, 241),
		OnAccent = Color3.fromRGB(255, 255, 254),
		Logo = "https://raw.githubusercontent.com/Delvase/PressureBypass/refs/heads/main/PressureAvatar.png",
	},
	Dark = {
		Bg = Color3.fromRGB(22, 23, 28),
		Panel = Color3.fromRGB(32, 33, 40),
		Accent = Color3.fromRGB(226, 228, 236),
		AccentSoft = Color3.fromRGB(68, 70, 82),
		Text = Color3.fromRGB(238, 239, 244),
		SubText = Color3.fromRGB(150, 153, 168),
		Track = Color3.fromRGB(76, 78, 90),
		Stroke = Color3.fromRGB(62, 64, 76),
		OnAccent = Color3.fromRGB(24, 25, 30),
		Logo = "https://raw.githubusercontent.com/Delvase/PressureBypass/refs/heads/main/PressureAvatarBlack.png",
		Gradients = {
			Window = {Color3.fromRGB(52, 54, 64), Color3.fromRGB(20, 21, 26), 45},
			Header = {Color3.fromRGB(58, 60, 71), Color3.fromRGB(36, 37, 45), 0},
			Section = {Color3.fromRGB(47, 49, 58), Color3.fromRGB(34, 35, 42), 90},
		},
		PixelPalette = {
			Color3.fromRGB(255, 255, 255), Color3.fromRGB(226, 226, 232), Color3.fromRGB(150, 152, 162),
			Color3.fromRGB(70, 72, 82), Color3.fromRGB(10, 10, 12),
		},
	},
	Sky = {
		Bg = Color3.fromRGB(232, 244, 255),
		Panel = Color3.fromRGB(250, 253, 255),
		Accent = Color3.fromRGB(14, 165, 233),
		AccentSoft = Color3.fromRGB(207, 234, 252),
		Text = Color3.fromRGB(22, 38, 56),
		SubText = Color3.fromRGB(96, 122, 148),
		Track = Color3.fromRGB(196, 216, 234),
		Stroke = Color3.fromRGB(212, 229, 244),
		OnAccent = Color3.fromRGB(255, 255, 254),
		Logo = "https://raw.githubusercontent.com/Delvase/PressureBypass/refs/heads/main/PressureAvatarBlue.png",
	},
}
local ThemeOrder = {"Orange", "Dark", "Sky"}
local Theme = {}
for k, v in pairs(Themes.Orange) do Theme[k] = v end
local Registry = {}

local FONT, FONT_B = Enum.Font.GothamMedium, Enum.Font.GothamBold

local function create(class, props, parent)
	local o = Instance.new(class)
	local skip = props.NoTheme
	for k, v in pairs(props) do
		if k ~= "NoTheme" then o[k] = v end
	end
	if parent then o.Parent = parent end
	if not skip and (o:IsA("GuiObject") or o:IsA("UIStroke")) then
		table.insert(Registry, o)
	end
	return o
end

local GradientList = {}

local function gradientFor(role)
	local g = Theme.Gradients and Theme.Gradients[role]
	if g then
		return ColorSequence.new(g[1], g[2]), g[3] or 90
	end
	return ColorSequence.new(role == "Window" and Theme.Bg or Theme.Panel), 90
end

local function surface(frame, role, rot)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	local seq, r = gradientFor(role)
	local g = Instance.new("UIGradient")
	g.Color = seq
	g.Rotation = rot or r
	g.Parent = frame
	table.insert(GradientList, {g = g, role = role, rot = rot})
	return g
end

local function near(a, b)
	return math.abs(a.R - b.R) < 0.002 and math.abs(a.G - b.G) < 0.002 and math.abs(a.B - b.B) < 0.002
end

local function recolor(o, map)
	local function set(prop)
		local n = map(o[prop])
		if n then o[prop] = n end
	end
	if o:IsA("UIStroke") then
		set("Color")
		return
	end
	set("BackgroundColor3")
	if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then set("TextColor3") end
	if o:IsA("TextBox") then set("PlaceholderColor3") end
	if o:IsA("ImageLabel") then set("ImageColor3") end
	if o:IsA("ScrollingFrame") then set("ScrollBarImageColor3") end
end

local function setTheme(name)
	local new = Themes[name]
	if not new then return false end
	local old = {}
	for k, v in pairs(Theme) do
		if typeof(v) == "Color3" then old[k] = v end
	end
	local function map(c)
		for k, oc in pairs(old) do
			if new[k] and near(c, oc) then return new[k] end
		end
		return nil
	end
	for k, v in pairs(new) do Theme[k] = v end
	Theme.Gradients = new.Gradients
	Theme.PixelPalette = new.PixelPalette
	Theme.Logo = new.Logo
	for i = #GradientList, 1, -1 do
		local e = GradientList[i]
		if e.g.Parent == nil then
			table.remove(GradientList, i)
		else
			local seq, r = gradientFor(e.role)
			e.g.Color = seq
			e.g.Rotation = e.rot or r
		end
	end
	for i = #Registry, 1, -1 do
		local o = Registry[i]
		if o.Parent == nil then
			table.remove(Registry, i)
		else
			recolor(o, map)
		end
	end
	return true
end
local function corner(o, r) return create("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function stroke(o, c, t)
	return create("UIStroke", {Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function pad(o, l, r, t, b)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r),
		PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b),
	}, o)
end
local function tween(o, props, t)
	TS:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end
local function makeDraggable(handle, target, canDrag)
	local dragging, startPos, startObj
	handle.InputBegan:Connect(function(i)
		if isPress(i) then
			if canDrag and not canDrag() then return end
			dragging, startPos, startObj = true, i.Position, target.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = i.Position - startPos
			local sc = target:FindFirstChildOfClass("UIScale")
			if sc and sc.Scale > 0 then d = d / sc.Scale end
			target.Position = UDim2.new(startObj.X.Scale, startObj.X.Offset + d.X, startObj.Y.Scale, startObj.Y.Offset + d.Y)
		end
	end)
end
local function label(parent, text, size, color, font, xalign)
	return create("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size or 14,
		TextColor3 = color or Theme.Text, Font = font or FONT,
		TextXAlignment = xalign or Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local DEFAULT_LOGO = "https://raw.githubusercontent.com/Delvase/PressureBypass/refs/heads/main/PressureAvatar.png"

local function resolveImage(src)
	if type(src) ~= "string" then return nil end
	if src:find("^rbxassetid://") or src:find("^rbxasset://") then return src end
	if src:match("^%d+$") then return "rbxassetid://" .. src end
	if not src:find("^https?://") then return nil end
	if not (writefile and getcustomasset) then return nil end

	local hash = 5381
	for i = 1, #src do hash = (hash * 33 + src:byte(i)) % 4294967296 end
	local name = "DuntUI_" .. hash .. ".png"

	local ok = pcall(function()
		if not (isfile and isfile(name)) then
			writefile(name, game:HttpGet(src))
		end
	end)
	if not ok then return nil end
	local ok2, asset = pcall(getcustomasset, name)
	return ok2 and asset or nil
end

local ColorNames = {
	red = Color3.fromRGB(255, 0, 0),
	black = Color3.fromRGB(0, 0, 0),
	white = Color3.fromRGB(255, 255, 255),
	yellow = Color3.fromRGB(255, 255, 0),
	green = Color3.fromRGB(0, 255, 0),
	purple = Color3.fromRGB(128, 0, 128),
	pink = Color3.fromRGB(255, 105, 180),
	brown = Color3.fromRGB(139, 69, 19),
	grey = Color3.fromRGB(128, 128, 128),
	gray = Color3.fromRGB(128, 128, 128),
}

local function parseColor(v)
	if typeof(v) == "Color3" then return v end
	if type(v) ~= "string" then return nil end
	local str = v:lower():match("^%s*(.-)%s*$")
	if ColorNames[str] then return ColorNames[str] end
	local hex = str:match("^#?(%x%x%x%x%x%x)$")
	if hex then
		return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
	end
	local h3 = str:match("^#(%x%x%x)$")
	if h3 then
		return Color3.fromRGB(tonumber(h3:sub(1, 1), 16) * 17, tonumber(h3:sub(2, 2), 16) * 17, tonumber(h3:sub(3, 3), 16) * 17)
	end
	return nil
end

local Library = {}
Library.Themes = Themes
Library.Colors = ColorNames
Library.ParseColor = parseColor
local Window, Tab, Section = {}, {}, {}
Window.__index, Tab.__index, Section.__index = Window, Tab, Section

function Library.new(cfg)
	cfg = cfg or {}
	local initialTheme = Themes[cfg.Theme] and cfg.Theme or "Orange"
	setTheme(initialTheme)
	local self = setmetatable({Flags = {}, Tabs = {}, _open = false, _token = 0, _tweens = {}, Animation = cfg.Animation or "Pixels", ThemeName = initialTheme, Locked = cfg.Locked == true, _logoCustom = cfg.Icon ~= nil}, Window)
	local lock = cfg.Lock
	if lock == true then
		lock = {Name = true, Logo = true, Subtitle = true}
	elseif type(lock) ~= "table" then
		lock = {}
	end
	self.Lock = lock
	self._scriptName = tostring(cfg.ScriptName or cfg.Title or "DuntUI")
	self._scriptCustom = cfg.ScriptName ~= nil
	self._page, self._typeToken = 0, 0
	local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local w = mobile and math.clamp(vp.X * 0.92, 340, 700) or 760
	local h = mobile and math.clamp(vp.Y * 0.85, 240, 420) or 460
	if typeof(cfg.Size) == "Vector2" then w, h = cfg.Size.X, cfg.Size.Y end
	local sbW = mobile and 104 or 140
	local colCount = cfg.Columns
	if colCount ~= 1 and colCount ~= 2 then
		colCount = (w - sbW - 28 >= 440) and 2 or 1
	end
	self.Columns = colCount
	self._sbW = sbW

	local gui = create("ScreenGui", {
		Name = "DuntUI", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
	})
	local ok = pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
	if not ok or not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
	self.Gui = gui

	local main = create("Frame", {
		Size = UDim2.fromOffset(w, h), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Visible = false,
	}, gui)
	self._scale = create("UIScale", {Scale = 1}, main)
	self.Main = main
	local shell = create("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Bg, ClipsDescendants = true,
	}, main)
	corner(shell, 16); stroke(shell, Theme.Accent, 2)
	surface(shell, "Window")
	local stage = create("Frame", {Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1}, shell)
	self._stage = stage

	local header = create("Frame", {Size = UDim2.fromOffset(w, 56)}, stage)
	surface(header, "Header", 0)
	corner(header, 16)
	local headerFill = create("Frame", {Size = UDim2.new(1, 0, 0.5, 0), Position = UDim2.fromScale(0, 0.5), BorderSizePixel = 0}, header)
	surface(headerFill, "Header", 0)
	create("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0}, header)
	local logo = create("Frame", {Size = UDim2.fromOffset(36, 36), Position = UDim2.new(0, 12, 0.5, -18), BackgroundColor3 = Theme.Accent}, header)
	corner(logo, 10)
	local fallback = create("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(11, 11), BackgroundColor3 = Theme.OnAccent, Rotation = 45}, logo)
	local logoImg = create("ImageLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ScaleType = Enum.ScaleType.Fit}, logo)
	corner(logoImg, 10)
	self._logo, self._logoImg, self._logoFallback = logo, logoImg, fallback

	local title = label(header, cfg.Title or "DuntUI", 17, Theme.Text, FONT_B)
	title.Position, title.Size = UDim2.fromOffset(58, 8), UDim2.fromOffset(160, 22)
	title.TextTruncate = Enum.TextTruncate.AtEnd
	local sub = label(header, cfg.Subtitle or "", 12, Theme.Accent)
	sub.Position, sub.Size = UDim2.fromOffset(58, 28), UDim2.fromOffset(160, 18)
	sub.TextTruncate = Enum.TextTruncate.AtEnd
	self._title, self._sub = title, sub

	local statsLbl = label(header, "", 12, Theme.SubText, FONT, Enum.TextXAlignment.Right)
	statsLbl.Size, statsLbl.Position = UDim2.fromOffset(150, 20), UDim2.new(1, -66 - 150, 0.5, -10)
	statsLbl.Visible = not mobile or w > 420

	local screenW = 144
	local screen = create("Frame", {
		Size = UDim2.fromOffset(screenW, 30), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Bg, ClipsDescendants = true, Visible = cfg.Screen ~= false and w >= 500,
	}, header)
	corner(screen, 15); stroke(screen, Theme.Stroke)
	local track = create("Frame", {Size = UDim2.new(2, 0, 1, 0), BackgroundTransparency = 1}, screen)
	local timeLbl = label(track, os.date("%H:%M:%S"), 14, Theme.Text, FONT_B, Enum.TextXAlignment.Center)
	timeLbl.Size = UDim2.new(0.5, -14, 1, 0)
	local nameLbl = label(track, "", 13, Theme.Accent, FONT_B)
	nameLbl.Size, nameLbl.Position = UDim2.new(0.5, -30, 1, 0), UDim2.new(0.5, 14, 0, 0)
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	local dots = {}
	for k = 1, 2 do
		local d = create("Frame", {
			Size = UDim2.fromOffset(4, 4), Position = UDim2.new(1, -11, 0.5, k == 1 and -7 or 3),
			BackgroundColor3 = Theme.Track, BorderSizePixel = 0,
		}, screen)
		corner(d, 2)
		dots[k] = d
	end
	self._timeLbl, self._nameLbl = timeLbl, nameLbl
	local function flip(n)
		self._page = n % 2
		tween(track, {Position = UDim2.new(-self._page, 0, 0, 0)}, 0.28)
		dots[1].BackgroundColor3 = self._page == 0 and Theme.Accent or Theme.Track
		dots[2].BackgroundColor3 = self._page == 1 and Theme.Accent or Theme.Track
		if self._page == 1 then
			self:_typeScript()
		else
			self._typeToken += 1
		end
	end
	dots[1].BackgroundColor3 = Theme.Accent
	self._flip = flip
	local hit = create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5}, screen)
	hit.InputBegan:Connect(function(i)
		if not isPress(i) then return end
		local startX, lastX = i.Position.X, i.Position.X
		local conn = UIS.InputChanged:Connect(function(m)
			if isMove(m) then lastX = m.Position.X end
		end)
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				conn:Disconnect()
				local dx = lastX - startX
				if dx >= 18 then
					flip(self._page - 1)
				else
					flip(self._page + 1)
				end
			end
		end)
	end)

	local closeBtn = create("TextButton", {
		Text = "–", Font = FONT_B, TextSize = 20, TextColor3 = Theme.Accent,
		BackgroundColor3 = Theme.AccentSoft, AutoButtonColor = false,
		Size = UDim2.fromOffset(34, 34), Position = UDim2.new(1, -46, 0.5, -17),
	}, header)
	corner(closeBtn, 17)
	makeDraggable(header, main, function() return not self.Locked end)

	local body = create("Frame", {Size = UDim2.fromOffset(w, h - 56), Position = UDim2.fromOffset(0, 56), BackgroundTransparency = 1}, stage)
	self._header, self._body, self._shell = header, body, shell

	local COLS = math.clamp(math.floor(w / 28), 12, 32)
	local ROWS = math.clamp(math.floor(h / 28), 8, 22)
	local cellLayer = create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 50}, shell)
	self._cellLayer, self._cells = cellLayer, {}
	for cx = 0, COLS - 1 do
		for cy = 0, ROWS - 1 do
			local corner4 = (cx == 0 or cx == COLS - 1) and (cy == 0 or cy == ROWS - 1)
			if not corner4 then
				local px, py = (cx + 0.5) / COLS, (cy + 0.5) / ROWS
				local f = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(px, py),
					Size = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0,
					BackgroundColor3 = Theme.Accent, NoTheme = true,
				}, cellLayer)
				local d = math.sqrt((px - 0.5) ^ 2 + (py - 0.5) ^ 2) / 0.7071
				table.insert(self._cells, {f = f, full = UDim2.new(1 / COLS, 1, 1 / ROWS, 1), d = d, k = math.random(1, 5)})
			end
		end
	end

	local buildLine = create("Frame", {
		Size = UDim2.new(1, -28, 0, 3), Position = UDim2.new(0, 14, 1, -4),
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false, ZIndex = 60,
	}, shell)
	corner(buildLine, 2)
	self._buildLine = buildLine
	local edgeLine = create("Frame", {
		Size = UDim2.new(0, 3, 1, -28), Position = UDim2.new(1, -4, 0, 14),
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false, ZIndex = 60,
	}, shell)
	corner(edgeLine, 2)
	self._edgeLine = edgeLine

	self._beams = {}
	local function beam(anchor, horizontal, rot, from, to)
		local size = horizontal and UDim2.new(0.5, 0, 0, 16) or UDim2.new(0, 16, 0.5, 0)
		local g = create("Frame", {
			AnchorPoint = anchor, Position = from, Size = size, BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.72, BorderSizePixel = 0, Visible = false, ZIndex = 70,
		}, main)
		corner(g, 8)
		create("UIGradient", {Rotation = rot, Transparency = NumberSequence.new(1, 0)}, g)
		local core = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = horizontal and UDim2.new(1, 0, 0, 4) or UDim2.new(0, 4, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 176, 90), BorderSizePixel = 0, NoTheme = true,
		}, g)
		corner(core, 2)
		create("UIGradient", {Rotation = rot, Transparency = NumberSequence.new(1, 0)}, core)
		table.insert(self._beams, {f = g, core = core, from = from, to = to, size = size, horizontal = horizontal})
	end
	beam(Vector2.new(1, 0.5), true, 0, UDim2.fromScale(0, 0.5), UDim2.fromScale(0.5, 0.5))
	beam(Vector2.new(0, 0.5), true, 180, UDim2.fromScale(1, 0.5), UDim2.fromScale(0.5, 0.5))
	beam(Vector2.new(0.5, 1), false, 90, UDim2.fromScale(0.5, 0), UDim2.fromScale(0.5, 0.5))
	beam(Vector2.new(0.5, 0), false, 270, UDim2.fromScale(0.5, 1), UDim2.fromScale(0.5, 0.5))
	local flash = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 80,
	}, main)
	corner(flash, 100)
	self._flash = flash
	local sidebar = create("Frame", {Size = UDim2.new(0, sbW, 1, 0), BackgroundColor3 = Theme.Panel}, body)
	corner(sidebar, 16)
	create("Frame", {Size = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0}, sidebar)
	create("Frame", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.fromScale(0.5, 0), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0}, sidebar)
	create("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0}, sidebar)
	local tabList = create("ScrollingFrame", {
		Size = UDim2.new(1, -1, 1, -64), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
	}, sidebar)
	create("UIListLayout", {Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}, tabList)
	pad(tabList, 0, 0, 8, 8)
	self._tabList = tabList

	local lp = Players.LocalPlayer
	local prof = create("Frame", {Size = UDim2.new(1, -16, 0, 48), Position = UDim2.new(0, 8, 1, -56), BackgroundColor3 = Theme.Bg}, sidebar)
	corner(prof, 14)
	local av = create("ImageLabel", {Size = UDim2.fromOffset(32, 32), Position = UDim2.new(0, 8, 0.5, -16), BackgroundColor3 = Theme.Track}, prof)
	corner(av, 16)
	pcall(function()
		av.Image = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)
	local pn = label(prof, lp.DisplayName, 12, Theme.Text, FONT_B)
	pn.Position, pn.Size = UDim2.fromOffset(46, 8), UDim2.new(1, -50, 0, 16)
	pn.TextTruncate = Enum.TextTruncate.AtEnd
	local pr = label(prof, cfg.Rank or "Free", 11, Theme.Accent)
	pr.Position, pr.Size = UDim2.fromOffset(46, 24), UDim2.new(1, -50, 0, 14)

	self._content = create("Frame", {Size = UDim2.new(1, -sbW - 8, 1, -8), Position = UDim2.fromOffset(sbW, 0), BackgroundTransparency = 1}, body)

	local fab = create("TextButton", {
		Text = "≡", Font = FONT_B, TextSize = 24, TextColor3 = Theme.OnAccent,
		BackgroundColor3 = Theme.Accent, AutoButtonColor = false,
		Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 12, 0.5, -22),
	}, gui)
	corner(fab, 22); stroke(fab, Theme.OnAccent, 2)
	makeDraggable(fab, fab)
	local function toggleUI() self:SetVisible(not self._open) end
	fab.MouseButton1Click:Connect(toggleUI)
	closeBtn.MouseButton1Click:Connect(toggleUI)
	local key = cfg.ToggleKey or Enum.KeyCode.RightShift
	UIS.InputBegan:Connect(function(i, gp)
		if not gp and i.KeyCode == key then toggleUI() end
	end)

	local frames, acc = 0, 0
	local lastSec = 0
	RunService.Heartbeat:Connect(function(dt)
		local now = os.time()
		if now ~= lastSec then
			lastSec = now
			timeLbl.Text = os.date("%H:%M:%S", now)
		end
		frames += 1; acc += dt
		if acc >= 0.5 then
			local fps = math.floor(frames / acc + 0.5)
			local ping = 0
			pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
			statsLbl.Text = ("%dMS  %dFPS  %d/%d"):format(ping, fps, #Players:GetPlayers(), Players.MaxPlayers)
			self._fps, self._ping = fps, ping
			self:_updateWM()
			frames, acc = 0, 0
		end
	end)

	local wm = {Enabled = true, Locked = false, FPS = true, MS = true, Time = true, Players = true, Nick = true, Name = cfg.Title or "DuntUI"}
	self.WM, self._fps, self._ping = wm, 0, 0
	local wmFrame = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 28),
		Position = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.Accent,
	}, gui)
	corner(wmFrame, 14); stroke(wmFrame, Theme.OnAccent, 1)
	pad(wmFrame, 10, 10, 0, 0)
	local wmLbl = create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 28), BackgroundTransparency = 1,
		Text = "", Font = FONT_B, TextSize = 13, TextColor3 = Theme.OnAccent,
	}, wmFrame)
	self._wmFrame, self._wmLbl = wmFrame, wmLbl
	makeDraggable(wmFrame, wmFrame, function() return not wm.Locked end)

	local st = self:Tab("Settings", nil, {Builtin = true, Order = 1000})
	local ui = st:Section("Interface")
	ui:Slider({
		Name = "UI Size", Min = 50, Max = 150, Default = 100, Increment = 5, Suffix = "%", Flag = "ui_size",
		Callback = function(v) self:SetScale(v / 100) end,
	})
	if not lock.Name then
		ui:Textbox({
			Name = "UI Name", Default = title.Text, Placeholder = "name",
			Callback = function(t) if t ~= "" then self:SetTitle(t) end end,
		})
	end
	if not lock.Subtitle then
		ui:Textbox({
			Name = "Link", Default = sub.Text, Placeholder = "t.me/...",
			Callback = function(t) self:SetSubtitle(t) end,
		})
	end
	if not lock.Logo then
		ui:Textbox({
			Name = "Logo URL", Placeholder = "https://...png",
			Callback = function(t)
				if t ~= "" then
					self:SetLogo(t)
				else
					self:ResetLogo()
				end
			end,
		})
	end
	local themeOptions, extra = {}, {}
	for _, n in ipairs(ThemeOrder) do
		if Themes[n] then table.insert(themeOptions, n) end
	end
	for n in pairs(Themes) do
		local known = false
		for _, k in ipairs(ThemeOrder) do
			if k == n then known = true end
		end
		if not known then table.insert(extra, n) end
	end
	table.sort(extra)
	for _, n in ipairs(extra) do table.insert(themeOptions, n) end
	self._themeDropdown = ui:Dropdown({
		Name = "Theme", Options = themeOptions, Default = self.ThemeName, Flag = "ui_theme",
		Callback = function(v) self:SetTheme(v) end,
	})
	self._lockToggle = ui:Toggle({
		Name = "Lock UI position", Default = self.Locked, Flag = "ui_locked",
		Callback = function(v) self.Locked = v end,
	})
	ui:Dropdown({
		Name = "Animation", Options = {"Pixels", "Build", "Diagonal", "Laser", "None"}, Default = self.Animation, Flag = "ui_anim",
		Callback = function(v) self.Animation = v end,
	})
	ui:Button({
		Name = "Replay animation",
		Callback = function()
			self:SetVisible(false)
			task.delay(1, function() self:SetVisible(true) end)
		end,
	})
	local ws = st:Section("Watermark")
	local function wmToggle(name, key, flag)
		ws:Toggle({Name = name, Default = wm[key], Flag = flag, Callback = function(v) wm[key] = v; self:_updateWM() end})
	end
	wmToggle("Show watermark", "Enabled", "wm_enabled")
	wmToggle("Lock position", "Locked", "wm_locked")
	wm.Locked = false
	wmToggle("FPS", "FPS", "wm_fps")
	wmToggle("Ping (MS)", "MS", "wm_ms")
	wmToggle("Time", "Time", "wm_time")
	wmToggle("Players", "Players", "wm_players")
	wmToggle("Nickname", "Nick", "wm_nick")
	if not lock.Name then
		ws:Textbox({
			Name = "Watermark text", Default = wm.Name, Placeholder = "text",
			Callback = function(t) wm.Name = t; self:_updateWM() end,
		})
	end
	self:_updateWM()

	if cfg.Icon ~= false then
		self:_applyLogo(cfg.Icon or Theme.Logo or DEFAULT_LOGO)
	end
	self:SetVisible(true)
	return self
end

function Window:Destroy() self.Gui:Destroy() end

function Window:SetTitle(text)
	self._title.Text = tostring(text)
	self.Gui.Name = tostring(text)
	self.WM.Name = tostring(text)
	self:_updateWM()
	if not self._scriptCustom then self:_setScript(text) end
end

function Window:SetScriptName(text)
	self._scriptCustom = true
	self:_setScript(text)
end

function Window:_setScript(text)
	self._scriptName = tostring(text)
	if self._page == 1 then self:_typeScript() end
end

function Window:_typeScript()
	self._typeToken += 1
	local token = self._typeToken
	local lbl = self._nameLbl
	local chars = {}
	for _, c in utf8.codes(self._scriptName) do table.insert(chars, utf8.char(c)) end
	lbl.Text = ""
	task.spawn(function()
		for i = 1, #chars do
			if token ~= self._typeToken or lbl.Parent == nil then return end
			lbl.Text = table.concat(chars, "", 1, i) .. "|"
			task.wait(0.07)
		end
		local on = true
		while token == self._typeToken and lbl.Parent ~= nil do
			lbl.Text = table.concat(chars) .. (on and "|" or "")
			on = not on
			task.wait(0.5)
		end
	end)
end

function Window:SetTheme(name)
	if not Themes[name] or self.ThemeName == name then return end
	self.ThemeName = name
	setTheme(name)
	if not self._logoCustom then
		self:_applyLogo(Theme.Logo or DEFAULT_LOGO)
	end
	if self._themeDropdown and self._themeDropdown:Get() ~= name then
		self._themeDropdown:Set(name)
	end
end

function Window:SetLocked(v)
	v = v == true
	self.Locked = v
	if self._lockToggle and self._lockToggle:Get() ~= v then
		self._lockToggle:Set(v)
	end
end

function Window:SetScale(s)
	self._scale.Scale = math.clamp(s, 0.3, 2)
end

function Window:_updateWM()
	local wm = self.WM
	self._wmFrame.Visible = wm.Enabled
	if not wm.Enabled then return end
	local parts = {}
	if wm.Name ~= "" then table.insert(parts, wm.Name) end
	if wm.FPS then table.insert(parts, self._fps .. " FPS") end
	if wm.MS then table.insert(parts, self._ping .. " MS") end
	if wm.Time then table.insert(parts, os.date("%H:%M:%S")) end
	if wm.Players then table.insert(parts, #Players:GetPlayers() .. "/" .. Players.MaxPlayers) end
	if wm.Nick then table.insert(parts, Players.LocalPlayer.Name) end
	self._wmLbl.Text = table.concat(parts, "  |  ")
end

function Window:SetSubtitle(text)
	self._sub.Text = tostring(text)
end

function Window:SetLogo(src)
	self._logoCustom = true
	self:_applyLogo(src)
end

function Window:ResetLogo()
	self._logoCustom = false
	self:_applyLogo(Theme.Logo or DEFAULT_LOGO)
end

function Window:_applyLogo(src)
	self._logoToken = (self._logoToken or 0) + 1
	local token = self._logoToken
	local img, fb, logo = self._logoImg, self._logoFallback, self._logo
	if not src then
		img.Visible, fb.Visible = false, true
		logo.BackgroundTransparency = 0
		return
	end
	task.spawn(function()
		local asset = resolveImage(src)
		if token ~= self._logoToken then return end
		if asset then
			img.Image = asset
			img.Visible, fb.Visible = true, false
			logo.BackgroundTransparency = 1
		else
			img.Visible, fb.Visible = false, true
			logo.BackgroundTransparency = 0
		end
	end)
end

function Window:Toggle() self:SetVisible(not self._open) end

function Window:_tw(obj, props, time, style, dir, delay)
	local t = TS:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out, 0, false, delay or 0), props)
	table.insert(self._tweens, t)
	t:Play()
	return t
end

function Window:_paintFx()
	local a = Theme.Accent
	local white = Color3.new(1, 1, 1)
	local pal = Theme.PixelPalette or {a, a:Lerp(white, 0.25), a:Lerp(white, 0.5), a:Lerp(white, 0.75), white}
	for _, c in ipairs(self._cells) do c.f.BackgroundColor3 = pal[(c.k - 1) % #pal + 1] end
	for _, b in ipairs(self._beams) do b.core.BackgroundColor3 = a:Lerp(white, 0.45) end
end

function Window:_resetAnim()
	for _, t in ipairs(self._tweens) do t:Cancel() end
	table.clear(self._tweens)
	local shell = self._shell
	shell.AnchorPoint = Vector2.new(0, 0)
	shell.Position = UDim2.fromScale(0, 0)
	shell.Size = UDim2.fromScale(1, 1)
	self._header.Visible, self._body.Visible = true, true
	self._cellLayer.Visible = false
	self._buildLine.Visible = false
	self._edgeLine.Visible = false
	shell.Visible = true
	self._stage.AnchorPoint = Vector2.new(0, 0)
	self._stage.Position = UDim2.fromScale(0, 0)
	for _, b in ipairs(self._beams) do
		b.f.Visible = false
		b.f.Size = b.size
		b.f.Position = b.from
	end
	self._flash.Visible = false
	self:_paintFx()
	self._flash.Size = UDim2.fromOffset(0, 0)
	for _, c in ipairs(self._cells) do
		c.f.Size = UDim2.new(0, 0, 0, 0)
		c.f.BackgroundTransparency = 0
	end
end

function Window:SetVisible(show)
	if self._open == show then return end
	self._open = show
	self._token += 1
	local token = self._token
	self:_resetAnim()
	local mode = self.Animation
	if show then
		self.Main.Visible = true
		if mode == "Pixels" then
			self:_pixelsIn(token)
		elseif mode == "Build" then
			self:_buildIn(token)
		elseif mode == "Diagonal" then
			self:_diagIn(token)
		elseif mode == "Laser" then
			self:_laserIn(token)
		end
	else
		if mode == "Pixels" then
			self:_pixelsOut(token)
		elseif mode == "Build" then
			self:_buildOut(token)
		elseif mode == "Diagonal" then
			self:_diagOut(token)
		elseif mode == "Laser" then
			self:_laserOut(token)
		else
			self.Main.Visible = false
		end
	end
end

function Window:_pixelsIn(token)
	local shell = self._shell
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.Position = UDim2.fromScale(0.5, 0.5)
	shell.Size = UDim2.fromScale(0.08, 0.08)
	self._header.Visible, self._body.Visible = false, false
	self._cellLayer.Visible = true
	self:_tw(shell, {Size = UDim2.fromScale(1, 1)}, 0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	for _, c in ipairs(self._cells) do
		self:_tw(c.f, {Size = c.full}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out, c.d * 0.4 + math.random() * 0.1)
	end
	task.delay(0.82, function()
		if token ~= self._token then return end
		self._header.Visible, self._body.Visible = true, true
		for _, c in ipairs(self._cells) do
			self:_tw(c.f, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.6}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, math.random() * 0.3)
		end
		task.delay(0.65, function()
			if token ~= self._token then return end
			self:_resetAnim()
		end)
	end)
end

function Window:_pixelsOut(token)
	self._cellLayer.Visible = true
	for _, c in ipairs(self._cells) do
		self:_tw(c.f, {Size = c.full}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, math.random() * 0.15)
	end
	task.delay(0.38, function()
		if token ~= self._token then return end
		local shell = self._shell
		self._header.Visible, self._body.Visible = false, false
		shell.AnchorPoint = Vector2.new(0.5, 0.5)
		shell.Position = UDim2.fromScale(0.5, 0.5)
		self:_tw(shell, {Size = UDim2.fromScale(0.08, 0.08)}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			if token ~= self._token then return end
			self.Main.Visible = false
			self:_resetAnim()
		end)
	end)
end

function Window:_buildIn(token)
	local shell = self._shell
	shell.Size = UDim2.new(1, 0, 0, 0)
	self._buildLine.Visible = true
	self:_tw(shell, {Size = UDim2.fromScale(1, 1)}, 0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	task.delay(0.8, function()
		if token ~= self._token then return end
		self:_resetAnim()
	end)
end

function Window:_diagIn(token)
	local shell = self._shell
	shell.Size = UDim2.fromScale(0, 0)
	self._buildLine.Visible, self._edgeLine.Visible = true, true
	self:_tw(shell, {Size = UDim2.fromScale(1, 1)}, 0.85, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	task.delay(0.9, function()
		if token ~= self._token then return end
		self:_resetAnim()
	end)
end

function Window:_diagOut(token)
	self._buildLine.Visible, self._edgeLine.Visible = true, true
	self:_tw(self._shell, {Size = UDim2.fromScale(0, 0)}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(0.45, function()
		if token ~= self._token then return end
		self.Main.Visible = false
		self:_resetAnim()
	end)
end

function Window:_laserIn(token)
	local shell, stage = self._shell, self._stage
	stage.AnchorPoint = Vector2.new(0.5, 0.5)
	stage.Position = UDim2.fromScale(0.5, 0.5)
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.Position = UDim2.fromScale(0.5, 0.5)
	shell.Size = UDim2.fromScale(0, 0)
	shell.Visible = false
	for _, b in ipairs(self._beams) do
		b.f.Position = b.from
		b.f.Size = b.size
		b.f.Visible = true
		self:_tw(b.f, {Position = b.to}, 0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end
	task.delay(0.36, function()
		if token ~= self._token then return end
		local flash = self._flash
		flash.Visible = true
		flash.Size = UDim2.fromOffset(10, 10)
		flash.BackgroundTransparency = 0.15
		self:_tw(flash, {Size = UDim2.fromOffset(170, 170), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		for _, b in ipairs(self._beams) do
			local gone = b.horizontal and UDim2.new(0, 0, 0, 16) or UDim2.new(0, 16, 0, 0)
			self:_tw(b.f, {Size = gone}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
		shell.Visible = true
		self:_tw(shell, {Size = UDim2.fromScale(1, 1)}, 0.65, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end)
	task.delay(1.1, function()
		if token ~= self._token then return end
		self:_resetAnim()
	end)
end

function Window:_laserOut(token)
	local shell, stage = self._shell, self._stage
	stage.AnchorPoint = Vector2.new(0.5, 0.5)
	stage.Position = UDim2.fromScale(0.5, 0.5)
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.Position = UDim2.fromScale(0.5, 0.5)
	self:_tw(shell, {Size = UDim2.fromScale(0, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	task.delay(0.45, function()
		if token ~= self._token then return end
		self.Main.Visible = false
		self:_resetAnim()
	end)
end

function Window:_buildOut(token)
	self._buildLine.Visible = true
	self:_tw(self._shell, {Size = UDim2.new(1, 0, 0, 0)}, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(0.4, function()
		if token ~= self._token then return end
		self.Main.Visible = false
		self:_resetAnim()
	end)
end

function Window:_openColor(titleText, startColor, onApply)
	if not self._cd then self._cd = self:_buildColorDialog() end
	self._cd.open(titleText, startColor, onApply)
end

function Window:_buildColorDialog()
	local DW, DH = 380, 290
	local overlay = create("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45, Active = true, Visible = false, ZIndex = 100,
	}, self.Gui)
	local dlg = create("Frame", {
		Size = UDim2.fromOffset(DW, DH), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Theme.Panel, Active = true,
	}, overlay)
	corner(dlg, 22); stroke(dlg, Theme.Accent, 2)
	local dscale = create("UIScale", {}, dlg)
	local function fit()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		dscale.Scale = math.min(1, (vp.Y * 0.92) / DH, (vp.X * 0.96) / DW)
	end

	local titleLbl = label(dlg, "", 17, Theme.Text, FONT_B)
	titleLbl.Position, titleLbl.Size = UDim2.fromOffset(18, 12), UDim2.fromOffset(DW - 36, 24)

	local sv = create("Frame", {Size = UDim2.fromOffset(170, 120), Position = UDim2.fromOffset(16, 44), BackgroundColor3 = Color3.new(1, 0, 0), NoTheme = true}, dlg)
	corner(sv, 12)
	local white = create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1)}, sv)
	corner(white, 12)
	create("UIGradient", {Transparency = NumberSequence.new(0, 1)}, white)
	local black = create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0)}, sv)
	corner(black, 12)
	create("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(1, 0)}, black)
	local svHit = create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, sv)
	local svCur = create("Frame", {Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), NoTheme = true}, sv)
	corner(svCur, 8); stroke(svCur, Theme.Text, 2)

	local hue = create("Frame", {Size = UDim2.fromOffset(14, 120), Position = UDim2.fromOffset(194, 44), BackgroundColor3 = Color3.new(1, 1, 1)}, dlg)
	corner(hue, 7)
	create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
			ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
			ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
			ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
			ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
		}),
	}, hue)
	local hueHit = create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(0, 34, 1, 0), Position = UDim2.fromOffset(-10, 0)}, hue)
	local hueCur = create("Frame", {Size = UDim2.fromOffset(18, 18), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 0, 0), NoTheme = true}, hue)
	corner(hueCur, 9); stroke(hueCur, Theme.Text, 2)

	local function field(x, y, w, suffix, placeholder)
		local f = create("Frame", {Size = UDim2.fromOffset(w, 26), Position = UDim2.fromOffset(x, y), BackgroundColor3 = Theme.Bg}, dlg)
		corner(f, 13)
		local tb = create("TextBox", {
			Size = UDim2.new(1, -66, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
			Text = "", PlaceholderText = placeholder or "", Font = FONT, TextSize = 13, TextColor3 = Theme.Text,
			PlaceholderColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false, ClipsDescendants = true,
		}, f)
		local sl = label(f, suffix, 12, Theme.SubText, FONT, Enum.TextXAlignment.Right)
		sl.Size, sl.Position = UDim2.fromOffset(46, 26), UDim2.new(1, -54, 0, 0)
		return tb
	end
	local hexBox = field(220, 44, 144, "Hex")
	local rBox = field(220, 74, 144, "Red")
	local gBox = field(220, 104, 144, "Green")
	local bBox = field(220, 134, 144, "Blue")

	local oldSw = create("Frame", {Size = UDim2.fromOffset(82, 22), Position = UDim2.fromOffset(16, 172), BackgroundColor3 = Color3.new(1, 1, 1), NoTheme = true}, dlg)
	corner(oldSw, 11); stroke(oldSw, Theme.Stroke)
	local newSw = create("Frame", {Size = UDim2.fromOffset(82, 22), Position = UDim2.fromOffset(104, 172), BackgroundColor3 = Color3.new(1, 1, 1), NoTheme = true}, dlg)
	corner(newSw, 11); stroke(newSw, Theme.Stroke)

	local namePlaceholder = "Red, Black, White, Yellow, Green, Purple, Pink, Brown, Grey"
	local nameBox = field(16, 204, 348, "Name", namePlaceholder)
	nameBox.Size = UDim2.new(1, -66, 1, 0)

	local cancel = create("TextButton", {
		Text = "Cancel", Font = FONT_B, TextSize = 15, TextColor3 = Theme.Text, AutoButtonColor = false,
		BackgroundColor3 = Theme.Panel, Size = UDim2.fromOffset(170, 38), Position = UDim2.fromOffset(16, 238),
	}, dlg)
	corner(cancel, 19); stroke(cancel, Theme.Track)
	local applyBtn = create("TextButton", {
		Text = "Apply", Font = FONT_B, TextSize = 15, TextColor3 = Theme.OnAccent, AutoButtonColor = false,
		BackgroundColor3 = Theme.Accent, Size = UDim2.fromOffset(170, 38), Position = UDim2.fromOffset(194, 238),
	}, dlg)
	corner(applyBtn, 19)

	local H, S, V = 0, 1, 1
	local applyCb
	local function curColor() return Color3.fromHSV(H, S, V) end
	local function refresh()
		local c = curColor()
		sv.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
		svCur.Position = UDim2.new(S, 0, 1 - V, 0)
		hueCur.Position = UDim2.new(0.5, 0, H, 0)
		svCur.BackgroundColor3 = c
		hueCur.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
		newSw.BackgroundColor3 = c
		local r, g, b = math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
		hexBox.Text = ("#%02x%02x%02x"):format(r, g, b)
		rBox.Text, gBox.Text, bBox.Text = tostring(r), tostring(g), tostring(b)
	end
	local function setColor(c)
		H, S, V = c:ToHSV()
		refresh()
	end

	local function rawPos(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			return Vector2.new(i.Position.X, i.Position.Y)
		end
		return UIS:GetMouseLocation()
	end
	local function svFrom(i)
		local p = rawPos(i)
		S = math.clamp((p.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
		V = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
		refresh()
	end
	local function hueFrom(i)
		local p = rawPos(i)
		H = math.clamp((p.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
		refresh()
	end
	local dragSV, dragHue = false, false
	svHit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragSV = true; svFrom(i)
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragSV = false end end)
		end
	end)
	hueHit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragHue = true; hueFrom(i)
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragHue = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if isMove(i) then
			if dragSV then svFrom(i) elseif dragHue then hueFrom(i) end
		end
	end)

	hexBox.FocusLost:Connect(function()
		local c = parseColor(hexBox.Text)
		if c then setColor(c) else refresh() end
	end)
	local function rgbEdited()
		local r, g, b = tonumber(rBox.Text), tonumber(gBox.Text), tonumber(bBox.Text)
		if r and g and b then
			setColor(Color3.fromRGB(math.clamp(math.floor(r), 0, 255), math.clamp(math.floor(g), 0, 255), math.clamp(math.floor(b), 0, 255)))
		else
			refresh()
		end
	end
	rBox.FocusLost:Connect(rgbEdited)
	gBox.FocusLost:Connect(rgbEdited)
	bBox.FocusLost:Connect(rgbEdited)
	nameBox.FocusLost:Connect(function()
		local text = nameBox.Text
		if text == "" then return end
		local c = parseColor(text)
		if c then
			setColor(c)
			nameBox.Text = ""
		else
			nameBox.Text = ""
			nameBox.PlaceholderText = "Unknown color: " .. text
			task.delay(2, function() nameBox.PlaceholderText = namePlaceholder end)
		end
	end)

	cancel.MouseButton1Click:Connect(function() overlay.Visible = false end)
	applyBtn.MouseButton1Click:Connect(function()
		if applyCb then applyCb(curColor()) end
		overlay.Visible = false
	end)

	return {
		open = function(titleText, color, cb)
			titleLbl.Text = titleText or "Color"
			applyCb = cb
			oldSw.BackgroundColor3 = color
			nameBox.Text = ""
			setColor(color)
			fit()
			overlay.Visible = true
		end,
	}
end

function Window:Tab(name, icon, opts)
	opts = opts or {}
	local tab = setmetatable({Window = self, Name = name, Builtin = opts.Builtin}, Tab)
	local btn = create("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.new(1, -16, 0, 36),
		BackgroundColor3 = Theme.AccentSoft, BackgroundTransparency = 1,
		LayoutOrder = opts.Order or (#self.Tabs + 1),
	}, self._tabList)
	corner(btn, 18)
	local bar = create("Frame", {Size = UDim2.fromOffset(3, 18), Position = UDim2.new(0, 0, 0.5, -9), BackgroundColor3 = Theme.Accent, Visible = false}, btn)
	corner(bar, 2)
	local x = 10
	if icon then
		create("ImageLabel", {Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, 10, 0.5, -9), BackgroundTransparency = 1, Image = icon, ImageColor3 = Theme.SubText}, btn)
		x = 34
	end
	local lbl = label(btn, name, 14, Theme.SubText)
	lbl.Position, lbl.Size = UDim2.fromOffset(x, 0), UDim2.new(1, -x - 4, 1, 0)
	lbl.TextTruncate = Enum.TextTruncate.AtEnd

	local page = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
	}, self._content)
	create("UIListLayout", {Padding = UDim.new(0, 8)}, page)
	pad(page, 10, 10, 10, 10)
	tab.Page = page
	local two = self.Columns == 2
	local cols = create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, page)
	create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, cols)
	tab._cols, tab._n = {}, 0
	for i = 1, two and 2 or 1 do
		local c = create("Frame", {
			Size = two and UDim2.new(0.5, -4, 0, 0) or UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = i,
		}, cols)
		create("UIListLayout", {Padding = UDim.new(0, 8)}, c)
		tab._cols[i] = c
	end

	function tab:_set(on)
		page.Visible = on; bar.Visible = on
		tween(btn, {BackgroundTransparency = on and 0 or 1})
		lbl.TextColor3 = on and Theme.Accent or Theme.SubText
		local img = btn:FindFirstChildOfClass("ImageLabel")
		if img then img.ImageColor3 = on and Theme.Accent or Theme.SubText end
	end
	btn.MouseButton1Click:Connect(function() self:Select(tab) end)
	table.insert(self.Tabs, tab)
	if not self._selected or (self._selected.Builtin and not tab.Builtin) then self:Select(tab) end
	return tab
end

function Window:Select(tab)
	self._selected = tab
	for _, t in ipairs(self.Tabs) do t:_set(t == tab) end
end

function Tab:Section(name, side)
	local sec = setmetatable({Window = self.Window, Tab = self}, Section)
	local idx = 1
	if #self._cols == 2 then
		local sd = type(side) == "string" and side:lower() or nil
		if sd == "left" then
			idx = 1
		elseif sd == "right" then
			idx = 2
		else
			idx = (self._n % 2) + 1
		end
	end
	self._n += 1
	local frame = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Panel,
	}, self._cols[idx])
	corner(frame, 16); stroke(frame, Theme.Stroke)
	surface(frame, "Section")
	create("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, frame)
	pad(frame, 12, 12, 10, 10)
	local t = label(frame, string.upper(name), 12, Theme.Accent, FONT_B)
	t.Size, t.LayoutOrder = UDim2.new(1, 0, 0, 18), -2
	create("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, LayoutOrder = -1}, frame)
	sec.Items = frame
	return sec
end

local function row(sec, h)
	return create("Frame", {Size = UDim2.new(1, 0, 0, h or 32), BackgroundTransparency = 1, ClipsDescendants = true}, sec.Items)
end
local function setFlag(sec, cfg, v)
	if cfg.Flag then sec.Window.Flags[cfg.Flag] = v end
end

function Section:Label(text)
	local r = row(self, 24)
	local l = label(r, text, 13, Theme.SubText)
	l.Size = UDim2.fromScale(1, 1)
	return {Set = function(_, v) l.Text = v end}
end

function Section:Button(cfg)
	local b = create("TextButton", {
		Text = cfg.Name or "Button", Font = FONT_B, TextSize = 14, TextColor3 = Theme.Accent,
		BackgroundColor3 = Theme.AccentSoft, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 32),
	}, self.Items)
	corner(b, 16)
	b.MouseButton1Click:Connect(function()
		tween(b, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.OnAccent}, 0.08)
		task.delay(0.12, function() tween(b, {BackgroundColor3 = Theme.AccentSoft, TextColor3 = Theme.Accent}) end)
		if cfg.Callback then task.spawn(cfg.Callback) end
	end)
end

function Section:Toggle(cfg)
	local state = cfg.Default or false
	local r = row(self)
	local l = label(r, cfg.Name or "Toggle", 14)
	l.Size = UDim2.new(1, -50, 1, 0)
	local sw = create("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -38, 0.5, -10), BackgroundColor3 = Theme.Track,
	}, r)
	corner(sw, 10)
	local knob = create("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.OnAccent}, sw)
	corner(knob, 7)
	local obj = {}
	local function apply(v, fire)
		state = v
		tween(sw, {BackgroundColor3 = v and Theme.Accent or Theme.Track})
		tween(knob, {Position = v and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
		setFlag(self, cfg, v)
		if fire and cfg.Callback then task.spawn(cfg.Callback, v) end
	end
	function obj:Set(v) apply(v, true) end
	function obj:Get() return state end
	sw.MouseButton1Click:Connect(function() apply(not state, true) end)
	apply(state, false)
	return obj
end

function Section:Slider(cfg)
	local min, max, inc = cfg.Min or 0, cfg.Max or 100, cfg.Increment or 1
	local value = math.clamp(cfg.Default or min, min, max)
	local dec, scaled = 0, inc
	while dec < 8 and math.abs(scaled - math.floor(scaled + 0.5)) > 1e-7 do
		scaled = scaled * 10
		dec += 1
	end
	local fmt = "%." .. dec .. "f"
	local function snap(v)
		v = min + math.floor((v - min) / inc + 0.5) * inc
		v = math.clamp(v, min, max)
		return tonumber(fmt:format(v))
	end
	local function show(v)
		local t = fmt:format(v)
		if dec > 0 then
			t = t:gsub("0+$", "")
			t = t:gsub("%.$", "")
		end
		return t
	end
	local r = row(self)
	local l = label(r, cfg.Name or "Slider", 14)
	l.Size = UDim2.new(0.4, 0, 1, 0)
	local box = label(r, "", 13, Theme.Text, FONT_B, Enum.TextXAlignment.Center)
	box.Size, box.Position, box.BackgroundTransparency = UDim2.fromOffset(42, 22), UDim2.new(1, -42, 0.5, -11), 0
	box.BackgroundColor3 = Theme.Bg
	corner(box, 11)
	box.TextScaled = true
	create("UITextSizeConstraint", {MaxTextSize = 13, MinTextSize = 7}, box)
	local track = create("Frame", {
		Size = UDim2.new(0.6, -62, 0, 6), Position = UDim2.new(0.4, 4, 0.5, -3), BackgroundColor3 = Theme.Track,
	}, r)
	corner(track, 3)
	local fill = create("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent}, track)
	corner(fill, 3)
	local knob = create("Frame", {Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Theme.OnAccent}, track)
	corner(knob, 7); stroke(knob, Theme.Accent, 2)
	local hit = create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0.5, -14)}, track)

	local obj = {}
	local function apply(v, fire)
		v = snap(v)
		value = v
		local rel = (max == min) and 0 or (v - min) / (max - min)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		box.Text = show(v) .. (cfg.Suffix or "")
		setFlag(self, cfg, v)
		if fire and cfg.Callback then task.spawn(cfg.Callback, v) end
	end
	function obj:Set(v) apply(v, true) end
	function obj:Get() return value end

	local dragging = false
	local page = self.Tab.Page
	local function fromInput(i)
		local rel = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		apply(min + (max - min) * rel, true)
	end
	hit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true; page.ScrollingEnabled = false
			fromInput(i)
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false; page.ScrollingEnabled = true end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then fromInput(i) end
	end)
	apply(value, false)
	return obj
end

function Section:Dropdown(cfg)
	local options = cfg.Options or {}
	local multi = cfg.Multi == true
	local selected, current = {}, nil
	local def = cfg.Default
	if multi then
		if type(def) == "table" then
			for _, v in ipairs(def) do selected[v] = true end
		elseif def ~= nil then
			selected[def] = true
		end
	else
		if type(def) == "table" then def = def[1] end
		current = def
		if current == nil then current = options[1] end
	end

	local r = row(self)
	local l = label(r, cfg.Name or "Dropdown", 14)
	l.Size = UDim2.new(0.5, 0, 0, 32)
	local btn = create("TextButton", {
		Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.Bg,
		Size = UDim2.new(0.5, -2, 0, 28), Position = UDim2.new(0.5, 2, 0, 2),
	}, r)
	corner(btn, 14); stroke(btn, Theme.Stroke)
	local cur = label(btn, "", 13, Theme.Text)
	cur.Position, cur.Size = UDim2.fromOffset(12, 0), UDim2.new(1, -34, 1, 0)
	cur.TextTruncate = Enum.TextTruncate.AtEnd
	local arrow = label(btn, ">", 14, Theme.SubText, FONT_B, Enum.TextXAlignment.Center)
	arrow.Size, arrow.Position, arrow.Rotation = UDim2.fromOffset(20, 28), UDim2.new(1, -24, 0, 0), 90

	local listH = math.min(#options * 28 + 8, 148)
	local list = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, listH), Position = UDim2.fromOffset(0, 36), BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
	}, r)
	corner(list, 14)
	create("UIListLayout", {Padding = UDim.new(0, 2)}, list)
	pad(list, 4, 4, 4, 4)

	local buttons = {}
	local function value()
		if not multi then return current end
		local t = {}
		for _, o in ipairs(options) do if selected[o] then table.insert(t, o) end end
		return t
	end
	local function refreshUI()
		if multi then
			local t = value()
			local names = {}
			for _, o in ipairs(t) do table.insert(names, tostring(o)) end
			cur.Text = #names > 0 and table.concat(names, ", ") or "None"
		else
			cur.Text = tostring(current)
		end
		for opt, b in pairs(buttons) do
			local on = (multi and selected[opt]) or (not multi and current == opt)
			b.BackgroundTransparency = on and 0 or 1
			b.TextColor3 = on and Theme.Accent or Theme.Text
		end
	end
	local function fire()
		setFlag(self, cfg, value())
		if cfg.Callback then task.spawn(cfg.Callback, value()) end
	end

	local open = false
	local function setOpen(v)
		open = v
		tween(arrow, {Rotation = v and -90 or 90})
		tween(r, {Size = UDim2.new(1, 0, 0, v and (40 + listH) or 32)})
	end
	for _, opt in ipairs(options) do
		local o = create("TextButton", {
			Text = tostring(opt), Font = FONT, TextSize = 13, TextColor3 = Theme.Text,
			BackgroundColor3 = Theme.AccentSoft, BackgroundTransparency = 1,
			AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 26),
		}, list)
		corner(o, 13)
		buttons[opt] = o
		o.MouseButton1Click:Connect(function()
			if multi then
				selected[opt] = (not selected[opt]) or nil
				refreshUI(); fire()
			else
				current = opt
				refreshUI(); fire()
				setOpen(false)
			end
		end)
	end
	btn.MouseButton1Click:Connect(function() setOpen(not open) end)

	local obj = {}
	function obj:Set(v)
		if multi then
			selected = {}
			if type(v) == "table" then
				for _, o in ipairs(v) do selected[o] = true end
			elseif v ~= nil then
				selected[v] = true
			end
		else
			if type(v) == "table" then v = v[1] end
			current = v
		end
		refreshUI(); fire()
	end
	function obj:Get() return value() end
	refreshUI()
	setFlag(self, cfg, value())
	return obj
end

function Section:ColorPicker(cfg)
	local color = parseColor(cfg.Default) or Color3.fromRGB(255, 122, 24)
	local r = row(self)
	local l = label(r, cfg.Name or "Color", 14)
	l.Size = UDim2.new(1, -60, 1, 0)
	local sw = create("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(44, 22),
		Position = UDim2.new(1, -44, 0.5, -11), BackgroundColor3 = color, NoTheme = true,
	}, r)
	corner(sw, 11); stroke(sw, Theme.Stroke, 1)
	local obj = {}
	local function apply(c, fire)
		color = c
		sw.BackgroundColor3 = c
		setFlag(self, cfg, c)
		if fire and cfg.Callback then task.spawn(cfg.Callback, c) end
	end
	function obj:Set(v)
		local c = parseColor(v)
		if c then apply(c, true) end
	end
	function obj:Get() return color end
	sw.MouseButton1Click:Connect(function()
		self.Window:_openColor(cfg.Name or "Color", color, function(c) apply(c, true) end)
	end)
	apply(color, false)
	return obj
end

function Section:Textbox(cfg)
	local r = row(self)
	local l = label(r, cfg.Name or "Textbox", 14)
	l.Size = UDim2.new(0.5, 0, 1, 0)
	local tb = create("TextBox", {
		Text = cfg.Default or "", PlaceholderText = cfg.Placeholder or "", Font = FONT, TextSize = 13,
		TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, ClearTextOnFocus = false,
		BackgroundColor3 = Theme.Bg, Size = UDim2.new(0.5, -2, 0, 28), Position = UDim2.new(0.5, 2, 0, 2),
	}, r)
	corner(tb, 14); stroke(tb, Theme.Stroke)
	tb.FocusLost:Connect(function()
		setFlag(self, cfg, tb.Text)
		if cfg.Callback then task.spawn(cfg.Callback, tb.Text) end
	end)
	return tb
end

return Library
