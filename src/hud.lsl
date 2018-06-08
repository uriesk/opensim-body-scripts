//### alpha-hud.lsl
//indentification string of the mesh body
string gs_ident = "apollo";
//for set-counter and saving sets:
integer gi_counterSelectedNumber = 1;
integer gi_counterLinkNumber;
integer gb_saveNext = FALSE;
list gl_savedSets;
//for choosing UUIDs of Skins:
string gs_skinPart = "";
integer gi_uuidHandle;

setCounterNumber(integer i_prim, integer i_face, integer number)
{
    if (number > 16 || number < 1) return;
    --number;
    float x_offset = -0.375 + ((number % 4) * 0.25);
    float y_offset = 0.375 - (llFloor(number / 4) * 0.25);

    llSetLinkPrimitiveParamsFast(i_prim, [PRIM_TEXTURE, i_face, "numbers", <0.25, 0.25, 0.0>, <x_offset, y_offset, 0.0>, 0.0]);
}

resetHUD()
{
    llRegionSayTo(llGetOwner(), -50, gs_ident + ":Reset");
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

funzionericordacolore(integer num)
{
    list value=  llGetLinkPrimitiveParams(num, [PRIM_COLOR, ALL_SIDES]);
    float alpha= llList2Float(value,1);
    vector colore= llList2Vector(value,0);
    if(alpha == 1.0)
    {   
        llSetLinkPrimitiveParamsFast(num, [  PRIM_COLOR,ALL_SIDES, colore, 0]);
    }
    else 
    {   
        llSetLinkPrimitiveParamsFast(num, [  PRIM_COLOR,ALL_SIDES, colore, 1]);
    }

}


default
{
    state_entry()
    {
        llListen(-51,"","","");
        resetHUD();
    }

    on_rez(integer num)
    {
        llRegionSayTo(llGetOwner(), -50, gs_ident + ":updatealpha");
    }

    touch_start(integer num_detected)
    {
        integer link = llDetectedLinkNumber(0);
        integer face=llDetectedTouchFace(0);

        string scelto= llList2String(llGetLinkPrimitiveParams(link, [ PRIM_DESC ]), 0);
        string comando=llGetSubString(scelto,0,0);

        if(comando == "R")
        {
            resetHUD();
        }
        else if(comando == "P")
        {
            funzionericordacolore(link);
            llRegionSayTo(llGetOwner(), -50, gs_ident + ":" + scelto);
            // llSay(0,scelto);
        }     
        else if(comando == "-")
        {
            llRegionSayTo(llGetOwner(), -50, gs_ident + ":" + scelto);
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
        else if(comando == ">")
        {
            ++gi_counterSelectedNumber;
            if(gi_counterSelectedNumber > 16)
            {
                gi_counterSelectedNumber = 1;
            }
            setCounterNumber(gi_counterLinkNumber, ALL_SIDES, gi_counterSelectedNumber);
        }
        else if(comando == "<")
        {
            --gi_counterSelectedNumber;
            if(gi_counterSelectedNumber < 1)
            {
                gi_counterSelectedNumber = 16;
            }
            setCounterNumber(gi_counterLinkNumber, ALL_SIDES, gi_counterSelectedNumber);
        }
        else if(comando == "S")
        {
            integer pos = llListFindList(gl_savedSets, (list)gi_counterSelectedNumber);
            if (pos != -1)
            {
                gl_savedSets = llDeleteSubList(gl_savedSets, pos, pos + 1);
            }
            gb_saveNext = TRUE;
            llRegionSayTo(llGetOwner(), -50, gs_ident + ":updatealpha");
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
                llRegionSayTo(llGetOwner(), -50, gs_ident + ":-3" + llList2String(gl_savedSets, pos + 1));
            }
        }
        else if(comando == "U")
        {
            gs_skinPart = llGetSubString(scelto, 1, -1);
            llTextBox(llGetOwner(), "Enter UUID of skin texture for " + gs_skinPart, -81);
            gi_uuidHandle = llListen(-81, "", llGetOwner(), "");
            llSetTimerEvent(120);
        }
        else if(comando == "G")
        {
            llRegionSayTo(llGetOwner(), -50, gs_ident + ":getalpha");
        }

        if (face == TOUCH_INVALID_FACE)
        {
            llOwnerSay("Sorry, your viewer doesn't support touched faces.");
        }
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

        if (channe == -51)
        {
            if(llSubStringIndex(message, gs_ident) != 0)
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
                }
                else
                {
                    readBase64AlphaString(s_currentAlpha);
                }
            }
        }
        if (channe == -81)
        {
            llListenRemove(gi_uuidHandle);
            llSetTimerEvent(0.0);
            if (gs_skinPart != "")
            {
                llOwnerSay("skin for " + gs_skinPart);
                if (gs_skinPart == "Head")
                {
                    llSay(300301, message);
                }
                else if (gs_skinPart == "Upper Body")
                {
                    llSay(171800, message);
                }
                else if (gs_skinPart == "Lower Body")
                {
                    llSay(171801, message);
                }
                else if (gs_skinPart == "Neck")
                {
                    llSay(171802, message);
                }
                else if (gs_skinPart == "Eyes")
                {
                    llSay(100701, message);
                }
                gs_skinPart = "";
            }
        }
    }
}

