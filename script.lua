--[[
    TITRE: UNDETEK xhub — Sniper Duels
    DESCRIPTION: Aimbot camera (no-hook, anti-crash), triggerbot, prediction +
    range track, ESP. Au boot: Start Safe Script | Start Rage Script.
    Safe = visee humanisee, toujours precise (0 miss). Rage = snap brut.
    360 Auto: capture sphere + cam libre + tir auto (micro-flick).
    UI blanche compacte, RightShift.
    100% standalone (no hub / no HttpGet), executor Xeno.

    VERSION: 3.6 (2026-08-07)
    CIBLE: Roblox "Sniper Duels" (place 109397169461300) • Executor: Xeno

    v3.6 — FIX 360 Auto (flick trop court + LOS derriere):
      * flickFire: hold snap 2–3 RenderStepped + ~60ms AVANT restoreCam
      * full360 LOS = ray Head/HRP local -> tete ennemi (pas ViewportPoint)
      * getBestTarget360: score distance 3D only (scan sphere, aucun filtre FOV)
      * Hold hardLock pendant fenetre de tir; toast 1er tir + DBG optionnel
      * Safe/Rage: aim+trig+full360 toujours ON au Start

    v3.5 — 360 Auto · cam libre · tir auto (Safe + Rage):
      * CFG.full360 ON: acquisition sphere 360 (ignore aimFov/trigFov)
      * Cam libre (freeCam): pas de lock continu — look normal joueur
      * Micro-flick no-hook: save CFrame -> snap aimFirePos 1 frame -> fire -> restore
      * Auto-fire des qu'une cible valide (range + mur + equipe)
      * Toggle UI "360 Auto" · default ON Safe et Rage

    v3.4 — Rage FOV / aggro a fond:
      * aimFov / trigFov / aimReleaseFov = 999 (ecran entier, px)
      * sticky ON · smooth 0 · cooldown 0 · predict + range track max
      * Camera FieldOfView 120 (max Roblox) apres Start Rage
      * Cercle FOV = rayon aim/trig reel (999)
      * Safe inchange: humanise + 0 miss

    v3.3 — Safe = humanise + 0 miss (aussi fort / mieux que Rage):
      * Split aimDisplayPos (camera humanisee) vs aimFirePos (tete+predict exact)
      * Fenetre de tir: camera + gate = aimFirePos (offsets humanize hors ray)
      * Safe FOV / trigger / predict = niveau Rage (ou +) — plus de nerf
      * Retire jitter VIM / delay Safe qui faisaient rater
      * Labels: Safe = humanise · 0 miss · aussi fort | Rage = snap brut

    BUILD 100% NO-HOOK (aucun hook executor -> aucun crash sur ce Xeno):
      * Tir = RAYCAST camera. Micro-flick CFrame (pas de Silent Aim hook).
      * Retire: Silent Aim / Kill Aura (hooks -> crash Xeno).

    Ennemis: Workspace.Characters
      * plat:  Workspace.Characters.<username>
      * duel:  Workspace.Characters.{uuid}.A|B.<username>
      * model: HumanoidRootPart, Head, Humanoid (PredictedHealth/Health>0 = vivant)
      * PAS de Teams Roblox -> l'equipe A/B vient du dossier ancetre "A"/"B".

    Menu: touche  RightShift . Bouton UNLOAD dans le menu.
]]

if getgenv and getgenv().__XHUB_SNIPER_STANDALONE then
    pcall(function() getgenv().__XHUB_SNIPER_STANDALONE_UNLOAD() end)
end

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local StarterGui        = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- FOV camera forcee a 120 deg (max Roblox) au lancement — non reglable menu
local FIXED_FOV = 120

local VERSION = "3.6"

----------------------------------------------------------------------
-- CONFIG (RAGE defaults — appliques apres choix boot; combat OFF tant que pas choisi)
----------------------------------------------------------------------
local CFG = {
    -- AIMBOT camera (no-hook) — defaults MAX (RAGE)
    aimEnabled     = false,   -- active apres Start Safe/Rage
    aimAlways      = false,
    aimHoldMouse2  = true,
    aimSmoothing   = 0,       -- 0 = snap max (reactif) — RAGE
    aimFov         = 999,     -- ecran entier (px) — RAGE a fond
    aimReleaseFov  = 999,     -- sticky = meme plafond
    aimPart        = "Head",
    aimSticky      = true,
    aimMouseNudge  = false,
    showFovCircle  = true,

    -- TRIGGERBOT — defaults MAX (RAGE)
    trigEnabled       = false,  -- active apres boot
    trigFov           = 999,    -- ecran entier (px) — RAGE a fond
    trigCooldown      = 0,      -- min = tir le plus rapide
    fireDelay         = 0.02,   -- min (clamp code >= 0.02)
    alignThreshold    = 8.0,    -- max (hard snap)
    trigOnlyWhenLocked= false,
    trigHardSnap      = true,   -- RAGE: snap dur avant tir
    trigSettleFrames  = 0,
    trigScopeDelay    = 0,

    visibleOnly    = true,
    teamCheck      = true,

    -- ESP — defaults MAX
    espEnabled     = false,   -- active apres boot
    espBox         = true,
    espName        = true,
    espHealth      = true,
    espTracer      = false,
    espRainbow     = false,
    espMaxDistance = 250,     -- max affichage / portee cible

    -- PREDICT — RAGE max
    predEnabled      = true,
    predScale        = 1.25,
    predBulletSpeed  = 2800,
    predExtraMs      = 45,
    predAccel        = true,  -- RAGE: accel lead ON
    predIter         = 3,
    predMaxStuds     = 8.0,   -- plafond lead (studs) — RAGE
    predMaxSpeed     = 64,    -- vitesse max comptee

    -- RANGE TRACK — RAGE max
    rangeTrack       = true,
    rangeDrop        = true,
    rangeDropScale   = 0.18,
    rangeGravity     = 196.2,
    rangeLeadBoost   = 0.14,
    rangeNear        = 35,

    -- CROUCH au tir (Ctrl ~1s pour precision noscope)
    crouchOnFire     = true,
    crouchFireSec    = 1.0,   -- duree accroupi apres chaque tir trigger

    -- SAFE humanize DISPLAY only (camera path). Fire ray = aimFirePos exact.
    safeGaussStuds   = 0.045, -- bruit monde entre les tirs (pas sur le ray)
    safePxMin        = 2,     -- drift pixels L/R (et leger U/D) — look only
    safePxMax        = 7,
    safeSmoothTime   = 0.16,  -- expo / cinematographique (secondes)
    safeBezierSec    = 0.22,  -- duree interpolation Bezier vers cible
    safeOvershootP   = 0.010, -- proba micro-overshoot / frame (look only)

    -- 360 Auto: capture sphere + cam libre + tir auto (micro-flick)
    full360          = true,  -- ignore FOV cone; range + wall + team
}

-- La portee cible/aim suit la meme limite que l'ESP (proches uniquement)
local function maxDist() return CFG.espMaxDistance end

local function applyFixedFov()
    Camera = Workspace.CurrentCamera
    if not Camera then return end
    pcall(function()
        if State.savedFov == nil then
            State.savedFov = Camera.FieldOfView
        end
        Camera.FieldOfView = FIXED_FOV
    end)
end

local function restoreFixedFov()
    if State.savedFov == nil then return end
    pcall(function()
        local cam = Workspace.CurrentCamera
        if cam then cam.FieldOfView = State.savedFov end
    end)
    State.savedFov = nil
end

local function enforceFixedFov()
    local cam = Workspace.CurrentCamera
    if not cam or not State.alive then return end
    if math.abs((cam.FieldOfView or 0) - FIXED_FOV) > 0.05 then
        pcall(function() cam.FieldOfView = FIXED_FOV end)
    end
end

----------------------------------------------------------------------
-- THEME creme / couleurs
----------------------------------------------------------------------
local COL_CREAM   = Color3.fromRGB(245, 241, 232)
local COL_INK     = Color3.fromRGB(30, 28, 24)
local COL_ENEMY   = Color3.fromRGB(235, 90, 90)
local COL_VIS     = Color3.fromRGB(235, 235, 235)
local COL_TEAM_A  = Color3.fromRGB(80, 160, 255)   -- bleu
local COL_TEAM_B  = Color3.fromRGB(255, 150, 70)   -- orange
local COL_TARGET  = Color3.fromRGB(120, 255, 140)  -- cible verrouillee
local COL_FOV     = Color3.fromRGB(235, 235, 235)

local function rainbow()
    return Color3.fromHSV((tick() * 0.25) % 1, 0.75, 1)
end

local function teamColor(tag)
    if CFG.espRainbow then return rainbow() end
    if tag == "A" then return COL_TEAM_A end
    if tag == "B" then return COL_TEAM_B end
    return COL_ENEMY
end

