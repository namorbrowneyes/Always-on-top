-- Always-on-Top for macOS — Hammerspoon port of namorbrowneyes/Always-on-top (AHK v2).
--   Press the toggle key to pin the focused window on top; press again to unpin it.
--   Each pinned window gets its own 🔒 badge that follows its corner.
--   You can pin as MANY windows as you like — toggling only affects the focused one.
--
-- macOS has no public API to set another app's window level, so "on top" is
-- enforced by re-raising pinned windows whenever another window comes forward.
-- hs.window:raise() does NOT steal keyboard focus, so you keep typing where you are.
-- The 🔒 badges are Hammerspoon's OWN canvas windows, which we CAN force on top.

local M = {}

-- ── Configuration ────────────────────────────────────────────────────────────
local CONFIG = {
  mods   = {"ctrl"},   -- modifier(s); AHK "^" = ctrl
  key    = "space",    -- toggle key  (Ctrl+Space, matching the Windows build)
  corner = "TopLeft",  -- TopLeft | TopRight | BottomLeft | BottomRight
  size   = 30,         -- core badge size in points (Retina handled automatically)

  -- Pulsing neon badge, amber/gold
  accent    = { red = 1.0, green = 0.75, blue = 0.10 }, -- amber/gold halo + rim
  halo      = 14,      -- glow padding around the core badge (points)
  glowMin   = 4,       -- min glow blur radius
  glowMax   = 16,      -- max glow blur radius (peak of the pulse)
  pulseSecs = 2.0,     -- full breathe cycle (in → out) duration
}
-- ─────────────────────────────────────────────────────────────────────────────

local CANVAS = CONFIG.size + CONFIG.halo * 2  -- full canvas incl. room for the glow

local pinned  = {}   -- [winId] = { win = hs.window, canvas = hs.canvas }
local follower       -- hs.timer: keeps every badge glued to its window corner
local pulser         -- hs.timer: animates the breathing glow on all badges
local wfilter        -- hs.window.filter: re-raises pinned windows
local phase = 0      -- shared animation phase accumulator

local function buildCanvas()
  local s, h, a = CONFIG.size, CONFIG.halo, CONFIG.accent
  local c = hs.canvas.new({ x = 0, y = 0, w = CANVAS, h = CANVAS })
  c:level(hs.canvas.windowLevels.overlay)          -- above normal app windows
  c:behaviorAsLabels({ "canJoinAllSpaces", "stationary", "fullScreenAuxiliary" })
  c:canvasMouseEvents(false, false, false, false)  -- click-through
  c:appendElements(
    {
      -- dark core with an accent rim; its accent-colored shadow IS the neon glow
      type = "rectangle", action = "strokeAndFill",
      frame = { x = h, y = h, w = s, h = s },
      fillColor = { red = 0.04, green = 0.04, blue = 0.05, alpha = 0.85 },
      strokeColor = { red = a.red, green = a.green, blue = a.blue, alpha = 0.95 },
      strokeWidth = 2,
      roundedRectRadii = { xRadius = 7, yRadius = 7 },
      withShadow = true,
      shadow = { blurRadius = CONFIG.glowMin,
                 color = { red = a.red, green = a.green, blue = a.blue, alpha = 0.9 },
                 offset = { h = 0, w = 0 } },
    },
    {
      type = "text", text = "🔒",
      textSize = math.floor(s * 0.60), textAlignment = "center",
      textColor = { white = 1 },
      frame = { x = h, y = h + s * 0.12, w = s, h = s },
    }
  )
  return c
end

local function placeCanvas(entry)
  local f = entry.win:frame()
  local s, h = CONFIG.size, CONFIG.halo
  local right  = (CONFIG.corner == "TopRight" or CONFIG.corner == "BottomRight")
  local bottom = (CONFIG.corner == "BottomLeft" or CONFIG.corner == "BottomRight")
  -- place the CORE at the window corner; canvas origin backs off by the halo
  local coreX = right  and (f.x + f.w - s) or f.x
  local coreY = bottom and (f.y + f.h - s) or f.y
  entry.canvas:topLeft({ x = coreX - h, y = coreY - h })
end

