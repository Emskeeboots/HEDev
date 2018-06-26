// tlr_inc_utils.nss
// Common routines for meaglyn's tailoring system
// This contains code to use lists and 2das to check for next/previous part to use.
// It allows the builder to specific allow and deny lists for each part based on gender 
// and race. This is especially useful for heads.
// For clothing pieces you can essentially use the parts_*.2da files as the allow list
// with an optional limiting to a specific AC. You can then additionally specify a deny list.

// These routines are called by code in the bt_inc and tlr_include files which handle the 
// specifics for each type (body or clothing) of tailoring.

#include "x0_i0_stringlib"

const int TLR_DEBUG = FALSE;

void tlrDebug(string sMsg, object oPC = OBJECT_INVALID) {
        if (TLR_DEBUG) {
                if (!GetIsPC(oPC))
                        oPC = GetFirstPC();

                SendMessageToPC(oPC, sMsg);
                WriteTimestampedLogEntry(sMsg);
        }
}


string GetCachedACBonus(string sFile, int iRow);
string tlrGet2DAFile(int nPart);
int IsIntInList(string sList, int nNum);

//
int tlrNextIn2DAfile(int nPart, int nCur, int nTop, int nBottom, int nAC = -1, int bDec = FALSE, string sDeny = "") {

        if (bDec) {
                nCur --;
                if (nCur < nBottom) nCur = nTop;
        } else {
                nCur ++;
                if (nCur > nTop) nCur = nBottom;
        }


        string s2DAFile = tlrGet2DAFile(nPart);
        string s2DA_ACBonus = GetCachedACBonus(s2DAFile, nCur);

        int nCount = 0;
        int nMax = nTop - nBottom + 1;

        // Make sure we don't got around for ever looking for a part.
        while (nCount < nMax) {

                // Valid 2da entry 
                if (s2DA_ACBonus != "SKIP" && s2DA_ACBonus != "FAIL") {
                        // Not in the deny list
                        if (sDeny == "" || !IsIntInList(sDeny, nCur)) {

                                // Check for an AC match
                                if (nAC == -1 || nAC == StringToInt(s2DA_ACBonus)) {

                                       // okay to use this one
                                        return nCur;
                                }
                        }
                }

                nCount ++;
                if (bDec) {
                        nCur --;
                                // and wrap to max if needed
                        if (nCur < nBottom) nCur = nTop;
                } else {
                        nCur ++;
                        if (nCur > nTop) nCur = nBottom;
                }
                s2DA_ACBonus = GetCachedACBonus(s2DAFile, nCur);
        }

        // fallback to empty part - this is for clothing parts not body parts...
        return nBottom;
}



int IsIntInList(string sList, int nNum) {

        int nHighest = 0;
        int nDash;
        int nInt = 0;
        int nStart;
        int nEnd;

        // Each token is an int or a range
        if (nNum < 0)
                return FALSE;

        // Nothing is in an empty list
        if (sList == "")
                return FALSE;

        struct sStringTokenizer stTok = GetStringTokenizer(sList, ",");
        if (!HasMoreTokens(stTok)) {
                return FALSE;
        }
        while (HasMoreTokens(stTok)) {
                stTok = AdvanceToNextToken(stTok);
                string sCur = GetNextToken(stTok);

                //endMessageToPC(GetFirstPC(), "Got token " + sCur + " highest = " + IntToString(nHighest));
                if ((nDash = FindSubString(sCur, "-")) != -1) {
                        // Handle a range
                        nStart = StringToInt(GetStringLeft(sCur, nDash));
                        nEnd = StringToInt(GetStringRight(sCur, GetStringLength(sCur) - (nDash + 1)));
                        //SendMessageToPC(GetFirstPC(), "Got range start = "
                        //    + IntToString(nStart) + " end = " + IntToString(nEnd)
                        //    + " dash = " + IntToString(nDash));
                        if (nNum >= nStart && nNum <= nEnd)
                                return TRUE;
                        nHighest = nEnd;
                } else {
                        nInt = StringToInt(sCur);
                        if (nInt == nNum)
                                return TRUE;
                        nHighest = nInt;
                }
                if (nHighest > nNum)
                        return FALSE;
        }
        return FALSE;
}

