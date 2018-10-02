# Athena Mesh Body Script

The Athena5 HUD has one linked prim for every alpha. This makes the prim usage very high, while setting it up is a lot easier than having one-face -> one alpha.

## How to build Athena HUD
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

