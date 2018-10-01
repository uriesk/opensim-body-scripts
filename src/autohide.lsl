//### autohide.lsl
//Setting alphas and feet shapes on attach and
//detach of clothing
key k_owner;

// ==SetUp:
//1. Uncomment the llRegionSayTo lines for the mesh-bodies you need.
//2. Comment out the once you don't need or delete them.
//3. Change the Alpha Configuration String to what you need
//(you can get the ALpha Configuration String from the "{}" button in
// the alpha HUD)
//Remember that the message has to look like:
//attach:
// [mesh-body-identification]:-1[alpha-configuration-string]
//detach:
// [mesh-body-identification]:-2[alpha-configuration-string]
//i.e.: "athena:-2AAAHAwPDzAwA//8BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" 
//
// ==Feet Shape:
//If you want to change the feet shape, the message has to look like:
// [mesh-body-identification]:feet[number]
//with number meaning:
//0 = hide feet
//1 = flat feet
//2 = first level
//3 = second level

default
{
    attach(key id)
    {
        if (id == NULL_KEY)
        {
            //on detach
            llRegionSayTo(k_owner, -50, "apollo:-2AAAAAAAPCgAAoPAAAAAAAAAAAAAAAAAPDwAAAP///w9f//AAAAAAAAAAAAAAAOAAAAAAAAAAAAAAAA");
            llRegionSayTo(k_owner, -50, "adonis:-2asdfasdfas");
            llRegionSayTo(k_owner, -50, "ares:-2asdfsdafsadfas");
            llRegionSayTo(k_owner, -50, "freya:-2asdfasdfasfasdf");
            llRegionSayTo(k_owner, -50, "athena:-2AAAHAwPDzAwA//8BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
            llRegionSayTo(k_owner, -50, "athena:feet1");
        }
        else
        {
            //on attach
            k_owner = id;
            llRegionSayTo(k_owner, -50, "apollo:-1AAAAAAAPCgAAoPAAAAAAAAAAAAAAAAAPDwAAAP///w9f//AAAAAAAAAAAAAAAOAAAAAAAAAAAAAAAA");
            llRegionSayTo(k_owner, -50, "adonis:-1sadfasdfasd");
            llRegionSayTo(k_owner, -50, "ares:-1asdfasdfasd");
            llRegionSayTo(k_owner, -50, "freya:-1asdfasdfasdf");
            llRegionSayTo(k_owner, -50, "athena:-1AAAHAwPDzAwA//8BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
            llRegionSayTo(k_owner, -50, "athena:feet3");
        }
        return;
    }
}

//Why does this look like that?
//- The attach event can potentially be cut-off on detach, it has
//just a very limited time to execute. It is important to get the 
//messages to the body as fast as possible. Thats why the alphas
//strings are not in nice global variables or lists.
