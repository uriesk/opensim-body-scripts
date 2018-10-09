## Adonis5 Mesh Body Scripts
Adonis5 HUD is using an alpha selection mesh where the faces of the prims match the alpha faces on the body. It is much faster and drops the prim usage from 120 of the previous version (every alpha face is one linked prim) to 20.

Adonis5 isn't set up for multiple layers.

At the same time a HUD just for selecting skins using the current API got released, it is skin-hud.lsl, it got replaced later by a HUD with tabs for skins, tattoos and clothes.