----------------------------------------------------------------------
-- STATE
----------------------------------------------------------------------
local State = {
    conns         = {},
    drawings      = {},   -- [model] = {box,name,hp,hpbg,tracer}
    alive         = true,
    holdingM2     = false,
    m2Since       = 0,      -- tick() du dernier clic droit (animation ADS)
    currentTarget = nil,  -- model sticky
    lastFire      = 0,
    firing        = false,
    locked        = false, -- une cible est verrouillee
    aligned       = false, -- la camera est alignee sur la tete (sous seuil)
    trigReady     = false, -- cooldown pret
    settleLeft    = 0,     -- frames a attendre apres hard-snap avant fire
    myTeamTag     = nil,
    renderBound   = false,
    fovCircle     = nil,
    -- perf cache
    targetsCache  = nil,
    targetsAt     = 0,
    targetsTTL    = 0.18,  -- refresh liste cibles ~5/sec max
    teamTagAt     = 0,
    teamTagTTL    = 2.0,
    rayFilter     = nil,
    rayFilterAt   = 0,
    visCache      = {},    -- [part] = {t=time, ok=bool}
    visCacheTTL   = 0.12,
    espFrameSkip  = 0,
    lastEngage    = 0,
    predTrack     = {},   -- [model] = {pos, vel, acc, t}
    predSmooth    = {},   -- [model] = Vector3 lissage point visé
    predPruneAt   = 0,
    lastRange     = 0,    -- studs vers cible lock
    lastLeadMs    = 0,    -- ms temps vol estime
    crouchPulseId = 0,
    crouchHeld    = false,
    csrFolder     = nil,
    savedCamMode  = nil,
    savedMinZoom  = nil,
    savedMaxZoom  = nil,
    savedFov      = nil,
    -- boot Safe/Rage
    scriptMode    = nil,   -- "safe"|"rage"
    bootReady     = false,
    -- 360 Auto: cam libre (pas de lock continu) — flick uniquement au tir
    freeCam       = true,
    -- toast une seule fois au 1er tir 360 reussi
    first360FireToast = false,
    -- humanize SAFE (look only — fire window = exact head/predict)
    humPxOff      = Vector2.zero,
    humPxTarget   = Vector2.zero,
    humPxRetarget = 0,
    humBezierT    = 0,
    humBezierModel= nil,
    humOverUntil  = 0,
    humLastT      = 0,
    humLastLook   = nil,
}

local hasDrawing = pcall(function() return Drawing and Drawing.new end)

----------------------------------------------------------------------
-- HELPERS cibles
----------------------------------------------------------------------
local function effectiveHealth(hum)
    if not hum then return 0 end
    local ok, pred = pcall(function() return hum:GetAttribute("PredictedHealth") end)
    if ok and type(pred) == "number" then return pred end
    local ok2, hp = pcall(function() return hum.Health end)
    return (ok2 and hp) or 0
end

local function isAlive(hum)
    if not hum then return false end
    if effectiveHealth(hum) <= 0 then return false end
    local ok, st = pcall(function() return hum:GetState() end)
    if ok and st == Enum.HumanoidStateType.Dead then return false end
    local ok2, ps = pcall(function() return hum.PlatformStand end)
    if ok2 and ps then return false end
    local ok3, deadTag = pcall(function() return hum:HasTag("Dead") end)
    if ok3 and deadTag then return false end
    return true
end

local function getHealth(hum)
    local hp = effectiveHealth(hum)
    local max = (pcall(function() return hum.MaxHealth end) and hum.MaxHealth) or 100
    if not max or max <= 0 then max = 100 end
    return hp or 0, max
end

local function findRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function isCharacterModel(m)
    if not (m and m:IsA("Model")) then return false end
    local hum = m:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and findRoot(m) ~= nil
end

local function isLocalModel(m)
    if not m then return false end
    if m == LocalPlayer.Character then return true end
    if Players:GetPlayerFromCharacter(m) == LocalPlayer then return true end
    return m.Name == LocalPlayer.Name or m.Name == LocalPlayer.DisplayName
end

local function myRootPart()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Equipe locale (cache — pas de walk complet chaque frame)
local function resolveMyTeamTag(force)
    local now = tick()
    if not force and State.myTeamTag ~= nil and (now - State.teamTagAt) < State.teamTagTTL then
        return State.myTeamTag
    end
    State.teamTagAt = now
    local folder = Workspace:FindFirstChild("Characters")
    if not folder then State.myTeamTag = nil; return nil end
    local found
    local function walk(node, tag, depth)
        if found or depth > 12 then return end
        for _, ch in ipairs(node:GetChildren()) do
            if not ch:IsA("Tool") then
                local nextTag = (ch.Name == "A" or ch.Name == "B") and ch.Name or tag
                if isCharacterModel(ch) then
                    if isLocalModel(ch) then found = nextTag; return end
                elseif ch:IsA("Folder") or ch:IsA("Model") then
                    walk(ch, nextTag, depth + 1)
                end
                if found then return end
            end
        end
    end
    walk(folder, nil, 0)
    State.myTeamTag = found
    return found
end

local function buildTargetsList()
    local out, seen = {}, {}
    local myTag = resolveMyTeamTag(false)

    local function add(model, teamTag)
        if not model or seen[model] then return end
        if isLocalModel(model) then return end
        local hum  = model:FindFirstChildOfClass("Humanoid")
        local root = findRoot(model)
        if hum and root and isAlive(hum) then
            seen[model] = true
            out[#out + 1] = {
                model = model, root = root, head = model:FindFirstChild("Head"),
                hum = hum, player = Players:GetPlayerFromCharacter(model),
                teamTag = teamTag,
                sameTeam = (myTag ~= nil and teamTag ~= nil and teamTag == myTag),
            }
        end
    end

    local function walk(node, teamTag, depth)
        if depth > 12 then return end
        for _, ch in ipairs(node:GetChildren()) do
            if not ch:IsA("Tool") then
                local nextTag = (ch.Name == "A" or ch.Name == "B") and ch.Name or teamTag
                if ch:IsA("Model") then
                    if isCharacterModel(ch) then add(ch, nextTag)
                    else walk(ch, nextTag, depth + 1) end
                elseif ch:IsA("Folder") then
                    walk(ch, nextTag, depth + 1)
                end
            end
        end
    end

    local charFolder = Workspace:FindFirstChild("Characters")
    if charFolder then walk(charFolder, nil, 0) end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and isCharacterModel(plr.Character) then
            add(plr.Character, nil)
        end
    end
    return out
end

-- Liste cible cachee (evite walk Characters a chaque frame)
local function collectTargets(force)
    local now = tick()
    if not force and State.targetsCache and (now - State.targetsAt) < State.targetsTTL then
        return State.targetsCache
    end
    State.targetsCache = buildTargetsList()
    State.targetsAt = now
    State.rayFilter = nil
    State.visCache = {}
    return State.targetsCache
end

