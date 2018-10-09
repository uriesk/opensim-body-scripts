//### tattoo-hud.lsl
//HUD for selecting textures for tattoo layer
integer gi_buttonOffset = 4;
integer gi_frontFace = 4;
integer gi_linkBack = 2;
integer gi_linkForward = 3;
integer gi_linkApply = 17;
integer gi_linkHelp = 19;
integer gi_linkRefresh = 20;
integer gi_itemCount;
integer gi_curPage;
//faces of model
integer gi_modelLink = 18;
integer gi_headFace = 1;
integer gi_upperFace = 2;
integer gi_lowerFace = 3;
integer gi_tattooUpperFace = 5;
integer gi_tattooLowerFace = 6;
integer gi_clothesUpperFace = 7;
integer gi_clothesLowerFace = 0;
integer gi_curSel;
//channels
integer gi_SkinChannel = -60;
integer gi_SkinHUDChannel = -61;
//transparent texture name
string gs_transparentTextureName = "transparent";
//Skin texture lists
list gl_ident;
//tmp
integer gi_listenerSkinHUDChannel;
key gk_curUpper;
key gk_curLower;

drawButtons()
{
    integer i_pageCount = llFloor((gi_itemCount - 1) / 12);
    if (gi_curPage > i_pageCount)
    {
        gi_curPage = 0;
    }
    if (gi_curPage < 0)
    {
        gi_curPage = i_pageCount;
    }

    integer a = 0;
    integer i_item;
    string s_item;
    string s_texture;
    while (a < 12)
    {
        i_item = gi_curPage * 12 + a;
        if (i_item < gi_itemCount)
        {
            s_item = llList2String(gl_ident, i_item);
            if (llGetInventoryType(s_item + "-upper") == INVENTORY_TEXTURE)
            {
                s_texture = s_item + "-upper";
            }
            else if (llGetInventoryType(s_item + "-lower") == INVENTORY_TEXTURE)
            {
                s_texture = s_item + "-lower";
            }
            else
            {
                s_texture = NULL_KEY;
            }
            llSetLinkPrimitiveParamsFast(a + gi_buttonOffset,      [PRIM_TEXTURE, gi_frontFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, gi_frontFace, <1.0, 1.0, 1.0>, 1.0, PRIM_TEXT, s_item, <0.9, 0.9, 0.9>, 1.0]);
            /*//Draw Text
            CommandList = osSetFontSize( CommandList, gi_fontSize );
            string TextToDraw = llGetSubString(s_item, 0, 15);
            vector Extents = osGetDrawStringSize( "vector", TextToDraw, "Arial", gi_fontSize );
            vector Position = llList2Vector(gl_textPositions, a);
            integer xpos = (integer)llFloor(gi_textureDimension * Position.x - ((integer) Extents.x >> 1));
            integer ypos = (integer)llFloor(gi_textureDimension * (1 - Position.y) - ((integer) Extents.y >> 1));
            CommandList = osMovePen( CommandList, xpos, ypos );
            CommandList = osDrawText( CommandList, TextToDraw );*/
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
    if (llGetInventoryType(gs_transparentTextureName) == INVENTORY_TEXTURE)
    {
        llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesUpperFace, gs_transparentTextureName, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesLowerFace, gs_transparentTextureName, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        gk_curUpper = (key)gs_transparentTextureName;
        gk_curLower = (key)gs_transparentTextureName;
    }
    llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, 4, "73c54d8e-18bc-4c2e-9861-b63092bc30ed", <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
    llRegionSayTo(llGetOwner(), gi_SkinChannel, "gettexture");
    gi_listenerSkinHUDChannel = llListen(gi_SkinHUDChannel, "", "", "");
    llSetTimerEvent(3.0);
}

default
{
    state_entry()
    {
        //rotate model
        llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_OMEGA, <0.0, 0.0, 1.0>, PI / -4, 1.0, PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0]);
        //check textures in inventory and populate lists
        integer i_itemCount = llGetInventoryNumber(INVENTORY_TEXTURE);
        integer a = 0;
        string s_item;
        string s_ident;
        string s_part;
        integer b;
        while (a < i_itemCount)
        {
            s_item = llGetInventoryName(INVENTORY_TEXTURE, a);
            b = llSubStringIndex(s_item, "-");
            s_ident = llGetSubString(s_item, 0, b - 1);
            s_part = llGetSubString(s_item, b + 1, -1);
            if (s_part == "upper" || s_part == "lower" || s_part == "head" || s_part == "neck")
            {
                if (llListFindList(llList2List(gl_ident, -5, -1), [s_ident]) == -1)
                {
                    b = llGetListLength(gl_ident);
                    gl_ident += [s_ident];
                }
            }
            ++a;
        }
        gi_curPage = 0;
        gi_itemCount = llGetListLength(gl_ident);
        //draw buttons
        drawButtons();
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
        if (s_part == "lower")
        {
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_lowerFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        }
        else if (s_part == "upper")
        {
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_upperFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        }
        else if (s_part == "head")
        {
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_headFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        }
        else if (s_part == "tattoo-upper")
        {
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_tattooUpperFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        }
        else if (s_part == "tattoo-lower")
        {
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_tattooLowerFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        }
        else if (s_part == "clothes-upper")
        {
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesUpperFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            gk_curUpper = s_texture;
        }
        else if (s_part == "clothes-lower")
        {
            llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesLowerFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            gk_curLower = s_texture;
        }
    }

    touch_start(integer num)
    {
        integer link = llDetectedLinkNumber(0);
        if (link == gi_linkBack)
        {
            --gi_curPage;
            drawButtons();
        }
        else if (link == gi_linkForward)
        {
            ++gi_curPage;
            drawButtons();
        }
        else if (link == gi_linkHelp)
        {
            llGiveInventory(llDetectedKey(0), "Help");
        }
        else if (link == gi_linkRefresh)
        {
            llResetScript();
        }
        else if (link >= gi_buttonOffset && link < gi_buttonOffset + 12)
        {
            integer i_item = gi_curPage * 12 + link - gi_buttonOffset;
            if (i_item >= gi_itemCount)
            {
                return;
            }
            gi_curSel = i_item;
            string s_ident = llList2String(gl_ident, gi_curSel); 
            string s_part = s_ident + "-upper";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesUpperFace, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesUpperFace, gk_curUpper, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
            s_part = s_ident + "-lower";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesLowerFace, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_clothesLowerFace, gk_curLower, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
        }
        else if (link == gi_linkApply)
        {
            key k_owner = llGetOwner();
            string s_ident = llList2String(gl_ident, gi_curSel); 
            string s_part = s_ident + "-upper";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                gk_curUpper = llGetInventoryKey(s_part);
                llRegionSayTo(k_owner, gi_SkinChannel, "clothes-upper:" + (string)gk_curUpper);
            }
            s_part = s_ident + "-lower";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                gk_curLower = llGetInventoryKey(s_part);
                llRegionSayTo(k_owner, gi_SkinChannel, "clothes-lower:" + (string)gk_curLower);
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
