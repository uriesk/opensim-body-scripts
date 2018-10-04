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
1. Put the body-main.lsl script into the mesh body
2. change the gs\_ident string in body-main.lsl to the same string that you set above on 3 as description for the HUD
3. Generate a gs\_alphaFilterMask string with the tools/alphastring.lsl script (instructions are there)
   The gs\_alphaFilterMask tells the script which links/faces to ignore when toggling alphas.
4. Now you can test the HUD, individual alphas should already be able to get set just fine and the reset button should work
5. To be able to set textures for upper-body, lower-body, etc., you have to set the name and the alpha-string for it in gl\_textureSets
   like: ["upper", "\<alpha string\>", "lower", "\<alpha string\>"]
   You can also use the tools/alphastring.lsl script for generating those.
6. If you need exclusive selections like having 3 different nail shapes and there should be always one active and it should be able to be changed with commands like "nail0", "nail1", etc. Define the alphas in gl\_toggleSets as 2D array like ["nail", "210,220;211,221;212,222"], which means that the command nail0 sets prim 21 face 0 and prim 22 face 0 to visible and 21/1, 22/1, 21/2 and 22/2 to invisible, and so on.

## Tattoo and clothing layers
Multiple layers can be provided by wearing another body thats just slightly bigger on top of it like onion layers. The script for those layers is body-layers.lsl. It has to get SetUp exactly like the main script of the body by setting gs\_ident, gs\_alphaFilterMask and the texture list gl\_textureSets, just that the names for the textures are different like "tattoo-upper".
The link order of the layers are supposed to be exactly like the main body, but a few differences can be remapped in the gl\_faceMapping list by entering the prim/face of the main body as integer and then the corespondending prim/face of the layer as string, like [10, "21"], which maps prim 1 face 0 of main body to prim 2 face 1 of the layer.


## Autohide
It shouldn't be the responsibility of the user to set his alphas right, the clothes themself should tell what alphas they need.
For this, check out the autohide.lsl script.

## Texture HUD
The texture-hud.lsl script is for an HUD for selecting textures, it can store as many textures as you want. It has 12 buttons per page, a model that is showing the selected textures and arrow buttons to browse through the textures. 
