# UNDETEK xhub — Sniper Duels

Standalone script · No hub · No key.
PlaceId `109397169461300` · **v6.0**

[-- UNDETEK xhub Supported Games --]
[+] Sniper Duels

[-- Features (v6.0) --]
[+] Boot : Start Safe Script | Start Rage Script
[+] **360° au MAX + FIABLE** — acquire + hardLock chaque frame, tir 1 frame (~0ms),
    hysteresis LOS 0.45s (ne lâche plus la cible sur micro-perte de vue) — RAGE
[+] **0ms** — smoothing 0 · cooldown 0 · fireDelay 0 · FOV 999
[+] **ANTI-FREEZE** — filtre LOS stable + budget raycast/frame + cache peek/vis
    (fini les gels ~3s ; plus de reconstruction de liste à chaque ray)
[+] **FOV Wipe Parts (BETA)** — dissocie + supprime les BaseParts devant la cam
    (FOV perso + limite en studs · JAMAIS de Model/Tool/Character · batch anti-lag
    via GetPartBoundsInRadius, pas de GetDescendants du Workspace)
[+] **ADS instant** (Aiming remote + HumAttr + FOV snap — skip le ~1s scope jeu)
[+] Grosse IA cible (part visible tête>torse>HRP · HP bas · menace · plus proche)
[+] Tir VIM + mouse1click · firing failsafe 0.15s · sticky hysteresis
[+] Mode Safe (FOV humanisé) / Rage (360 MAX) + Predict + range track
[+] ESP (box / nom / vie) · UI blanche compacte · RightShift · UNLOAD

[-- Honest limits --]
[-] FOV Wipe = BETA — parts uniquement (jamais de Model), limité en studs
[-] ADS instant = attempt client (remote Aiming). Anim Viewmodel / gate serveur peuvent rester
[-] Cam libre = optionnel, moins fiable ; défaut = lock continu
[-] Pas de Silent Aim / Kill Aura / Spinbot (chemins instables ou trop flag)
[-] Optimisé pour Xeno (standalone) · script publié obfusqué

[-- Suggested Executors --]
PC: Xeno, Volt, Solara
MOBILE: Delta, Codex

[-- Links --]
GitHub: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
Raw: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua
Discord: https://discord.gg/cgRsTMUa9J
Site: https://xhub.blog/library#/games/sniper-duels

[-- Loadstring --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua"))()
```

[-- Tags --]
`sniper` `duels` `aimbot` `triggerbot` `esp` `undetek` `xeno`