local function getRayFilter()
    local now = tick()
    if State.rayFilter and (now - State.rayFilterAt) < State.targetsTTL then
        return State.rayFilter
    end
    local models = {}
    if LocalPlayer.Character then models[#models + 1] = LocalPlayer.Character end
    for _, t in ipairs(collectTargets(false)) do
        models[#models + 1] = t.model
    end
    State.rayFilter = models
    State.rayFilterAt = now
    return models
end

local function aimPartOf(t)
    if CFG.aimPart == "HRP" then return t.root end
    if CFG.aimPart == "Neck" then
        local neck = t.model:FindFirstChild("Neck", true)
        if neck and neck:IsA("BasePart") then return neck end
        return t.head or t.root
    end
    return t.head or t.root
end

local function dropTarget(model)
    if not model then return end
    if State.currentTarget == model then State.currentTarget = nil end
    State.predTrack[model] = nil
    State.predSmooth[model] = nil
    State.targetsCache = nil
end

local function isTargetValid(t, part)
    if not t or not part or not part.Parent then return false end
    local model = t.model or modelOf(t, part)
    if not model or not model.Parent then return false end
    local hum = t.hum or model:FindFirstChildOfClass("Humanoid")
    if not isAlive(hum) then
        dropTarget(model)
        return false
    end
    return true
end

----------------------------------------------------------------------
-- PREDICT mouvement — vitesse lisse + lead balistique
----------------------------------------------------------------------
local function modelOf(t, part)
    if t and t.model then return t.model end
    if part then
        local m = part:FindFirstAncestorOfClass("Model")
        if m then return m end
    end
    return nil
end

local function sampleVelocity(model, part, root)
    local vel = Vector3.zero
    local acc = Vector3.zero
    if not model or not part then return vel, acc end

    local now = tick()
    local pos = part.Position
    local tr = State.predTrack[model]

    if tr then
        local dt = math.max(now - tr.t, 1 / 240)
        local rawVel = (pos - tr.pos) / dt
        -- ignore pics reseau (teleport / jitter)
        if rawVel.Magnitude > 120 then rawVel = tr.vel end
        local blend = math.clamp(dt * 10, 0.15, 0.55)
        vel = tr.vel:Lerp(rawVel, blend)
        local rawAcc = (vel - tr.vel) / dt
        if rawAcc.Magnitude > 50 then rawAcc = Vector3.zero end
        acc = tr.acc:Lerp(rawAcc, 0.25)
    end

    -- Physique HRP — horizontal seulement (saut/anim Y = bruit)
    if root and root:IsA("BasePart") then
        local ok, rv = pcall(function() return root.AssemblyLinearVelocity end)
        if ok and rv then
            rv = Vector3.new(rv.X, 0, rv.Z)
            if rv.Magnitude > 120 then rv = vel end
            vel = vel:Lerp(rv, 0.55)
        end
    end

    local cap = CFG.predMaxSpeed or 48
    if vel.Magnitude > cap then vel = vel.Unit * cap end

    State.predTrack[model] = { pos = pos, vel = vel, acc = acc, t = now }
    return vel, acc
end

local function bulletLeadTime(dist)
    local speed = math.max(CFG.predBulletSpeed, 200)
    local t = (dist / speed) + (CFG.predExtraMs / 1000)
    t = t * math.max(CFG.predScale, 0.05)
    if CFG.rangeTrack and CFG.rangeLeadBoost > 0 then
        local far = math.max(maxDist(), 1)
        local near = CFG.rangeNear or 35
        local frac = math.clamp((dist - near) / math.max(far - near, 1), 0, 1)
        t = t * (1 + frac * CFG.rangeLeadBoost)
    end
    return t
end

local function rangeDropOffset(dist, leadTime)
    if not CFG.rangeTrack or not CFG.rangeDrop then return Vector3.zero end
    local g = CFG.rangeGravity or 196.2
    local scale = math.clamp(CFG.rangeDropScale or 0, 0, 2)
    if scale <= 0 then return Vector3.zero end
    local drop = 0.5 * g * leadTime * leadTime * scale
    -- leger extra drop lineaire longue portee (balle lourde)
    drop = drop + math.max(dist - (CFG.rangeNear or 35), 0) * 0.002 * scale
    return Vector3.new(0, drop, 0)
end

local function aimWorldPos(t, part)
    if not part or not part.Parent then return nil end
    local pos = part.Position
    local camPos = Camera.CFrame.Position
    local model = modelOf(t, part)
    local root = (t and t.root) or (model and findRoot(model))

    local vel, acc = Vector3.zero, Vector3.zero
    if CFG.predEnabled and model then
        vel, acc = sampleVelocity(model, part, root)
    end

    local moving = vel.Magnitude >= 1.2
    if not CFG.predEnabled and not CFG.rangeTrack then return pos end
    if CFG.predEnabled and not moving and not CFG.rangeTrack then return pos end

    local predicted = pos
    local dist = (pos - camPos).Magnitude
    local lead = 0
    local passes = math.clamp(math.floor(CFG.predIter or 2), 1, 5)

    for _ = 1, passes do
        dist = (predicted - camPos).Magnitude
        lead = bulletLeadTime(dist)
        if CFG.predEnabled and moving then
            local offset = vel * lead
            if CFG.predAccel and acc.Magnitude > 0.5 then
                offset = offset + acc * (0.5 * lead * lead)
            end
            local capStuds = CFG.predMaxStuds or 5.5
            if offset.Magnitude > capStuds then
                offset = offset.Unit * capStuds
            end
            predicted = pos + offset
        else
            predicted = pos
        end
    end

    predicted = predicted + rangeDropOffset(dist, lead)

    -- lissage anti-secousse entre frames
    if CFG.predEnabled and model then
        local prev = State.predSmooth[model]
        if prev then
            predicted = prev:Lerp(predicted, 0.42)
        end
        State.predSmooth[model] = predicted
    end

    if CFG.rangeTrack then
        State.lastRange = dist
        State.lastLeadMs = lead * 1000
    end

    return predicted
end

local function prunePredTrack()
    local now = tick()
    if now - State.predPruneAt < 1.5 then return end
    State.predPruneAt = now
    for model in pairs(State.predTrack) do
        if not model.Parent then
            State.predTrack[model] = nil
            State.predSmooth[model] = nil
        end
    end
end

-- WALL CHECK avec cache court (1 raycast max par part / ~0.12s)
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

-- full360: LOS depuis Head/HRP local (ennemis derriere OK). Sinon: camera.
local function losOrigin()
    if CFG.full360 then
        local char = LocalPlayer.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head and head:IsA("BasePart") then return head.Position end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:IsA("BasePart") then return hrp.Position end
        end
    end
    Camera = Workspace.CurrentCamera
    return Camera and Camera.CFrame.Position or Vector3.zero
end

local function isVisible(part, worldPos, t)
    if not CFG.visibleOnly then return true end
    if not part or not part.Parent then return false end
    worldPos = worldPos or aimWorldPos(t, part) or part.Position
    local origin = losOrigin()
    if CFG.predEnabled then
        local model = modelOf(t, part)
        local tr = model and State.predTrack[model]
        if tr and tr.vel.Magnitude > 2 then
            local dir = worldPos - origin
            if dir.Magnitude < 0.01 then return true end
            rayParams.FilterDescendantsInstances = getRayFilter()
            local ok, res = pcall(function() return Workspace:Raycast(origin, dir, rayParams) end)
            return (not ok) or res == nil
        end
    end
    -- full360: pas de cache ecran-dependant — LOS corps peut changer vite en rotation
    local now = tick()
    if not CFG.full360 then
        local c = State.visCache[part]
        if c and (now - c.t) < State.visCacheTTL then return c.ok end
    end
    local dir = worldPos - origin
    if dir.Magnitude < 0.01 then
        if not CFG.full360 then State.visCache[part] = { t = now, ok = true } end
        return true
    end
    rayParams.FilterDescendantsInstances = getRayFilter()
    local ok, res = pcall(function() return Workspace:Raycast(origin, dir, rayParams) end)
    local vis = (not ok) or res == nil
    if not CFG.full360 then State.visCache[part] = { t = now, ok = vis } end
    return vis
end

-- Meilleure cible: plus proche du crosshair DANS le FOV (tiebreak 3D),
-- respecte teamCheck, maxDistance et wall-check.
local function acquireTarget(fov, needVisible)
    fov = fov or CFG.aimFov
    if needVisible == nil then needVisible = true end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestPart, bestScreen, best3D = nil, nil, math.huge, math.huge
    local mr = myRootPart()
    for _, t in ipairs(collectTargets(false)) do
        if not (CFG.teamCheck and t.sameTeam) then
            local part = aimPartOf(t)
            if part then
                local ap = aimWorldPos(t, part)
                local d3 = mr and (ap - mr.Position).Magnitude or 0
                if d3 <= maxDist() then
                    local sp, on = Camera:WorldToViewportPoint(ap)
                    if on and sp.Z > 0 then
                        local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d2 <= fov then
                            local vis = (not needVisible) or isVisible(part, ap, t)
                            if vis then
                                -- priorite crosshair, tiebreak distance 3D
                                if d2 < bestScreen - 0.5
                                   or (math.abs(d2 - bestScreen) <= 0.5 and d3 < best3D) then
                                    bestScreen = d2; best3D = d3; best = t; bestPart = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

-- 360: scan TOUS les joueurs dans la sphere. Score = distance 3D ONLY.
-- Aucun FOV / ViewportPoint / facing — derriere = eligible si LOS corps.
local function getBestTarget360(needVisible)
    if needVisible == nil then needVisible = true end
    local best, bestPart, bestDist = nil, nil, math.huge
    local mr = myRootPart()
    for _, t in ipairs(collectTargets(false)) do
        if not (CFG.teamCheck and t.sameTeam) then
            local part = aimPartOf(t)
            if part then
                local ap = aimWorldPos(t, part)
                if ap then
                    local d3 = mr and (ap - mr.Position).Magnitude or math.huge
                    if d3 <= maxDist() then
                        local vis = (not needVisible) or isVisible(part, ap, t)
                        if vis and d3 < bestDist then
                            bestDist = d3
                            best = t
                            bestPart = part
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

-- Cible sticky : garde la meme tant que vivante / dans releaseFov / a portee / visible / pas ally.
-- full360: ignore releaseFov ecran — garde tant que range + mur + equipe OK.
local function stickyTarget()
    if CFG.aimSticky and State.currentTarget then
        local m = State.currentTarget
        if m and m.Parent and isCharacterModel(m) and not isLocalModel(m) then
            local hum = m:FindFirstChildOfClass("Humanoid")
            if isAlive(hum) then
                local t = { model = m, root = findRoot(m), head = m:FindFirstChild("Head"), hum = hum }
                for _, ct in ipairs(collectTargets(false)) do
                    if ct.model == m then
                        t.sameTeam = ct.sameTeam
                        t.teamTag = ct.teamTag
                        break
                    end
                end
                if not (CFG.teamCheck and t.sameTeam) then
                    local part = aimPartOf(t)
                    local mr = myRootPart()
                    if part and mr then
                        local ap = aimWorldPos(t, part)
                        if ap and (ap - mr.Position).Magnitude <= maxDist() then
                            if CFG.full360 then
                                if isVisible(part, ap, t) then
                                    return t, part
                                end
                            else
                                local sp, on = Camera:WorldToViewportPoint(ap)
                                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                                if on and sp.Z > 0
                                   and (Vector2.new(sp.X, sp.Y) - center).Magnitude <= CFG.aimReleaseFov
                                   and isVisible(part, ap, t) then
                                    return t, part
                                end
                            end
                        end
                    end
                end
            else
                dropTarget(m)
            end
        end
        State.currentTarget = nil
    end
    local t, part
    if CFG.full360 then
        t, part = getBestTarget360(true)
    else
        t, part = acquireTarget(CFG.aimFov, true)
    end
    if t then State.currentTarget = t.model end
    return t, part
end

----------------------------------------------------------------------
-- CAMERA LOCK (lissage) + humanize SAFE (DISPLAY only)
-- Safe: gauss / Bezier / drift / smooth pour le LOOK entre les tirs.
-- Fire window: aimFirePos exact (tete+predict) — 0 miss, pas de offset.
----------------------------------------------------------------------
local function myCharacterRoot()
    local c = LocalPlayer.Character
    return c and findRoot(c)
end

local function gaussNoise(std)
    -- Box-Muller
    local u1 = math.max(1e-12, math.random())
    local u2 = math.random()
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2) * (std or 1)
end

local function cubicBezier3(p0, p1, p2, p3, t)
    local u = 1 - t
    return p0 * (u * u * u)
        + p1 * (3 * u * u * t)
        + p2 * (3 * u * t * t)
        + p3 * (t * t * t)
end

local function pixelOffsetToWorld(cam, worldPos, px)
    if not cam or not worldPos or not px then return Vector3.zero end
    local dist = (worldPos - cam.CFrame.Position).Magnitude
    if dist < 0.5 then dist = 0.5 end
    local vs = cam.ViewportSize
    local fov = math.rad(cam.FieldOfView or FIXED_FOV)
    local worldPerPx = (2 * dist * math.tan(fov * 0.5)) / math.max(vs.Y, 1)
    return cam.CFrame.RightVector * (px.X * worldPerPx)
        + cam.CFrame.UpVector * (-px.Y * worldPerPx)
end

local function retargetHumPixels()
    local lo = CFG.safePxMin or 2
    local hi = CFG.safePxMax or 7
    if hi < lo then hi = lo end
    local mag = lo + math.random() * (hi - lo)
    local ang = math.random() * math.pi * 2
    -- L/R dominant, leger U/D (erreur humaine) — DISPLAY only
    State.humPxTarget = Vector2.new(math.cos(ang) * mag, math.sin(ang) * mag * 0.45)
    State.humPxRetarget = tick() + (0.4 + math.random() * 1.1)
end

-- Exact head + predict — trigger / fire / last-frame cam. NEVER humanized.
local function aimFirePos(t, part)
    return aimWorldPos(t, part)
end

-- Humanized look target (Safe only). Rage = exact.
local function aimDisplayPos(t, part)
    local base = aimFirePos(t, part)
    if not base then return nil end
    if State.scriptMode ~= "safe" then return base end

    local now = tick()
    if now >= (State.humPxRetarget or 0) then
        retargetHumPixels()
    end
    State.humPxOff = State.humPxOff or Vector2.zero
    State.humPxTarget = State.humPxTarget or Vector2.zero
    State.humPxOff = State.humPxOff:Lerp(State.humPxTarget, 0.07)

    local std = CFG.safeGaussStuds or 0.045
    local g = Vector3.new(gaussNoise(std), gaussNoise(std * 0.7), gaussNoise(std))
    local pxWorld = pixelOffsetToWorld(Camera, base, State.humPxOff)
    local noisy = base + pxWorld + g

    -- micro-overshoot / correction (look only — jamais sur le ray de tir)
    if now < (State.humOverUntil or 0) then
        local look = noisy - Camera.CFrame.Position
        if look.Magnitude > 0.05 then
            local side = Camera.CFrame.RightVector * ((State.humPxOff.X or 0) * 0.008)
            local amt = 0.05 + math.random() * 0.07
            local phase = (State.humOverUntil - now) / math.max((State.humOverDur or 0.08), 0.04)
            if phase > 0.45 then
                noisy = noisy + look.Unit * amt + side
            else
                noisy = noisy - look.Unit * (amt * 0.35)
            end
        end
    elseif math.random() < (CFG.safeOvershootP or 0.010) then
        State.humOverDur = 0.05 + math.random() * 0.07
        State.humOverUntil = now + State.humOverDur
    end
    return noisy
end

local function snapCamera(t, part, smoothing)
    if not part then return end
    smoothing = smoothing == nil and CFG.aimSmoothing or smoothing
    local pos = aimDisplayPos(t, part)
    if not pos then return end

    pcall(function()
        if State.scriptMode == "safe" then
            -- Look humanise: Bezier + expo smooth (entre les tirs)
            local now = tick()
            local dt = now - (State.humLastT or now)
            if dt <= 0 or dt > 0.08 then dt = 1 / 60 end
            State.humLastT = now

            local model = t and t.model
            if model ~= State.humBezierModel then
                State.humBezierModel = model
                State.humBezierT = 0
                State.humLastLook = Camera.CFrame.LookVector
                State.humBezierRefresh = now + (0.55 + math.random() * 0.45)
            elseif now >= (State.humBezierRefresh or 0) and (State.humBezierT or 0) >= 0.92 then
                State.humBezierT = 0.35 + math.random() * 0.25
                State.humLastLook = Camera.CFrame.LookVector
                State.humBezierRefresh = now + (0.5 + math.random() * 0.55)
            end

            local camPos = Camera.CFrame.Position
            local goalDir = (pos - camPos)
            if goalDir.Magnitude < 1e-4 then return end
            goalDir = goalDir.Unit

            local startDir = State.humLastLook or Camera.CFrame.LookVector
            local bezSec = math.max(CFG.safeBezierSec or 0.22, 0.05)
            State.humBezierT = math.clamp((State.humBezierT or 0) + dt / bezSec, 0, 1)
            local tBez = State.humBezierT

            local p0 = camPos + startDir
            local p3 = pos
            local side = Camera.CFrame.RightVector * ((State.humPxOff.X or 0) * 0.015)
            local p1 = camPos:Lerp(pos, 0.28) + side + Camera.CFrame.UpVector * 0.04
            local p2 = camPos:Lerp(pos, 0.62) - side * 0.55
            local bent = cubicBezier3(p0, p1, p2, p3, tBez)
            local bentDir = (bent - camPos)
            if bentDir.Magnitude < 1e-4 then bentDir = goalDir else bentDir = bentDir.Unit end

            local goal = CFrame.lookAt(camPos, camPos + bentDir)
            local smoothTime = math.max(CFG.safeSmoothTime or 0.16, 0.04)
            local alpha = 1 - math.exp(-dt / smoothTime)
            alpha = math.clamp(alpha, 0.02, 0.55)
            Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
            State.humLastLook = Camera.CFrame.LookVector
            return
        end

        -- RAGE: snap / lerp rapide sur aim exact
        local goal = CFrame.lookAt(Camera.CFrame.Position, pos)
        if smoothing <= 0.001 then
            Camera.CFrame = goal
        else
            local alpha = math.clamp(1 - smoothing, 0.05, 1)
            Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
        end
    end)
    if CFG.aimMouseNudge and typeof(mousemoverel) == "function" then
        local sp, on = Camera:WorldToViewportPoint(pos)
        if on and sp.Z > 0 then
            local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
            local f = math.clamp(1 - math.max(smoothing, 0), 0.08, 1)
            if State.scriptMode == "safe" then f = f * 0.35 end
            local dx, dy = (sp.X - cx) * f, (sp.Y - cy) * f
            if math.abs(dx) > 0.3 or math.abs(dy) > 0.3 then
                pcall(mousemoverel, dx, dy)
            end
        end
    end
end

-- Force look EXACT sur aimFirePos (fenetre de tir Safe + Rage hard-snap)
local function hardLockCamera(t, part)
    if not part then return end
    local pos = aimFirePos(t, part)
    if not pos then return end
    pcall(function()
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, pos)
    end)
    State.humLastLook = Camera.CFrame.LookVector
    if CFG.aimMouseNudge and typeof(mousemoverel) == "function" then
        local sp, on = Camera:WorldToViewportPoint(pos)
        if on and sp.Z > 0 then
            local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
            pcall(mousemoverel, sp.X - cx, sp.Y - cy)
        end
    end
