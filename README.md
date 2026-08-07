# UNDETEK xhub — Sniper Duels

Standalone scripts · No hub · No key.
PlaceId `109397169461300` · **Combat v8.1** · **Autofarm v1.0**

[-- UNDETEK xhub Supported Games --]
[+] Sniper Duels

[-- Two scripts (separated) --]
[+] `script.lua` — **combat only** v8.1 (aim / trigger / ESP / predict / dodge / slide)
[+] `autofarm.lua` **v1.1** — **lobby queue loop** (PLAY DUELS → 1v1 only → QUEUE → RETURN)
    Soft PlaceId (lobby UI OK), robust button find/click, debug toasts + F9 logs

Hunt/Chase pathfinding was **removed from combat** (micro-lag). Optional cover/hunt lives in autofarm, throttled (repath ~1.5s, ComputeAsync off hot path).

[-- Combat v8.1 --]
[+] Boot : Start Safe Script | Start Rage Script (RightShift menu)
[+] **Slide fix** — Shift+W (run) **then** Ctrl pulse (not Ctrl alone)
[+] **Respawn click** — mouse1click center after 0.3s (FOV/zoom fix) + teleport detect
[+] **Dodge loin** — burst lateral · wall check LOS
[+] **Memory locale Xeno (stats)** — `UNDETEK_memory/sniper_v8.json` leadScale EMA (not LLM)
[+] Predict runners · aim-first HARD · ADS instant · ESP

[-- Autofarm v1.0 — how to use --]
1. Join Sniper Duels **lobby**
2. Exec `autofarm.lua` **ONCE** (Xeno)
3. Loop: PLAY DUELS → keep **1v1** · turn off 2v2/3v3/4v4/FFA/Crown → QUEUE
4. Match start → loads combat once (`UNDETEK_SNIPER_AUTOFARM=true` → auto Rage)
5. Match end (~20s no char + **RETURN TO LOBBY**) → click → repeat
6. Stop: leave place / quit Xeno / unload. **Does not** auto-restart on rejoin — re-exec autofarm.

[-- Honest limits --]
[-] Memory stats = local Xeno file (leadScale/hits) — not a remote LLM
[-] Autofarm cover/hunt = cheap PathfindingService, throttled — not "AI LAN"
[-] Dodge = best-effort client
[-] No Silent Aim / Kill Aura / Spinbot

[-- Suggested Executors --]
PC: Xeno, Volt, Solara
MOBILE: Delta, Codex

[-- Links --]
GitHub: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
Combat raw: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua
Autofarm raw: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua
Discord: https://discord.gg/cgRsTMUa9J
Site: https://xhub.blog/library#/games/sniper-duels

[-- Loadstring combat --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua"))()
```

[-- Loadstring autofarm (lobby) --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua"))()
```

[-- Tags --]
`sniper` `duels` `aimbot` `triggerbot` `esp` `undetek` `xeno` `autofarm`
