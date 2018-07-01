// _inc_nwnx.nss

// master include for all NWNX functionality. 
// This should handle the case where NWNX is not available so that all the calling code
// does not need to check.

#include "_inc_data"
#include "nwnx_creature"
#include "nwnx_object"
#include "nwnx_item"


// CAMPAIGN DATABASEs                     * COORDINATE NAMES WITH SERVER ADMIN *
// DEVELOPMENT mode uses NBDE DB in which the following values are like "table names" for the database

// name of the database. contains list of Players by player name.
const string PLAYER_DATA = "PlayerData";
// TRACKS (for each pc): last campaign played, cpc status, elemental prefs, rebuke/turn undead, etc...
const string CHARACTER_DATA     = "CharacterData";

// UNUSED
// NAMES OF RECORDS IN THE NBDE CAMPAIGN DATABASE //
// Character locations in campaign.                             * DO NOT TOUCH *
//const string PC_LASTLOC         = "PCLoc"; // location
//const string PC_HP              = "CurrentHP"  ;        // int

// These were not (yet) defined in NWNXEE - assuming the number are the same...
const int VARIABLE_TYPE_INT                     = 1;
const int VARIABLE_TYPE_FLOAT                   = 2;
const int VARIABLE_TYPE_STRING                  = 3;
const int VARIABLE_TYPE_OBJECT                  = 4;
const int VARIABLE_TYPE_LOCATION                = 5;

int GetHaveNWNX() {
	return !GetLocalInt(GetModule(), "DEVELOPMENT");
}


string nwnxPrintVariable(object oObj, struct NWNX_Object_LocalVariable lv, int bValue = FALSE) {

        string sRet = "Name ";
        sRet += lv.key;
        sRet += " Type ";
        switch (lv.type) {
               case VARIABLE_TYPE_INT:       sRet += "Int";
               if (bValue) sRet += "(" + IntToString(GetLocalInt(oObj, lv.key))  + ")"; 
               break;
               case VARIABLE_TYPE_FLOAT:     sRet += "Float"; 
               if (bValue) sRet +=  "(" + FloatToString(GetLocalFloat(oObj, lv.key)) + ")"; 
               break;
               case VARIABLE_TYPE_STRING:    sRet += "String"; 
               if (bValue) sRet += "(" + GetLocalString(oObj, lv.key) + ")"; 
               break;
               case VARIABLE_TYPE_OBJECT:    sRet += "Object"; 
               if (bValue) sRet += "(" + ObjectToString(GetLocalObject(oObj, lv.key)) + ")"; 
               break; 
               case VARIABLE_TYPE_LOCATION:  sRet += "Location"; 
               if (bValue) sRet += "(in area " + GetName(GetAreaFromLocation(GetLocalLocation(oObj, lv.key))) + ")"; 
                       //sRet += "(" + LocationToString(GetLocalLocation(oObj, lv.key)) + ")"; 
               break;
        }
        return sRet;
}

void nwnxDeleteVariable(object oObj, struct NWNX_Object_LocalVariable lv) {

        //if (!GetIsVariableValid(lv)) return;

        switch (lv.type) {
               case VARIABLE_TYPE_INT:  DeleteLocalInt(oObj, lv.key);
               break;
               case VARIABLE_TYPE_FLOAT: DeleteLocalFloat(oObj, lv.key); 
               break;
               case VARIABLE_TYPE_STRING: DeleteLocalString(oObj, lv.key); 
               break;
               case VARIABLE_TYPE_OBJECT: DeleteLocalObject(oObj, lv.key); 
               break; 
               case VARIABLE_TYPE_LOCATION: DeleteLocalLocation(oObj, lv.key);
               break;
        }
}