end

-- Angle (deg) vers le point de TIR exact (pas le display humanise)
local function aimAngleTo(t, part)
    if not part then return 999 end
    local pos = aimFirePos(t, part)
    if not pos then return 999 end
    local dir = pos - Camera.CFrame.Position
    if dir.Magnitude < 0.01 then return 0 end
    local dot = math.clamp(Camera.CFrame.LookVector:Dot(dir.Unit), -1, 1)
    return math.deg(math.acos(dot))
end

-- La tete est-elle DANS le rayon trigFov a l'ecran ?
-- Gate sur aimFirePos (stable) — humanize ne doit jamais faire rater le gate.
-- full360: gate ignoree (acquisition sphere).
local function withinTrigFov(t, part)
    if CFG.full360 then return true end
    if not part then return false end
    local pos = aimFirePos(t, part)
    if not pos then return false end
    local sp, on = Camera:WorldToViewportPoint(pos)
    if not (on and sp.Z > 0) then return false end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(sp.X, sp.Y) - center).Magnitude <= CFG.trigFov
end

-- Pret a tirer — gates sur aimFirePos exact (0 miss)
-- full360: pas de FOV / angle gate — le micro-flick aligne au moment du tir
local function triggerCanFire(t, part)
    if not isTargetValid(t, part) then return false end
    if not CFG.full360 and not withinTrigFov(t, part) then return false end
    local ap = aimFirePos(t, part)
    if not ap then return false end
    if not isVisible(part, ap, t) then return false end
    if CFG.trigHardSnap and not CFG.full360 then
        return aimAngleTo(t, part) <= CFG.alignThreshold
    end
    return true
