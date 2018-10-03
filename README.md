# Mesh Body Scripts

This project provides scripts to create a HUD for controlling your own mesh body in OpenSim and SL.
Following features are supported:
- Selecting Alphas
- Saving and Loading Alphas configurations in slots
- Selecting Alphas in groups (like upper-arm, torso, pelvis, etc.)
- Output an ASCII string that represents the Alpha configuration
- Auto-Alpha (the clothes trigger their alphas on attach)
- Setting Skin Textures for Upper- and Lower Body and for Neck fix via UUID input field
  (if you want a texture selection, use another script)

## How to build a HUD
1. Create a HUD where every Button has it's own link number (if all the buttons are on one texture, you could link a transparent cube in front of them and use that one as button) or at least its own face or some group (like one linked prim above 6 in a row). Also the Counter that is showing the number of the current selected slot has to have it's own link number or face.
2. Put the *hud.lsl* script and the *numbers* texture into the root prim of the HUD.
3. Set the description of the HUD to some simple name that will get used as identification string when communicating with the body (i.e. "adonis")
4. The Description field of the linked Button is specifying what they do, following Descriptions are possible:
  - leading Z
    Toggle the alpha of the touched link/face on click, rest of the string gets interpreted as usual command
  - P23
    Toggle a single alpha element by number and face. this example will toggle the alpha face 3 of link number 2 on the body. P112 would toggle face 2 on link number 11. Face number 9 is ALL_SIDES.
    Can also be with - split list of multiple faces (i.e. P23-39).
    (this gets used if every single alpha element in the HUD is an own linked prim)
  - Q2
    Toggle a single alpha element by link number (here: 2) and the touched face.
    (this gets used if the alpha buttons in the HUD are are linked prims where the face number corespondend with the face number of the body - this is recommended)
  - R
    Reset all alphas
  - -\<number\>\<alpha string\>
    Toggle alphas on a whole group that is defined by an alpha string. Used to set alphas i.e. on whole Torso
    Possible numbers:
    1 -> set given alphas to active
    2 -> set given alphas to non-active
    3 -> toggle given alphas individually
    4 -> set whole body to this string (i.e. alpha saving slots)
    5 -> toggle given alphas in group, all set or all unset (i.e. group selection button like "Torso", "Upper legs")
  - C
    This link will display the number of the currently selected alpha slot
  - \>
    Button to switch to next alpha slot
  - \<
    Button for going to previous alpha slot
  - S
    Save current alpha configuration into slot
  - T
    Send command directly to body (i.e.: Tfeet0 to send "feet0" to body to use it there to select different feet meshes)
  - L
    Load alpha configuration from slot
  - U\<name\>
    Ask user to prvide a UUID of a skin texture for a body part. Currently implemented names: "Upper Body", "Lower Body", "Neck", "Eyes" and "Head"
  - A
    Print the current alpha configuration string in the chat to the Owner
  - Gx|x|x;x|x|x
    A Group button (like one prim above a list of 5 buttons) with own defined behaviour, this can be used for finger nail forms, list of group selection button, for textures or just saving prims, etc. . i.e.: "G>|<" would use the upper half of the prim for the < button and the lower half for the > button.
5. If some of the buttons can't be set up by description like in 3 (maybe because you need more characters as the description allowes), give them an empty description and map them in the gl\_mapping list in the hud.lsl script. If it is the counter, set the gi\_counterLinkNumber and gi\_counterFaceNumber in the script.
   (example: ["13", "R"] for link 1 face 3 being the reset button)

## Setup mesh body to HUD
1. Put the *body-single-layer.lsl* script into the mesh body
2. change the gs\_ident string in body-single-layer.lsl to the same string that you set above on 3 as description for the HUD
3. Generate a gs_alphaFilterMask string with the tools/alphastring.lsl script (instructions are there)
   The gs_alphaFilterMask tells the script which links/faces to ignore when toggling alphas.
4. Now you can test the HUD, individual alphas should already be able to get set just fine and the reset button should work
5. To be able to set textures for upper-body, lower-body, etc., you have to set the name and the alpha-string for it in gl\_textureSets
   like: ["upper", "\<alpha string\>", "lower", "\<alpha string\>"]
   You can also use the tools/alphastring.lsl script for generating those.


## Tattoo and clothing layers
Mesh bodies that provide tattoo and clothing layers in SL are doing that by putting multiple full bodies on top of each other like onion layors. While this is a necessity in SL to be able to sell tattoos and applier clothes for mesh bodies without having to reveal the texture itself, this is of course also causing lots of lag and it is also lots of work to set it up right.
Within the OpenSource community of OpenSim, this is not needed, because you can just take a tattoo layer, put it on your skin texture with photoshop, gimp, whatever, upload it yourself and set it as your skin. Also there is the talk about bake-on-mesh already for years, which would make those onion layers obsolete.

The scripts might be adjusted in the future to provide also the possibility of layored mesh bodies, but this is a very low priority right now.

