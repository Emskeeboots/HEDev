//::///////////////////////////////////////////////
//:: _mod_respawn
//:://////////////////////////////////////////////
/*
    Use: OnRespawn Module Event


*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2015 dec 20)
//:: Modified:  henesua (2016 jul 6) adapting for Fugue
//:://////////////////////////////////////////////

#include "nw_i0_plot"

#include "_inc_util"
#include "_inc_corpse"
#include "tb_inc_util"

void CreatePrettyCorpse(object oRespawner, location lDeath)
{
    // the corpse node will hold the inventory of the PC
    object oCorpseNode  = CreateCorpseNodeFromBody(oRespawner, lDeath);

    // create corpse
    DelayCommand(0.2, CreateCorpseFromCorpseNode(oCorpseNode, lDeath));
}


void SendToFugue(object oRespawner)
{
    // strip all items---------------
    AssignCommand(oRespawner, StripInventory(oRespawner));
    // ------------------------------

    // remove all effects ----------
    effect eLoop=GetFirstEffect(oRespawner);
    while (GetIsEffectValid(eLoop))
    {
        RemoveEffect(oRespawner, eLoop);
        eLoop=GetNextEffect(oRespawner);
    }
    // restore personal VFX --------- 
    DeleteLocalInt(oRespawner, "vfx_do_op");
    ExecuteScript("_vfx_do_op", oRespawner);
    // ------------------------------

    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oRespawner);
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints(oRespawner)), oRespawner);

    string sDestTag = "dst_respawn_default";
    //string sDestTag = "";

    object oWPFugue = GetObjectByTag(sDestTag);
    if (GetIsObjectValid(oWPFugue))
    {

        SendMessageToPC(GetFirstPC(), "Respawn found " + sDestTag);
        ForceJump(oRespawner, GetLocation(oWPFugue));
        //AssignCommand(oRespawner,JumpToLocation(GetLocation(oWPFugue)));
    }
    else
    {
        SendMessageToPC(GetFirstPC(), "Respawn " + sDestTag + " not found - respawning in place.");
        // * do nothing, just 'res where you are
        AssignCommand(oRespawner,PlayAnimation(ANIMATION_LOOPING_DEAD_BACK,1.0,1000.00));
    }
}


void main()
{
    object oRespawner   = GetLastRespawnButtonPresser();
    location lDeath     = GetLocation(oRespawner);
    object oMod         = GetModule();

    //double respawn protection
    string sVarName = ObjectToString(oRespawner)+"_JUST_RESPAWNED";
    if(GetLocalInt(oMod,sVarName))
        return;
    SetLocalInt(oMod,sVarName,1);
    DelayCommand(2.5, SetLocalInt(oMod,sVarName,0));

    // We never faded to black... but whatever.
    FadeFromBlack(oRespawner);

    db(GetName(oRespawner) + " respawns to fugue plain!");

    // remove problems with spawning corpse at the same location
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneGhost(), oRespawner, 6.00);
    // make the respawning PC temporarily invisible
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY),oRespawner,6.00);

    string pcid         = GetPCID(oRespawner);
    // make the PC's inventory persistent (we strip their body of all items when they go to fugue)
    CreatePersistentInventory("INV_CORPSE_"+pcid, oRespawner, pcid);

    Data_SetLocation("RESPAWN", GetLocation(oRespawner), oRespawner, pcid);

    DelayCommand(0.1, CreatePrettyCorpse(oRespawner, lDeath) );

    // send the respawner to the FUGUE
    DelayCommand(0.2, SendToFugue(oRespawner));
 }