end

----------------------------------------------------------------------
-- CROUCH pulse au tir (Ctrl + remote jeu)
----------------------------------------------------------------------
local function getCSR()
    if State.csrFolder and State.csrFolder.Parent then return State.csrFolder end
    local ok, folder = pcall(function()
        return ReplicatedStorage:WaitForChild("Remotes", 3)
            :WaitForChild("Character", 3)
            :WaitForChild("CharacterStateReplication", 3)
    end)
    if ok and folder then State.csrFolder = folder end
    return State.csrFolder
end

local function crouchRemote(on)
    local folder = getCSR()
    if not folder then return end
    local rem = folder:FindFirstChild("Crouching")
    if rem and rem:IsA("RemoteEvent") then
        pcall(function() rem:FireServer(on) end)
    end
end

local function crouchKey(on)
    local vim
    pcall(function() vim = game:GetService("VirtualInputManager") end)
    if vim then
        pcall(function() vim:SendKeyEvent(on, Enum.KeyCode.LeftControl, false, game) end)
        pcall(function() vim:SendKeyEvent(on, Enum.KeyCode.C, false, game) end)
    end
    if typeof(keypress) == "function" and typeof(keyrelease) == "function" then
        if on then
            pcall(keypress, Enum.KeyCode.LeftControl)
            pcall(keypress, Enum.KeyCode.C)
        else
            pcall(keyrelease, Enum.KeyCode.LeftControl)
            pcall(keyrelease, Enum.KeyCode.C)
        end
    end
end

local function crouchPress()
    crouchRemote(true)
    crouchKey(true)
    State.crouchHeld = true
end

local function crouchRelease()
    crouchKey(false)
    crouchRemote(false)
    State.crouchHeld = false
end

local function pulseCrouchOnFire()
    if not CFG.crouchOnFire then return end
    State.crouchPulseId = State.crouchPulseId + 1
    local pulseId = State.crouchPulseId
    crouchPress()
    task.spawn(function()
        task.wait(math.clamp(CFG.crouchFireSec or 1, 0.2, 3))
        if State.crouchPulseId ~= pulseId then return end
        crouchRelease()
    end)
end

-- Auto-fire : mode naturel = clic court ; hard snap = press+release
local function doFire()
    if State.firing then return false end
    if (tick() - State.lastFire) < CFG.trigCooldown then return false end
    State.firing = true
    State.lastFire = tick()
    pulseCrouchOnFire()
    task.spawn(function()
        local d = math.clamp(CFG.fireDelay, 0.02, 0.25)
        local ok = false
        -- Mode naturel : clic instantane en priorite (pas de fireDelay)
        if not CFG.trigHardSnap and typeof(mouse1click) == "function" then
            ok = pcall(mouse1click)
        end
        if not ok and typeof(mouse1press) == "function" and typeof(mouse1release) == "function" then
            ok = pcall(function()
                mouse1press()
                task.wait(d)
                mouse1release()
            end)
        end
        if not ok then
            local vim
            pcall(function() vim = game:GetService("VirtualInputManager") end)
            if vim then
                local vs = Camera.ViewportSize
                local mx, my = vs.X / 2, vs.Y / 2
                pcall(function()
                    local mp = UserInputService:GetMouseLocation()
                    if mp then mx, my = mp.X, mp.Y end
                end)
                -- Pas de jitter: le ray suit la camera deja hard-lockee sur aimFirePos
                ok = pcall(function()
                    vim:SendMouseButtonEvent(mx, my, 0, true, game, 1)
                    task.wait(d)
                    vim:SendMouseButtonEvent(mx, my, 0, false, game, 1)
                end)
            end
        end
        if not ok and typeof(mouse1click) == "function" then
            ok = pcall(mouse1click)
        end
        task.wait(0.01)
        State.firing = false
    end)
    return true
end

-- Micro-flick no-hook (360 / freeCam):
-- save cam -> snap aimFirePos -> HOLD 2–3 frames + ~60ms -> fire pendant snap -> restore.
-- CRITICAL: restore trop tot = raycast jeu utilise look restaure -> miss / "marche pas".
local function dbg360(msg)
    if typeof(getgenv) == "function" and getgenv().UNDETEK_SNIPER_DBG then
        warn("[UNDETEK] " .. tostring(msg))
    end
end

local function notifyFirst360Fire(name)
    if State.first360FireToast then return end
    State.first360FireToast = true
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "UNDETEK 360 OK",
            Text = "Tir auto: " .. tostring(name or "?") .. " — flick hold OK",
            Duration = 4,
        })
    end)
end

local function flickFire(t, part)
    if State.firing then return false end
    if (tick() - State.lastFire) < CFG.trigCooldown then return false end
    if not isTargetValid(t, part) then return false end

    Camera = Workspace.CurrentCamera
    if not Camera then return false end

    local pos = aimFirePos(t, part)
    if not pos then return false end
    if CFG.visibleOnly and not isVisible(part, pos, t) then return false end

    State.firing = true
    State.lastFire = tick()
    pulseCrouchOnFire()

    local targetName = (t and t.model and t.model.Name) or "?"
    dbg360("360 fire " .. targetName)

    -- Async: NE PAS bloquer BindToRenderStep (sinon deadlock Wait)
    task.spawn(function()
        local cam = Workspace.CurrentCamera
        if not cam then
            State.firing = false
            return
        end

        local savedCF = cam.CFrame
        local restored = false
        local function restoreCam()
            if restored then return end
            restored = true
            pcall(function()
                local c = Workspace.CurrentCamera
                if c then c.CFrame = savedCF end
            end)
        end

        local function snapNow()
            local c = Workspace.CurrentCamera
            if not c then return false end
            local p = aimFirePos(t, part) or pos
            if not p then return false end
            pcall(function()
                c.CFrame = CFrame.lookAt(c.CFrame.Position, p)
            end)
            return true
        end

        -- Hold hardLock pendant toute la fenetre de tir
        if not snapNow() then
            State.firing = false
            return
        end

        -- 2–3 frames snapped pour que le raycast jeu voie le look
        RunService.RenderStepped:Wait()
        snapNow()
        RunService.RenderStepped:Wait()
        snapNow()

        local ok = false
        local d = math.clamp(CFG.fireDelay, 0.02, 0.12)

        -- Clic PENDANT le snap (cam encore lockee)
        if typeof(mouse1press) == "function" and typeof(mouse1release) == "function" then
            ok = pcall(mouse1press)
            if ok then
                -- hold lock pendant press + delay + 1 frame apres release
                task.wait(d)
                snapNow()
                pcall(mouse1release)
                RunService.RenderStepped:Wait()
                snapNow()
            end
        end
        if not ok and typeof(mouse1click) == "function" then
            ok = pcall(mouse1click)
            RunService.RenderStepped:Wait()
            snapNow()
        end
        if not ok then
            local vim
            pcall(function() vim = game:GetService("VirtualInputManager") end)
            if vim then
                local vs = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
                local mx, my = vs.X / 2, vs.Y / 2
                pcall(function()
                    local mp = UserInputService:GetMouseLocation()
                    if mp then mx, my = mp.X, mp.Y end
                end)
                ok = pcall(function()
                    vim:SendMouseButtonEvent(mx, my, 0, true, game, 1)
                end)
                if ok then
                    task.wait(d)
                    snapNow()
                    pcall(function()
                        vim:SendMouseButtonEvent(mx, my, 0, false, game, 1)
                    end)
                    RunService.RenderStepped:Wait()
                    snapNow()
                end
            end
        end

        -- Extra hold ~50–80ms: balle / hitreg souvent apres le release
        local holdUntil = tick() + 0.06
        while tick() < holdUntil do
            snapNow()
            RunService.RenderStepped:Wait()
        end

        restoreCam()

        if ok then
            notifyFirst360Fire(targetName)
        end

        task.wait(0.02)
        State.firing = false
        -- filet: re-restore si un autre thread a touche
        restoreCam()
    end)
    return true
end

