//### autohide.lsl
list gl_alphaConfig = [
    "apollo",   "",
    "adonis",   "",
    "ares",     "",
    "athena",   "",
    "freya",    ""
]



default
{
    attach(key id)
    {
        integer i_mode;
        if (id)
        {
            i_mode = 1;
        }
        else if (llGetAttached() == 0)
        {
            i_mode = 2;
        }
        else
        {
            return;
        }

        integer i_count = llGetListLength(gl_alphaConfig);
        integer a = 0;
        string s_ident;
        string s_alpha;
        while (a < i_count)
        {
            s_ident = llList2String(gl_alphaConfig, a);
            s_alpha = llList2String(gl_alphaConfig, ++a);
            if (s_alpha != "")
            {
                llRegionSayTo(llGetOwner(), -50, s_ident + ":-" + (string)i_mode + s_alpha);
            }
            ++a;
        }
    }
}
