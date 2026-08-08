# UNDETEK xhub — Sniper Duels

Standalone scripts · No hub · No key.
PlaceId `109397169461300` · **Combat v8.28** · **Autofarm v2.12**

[-- Two scripts --]
[+] `script.lua` — **combat only** v8.28 (ADS 24/7 · smart jump · trigger · peek L/R · predict · cible smart)
[+] `autofarm.lua` — **v2.12** HUD bas-droite → case vide → MoveTo → finish pad → combat → RETURN TO LOBBY

[-- Autofarm --]
1. Join Sniper Duels **lobby**
2. Exec `autofarm.lua` **ONCE** (Xeno)
3. HUD **MRN / UNDETEK** → **1v1 / 2v2 / 3v3 / 4v4**
4. Prefère une **case vide** · PATH MoveTo · finish sur la case
5. Si **>250 studs** du lobby → charge combat (`?v=828`)
6. **Combat OFF** au lobby · fin de match → RETURN TO LOBBY

[-- Combat v8.28 --]
[+] ADS **24/7** dès le boot
[+] **Smart jump**: raycast avant MoveTo — obstacle 2–6 studs → Jump (cd 0.5s, pas de spam)
[+] Trigger + wallbang · predict renforcé
[+] Derrière mur: peek léger L/R (préfère jump+peek au slide inutile)
[+] Cible proche / qui approche · ESP max 250 · auto-reload 5

[-- Links --]
GitHub: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
+ info: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
Combat: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=828
Autofarm: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua?v=212

[-- Loadstring combat --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=828"))()
```

[-- Loadstring autofarm --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua?v=212"))()
```
