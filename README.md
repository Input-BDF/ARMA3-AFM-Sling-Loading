# ARMA3-AFM-Sling-Loading
## Workaround for current Advanced Flight Model sling loading issues

With AFM active pilots can struggle lifting cargo pilots with SFM can lift. For example CH-67 can lift an Huron Cargo container (From the numbers for shure).

This mod will not completly fix this, but it adjusts the weight of the lifting helicopter and the lifted cargo in a configurable way when the ropes thighten (and vise versa)

## To use all this it is best to:
  * install the mod an the server (can be whitelisted)
  * AFM pilots need the mod enabled
  * a player with AFM enabled has to enter the helo before attaching cargo (once during missioon is enough, helos but state will reset on respawn)
  * when sling loading and pilot has AFM enabled all the magic happens
    * rope attaching player or pilot (depends) will see a hint about the cargos weight
    * when lifting and rope threshold is reached (above and below) pilot will be notified about the weight changes
  * players with SFM (AFM disabled) can still attach ropes when [Advanced Sling Loading](https://steamcommunity.com/sharedfiles/filedetails/?id=615007497) or [Advanced Sling Loading Refactored](https://steamcommunity.com/sharedfiles/filedetails/?id=2800112936) is enabled
  * Admins can adjust settings via configure addons. Default settings are just a feeling.
  * Admins can disallow Adv. Sling Load (Refactored) Heavy Weight Lifting or allow it (not testet totally)

## Currently tested on
  * SP - Eden editor
  * MP - local hosted server
  * MP - remote dedicated server

## What can go wrong? (aka known issues)
  * if cargo is destroyed during sling load operation it may happen that the helo-weight will increase infinitly
  * Explosion, cause the letter E in ARMA stands for Explosions
  * ...

## Special thanks for
  [Sethduda](https://github.com/sethduda) and [ryantownshend](https://github.com/ryantownshend]). I oriented a little bit on your work and concepts.