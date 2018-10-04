//### alphastring.lsl
// script-version: 0.6
//This script provides simple operations for a base64 alphas string
//You can use this to create the base64 strings needed for the texture setting lists
//or the alphaFilterMask (prims that should be ignored) in the body script.
//
// Examples:
//Genearte a gs_alphaFilterMask.
//You want to ignore the whole prim with the link number 1 and the face 2 of the link 5 prim:
// l_prims = ["19", "52"];
// l_alpha = [];
// l_prims_ignore = "";
// s_alpha_mask = "";
// i_invert = TRUE;
//You want to make a base64 string for setting textures of the upper body:
// 1. Select all alphas that should have that texture in the HUD
// 2. Click the {} button in the HUD and copy the alpha string
// l_prims = [];
// l_alpha = ["copied alpha string"];
// l_prims_ignore = [];
// s_alpha_mask = gs_alphaFilterMask from body script
// i_invert = FALSE;
//You want to make a basse64 string for setting textures of just two fingernails prims 16 and 17
// l_prims = ["169", "179"];
// l_alpha = [];
// l_prims_ignore = "";
// s_alpha_mask = "";
// i_invert = FALSE;
//

// 1. Set your values here:
// If you don't need something, leave it empty
list l_prims = []; 
list l_alpha = [];
list l_prims_ignore = [];
string s_alpha_mask = "";
integer i_invert = TRUE;
// 2. Save the script and put it inside the body, it will print the 
//    resulting base64 string and delete itself again.


//-----------------------------------------------------------------------
string hexToString(integer bits)
{
    //this function is just for testing purpose,
    //but is still included in the final release, because
    //of it's low footprint
    string XDIGITS = "0123456789abcdef";
    string nybbles;
    integer cnt = 0;
    while (cnt < 8)
    {
        integer lsn = bits & 0xF;
        string nybble = llGetSubString(XDIGITS, lsn, lsn);
        nybbles = nybble + nybbles;
        bits = bits >> 4;
        bits = bits & 0xfffFFFF;
        cnt++;
    }
    nybbles = "0x" + nybbles;
    return nybbles;
}

string list2Base64(list l_primList)
{
    //create a list of 0s with the needed length
    integer i_intCount = llCeil((float)llGetNumberOfPrims() / (float)4);
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



default
{
    state_entry()
    {
        string base64 = list2Base64(l_prims);
        if (l_alpha != [])
        {
            integer i_cnt = llGetListLength(l_alpha);
            while (i_cnt--)
            {
                string base64_alpha = llList2String(l_alpha, i_cnt);
                if (base64_alpha != "")
                {
                    base64 = base64Or(base64, base64_alpha);
                }
            }
        }
        if (l_prims_ignore != [])
        {
            base64 = base64And(base64Invert(list2Base64(l_prims_ignore)), base64);
        }
        if (s_alpha_mask != "")
        {
            base64 = base64And(s_alpha_mask, base64);
        }
        if (i_invert)
        {
            base64 = base64Invert(base64);
        }
        llSay(0, "Resulting Base64 String:\n" + base64);
        llRemoveInventory(llGetScriptName());
    }
}