-- Breathing glow: oscillate every badge's shadow blur (and rim alpha) sinusoidally.
local function pulseAll()
  phase = phase + 0.03
  local t = 0.5 + 0.5 * math.sin(phase * (2 * math.pi / CONFIG.pulseSecs))
  local a = CONFIG.accent
  local blur = CONFIG.glowMin + (CONFIG.glowMax - CONFIG.glowMin) * t
  for _, entry in pairs(pinned) do
    entry.canvas[1].shadow = {
      blurRadius = blur,
      color = { red = a.red, green = a.green, blue = a.blue, alpha = 0.55 + 0.45 * t },
      offset = { h = 0, w = 0 },
    }
    entry.canvas[1].strokeColor = { red = a.red, green = a.green, blue = a.blue, alpha = 0.6 + 0.4 * t }
  end
end

-- Re-raise any pinned window that has slipped below a normal (non-pinned) window.
-- Driven by polling the real z-order rather than focus events, because some apps
-- (notably Microsoft Remote Desktop) take focus inside an embedded view or
-- reorder themselves without emitting a windowFocused event we'd otherwise catch.
-- Windows already on top are left alone, so there's no flicker.
local function raisePinnedAboveNormal()
  local ordered = hs.window.orderedWindows()   -- front (1) → back
  local firstNormal
  for i, w in ipairs(ordered) do
    if not pinned[w:id()] then firstNormal = i; break end
  end
  if not firstNormal then return end           -- nothing normal in front of anything
  for i = firstNormal + 1, #ordered do
    local w = ordered[i]
    if pinned[w:id()] then w:raise() end        -- pinned but below a normal window → lift it
  end
end

local raiseTick = 0

-- Reposition every badge; drop any whose window has vanished/hidden.
local function followAll()
  for id, entry in pairs(pinned) do
    if entry.win:isVisible() then
      placeCanvas(entry)
    else
      M.unpinId(id)
    end
  end
  raiseTick = (raiseTick + 1) % 3              -- ~every 0.3s alongside the 0.1s badge follow
  if raiseTick == 0 then raisePinnedAboveNormal() end
end

local function timersRunning() return follower ~= nil end

local function startTimers()
  if timersRunning() then return end
  follower = hs.timer.doEvery(0.1, followAll)
  pulser   = hs.timer.doEvery(0.03, pulseAll)   -- ~33fps breathing glow
  wfilter  = hs.window.filter.new(nil)
  wfilter:subscribe(hs.window.filter.windowFocused, function(w)
    if not w then return end
    -- If a pinned window was just focused, it's already frontmost — don't raise
    -- the others over it (that would make same-app pinned windows fight, e.g.
    -- two Terminal windows shoving each other behind). Only raise pinned windows
    -- above a NON-pinned window that just came forward.
    if pinned[w:id()] then return end
    for _, entry in pairs(pinned) do
      entry.win:raise()
    end
  end)
end

local function stopTimers()
  if follower then follower:stop(); follower = nil end
  if pulser   then pulser:stop();   pulser   = nil end
  if wfilter  then wfilter:unsubscribeAll(); wfilter = nil end
end

function M.pinId(win)
  local id = win:id()
  if pinned[id] then return end
  local entry = { win = win, canvas = buildCanvas() }
  pinned[id] = entry
  placeCanvas(entry)
  entry.canvas:show()
  win:raise()
  startTimers()
end

function M.unpinId(id)
  local entry = pinned[id]
  if not entry then return end
  if entry.canvas then entry.canvas:delete() end
  pinned[id] = nil
  if not next(pinned) then stopTimers() end   -- nothing left → idle, no timers
end

function M.toggle()
  local win = hs.window.focusedWindow()
  if not win then return end
  local id = win:id()
  if pinned[id] then
    M.unpinId(id)
    hs.alert.show("📍 Unpinned")
  else
    M.pinId(win)
    hs.alert.show("📌 Pinned on top")
  end
end

-- Unpin everything (used on reload so stale canvases don't linger).
function M.unpinAll()
  for id in pairs(pinned) do M.unpinId(id) end
end

hs.hotkey.bind(CONFIG.mods, CONFIG.key, M.toggle)

return M
