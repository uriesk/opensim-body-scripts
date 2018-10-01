# Mesh Body Scripts

This project provides scripts to create a HUD for controlling your own mesh body in OpenSim and SL.
Following features are supported:
- Selecting Alphas
- Saving and Loading Alphas configurations in slots
- Selecting Alphas in groups (like upper-arm, torso, pelvis, etc.)
- Output an ASCII string that represents the Alpha configuration
- Auto-Alpha (the clothes trigger their alphas on attach)
- Setting Skin Textures for Upper- and Lower Body and for Neck fix
- Setting those Skin textures in a text input box per UUID)

## How to build a HUD
1. Create a HUD where every Button has it's own link number (if all the buttons are on one texture, you could link a transparent cube in front of them and use that one as button). Also the Counter that is showing the number of the current selected slot has to have it's own link number.
2. Put the *hud.lsl* script and the *numbers* texture into the root prim of the HUD.
3. The Description field of the linked Button is specifying what they do, following Descriptions are possible:
   - P23
     Toggle a single alpha element by number and face. this example will toggle the alpha face 3 of link number 2 on the body. P112 would toggle face 2 on link number 11.
  - R
    Reset all alphas
  - -1\<alpha string\>
    Toggle alphas on a whole group that is defined by an alpha string. Used to set alphas i.e. on whole Torso
  - C
    This link will display the number of the currently selected alpha slot
  - \>
    Button to switch to next alpha slot
  - \<
    Button for going to previous alpha slot
  - S
    Save current alpha configuration into slot
  - L
    Load alpha configuration from slot
  - U\<name\>
    Ask user to prvide a UUID of a skin texture for a body part. Currently implemented names: "Upper Body", "Lower Body", "Neck", "Eyes" and "Head"
  - G
    Print the current alpha configuration string in the chat to the Owner
4. Put the *body-single-layer.lsl* script into the mesh body

## Tattoo and clothing layers
Mesh bodies that provide tattoo and clothing layers in SL are doing that by putting multiple full bodies on top of each other like onion layors. While this is a necessity in SL to be able to sell tattoos and applier clothes for mesh bodies without having to reveal the texture itself, this is of course also causing lots of lag and it is also lots of work to set it up right.
Within the OpenSource community of OpenSim, this is not needed, because you can just take a tattoo layer, put it on your skin texture with photoshop, gimp, whatever, upload it yourself and set it as your skin. Also there is the talk about bake-on-mesh already for years, which would make those onion layers obsolete.

The scripts might be adjusted in the future to provide also the possibility of layored mesh bodies, but this is a very low priority right now.

