////////////////////////////////////////////////////////////////////////////////
//
//  Olander's Realistic Systems - HTF System - Fishing
//  ohtf_fishing
//  Modified by Don Anderson
//  Re-Modified by Meaglyn
//  dandersonru@msn.com
//
//  Original Script by Nouny (x@nouny.com)
//      Thanks for a nice base script!
//
//  <meaglyn> Original documentation - some may not apply
//
//  Placed in the Module On Activate Item Event
//
//  You MUST equip the Fishing Rod.
//
//  You also must be in a body of water...basically
//  a water source trigger that can be used for filling
//  the Canteen or Fishing.
//
//  NOTE: You will get a message when you enter one
//        of these triggers letting you know you can
//        fish or fill the Canteen.
//
//  The Fresh Fish can be cooked on the campfire for roasted
//  fish you can eat =).
//
//
////////////////////////////////////////////////////////////////////////////////

#include "x2_inc_switches"
#include "tb_inc_color"

string NOFISHINGHERE    = "Find a Lake or Stream to fish from.";

// Percentage chance to break fishing line and have to start over.
int BREAK_CHANCE = 25;


// From  "hfc_inc"
int hfcDoFishingCheck(object oPC, int bReport, int nDC) {

        int nSkill = 1 + GetAbilityModifier(ABILITY_WISDOM, oPC); // skillGetSkillRank(SKILL_S_FISHING, oPC);
    if (nSkill > 5) nSkill = 5;

        int nRoll  = d20(); //The roll

        int nTotal = nRoll + nSkill; //Total roll
        int bSuccess = nTotal >= nDC;

        //Tell Player Die Roll
        if (bReport) {
                string sTotal = ColorString(IntToString(nTotal), TEXT_COLOR_GREY);
                string sRoll = ColorString(IntToString(nRoll), TEXT_COLOR_GREY);
        string sSkill = ColorString(IntToString(nSkill), TEXT_COLOR_GREY);
                string sFinal = "Fishing Skill " + sSkill + " Roll : "
            +sRoll+" vs. DC " + IntToString(nDC) + " = "+sTotal;
//                FloatingTextStringOnCreature(sFinal, oPC, FALSE);
        }

        return bSuccess;

}

void ActionCatchFish(string sRef, location lLoc, string sLbs) {
        object oFish = CreateObject(OBJECT_TYPE_ITEM, sRef, lLoc, TRUE);
    if (GetIsObjectValid(oFish) && sLbs != "") {
        SetDescription(oFish, GetDescription(oFish) + "\nWeight: " + sLbs);
        SetName(oFish, GetName(oFish) + ", " + sLbs);
    }
}

string hfcGetFishMessage() {
        switch (Random(10)) {
               case 0: return  "*You have hooked something*";
               case 1: return  "*You have hooked something*";
               case 2: return  "*You have hooked something*";
               case 3: return "*You have hooked something*";
               case 4: return "*You have hooked something*";
               case 5: return "*You have hooked something*";
               case 6: return "*You have hooked something*";
               case 7: return "*You have hooked something*";
               case 8: return "*You have hooked something*";
               case 9: return "*You have hooked something*";
        }
        return "Not getting away this time.";
}

string hfcGetSnappedMsg() {
        switch(Random(10)) {
                case 0: return "*The line snapped*";
                case 1: return "*The line snapped*";
                case 2: return "*The line snapped*";
                case 3: return "*The line snapped*";
                case 4: return "*The line snapped*";
                case 5: return "*The line snapped*";
                case 6: return "*The line snapped*";
                case 7: return "*The line snapped*";
                case 8: return "*The line snapped*";
                case 9: return "*The line snapped*";
        }
         return "*The line snapped*";
}

