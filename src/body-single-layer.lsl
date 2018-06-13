//### body-single-layer.lsl
// script-version: 0.3
//indentification string of the mesh body
string gs_ident = "athena";
//if Ankle Lock is on or off
integer gb_ankleLock = TRUE;
//linked faces that get ignored
//last digit: face number - previous digits: link number
//if last digit is 9, it is considered as ALL_SIDES of prim
//(faces from gl_feet, gl_neck and gl_nailsShape are already ignored, no need to set them here again)
list gl_ignorePrims = ["19", "340", "350", "360"];
//setup upper body texture
//base64 config string with 1 being relevant face
integer gi_channelUpper = 171800;
string gs_UpperParts = "AP///w///AwA/////AAAAAAAAAAAAAAAAAAAAAAAAAAAD4fAfID//w";
//setup for lower body texture
//base64 config string with 1 being relevant faces
//(the feet, without nails, will be automatically included, they don't
// have to be part of the string)
integer gi_channelLower = 171801;
string gs_LowerParts = "AAAAAAAAAAAAAAAAAA/P///w/////w/////w/////w///4eAeP//AA";
//setup for neck-fix texture
//the parts, that it applies the texture to, are defined in gl_neck
integer gi_channelNeck = 171802;
//setup for nails texture
//last digit: face number - previous digits: link number
//if last digit is 9, it is considered as ALL_SIDES of prim
integer gi_feetNailsChannel  = 191801;
list gl_feetNails = ["341", "351", "360"];
integer gi_handNailsChannel  = 181801;
list gl_handNails = ["320", "321", "322", "323", "324", "330", "331", "332", "333", "334"];
//setup for changing parts
//last digit: face number - previous digits: link number
//if last digit is 9, it is considered as ALL_SIDES of prim
//every entry in the list can itself be a comma-seperated list
//entry can also be ""
list gl_feet = ["", "349", "359", "369"];
list gl_neck = ["", "314", "313", "312", "311", "310"];
list gl_nailsShape = ["324,334", "321,331", "320,330", "323,333", "322,332", ""];
//main communication Channel
integer gi_BodyChannel = -50;
integer gi_HUDChannel = -51;
// === Do not edit something below here, if you are not a scripter ===
string gs_filterPrims;


list splitList(list l_multiPrimList)
{
    list l_result = [];
    integer i_length = llGetListLength(l_multiPrimList);
    integer a = 0;
    while (a < i_length)
    {
        l_result += llParseString2List(llList2String(l_multiPrimList, a), [","], []);
        ++a;
    }
    return l_result;
}

string list2Base64(list l_primList)
{
    //create a list of 0s with the needed length
    integer i_intCount = llCeil(llGetNumberOfPrims() / 4);
    integer a = 0;
    list l_intList = [];
    while (a < i_intCount)
    {
        l_intList += (list)0;
        ++a;
    }
    //write bits
    integer i_primListLength = llGetListLength(l_primList);
    string s_tmpString;
    integer i_prim;
    integer i_face;
    integer i_posInt;
    integer i_pos;
    integer i_tmp;
    list l_allFaces;
    integer b;
    a = 0;
    while (a < i_primListLength)
    {
        s_tmpString = llList2String(l_primList, a);
        if (s_tmpString != "")
        {
            i_prim = (integer)llGetSubString(s_tmpString, 0, -2);
            i_face = (integer)llGetSubString(s_tmpString, -1, -1);
            //if ALL_SIDES of prim
            if (i_face == 9)
            {
                l_allFaces = [];
                b = 0;
                while (b < 8)
                {
                    l_allFaces += (list)((string)i_prim + (string)b);
                    b++;
                }
                l_primList = llListReplaceList(l_primList, l_allFaces, a, a);
                i_primListLength += 7;
                i_face = 0;
            }
            i_posInt = llFloor(( --i_prim * 8 + i_face ) / 32);
            i_pos = (i_prim * 8 + i_face) % 32;
            i_tmp = llList2Integer(l_intList, i_posInt);
            i_tmp = i_tmp | (0x00000001 << (31 - i_pos));
            l_intList = llListReplaceList(l_intList, (list)i_tmp, i_posInt, i_posInt);
        }
        ++a;
    }
    //create base64 string
    string s_result = "";
    a = 0;
    while (a < i_intCount)
    {
        s_result += llGetSubString(llIntegerToBase64(llList2Integer(l_intList, a)), 0, 5);
        ++a;
    }
    return s_result;
}