// This may not be needed. It should be a bit more efficient though
int GetIntInList(string sList, int nNum) {

        int nHighest = 0;
        int nDash;
        int nInt = 0;
        int nStart;
        int nEnd;

        struct sStringTokenizer stTok = GetStringTokenizer(sList, ",");
        if (!HasMoreTokens(stTok)) {
                return nNum;
        }
        while (HasMoreTokens(stTok)) {
                stTok = AdvanceToNextToken(stTok);
                string sCur = GetNextToken(stTok);

                //endMessageToPC(GetFirstPC(), "Got token " + sCur + " highest = " + IntToString(nHighest));
                if ((nDash = FindSubString(sCur, "-")) != -1) {
                        // Handle a range
                        nStart = StringToInt(GetStringLeft(sCur, nDash));
                        nEnd = StringToInt(GetStringRight(sCur, GetStringLength(sCur) - (nDash + 1)));
                        //SendMessageToPC(GetFirstPC(), "Got range start = "
                        //    + IntToString(nStart) + " end = " + IntToString(nEnd)
                        //    + " dash = " + IntToString(nDash));
                        // if in the range okay
                        if (nNum >= nStart && nNum <= nEnd)
                                return nNum;
                        else if (nNum < nStart)
                                return nStart;

                        nHighest = nEnd;
                } else {
                        nInt = StringToInt(sCur);
                        if (nInt == nNum)
                                return nNum;
                        nHighest = nInt;
                }
                if (nHighest > nNum)
                        return nHighest;
        }
        return -1;
}

int GetIntInListDec(string sList, int nNum) {

        int nLowest = 1000;
        int nDash;
        int nInt = 0;
        int nStart;
        int nEnd;

        int nElements = GetNumberTokens(sList, ",");
        if (nElements <= 0)
                return nNum;

        int nCur = nElements -1;
    //SendMessageToPC(GetFirstPC(), "IntInListDec list = '" + sList + "' nNum = "
    //  + IntToString(nNum) + " nelem = " + IntToString(nElements));
        while (nCur >= 0) {
                string sCur = GetTokenByPosition(sList, ",", nCur);

                //SendMessageToPC(GetFirstPC(), "Got token " + sCur + " highest = " + IntToString(nHighest));
                if ((nDash = FindSubString(sCur, "-")) != -1) {
                        // Handle a range
                        nStart = StringToInt(GetStringLeft(sCur, nDash));
                        nEnd = StringToInt(GetStringRight(sCur, GetStringLength(sCur) - (nDash + 1)));
                        //SendMessageToPC(GetFirstPC(), "Got range start = "
                        //    + IntToString(nStart) + " end = " + IntToString(nEnd)
                        //    + " dash = " + IntToString(nDash));
                        // if in the range okay
                        if (nNum >= nStart && nNum <= nEnd)
                                return nNum;
                        else if (nNum > nEnd)
                                return nEnd;

                        nLowest = nStart;
                } else {
                        nInt = StringToInt(sCur);
                        if (nInt == nNum)
                                return nNum;
                        nLowest = nInt;
                }
                if (nLowest < nNum)
                        return nLowest;
        nCur --;
        }
        return -1;
}

// Pass in the index
// nBottom and nTop define the total range. Returns
// next index int the range in the list, starting at nIdx inclusive
// (i.e. may return nIdx itself).
// If list is empty this just returns nIdx (wrapping if > nTop).
// NOTE : items in the list should be within defined range.
int tlrGetNextInList(int nIdx, int nBottom, int nTop, string sList = "") {
        //if (nIdx > nTop)
        //        nIdx = nBottom;

        if (sList == "")
                return nIdx;


        int nRet = GetIntInList(sList, nIdx);
        // This means we need to start again at the beginning
        if (nRet == -1) {
                nIdx = nBottom;
                nRet = GetIntInList(sList, nIdx);
        }
        return nRet;

}


