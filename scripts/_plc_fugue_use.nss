//::///////////////////////////////////////////////
//:: _plc_fugue_use
//:://////////////////////////////////////////////
/*
    Use Event Script for the "Leave Fugue" placeable
*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2016 jul 17)
//:: Modified:
//:://////////////////////////////////////////////
#include "nw_i0_plot"
#include "00_debug"

#include "_inc_color"
#include "_inc_corpse"
#include "_inc_data"



/////////////////////////////////////////////////////////////////////////////
        // Set new XP, and take gold based on penalty
 /*        SetXP(oDead, nNewXP);
         AssignCommand(oDead,
                        TakeGoldFromCreature(FloatToInt(
                            flPenaltyGold * GetGold(oDead)),
                         oDead, TRUE));

         int nCurrentXP = GetXP(oDead);
         int nCharacterLevel = GetHitDice(oDead);   */
////////////////////////////////////////

//:://////////// //////////////// ///////////////////
//:: Multiplayer Spawn script that encludes XP and Gold Penalty
//:: nw_o0_respawn_rr
//:: Copyright (c) 2001 Bioware Corp.
//:://///////// ////////////////// /////////////////
/*
*/
//::///////// ////////////////////// ///////////////
//:: Created By: Allen Waldrop
//:: Created On: 6/23/2002 1:31:28 AM
//:: Based off Original OnPlayerRespawn Script,
//:: Created By:   Brent (Bioware)
//:: Created On:   November
//:://////////// ////////////////// ////////////////

void RespawnerPenalized() {
        object oDead = GetLastRespawnButtonPresser();
        int nXP = GetXP(oDead);
        int nPenalty = 100 * GetHitDice(oDead);
        int nHD = GetHitDice(oDead);
        int nMin = ((nHD * (nHD - 1)) / 2) * 1000;

        int nNewXP = nXP - nPenalty;
        if (nNewXP < nMin)
               nNewXP = nMin;

        SetXP(oDead, nNewXP);

        int nGoldToTake =    FloatToInt(0.15 * GetGold(oDead));
        if (nGoldToTake > 30000) {
                nGoldToTake = 30000;
        }

        AssignCommand (oDead, TakeGoldFromCreature(nGoldToTake, oDead, TRUE));
        DelayCommand (4.0, FloatingTextStrRefOnCreature (58299, oDead, FALSE));
        DelayCommand (4.8, FloatingTextStrRefOnCreature (58300, oDead, FALSE));
}

void main() {
        object user = GetLastUsedBy();
        string pcid = GetPCID(user);
        location respawn;
        int bPenalty = (GetHitDice(user) > GetLocalInt(GetModule(), "RESPAWN_PENALTY_LEVEL"));

        if (GetLocalInt(OBJECT_SELF, "FUGUE_FIXED_PORTAL")) {
                respawn = GetLocation(GetWaypointByTag("dst_fugue"));
        } else {
                respawn = corpseGetRespawnLocation(user);
        }

        string click_var_label    = "CLICKED"+ObjectToString(OBJECT_SELF);
        corpseDebug("fugue plc - area = '" + GetName(GetAreaFromLocation(respawn))
                + "'  clicked = " + IntToString(GetLocalInt(user, click_var_label)));
        if( !GetLocalInt(user, click_var_label)) {
                string area_name    =  GetName(GetAreaFromLocation(respawn) );

                SetLocalInt(user, click_var_label, TRUE);
                if(bPenalty) {
                        SendMessageToPC(user, DMBLUE+"Click again to respawn to "+PALEBLUE+area_name+DMBLUE+" with a penalty.");
                } else {
                        SendMessageToPC(user, DMBLUE+"Click again to respawn to "+PALEBLUE+area_name+DMBLUE+".");
                }

                DelayCommand(12.0, DeleteLocalInt(user, click_var_label) );
                return;
        }

        // Clear PC Death _after_ second click when we are really doing it.
        ClearPCDeath(pcid);
        CreatureSetIncorporeal(FALSE, user);

        PrepPCForRespawn(user, respawn);
        AssignCommand(user, CharacterRaiseCompletes(respawn, "RAISED"));
        if(bPenalty) {
                DelayCommand(1.0, AssignCommand(user, RespawnerPenalized() ) );
        }
}
