
default
{
    touch_start(integer num_detected)
    {
        vector pos = llDetectedTouchST(0);
        integer num = (integer)(pos.x * 11.0) + 1;
        llRegionSayTo(llGetOwner(), -60, "alan-handnails:" + (string)llGetInventoryKey("handnail" + (string)num));
        llRegionSayTo(llGetOwner(), -60, "alan-feetnails:" + (string)llGetInventoryKey("feetnail" + (string)num));
    }
}