string hfcGetSuccessMsg(string sName = "fish", string sLbs = "") {

    string sRet = "You caught a ";
    if (sLbs != "") {
        if (GetStringRight(sLbs, 1) == "s") {
            sLbs = GetStringLeft(sLbs, GetStringLength(sLbs) - 1);
        }
        sRet += sLbs + " ";
    }
    sRet += sName + "!";
        return ColorString(sRet, TEXT_COLOR_RED);
}

string getOuncesToString(int nOunces) {

    float fPounds = nOunces/16.0;

    if (fPounds == 1.0) {
        return "1 lb";
    }

    return FloatToString(fPounds, 4, 1) + " lbs";
}


// return a random weight for the given fish type (by blueprint resref) in ounces
int getWeightForFish(string sRef) {

    if (sRef == "tt_bluegill") {
        // Bluegill 0.3 - 4 lbs
        // 5 - 64 ounzes
        int ret = Random(60) + 5;
        return ret;
    }

    if (sRef == "tt_bluegill001") {
        // Bullhead 0.3 - 3 lb
        /// 5 - 48 ounces
        int ret = Random(44) + 5;
        return ret;
    }

    if (sRef == "tt_mfish") {
        // Smallmouth Bass  1 - 12 lb
        // 16 - 192 ounces
        int ret = Random(12) + 1;
        return ret * 16;
    }

    if (sRef == "tt_bluegill002") {
        //Yellow Perch  0.4 - 4 lb
        // 6 - 64 ounces
        int ret = Random(59) + 6;
        return ret;
    }

    if (sRef == "tt_mfish001" ) {
        //Pike      5 - 50 lb
        // 80 - 800 ounces
        int ret = Random(46) + 5;
        return ret * 16;
    }

    if (sRef == "tt_mfish002" ) {
        // Rainbow Trout    0.5 - 6 lb
        // 7 - 96 ounces
        int ret = Random(90) + 7;
        return ret;
    }

    if (sRef == "tt_lfish") {
        // Lake Trout   10 - 100 lb
        // 160 - 1600 ounces
        int ret = Random(91) + 10;
        return ret * 16;
    }

    if (sRef == "tt_mfish003") {
        // Walleye      1 - 22 lb
        // 16 - 352 ounces
        int ret = Random(22) + 1;
        return ret * 16;
    }

    return  Random(60) + 5;

}

int  GetFishingDC(string sWBody) {

    // This one is not needed as it's the default return value
    //if (sWBody == "Stream" || sWBody == "Slow Stream") {
    //  return 15;
    //}
    if (sWBody == "Fast Stream") {
        return 20;
    } else if (sWBody == "Lake" || sWBody == "Pond" ) {
        return 12;
    } else if (sWBody == "Forest Stream" ) {
        return 22;
    }
    return 15;
}


