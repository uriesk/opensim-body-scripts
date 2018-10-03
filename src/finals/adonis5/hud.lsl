//### hud.lsl
// script-version: 0.7
//
//manual mapping of buttons that can't be maped in their descriptions
list gl_mapping = ["205", "L", "204", "S", "206", "R", "200", "A", "201", ">", "202", "<", "150", "ZP169", "151", "ZP179", "155", "ZP199", "156", "ZP189", "174", "G-5AAAAAAAAAAAAAH4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|-5AAAAAAAAAAAAAAAA/A/AAAAAAAAAAAAAAAAAAAAAAAAAAAAA|-5AAAAAAAAAAAAAAAAAwA///AAAAAAAAAAAAAAAAAAAAAAAAAA;-5AD//AAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|-5AAAAAAABz+AAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|-5AAAA8A8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "152", "ZP200-210-220-230-240-250-269", "153", "ZP279-289-299"];
//color of the slots counter
vector gv_counterSaveColor = <0.8, 0.0, 0.0>;
vector gv_counterUnsavedColor = <0.0,0.0,0.0>;
//link number and face of counter (gets overwritten if there is a link with description "C")
integer gi_counterLinkNumber = 20;
integer gi_counterFaceNumber = 3;
//communication channels to body
integer gi_BodyChannel = -50;
integer gi_HUDChannel = -51;

// === Do not edit something below here, if you are not a scripter ===
//for set-counter and saving sets:
integer gi_counterSelectedNumber = 1;
integer gb_saveNext = FALSE;
list gl_savedSets;
//for choosing UUIDs of Skins:
string gs_skinPart = "";
integer gi_uuidHandle;
//identification string
string gs_ident;


integer multiButtonNumber(vector v_touchPosition, vector v_dimension)
{
    integer i_vert = llFloor((1 - v_touchPosition.y) * v_dimension.y);
    integer i_hor = llFloor(v_touchPosition.x * v_dimension.x);
    return (integer)(i_hor * v_dimension.y + i_vert);
}

updateCounterNumber()
{
    integer i_selectedNumber = gi_counterSelectedNumber;
    vector v_color;
    if (i_selectedNumber > 16 || i_selectedNumber < 1) return;
    --i_selectedNumber;
    float x_offset = -0.375 + ((i_selectedNumber % 4) * 0.25);
    float y_offset = 0.375 - (llFloor(i_selectedNumber / 4) * 0.25);

    if (llListFindList(gl_savedSets, (list)gi_counterSelectedNumber) == -1)
    {
        v_color = gv_counterUnsavedColor;
    }
    else
    {
        v_color = gv_counterSaveColor;
    }

    llSetLinkPrimitiveParamsFast(gi_counterLinkNumber, [PRIM_TEXTURE, gi_counterFaceNumber, "numbers", <0.25, 0.25, 0.0>, <x_offset, y_offset, 0.0>, 0.0, PRIM_COLOR, gi_counterFaceNumber, v_color, 1]);
}

resetHUD()
{
    gi_counterSelectedNumber = 1;
    updateCounterNumber();
    llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":Reset");
    integer a = llGetNumberOfPrims();
    while(a--)
    {
        string scelto = llList2String(llGetLinkPrimitiveParams(a, [ PRIM_DESC ]), 0);
        if(scelto == "C")
        {
            gi_counterLinkNumber = a;
            gi_counterFaceNumber = ALL_SIDES;
        }
    }
}