----------------------------------------------------------------------
-- ESP (Drawing only) — seulement les proches (<= espMaxDistance)
----------------------------------------------------------------------
local function newDraw(class, props)
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok or not d then return nil end
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function makeEsp()
    return {
        box    = newDraw("Square", { Thickness = 1, Filled = false, Transparency = 1, Visible = false, Color = COL_ENEMY }),
        name   = newDraw("Text",   { Size = 13, Center = true, Outline = true, Transparency = 1, Visible = false, Color = COL_VIS }),
        hp     = newDraw("Square", { Thickness = 1, Filled = true, Transparency = 1, Visible = false, Color = Color3.fromRGB(90, 220, 90) }),
        hpbg   = newDraw("Square", { Thickness = 1, Filled = true, Transparency = 1, Visible = false, Color = Color3.fromRGB(0, 0, 0) }),
        tracer = newDraw("Line",   { Thickness = 1, Transparency = 1, Visible = false, Color = COL_ENEMY }),
    }
end

local function hideEsp(d)
    if not d then return end
    for _, o in pairs(d) do if o then o.Visible = false end end
end
local function destroyEsp(d)
    if not d then return end
    for _, o in pairs(d) do if o then pcall(function() o:Remove() end) end end
end
local function clearAllEsp()
    for model, d in pairs(State.drawings) do destroyEsp(d); State.drawings[model] = nil end
end

local function stepEsp()
    if not hasDrawing or not CFG.espEnabled then
        for _, d in pairs(State.drawings) do hideEsp(d) end
        return
    end
    -- ESP ~20 fps max (evite lag quand aim actif)
    State.espFrameSkip = (State.espFrameSkip + 1) % 3
    if State.espFrameSkip ~= 0 and aimActive() then return end

    local targets = collectTargets(false)
    local present = {}
    local mr = myRootPart()
    local maxD = maxDist()

    for _, t in ipairs(targets) do
        local skip = (CFG.teamCheck and t.sameTeam)
        local dist = mr and (t.root.Position - mr.Position).Magnitude or math.huge
        if not skip and dist <= maxD then
            present[t.model] = true
            local d = State.drawings[t.model]
            if not d then d = makeEsp(); State.drawings[t.model] = d end

            -- Box rapide: Head + HRP seulement (pas tout GetChildren)
            local head, root = t.head, t.root
            local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
            local anyOn = false
            for _, p in ipairs({ head, root }) do
                if p and p:IsA("BasePart") then
                    local sp, on = Camera:WorldToViewportPoint(p.Position)
                    if on and sp.Z > 0 then
                        anyOn = true
                        local sz = p:IsA("BasePart") and math.max(p.Size.X, p.Size.Y, p.Size.Z) * 8 or 40
                        if sp.X - sz < minX then minX = sp.X - sz end
                        if sp.Y - sz < minY then minY = sp.Y - sz end
                        if sp.X + sz > maxX then maxX = sp.X + sz end
                        if sp.Y + sz > maxY then maxY = sp.Y + sz end
                    end
                end
            end
            if anyOn then
                local w, h = (maxX - minX), (maxY - minY)
                local pad = math.clamp(w * 0.12, 2, 12)
                minX, maxX = minX - pad, maxX + pad
                minY, maxY = minY - pad, maxY + pad
                w, h = maxX - minX, maxY - minY

                local isTgt = (State.currentTarget == t.model)
                local col = isTgt and COL_TARGET or teamColor(t.teamTag)
                if d.box then
                    d.box.Visible = CFG.espBox
                    d.box.Color = col
                    d.box.Position = Vector2.new(minX, minY)
                    d.box.Size = Vector2.new(w, h)
                end
                if d.name then
                    d.name.Visible = CFG.espName
                    d.name.Color = col
                    d.name.Position = Vector2.new(minX + w / 2, minY - 15)
                    d.name.Text = string.format("%s%s  [%dm]",
                        t.player and t.player.Name or t.model.Name,
                        t.teamTag and (" ["..t.teamTag.."]") or "",
                        math.floor(dist))
                end
                if d.hp and d.hpbg then
                    if CFG.espHealth then
                        local hp, max = getHealth(t.hum)
                        local ratio = math.clamp(hp / max, 0, 1)
                        d.hpbg.Visible = true
                        d.hpbg.Position = Vector2.new(minX - 5, minY)
                        d.hpbg.Size = Vector2.new(3, h)
                        d.hp.Visible = true
                        d.hp.Position = Vector2.new(minX - 5, minY + h * (1 - ratio))
                        d.hp.Size = Vector2.new(3, h * ratio)
                        d.hp.Color = Color3.fromRGB(math.floor(220 * (1 - ratio)) + 35, math.floor(200 * ratio) + 20, 60)
                    else
                        d.hp.Visible = false; d.hpbg.Visible = false
                    end
                end
                if d.tracer then
                    if CFG.espTracer then
                        d.tracer.Visible = true
                        d.tracer.Color = col
                        d.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        d.tracer.To = Vector2.new(minX + w / 2, maxY)
                    else
                        d.tracer.Visible = false
                    end
                end
            else
                hideEsp(d)
            end
        end
    end

    for model, d in pairs(State.drawings) do
        if not present[model] then destroyEsp(d); State.drawings[model] = nil end
    end
end

----------------------------------------------------------------------
-- FOV CIRCLE
----------------------------------------------------------------------
local function stepFovCircle()
    if not hasDrawing then return end
    if not State.fovCircle then
        State.fovCircle = newDraw("Circle", { Thickness = 1, Filled = false, Transparency = 0.8, Visible = false, Color = COL_FOV, NumSides = 48 })
    end
    local c = State.fovCircle
    if not c then return end
    -- 360 Auto: pas de cone FOV utile — cercle masque
    if CFG.full360 then
        c.Visible = false
        return
    end
    local armed = CFG.aimEnabled and (CFG.aimAlways or (CFG.aimHoldMouse2 and State.holdingM2))
    if CFG.showFovCircle and (armed or CFG.trigEnabled) then
        c.Visible = true
        -- Rayon = FOV actif reel (aim px si armed, sinon trig px) — plus de faux cercle aimFov en trigger-only
        local radius = armed and CFG.aimFov or CFG.trigFov
        c.Radius = math.max(8, radius)
        c.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        -- Couleur / epaisseur selon mode Safe vs Rage + lock
        if State.scriptMode == "safe" then
            c.Thickness = 1
            c.Transparency = 0.72
            c.Color = armed and Color3.fromRGB(90, 180, 120) or Color3.fromRGB(160, 190, 170)
        else
            c.Thickness = armed and 2 or 1
            c.Transparency = 0.55
            c.Color = armed and COL_TARGET or Color3.fromRGB(235, 200, 120)
        end
    else
        c.Visible = false
    end
end

----------------------------------------------------------------------
-- AIMBOT (no-hook) — camera-lock lisse chaque RenderStep
----------------------------------------------------------------------
local function aimActive()
    if not CFG.aimEnabled then return false end
    -- 360 Auto: toujours "arme" (comme RMB maintenu) sans lock cam
    if CFG.full360 then return true end
    if CFG.aimAlways then return true end
    if CFG.aimHoldMouse2 and State.holdingM2 then return true end
    return false
end

local function freeCamActive()
    return CFG.full360 and State.freeCam
end

----------------------------------------------------------------------
-- ENGAGE : 360 = capture + flick auto | sinon clic droit aim+trigger
----------------------------------------------------------------------
local function stepEngage()
    if not State.bootReady then return end
    if not aimActive() and not CFG.trigEnabled then return end

    Camera = Workspace.CurrentCamera
    if not Camera then return end

    State.locked = false
    State.aligned = false
    State.trigReady = (tick() - State.lastFire) >= CFG.trigCooldown and not State.firing

    local armed = aimActive()
    local tgt, part
    local free = freeCamActive()

    -- ─── 360 Auto + cam libre: acquire sphere, pas de lock continu entre tirs ───
    if CFG.full360 then
        -- Gates: apres Start Safe/Rage aim+trig sont ON; sinon toggle menu
        if not CFG.aimEnabled and not CFG.trigEnabled then return end
        -- Force arming: full360 ne depend pas de RMB
        tgt, part = stickyTarget()
        if not part or not part.Parent or not isTargetValid(tgt, part) then
            State.settleLeft = 0
            return
        end
        State.locked = true
        prunePredTrack()
        -- Cam libre entre tirs: jamais snapCamera continu
        -- Pendant flickFire: hardLock hold ~60ms (async) puis restore
        State.aligned = true
        if CFG.trigEnabled and State.trigReady and triggerCanFire(tgt, part) then
            flickFire(tgt, part)
        end
        return
    end

    -- ─── Mode classique (FOV cone + lock cam) ───
    if armed then
        tgt, part = stickyTarget()
    elseif CFG.trigEnabled then
        tgt, part = acquireTarget(CFG.trigFov, true)
    end

    if not part or not part.Parent or not isTargetValid(tgt, part) then
        State.settleLeft = 0
        State.humBezierModel = nil
        State.humBezierT = 0
        State.humLastLook = nil
        State.humOverUntil = 0
        return
    end
    State.locked = true
    prunePredTrack()

    local wantFire = CFG.trigEnabled
        and State.trigReady
        and (not CFG.trigOnlyWhenLocked or armed)
        and triggerCanFire(tgt, part)

    if wantFire then
        -- Fire window: camera + ray = aimFirePos exact (0 miss, Safe comme Rage)
        hardLockCamera(tgt, part)
    elseif armed and not free then
        -- Entre les tirs: Safe humanise le look, Rage snap agressif
        snapCamera(tgt, part, CFG.aimSmoothing)
    end

    State.aligned = withinTrigFov(tgt, part)
    if CFG.trigHardSnap then
        State.aligned = aimAngleTo(tgt, part) <= CFG.alignThreshold
    end

    if not CFG.trigEnabled then
        State.settleLeft = 0
        return
    end
    if not State.trigReady then return end
    if CFG.trigOnlyWhenLocked and not armed then return end

    if not wantFire then
        State.settleLeft = 0
        return
    end

    if CFG.trigHardSnap then
        if aimAngleTo(tgt, part) > CFG.alignThreshold then return end
    end

    doFire()
