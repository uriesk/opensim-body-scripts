//### texture-hud.lsl
//HUD for selecting textures for tattoo layer
//buttons and tabs to press
integer gi_frontFace = 4;
integer gi_buttonsLink = 1;
integer gi_faceTabs = 0;
integer gi_faceApply = 1;
integer gi_faceRefresh = 2;
integer gi_faceHelp = 3;
integer gi_faceBack = 4;
integer gi_faceForward = 5;
//buttons for skin selection
integer gi_buttonOffset = 2;
integer gi_buttonAmount = 12;
//link of sites counter
integer gi_linkSites = 16;
//faces of preview model
integer gi_modelLink = 15;
integer gi_headFace = 1;
integer gi_upperFace = 2;
integer gi_lowerFace = 3;
integer gi_tattooUpperFace = 5;
integer gi_tattooLowerFace = 6;
integer gi_clothesUpperFace = 7;
integer gi_clothesLowerFace = 0;
//tab difference
string gs_skinTexturePrefix = "s";
string gs_tattooTexturePrefix = "t";
string gs_clothesTexturePrefix = "c";
string gs_skinCommandPrefix = "";
string gs_tattooCommandPrefix = "tattoo-";
string gs_clothesCommandPrefix = "clothes-";
//channels
integer gi_SkinChannel = -60;
integer gi_SkinHUDChannel = -61;
//transparent texture name
string gs_transparentTextureName = "transparent";
//Skin texture lists
list gl_ident;
//tmp
integer gi_itemCount;
integer gi_curPage;
integer gi_curSel;
integer gi_listenerSkinHUDChannel;
list gl_curModelTextures;
key gk_curUpper;
key gk_curLower;
string gs_curTexturePrefix;
string gs_curCommandPrefix;
integer gi_curModelFaceU;
integer gi_curModelFaceL;

drawButtons()
{
    integer i_pageCount = llFloor((gi_itemCount - 1) / gi_buttonAmount);
    if (gi_curPage > i_pageCount)
    {
        gi_curPage = 0;
    }
    if (gi_curPage < 0)
    {
        gi_curPage = i_pageCount;
    }
    llSetLinkPrimitiveParamsFast(gi_linkSites, [PRIM_TEXT, (string)(gi_curPage + 1) + " / " + (string)(i_pageCount + 1), <0.9, 0.9, 0.9>, 1.0]);

    integer a = 0;
    integer i_item;
    string s_item;
    string s_texture;
    while (a < gi_buttonAmount)
    {
        i_item = gi_curPage * gi_buttonAmount + a;
        if (i_item < gi_itemCount)
        {
            s_item = llList2String(gl_ident, i_item);
            s_texture = gs_curTexturePrefix + "-" + s_item + "-upper";
            if (llGetInventoryType(s_texture) != INVENTORY_TEXTURE)
            {
                s_texture = gs_curTexturePrefix + "-" + s_item + "-lower";
                if (llGetInventoryType(s_texture) != INVENTORY_TEXTURE)
                {
                    s_texture = gs_curTexturePrefix + "-" + s_item + "-head";
                    if (llGetInventoryType(s_texture) != INVENTORY_TEXTURE)
                    {
                        s_texture = NULL_KEY;
                    }
                }
            }
            llSetLinkPrimitiveParamsFast(a + gi_buttonOffset,      [PRIM_TEXTURE, gi_frontFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, gi_frontFace, <1.0, 1.0, 1.0>, 1.0, PRIM_TEXT, s_item, <0.9, 0.9, 0.9>, 1.0]);
        }
        else
        {
            llSetLinkPrimitiveParamsFast(a + gi_buttonOffset,      [PRIM_TEXTURE, gi_frontFace, TEXTURE_BLANK, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, gi_frontFace, <0.28, 0.28, 0.28>, 1.0, PRIM_TEXT, "", ZERO_VECTOR, 0.0]);
        }
        ++a;
    }
}

updateLayers()
{
    key k_trans = llGetInventoryKey(gs_transparentTextureName);
    gl_curModelTextures = [k_trans, k_trans, k_trans, k_trans, "73c54d8e-18bc-4c2e-9861-b63092bc30ed", k_trans, k_trans, k_trans];
    llRegionSayTo(llGetOwner(), gi_SkinChannel, "gettexture");
    gi_listenerSkinHUDChannel = llListen(gi_SkinHUDChannel, "", "", "");
    llSetTimerEvent(3.0);
}

setLayers()
{
    key k_tmp;
    integer i_cnt = 8;
    while (i_cnt--)
    {
        k_tmp = llList2Key(gl_curModelTextures, i_cnt);
        llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, i_cnt, k_tmp, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
    }
}