readBase64AlphaString(string s_base64Alpha)
{
    list l_intAlphaConf = [];
    integer i_partLength = llStringLength(s_base64Alpha) / 6;
    integer a = 0;
    while (a < i_partLength)
    {
        l_intAlphaConf += (list)llBase64ToInteger(llGetSubString(s_base64Alpha, a * 6, a * 6 + 5));
        ++a;
    }
    integer i_face;
    integer i_prim;
    integer i_bitPos;
    integer i_alpha;
    integer i_split;
    integer i_primCount = llGetNumberOfPrims();
    vector v_color;
    string s_desc;
    string s_command;
    //check descriptions of all prims and set alphas
    for( a = 1; a <= i_primCount; ++a)
    {
        s_desc = llList2String(llGetLinkPrimitiveParams(a, [ PRIM_DESC ]), 0);
        s_command = llGetSubString(s_desc, 0, 1);
        if (s_command == "ZP")
        {
            //if multiple faces, just care about first
            i_split = llSubStringIndex(s_desc, "-");
            if (i_split != -1)
            {
                s_desc = llGetSubString(s_desc, 0, i_split - 1);
            }
            i_face = (integer)llGetSubString(s_desc, -1, -1);
            //if ALL_SIDES, just care about 0 face
            if (i_face == 9)
            {
                i_face = 0;
            }
            i_prim = (integer)llGetSubString(s_desc, 2, -2);
            i_bitPos = (i_prim - 1) * 8 + i_face;
            i_alpha = (llList2Integer(l_intAlphaConf, llFloor(i_bitPos / 32)) >> (31 - (i_bitPos % 32))) & 0x0000001;
            v_color = llList2Vector(llGetLinkPrimitiveParams(a, [PRIM_COLOR, ALL_SIDES]),0);
            if (i_alpha)
            {
                llSetLinkPrimitiveParamsFast(a, [PRIM_COLOR,ALL_SIDES, v_color, 0]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(a, [PRIM_COLOR,ALL_SIDES, v_color, 1]);
            }
        }
        else if (s_command == "ZQ")
        {
            i_prim = (integer)llGetSubString(s_desc, 2, -1);
            i_face = 8;
            while (i_face--)
            {
                i_bitPos = (i_prim - 1) * 8 + i_face;
                i_alpha = (llList2Integer(l_intAlphaConf, llFloor(i_bitPos / 32)) >> (31 - (i_bitPos % 32))) & 0x0000001;
                v_color = llList2Vector(llGetLinkPrimitiveParams(a, [PRIM_COLOR, i_face]),0);
                if (i_alpha)
                {
                    llSetLinkPrimitiveParamsFast(a, [PRIM_COLOR, i_face, v_color, 0]);
                }
                else
                {
                    llSetLinkPrimitiveParamsFast(a, [PRIM_COLOR, i_face, v_color, 1]);
                }
            }
        }
    }
    //same again for mappings
    integer i_hudPrim;
    integer i_hudFace;
    a = llGetListLength(gl_mapping) / 2;
    while (a--)
    {
        s_desc = llList2String(gl_mapping, a * 2 + 1);
        if (llSubStringIndex(s_desc, "ZP") == 0)
        {
            i_hudPrim = llList2Integer(gl_mapping, a * 2);
            i_hudFace = (integer)i_hudPrim % (integer)10;
            i_hudPrim = (integer)i_hudPrim / (integer)10;
            i_split = llSubStringIndex(s_desc, "-");
            if (i_split != -1)
            {
                s_desc = llGetSubString(s_desc, 0, i_split - 1);
            }
            i_face = (integer)llGetSubString(s_desc, -1, -1);
            if (i_face == 9)
            {
                i_face = 0;
            }
            i_prim = (integer)llGetSubString(s_desc, 2, -2);
            i_bitPos = (i_prim - 1) * 8 + i_face;
            i_alpha = (llList2Integer(l_intAlphaConf, llFloor(i_bitPos / 32)) >> (31 - (i_bitPos % 32))) & 0x0000001;
            v_color = llList2Vector(llGetLinkPrimitiveParams(i_hudPrim, [PRIM_COLOR, i_hudFace]),0);
            if (i_alpha)
            {
                llSetLinkPrimitiveParamsFast(i_hudPrim, [PRIM_COLOR, i_hudFace, v_color, 0]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(i_hudPrim, [PRIM_COLOR, i_hudFace, v_color, 1]);
            }
        }
    }
}

toggleSingleAlpha(integer num, integer face)
{
    list value = llGetLinkPrimitiveParams(num, [PRIM_COLOR, face]);
    float alpha = llList2Float(value,1);
    vector colore = llList2Vector(value,0);
    if(alpha == 1.0)
    {   
        llSetLinkPrimitiveParamsFast(num, [  PRIM_COLOR, face, colore, 0]);
    }
    else 
    {   
        llSetLinkPrimitiveParamsFast(num, [  PRIM_COLOR, face, colore, 1]);
    }

}

executeCommand(string scelto, integer link, integer face)
{
    string comando = llGetSubString(scelto, 0, 0);
    if(comando == "Z")
    {
        toggleSingleAlpha(link, face);
        scelto = llGetSubString(scelto, 1, -1);
        comando = llGetSubString(scelto, 0, 0);
    }

    if(comando == "G")
    {
        list l_btns = llParseStringKeepNulls(llGetSubString(scelto, 1, -1), [";"], []);
        float i_columns = llGetListLength(l_btns);
        l_btns = llParseStringKeepNulls(llGetSubString(scelto, 1, -1), [";", "|"], []);
        float i_rows = llGetListLength(l_btns) / i_columns;
        scelto = llList2String(l_btns, multiButtonNumber(llDetectedTouchST(0), <i_columns, i_rows, 0>));
        comando = llGetSubString(scelto, 0, 0);
        l_btns = [];
    }

    if(comando == "P")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + scelto);
    }
    else if(comando == "Q")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":P" + llGetSubString(scelto, 1, -1) + (string)face);
    }
    else if(comando == "R")
    {
        resetHUD();
    }
    else if(comando == "-")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + scelto);
    } 
    else if (comando == "T")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + llGetSubString(scelto, 1, -1));
    }
    else if(comando == ">")
    {
        ++gi_counterSelectedNumber;
        if(gi_counterSelectedNumber > 16)
        {
            gi_counterSelectedNumber = 1;
        }
        updateCounterNumber();
    }
    else if(comando == "<")
    {
        --gi_counterSelectedNumber;
        if(gi_counterSelectedNumber < 1)
        {
            gi_counterSelectedNumber = 16;
        }
        updateCounterNumber();
    }
    else if(comando == "S")
    {
        integer pos = llListFindList(gl_savedSets, (list)gi_counterSelectedNumber);
        if (pos != -1)
        {
            gl_savedSets = llDeleteSubList(gl_savedSets, pos, pos + 1);
        }
        gb_saveNext = TRUE;
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":updatealpha");
    }
    else if(comando == "L")
    {
        integer pos = llListFindList(gl_savedSets, (list)gi_counterSelectedNumber);
        if (pos == -1)
        {
            llOwnerSay("No Alphas saved yet on slot: " + (string)gi_counterSelectedNumber);
        }
        else
        {
            llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":-4" + llList2String(gl_savedSets, pos + 1));
        }
    }
    else if(comando == "U")
    {
        gs_skinPart = llGetSubString(scelto, 1, -1);
        llTextBox(llGetOwner(), "Enter UUID of skin texture for " + gs_skinPart, -81);
        gi_uuidHandle = llListen(-81, "", llGetOwner(), "");
        llSetTimerEvent(120);
    }
    else if(comando == "A")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":getalpha");
    }
}


