# UNDETEK xhub — Sniper Duels

Standalone scripts · No hub · No key.
PlaceId `109397169461300` · **Combat v8.30** · **Autofarm v2.14**

[-- Two scripts --]
[+] `script.lua` — **combat only** v8.30 (jump+strafe dodge · LOS stricte · trigger precis · ADS 24/7)
[+] `autofarm.lua` — **v2.14** HUD bas-droite → case vide → MoveTo → finish pad → combat → RETURN TO LOBBY

[-- Autofarm --]
1. Join Sniper Duels **lobby**
2. Exec `autofarm.lua` **ONCE** (Xeno)
3. HUD **MRN / UNDETEK** → **1v1 / 2v2 / 3v3 / 4v4**
4. Prefère une **case vide** · PATH MoveTo · finish sur la case
5. Si **>250 studs** du lobby → charge combat (`?v=830`)
6. **Combat OFF** au lobby · fin de match → RETURN TO LOBBY

[-- Combat v8.30 --]
[+] ADS **24/7** dès le boot
[+] **Esquive**: JUMP + A/D (parfois W/S) en même temps — pas slide seul
[+] **LOS stricte**: plus de tir mur aveugle — HOLD jusqu'à LOS claire
[+] Trigger **precis** (Aiming API + VIM centre + mouse1 + Activate)
[+] Peek L/R + smart jump · predict · ESP 250 · reload 5

[-- Links --]
GitHub: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
+ info: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
Combat: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=830
Autofarm: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua?v=214

[-- Loadstring combat --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=830"))()
```

[-- Loadstring autofarm --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua?v=214"))()
```
