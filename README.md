# UNDETEK xhub — Sniper Duels

Standalone scripts · No hub · No key.
PlaceId `109397169461300` · **Combat v8.21** · **Autofarm v2.5**

[-- Two scripts --]
[+] `script.lua` — **combat only** v8.21 (aim / trigger / ESP / dodge — sans bot hunt)
[+] `autofarm.lua` — **v2.5** HUD mode → case vide → MoveTo + nudge → combat si loin → RETURN TO LOBBY

[-- Autofarm v2.5 — HUD + nudge --]
1. Join Sniper Duels **lobby**
2. Exec `autofarm.lua` **ONCE** (Xeno)
3. HUD **MRN / UNDETEK** (haut-gauche) → choisis **1v1 / 2v2 / 3v3 / 4v4** (changeable anytime)
4. Prefère une **case vide** (aucun joueur ~10 studs) parmi les 4 pads du mode
5. Suit le PATH (MoveTo + sprint) + **petit coup en avant** en fin de path
6. HUD masqué si **>250 studs** · réaffiché au lobby
7. Si **>250 studs** du lobby → charge combat Rage
8. **Combat OFF** au lobby
9. Fin de match → souris sur **RETURN TO LOBBY** → re-scan case vide → re-path
10. Stop: leave / quit Xeno / unload autofarm

[-- Combat v8.21 --]
[+] Safe / Rage · ADS · LOS · dodge · ESP
[+] Sans Bot Hunt dans le menu

[-- Links --]
GitHub: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
+ info: https://github.com/jvd11665-dot/UNDETEK-xhub-sniper
Combat: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=821
Autofarm: https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua?v=25

[-- Loadstring combat --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/script.lua?v=821"))()
```

[-- Loadstring autofarm --]
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jvd11665-dot/UNDETEK-xhub-sniper/main/autofarm.lua?v=25"))()
```
