//::///////////////////////////////////////////////
//:: Name x2_def_ondeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default OnDeath script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
#include "dq_ai_death"

void main()
{
    ExecuteScript("nw_c2_default7", OBJECT_SELF);
    string sTag=GetTag(OBJECT_SELF);
    if(sTag=="Brc_bossWRAITHranged"||sTag=="Brc_bossWRAITH"||sTag=="Brc_bossWRAITHmelee"){
        WraithDeath(10);
    }
}





