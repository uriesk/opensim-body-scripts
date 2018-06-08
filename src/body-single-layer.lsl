//### body-alpha.lsl
//indentification string of the mesh body
string gs_ident = "apollo";
//link numbers that get ignored
list gl_ignorePrims = [1];
//setup upper body texture
integer gi_channelUpper = 171800;
string gs_UpperParts = "";
//setup for lower body texture
integer gi_channelLower = 171801;
string gs_LowerParts = "";

setAlphaAll(float alpha)
{
    integer a;
    integer prim1s = llGetNumberOfPrims();
    for( a = 1; a <= prim1s; ++a)
    {
        if (llListFindList(gl_ignorePrims, (list)a) == -1)
        {
            llSetLinkPrimitiveParamsFast(a, [PRIM_COLOR, ALL_SIDES, <1.000, 1.000, 1.000>, alpha]);
        }
    }
}

toggleAlpha(integer num,integer face)
{
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
                i_mask = 0x0000001;
                i_mask = i_mask << i_bitCount;
                i_tempAlphaConf = i_tempAlphaConf | i_mask;
            }
            if (i_bitCount == 0)
            {
                s_base64alpha += llGetSubString(llIntegerToBase64(i_tempAlphaConf), 0, 5);
                i_bitCount = 32;
                i_tempAlphaConf = 0;
            }
            ++b;
        }
    }
    llRegionSayTo(llGetOwner(), -51, gs_ident + ":+" + s_base64alpha);
    return s_base64alpha;
}

readBase64AlphaString(string s_base64alpha, integer mode)
{
    //mode:
    // 1: Set bits are going to be set to transparency
    // 2: Set bits are going to be set to full oppacy
    // 3: Set bits are going to be set to transparency,
    //    unset bist are going to be set to full oppacy
    // 4: Set bits will be toggled
    integer i_partLength = llStringLength(s_base64alpha) / 6;
    integer a = 0;
    integer i_tempAlphaConf;
    integer i_bitCount;
    integer i_totalBitCount = 0;
    integer i_prim;
    integer i_face;
    integer i_alpha;
    while (a < i_partLength)
    {
        i_tempAlphaConf = llBase64ToInteger(llGetSubString(s_base64alpha, a * 6, a * 6 + 5));
        i_bitCount = 32;
        while (i_bitCount > 0)
        {
            --i_bitCount;
            i_prim = llFloor(i_totalBitCount / 8) + 1;
            i_face = i_totalBitCount % 8;
            i_alpha = (i_tempAlphaConf >> i_bitCount) & 0x0000001;
            if (llListFindList(gl_ignorePrims, (list)i_prim) == -1)
            {
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
                        llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 0.0]);
                    }
                    else
                    {
                        llSetLinkPrimitiveParamsFast(i_prim, [PRIM_COLOR, i_face, <1.0, 1.0, 1.0>, 1.0]);
                    }
                }
                else if (mode == 4)
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
            }
            ++i_totalBitCount;
        }
        a++;
    }
}

setTexture(string s_base64alpha, string s_texture)
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
            i_set = (i_tempPartConf >> i_bitCount) & 0x0000001;
            if (llListFindList(gl_ignorePrims, (list)i_prim) == -1)
            {
                if (i_set)
                {
                    llSetLinkPrimitiveParamsFast(i_prim, [PRIM_TEXTURE, i_face, message, <1,1,0>, <0,0,0>, 0]);
                }
            }
            ++i_totalBitCount;
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
    state_entry()
    {
        llListen(-50,"","","");
        llListen(gi_channelUpper, "", "", "");
        llListen(gi_channelLower, "", "", "");
        //setAlphaAll(1.0);

    }  
    listen(integer channe, string name, key id, string message)
    {
        key ownerOfThisObject = llGetOwner();
        key ownerOfSpeaker = llGetOwnerKey(id);
        if (ownerOfSpeaker != ownerOfThisObject)
        {
            return;
        }
        
        if (channe == gi_channelUpper)
        {
            if (gs_UpperParts == "")
            {
                return;
                setTexture(gs_UpperParts, message);
            }
        }
        if (channe == gi_channelLower)
        {
            if (gs_LowerParts == "")
            {
                return;
                setTexture(gs_LowerParts, message);
            }
        }

        if (llSubStringIndex(message, gs_ident) != 0)
        {
            return;
        }
        else
        {
            message = llGetSubString(message, llStringLength(gs_ident) + 1, -1);
        }

        if (llSubStringIndex(message, "getalpha") == 0)
        {
            string s_config = getBase64AlphaString();
            llRegionSayTo(ownerOfThisObject, 0, "Current Alpha String:\n" + s_config);
        }

        if (llSubStringIndex(message, "updatealpha") == 0)
        {
            getBase64AlphaString();
        }

        string definizione=llGetSubString(message,0,0);

        if (definizione == "-")
        {
            integer i_mode = (integer)llGetSubString(message, 1, 1);
            string s_base64Alpha = llGetSubString(message, 2, -1);
            readBase64AlphaString(s_base64Alpha, i_mode);
            getBase64AlphaString();
        }

        if (message == "Reset")
        {
            setAlphaAll(1.0);
            getBase64AlphaString();
        } 


        if (definizione == "P")
        {
            integer i_linkNumber = (integer)llGetSubString(message, 1, -2);
            integer i_faceNumber = (integer)llGetSubString(message, -1, -1);
            toggleAlpha(i_linkNumber,i_faceNumber);
        }
    }
}