void doFishing(object oPC, string sWBody, location lLoc, int bReport, int nDC) {

    if (nDC <= 0) {
        nDC = GetFishingDC(sWBody);
    }

    // Do the skill check
        int bSuccess = hfcDoFishingCheck(oPC, TRUE, nDC);

        if (!bSuccess)  {
        // Chance to break - if you fail the skill check only.
        if (Random(100) < BREAK_CHANCE){
            string sSnap = hfcGetSnappedMsg();
            AssignCommand(oPC, ActionSpeakString(ColorString(sSnap, TEXT_COLOR_RED)));
        } else {
            string sNothing = "*Nothing hooked on this cast*";
            AssignCommand(oPC, ActionSpeakString(sNothing));
        }
                AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_TAUNT));
                return;
        }

      //Message Player Hooked Something
        AssignCommand(oPC, ActionSpeakString(ColorString(hfcGetFishMessage(), TEXT_COLOR_GREY)));

    AssignCommand(oPC, ActionPlayAnimation (ANIMATION_FIREFORGET_SALUTE));
        AssignCommand(oPC, ActionPlayAnimation (ANIMATION_FIREFORGET_SALUTE));

        int nCatch = d100(); //ok, what did the PC catch?
    string sName;
    string sRef;
    int nAnim = ANIMATION_FIREFORGET_VICTORY3;
    string sMsg = "";

        //PC gets a loot bag!
        if (nCatch >= 100) {
                if(d2()) {
                        AssignCommand(oPC, ActionSpeakString("*You think you hooked a log*"));
                } else {
                        AssignCommand(oPC, ActionSpeakString("*You hooked something lifeless*"));
                }
        AssignCommand(oPC, ActionWait(1.0));
                AssignCommand(oPC, PlayVoiceChat(VOICE_CHAT_CHEER));

        nAnim = ANIMATION_FIREFORGET_VICTORY1;
        sRef =  "tres_goldlow001";
        sMsg = ColorString("I drug out a Bag of Gold!", TEXT_COLOR_RED);
        } else {

                 /******************************************************************************/
                 //:: STREAM FISHING
             // Adjust the sRef settings here for what is in the module.
        if (sWBody == "Stream" || sWBody == "Slow Stream") {
            if (nCatch > 90) {
                sName = "Pike";
                sRef = "tt_mfish001";
            } else if (nCatch > 80) {
                sName = "Bullhead";
                sRef = "tt_bluegill001";
            } else if (nCatch > 60) {
                sName = "Yellow Perch";
                sRef = "tt_bluegill002";
            } else {
                sName = "Bluegill";
                sRef = "tt_bluegill";
            }

            /*
            if (nCatch >= 21) {
                sName = "Trout";
                sRef = "tt_fish"; //"rawtrout";
            } else {
                sName = "Salmon";
                sRef = "tt_fish"; // "rawsalmon";
            }
            */
        } else if (sWBody == "Fast Stream") {
            if (nCatch > 60 && GetIsDay() && GetWeather(GetArea(oPC)) == WEATHER_CLEAR) {
                sName = "Rainbow Trout";
                sRef = "tt_mfish002";
            } else {
                sName = "Bluegill";
                sRef = "tt_bluegill";
            }

            /*
            if (nCatch >= 21) {
                sName = "Trout";
                sRef = "tt_fish"; //"rawtrout";
            } else {
                sName = "Salmon";
                sRef = "tt_fish"; // "rawsalmon";
            }
            */
        } else if (sWBody == "Forest Stream") {
            if (nCatch < 51 && GetIsDay() && GetWeather(GetArea(oPC)) == WEATHER_CLEAR) {
                sName = "Rainbow Trout";
                sRef = "tt_mfish002";
            } else {
                sName = "Smallmouth Bass";
                sRef = "tt_mfish";
            }

            /*
            if (nCatch >= 21) {
                sName = "Trout";
                sRef = "tt_fish"; //"rawtrout";
            } else {
                sName = "Salmon";
                sRef = "tt_fish"; // "rawsalmon";
            }
            */
        } else if (sWBody == "Lake") {
            /******************************************************************************/
            //:: LAKE FISHING
            if (nCatch > 90) {
                if (GetIsNight() && GetWeather(GetArea(oPC)) == WEATHER_RAIN) {
                    sName = "Walleye";
                    sRef = "tt_mfish003";
                } else {
                    sName = "Yellow Perch";
                    sRef = "tt_bluegill002";
                }
            } else if (nCatch > 80) {
                sName = "Pike";
                sRef = "tt_mfish001";
            } else if (nCatch > 70) {
                sName = "Lake Trout";
                sRef = "tt_lfish";
            } else if (nCatch > 40) {
                sName = "Bluegill";
                sRef = "tt_bluegill";
            } else {
                sName = "Yellow Perch";
                sRef = "tt_bluegill002";
            }

            /*
            //Trout Fishing from a Lake
            if (nCatch >= 51) {
                sName = "Trout";
                sRef = "rawtrout";
            } else if (nCatch >= 21) {
                sName = "Bass";
                sRef = "rawbass";
            } else {
                                sName = "Pike";
                                sRef = "rawpike";
            }
            */

        } else if (sWBody == "Pond") {

            if (nCatch > 70) {
                sName = "Bullhead";
                sRef = "tt_bluegill001";
            } else if (nCatch > 30) {
                sName = "Yellow Perch";
                sRef = "tt_bluegill002";
            } else {
                sName = "Bluegill";
                sRef = "tt_bluegill";
            }

        } else if (sWBody == "Salt Water") {
                /******************************************************************************/
                //:: SALT WATER FISHING

                //flounder
            if (nCatch >= 71) {
                sName = "Flounder";
                sRef = "rawflounder";
            } else if (nCatch >= 51) {
                sName = "BlueFish";
                sRef = "rawfish";
            } else if (nCatch >= 41) {
                sName = "Tuna";
                sRef = "rawtuna";
            } else if (nCatch >= 21) {
                sName = "Crab";
                sRef = "rawcrab";
            } else if (nCatch <= 20) {
                sName = "Lobster";
                sRef = "rawlobster";
            }
        }

    }
    string sLbs = "";
    if (sMsg == "") {
        int nWeight = getWeightForFish(sRef);
        sLbs =  getOuncesToString(nWeight);
        sMsg = hfcGetSuccessMsg(sName, sLbs);
    }
    AssignCommand(oPC, ActionSpeakString(sMsg));
    AssignCommand(oPC, ActionPlayAnimation (nAnim));
    AssignCommand(oPC, ActionCatchFish(sRef, lLoc, sLbs));
}

