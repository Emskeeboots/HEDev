//::///////////////////////////////////////////////
//:: _s2_jump
//:://////////////////////////////////////////////
/*
    Spell Script for Jump

    Transports the caster a very short distance to the targeted space similar to dimension door.
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 17)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"
#include "_inc_color"

float DetermineMaxJump(int nAppear);
void DoJumpAnimation(location lDest);
void DoJump(location lDest);

float DetermineMaxJump(int nAppear)
{
    float fDist;
    string sName= Get2DAString("appearance","NAME",nAppear);
    if(nAppear<=6)
        fDist   = 2.0*StringToFloat(Get2DAString("appearance","HEIGHT",nAppear));
    else if( sName=="frog" || sName=="spider" || sName=="deer" || sName=="goat")// VERIFY VALUES
        fDist   = 12.0;
    else if( GetCreatureSize(OBJECT_SELF)>CREATURE_SIZE_MEDIUM )
        fDist   = 9.0;
    else
        fDist   = 5.0;
    return fDist;
}

void DoJumpAnimation(location lDest)
{
    SetFootstepType(FOOTSTEP_TYPE_NONE);
    AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM8, 1.5, 1.2));
    DelayCommand(4.40, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY), OBJECT_SELF, 0.63));
    DelayCommand(4.42, AssignCommand(OBJECT_SELF, JumpToLocation(lDest)));
    DelayCommand(4.44, SetFootstepType(FOOTSTEP_TYPE_DEFAULT));
}

void DoJump(location lDest)
{
    // actual flight
    effect eJump = EffectDisappearAppear(lDest);
    ActionWait( 0.1f );
    ActionDoCommand( ApplyEffectToObject( DURATION_TYPE_TEMPORARY, eJump, OBJECT_SELF, 3.0 ) );
}

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    //  object oCaster = GetLastSpellCaster();
    if ( !GetIsObjectValid(OBJECT_SELF) )
        return;
    if ( GetIsInCombat(OBJECT_SELF) )
    {
        SendMessageToPC(OBJECT_SELF, RED+"You can not jump while engaged in combat.");
        return;
    }

    location lStart = GetLocation(OBJECT_SELF);
    location lDest  = GetSpellTargetLocation();
    float fDur      = 3.0;
    float fDist     = GetDistanceBetweenLocations(lStart, lDest);
    int nAppear     = GetAppearanceType(OBJECT_SELF);
    float fMax      = DetermineMaxJump(nAppear);
    if((fDist>fMax))
    {
        SendMessageToPC(OBJECT_SELF, RED+"You are attempting to jump too far.");
        return;
    }

    ClearAllActions();
    if(nAppear<=6 || FindSubString(GetStringLowerCase(Get2DAString("appearance", "MODELTYPE", nAppear)), "f")!=-1)
        AssignCommand(OBJECT_SELF, DoJumpAnimation(lDest));
    else
        AssignCommand(OBJECT_SELF, DoJump(lDest));
}
