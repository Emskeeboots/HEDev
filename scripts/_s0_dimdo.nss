//::///////////////////////////////////////////////
//:: _s0_dimdo
//:://////////////////////////////////////////////
/*
    Spell Script for Dimensional Portal

    Creates two placeables which enables transport between them.

*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2011 oct 16)
//:: Modified:  The Magus (2013 jan 24) using spellfocus system
//:://////////////////////////////////////////////
//:: Modified:  henesua (2016 jan 18) added transdimensional portal. made use of community patch.

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_color"
#include "_inc_constants"
#include "_inc_spells"

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();

    object oArea    = GetArea(OBJECT_SELF);
    string sRefDimdoor  = "aa_plc_dimportal"; // resref of placeable for dimension door

    // Disable in areas with area "AREA_NO_TELEPORT" set
    if ( GetLocalInt(oArea, "AREA_NO_TELEPORT") )
    {
        SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILED. You cannot teleport in this area.");
        return;
    }

    // SPECIAL TARGETTING - accepts "Spell Focus"- see _s2_marktarget and spellfocus_inc
    if(GetLocalInt(OBJECT_SELF, SPELLFOCUS_USE))
    {
        object oFocus   = GetLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);

        //garbage collection
        DeleteLocalInt(OBJECT_SELF, SPELLFOCUS_USE);
        DeleteLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);

        // Focus Data
        int nFocusType  = GetLocalInt(oFocus, SPELLFOCUS_TYPE);
        if(nFocusType==1)
            spell.Loc       = GetSpellFocusLocation(oFocus);
        else if(nFocusType==2)
            spell.Loc       = GetLocation(GetLocalObject(oFocus, SPELLFOCUS_CREATURE));
        else if(nFocusType==3)
            spell.Loc       = GetLocation(GetPCByPCID(GetLocalString(oFocus, SPELLFOCUS_CREATURE)));

        object oAreaAlt = GetAreaFromLocation(spell.Loc);

        // warding
        if(GetLocalInt(oAreaAlt, "AREA_NOTELEPORT") || !GetIsObjectValid(oAreaAlt))
        {
            SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILED. You cannot teleport to the targeted area.");
            return;
        }
        else if(    spell.Id==SPELL_TRANSDIMENSIONAL_PORTAL
                ||  (spell.Id==SPELL_DIMENSIONAL_PORTAL && GetArea(OBJECT_SELF)==oAreaAlt)
               )
        {
            SendMessageToPC(OBJECT_SELF, DMBLUE+"Success: Portal created in "+GetName(oAreaAlt)+".");
            if(SPELLFOCUS_ONE_USE)
                DestroyObject(oFocus, 0.5);
        }
        else
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: Portal must be created in the same area.");
            return;
        }
    }
    // END SPECIAL TARGETTING --------------------------------------------------

    // * duration -----
    int nDuration   = spell.Level;
    if(spell.Meta== METAMAGIC_EXTEND)
        nDuration *= 2;
    float fDuration = RoundsToSeconds(nDuration);

    // unique identifier for caster
    string sCaster  = ObjectToString(OBJECT_SELF);
    // vector math for position and facing of door
    float fCaster   = GetFacing(OBJECT_SELF);
    float fDoor     = fCaster + 180.0;
    if(fDoor>360.0){fDoor = fCaster - 180.0;}
    location lDoor  = Location( GetArea(OBJECT_SELF),
                                GetChangedPosition(GetPosition(OBJECT_SELF), 1.0, fCaster),
                                fDoor
                              );

    effect eDimensionDoor = EffectVisualEffect( VFX_FNF_SUMMON_UNDEAD, FALSE );

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eDimensionDoor, lDoor);
    object oDoorNear    = CreateObject(OBJECT_TYPE_PLACEABLE, sRefDimdoor, lDoor, FALSE, "plc_door_"+sCaster+"_1");
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eDimensionDoor, spell.Loc);
    object oDoorFar     = CreateObject(OBJECT_TYPE_PLACEABLE, sRefDimdoor, spell.Loc, FALSE, "plc_door_"+sCaster+"_2");
    AssignCommand(oDoorFar, SetFacing(fCaster));
    SetLocalObject(oDoorNear, "DESTINATION", oDoorFar);
    SetLocalObject(oDoorNear, "CREATOR", OBJECT_SELF);
    SetLocalInt(oDoorNear, "LEVEL", spell.Level);
    SetLocalObject(oDoorFar, "DESTINATION", oDoorNear);
    SetLocalObject(oDoorFar, "CREATOR", OBJECT_SELF);
    SetLocalInt(oDoorFar, "LEVEL", spell.Level);

    // duration
    DelayCommand(fDuration, ExecuteScript("_s1_dimdo_dest", oDoorNear) );
    // Maintained by concentration
    CasterSetConcentration(oDoorNear,"_s1_dimdo_dest");
}