// This is a bit less efficient but will be faster for sparse lists
int tlrGetPrevInList(int nIdx, int nBottom, int nTop, string sList = "") {

        //if (nIdx < nBottom)
         //       nIdx = nTop;

        if (sList == "")
                return nIdx;

        int nRet = GetIntInListDec(sList, nIdx);
        if (nRet == -1) {
                nIdx = nTop;
                nRet = GetIntInListDec(sList, nIdx);
        }
        /*
        while (!IsIntInList(sList, nIdx)) {
                nIdx --;
                if (nIdx < nBottom)
                        nIdx = nTop;
        }
        */
        return nRet;
}

// Given an index - find the next in the range which is allowed and not denied.
// Empty allow list means allow every thing (unless denied).
// If non empty then idx must be in sAllow.
// Empty deny means deny nothing, non empty means returned value will not be in sDeny
int tlrGetNextIdx(int nIdx, int nBottom, int nTop, string sAllow = "", string sDeny = "") {
        nIdx ++;
        if (nIdx > nTop)
                nIdx = nBottom;

        if (sAllow == "" && sDeny == "")
                return nIdx;

        if (sAllow == "") {
                // sDeny is not empty -
                while (IsIntInList(sDeny, nIdx)) {
                        nIdx ++;
                        if (nIdx > nTop)
                                nIdx = nBottom;
                }
                return nIdx;
        } else if (sDeny == "") {
                // Allow is non-empty
                return tlrGetNextInList(nIdx, nBottom, nTop, sAllow);
        } else {
                // Both lists active
                nIdx =  tlrGetNextInList(nIdx, nBottom, nTop, sAllow);
                while (IsIntInList(sDeny, nIdx)) {
                        nIdx ++;
                        if (nIdx > nTop)
                                nIdx = nBottom;
                        nIdx =  tlrGetNextInList(nIdx, nBottom, nTop, sAllow);
                }
        }

        return nIdx;

}
int tlrGetPrevIdx(int nIdx, int nBottom, int nTop, string sAllow = "", string sDeny = "") {
        nIdx --;
        if (nIdx < nBottom)
                nIdx = nTop;

        if (sAllow == "" && sDeny == "")
                return nIdx;

        if (sAllow == "") {
                // sDeny is not empty -
                while (IsIntInList(sDeny, nIdx)) {
                        nIdx --;
                        if (nIdx < nBottom)
                                nIdx = nTop;
                }
                return nIdx;
        } else if (sDeny == "") {
                // Allow is non-empty
                return tlrGetPrevInList(nIdx, nBottom, nTop, sAllow);
        } else {
                // Both lists active
                nIdx =  tlrGetPrevInList(nIdx, nBottom, nTop, sAllow);
                while (IsIntInList(sDeny, nIdx)) {
                        nIdx --;
                        if (nIdx < nBottom)
                                nIdx = nTop;
                        nIdx =  tlrGetPrevInList(nIdx, nBottom, nTop, sAllow);
                }
        }

        return nIdx;

}


// These numbers are the same as the  ITEM_APPR_ARMOR_MODEL_* set
int tlrIsSymmetrical(int nPart) {
        if (nPart == ITEM_APPR_ARMOR_MODEL_LFOREARM || nPart == ITEM_APPR_ARMOR_MODEL_RFOREARM
                || nPart == ITEM_APPR_ARMOR_MODEL_LBICEP || nPart == ITEM_APPR_ARMOR_MODEL_RBICEP
                || nPart == ITEM_APPR_ARMOR_MODEL_LHAND || nPart == ITEM_APPR_ARMOR_MODEL_RHAND
                || nPart == ITEM_APPR_ARMOR_MODEL_LFOOT || nPart == ITEM_APPR_ARMOR_MODEL_RFOOT
                || nPart == ITEM_APPR_ARMOR_MODEL_LTHIGH || nPart == ITEM_APPR_ARMOR_MODEL_RTHIGH
                || nPart == ITEM_APPR_ARMOR_MODEL_LSHIN || nPart == ITEM_APPR_ARMOR_MODEL_RSHIN)
                return TRUE;
        return FALSE;
}