// oObj = object who's variables to dump.  
// oPC = target of output
void nwnxDumpVariables(object oObj, object oPC, int bValue = FALSE) {

        // No NWNX
        if (!GetHaveNWNX())
                return;
        
        SendMessageToPC(oPC, "Dumping variables for " + GetName(oObj));
        int nMax = NWNX_Object_GetLocalVariableCount(oObj);
        int i;
        struct NWNX_Object_LocalVariable lv;
        for (i = 0; i < nMax; i ++) {
                lv =  NWNX_Object_GetLocalVariable(oObj, i);
                SendMessageToPC(oPC, IntToString(i) + ":" + nwnxPrintVariable(oObj, lv, bValue));
        }
}

void nwnxDeleteAllVariables(object oObj) {

        // No NWNX 
	if (!GetHaveNWNX()) {
                return;
        }

        int nMax = NWNX_Object_GetLocalVariableCount(oObj);
        int i;
        struct NWNX_Object_LocalVariable lv;
        for (i = 0; i < nMax; i ++) {
                lv = NWNX_Object_GetLocalVariable(oObj, i);
                nwnxDeleteVariable(oObj, lv);
        }
}

// Not needed in NWN:EE - this is a ini setting.
void NWNX_SetTMILimit (int nLimit) {
	if (!GetHaveNWNX()) {
                return;
        }
	//SetTMILimit(nLimit);
}

void NWNX_SetSoundset (object oCreature, int nSoundset) {
	if (!GetHaveNWNX()) {
                return;
        }
	 NWNX_Creature_SetSoundset(oCreature, nSoundset);
}

void NWNX_SetAbilityScore (object oCreature, int nAbility, int nValue) {
	if (!GetHaveNWNX()) {
                return;
        }
	NWNX_Creature_SetRawAbilityScore(oCreature, nAbility, nValue);
}

void NWNX_SetMaxHitPoints(object oCreature, int nHP) {
	if (!GetHaveNWNX()) {
                return;
        }
	NWNX_Object_SetMaxHitPoints (oCreature, nHP);
}

void NWNX_ModifySkillRank (object oCreature, int nSkill, int nValue) {
	if (!GetHaveNWNX()) {
                return;
        }	
	//ModifySkillRank(oCreature, nSkill, nValue);
        int nCur = GetSkillRank(nSkill, oCreature, TRUE);
        NWNX_Creature_SetSkillRank(oCreature, nSkill, nCur + nValue);
}

void NWNX_SetACNaturalBase (object oCreature, int nAC) {
	if (!GetHaveNWNX()) {
                return;
        }
	NWNX_Creature_SetBaseAC(oCreature, nAC);
        //SetACNaturalBase(oCreature, nAC);
}

void NWNX_SetCurrentHitPoints(object oCreature, int nHP) {

	if (!GetHaveNWNX()) {
                int nCur = GetCurrentHitPoints(oCreature);
                if (nHP < nCur) {
                        // effect damage
                        int nDam = nCur - nHP;
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDam, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY), oCreature);
                } else if (nHP > nCur) {
                        //effect heal 
                        int nHeal = nHP - nCur;
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHeal), oCreature);
                }
                return;
        }

        if (GetIsObjectValid(oCreature))
                NWNX_Object_SetCurrentHitPoints(oCreature, nHP); 

}