default
{
    state_entry()
    {
        llListen(gi_HUDChannel,"","","");
        resetHUD();
        gs_ident = llList2String(llGetPrimitiveParams([PRIM_DESC]), 0);
    }

    on_rez(integer num)
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":updatealpha");
    }

    touch_start(integer num_detected)
    {
        integer link = llDetectedLinkNumber(0);
        integer face = llDetectedTouchFace(0);
        if (face == TOUCH_INVALID_FACE)
        {
            llOwnerSay("Sorry, your viewer doesn't support touched faces.");
            return;
        }
        string desc = llList2String(llGetLinkPrimitiveParams(link, [ PRIM_DESC ]), 0);
        //if no description, try to find command in gl_mapping
        if (desc == "")
        {
            integer i_found = llListFindList(gl_mapping, [(string)link + (string)face]) + 1;
            if (i_found)
            {
                desc = llList2String(gl_mapping, i_found);
            }
        }

        executeCommand(desc, link, face);
    }

    timer()
    {
        llListenRemove(gi_uuidHandle);
        llSetTimerEvent(0.0);
    }
 
    listen(integer channe,string name,key id,string message)
    {
        key ownerOfThisObject = llGetOwner();
        key ownerOfSpeaker = llGetOwnerKey(id);
        if (ownerOfSpeaker != ownerOfThisObject)
        {
            return;
        }

        if (channe == gi_HUDChannel)
        {
            if(llSubStringIndex(message, gs_ident + ":") != 0)
            {
                return;
            }
            else
            {
                message = llGetSubString(message, llStringLength(gs_ident) + 1, -1);
            }

            string setup = llGetSubString(message, 0, 0);
            if (setup == "+")
            {
                string s_currentAlpha = llGetSubString(message, 1, -1);
                if(gb_saveNext)
                {
                    gl_savedSets += [gi_counterSelectedNumber, s_currentAlpha];
                    gb_saveNext = FALSE;
                    updateCounterNumber();
                }
                else
                {
                    readBase64AlphaString(s_currentAlpha);
                }
            }
        }
        else if (channe == -81)
        {
            llListenRemove(gi_uuidHandle);
            llSetTimerEvent(0.0);
            if (gs_skinPart != "")
            {
                llOwnerSay("Changing skin for " + gs_skinPart);
                llRegionSayTo(llGetOwner(), -60, gs_skinPart + ":" + message);
                if (gs_skinPart == "head")
                {
                    llSay(300301, message);
                }
                else if (gs_skinPart == "eyes")
                {
                    llSay(100701, message);
                }
                gs_skinPart = "";
            }
        }
    }
}