int tlrIsArms(int nPart) {
        if (nPart == ITEM_APPR_ARMOR_MODEL_LFOREARM || nPart == ITEM_APPR_ARMOR_MODEL_RFOREARM
                || nPart == ITEM_APPR_ARMOR_MODEL_LBICEP || nPart == ITEM_APPR_ARMOR_MODEL_RBICEP
                || nPart == ITEM_APPR_ARMOR_MODEL_LHAND || nPart == ITEM_APPR_ARMOR_MODEL_RHAND)
                return TRUE;
        return FALSE;

}

int tlrIsLegs(int nPart) {
        if (nPart == ITEM_APPR_ARMOR_MODEL_LFOOT || nPart == ITEM_APPR_ARMOR_MODEL_RFOOT
                || nPart == ITEM_APPR_ARMOR_MODEL_LTHIGH || nPart == ITEM_APPR_ARMOR_MODEL_RTHIGH
                || nPart == ITEM_APPR_ARMOR_MODEL_LSHIN || nPart == ITEM_APPR_ARMOR_MODEL_RSHIN)
                return TRUE;
        return FALSE;
}

int tlrGetOppositePart(int nPart) {
        switch (nPart) {
              case ITEM_APPR_ARMOR_MODEL_RBICEP: return ITEM_APPR_ARMOR_MODEL_LBICEP;
              case ITEM_APPR_ARMOR_MODEL_RFOOT: return ITEM_APPR_ARMOR_MODEL_LFOOT;
              case ITEM_APPR_ARMOR_MODEL_RFOREARM: return ITEM_APPR_ARMOR_MODEL_LFOREARM;
              case ITEM_APPR_ARMOR_MODEL_RHAND: return ITEM_APPR_ARMOR_MODEL_LHAND;
              case ITEM_APPR_ARMOR_MODEL_RSHIN: return ITEM_APPR_ARMOR_MODEL_LSHIN;
              case ITEM_APPR_ARMOR_MODEL_RSHOULDER: return ITEM_APPR_ARMOR_MODEL_LSHOULDER;
              case ITEM_APPR_ARMOR_MODEL_RTHIGH: return ITEM_APPR_ARMOR_MODEL_LTHIGH;
              case ITEM_APPR_ARMOR_MODEL_LBICEP: return ITEM_APPR_ARMOR_MODEL_RBICEP;
              case ITEM_APPR_ARMOR_MODEL_LFOOT: return ITEM_APPR_ARMOR_MODEL_RFOOT;
              case ITEM_APPR_ARMOR_MODEL_LFOREARM: return ITEM_APPR_ARMOR_MODEL_RFOREARM;
              case ITEM_APPR_ARMOR_MODEL_LHAND: return ITEM_APPR_ARMOR_MODEL_RHAND;
              case ITEM_APPR_ARMOR_MODEL_LSHIN: return ITEM_APPR_ARMOR_MODEL_RSHIN;
              case ITEM_APPR_ARMOR_MODEL_LSHOULDER: return ITEM_APPR_ARMOR_MODEL_RSHOULDER;
              case ITEM_APPR_ARMOR_MODEL_LTHIGH: return ITEM_APPR_ARMOR_MODEL_RTHIGH;
        }
        // Return self in case not a symmetrical part.
        return nPart;
}