void  NWNX_SetItemWeight (object oItem, int nTenthLbs) {

	if(!GetHaveNWNX()) {
		int pounds = FloatToInt(nTenthLbs/10.0);
		itemproperty ip;
		while(pounds) {
			if(pounds>=750) {
				pounds -=750;
				ip = ItemPropertyWeightIncrease(12);
			} else if(pounds>=500) {
				pounds -=500;
				ip = ItemPropertyWeightIncrease(11);
			} else if(pounds>=250) {
				pounds -=250;
				ip = ItemPropertyWeightIncrease(10);
			} else if(pounds>=100) {
				pounds -=100;
				ip = ItemPropertyWeightIncrease(5);
			} else if(pounds>=50) {
				pounds -=50;
				ip = ItemPropertyWeightIncrease(4);
			} else if(pounds>=30) {
				pounds -=30;
				ip = ItemPropertyWeightIncrease(3);
			} else if(pounds>=15) {
				pounds -=15;
				ip = ItemPropertyWeightIncrease(2);
			} else if(pounds>=10) {
				pounds -=10;
				ip = ItemPropertyWeightIncrease(1);
			} else if(pounds>=5) {
				pounds -=5;
				ip = ItemPropertyWeightIncrease(0);
			} else if(pounds>=4) {
				pounds -=4;
				ip = ItemPropertyWeightIncrease(9);
			} else if(pounds>=3) {
				pounds -=3;
				ip = ItemPropertyWeightIncrease(8);
			} else if(pounds>=2) {
				pounds -=2;
				ip = ItemPropertyWeightIncrease(7);
			} else if(pounds>=1) {
				pounds -=1;
				ip = ItemPropertyWeightIncrease(6);
			}
			AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
		}
	} else  {
		NWNX_Item_SetWeight(oItem, nTenthLbs);
	}
}

// This might not work if HE does not have iprops for all the feats that use this code.
int nwnxGetIprpForFeat(int nFeat) {
        int i = 0;
        int nMax = 225;
        if (nFeat < 0) return -1;

        string sVal;
        while (i <= nMax) {
                sVal = Get2DAString("iprp_feats", "FeatIndex", i);
                if (sVal != "****") {
                         if (StringToInt(sVal) == nFeat) {
                                return i;
                         }                       
                }
                i ++;
        }

        return -1;
}

void NWNX_AddKnownFeat(object oPC, int nFeat, int nIPFeat = -1, int nLevel = -1) {

        if (nFeat != -1 && GetHasFeat(nFeat,oPC)) {
                return;
        }
        if (GetHaveNWNX()) {
                if (nFeat == -1 && nIPFeat != -1){
                        nFeat = StringToInt(Get2DAString("iprp_feats", "FeatIndex",nIPFeat));
                }
                if (!NWNX_Creature_GetKnowsFeat(oPC, nFeat)) {
                        if (nLevel != -1) {
                                NWNX_Creature_AddFeatByLevel(oPC, nFeat, nLevel);
                        } else {
                                NWNX_Creature_AddFeat(oPC, nFeat);
                        }
                }
                return;
        }

        if (nIPFeat == -1) {
                nIPFeat = nwnxGetIprpForFeat(nFeat);
        }
        if(nIPFeat < 0) {
                WriteTimestampedLogEntry("Unable to find iprp for feat " + IntToString(nFeat));
                return;
        }

        object oSkin = SkinGetSkin(oPC);
        itemproperty ip = ItemPropertyBonusFeat(nIPFeat);
        IPSafeAddItemProperty(oSkin,ip,0.0,X2_IP_ADDPROP_POLICY_KEEP_EXISTING,FALSE,FALSE);

}

void NWNX_RemoveKnownFeat(object oPC, int nFeat, int nIPFeat = -1, int nLevel = -1) {

        if (nFeat != -1 && !GetHasFeat(nFeat,oPC)) {
                return;
        }
        if (GetHaveNWNX()) {
                if (nFeat == -1 && nIPFeat != -1){
                        nFeat = StringToInt(Get2DAString("iprp_feats", "FeatIndex",nIPFeat));
                }		
                if (NWNX_Creature_GetKnowsFeat(oPC, nFeat)) {
                                NWNX_Creature_RemoveFeat(oPC, nFeat);
		}
                return;
        }

	/* 
	   No real non NWNX version of this one 
	 */

}

int NWNX_GetPCInitialized(object oPC) {
	string sCharID = GetPCID(oPC);
	
	if(GetHaveNWNX()) {
		NWNX_SqlExecPrepared("SELECT initialized FROM characters WHERE character_id=?;", sCharID);
                if (NWNX_SQL_ReadyToReadNextRow()) { 
                        NWNX_SQL_ReadNextRow();
                        int bInit = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
                        return !bInit;
                }    
	}
	return GetLocalInt(oPC, "initialized");
}

