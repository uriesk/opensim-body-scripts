//### touchinfo.lsl
//Script to output informations of touch event

default
{
    touch_start(integer num)
    {
        vector v_st = llDetectedTouchST(0);
        llSay(0, "Touched Link: " + (string)llDetectedLinkNumber(0) + "\nToched Face: " + (string)llDetectedTouchFace(0) + "\nTouched ST: " + (string)v_st.x + "," + (string)v_st.y);
    }
}

