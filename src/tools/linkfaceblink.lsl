//### linkfaceblink.lsl
//Script to make all face numbers of all links blink,
//helpful for putting things together in order
integer gi_blinkCount;
integer gi_totalLinkCount;
integer gi_currentLink;
float gf_oldIntensity;

blink()
{
    if (gi_blinkCount <= 0)
    {
        gi_blinkCount = gi_totalLinkCount;
    }
    if (gi_blinkCount > gi_totalLinkCount)
    {
        gi_blinkCount = 0;
    }

    integer prim = (integer)gi_currentLink / (integer)8;
    integer face = (integer)gi_currentLink % (integer)8;
    if (gi_currentLink != 0)
    {
        llSetLinkPrimitiveParamsFast(prim, [PRIM_GLOW, face, gf_oldIntensity]);
    }
    gi_currentLink = gi_blinkCount;
    prim = (integer)gi_currentLink / (integer)8;
    face = (integer)gi_currentLink % (integer)8;
    gf_oldIntensity = llList2Float(llGetLinkPrimitiveParams(prim, [PRIM_GLOW, face]), 0);
    llSetLinkPrimitiveParamsFast(prim, [PRIM_GLOW, face, 0.4]);
    llSay(0, "Link/Face number: " + (string)prim + "/" + (string)face);
}

default
{
    state_entry()
    {
        llListen(111, "", "", "");
        gi_totalLinkCount = llGetNumberOfPrims() * 8;
    }

    touch_start(integer num)
    {
        llDialog(llDetectedKey(0), "Link Blinker", ["< Previous", "Next >", "Stop", "Timer"], 111);
    }

    listen(integer channel, string name, key user, string message)
    {
        if (message == "Timer")
        {
            llSetTimerEvent(1);
        }
        if (message == "Next >")
        {
            --gi_blinkCount;
            blink();
        }
        if (message == "< Previous")
        {
            ++gi_blinkCount;
            blink();
        }
        if (message == "Stop")
        {
            llSetTimerEvent(0);
            if (gi_currentLink != 0)
            {
                integer prim = (integer)gi_currentLink / (integer)8;
                integer face = (integer)gi_currentLink % (integer)8;
                llSetLinkPrimitiveParamsFast(prim, [PRIM_GLOW, face, gf_oldIntensity]);
            }
            gi_currentLink = 0;
            gi_blinkCount = 0;
        }
        llDialog(user, "Link Blinker", ["< Previous", "Next >", "Stop", "Timer"], 111);
    }

    timer()
    {
        ++gi_blinkCount;
        blink();
    }
}