void NWNX_SetPCInitialized(object oPC) {
	string sCharID = GetPCID(oPC);
	
	if(GetHaveNWNX()) {
                dbstr("Setting Initialized for PC " + GetName(oPC));
		NWNX_SqlExecPrepared("UPDATE characters SET initialized=1 WHERE character_id=?;" , sCharID);
		return;
	}
	
	SetLocalInt(oPC, "initialized", 1);
}

void NWNX_SaveGameTime(string campaign_id) {

        if(!GetHaveNWNX()) {
                return;
        }

        if(!GetLocalInt(GetModule(), "MOD_TIME_RESTORED")) {
                WriteTimestampedLogEntry("Module Save time - MOD_TIME_RESTORED unset!!!");
                return;
        }

        struct DATETIME time;
        time.year   = GetCalendarYear();
        time.month  = GetCalendarMonth();
        time.day    = GetCalendarDay();
        time.hour   = GetTimeHour();
        time.minute = GetTimeMinute();
        time.second = GetTimeSecond();  
        //WriteTimestampedLogEntry("Module Save time: yr " + IntToString(time.year) + " month " 
        //                             + IntToString(time.month) + " day " + IntToString(time.day) + " "
        //                             + IntToString(time.hour) + ":" + IntToString(time.minute));  
        string game_time   = ConvertDateTimeToTimeStamp(time);
	NWNX_SqlExecPrepared("UPDATE campaigns SET time_game=?, campaign_id=?;" , game_time, campaign_id);
}

void NWNX_RestoreGameTime(string campaign_id) {

        if(!GetHaveNWNX()) {
                return;
        }

        struct DATETIME time;
        object oMod     = GetModule();
        int bFail       = FALSE;
    
        // try to get current time
        NWNX_SqlExecPrepared("SELECT epoch_game, time_game FROM campaigns WHERE campaign_id=?;", campaign_id);
        if(NWNX_SQL_ReadyToReadNextRow()) {
                NWNX_SQL_ReadNextRow();
                // first set the epoch
                //time  = ConvertTimeStampToDateTime(GetStringLeft(GetLocalString(oMod,"NWNX_ODBC2_FetchRow"),20));
                time  = ConvertTimeStampToDateTime(NWNX_SQL_ReadDataInActiveRow(0));
                if(time.year) {
                        SetLocalInt(oMod,"EPOCH_YEAR",time.year);
                        SetLocalInt(oMod,"EPOCH_MONTH",time.month);
                        SetLocalInt(oMod,"EPOCH_DAY",time.day);
                        SetLocalInt(oMod,"EPOCH_HOUR",time.hour);

                        // next gather game time
                        //time = ConvertTimeStampToDateTime(GetStringRight(GetLocalString(oMod,"NWNX_ODBC2_FetchRow"),20));
                        time = ConvertTimeStampToDateTime(NWNX_SQL_ReadDataInActiveRow(0));

                        // restore game time
                        SetCalendar(time.year, time.month, time.day);
                        SetTime(time.hour, time.minute, 0, 0);
                        WriteTimestampedLogEntry("Restored time: yr " + IntToString(time.year) + " month " 
                           + IntToString(time.month) + " day " + IntToString(time.day)  + " "
                           + IntToString(time.hour) + ":" + IntToString(time.minute));   
                } else {
                        bFail   = TRUE;
                }
        } else {
                bFail = TRUE;
        }

        // failed to get time from DB... so we must set it
        if(bFail) {
                WriteTimestampedLogEntry("Failed to restore time from Database. Using current");
                time.year   = GetCalendarYear();
                time.month  = GetCalendarMonth();
                time.day    = GetCalendarDay();
                time.hour   = GetTimeHour();
                time.minute = GetTimeMinute();
                time.second = GetTimeSecond();

                SetLocalInt(oMod,"EPOCH_YEAR",time.year);
                SetLocalInt(oMod,"EPOCH_MONTH",time.month);
                SetLocalInt(oMod,"EPOCH_DAY",time.day);
                SetLocalInt(oMod,"EPOCH_HOUR",time.hour);

                WriteTimestampedLogEntry("Module time: yr " + IntToString(time.year) + " month " 
                   + IntToString(time.month) + " day " + IntToString(time.day)  + " "
                   + IntToString(time.hour) + ":" + IntToString(time.minute));  
                string epoch_time   = ConvertDateTimeToTimeStamp(time);
		NWNX_SqlExecPrepared("UPDATE campaigns SET epoch_game=?,time_game=? WHERE campaign_id=?;", epoch_time,epoch_time,campaign_id);
        }

        SetLocalInt(oMod, "MOD_TIME_RESTORED", TRUE);
       
        // special initialization which facilitate tracking the very moment a new hour has begun
        //if(time.minute==0)
        //    SetLocalInt(oMod,"MOD_HOUR", time.hour-1);
        //else
        //    SetLocalInt(oMod,"MOD_HOUR", time.hour);
        //
}