int tlrGetPartNumber(object oObject, int nPart) {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE) {
                return GetCreatureBodyPart(nPart, oObject);
        } else if (GetObjectType(oObject) == OBJECT_TYPE_ITEM) {
                if (GetBaseItemType(oObject) == BASE_ITEM_ARMOR)
                        return GetItemAppearance(oObject, ITEM_APPR_TYPE_ARMOR_MODEL, nPart);
                else
                        return -1;
        }

        return -1;
}
string tlrGet2DAFile(int nPart) {
        switch (nPart) {

                case ITEM_APPR_ARMOR_MODEL_BELT: return "parts_belt";
                case ITEM_APPR_ARMOR_MODEL_RBICEP:
                case ITEM_APPR_ARMOR_MODEL_LBICEP: return "parts_bicep";
                case ITEM_APPR_ARMOR_MODEL_RFOOT:
                case ITEM_APPR_ARMOR_MODEL_LFOOT: return "parts_foot";
                case ITEM_APPR_ARMOR_MODEL_RFOREARM:
                case ITEM_APPR_ARMOR_MODEL_LFOREARM: return "parts_forearm";
                case ITEM_APPR_ARMOR_MODEL_RHAND:
                case ITEM_APPR_ARMOR_MODEL_LHAND: return "parts_hand";
                case ITEM_APPR_ARMOR_MODEL_RSHIN:
                case ITEM_APPR_ARMOR_MODEL_LSHIN: return "parts_shin";
                case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
                case ITEM_APPR_ARMOR_MODEL_LSHOULDER: return "parts_shoulder";
                case ITEM_APPR_ARMOR_MODEL_RTHIGH:
                case ITEM_APPR_ARMOR_MODEL_LTHIGH: return "parts_legs";
                case ITEM_APPR_ARMOR_MODEL_NECK: return "parts_neck";
                case ITEM_APPR_ARMOR_MODEL_PELVIS: return "parts_pelvis";
                case ITEM_APPR_ARMOR_MODEL_ROBE: return "parts_robe";
                case ITEM_APPR_ARMOR_MODEL_TORSO: return "parts_chest";
        }
        return "";
}

int tlrCheckNew2da(string sFile) {
        int nRet = GetLocalInt(GetModule(), sFile);
        if (nRet == 2) {
                return TRUE;
        } else if (nRet == 1)
        return FALSE;

        // Need to look it up
        // Row 1 is valid in all 2das
        string sVal = Get2DAString(sFile, "MODELSRC", 1);
        if (sVal == "1") {
                SetLocalInt(GetModule(), sFile, 2);
                return TRUE;
        } 
        SetLocalInt(GetModule(), sFile, 1);
        return FALSE; 
}


string GetCachedACBonus(string sFile, int iRow) {
        object oMod = GetModule();
        string sACBonus = GetLocalString(oMod, sFile + IntToString(iRow));

        if (sACBonus == "") {
                sACBonus = Get2DAString(sFile, "ACBONUS", iRow);

                if (sACBonus == "") {
                        sACBonus = "SKIP";

            // This one won't mean much since all files are padded to 255. The loop will just have to go all the way.
                        string sCost = Get2DAString(sFile, "COSTMODIFIER", iRow);
                        if (sCost == "" ) sACBonus = "FAIL";
                } else if (tlrCheckNew2da(sFile)) {
               // ACBONUS was not empty if we have new 2das need to check the model source
                        string sSrc = Get2DAString(sFile, "MODELSRC", iRow);
                        if (sSrc == "")
                                sACBonus = "SKIP";
                        else 
                                SetLocalInt(oMod, sFile + "SRC" + IntToString(iRow), StringToInt(sSrc));
                }

                SetLocalString(GetModule(), sFile + IntToString(iRow), sACBonus);
        }

        return sACBonus;
}

int GetCachedModelSrc(string sFile, int iRow) {
        string sAC = GetCachedACBonus(sFile, iRow);
        if (sAC == "SKIP" || sAC == "FAIL")
                return 0;

        if(tlrCheckNew2da(sFile)) {
                return GetLocalInt(GetModule(), sFile + "SRC" + IntToString(iRow));
        }
        return 0;
}


void tlrStartChat(object oPC, object oModel = OBJECT_SELF) {
    DeleteLocalInt(oPC, "TLR_CHAT_VALUE");
    SetLocalObject(oPC, "TLR_CHAT_MODEL", oModel);
}

