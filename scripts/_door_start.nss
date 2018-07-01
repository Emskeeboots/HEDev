//::///////////////////////////////////////////////
//:: _door_start
//:://////////////////////////////////////////////
/*
    only used by the door which exits the lobby
*/
//:://////////////////////////////////////////////
//:: Created By: henesua (2016 jan 5)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_constants"
#include "_inc_util"

void InitializeCharacterAppearance(object oPC) {
    // this should also be stored in the DB if using NWNX

    // store the PCs natural phenotype
    int nNaturalPhenoType = GetPhenoType(oPC);
    string phenoname      = "normal";
    if(nNaturalPhenoType==PHENOTYPE_NORMAL)
    {
        nNaturalPhenoType+=1000;
    }
    else if(nNaturalPhenoType==PHENOTYPE_BIG)
    {
        nNaturalPhenoType+=1000;
        phenoname         = "large";
    }
    else
    {
        nNaturalPhenoType =PHENOTYPE_NORMAL+1000;  // default to phenotype normal
    }
    SetSkinInt(oPC,"PHENOTYPE_NATURAL", nNaturalPhenoType);
    SetSkinString(oPC,"PHENOTYPE_NATURAL_NAME", phenoname);

    // store the PCs natural appearance
    int nNaturalAppearance = GetAppearanceType(oPC)+1000;
    SetSkinInt(oPC,"APPEARANCE_NATURAL", nNaturalAppearance);
    // good place to do every body part too
    int nPart;
    for (nPart=0; nPart<=20; nPart++)
    {
        SetSkinInt( oPC,
                    "PART_NATURAL"+IntToString(nPart),
                    GetCreatureBodyPart(nPart,oPC)
                  );
    }
    // wings
    SetSkinInt(oPC, "WING_NATURAL", GetCreatureWingType(oPC) );
    // tails
    SetSkinInt(oPC, "TAIL_NATURAL", GetCreatureTailType(oPC) );
}

void main()
{
    object oDest    = GetTransitionTarget(OBJECT_SELF);
    object oPC      = GetClickingObject();

    // remove all effects on pc
    RemoveEffectsByType(oPC);

    // final initialization should happen here
    InitializeCharacterAppearance(oPC);

    if(MODULE_DEVELOPMENT_MODE)
    {
        // Send PC to the latest development waypoint to get on with testing

        int nth = 0;
        object temp = GetObjectByTag(WP_DEVELOPMENT, nth++);
        while(GetIsObjectValid(temp))
        {
            oDest   = temp;
            temp = GetObjectByTag(WP_DEVELOPMENT, nth++);
        }
    }

    AssignCommand(oPC, ActionJumpToObject(oDest) );
}