string base64And(string base641, string base642)
{
    integer i_intCount = llStringLength(base641) / 6;
    string s_result = "";
    integer a = 0;
    integer i_tmp1;
    integer i_tmp2;
    while (a < i_intCount)
    {
        i_tmp1 = llBase64ToInteger(llGetSubString(base641, a * 6, a * 6 + 5));
        i_tmp2 = llBase64ToInteger(llGetSubString(base642, a * 6, a * 6 + 5));
        s_result += llGetSubString(llIntegerToBase64(i_tmp1 & i_tmp2), 0, 5);
        a++;
    }
    return s_result;
}

string base64Or(string base641, string base642)
{
    integer i_intCount = llStringLength(base641) / 6;
    string s_result = "";
    integer a = 0;
    integer i_tmp1;
    integer i_tmp2;
    while (a < i_intCount)
    {
        i_tmp1 = llBase64ToInteger(llGetSubString(base641, a * 6, a * 6 + 5));
        i_tmp2 = llBase64ToInteger(llGetSubString(base642, a * 6, a * 6 + 5));
        s_result += llGetSubString(llIntegerToBase64(i_tmp1 | i_tmp2), 0, 5);
        a++;
    }
    return s_result;
}

string base64Invert(string base64)
{
    integer i_intCount = llStringLength(base64) / 6;
    string s_result = "";
    integer a = 0;
    integer i_tmp;
    while (a < i_intCount)
    {
        i_tmp = llBase64ToInteger(llGetSubString(base64, a * 6, a * 6 + 5));
        s_result += llGetSubString(llIntegerToBase64(i_tmp ^ 0xFFFFFFFF), 0, 5);
        a++;
    }
    return s_result;
}

toggleAlpha(integer num,integer face)
{
    if (face == 9)
    {
        face = ALL_SIDES;
    }
    list value =  llGetLinkPrimitiveParams(num, [PRIM_COLOR,face]);
    float alpha = llList2Float(value,1);
    vector colore = llList2Vector(value,0);
    if(alpha == 0.0)
    {   
        llSetLinkPrimitiveParamsFast(num, [PRIM_COLOR, face, colore, 1]);
    }
    else
    {   
        llSetLinkPrimitiveParamsFast(num, [PRIM_COLOR, face, colore, 0]);
    }
}

string getBase64AlphaString()
{
    string s_base64alpha = "";
    integer i_prims = llGetNumberOfPrims();
    integer a = 0;
    integer i_bitCount = 32;
    integer i_tempAlphaConf = 0; 
    integer b;
    integer i_mask;
    while (a < i_prims)
    {
        a++;
        b = 0;
        while (b < 8)
        {
            --i_bitCount;
            if (llList2Float(llGetLinkPrimitiveParams(a, [PRIM_COLOR, b]), 1) != 1.0)
            {
                i_mask = 0x00000001;
                i_mask = i_mask << i_bitCount;
                i_tempAlphaConf = i_tempAlphaConf | i_mask;
            }
            if (i_bitCount == 0)
            {
                s_base64alpha += llGetSubString(llIntegerToBase64(i_tempAlphaConf), 0, 5);
                i_bitCount = 32;
                i_tempAlphaConf = 0;
                i_mask = 0;
            }
            ++b;
        }
    }
    if (i_mask != 0)
    {
        s_base64alpha += llGetSubString(llIntegerToBase64(i_tempAlphaConf), 0, 5);
    }
    llOwnerSay("DEBUG send base64alpha update to HUD");
    llRegionSayTo(llGetOwner(), gi_HUDChannel, gs_ident + ":+" + s_base64alpha);
    return s_base64alpha;
}

readBase64AlphaString(string s_base64alpha, integer mode)
{
    //mode:
    // 1: Set bits are going to be set to transparency
    // 2: Set bits are going to be set to full oppacy
    // 3: Set bits will be toggled
    // 4: Set bits are going to be set to full oppacy
    //    Unset bits are going to be set to transparency
    integer i_partLength = llStringLength(s_base64alpha) / 6;
    integer a = 0;
    integer i_tempAlphaConf;
    integer i_bitCount;
    integer i_totalBitCount = 0;
    integer i_prim;
    integer i_face;
    integer i_alpha;
    llOwnerSay("DEBUG setting Alphas!");
    if (mode == 4)
    {
        readBase64AlphaString(s_base64alpha, 1);
        s_base64alpha = base64Invert(s_base64alpha);
        readBase64AlphaString(s_base64alpha, 2);
        return;
    }
    s_base64alpha = base64And(gs_filterPrims, s_base64alpha);
    while (a < i_partLength)
    {
        i_tempAlphaConf = llBase64ToInteger(llGetSubString(s_base64alpha, a * 6, a * 6 + 5));
        i_bitCount = 32;
        while (i_bitCount > 0)
        {
            --i_bitCount;
            i_prim = llFloor(i_totalBitCount / 8) + 1;
            i_face = i_totalBitCount % 8;
            i_alpha = (i_tempAlphaConf >> i_bitCount) & 0x00000001;
            if (mode == 1)
            {
                if (i_alpha)
                {
                    llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 0.0]);
                }
            }
            else if (mode == 2)
            {
                if (i_alpha)
                {
                    llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 1.0]);
                }
            }
            else if (mode == 3)
            {
                if (i_alpha)
                {
                    if(llList2Float(llGetLinkPrimitiveParams(i_prim, [PRIM_COLOR, i_face]), 1) == 1.0)
                    {
                        llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 0.0]);
                    }
                    else
                    {
                        llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 1.0]);
                    }
                }
            }
            ++i_totalBitCount;
        }
        a++;
    }
    llOwnerSay("DEBUG Alphas set!");
}