void NWNX_SetAddCDKey(object oPC) {

	if(GetHaveNWNX()) {
		NWNX_SqlExecPrepared("INSERT INTO player_misc (player_id,label,value) VALUES (?, 'CDKEY_ADD', 'true');", NWNX_GetPlayerID(oPC));
	
	} else {

		// THis is currently not ported - not worrying about CD keys when not runnign the real server
	  /*
	    string sStoredKey = NBDE_GetCampaignString(PLAYER_DATA, GetPCPlayerName(oPC));
	    if (sStoredKey != "") {
	    int nLength =  GetStringLength(sStoredKey);
	    if (nLength > 65) // allow 7 keys max SET-key-key-key-key-key-key-key   SET/ADD + 7 spacers + 7x8 keys = 66
	    {
            SendMessageToPC(oPC, PINK+"You have already associated seven (7) CD Keys with this player account."
	    +" If you need to use different CD Keys, contact a DM."
	    );
            return;
	    }
	    }
	    
	    string sKeys = "ADD" + GetStringRight(sStoredKey, GetStringLength(sStoredKey) - 3);//mark as adding
	    NBDE_SetCampaignString(PLAYER_DATA, GetPCPlayerName(oPC), sKeys);
	  */	
		
	}
}


void NWNX_CorpseSaveLocationToTaker(object oTaker, object oCorpseItem)
{
    // NWNX
    if(MODULE_NWNX_MODE)
    {
        string character_id = GetLocalString(oCorpseItem,"CORPSE_PCID");
        string taker_id     = GetPCID(oTaker);
        string type         = "CORPSE";
        string area_id      = "inventory";
        string position     = taker_id;
        string facing       = "0";
        string campaign_id  = NWNX_GetCampaignID();

        // commit to DB
	string sQuery =  "INSERT INTO character_locations (character_id, campaign_id, type, area_id, position, facing) "
		+"VALUES(?,?,'CORPSE','inventory',?,'0') "
		+"ON DUPLICATE KEY UPDATE area_id=VALUES(area_id), position=VALUES(position), facing=VALUES(facing);";
	NWNX_SqlExecPrepared(sQuery, character_id, campaign_id, position);
        
        // taker is carrying this corpse
        NWNX_StoreCampaignValue("corpse_holder", taker_id, campaign_id, character_id);

    } else {
	    // Not implemented for non NWNX 
    }
}


