//::///////////////////////////////////////////////
//:: _mod_dying
//:://////////////////////////////////////////////
/*
    Module Event: OnDying

    This script handles default dying behavior for players.
    Dying is when the character is between 0 and -9 hit points.
    -10 and below is death.

    The default dying system is handled by _ex_dying
    which is called by this script

    Custom dying behavior scripts can also be used
    by naming the script on the NPC/Monster in the local string "SCRIPT_PC_DYING".
    Intention of custom dying behavior is to highlight special dramatic moments.

*/
//:://////////////////////////////////////////////
//:: Created : henesua (2015 dec 19)
//:://////////////////////////////////////////////

#include "_inc_death"

#include "x0_i0_partywide"
#include "x0_i0_match"

void PCRevives(object oPC);
void PCRevives(object oPC)
{
    int iCurrentHP  = GetCurrentHitPoints(oPC);

    if(iCurrentHP<1)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(abs(iCurrentHP)+1),oPC);
        WipeKillerDataFromVictim(oPC);
    }

    if(GetHasEffect(EFFECT_TYPE_CUTSCENE_PARALYZE,oPC))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_IMP_SLEEP),oPC,6.0);
        DelayCommand(3.0,PCRevives(oPC));
    }
}

void main()
{
    object oPC      = GetLastPlayerDying();

    if(GetLocalInt(oPC, "IS_DEAD")) {
        deathDebug("_mod_dying: " +GetName(oPC) + " is already dead - nothing to do.");
        return;
    } 

    int iCurrentHP  = GetCurrentHitPoints(oPC);
    object oKiller  = GetLastDamager(oPC);
    StoreKillerDataOnVictim(oPC,oKiller);

    deathDebug("_mod_dying: " +GetName(oPC) + " cur HP = " +IntToString(iCurrentHP));
    DeleteLocalInt(oPC, "PC_STABILIZED");


    // SUBDUED BUT NOT KILLED --------------------------------------------------
    if(GetLocalInt(oKiller, "COMBAT_NONLETHAL") && oKiller!=oPC)
    {
        AssignCommand(oPC, SpeakString(SHOUT_SUBDUAL_DEAD, TALKVOLUME_SILENT_TALK));
        SetLocalInt(oPC, "PC_STABILIZED", TRUE);
        float fBlackoutTime = 36.0;

        int nConAdj = GetAbilityModifier(ABILITY_CONSTITUTION)-1;
        if(nConAdj<0)
            fBlackoutTime   -= 6.0*IntToFloat(nConAdj);
        else
            fBlackoutTime   -= 3.0*IntToFloat(nConAdj);

        if(fBlackoutTime<24.0)
            fBlackoutTime   = 24.0;

        // heal them
        //ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(1), oPC);

        effect eDazed       = SupernaturalEffect(EffectDazed());
        effect eKnockdown   = SupernaturalEffect(EffectKnockdown());
        effect eBlind       = SupernaturalEffect(EffectBlindness());
        effect eLink        = EffectLinkEffects(eDazed, eKnockdown);
                eLink       = EffectLinkEffects(eLink, eBlind);
                eLink       = EffectLinkEffects(eLink, EffectVisualEffect(VFX_IMP_SLEEP));
                eLink       = EffectLinkEffects(eLink, EffectCutsceneParalyze());

        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(abs(iCurrentHP)+1),oPC);
        DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, fBlackoutTime) );
        DelayCommand((fBlackoutTime+1.0), PCRevives(oPC) );
        // Garbage collection
        DelayCommand(2.5, DeleteLocalObject(oPC, "KILLER"));// no longer need this
        DelayCommand(2.5, DeleteLocalInt(oPC, "IS_DEAD"));  // give death flag a limited lifespan
        return;
    }

    // Narration
    FloatingTextStringOnCreature(" ", oPC, FALSE);
    FloatingTextStringOnCreature(RED+GetName(oPC)+" is mortally wounded!", oPC, FALSE);
    FloatingTextStringOnCreature(" ", oPC, FALSE);

    // Determine whether to execute CUSTOM or DEFAULT dying behavior 
    // get custom dying script - 
    string sDying   = GetLocalString(oKiller, "SCRIPT_PC_DYING");
    if (sDying == "")
        sDying = GetLocalString(GetArea(oPC), "SCRIPT_PC_DYING");

    // If this sets DEATH_CUSTOM then we are done
    if(sDying != "") {
        // CUSTOM DYING BEHAVIOR
        DeleteLocalInt(oPC, "DEATH_CUSTOM");
        ExecuteScript(sDying, oPC);
    }

    if(GetLocalInt(oPC, "DEATH_CUSTOM")) {
        DeleteLocalInt(oPC, "DEATH_CUSTOM");
        return;
    }
        
    // DEFAULT DYING BEHAVIOR
    AssignCommand(oPC, ClearAllActions());
    SetLocalInt(oPC, "iPCDC", 17);

        // Determine whether DEAD or DYING
    if (iCurrentHP <= -10) {
            // DEAD ----------------------------
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
            // Garbage collection
            DeleteLocalInt(oPC, "PC_STABILIZED");
            return;
    } else if (iCurrentHP > 0) {
                // Catch the case where the PC has been healed - should not 
                // fire here.
                //DeleteLocalInt(oPC, "PC_STABILIZED");
    } else {
        // DYING ---------------------------
        effect eBlood;
        float fDelay; // Rate of iterative bleeding

        // Rate of bleeding relates to chance of stabilizing.
        int iStabilize = GetStabilizeBonus(oPC);
        if(iStabilize < 0)
            fDelay = 3.0;   // faster bleeding
        else if (iStabilize > 0)
            fDelay = 9.0;  // slower bleeding
        else
            fDelay = 6.0;   // normal bleeding

        // Unfinished business - Probably best to handle what monsters do with the dying in their AI rather than here.
        //if(MODULE_DEBUG_MODE){SurrenderAllToEnemies(oKiller);}

        string sPC_bloodstain;
            // Blood effects determined by amount of damage to PC
        if (iCurrentHP <=-8) {
                eBlood   = EffectVisualEffect(VFX_COM_CHUNK_RED_LARGE);
                sPC_bloodstain = "bleed5";
        } else if (iCurrentHP <=-6) {
                eBlood   = EffectVisualEffect(VFX_COM_CHUNK_RED_MEDIUM);
                sPC_bloodstain = "bleed4";
        } else if (iCurrentHP <=-4) {
                eBlood   = EffectVisualEffect(VFX_COM_CHUNK_RED_MEDIUM);
                sPC_bloodstain = "bleed3";
        } else if (iCurrentHP <=-2) {
                eBlood   = EffectVisualEffect(VFX_COM_CHUNK_RED_SMALL);
                sPC_bloodstain = "bleed2";
        } else {
                eBlood   = EffectVisualEffect(VFX_COM_CHUNK_RED_SMALL);
                sPC_bloodstain = "bleed1";
        }

        PlayVoiceChat(VOICE_CHAT_HELP, oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eBlood, oPC);

        object oBlood = CreateObject(OBJECT_TYPE_PLACEABLE,sPC_bloodstain, GetLocation(oPC),TRUE);
        DestroyObject(oBlood, fDelay);
        deathDebug("_mod_dying: " +GetName(oPC) + " scheduled _ex_dying for " + FloatToString(fDelay));
        DelayCommand(fDelay, ExecuteScript("_ex_dying", oPC));
    }
}

