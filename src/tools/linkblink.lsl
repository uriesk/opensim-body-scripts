//### linkblink.lsl
//Script to make link numbers blink,
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

    if (gi_currentLink != 0)
    {
        llSetLinkPrimitiveParamsFast(gi_currentLink, [PRIM_GLOW, ALL_SIDES, gf_oldIntensity]);
    }
    gi_currentLink = gi_blinkCount;
    gf_oldIntensity = llList2Float(llGetLinkPrimitiveParams(gi_currentLink, [PRIM_GLOW, ALL_SIDES]), 0);
    llSetLinkPrimitiveParamsFast(gi_currentLink, [PRIM_GLOW, ALL_SIDES, 0.4]);
    llSay(0, "Link number: " + (string)gi_currentLink);
}

default
{
    state_entry()
    {
        llListen(111, "", "", "");
        gi_totalLinkCount = llGetNumberOfPrims();
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
                llSetLinkPrimitiveParamsFast(gi_currentLink, [PRIM_GLOW, ALL_SIDES, gf_oldIntensity]);
            }
            gi_currentLink = 0;
            gi_blinkCount = 0;
        }
        llDialog(user, "Link Blinker", ["< Previous", "Next >", "Stop", "Timer"], 111);
    }

    timer()
    {
        --gi_blinkCount;
        blink();
    }
}
