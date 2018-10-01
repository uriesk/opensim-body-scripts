//### texture-hud.lsl
//HUD for selecting textures
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
integer gi_headFace = 0;
integer gi_upperFace = 2;
integer gi_lowerFace = 3;
integer gi_curSel;
//variables for text
list gl_textPositions = [<0.183510, 0.821150, 0.000000>, <0.398038, 0.821150, 0.000000>,  <0.602588, 0.819204, 0.000000>, <0.820442, 0.819204, 0.000000>, <0.178521, 0.535110, 0.000000>, <0.404690, 0.544839, 0.000000>, <0.620881, 0.539001, 0.000000>, <0.823768, 0.539001, 0.000000>, <0.173532, 0.260744, 0.000000>, <0.399701, 0.258799, 0.000000>, <0.614229, 0.264636, 0.000000>, <0.818779, 0.260744, 0.000000>];
integer gi_textureDimension = 1024;
integer gi_fontSize = 17;
list gl_textureBuffer;
//Skin texture lists
list gl_ident;

drawButtons()
{
    string CommandList = "";

    integer i_pageCount = llFloor((gi_itemCount - 1) / 12);
    if (gi_curPage > i_pageCount)
    {
        gi_curPage = 0;
    }
    if (gi_curPage < 0)
    {
        gi_curPage = i_pageCount;
    }

    CommandList = osSetFontSize(CommandList, 24);
    CommandList = osMovePen(CommandList, (integer)llFloor(0.90 * gi_textureDimension), (integer)llFloor(0.05 * gi_textureDimension));
    CommandList = osDrawText(CommandList, (string)(gi_curPage + 1) + "/" + (string)(i_pageCount + 1));

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
            s_texture = s_item + "-upper";
            if (llGetInventoryType(s_texture) != INVENTORY_TEXTURE)
            {
                s_texture = NULL_KEY;
            }
            llSetLinkPrimitiveParamsFast(a + gi_buttonOffset,  	[PRIM_TEXTURE, gi_frontFace, s_texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, gi_frontFace, <1.0, 1.0, 1.0>, 1.0]);
            //llSetLinkPrimitiveParamsFast(a + gi_buttonOffset,  	[PRIM_TEXTURE, gi_frontFace, s_item, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, gi_frontFace, <1.0, 1.0, 1.0>, 1.0, PRIM_TEXT, s_item, <0.0, 0.0, 0.0>, 1.0]);
            //Draw Text
            CommandList = osSetFontSize( CommandList, gi_fontSize );
            string TextToDraw = llGetSubString(s_item, 0, 15);
            vector Extents = osGetDrawStringSize( "vector", TextToDraw, "Arial", gi_fontSize );
            vector Position = llList2Vector(gl_textPositions, a);
            integer xpos = (integer)llFloor(gi_textureDimension * Position.x - ((integer) Extents.x >> 1));
            integer ypos = (integer)llFloor(gi_textureDimension * (1 - Position.y) - ((integer) Extents.y >> 1));
            CommandList = osMovePen( CommandList, xpos, ypos );
            CommandList = osDrawText( CommandList, TextToDraw );
        }
        else
        {
            llSetLinkPrimitiveParamsFast(a + gi_buttonOffset,  	[PRIM_COLOR, gi_frontFace, <1.0, 1.0, 1.0>, 0.0]);
            //llSetLinkPrimitiveParamsFast(a + gi_buttonOffset,  	[PRIM_COLOR, gi_frontFace, <1.0, 1.0, 1.0>, 0.0, PRIM_TEXT, "", ZERO_VECTOR, 0.0]);
        }
        ++a;
    }
    key texture = llList2Key(gl_textureBuffer, gi_curPage);
    if (texture == NULL_KEY)
    {
        llSetTimerEvent(5.5);
        llSetLinkPrimitiveParamsFast(LINK_ROOT, [PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 0.1]);
        osSetDynamicTextureData( "", "vector", CommandList, "width:" + (string)gi_textureDimension + ",height:" + (string)gi_textureDimension + ",alpha:0", 0 );
        texture = llList2Key(llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_TEXTURE, ALL_SIDES]), 0);
        gl_textureBuffer = llListReplaceList(gl_textureBuffer, [texture], gi_curPage, gi_curPage);
    }
    else
    {
        llSetLinkPrimitiveParamsFast(LINK_ROOT, [PRIM_TEXTURE, ALL_SIDES, texture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
    }
}

default
{
    state_entry()
    {
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
        //initialize buffer for text-textures
        a = 0;
        integer pageCnt = llFloor(gi_itemCount / 12);
        while (a <= pageCnt)
        {
            gl_textureBuffer += [NULL_KEY];
            ++a;
        }
        //draw buttons
        drawButtons();
    }

    timer()
    {
        llSetTimerEvent(0);
        llSetLinkPrimitiveParamsFast(LINK_ROOT, [PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0]);
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
            string s_part = s_ident + "-head";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_headFace, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
            s_part = s_ident + "-upper";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_upperFace, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
            s_part = s_ident + "-lower";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llSetLinkPrimitiveParamsFast(gi_modelLink, [PRIM_TEXTURE, gi_lowerFace, s_part, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
            }
        }
        else if (link == gi_linkApply)
        {
            key k_owner = llGetOwner();
            string s_ident = llList2String(gl_ident, gi_curSel); 
            string s_part = s_ident + "-head";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llRegionSayTo(k_owner, -60, "head:" + (string)llGetInventoryKey(s_part));
                llRegionSayTo(k_owner, 300301, (string)llGetInventoryKey(s_part));
            }
            s_part = s_ident + "-upper";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llRegionSayTo(k_owner, -60, "upper:" + (string)llGetInventoryKey(s_part));
            }
            s_part = s_ident + "-lower";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llRegionSayTo(k_owner, -60, "lower:" + (string)llGetInventoryKey(s_part));
            }
            s_part = s_ident + "-neck";
            if (llGetInventoryType(s_part) == INVENTORY_TEXTURE)
            {
                llRegionSayTo(k_owner, -60, "neck:" + (string)llGetInventoryKey(s_part));
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