end

----------------------------------------------------------------------
-- BOUCLES (1 seule boucle aim — plus de double Heartbeat = moins de lag)
----------------------------------------------------------------------
local RENDER_NAME = "\0XHUB_SD_AIM\0"
pcall(function() RunService:UnbindFromRenderStep(RENDER_NAME) end)
pcall(function()
    RunService:BindToRenderStep(RENDER_NAME, Enum.RenderPriority.Last.Value, function()
        if not State.alive then return end
        pcall(stepEngage)
    end)
    State.renderBound = true
end)

State.conns[#State.conns + 1] = RunService.RenderStepped:Connect(function()
    if not State.alive or not State.bootReady then return end
    pcall(enforceFixedFov)
    if CFG.espEnabled or aimActive() then pcall(stepEsp) end
    if CFG.showFovCircle and (CFG.aimEnabled or CFG.trigEnabled) then pcall(stepFovCircle) end
end)

State.conns[#State.conns + 1] = LocalPlayer.CharacterAdded:Connect(function()
    State.targetsCache = nil
    State.visCache = {}
    State.predTrack = {}
    State.predSmooth = {}
    State.currentTarget = nil
    task.defer(function()
        resolveMyTeamTag(true)
    end)
end)

State.conns[#State.conns + 1] = UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        State.holdingM2 = true
        State.m2Since = tick()
    end
end)
State.conns[#State.conns + 1] = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        State.holdingM2 = false
        State.settleLeft = 0
    end
end)

----------------------------------------------------------------------
-- UI (theme BLANC compact) — boutons uniquement, tout deja a fond
----------------------------------------------------------------------
local UI_W, UI_PAD, UI_GAP = 150, 5, 3
local UI_TITLE, UI_TEXT, UI_BTN = 11, 8, 15

-- Palette blanche
local UI_BG      = Color3.fromRGB(246, 246, 248)
local UI_PANEL   = Color3.fromRGB(228, 228, 233)
local UI_ON      = Color3.fromRGB(150, 214, 165)  -- vert clair = actif
local UI_TXT     = Color3.fromRGB(22, 22, 26)
local UI_TXT_DIM = Color3.fromRGB(110, 110, 122)

local guiParent
pcall(function() if typeof(gethui) == "function" then guiParent = gethui() end end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
-- anti double-GUI (reste apres unload partiel / re-exec)
pcall(function()
    if not guiParent then return end
    for _, ch in ipairs(guiParent:GetChildren()) do
        if ch.Name == "\0\0SD\0\0" then ch:Destroy() end
    end
end)

local screen = Instance.new("ScreenGui")
screen.Name = "\0\0SD\0\0"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screen.Parent = guiParent end)

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(UI_W, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Position = UDim2.fromOffset(16, 80)
frame.BackgroundColor3 = UI_BG
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false -- cache tant que Safe/Rage pas choisi
frame.Parent = screen
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = frame
local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(200, 200, 210)
stroke.Thickness = 1; stroke.Parent = frame
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, UI_PAD); pad.PaddingBottom = UDim.new(0, UI_PAD)
pad.PaddingLeft = UDim.new(0, UI_PAD); pad.PaddingRight = UDim.new(0, UI_PAD)
pad.Parent = frame
local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, UI_GAP)
list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 15)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = UI_TITLE
title.TextColor3 = UI_TXT
title.Text = "UNDETEK xhub"
title.Parent = frame

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 12)
sub.BackgroundTransparency = 1
sub.Font = Enum.Font.Gotham
sub.TextSize = UI_TEXT
sub.TextColor3 = UI_TXT_DIM
sub.Text = "v" .. VERSION .. " - FOV 120 - RightShift"
sub.Parent = frame

local modeBadge = Instance.new("TextLabel")
modeBadge.Size = UDim2.new(1, 0, 0, 12)
modeBadge.BackgroundTransparency = 1
modeBadge.Font = Enum.Font.GothamMedium
modeBadge.TextSize = UI_TEXT
modeBadge.TextColor3 = UI_TXT_DIM
modeBadge.Text = "MODE: —"
modeBadge.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 22)
status.BackgroundColor3 = UI_PANEL
status.BorderSizePixel = 0
status.Font = Enum.Font.Code
status.TextSize = UI_TEXT
status.TextColor3 = UI_TXT
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top
status.Text = "..."
status.Parent = frame
local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 4); sc.Parent = status

local function addToggle(label, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, UI_BTN)
    btn.BackgroundColor3 = UI_PANEL
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = UI_TEXT
    btn.TextColor3 = UI_TXT
    btn.AutoButtonColor = true
    btn.Parent = frame
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = btn
    local function render()
        local on = CFG[key]
        btn.Text = (on and "[ON]  " or "[OFF] ") .. label
        btn.BackgroundColor3 = on and UI_ON or UI_PANEL
    end
    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        if key == "full360" then
            State.freeCam = CFG.full360
        end
        if not CFG.espEnabled then for _, d in pairs(State.drawings) do hideEsp(d) end end
        render()
    end)
    render()
    State._toggleRenders = State._toggleRenders or {}
    State._toggleRenders[#State._toggleRenders + 1] = render
    return btn
end

-- Boutons principaux (actives apres choix Safe/Rage)
addToggle("360 Auto", "full360")
addToggle("Aimbot", "aimEnabled")
addToggle("Trigger", "trigEnabled")
addToggle("Predict", "predEnabled")
addToggle("Mur (wall)", "visibleOnly")
addToggle("Equipe A/B", "teamCheck")
addToggle("ESP", "espEnabled")
addToggle("Cercle FOV", "showFovCircle")

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, 0, 0, 18)
unloadBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
unloadBtn.BorderSizePixel = 0
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.TextSize = UI_TEXT
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Text = "UNLOAD"
unloadBtn.Parent = frame
local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(0, 4); uc.Parent = unloadBtn

----------------------------------------------------------------------
-- BOOT CHOOSER: Start Safe Script | Start Rage Script
----------------------------------------------------------------------
local bootGui = Instance.new("Frame")
bootGui.Name = "BootMode"
bootGui.Size = UDim2.fromOffset(220, 0)
bootGui.AutomaticSize = Enum.AutomaticSize.Y
bootGui.Position = UDim2.new(0.5, -110, 0.5, -70)
bootGui.BackgroundColor3 = UI_BG
bootGui.BorderSizePixel = 0
bootGui.Active = true
bootGui.Draggable = true
bootGui.ZIndex = 20
bootGui.Parent = screen
do
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = bootGui
    local bs = Instance.new("UIStroke"); bs.Color = Color3.fromRGB(200, 200, 210); bs.Thickness = 1; bs.Parent = bootGui
    local bp = Instance.new("UIPadding")
    bp.PaddingTop = UDim.new(0, 10); bp.PaddingBottom = UDim.new(0, 10)
    bp.PaddingLeft = UDim.new(0, 10); bp.PaddingRight = UDim.new(0, 10)
    bp.Parent = bootGui
    local bl = Instance.new("UIListLayout"); bl.Padding = UDim.new(0, 6); bl.SortOrder = Enum.SortOrder.LayoutOrder; bl.Parent = bootGui
end

local bootTitle = Instance.new("TextLabel")
bootTitle.Size = UDim2.new(1, 0, 0, 18)
bootTitle.BackgroundTransparency = 1
bootTitle.Font = Enum.Font.GothamBold
bootTitle.TextSize = 13
bootTitle.TextColor3 = UI_TXT
bootTitle.Text = "UNDETEK Sniper"
bootTitle.Parent = bootGui

local bootSub = Instance.new("TextLabel")
bootSub.Size = UDim2.new(1, 0, 0, 28)
bootSub.BackgroundTransparency = 1
bootSub.Font = Enum.Font.Gotham
bootSub.TextSize = 9
bootSub.TextColor3 = UI_TXT_DIM
bootSub.TextWrapped = true
bootSub.Text = "SAFE / RAGE · 360° auto · cam libre · tir auto"
bootSub.Parent = bootGui

