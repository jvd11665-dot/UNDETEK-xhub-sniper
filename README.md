# UNDETEK xhub — Sniper Duels

Standalone scripts · No hub · No key.
PlaceId `109397169461300` · **Combat v8.11** · **Autofarm v1.0**

[-- UNDETEK xhub Supported Games --]
[+] Sniper Duels

[-- Two scripts (separated) --]
[+] `script.lua` — **combat only** v8.11 (aim / trigger / ESP / predict / dodge / slide / hunt / knife / reload)
[+] `autofarm.lua` **v1.1** — **lobby queue loop** (PLAY DUELS → 1v1 only → QUEUE → RETURN)
    Soft PlaceId (lobby UI OK), robust button find/click, debug toasts + F9 logs

[-- Combat v8.11 — reload + ADS loin + couteau --]
[+] Boot : Start Safe Script | Start Rage Script (RightShift menu)
[+] **Auto-reload** — StartReload / R quand chargeur vide
[+] **ADS loin** — hold clic droit + Aiming avant de se présenter (≥40)
[+] **Couteau** — touche 2 au contact (≤12) · touche 1 sniper en reculant (≥16)
[+] Hunt + dodge stables (feeling v8.10 / v8.5) · clearScope Rage
[+] Slide · respawn FOV · Predict · ESP · memory locale Xeno

[-- Autofarm v1.0 — how to use --]
1. Join Sniper Duels **lobby**
2. Exec `autofarm.lua` **ONCE** (Xeno)
3. Loop: PLAY DUELS → keep **1v1** · turn off 2v2/3v3/4v4/FFA/Crown → QUEUE
4. Match start → loads combat once (`UNDETEK_SNIPER_AUTOFARM=true` → auto Rage)
5. Match end (~20s no char + **RETURN TO LOBBY**) → click → repeat
6. Stop: leave place / quit Xeno / unload. **Does not** auto-restart on rejoin — re-exec autofarm.

[-- Honest limits --]
[-] Memory stats = local Xeno file (leadScale/hits) — not a remote LLM
[-] Autofarm cover/hunt = cheap PathfindingService, throttled
[-] Dodge = best-effort client
[-] No Silent Aim / Kill Aura / Spinbot

[-- Suggested Executors --]
PC: Xeno, Volt, Solara
MOBILE: Delta, Codex

[-- Links --]
GitHub: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
+ info: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
Combat raw: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=811
Autofarm raw: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua
Discord: https://discord.gg/cgRsTMUa9J
Site: https://xhub.blog/library#/games/sniper-duels

[-- Loadstring combat --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=811"))()
```

[-- Loadstring autofarm (lobby) --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua"))()
```

[-- Tags --]
`sniper` `duels` `aimbot` `triggerbot` `esp` `undetek` `xeno` `autofarm`
