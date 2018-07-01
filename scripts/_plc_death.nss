//::///////////////////////////////////////////////
//:: _plc_death
//:://////////////////////////////////////////////
/*
    Use: OnDeath event of a placeable (or door)

Local String
    - REMAINS  resref of item to leave behind on death
    - REMAINS_PLACE if true, remains are a placeable instead of an item
    - REMAINS_SCRIPT identifier of a script to run on the remains when created (runs on each when created)
    - DEATH_SCRIPT identifier of an additional script to run on death (runs on killer)

Remains Data
    - REMAINS_APPEAR int - if TRUE appear animation plays
    - REMAINS_NUMBER int - number of items of REMAINS to be created
    - REMAINS_TAG string - tag of item for REMAINS when created
    - REMAINS_QUALITY string - quality property of item for REMAINS (unapplied if blank) see SetItemQuality [aa_inc_craft]

*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2012 mar 5)
//:: Modified: The Magus (2012 apr 9)  -- added DEATH_SCRIPT and REMAINS_SCRIPT
//:: Modified: The Magus (2012 may 5)  -- added REMAINS_QUALITY and a silent shout when destroyed
//:: Modified: Henesua (2014 mar 23) loot creation
//:://////////////////////////////////////////////

#include "x2_inc_itemprop"

#include "_inc_constants"
#include "_inc_craft"
#include "_inc_loot"

void main()
{
    object oKiller      = GetLastKiller();
    string sRefRemains  = GetLocalString(OBJECT_SELF,"REMAINS");
    string sDeathScript = GetLocalString(OBJECT_SELF,"DEATH_SCRIPT");

    // Alert "owner" faction - requires that "owner" hears this and is set up to respond
    SpeakString(SHOUT_PLACEABLE_DESTROYED+ObjectToString(OBJECT_SELF), TALKVOLUME_SILENT_SHOUT);
    SetLocalString(oKiller,SHOUT_PLACEABLE_DESTROYED,ObjectToString(OBJECT_SELF));

    object oRemains;
    if(sRefRemains!="")
    {
        location lLoc;
        object oArea    = GetArea(OBJECT_SELF);
        vector vPos     = GetPosition(OBJECT_SELF);
        vector vPos1; float x, y;
        float fFace     = GetFacing(OBJECT_SELF);

        int bPlace      = GetLocalInt(OBJECT_SELF,"REMAINS_PLACE");
        int bAppear     = GetLocalInt(OBJECT_SELF, "REMAINS_APPEAR");
        string sTag     = GetLocalString(OBJECT_SELF, "REMAINS_TAG");
        int nRemains    = GetLocalInt(OBJECT_SELF, "REMAINS_NUMBER");
        if(!nRemains){ nRemains = 1; }
        string sRemScrip= GetLocalString(OBJECT_SELF, "REMAINS_SCRIPT");
        string sRemQual = GetLocalString(OBJECT_SELF, "REMAINS_QUALITY");
        while(nRemains)
        {
            fFace  += 15;
            x       = (IntToFloat(Random(25))-12.0)/10.0;
            y       = (IntToFloat(Random(25))-12.0)/10.0;
            vPos1   = Vector(vPos.x+x, vPos.y+y, vPos.z);
            lLoc    = Location(oArea, vPos1, fFace);
            if(bPlace)
            {
                // PLACEABLE REMAINS
                oRemains= CreateObject(OBJECT_TYPE_PLACEABLE, sRefRemains, lLoc, bAppear, sTag );
            }
            else
            {
                // ITEM REMAINS
                oRemains= CreateObject(OBJECT_TYPE_ITEM, sRefRemains, lLoc, bAppear, sTag );
                if(sRemQual!="")
                    SetItemQuality(sRemQual, oRemains);
            }

            if(sRemScrip!="")
                ExecuteScript(sRemScrip, oRemains);
            nRemains--;
        }

    }

    // spawns treasure
    if(GetLocalInt(OBJECT_SELF, "LOOT"))
        LootGenerate(oKiller);

    if(sDeathScript!="")
        ExecuteScript(sDeathScript, oKiller);

    // this local string is used on some doors
    string sPair    = GetLocalString(OBJECT_SELF, "PAIRED");
    object oPair;
    if(sPair!="")
    {
        oPair       = GetObjectByTag(sPair);
        if(oPair==OBJECT_SELF)
            oPair   = GetObjectByTag(sPair, 1);
        if(GetIsObjectValid(oPair) && oPair!=OBJECT_SELF)
            if(GetIsObjectValid(oKiller))
                AssignCommand(oKiller, DestroyObject(oPair, 0.1));
            else
                DestroyObject(oPair, 0.1);
    }

    // this local object is created via script
    oPair           = GetLocalObject(OBJECT_SELF, "PAIRED");
    if(GetIsObjectValid(oPair))
        if(GetIsObjectValid(oKiller))
            AssignCommand(oKiller, DestroyObject(oPair, 0.1));
        else
            DestroyObject(oPair, 0.1);
}
