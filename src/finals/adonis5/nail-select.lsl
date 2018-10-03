default
{
    touch_start(integer num_detected)
    {
        vector pos = llDetectedTouchST(0);
        integer num = (integer)(pos.x * 11.0) + 1;
        string name = "nail" + (string)num;
        llRegionSayTo(llGetOwner(), -60, "adonis-handnails:" + (string)llGetInventoryKey(name));
        llRegionSayTo(llGetOwner(), -60, "adonis-feetnails:" + (string)llGetInventoryKey(name));
    }
}
