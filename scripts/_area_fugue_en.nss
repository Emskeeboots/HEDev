//::///////////////////////////////////////////////
//:: _area_fugue_en
//:://////////////////////////////////////////////
/*
    Put into: OnEnter Event for Fugue Area



*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2016 jul 17)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_constants"
#include "_inc_util"
#include "_inc_xp"

void main()
{
    object oDead    = GetEnteringObject();

    if (!GetIsPC(oDead)) return;

    Data_SavePC(oDead);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectAppear(), oDead);

    effect eDead    = EffectCutsceneGhost();
           eDead    = EffectLinkEffects( eDead, EffectVisualEffect(VFX_DUR_GHOST_TRANSPARENT));
//           eDead    = EffectLinkEffects( eDead, EffectVisualEffect(VFX_DUR_GLOW_WHITE));
//           eDead    = EffectLinkEffects( eDead, EffectVisualEffect(VFX_DUR_GHOSTLY_PULSE));
//           eDead    = EffectLinkEffects( eDead, EffectVisualEffect(VFX_DUR_AURA_PULSE_GREY_WHITE));
           eDead    = ExtraordinaryEffect(eDead);
           eDead    = SupernaturalEffect(eDead);

    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDead, oDead));

    //CreatureSetIncorporeal(TRUE, oDead);

    string sAreaID      = GetIDFromArea();
    string sAreaEntryTag= TAG_ENTRY + "AREA_"+sAreaID;
    int iAreaEntryCount;
    // TRACK PC VISITS TO AREA
    iAreaEntryCount = GetPersistentInt(oDead, sAreaEntryTag) + 1;
    SetPersistentInt(oDead, sAreaEntryTag, iAreaEntryCount);

    // GIVE XP REWARD
    if(iAreaEntryCount==1) // only on first entry in area
    {
        DelayCommand(1.0, XPRewardByType( "AREA_"+sAreaID, oDead, GetLocalInt(OBJECT_SELF, "AREA_XP_DISCOVERY"), XP_TYPE_AREA));
    }

    SendMessageToPC(oDead, " ");
    //SendMessageToPC(oDead, COLOR_OBJECT+"THE FUGUE");
    //SendMessageToPC(oDead, COLOR_DESCRIPTION+"  You are dead.");
    DelayCommand(0.1, SendMessageToPC(oDead, GREEN+GetName(OBJECT_SELF)) );
    DelayCommand(0.11, SendMessageToPC(oDead, LIME+"   "+AreaGetDescription(oDead,OBJECT_SELF,TRUE,iAreaEntryCount)) );

    DelayCommand(0.2, SendMessageToPC(oDead, " ") );
    DelayCommand(0.3, SendMessageToPC(oDead, RED+"          You are dead.") );
}