local function makeBootBtn(text, bg, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = UI_TXT
    b.Text = text
    b.LayoutOrder = order
    b.AutoButtonColor = true
    b.Parent = bootGui
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    return b
end

local safeBtn = makeBootBtn("Start Safe Script", Color3.fromRGB(180, 220, 195), 1)
local rageBtn = makeBootBtn("Start Rage Script", Color3.fromRGB(230, 190, 175), 2)
local bootUnloadBtn = makeBootBtn("Annuler / UNLOAD", Color3.fromRGB(220, 220, 225), 3)

local function applyRagePreset()
    -- Absolute max aggression — 360 + flick hold + auto
    CFG.aimEnabled = true
    CFG.trigEnabled = true
    CFG.espEnabled = true
    CFG.full360 = true
    State.freeCam = true
    State.first360FireToast = false
    CFG.aimSmoothing = 0
    CFG.aimFov = 999
    CFG.aimReleaseFov = 999
    CFG.aimSticky = true
    CFG.trigFov = 999
    CFG.trigCooldown = 0
    CFG.fireDelay = 0.02
    CFG.alignThreshold = 8.0
    CFG.trigHardSnap = true
    CFG.trigSettleFrames = 0
    CFG.trigScopeDelay = 0
    CFG.predEnabled = true
    CFG.predScale = 1.25
    CFG.predExtraMs = 45
    CFG.predAccel = true
    CFG.predIter = 3
    CFG.predMaxStuds = 8.0
    CFG.predMaxSpeed = 64
    CFG.rangeTrack = true
    CFG.rangeDrop = true
    CFG.rangeDropScale = 0.18
    CFG.rangeLeadBoost = 0.14
    CFG.visibleOnly = true
    CFG.teamCheck = true
    CFG.showFovCircle = false
    -- reset humanize state (evite residu Safe si re-exec apres unload partiel)
    State.humBezierT = 0
    State.humBezierModel = nil
    State.humLastLook = nil
    State.humOverUntil = 0
    State.humPxOff = Vector2.zero
    State.humPxTarget = Vector2.zero
end

local function applySafePreset()
    -- 360 + cam libre + tir auto · 0 miss sur flick hold (pas de humanize display)
    CFG.aimEnabled = true
    CFG.trigEnabled = true
    CFG.espEnabled = true
    CFG.full360 = true
    State.freeCam = true
    State.first360FireToast = false
    CFG.aimSmoothing = 0
    CFG.aimFov = 999
    CFG.aimReleaseFov = 999
    CFG.aimSticky = true
    CFG.trigFov = 999
    CFG.trigCooldown = 0
    CFG.fireDelay = 0.02
    CFG.alignThreshold = 8.0
    CFG.trigHardSnap = false
    CFG.trigSettleFrames = 0
    CFG.trigScopeDelay = 0
    CFG.predEnabled = true
    CFG.predScale = 1.15
    CFG.predExtraMs = 40
    CFG.predAccel = false -- Safe: accel OFF (bruit visuel)
    CFG.predIter = 2
    CFG.predMaxStuds = 6.5
    CFG.predMaxSpeed = 56
    CFG.rangeTrack = true
    CFG.rangeDrop = true
    CFG.rangeDropScale = 0.14
    CFG.rangeLeadBoost = 0.10
    CFG.visibleOnly = true
    CFG.teamCheck = true
    CFG.showFovCircle = false
    CFG.safeGaussStuds = 0.035 + math.random() * 0.02
    CFG.safePxMin = 2
    CFG.safePxMax = 7
    CFG.safeSmoothTime = 0.12 + math.random() * 0.06
    CFG.safeBezierSec = 0.16 + math.random() * 0.08
    CFG.safeOvershootP = 0.008 + math.random() * 0.006
    retargetHumPixels()
end

local function startScriptMode(mode)
    if State.bootReady then return end
    mode = (mode == "safe") and "safe" or "rage"
    State.scriptMode = mode
    State.bootReady = true
    if typeof(getgenv) == "function" then
        getgenv().UNDETEK_SNIPER_MODE = mode
    end
    if mode == "safe" then
        applySafePreset()
        modeBadge.Text = "MODE: SAFE · 360° auto · cam libre"
        modeBadge.TextColor3 = Color3.fromRGB(40, 120, 70)
        sub.Text = "v" .. VERSION .. " SAFE - 360° auto · cam libre · tir auto"
    else
        applyRagePreset()
        modeBadge.Text = "MODE: RAGE · 360° auto · cam libre"
        modeBadge.TextColor3 = Color3.fromRGB(160, 70, 50)
        sub.Text = "v" .. VERSION .. " RAGE - 360° auto · cam libre · tir auto"
    end
    bootGui.Visible = false
    pcall(function() bootGui:Destroy() end)
    frame.Visible = true
    if State._toggleRenders then
        for _, r in ipairs(State._toggleRenders) do pcall(r) end
    end
    applyFixedFov()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "UNDETEK Sniper v" .. VERSION,
            Text = "360° FIX: flick hold + LOS corps. RightShift = menu.",
            Duration = 6,
        })
    end)
end

safeBtn.MouseButton1Click:Connect(function() startScriptMode("safe") end)
rageBtn.MouseButton1Click:Connect(function() startScriptMode("rage") end)

-- Mode session (lecture seule) — le chooser s'affiche toujours a l'exec
if typeof(getgenv) == "function" and getgenv().UNDETEK_SNIPER_MODE then
    local prev = tostring(getgenv().UNDETEK_SNIPER_MODE)
    if prev == "safe" or prev == "rage" then
        bootSub.Text = "Dernier mode session: " .. string.upper(prev) .. ". Rechoisis Safe ou Rage."
    end
end

----------------------------------------------------------------------
-- STATUS LOOP (throttle ~3/sec — pas de walk Characters chaque Heartbeat)
----------------------------------------------------------------------
local statusAt = 0
State.conns[#State.conns + 1] = RunService.Heartbeat:Connect(function()
    if not State.alive or not State.bootReady then return end
    local now = tick()
    if now - statusAt < 0.35 then return end
    statusAt = now
    pcall(function()
        local live = collectTargets(false)
        local n = 0
        for _, t in ipairs(live) do if not (CFG.teamCheck and t.sameTeam) then n = n + 1 end end
        local tgtName = "aucune"
        if State.currentTarget and State.currentTarget.Parent then tgtName = State.currentTarget.Name end
        local trigTxt
        if not CFG.trigEnabled then trigTxt = "off"
        elseif State.firing then trigTxt = "TIR"
        elseif State.trigReady then trigTxt = "ready"
        else trigTxt = "cooldown" end
        local modeTxt = State.scriptMode == "safe" and "SAFE" or (State.scriptMode == "rage" and "RAGE" or "?")
        local camTxt = CFG.full360 and "360" or "FOV"
        status.Text = string.format(
            "%s %s E:%d %s\nR:%dm Aim:%s Trig:%s",
            modeTxt, camTxt, n, tgtName, math.floor(State.lastRange + 0.5),
            aimActive() and "ON" or "off",
            trigTxt)
    end)
end)

----------------------------------------------------------------------
-- UNLOAD + HOTKEY
----------------------------------------------------------------------
local function unload()
    State.alive = false
    if State.crouchHeld then crouchRelease() end
    restoreFixedFov()
    pcall(function() RunService:UnbindFromRenderStep(RENDER_NAME) end)
    for _, c in ipairs(State.conns) do pcall(function() c:Disconnect() end) end
    clearAllEsp()
    if State.fovCircle then pcall(function() State.fovCircle:Remove() end) end
    pcall(function() if bootGui then bootGui:Destroy() end end)
    pcall(function() screen:Destroy() end)
    if getgenv then
        getgenv().__XHUB_SNIPER_STANDALONE = nil
        getgenv().__XHUB_SNIPER_STANDALONE_UNLOAD = nil
    end
end
unloadBtn.MouseButton1Click:Connect(unload)
bootUnloadBtn.MouseButton1Click:Connect(unload)

State.conns[#State.conns + 1] = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if not State.bootReady then return end
        frame.Visible = not frame.Visible
    end
end)

-- refresh camera + re-acquisition perso au respawn
State.conns[#State.conns + 1] = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if Workspace.CurrentCamera then
        Camera = Workspace.CurrentCamera
        if State.bootReady then applyFixedFov() end
    end
end)
State.conns[#State.conns + 1] = LocalPlayer.CharacterAdded:Connect(function()
    State.currentTarget = nil
    State.myTeamTag = nil
    -- re-applique le FOV immediatement au respawn (self-heal) — seulement apres boot
    task.spawn(function()
        task.wait(0.3)
        if not State.alive or not State.bootReady then return end
        applyFixedFov()
    end)
end)

if getgenv then
    getgenv().__XHUB_SNIPER_STANDALONE = true
    getgenv().__XHUB_SNIPER_STANDALONE_UNLOAD = unload
end

pcall(function()
    -- FOV 120 applique apres Start Safe/Rage (pas avant le modal)
    StarterGui:SetCore("SendNotification", {
        Title = "UNDETEK Sniper v" .. VERSION,
        Text = "Choisis Start Safe ou Start Rage · 360° auto.",
        Duration = 5,
    })
end)
