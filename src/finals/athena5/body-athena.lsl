//### body-single-layer.lsl
// script-version: 0.4
//indentification string of the mesh body
string gs_ident = "athena";
//if Ankle Lock is on or off
integer gb_ankleLock = TRUE;
//linked faces that get ignored
//last digit: face number - previous digits: link number
//if last digit is 9, it is considered as ALL_SIDES of prim
//(faces from gl_feet, gl_neck and gl_nailsShape are already ignored, no need to set them here again)
list gl_ignorePrims = ["19", "342", "352", "360"];
//setup upper body texture
//base64 config string with 1 being relevant face
string gs_UpperParts = "AP///w///AwA/////AAAAAAAAAAAAAAAAAAAAAAAAAAAAABABAAAAA";
//setup for lower body texture
//base64 config string with 1 being relevant faces
//(the feet, without nails, will be automatically included, they don't
// have to be part of the string)
string gs_LowerParts = "AAAAAAAAAAAAAAAAAA/P///w/////w/////w/////w///4eAeP//AA";
//setup for nails texture
//last digit: face number - previous digits: link number
//if last digit is 9, it is considered as ALL_SIDES of prim
//(leave gl_neckParts empty and it will be auto generated from gl_neck)
//(leave gl_handNails empty and it will be auto generated from gl_nailsShape)
string gs_feetIdent = "athena-feetnails";
list gl_feetNails = ["340", "350", "361"];
string gs_handIdent = "athena-handnails";
list gl_handNails = [];
list gl_neckParts = [];
//setup for changing parts
//last digit: face number - previous digits: link number
//if last digit is 9, it is considered as ALL_SIDES of prim
//every entry in the list can itself be a comma-seperated list
//entry can also be ""
list gl_feet = ["", "349", "359", "369"];
list gl_neck = ["", "314", "313", "312", "311", "310"];
list gl_nailsShape = ["321,331", "322,332", "320,330", "324,334", "323,333", ""];
//main communication Channel
integer gi_BodyChannel = -50;
integer gi_HUDChannel = -51;
integer gi_SkinChannel = -60;
integer gi_SkinHUDChannel = -61;
//size of trusted Item list
integer gi_trustedItemsSize = 15;
// === Do not edit something below here, if you are not a scripter ===
string gs_alphaFilterMask;
string gs_textureFilterMask;
list gl_trustedItems;
integer gi_trustedItemPointer;

// === Message to fellow Developers ===
// The Alpha Configuration strings are just base64 encoded integers.
// Every bit represents a face and it is assumed that every linked prim has
// 8 faces, so it consists of at least llNUmberOfPrims * 8 bits.
// This method is incredibly fast and it is easy to combine them with logical
// OR and AND operations. If something can be done using this method, it should
// be done with that method.
// Other Basic Tips for maintaining a good performance:
// - Do not use llSay(), use llRegionSayTo() instead
//   Everything that is talking to the body is an attachment, no need for llSay
// - Try to avoid fancy list operations in loops
// - In LSL, if you compare something like if(statemet1 && statement2), then
//   statement2 will be checked even if it is not neccessary (like when statement 1
//   is already FALSE), thats good to know, if statement2 could potentionally
//   cause lag.
// - Do nut listen to more channels than neccessary
// - Feel free to contribute and improve :), every help is appreciated
// Channel usage:
// There are just 2 channels this script listens to, and there are just 2
// channels this script answers too.
// Channel -50 - Listen: Channel for body commands like setting alphas and choosing feet,
// nail shape, neck size and similar things.
// Channel -51 - Send: Channel for sending informations about those things (like the
// current alpha configuraton)
// Channel -60 - Listen: Channel for skin configuration
// Channel -61 - Send: Channel for sending skin informations
// For the messages that get send, check the code, it says more than every word.
// Messages on Channel -50 and -51 alwas start with an identification string gs_ident
// followed by ":" and the command.
// Messages on Channel -60 and -61 always start with the skin part, like "upper",
// followed by ":" and the texture uuid.

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