void main() {

        int nEvent = GetUserDefinedItemEventNumber();
        if (nEvent != X2_ITEM_EVENT_ACTIVATE) return;

        object oPC          = GetItemActivator();
        object oItem        = GetItemActivated();
        string sItemTag     = GetTag(oItem);
        object oWeapon      = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
        string sWeaponTag   = GetTag(oWeapon);

    // Not equipped - I don't think we can get here - if it's equippable you can't use the power if not equipped
        //if (sWeaponTag != "fishingrod") {
        //    SendMessageToPC(oPC, "You must equip the fishing rod to use it.");
        //    return;
        //}

        location lLoc       = GetLocation(oPC);
        string sWBody       = GetLocalString(oPC,"WATERBODY");//Set when entering and exiting Water Source Triggers
        int nWSource        = GetLocalInt(oPC,"WSOURCE");//Set when entering and exiting Water Source Triggers
    int bFishing        = GetLocalInt(oPC, "WFISHING");
    object oTrigger     = GetLocalObject(oPC, "WATERTRIGGER");
    int nDC = 0;
        if (GetIsObjectValid(oTrigger)) {
        nDC = GetLocalInt(oTrigger, "FISHING_DC");
    }

       //The Player DID NOT enter the water trigger
        if (!nWSource) {
                SendMessageToPC(oPC,NOFISHINGHERE);
                return;
        }

        // Water source does not allow fishing.
        if (!bFishing) {
                SendMessageToPC(oPC,NOFISHINGHERE);
                return;
        }

        //Put it all in the action queue
    AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionPlayAnimation (ANIMATION_LOOPING_TALK_PLEADING, 1.0, 3.0));
        AssignCommand(oPC, ActionPlayAnimation (ANIMATION_FIREFORGET_SALUTE));
        AssignCommand(oPC, ActionPlayAnimation (ANIMATION_FIREFORGET_SALUTE));
        AssignCommand(oPC, ActionWait(3.0));
        AssignCommand(oPC, ActionPlayAnimation (ANIMATION_FIREFORGET_SALUTE));
        AssignCommand(oPC, ActionWait(3.0));
        //AssignCommand(oPC, ActionPlayAnimation (ANIMATION_FIREFORGET_SALUTE));
    AssignCommand(oPC, ActionDoCommand(doFishing(oPC, sWBody, lLoc, TRUE, nDC)));

}

