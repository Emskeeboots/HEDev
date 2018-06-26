//::///////////////////////////////////////////////
//:: _mod_death
//:://////////////////////////////////////////////
/*
    Module Event: OnDeath
    Modified: NW_O0_DEATH.NSS Copyright (c) 2008 Bioware Corp.

    This script handles the default behavior
    that occurs when a player dies.

    Custom death behavior scripts can also be used
    by naming the script on either the Killer or the Area in the local string "SCRIPT_PC_DEATH".
    Scripts specified by the Killer have priority over the Area.
    Intention of custom death behavior is to highlight special dramatic moments.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles (November 6, 2001)
//:: Modified: BK (October 8 2002) Overriden for Expansion
//:: Modified: Deva Winblood (April 21th, 2008) Modified to handle dismounts when PC dies while mounted.
//:: Modified: henesua (2015 dec 19)
//:://////////////////////////////////////////////

#include "_inc_util"
#include "_inc_corpse"
#include "x3_inc_horse"
#include "x0_i0_position"
#include "tb_inc_string"

void DropCorpses(object oCreature)
{
    object oItem    = GetFirstItemInInventory(oCreature);
    float fDir      = GetFacing(oCreature);
    location lLoc   =  GenerateNewLocation(oCreature,
                                DISTANCE_SHORT,
                                GetOppositeDirection(fDir),
                                fDir);
    while(GetIsObjectValid(oItem))
    {
        if(GetResRef(oItem)=="corpse_pc")
            DelayCommand(0.1, CorpseItemDropped(oCreature, oItem, lLoc));

        oItem       = GetNextItemInInventory(oCreature);
    }
}


void Raise(object oPC)
{
        effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION);

        effect eBad = GetFirstEffect(oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints(oPC)), oPC);

        //Search for negative effects
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_ABILITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_AC_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_ATTACK_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SAVING_THROW_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SKILL_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_BLINDNESS ||
                GetEffectType(eBad) == EFFECT_TYPE_DEAF ||
                GetEffectType(eBad) == EFFECT_TYPE_PARALYZE ||
                GetEffectType(eBad) == EFFECT_TYPE_NEGATIVELEVEL)
                {
                    //Remove effect if it is negative.
                    RemoveEffect(oPC, eBad);
                }
            eBad = GetNextEffect(oPC);
        }
        //Fire cast spell at event for the specified target
        SignalEvent(oPC, EventSpellCastAt(OBJECT_SELF, SPELL_RESTORATION, FALSE));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oPC);

}

///////////////////////////////////////////////////////////////[ MAIN ]/////////
void main()
{
    object oPC = GetLastPlayerDied();

    // Check whether the death event has already been called
    if(GetLocalInt(oPC, "IS_DEAD")) {
        deathDebug("_mod_death: " +GetName(oPC) + " is already dead - nothing to do.");
        return;
    }
    SetLocalInt(oPC, "IS_DEAD", TRUE); // set the death event as called 
    DeleteLocalInt(oPC, "PC_STABILIZED"); // dead people are not considered stabilized.

    deathDebug("_mod_death: " +GetName(oPC) + " cur HP = " + IntToString(GetCurrentHitPoints(oPC)));
    // increment number of times that oPC died
    // SetLocalInt(oPC, "NW_L_PLAYER_DIED", GetLocalInt(oPC, "NW_L_PLAYER_DIED") + 1);

    // determine killer
    string killer_name  = GetLocalString(oPC,"KILLER_NAME");
    if(killer_name=="")
        StoreKillerDataOnVictim(oPC, GetLastDamager(oPC));


    // determine custom death script if any
    // priority is given to a script set on the pc (applied by the killer)
    // if no custom behavior is specified by the pc, then the area is checked
    string sCustomDeathScript = GetLocalString(oPC, "SCRIPT_PC_DEATH");
    if(sCustomDeathScript=="")
    {
        sCustomDeathScript = GetLocalString(GetArea(oPC), "SCRIPT_PC_DEATH");
    }

// BIOWARE's HORSE FIXES -------------------------------------------------------
    location lPC = GetLocation(oPC);
    object oModule = GetModule();
    object oHorse;
    object oInventory;
    string sID;
    int nC;
    string sT;
    string sR;
    int nCH;
    int nST;
    object oItem;
    effect eEffect;
    string sDB="X3SADDLEBAG"+GetTag(oModule);
    if (GetStringLength(GetLocalString(oModule,"X3_SADDLEBAG_DATABASE"))>0) sDB=GetLocalString(oModule,"X3_SADDLEBAG_DATABASE");
    if (HorseGetIsMounted(oPC))
    { // Dismount and then die
        //SetCommandable(FALSE,oPC);
        //ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oPC);
        DelayCommand(0.3,HORSE_SupportResetUnmountedAppearance(oPC));
        DelayCommand(3.0,HORSE_SupportCleanVariables(oPC));
        DelayCommand(1.0,HORSE_SupportRemoveACBonus(oPC));
        DelayCommand(1.0,HORSE_SupportRemoveHPBonus(oPC));
        DelayCommand(1.1,HORSE_SupportRemoveMountedSkillDecreases(oPC));
        DelayCommand(1.1,HORSE_SupportAdjustMountedArcheryPenalty(oPC));
        DelayCommand(1.2,HORSE_SupportOriginalSpeed(oPC));
        if (!GetLocalInt(oModule,"X3_HORSE_NO_CORPSES"))
        { // okay to create lootable horse corpses
            sR=GetSkinString(oPC,"sX3_HorseResRef");
            sT=GetSkinString(oPC,"sX3_HorseMountTag");
            nCH=GetSkinInt(oPC,"nX3_HorseAppearance");
            nST=GetSkinInt(oPC,"nX3_HorseTail");
            nC=GetLocalInt(oPC,"nX3_HorsePortrait");
            if (GetStringLength(sR)>0&&GetStringLeft(sR,GetStringLength(HORSE_PALADIN_PREFIX))!=HORSE_PALADIN_PREFIX)
            { // create horse
                oHorse=HorseCreateHorse(sR,lPC,oPC,sT,nCH,nST);
                SetLootable(oHorse,TRUE);
                SetPortraitId(oHorse,nC);
                SetLocalInt(oHorse,"bDie",TRUE);
                AssignCommand(oHorse,SetIsDestroyable(FALSE,TRUE,TRUE));
            } // create horse
        } // okay to create lootable horse corpses
        oInventory=GetLocalObject(oPC,"oX3_Saddlebags");
        sID=GetLocalString(oPC,"sDB_Inv");
        if (GetIsObjectValid(oInventory))
        { // drop horse saddlebags
            if (!GetIsObjectValid(oHorse))
            { // no horse created
                HORSE_SupportTransferInventory(oInventory,OBJECT_INVALID,lPC,TRUE);
            } // no horse created
            else
            { // transfer to horse
                HORSE_SupportTransferInventory(oInventory,oHorse,GetLocation(oHorse),TRUE);
                //DelayCommand(2.0,PurgeSkinObject(oHorse));
                //DelayCommand(3.0,KillTheHorse(oHorse));
                //DelayCommand(1.8,PurgeSkinObject(oHorse));
            } // transfer to horse
        } // drop horse saddlebags
        else if (GetStringLength(sID)>0)
        { // database based inventory
            nC=GetCampaignInt(sDB,"nCO_"+sID);
            while(nC>0)
            { // restore inventory
                sR=GetCampaignString(sDB,"sR"+sID+IntToString(nC));
                sT=GetCampaignString(sDB,"sT"+sID+IntToString(nC));
                nST=GetCampaignInt(sDB,"nS"+sID+IntToString(nC));
                nCH=GetCampaignInt(sDB,"nC"+sID+IntToString(nC));
                DeleteCampaignVariable(sDB,"sR"+sID+IntToString(nC));
                DeleteCampaignVariable(sDB,"sT"+sID+IntToString(nC));
                DeleteCampaignVariable(sDB,"nS"+sID+IntToString(nC));
                DeleteCampaignVariable(sDB,"nC"+sID+IntToString(nC));
                if (!GetIsObjectValid(oHorse))
                { // no lootable corpse
                    oItem=CreateObject(OBJECT_TYPE_ITEM,sR,lPC,FALSE,sT);
                } // no lootable corpse
                else
                { // lootable corpse
                    oItem=CreateItemOnObject(sR,oHorse,nST,sT);
                } // lootable corpse
                if (GetItemStackSize(oItem)!=nST) SetItemStackSize(oItem,nST);
                if (nCH>0) SetItemCharges(oItem,nCH);
                nC--;
            } // restore inventory
            DeleteCampaignVariable(sDB,"nCO_"+sID);
            //DelayCommand(2.0,PurgeSkinObject(oHorse));
            if (GetIsObjectValid(oHorse)&&GetLocalInt(oHorse,"bDie")) DelayCommand(3.0,KillTheHorse(oHorse));
            //DelayCommand(2.5,PurgeSkinObject(oHorse));
        } // database based inventory
        else if (GetIsObjectValid(oHorse))
        { // no inventory
            //DelayCommand(1.0,PurgeSkinObject(oHorse));
            DelayCommand(2.0,KillTheHorse(oHorse));
            //DelayCommand(1.8,PurgeSkinObject(oHorse));
        } // no inventory
        //eEffect=EffectDeath();
        //DelayCommand(1.6,ApplyEffectToObject(DURATION_TYPE_INSTANT,eEffect,oPC));
        //DelayCommand(1.7,SetCommandable(TRUE,oPC));
        //return;
    } // Dismount and then die

// CUSTOM DEATH BEHAVIOR -------------------------------------------------------
    if(sCustomDeathScript!="")
    {
        ExecuteScript(sCustomDeathScript, oPC);
        //garbage collection
        WipeKillerDataFromVictim(oPC);
        DeleteLocalInt(oPC, "IS_DEAD"); // give death flag a limited lifespan
        return;
    }

// DEFAULT DEATH BEHAVIOR ------------------------------------------------------
    AssignCommand(oPC, ClearAllActions());

    // drop items
    //DropItems(oPC);
    // drop all the corpses we are carrying
    DropCorpses(oPC);
    // store the death of the PC in DB
    RecordPCDeath(oPC);
    // create bloodstain
    object oBlood = CreateObject(OBJECT_TYPE_PLACEABLE,"bleed6",lPC,TRUE); // Project Q/special blood content
    DestroyObject(oBlood, 30.0); // give it a limited life span
    //dramatic vfx
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH), oPC);
    // narration
    FloatingTextStringOnCreature(" ",oPC,FALSE);
    FloatingTextStringOnCreature(tbColorAndCook(GetName(oPC)+" breathes <his/her> last.", oPC, TEXT_COLOR_WHITE),oPC,FALSE);
    //FloatingTextStringOnCreature(WHITE+GetName(oPC)+" breathes their last.", oPC,FALSE);
    FloatingTextStringOnCreature(" ",oPC,FALSE);
    // Garbage collection
    DelayCommand(2.5, WipeKillerDataFromVictim(oPC));
    DelayCommand(2.5, DeleteLocalInt(oPC, "IS_DEAD")); // give death flag a limited lifespan

    // * make friendly to Each of the 3 common factions
    // * Note: waiting for Sophia to make SetStandardFactionReptuation to clear all personal reputation
    if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER, oPC) <= 10)
    {   SetLocalInt(oPC, "NW_G_Playerhasbeenbad", 10); // * Player bad
        SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 80, oPC);
    }
    if (GetStandardFactionReputation(STANDARD_FACTION_MERCHANT, oPC) <= 10)
    {   SetLocalInt(oPC, "NW_G_Playerhasbeenbad", 10); // * Player bad
        SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 80, oPC);
    }
    if (GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, oPC) <= 10)
    {   SetLocalInt(oPC, "NW_G_Playerhasbeenbad", 10); // * Player bad
        SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 80, oPC);
    }

    DelayCommand(2.5, PopUpDeathGUIPanel(oPC, RESPAWN_BUTTON, HELP_BUTTON, 0, DEATH_RULES));
}
