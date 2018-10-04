//sets a random color to every linked prim
//uncomment stuff to make random color for every face
default
{
    state_entry()
    {
        llSay(0, "Giving every linked prim a random color...");
        integer num = llGetNumberOfPrims();
        integer face;
        vector color;
        while (num)
        {
            //face = 8;
            face = ALL_SIDES;
            //while (face--)
            //{
                color.x = llFrand(1.0);
                color.y = llFrand(1.0);
                color.z = llFrand(1.0);
                llSetLinkPrimitiveParamsFast(num, [PRIM_COLOR, face, color, 1.0] );
            //}
            --num;
        }
    }
}