integer base64FirstOne(string base64)
{
    integer i_intCount = llStringLength(base64) / 6;
    integer i_bitCount;
    integer a = 0;
    integer i_tmp;
    while (a < i_intCount)
    {
        i_tmp = llBase64ToInteger(llGetSubString(base64, a * 6, a * 6 + 5));
        if (i_tmp != 0)
        {
            i_bitCount = 0;
            while (~i_tmp & 0x80000000)
            {
                ++i_bitCount;
                i_tmp = (i_tmp << 1);
            }
            return a * 32 + i_bitCount;
        }
        a++;
    }
    return -1;
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
    s_base64alpha = base64And(s_base64alpha, gs_alphaFilterMask);
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
    s_base64alpha = base64And(gs_alphaFilterMask, s_base64alpha);
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


default
{
    state_entry()
    {
        llListen(gi_BodyChannel,"","","");
        llListen(gi_SkinChannel,"","","");
        //populate trusted tems list
        gl_trustedItems = [];
        integer a = 0;
        while (a < gi_trustedItemsSize)
        {
            gl_trustedItems += [NULL_KEY];
            ++a;
        }
        gi_trustedItemPointer = 0;
        //check neck lists
        if (gl_neckParts == [] && gl_neck != [])
        {
            gl_neckParts = splitList(gl_neck);
        }
        //check nails lists
        if (gl_handNails == [] && gl_nailsShape != [])
        {
            gl_handNails = splitList(gl_nailsShape);
        }
        //gs_alphaFilterMask = base64Invert(list2Base64(splitList(gl_feet + gl_neck + gl_nailsShape) + gl_ignorePrims + gl_feetNails + gl_handNails));
        gs_alphaFilterMask = base64Invert(list2Base64(gl_ignorePrims + splitList(gl_feet) + gl_neckParts + gl_handNails));
        gs_textureFilterMask = base64Invert(list2Base64(gl_handNails + gl_feetNails + gl_ignorePrims + gl_neckParts));
    } 

    listen(integer channe, string name, key id, string message)
    {
        key ownerOfThisObject = llGetOwner();
        key ownerOfSpeaker = llGetOwnerKey(id);
        if (ownerOfSpeaker != ownerOfThisObject)
        {
            //if an autohide event triggers on detach of an object, llGetOwnerKey(id) will return id
            //to still catch those events, we use a list of trusted items
            if (id != ownerOfSpeaker)
            {
                return;
            }
            else if (llListFindList(gl_trustedItems, [id]) == -1)
            {
                return;
            }
            llOwnerSay("DEBUG Item is allowed becaues it is in trusted list");
        }
        
        //Texture Channel
        if (channe == gi_SkinChannel)
        {
            list l_msgList = llParseString2List(message, [":"], []);
            string s_cmd = llList2String(l_msgList, 0);
            string s_uuid = llList2String(l_msgList, 1);
            l_msgList = [];

            if (s_cmd == "gettexture")
            {
                integer i_firstBit;
                integer i_link;
                integer i_face;
                string s_texture;
                if (gs_UpperParts != "")
                {
                    i_firstBit = base64FirstOne(base64And(gs_UpperParts, gs_textureFilterMask));
                    i_link = llFloor(i_firstBit / 8) + 1;
                    i_face = i_firstBit % 8; 
                    s_texture = llList2String(llGetLinkPrimitiveParams(i_link, [PRIM_TEXTURE, i_face]), 0);
                    llRegionSayTo(ownerOfThisObject, gi_SkinHUDChannel, "upper:" + s_texture);
                }
                if (gs_LowerParts != "")
                {
                    i_firstBit = base64FirstOne(base64And(gs_LowerParts, gs_textureFilterMask));
                    i_link = llFloor(i_firstBit / 8) + 1;
                    i_face = i_firstBit % 8; 
                    s_texture = llList2String(llGetLinkPrimitiveParams(i_link, [PRIM_TEXTURE, i_face]), 0);
                    llRegionSayTo(ownerOfThisObject, gi_SkinHUDChannel, "lower:" + s_texture);
                }
                if (gl_neckParts != [])
                {
                    i_firstBit = llList2Integer(gl_neckParts, 0);
                    i_link = llFloor(i_firstBit / 10);
                    i_face = i_firstBit % 10;
                    s_texture = llList2String(llGetLinkPrimitiveParams(i_link, [PRIM_TEXTURE, i_face]), 0);
                    llRegionSayTo(ownerOfThisObject, gi_SkinHUDChannel, "neck:" + s_texture);
                }
                if (gl_handNails != [])
                {
                    i_firstBit = llList2Integer(gl_handNails, 0);
                    i_link = llFloor(i_firstBit / 10);
                    i_face = i_firstBit % 10;
                    s_texture = llList2String(llGetLinkPrimitiveParams(i_link, [PRIM_TEXTURE, i_face]), 0);
                    llRegionSayTo(ownerOfThisObject, gi_SkinHUDChannel, gs_feetIdent + ":" + s_texture);
                }
                if (gl_feetNails != [])
                {
                    i_firstBit = llList2Integer(gl_feetNails, 0);
                    i_link = llFloor(i_firstBit / 10);
                    i_face = i_firstBit % 10;
                    s_texture = llList2String(llGetLinkPrimitiveParams(i_link, [PRIM_TEXTURE, i_face]), 0);
                    llRegionSayTo(ownerOfThisObject, gi_SkinHUDChannel, gs_handIdent + ":" + s_texture);
                }
            }
            if (s_cmd == "upper")
            {
                if (gs_UpperParts == "") return;
                setTextureBase64(base64And(gs_UpperParts, gs_textureFilterMask), s_uuid);
            }
            else if (s_cmd == "lower")
            {
                if (gs_LowerParts == "") return;
                //set feet but not nails,
                string s_base64Lower = base64Or(list2Base64(splitList(gl_feet)), gs_LowerParts);
                setTextureBase64(base64And(s_base64Lower, gs_textureFilterMask), s_uuid);
            }
            else if (s_cmd == "neck")
            {
                if (gl_neckParts == []) return;
                setTextureList(gl_neckParts, s_uuid);
            }
            else if (s_cmd == gs_handIdent)
            {
                if (gl_handNails == []) return;
                setTextureList(gl_handNails, s_uuid);
            }
            else if (s_cmd == gs_feetIdent)
            {
                if (gl_feetNails == []) return;
                setTextureList(gl_feetNails, s_uuid);
            }
            return;
        }

        //Body Channel
        if (channe != gi_BodyChannel || llSubStringIndex(message, gs_ident + ":") != 0)
        {
            return;
        }
        else
        {
            message = llGetSubString(message, llStringLength(gs_ident) + 1, -1);
        }
        //add item to trusted list
        //(so that item can send commands on detach events too,
        //when it is not possible to check it's owner)
        if (llListFindList(gl_trustedItems, [id]) == -1)
        {
            llOwnerSay("DEBUG Add item " + (string)id + " to trusted list");
            gl_trustedItems = llListReplaceList(gl_trustedItems, [id], gi_trustedItemPointer, gi_trustedItemPointer);
            llOwnerSay("DEBUG Trusted items: " + llDumpList2String(gl_trustedItems, ","));
            ++gi_trustedItemPointer;
            if (gi_trustedItemPointer == gi_trustedItemsSize)
            {
                gi_trustedItemPointer = 0;
            }
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

        if (message == "getalpha")
        {
            string s_config = getBase64AlphaString();
            llRegionSayTo(ownerOfThisObject, 0, "Current Alpha String:\n" + s_config);
            return;
        }
        if (message == "updatealpha")
        {
            getBase64AlphaString();
            return;
        }

        if (message == "Reset")
        {
            llOwnerSay("DEBUG Reset received.");
            gs_alphaFilterMask = base64Invert(list2Base64(splitList(gl_feet + gl_neck + gl_nailsShape) + gl_ignorePrims + gl_feetNails + gl_handNails));
            readBase64AlphaString(gs_alphaFilterMask, 2);
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