setTextureBase64(string s_base64alpha, string s_texture)
{
    integer i_partLength = llStringLength(s_base64alpha) / 6;
    integer a = 0;
    integer i_tempPartConf;
    integer i_bitCount;
    integer i_totalBitCount = 0;
    integer i_prim;
    integer i_face;
    integer i_set;
    while (a < i_partLength)
    {
        i_tempPartConf = llBase64ToInteger(llGetSubString(s_base64alpha, a * 6, a * 6 + 5));
        i_bitCount = 32;
        while (i_bitCount > 0)
        {
            --i_bitCount;
            i_prim = llFloor(i_totalBitCount / 8) + 1;
            i_face = i_totalBitCount % 8;
            i_set = (i_tempPartConf >> i_bitCount) & 0x00000001;
            if (i_set)
            {
                llSetLinkPrimitiveParamsFast(i_prim, [PRIM_TEXTURE, i_face, s_texture, <1,1,0>, <0,0,0>, 0]);
            }
            ++i_totalBitCount;
        }
        a++;
    }
}

setTextureList(list l_faceList, string s_texture)
{
    integer i_length = llGetListLength(l_faceList);
    integer a = 0;
    integer i_prim;
    integer i_face;
    integer i_faces;
    while (a < i_length)
    {
        i_faces = llList2Integer(l_faceList, a);
        i_face = i_faces % 10;
        if (i_face == 9)
        {
            i_face = ALL_SIDES;
        }
        i_prim = llFloor(i_faces / 10);
        if (i_prim != 0)
        {
            llSetLinkPrimitiveParamsFast(i_prim, [PRIM_TEXTURE, i_face, s_texture, <1,1,0>, <0,0,0>, 0]);
        }
        ++a;
    }
}

selectPart(list l_partList, integer num)
{
    if (l_partList == [])
    {
        return;
    }
    integer i_length = llGetListLength(l_partList);
    integer a = 0;
    list l_numParts;
    integer b;
    integer i_subLength;
    integer i_prim;
    integer i_face;
    integer i_faces;
    while (a < i_length)
    {
        l_numParts = llParseString2List(llList2String(l_partList, a), [","], []);
        i_subLength = llGetListLength(l_numParts);
        b = 0;
        while (b < i_subLength)
        {
            i_faces = llList2Integer(l_numParts, b);
            i_face = i_faces % 10;
            if (i_face == 9)
            {
                i_face = ALL_SIDES;
            }
            i_prim = llFloor(i_faces / 10);
            if (a == num)
            {
                llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 1.0]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 0.0]);
            }
            ++b;
        }
        a++;
    }
}

string hexToString(integer bits)
{
    string XDIGITS = "0123456789abcdef";
    string nybbles;
    integer cnt = 0;
    while (cnt < 8)
    {
        integer lsn = bits & 0xF; // least significant nybble
        string nybble = llGetSubString(XDIGITS, lsn, lsn);
        nybbles = nybble + nybbles;
        bits = bits >> 4; // discard the least significant bits at right
        bits = bits & 0xfffFFFF; // discard the sign bits at left
        cnt++;
    }
    nybbles = "0x" + nybbles;
    return nybbles;
}

