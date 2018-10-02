//### hud.lsl
// script-version: 0.4
//
//setup of feet changing buttons
//(it is one prim with multiple buttons on it)
// set gi_linkFeet to 0 to deactivate
// gv_feetButtonDirection tells button aligment (<1,0,0> = horicontal)
integer gi_feetButtonAmount = 4;
vector gv_feetButtonDirection = <1, 0, 0>;
//setup of hand nails changing buttons (same as feet)
integer gi_handButtonAmount = 6;
vector gv_handButtonDirection = <1, 0, 0>;
//setup of neck changing buttons (same as feet)
integer gi_neckButtonAmount = 6;
vector gv_neckButtonDirection = <1, 0, 0>;
//group selection multiButton
//(it is also one prim with multiple buttons)
list gl_groupButtons = ["-1AAAAAA/gDAwA////AADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "-1AAAAAAAPwAAAAAAA/AAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "-1AAD//wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD42A2AD//w", "-1AAAAAAAAAAAAAAAAAA/P8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "-1/wAAAAAAAAAAAAAAAAAAD//w/////w//8BAQAQEBAQAQEAAAAAAAAA", "-1/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+/g/v7+/g/v4AAAAAAAAA"];
vector gv_groupButtonDirection = <0, 1, 0>;
//color of the slots counter
vector gv_counterSaveColor = <0.8, 0.0, 0.0>;
vector gv_counterUnsavedColor = <0.0,0.0,0.0>;
//communication channels to body
integer gi_BodyChannel = -50;
integer gi_HUDChannel = -51;
// === Do not edit something below here, if you are not a scripter ===
//for set-counter and saving sets:
integer gi_counterSelectedNumber = 1;
integer gi_counterLinkNumber;
integer gb_saveNext = FALSE;
list gl_savedSets;
//for choosing UUIDs of Skins:
string gs_skinPart = "";
integer gi_uuidHandle;
//identification string
string gs_ident;


string multiButton(vector v_touchPosition, string s_commandPrefix, vector v_direction, integer i_buttonAmount)
{
    integer button = llFloor(v_touchPosition * v_direction * i_buttonAmount);
    string ret = s_commandPrefix + (string)button;
    return ret;
}

string groupButtons(vector v_touchPosition)
{
    string new_desc;
    integer button = llFloor((1 - v_touchPosition * gv_groupButtonDirection) * llGetListLength(gl_groupButtons));
    string ret = llList2String(gl_groupButtons, button);
    if (llGetSubString(ret, 1, 1) == "1")
    {
        new_desc = "-2" + llGetSubString(ret, 2, -1);
    }
    else
    {
        new_desc = "-1" + llGetSubString(ret, 2, -1);
    }
    gl_groupButtons = llListReplaceList(gl_groupButtons, (list)new_desc, button, button);
    return ret;
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

    llSetLinkPrimitiveParamsFast(gi_counterLinkNumber, [PRIM_TEXTURE, ALL_SIDES, "numbers", <0.25, 0.25, 0.0>, <x_offset, y_offset, 0.0>, 0.0, PRIM_COLOR, ALL_SIDES, v_color, 1]);
}

resetHUD()
{
    gi_counterSelectedNumber = 1;
    updateCounterNumber();
    llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":Reset");
    integer prim1s = llGetNumberOfPrims();
    integer a;
    for( a = 1; a <= prim1s; ++a)
    {
        string scelto = llList2String(llGetLinkPrimitiveParams(a, [ PRIM_DESC ]), 0);
        list value =  llGetLinkPrimitiveParams(a, [PRIM_COLOR, ALL_SIDES]);
        vector colore = llList2Vector(value,0);
        if (llGetSubString(scelto,0,0) == "P")
        {
            llSetLinkPrimitiveParamsFast(a, [PRIM_COLOR,ALL_SIDES, colore, 1]);   
        }
        if(scelto == "C")
        {
            gi_counterLinkNumber = a;
        }
    }
    integer groupButtonsAmount = llGetListLength(gl_groupButtons);
    string command;
    list tmp_list = [];
    a = 0;
    while (a < groupButtonsAmount)
    {
        command = llList2String(gl_groupButtons, a);
        tmp_list += (list)("-1" + llGetSubString(command, 2, -1));
        a++;
    }
    gl_groupButtons = tmp_list;
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
    vector v_color;
    integer i_primCount = llGetNumberOfPrims();
    for( a = 0; a <= i_primCount; ++a)
    {
        string s_desc = llList2String(llGetLinkPrimitiveParams(a, [ PRIM_DESC ]), 0);
        if (llGetSubString(s_desc, 0, 0) == "P")
        {
            i_face = (integer)llGetSubString(s_desc, -1, -1);
            if (i_face == 9)
            {
                i_face = 0;
            }
            i_prim = (integer)llGetSubString(s_desc, 1, -2);
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
    }
}

toggleSingleAlpha(integer num, integer face)
{
    list value = llGetLinkPrimitiveParams(num, [PRIM_COLOR, ALL_SIDES]);
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

    if(comando == "G")
    {
        comando = llGetSubString(scelto, 1, 1);
        if (comando == "F")
        {
            scelto = multiButton(llDetectedTouchST(0), "F", gv_feetButtonDirection, gi_feetButtonAmount);
        }
        else if (comando == "H")
        {
            scelto = multiButton(llDetectedTouchST(0), "H", gv_handButtonDirection, gi_handButtonAmount);
        }
        else if (comando == "N")
        {
            scelto = multiButton(llDetectedTouchST(0), "N", gv_neckButtonDirection, gi_neckButtonAmount);
        }
        else if (comando == "-")
        {
            scelto = groupButtons(llDetectedTouchST(0));
            link = 0;
        }
    }

    if(comando == "P")
    {
        if (link != 0)
        {
            toggleSingleAlpha(link, ALL_SIDES);
        }
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + scelto);
    }
    if(comando == "Q")
    {
        if (link != 0)
        {
            toggleSingleAlpha(link, face);
        }
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":P" + llGetSubString(scelto, 1, -1) + (string)face);
    }
    else if(comando == "R")
    {
        resetHUD();
    }
    else if(comando == "-")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + scelto);
        if (link != 0)
        {
            integer i_mode = (integer)llGetSubString(scelto, 1, 1);
            if (i_mode == 1)
            {
                llSetLinkPrimitiveParamsFast(link, [PRIM_DESC, "-2" + llGetSubString(scelto, 2, -1)]);
            }
            else if (i_mode == 2)
            {
                llSetLinkPrimitiveParamsFast(link, [PRIM_DESC, "-1" + llGetSubString(scelto, 2, -1)]);
            }
        }
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
    else if (comando == "F")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + "feet" + llGetSubString(scelto, 1, 1));
    }
    else if (comando == "H")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + "nails" + llGetSubString(scelto, 1, 1));
    }
    else if (comando == "N")
    {
        llRegionSayTo(llGetOwner(), gi_BodyChannel, gs_ident + ":" + "neck" + llGetSubString(scelto, 1, 1));
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

        executeCommand(desc, link, face);
    }

    timer()
    {
        llListenRemove(gi_uuidHandle);
        llSetTimerEvent(0.0);
        llOwnerSay("Menu timed out.");
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
                if (gs_skinPart == "Head")
                {
                    llSay(300301, message);
                    llSay(-60, "head:" + message);
                }
                else if (gs_skinPart == "Upper Body")
                {
                    llSay(-60, "upper:" + message);
                }
                else if (gs_skinPart == "Lower Body")
                {
                    llSay(-60, "lower:" + message);
                }
                else if (gs_skinPart == "Neck")
                {
                    llSay(-60, "neck:" + message);
                }
                else if (gs_skinPart == "Eyes")
                {
                    llSay(100701, message);
                    llSay(-60, "eyes:" + message);
                }
                gs_skinPart = "";
            }
        }
    }
}

