//### faceblink.lsl
//Script to make link numbers blink,
//helpful for putting things together in order
integer link = 34;

integer gi_blinkCount;
integer gi_currentFace = 8;
float gf_oldIntensity;

blink()
{
    if (gi_blinkCount < 0)
    {
        gi_blinkCount = 7;
    }
    if (gi_blinkCount > 7)
    {
        gi_blinkCount = 0;
    }

    if (gi_currentFace != 8)
    {
        llSetLinkPrimitiveParamsFast(link, [PRIM_GLOW, gi_currentFace, gf_oldIntensity]);
    }
    gi_currentFace = gi_blinkCount;
    gf_oldIntensity = llList2Float(llGetLinkPrimitiveParams(link, [PRIM_GLOW, gi_currentFace]), 0);
    llSetLinkPrimitiveParamsFast(link, [PRIM_GLOW, gi_currentFace, 0.4]);
    llSay(0, "Face glowing: " + (string)gi_currentFace);
}

default
{
    state_entry()
    {
        llListen(111, "", "", "");
        llListen(112, "", "", "");
    }

    touch_start(integer num)
    {
        llDialog(llDetectedKey(0), "Link Blinker", ["< Previous", "Next >", "Stop", "Timer", "Linknumber"], 111);
    }

    listen(integer channel, string name, key user, string message)
    {
        if (channel == 112)
        {
            link = (integer)message;
        }
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
            if (gi_currentFace != 0)
            {
                llSetLinkPrimitiveParamsFast(link, [PRIM_GLOW, gi_currentFace, gf_oldIntensity]);
            }
            gi_currentFace = 8;
            gi_blinkCount = 0;
        }
        if (message == "Linknumber")
        {
            llTextBox(user, "Enter Link Number", 112);
        }
        else
        {
            llDialog(user, "Link Blinker", ["< Previous", "Next >", "Stop", "Timer", "Linknumber"], 111);
        }
    }

    timer()
    {
        --gi_blinkCount;
        blink();
    }
}