default
{
    touch_start(integer num_detected)
    {
        integer link = llDetectedLinkNumber(0);
        integer face=llDetectedTouchFace(0);
        llOwnerSay("Touched on " + (string)link + " / " + (string)face);
    }

    state_entry()
    {
        llListen(gi_BodyChannel,"","","");
        llListen(gi_channelUpper, "", "", "");
        llListen(gi_channelLower, "", "", "");
        llListen(gi_channelNeck, "", "", "");
        if (gl_feetNails != [])
        {
            llListen(gi_feetNailsChannel, "", "", "");
        }
        if (gl_handNails != [])
        {
            llListen(gi_handNailsChannel, "", "", "");
        }
        gs_filterPrims = base64Invert(list2Base64(splitList(gl_feet + gl_neck + gl_nailsShape) + gl_ignorePrims + gl_feetNails + gl_handNails));
    } 

    listen(integer channe, string name, key id, string message)
    {
        key ownerOfThisObject = llGetOwner();
        key ownerOfSpeaker = llGetOwnerKey(id);
        if (ownerOfSpeaker != ownerOfThisObject)
        {
            return;
        }
        
        //Texture Channels
        if (channe == gi_channelUpper)
        {
            if (gs_UpperParts == "") return;
            setTextureBase64(base64And(gs_UpperParts, gs_filterPrims), message);
            return;
        }
        if (channe == gi_channelLower)
        {
            if (gs_LowerParts == "") return;
            //set feet but not nails,
            string s_base64feet = base64And(base64And(list2Base64(gl_feet), base64Invert(list2Base64(gl_feetNails))), base64Invert(list2Base64(gl_ignorePrims)));
            setTextureBase64(base64Or(base64And(gs_LowerParts, gs_filterPrims), s_base64feet), message);
            return;
        }
        if (channe == gi_channelNeck)
        {
            if (gl_neck == []) return;
            setTextureList(gl_neck, message);
            return;
        }
        if (channe == gi_handNailsChannel)
        {
            if (gl_handNails == []) return;
            setTextureList(gl_handNails, message);
            return;
        }
        if (channe == gi_feetNailsChannel)
        {
            if (gl_feetNails == []) return;
            setTextureList(gl_feetNails, message);
            return;
        }

        //Everything underneath is channel gi_BodyChannel
        //and requires gs_ident
        if (channe != gi_BodyChannel || llSubStringIndex(message, gs_ident + ":") != 0)
        {
            return;
        }
        else
        {
            message = llGetSubString(message, llStringLength(gs_ident) + 1, -1);
        }

        string command = llGetSubString(message,0,0);

        if (command == "-")
        {
            integer i_mode = (integer)llGetSubString(message, 1, 1);
            string s_base64Alpha = llGetSubString(message, 2, -1);
            readBase64AlphaString(s_base64Alpha, i_mode);
            getBase64AlphaString();
            return;
        }
        if (command == "P")
        {
            integer i_linkNumber = (integer)llGetSubString(message, 1, -2);
            integer i_faceNumber = (integer)llGetSubString(message, -1, -1);
            toggleAlpha(i_linkNumber,i_faceNumber);
            return;
        }

        if (llSubStringIndex(message, "getalpha") == 0)
        {
            string s_config = getBase64AlphaString();
            llRegionSayTo(ownerOfThisObject, 0, "Current Alpha String:\n" + s_config);
            return;
        }
        if (llSubStringIndex(message, "updatealpha") == 0)
        {
            getBase64AlphaString();
            return;
        }

        if (message == "Reset")
        {
            llOwnerSay("DEBUG Reset received.");
            gs_filterPrims = base64Invert(list2Base64(splitList(gl_feet + gl_neck + gl_nailsShape) + gl_ignorePrims + gl_feetNails + gl_handNails));
            readBase64AlphaString(gs_filterPrims, 2);
            getBase64AlphaString();
            llOwnerSay("DEBUG Finished Reset");
            return;
        } 

        if (llSubStringIndex(message, "nails") == 0)
        {
            selectPart(gl_nailsShape, (integer)llGetSubString(message, 5, 5));
            return;
        }
        if (llSubStringIndex(message, "neck") == 0)
        {
            llOwnerSay("DEBUG Neck " + message + " selected");
            selectPart(gl_neck, (integer)llGetSubString(message, 4, 4));
            return;
        }
        if (llSubStringIndex(message, "feet") == 0)
        {
            selectPart(gl_feet, (integer)llGetSubString(message, 4, 4));
            return;
        }
    }

    //ankle fix
    attach(key attached) 
    {
        if (attached != NULL_KEY && gb_ankleLock) 
        {
            llRequestPermissions(attached, PERMISSION_TRIGGER_ANIMATION);
        } 
        else 
        {
            llSetTimerEvent(0);
        }
    }
    run_time_permissions(integer perms) 
    {
        if(perms & PERMISSION_TRIGGER_ANIMATION) 
        {
            llStartAnimation("AnkleLock");
            llSetTimerEvent(1);
        }
    }
    timer() 
    {
        llStopAnimation("AnkleLock");
        llStartAnimation("AnkleLock");
    }
}