populateTextures()
{
    gl_ident = [];
    integer i_itemCount = llGetInventoryNumber(INVENTORY_TEXTURE);
    integer a = 0;
    string s_item;
    string s_ident;
    string s_part;
    list b;
    while (a < i_itemCount)
    {
        s_item = llGetInventoryName(INVENTORY_TEXTURE, a);
        b = llParseString2List(s_item, ["-"], []);
        s_ident = llList2String(b, 0);
        if (s_ident == gs_curTexturePrefix)
        {
            s_ident = llList2String(b, 1);
            s_part = llList2String(b, 2);
            if (s_part == "upper" || s_part == "lower" || s_part == "head" || s_part == "neck")
            {
                if (llListFindList(llList2List(gl_ident, -5, -1), [s_ident]) == -1)
                {
                    b = llGetListLength(gl_ident);
                    gl_ident += [s_ident];
                }
            }
        }
        ++a;
    }
    gi_curPage = 0;
    gi_itemCount = llGetListLength(gl_ident);
    //draw buttons
    drawButtons();
}

default
{
    state_entry()
    {
        //rotate model
        llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_OMEGA, <0.0, 0.0, 1.0>, PI / -4, 1.0, PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0]);
        //check textures for Skins in inventory and populate lists
        llSetLinkPrimitiveParamsFast(gi_buttonsLink, [PRIM_TEXTURE, gi_faceTabs, "hud-tabs", <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_COLOR, gi_clothesUpperFace, <1.0, 1.0, 1.0>, 0.0, PRIM_COLOR, gi_clothesLowerFace, <1.0, 1.0, 1.0>, 0.0]);
        gi_curModelFaceU = gi_upperFace;
        gi_curModelFaceL = gi_lowerFace;
        gs_curTexturePrefix = gs_skinTexturePrefix;
        gs_curCommandPrefix = gs_skinCommandPrefix;
        populateTextures();
        updateLayers();
    }

    on_rez(integer num)
    {
        updateLayers();
    }

    timer()
    {
        llSetTimerEvent(0.0);
        llListenRemove(gi_listenerSkinHUDChannel);
        setLayers();
    }

    listen(integer channe, string name, key id, string message)
    {
        if (llGetOwnerKey(id) != llGetOwner())
        {
            return;
        }
        list l_msgList = llParseString2List(message, [":"], []);
        string s_part = llList2String(l_msgList, 0);
        key s_texture = llList2Key(l_msgList, 1);
        integer gi_target = -1;
        if (s_part == "lower")
        {
            gi_target = gi_lowerFace;
        }
        else if (s_part == "upper")
        {
            gi_target = gi_upperFace;
        }
        else if (s_part == "head")
        {
            gi_target = gi_headFace;
        }
        else if (s_part == "tattoo-upper")
        {
            gi_target = gi_tattooUpperFace;
        }
        else if (s_part == "tattoo-lower")
        {
            gi_target = gi_tattooLowerFace;
        }
        else if (s_part == "clothes-upper")
        {
            gi_target = gi_clothesUpperFace;
        }
        else if (s_part == "clothes-lower")
        {
            gi_target = gi_clothesLowerFace;
            gk_curLower = s_texture;
        }
        else
        {
            return;
        }

        if (gi_target != -1)
        {
            gl_curModelTextures = llListReplaceList(gl_curModelTextures, [s_texture], gi_target, gi_target);
        }
    }

    touch_start(integer num)
    {
        integer touched = llDetectedLinkNumber(0);
        if (touched == gi_buttonsLink)
        {
            touched = llDetectedTouchFace(0);
            if (touched == gi_faceTabs)
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_curModelFaceU, llList2Key(gl_curModelTextures, gi_curModelFaceU), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_curModelFaceL, llList2Key(gl_curModelTextures, gi_curModelFaceL), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
                vector v_touchPos = llDetectedTouchST(0);
                float f_xPos = v_touchPos.x;
                //Coordinates of tabs buttons are hardcoded here
                if (f_xPos >= 0.026 && f_xPos < 0.28)
                {
                    //Skin Tab Pressed
                    llSetLinkPrimitiveParamsFast(gi_buttonsLink, [PRIM_TEXTURE, gi_faceTabs, "hud-tabs", <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
                    llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_COLOR, gi_clothesUpperFace, <1.0, 1.0, 1.0>, 0.0, PRIM_COLOR, gi_clothesLowerFace, <1.0, 1.0, 1.0>, 0.0]);
                    gi_curModelFaceU = gi_upperFace;
                    gi_curModelFaceL = gi_lowerFace;
                    gs_curCommandPrefix = gs_skinCommandPrefix;
                    gs_curTexturePrefix = gs_skinTexturePrefix;
                }
                else if (f_xPos >= 0.28 && f_xPos < 0.588)
                {
                    //Tattoo Tab Pressed
                    llSetLinkPrimitiveParamsFast(gi_buttonsLink, [PRIM_TEXTURE, gi_faceTabs, "hud-tabs", <1.0, 1.0, 0.0>, <0.0, 0.5, 0.0>, 0.0]);
                    llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_COLOR, gi_clothesUpperFace, <1.0, 1.0, 1.0>, 0.0, PRIM_COLOR, gi_clothesLowerFace, <1.0, 1.0, 1.0>, 0.0]);
                    gi_curModelFaceU = gi_tattooUpperFace;
                    gi_curModelFaceL = gi_tattooLowerFace;
                    gs_curCommandPrefix = gs_tattooCommandPrefix;
                    gs_curTexturePrefix = gs_tattooTexturePrefix;
                }
                else if (f_xPos >= 0.588 && f_xPos < 0.971)
                {
                    //Clothes Tab Pressed
                    llSetLinkPrimitiveParamsFast(gi_buttonsLink, [PRIM_TEXTURE, gi_faceTabs, "hud-tabs", <1.0, 1.0, 0.0>, <0.0, 0.250, 0.0>, 0.0]);
                    llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_COLOR, gi_clothesUpperFace, <1.0, 1.0, 1.0>, 1.0, PRIM_COLOR, gi_clothesLowerFace, <1.0, 1.0, 1.0>, 1.0]);
                    gi_curModelFaceU = gi_clothesUpperFace;
                    gi_curModelFaceL = gi_clothesLowerFace;
                    gs_curTexturePrefix = gs_clothesTexturePrefix;
                    gs_curCommandPrefix = gs_clothesCommandPrefix;
                }
                else
                {
                    return;
                }
                populateTextures();
                setLayers();
            }
            else if (touched == gi_faceBack)
            {
                --gi_curPage;
                drawButtons();
            }
            else if (touched == gi_faceForward)
            {
                ++gi_curPage;
                drawButtons();
            }
            else if (touched == gi_faceHelp)
            {
                llGiveInventory(llDetectedKey(0), "Help");
            }
            else if (touched == gi_faceRefresh)
            {
                llResetScript();
            }
            else if (touched == gi_faceApply)
            {
                key k_owner = llGetOwner();
                key k_tmp;
                string s_ident = llList2String(gl_ident, gi_curSel); 
                string s_part = gs_curTexturePrefix + "-" + s_ident + "-upper";
                if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
                {
                    k_tmp = llGetInventoryKey(s_part);
                    llRegionSayTo(k_owner, gi_SkinChannel, gs_curCommandPrefix + "upper:" + (string)k_tmp);
                    gl_curModelTextures = llListReplaceList(gl_curModelTextures, [k_tmp], gi_curModelFaceU, gi_curModelFaceU);
                }
                s_part = gs_curTexturePrefix + "-" + s_ident + "-lower";
                if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
                {
                    k_tmp = llGetInventoryKey(s_part);
                    llRegionSayTo(k_owner, gi_SkinChannel, gs_curCommandPrefix + "lower:" + (string)k_tmp);
                    gl_curModelTextures = llListReplaceList(gl_curModelTextures, [k_tmp], gi_curModelFaceL, gi_curModelFaceL);
                }
                s_part = gs_curTexturePrefix + "-" + s_ident + "-head";
                if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
                {
                    k_tmp = llGetInventoryKey(s_part);
                    llRegionSayTo(k_owner, gi_SkinChannel, gs_curCommandPrefix + "head:" + (string)k_tmp);
                    gl_curModelTextures = llListReplaceList(gl_curModelTextures, [k_tmp], gi_headFace, gi_headFace);
                }
            }
        }
        else if (touched >= gi_buttonOffset && touched < gi_buttonOffset + gi_buttonAmount)
        {
            integer i_item = gi_curPage * gi_buttonAmount + touched - gi_buttonOffset;
            if (i_item >= gi_itemCount)
            {
                return;
            }
            gi_curSel = i_item;
            string s_ident = llList2String(gl_ident, gi_curSel); 
            string s_part = gs_curTexturePrefix + "-" + s_ident + "-upper";
            if (llGetInventoryType(s_part) != INVENTORY_TEXTURE)
            {
                s_part = (string)llList2Key(gl_curModelTextures, gi_curModelFaceU);
            }
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_curModelFaceU, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);

            s_part = gs_curTexturePrefix + "-" + s_ident + "-lower";
            if (llGetInventoryType(s_part) != INVENTORY_TEXTURE)
            {
                s_part = (string)llList2Key(gl_curModelTextures, gi_curModelFaceL);
            }
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_curModelFaceL, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);

            s_part = gs_curTexturePrefix + "-" + s_ident + "-head";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_headFace, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
        }
    }

   changed(integer change)
   {
       if (change & CHANGED_INVENTORY)
       {
           llResetScript();
       }
   }
}