// This is used to change domains from one to the other. nOldDomain may be -1 to simply add the domain at the given index.
//  
void nwnxChangeDomain(object oTarget, int nOldDomain, int nNewDomain, int nIndex) {

        // Assumes domains all grant feats
        int nFindFeat = -1;

        if (nOldDomain != -1) {
                nFindFeat = StringToInt(Get2DAString("domains", "GrantedFeat", nOldDomain));
        }

        // Get new granted feat. 
        int nNewFeat = StringToInt(Get2DAString("domains", "GrantedFeat", nNewDomain));

        //SendMessageToPC(oTarget, "ChangeDomain  old " + IntToString(nOldDomain) + " feat = " + IntToString(nFindFeat));
        //SendMessageToPC(oTarget, "ChangeDomain  new " + IntToString(nNewDomain) + " feat = " + IntToString(nNewFeat));

        // Set the new domain        
        NWNX_Creature_SetClericDomain(oTarget, nIndex, nNewDomain);
        // find the level the PC first became a cleric
        int nHD = GetHitDice(oTarget);
        int nLevel = 1;

        while(nLevel <= nHD) {
                if(NWNX_Creature_GetClassByLevel(oTarget, nLevel) == CLASS_TYPE_CLERIC) {
                    break;
                }
                ++nLevel;
        }
        //SendMessageToPC(oTarget, "ChangeDomain - got first cleric level = " + IntToString(nLevel));

        // TODO - what about feats granted at levels?  If we only allow this for clerics at start it should be okay. 
        // But Hillsedge has no restrictions on adding classes but the level up code should handle that...

        // If nFindFeat > 0 we have a feat to replace not just add 
        // But only if newfeat is valid.
        // No longer have ability to replace feats at index so just remove if needed.
        if (nFindFeat != -1) { 
                NWNX_Creature_RemoveFeat(oTarget, nFindFeat);
        }

        if (nNewFeat != -1) {
                NWNX_Creature_AddFeatByLevel(oTarget, nNewFeat, nLevel);
        }
} 

int nwnxGetClericDomain(object oCreature, int nIndex) {

        if (GetHaveNWNX()) {
                int nDom = NWNX_Creature_GetClericDomain(oCreature, nIndex);
                //SendMessageToPC(oCreature, "found domain " + IntToString(nIndex) + " = " + IntToString(nDom));
                return nDom;
        }
/* 
        // this is broken -  needs to map to domain.2da row numbers not feats....
        // Look up the domains by feat - this is a hack - it's dependent on the numerical order
        int n1 = -1;
        int n2 = -1;
        int x;
        for (x = 306; x < 326; x ++) {
            if (GetHasFeat(x, oCreature)) {
                if (n1 != -1)
                     n2= x;
                else
                     n1 = x;
            }
        }
        for (x = 1998; x < 2001; x ++) {
            if (GetHasFeat(x, oCreature)) {
               if (n1 != -1)
                     n2= x;
                else
                     n1 = x;
            }

        }
        //SendMessageToPC(oCreature, "found domain " + IntToString(n1) + " and " + IntToString(n2));
        if (nIndex == 1)
            return n1;

        return n2;
        */
        return -1;
}

void nwnxSetClericDomain(object oCreature, int nIndex, int nDomain) {

        if (GetHaveNWNX()) {

                // First check that this is not set in one of the slots.
                int nD1 = NWNX_Creature_GetClericDomain(oCreature, 1);
                int nD2 = NWNX_Creature_GetClericDomain(oCreature, 2);

                //SendMessageToPC(oCreature, "SetClericDomain: Got domains (1 = " + IntToString(nD1) + ") (2 = " + IntToString(nD2) + ")");
                if (nD1 == nDomain || nD2 == nDomain) {
                        //SendMessageToPC(oCreature, "Already have domain " + IntToString(nDomain));
                        return;
                }
                int nOld;
                if (nIndex == 1) {
                        nOld = nD1;
                } else if (nIndex == 2) {
                        nOld = nD2;
                } 

                nwnxChangeDomain(oCreature, nOld, nDomain, nIndex); 
        }

}