int tlrStopChat(object oPC) {
    DeleteLocalObject(oPC, "TLR_CHAT_MODEL");
    int nRet =  GetLocalInt(oPC, "TLR_CHAT_VALUE");
    DeleteLocalInt(oPC, "TLR_CHAT_VALUE");
    return nRet;
}

// Return TRUE if this code handled the chat message
int tlrDoPCChat(object oPC, string sChat) {
        object oModel = GetLocalObject(oPC, "TLR_CHAT_MODEL");
	if (!GetIsObjectValid(oModel))
		return FALSE;
	
        tlrDebug("PCCHAT - model = " + GetTag(oModel) + " sChat =" + sChat);

	object oOutput; // = oModel;
	//if (GetObjectType(oModel) != OBJECT_TYPE_CREATURE)
	//oOutput = oPC;
	
	int nVal = StringToInt(sChat);
	if (nVal != 0 || IntToString(nVal) == sChat) {
		AssignCommand(oModel, SpeakString("I heard " + IntToString(nVal)));
		//FloatingTextStringOnCreature("I heard " + IntToString(nVal), oOutput);
		SetLocalInt(oPC, "TLR_CHAT_VALUE", nVal);
	} else {
		SetLocalInt(oPC, "TLR_CHAT_VALUE", -1);
		AssignCommand(oModel, SpeakString("I did not catch that..."));
		//FloatingTextStringOnCreature("I did not catch that...", oOutput);
	}
	return TRUE;
}
void tlr_testlist(object oPC) {

    int j;
    int nCur = 1;
    for (j = 0; j < 260; j++ ) {
            nCur = tlrNextIn2DAfile(ITEM_APPR_ARMOR_MODEL_BELT, nCur, 260, 1);
            SendMessageToPC(oPC, IntToString(j) + " Belt = " + IntToString(nCur));

    }
/*

        string sAllowList = "1,3,5-8,10,15-20";
        string sDenyList = "7,17";


        int i;
        int nCur = 0;

        SendMessageToPC(oPC,"Testing forward:");
        for (i = 0; i < 15; i ++ ) {
                nCur = tlrGetNextIdx(nCur, 1, 21, sAllowList, sDenyList);
                SendMessageToPC(oPC, IntToString(i) + ": got index " + IntToString(nCur));
        }


        SendMessageToPC(oPC, "Testing backwards:");
        for (i = 0; i < 15; i ++ ) {
                nCur = tlrGetPrevIdx(nCur, 1, 21, sAllowList, sDenyList);
                SendMessageToPC(oPC, IntToString(i) + ": got index " + IntToString(nCur));
        }

        nCur = 0;
        SendMessageToPC(oPC, "Testing emtpy allow:");
        for (i = 0; i < 20; i ++ ) {
                nCur = tlrGetPrevIdx(nCur, 1, 21, "", sDenyList);
                SendMessageToPC(oPC, IntToString(i) + ": got index " + IntToString(nCur));
        }
        nCur = 9;
        SendMessageToPC(oPC, "Testing back and forth(should be 10,8,10,8):");
        for (i = 0; i < 4; i ++ ) {
                nCur = tlrGetNextIdx(nCur, 1, 21, sAllowList, sDenyList);
                SendMessageToPC(oPC, IntToString(i) + ": got index " + IntToString(nCur));
                nCur = tlrGetPrevIdx(nCur, 1, 21, sAllowList, sDenyList);
                SendMessageToPC(oPC, IntToString(i) + ": got index " + IntToString(nCur));
        }

        nCur = 16;
        SendMessageToPC(oPC, "Testing back and forth(should be 18,16,18,16:");
        for (i = 0; i < 4; i ++ ) {
                nCur = tlrGetNextIdx(nCur, 1, 21, sAllowList, sDenyList);
                SendMessageToPC(oPC, IntToString(i) + ": got index " + IntToString(nCur));
                nCur = tlrGetPrevIdx(nCur, 1, 21, sAllowList, sDenyList);
                SendMessageToPC(oPC, IntToString(i) + ": got index " + IntToString(nCur));
        }
*/
}
