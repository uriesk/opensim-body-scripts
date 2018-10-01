
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


