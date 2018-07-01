//::///////////////////////////////////////////////
//:: _s2_flight
//:://////////////////////////////////////////////
/*
    Spell Script for Flight

    Transports the caster to the targeted space simila to dimension door.
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2013 jan 5)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"

void main()
{
    //Spellcast Hook Code
    if (!X2PreSpellCastCode())
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    if ( !GetIsObjectValid(OBJECT_SELF) )
        return;

    location lStart = GetLocation(OBJECT_SELF);
    location lDest  = GetSpellTargetLocation();
    float fDur      = 3.0;
    float fDist     = GetDistanceBetweenLocations(lStart, lDest);
    if((fDist/10.0)>3.0)
        fDur        = (fDist/10.0);

    // Alt flying appearance?
    int nType       = GetAppearanceType(OBJECT_SELF);
    int nAlt;
    if(nType>6)
    {
        if(nAlt==0)
        {
            string sType   = Get2DAString("appearance_x","ALT_FLIER",nType);
            nAlt    = StringToInt(sType);
        }
    }

    // actual flight
    effect eFlight = EffectDisappearAppear(lDest);
    // wind for wing flapping
    effect eWind = EffectVisualEffect(VFX_IMP_PULSE_WIND);

    ClearAllActions();
    SetFacingPoint(GetPositionFromLocation(lDest));
    if(nAlt)
        ActionDoCommand( SetCreatureAppearanceType(OBJECT_SELF, nAlt) );
    if(GetCreatureSize(OBJECT_SELF)>CREATURE_SIZE_MEDIUM)
        ActionDoCommand( ApplyEffectToObject(DURATION_TYPE_INSTANT, eWind, OBJECT_SELF) );
    ActionWait( 0.1f );
    ActionDoCommand( ApplyEffectToObject( DURATION_TYPE_TEMPORARY, eFlight, OBJECT_SELF, fDur ) );
}
