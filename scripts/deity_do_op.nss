//deity_do_op.nss

// Do certain operations for the deity sub system.
// This is usually executed as the PC in question.

// deity_tmp_op must be set
// 1 = save PC info to persistence. No effect in single player
// 2 = process cleric daily favor loss
// 3 = print pc deity status
// 4 = check if spell is allowed. Called with ExecuteScriptAndReturnInt
// 5 = do PC pray - called by the feat impl code
// 6 = set PC favor to give deity_tmp_val and clear all pray variables - used for debugging.
// 7 = give PC a holy symbol if she does not already have one.
// 8 = check if PC has a valid deity and can follow or serve that deity.

#include "x2_inc_switches"
#include "tb_inc_deity"


object findNearbyAltar(object oPC) {
        int nDeity = GetDeityIndex(oPC);

        int nNth =1;
        object oRet = GetNearestObjectByTag("deity_altar", oPC, nNth);
        while (GetIsObjectValid(oRet) && GetDistanceBetween(oPC, oRet) < 10.0) {
                if (GetLocalString(oRet, "deity_name") == GetDeity(oPC)) {
                        return oRet;
                }
                oRet = GetNearestObjectByTag("deity_altar", oPC, ++nNth);
        }
        return OBJECT_INVALID;
}

void main() {
        object oPC = OBJECT_SELF;
        int nOp = GetLocalInt(oPC, "deity_tmp_op");
        DeleteLocalInt(oPC, "deity_tmp_op");
        SetExecutedScriptReturnValue(FALSE);

        //SendMessageToPC(oPC, "deity_do_op : " + IntToString(nOp));
        if (nOp == 1) {

                if (!MODULE_NWNX_MODE)
                        return;
                SetPersistentInt(oPC, "deity_favor_points", GetLocalInt(oPC, "deity_favor_points"));
                int nCur = GetLocalInt(oPC, "deity_last_pray_" + IntToString(GetDeityIndex(oPC)));
                SetPersistentInt(oPC, "deity_last_pray", nCur);
                int nCount = GetLocalInt(oPC, "deity_pray_count");
                if (!nCount || CurrentDay() > nCur)
                        DeletePersistentInt(oPC, "deity_pray_count");
                else
                        SetPersistentInt(oPC, "deity_pray_count", nCount);

                return ;
        }


        if (nOp == 2) {
                deityDoDailyCheck(oPC);
                return ;
        }

        if (nOp == 3) {
                deityStatusFeedback(oPC);
                return;
        }

        if (nOp == 4) {
                int nSpell = GetSpellId();
                int nClass = GetLastSpellCastClass();
                if (nClass != CLASS_TYPE_CLERIC && nClass != CLASS_TYPE_DRUID
                && nClass != CLASS_TYPE_PALADIN && nClass != CLASS_TYPE_RANGER && nSpell != 308)
                        return;

                int nUserType = StringToInt(Get2DAString("spells", "UserType", nSpell));
                // Only spells and turnundead get effected here.
                if (nUserType != 1 && nSpell != 308)
                        return;


                int nStand =  deityGetStanding(GetDeityIndex(oPC), oPC);

                // No deity or lapsed then no spells.
                if (nStand <= 0) {
			WriteTimestampedLogEntry("DEBUG: " + GetName(oPC) + " Deity spell check: " + IntToString(nStand)
						 + " '" + GetDeity(oPC) + "' " + IntToString(GetDeityIndex(oPC))); 
                        SetLocalString(oPC, "spell_hook_message", "You feel spiritually uneasy and empty.");
                        SetExecutedScriptReturnValue(TRUE);
                }
                return;
        }

        if (nOp == 5) {
                int nDeity = GetDeityIndex(oPC);
                // if in combat do combat prayer

		if (nDeity < 0) {
			SendMessageToPC(oPC, "You have no deity to which to pray!");
			return;
			
		}
                if (GetIsInCombat(oPC)) {
                        deityMiracleCheck(oPC);
                } else {
                // else look for nearby altar to correct deity and if found pray at that
                        object oAltar = findNearbyAltar(oPC);
                        if (GetIsObjectValid(oAltar)) {
                                ActionMoveToLocation(GetLocation(oAltar));
                                ActionDoCommand(SetFacingPoint(GetPosition(oAltar)));
                        }
                // else just pray in place.
                        deityAnimatePrayer(nDeity, oPC);
                        ActionDoCommand(deityDoPrayerEither(oPC, oAltar));
                }

                return;
        }

        if (nOp == 6) {
                int nDeity = GetDeityIndex(oPC);
                int nFavor = GetLocalInt(oPC, "deity_tmp_val");
                DeleteLocalInt(oPC, "deity_tmp_val");

                if (nFavor < 1 || nFavor > 100)
                        return;

                DeitySetFavorPoints(oPC, nFavor);
                DeleteLocalInt(oPC, "deity_last_pray_" + IntToString(nDeity));
                DeleteLocalInt(oPC, "deity_pray_count");
                return;
        }

        if (nOp == 7) {
                GiveHolySymbol(oPC);
                // if this runs set the return value to true.
                SetExecutedScriptReturnValue(TRUE);
                return;
        }

        if (nOp == 8) {
                int nDeity = GetDeityIndex(oPC);
                //SendMessageToPC(oPC, "deity_do_op: got index " + IntToString(nDeity));
                if (nDeity < 0) {
                        SetExecutedScriptReturnValue(FALSE);
                        return;
                }

                // Check if valid selection
                if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) > 0) {
                        if (!DeityCheckCanServe(oPC, nDeity)) {
                               SetExecutedScriptReturnValue(FALSE);
                               return;
                        }
                } else {
                        if (!DeityCheckCanFollow(oPC, nDeity)) {
                                SetExecutedScriptReturnValue(FALSE);
                               return;
                        }
                }

                SetExecutedScriptReturnValue(TRUE);
                return;
        }

}
