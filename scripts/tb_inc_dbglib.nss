// tb_inc_dbglib.nss
// CREATED BY: meaglyn
// DATE      : 5/7/13
// These are the main routines for handlng #dbg chat commands
// and other routines used by debug tools.
// It's broken out of the basic debug include so that that can be included
// be every thing as needed and this can include other system includes.


#include "x3_inc_skin"
#include "00_debug"
#include "tb_inc_string"
#include "tb_inc_util"
#include "_inc_xp"
//#include "tb_inc_persist"
//#include "poison_inc_util"

void dbg_dumpCreature(object oTarget, int nLog, object oPC);
void dbg_dumpArea(object oArea, location lTarget, object oPC, int nLog = FALSE);
void dbg_dumpModule(int nLog, object oPC);

// These were from Jassper's debug code
//////////////////////////////////////////////////////////////////////
// This function will return the string representation
// of the Object Type
//////////////////////////////////////////////////////////////////////
string LookUpObjectType(int iType);


//////////////////////////////////////////////////////////////////////
// This function returns the string representation of each CLASS_TYPE*.
// If bAbbrev is TRUE it returns abbreviated format.
// Contributed by Axe Murderer
//////////////////////////////////////////////////////////////////////
string GetClassString(int iClassType,int bAbbrev = FALSE);

//////////////////////////////////////////////////////////////////////
// This function returns the string representation
// Of the area type AREA_ABOVEGROUND or AREA_UNDERGROUND
//////////////////////////////////////////////////////////////////////
string Area_AorU(object oArea);

//////////////////////////////////////////////////////////////////////
// This function returns the string representation
// of AREA_NATURAL or AREA_ARTIFICIAL
//////////////////////////////////////////////////////////////////////
string Area_NorA(object oArea);

//////////////////////////////////////////////////////////////////////
// This function returns the string representation
// of oObject Alignment
//////////////////////////////////////////////////////////////////////
string GetAlignString(object oObject);

// Dump a list of all the effects on oPC.
void dbgDumpCreatureEffects (object oPC);


string LookUpObjectType(int iType) {
    string sSend;
    switch(iType) {
        case OBJECT_TYPE_CREATURE:  return "OBJECT_TYPE_CREATURE";
        case OBJECT_TYPE_ITEM:      return "OBJECT_TYPE_ITEM";
        case OBJECT_TYPE_TRIGGER:   return "OBJECT_TYPE_TRIGGER";
        case OBJECT_TYPE_DOOR:      return "OBJECT_TYPE_DOOR";
        case OBJECT_TYPE_AREA_OF_EFFECT:    return "OBJECT_TYPE_AREA_OF_EFFECT";
        case OBJECT_TYPE_WAYPOINT:  return "OBJECT_TYPE_WAYPOINT";
        case OBJECT_TYPE_PLACEABLE: return "OBJECT_TYPE_PLACEABLE";
        case OBJECT_TYPE_STORE:     return "OBJECT_TYPE_STORE";
        case OBJECT_TYPE_ENCOUNTER: return "OBJECT_TYPE_ENCOUNTER";
        }
    return "OBJECT_TYPE_ALL or OBJECT_TYPE_INVALID";
}
string GetClassString(int iClassType,int bAbbrev = FALSE) {
    switch( iClassType) {
        case CLASS_TYPE_ABERRATION:       return (bAbbrev ? "Abb"  : "Abberration");
        case CLASS_TYPE_ANIMAL:           return (bAbbrev ? "Anml" : "Animal");
        case CLASS_TYPE_ARCANE_ARCHER:    return (bAbbrev ? "AA"   : "Arcane Archer");
        case CLASS_TYPE_ASSASSIN:         return (bAbbrev ? "Assn" : "Assassin");
        case CLASS_TYPE_BARBARIAN:        return (bAbbrev ? "Barb" : "Barbarian");
        case CLASS_TYPE_BARD:             return (bAbbrev ? "Bard" : "Bard");
        case CLASS_TYPE_BEAST:            return (bAbbrev ? "Bst"  : "Beast");
        case CLASS_TYPE_BLACKGUARD:       return (bAbbrev ? "BG"   : "Black Guard");
        case CLASS_TYPE_CLERIC:           return (bAbbrev ? "Clrc" : "Cleric");
        case CLASS_TYPE_COMMONER:         return (bAbbrev ? "Cmnr" : "Commoner");
        case CLASS_TYPE_CONSTRUCT:        return (bAbbrev ? "Cnst" : "Construct");
        case CLASS_TYPE_DIVINECHAMPION:   return (bAbbrev ? "CT"   : "Champion of Torm");
        case CLASS_TYPE_DRAGON:           return (bAbbrev ? "Drgn" : "Dragon");
        case CLASS_TYPE_DRAGONDISCIPLE:   return (bAbbrev ? "RDD"  : "Red Dragon Disciple");
        case CLASS_TYPE_DRUID:            return (bAbbrev ? "Dru"  : "Druid");
        case CLASS_TYPE_DWARVENDEFENDER:  return (bAbbrev ? "DD"   : "Dwarven Defender");
        case CLASS_TYPE_ELEMENTAL:        return (bAbbrev ? "Ele"  : "Elemental");
        case CLASS_TYPE_FEY:              return (bAbbrev ? "Fey"  : "Fey");
        case CLASS_TYPE_FIGHTER:          return (bAbbrev ? "Ftr"  : "Fighter");
        case CLASS_TYPE_GIANT:            return (bAbbrev ? "Gnt"  : "Giant");
        case CLASS_TYPE_HARPER:           return (bAbbrev ? "HS"   : "Harper Scout");
        case CLASS_TYPE_HUMANOID:         return (bAbbrev ? "Humn" : "Humanoid");
        case CLASS_TYPE_MAGICAL_BEAST:    return (bAbbrev ? "MB"   : "Magical Beast");
        case CLASS_TYPE_MONK:             return (bAbbrev ? "Monk" : "Monk");
        case CLASS_TYPE_MONSTROUS:        return (bAbbrev ? "Mnst" : "Monstrous");
        case CLASS_TYPE_OUTSIDER:         return (bAbbrev ? "Out"  : "Outsider");
        case CLASS_TYPE_PALADIN:          return (bAbbrev ? "Pal"  : "Paladin");
        case CLASS_TYPE_PALEMASTER:       return (bAbbrev ? "PM"   : "Pale Master");
        case CLASS_TYPE_RANGER:           return (bAbbrev ? "Rngr" : "Ranger");
        case CLASS_TYPE_ROGUE:            return (bAbbrev ? "Rog"  : "Rogue");
        case CLASS_TYPE_SHADOWDANCER:     return (bAbbrev ? "SD"   : "Shadow Dancer");
        case CLASS_TYPE_SHAPECHANGER:     return (bAbbrev ? "SC"   : "Shape Changer");
        case CLASS_TYPE_SHIFTER:          return (bAbbrev ? "Shft" : "Shifter");
        case CLASS_TYPE_SORCERER:         return (bAbbrev ? "Sorc" : "Sorcerer");
        case CLASS_TYPE_UNDEAD:           return (bAbbrev ? "Und"  : "Undead");
        case CLASS_TYPE_VERMIN:           return (bAbbrev ? "Vrmn" : "Vermin");
        case CLASS_TYPE_WEAPON_MASTER:    return (bAbbrev ? "WM"   : "Weapon Master");
        case CLASS_TYPE_WIZARD:           return (bAbbrev ? "Wiz"  : "Wizard");
        }
    return (bAbbrev ? "Inv" : "None");
}

string dbgGetEffectName(int nEffect) {
        switch(nEffect) {
               case 0: return "EFFECT_TYPE_INVALIDEFFECT";
               case 1: return "EFFECT_TYPE_DAMAGE_RESISTANCE";
               case 3: return "EFFECT_TYPE_REGENERATE";
               case 7: return "EFFECT_TYPE_DAMAGE_REDUCTION";
               case 9: return "EFFECT_TYPE_TEMPORARY_HITPOINTS";
               case 11: return "EFFECT_TYPE_ENTANGLE";
               case 12: return "EFFECT_TYPE_INVULNERABLE";
               case 13: return "EFFECT_TYPE_DEAF";
               case 14: return "EFFECT_TYPE_RESURRECTION";
               case 15: return "EFFECT_TYPE_IMMUNITY";
               case 17: return "EFFECT_TYPE_ENEMY_ATTACK_BONUS";
               case 18: return "EFFECT_TYPE_ARCANE_SPELL_FAILURE";
               case 20: return "EFFECT_TYPE_AREA_OF_EFFECT";
               case 21: return "EFFECT_TYPE_BEAM";
               case 23: return "EFFECT_TYPE_CHARMED";
               case 24: return "EFFECT_TYPE_CONFUSED";
               case 25: return "EFFECT_TYPE_FRIGHTENED";
               case 26: return "EFFECT_TYPE_DOMINATED";
               case 27: return "EFFECT_TYPE_PARALYZE";
               case 28: return "EFFECT_TYPE_DAZED";
               case 29: return "EFFECT_TYPE_STUNNED";
               case 30: return "EFFECT_TYPE_SLEEP";
               case 31: return "EFFECT_TYPE_POISON";
               case 32: return "EFFECT_TYPE_DISEASE";
               case 33: return "EFFECT_TYPE_CURSE";
               case 34: return "EFFECT_TYPE_SILENCE";
               case 35: return "EFFECT_TYPE_TURNED";
               case 36: return "EFFECT_TYPE_HASTE";
               case 37: return "EFFECT_TYPE_SLOW";
               case 38: return "EFFECT_TYPE_ABILITY_INCREASE";
               case 39: return "EFFECT_TYPE_ABILITY_DECREASE";
               case 40: return "EFFECT_TYPE_ATTACK_INCREASE";
               case 41: return "EFFECT_TYPE_ATTACK_DECREASE";
               case 42: return "EFFECT_TYPE_DAMAGE_INCREASE";
               case 43: return "EFFECT_TYPE_DAMAGE_DECREASE";
               case 44: return "EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE";
               case 45: return "EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE";
               case 46: return "EFFECT_TYPE_AC_INCREASE";
               case 47: return "EFFECT_TYPE_AC_DECREASE";
               case 48: return "EFFECT_TYPE_MOVEMENT_SPEED_INCREASE";
               case 49: return "EFFECT_TYPE_MOVEMENT_SPEED_DECREASE";
               case 50: return "EFFECT_TYPE_SAVING_THROW_INCREASE";
               case 51: return "EFFECT_TYPE_SAVING_THROW_DECREASE";
               case 52: return "EFFECT_TYPE_SPELL_RESISTANCE_INCREASE";
               case 53: return "EFFECT_TYPE_SPELL_RESISTANCE_DECREASE";
               case 54: return "EFFECT_TYPE_SKILL_INCREASE";
               case 55: return "EFFECT_TYPE_SKILL_DECREASE";
               case 56: return "EFFECT_TYPE_INVISIBILITY";
               case 57: return "EFFECT_TYPE_IMPROVEDINVISIBILITY";
               case 58: return "EFFECT_TYPE_DARKNESS";
               case 59: return "EFFECT_TYPE_DISPELMAGICALL";
               case 60: return "EFFECT_TYPE_ELEMENTALSHIELD";
               case 61: return "EFFECT_TYPE_NEGATIVELEVEL";
               case 62: return "EFFECT_TYPE_POLYMORPH";
               case 63: return "EFFECT_TYPE_SANCTUARY";
               case 64: return "EFFECT_TYPE_TRUESEEING";
               case 65: return "EFFECT_TYPE_SEEINVISIBLE";
               case 66: return "EFFECT_TYPE_TIMESTOP";
               case 67: return "EFFECT_TYPE_BLINDNESS";
               case 68: return "EFFECT_TYPE_SPELLLEVELABSORPTION";
               case 69: return "EFFECT_TYPE_DISPELMAGICBEST";
               case 70: return "EFFECT_TYPE_ULTRAVISION";
               case 71: return "EFFECT_TYPE_MISS_CHANCE";
               case 72: return "EFFECT_TYPE_CONCEALMENT";
               case 73: return "EFFECT_TYPE_SPELL_IMMUNITY";
               case 74: return "EFFECT_TYPE_VISUALEFFECT";
               case 75: return "EFFECT_TYPE_DISAPPEARAPPEAR";
               case 76: return "EFFECT_TYPE_SWARM";
               case 77: return "EFFECT_TYPE_TURN_RESISTANCE_DECREASE";
               case 78: return "EFFECT_TYPE_TURN_RESISTANCE_INCREASE";
               case 79: return "EFFECT_TYPE_PETRIFY";
               case 80: return "EFFECT_TYPE_CUTSCENE_PARALYZE";
               case 81: return "EFFECT_TYPE_ETHEREAL";
               case 82: return "EFFECT_TYPE_SPELL_FAILURE";
               case 83: return "EFFECT_TYPE_CUTSCENEGHOST";
               case 84: return "EFFECT_TYPE_CUTSCENEIMMOBILIZE";
        }

        return "EFFECT_TYPE_INVALID";
}


string Area_AorU(object oArea) {
    int iAU = GetIsAreaAboveGround(oArea);
    switch(iAU) {
        case AREA_ABOVEGROUND:   return "AREA_ABOVEGROUND";
        case AREA_UNDERGROUND:   return "AREA_UNDERGROUND";
        }
    return "AREA_INVALID";
}

string Area_NorA(object oArea) {
    int iNA = GetIsAreaNatural(oArea);
    switch(iNA) {
        case AREA_NATURAL:      return "AREA_NATURAL";
        case AREA_ARTIFICIAL:   return "AREA_ARTIFICIAL";
        }
    return "AREA_INVALID";
}

string GetAlignString(object oObject) {
    int LC = GetAlignmentLawChaos(oObject);
    int GE = GetAlignmentGoodEvil(oObject);

    if(LC == ALIGNMENT_CHAOTIC) {
        if(GE == ALIGNMENT_GOOD)return "Chaotic Good";
        if(GE == ALIGNMENT_NEUTRAL)return "Chaotic Neutral";
        if(GE == ALIGNMENT_EVIL)return "Chaotic Evil";
        return "Chaotic";
    } else if(LC == ALIGNMENT_LAWFUL) {
        if(GE == ALIGNMENT_GOOD)return "Lawful Good";
        if(GE == ALIGNMENT_NEUTRAL)return "Lawful Neutral";
        if(GE == ALIGNMENT_EVIL)return "Lawful Evil";
        return "Lawful";
    } else if(LC == ALIGNMENT_NEUTRAL) {
        if(GE == ALIGNMENT_GOOD)return "Neutral Good";
        if(GE == ALIGNMENT_NEUTRAL)return "True Neutral";
        if(GE == ALIGNMENT_EVIL)return  "Neutral Evil";
        return "Neutral";
    } else
        return "Unknown";
}

int StringToDebugLevel(string str) {

        if (str == "")
                return 0;

        string s2 = GetStringLeft(str, 2);
 
        //rest
        if (s2 == "re")
                return DEBUGLEVEL_1 ; 
        // module pc and area HB
        else if (s2 == "hb")
                return DEBUGLEVEL_2 ;
        // aww
        if (s2 == "aw")
                return DEBUGLEVEL_4;
        //pw
        else if (s2 == "pw")
                return DEBUGLEVEL_5;   
        //persist
        else if (s2 == "pe")
                return DEBUGLEVEL_6;
        return 0;
}

void dbgSetLevelFromStr(string sIn, int nOld, object oPC) {

       string sLeft = GetStringLeft(sIn,1);
       string sName = GetStringRest(sIn, 1);
       int nVal = StringToDebugLevel(sName);
       if (nVal == 0)
            return;

        int nNew;
        string sOp = "added ";
        if (sLeft == "-") {
                nNew = nOld &  ~nVal;
                sOp = "removed ";
        } else {
               nNew = nOld | nVal;
        }
        db("Debug level " +sOp + sName  + "(" + IntToHexString(nOld), -1, " to " + IntToHexString(nNew) +  ")", -1, TRUE, oPC);
        SetLocalInt(GetModule(), "DEBUG_LEVEL", nNew);
}

void dbgDumpCreatureEffects (object oPC) {
        effect e = GetFirstEffect(oPC);

        while (GetIsEffectValid(e)) {
                int nType = GetEffectType(e);
                object oCreator = GetEffectCreator(e);
                SendMessageToPC(oPC, GetName(oPC) + ": " + dbgGetEffectName(nType) + " - Creator: " + GetTag(oCreator));

                e = GetNextEffect(oPC);
        }


}

void dbg_doUnlock(object oPC) {
        float UNLOCKRANGE = 5.0;
        object oDoor = GetNearestObject(OBJECT_TYPE_DOOR, oPC, 1);
        if (GetIsObjectValid(oDoor)) {
                if (GetDistanceBetween(oPC, oDoor) < UNLOCKRANGE
                        && GetIsFacingTarget(oPC, oDoor, 90)
                        && GetLocked(oDoor)) {
                        db("Door " + GetTag(oDoor) + " :" + GetName(oDoor) + " unlocked.");
                        SetLocked(oDoor, FALSE);
                        return;
                }
        }

        object oPlc = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, 1);
        if (GetIsObjectValid(oPlc)) {
                if (GetDistanceBetween(oPC, oPlc) < UNLOCKRANGE
                        && GetIsFacingTarget(oPC, oPlc, 90)
                        && GetLocked(oPlc)) {
                        db("Placeable " + GetTag(oPlc) + " :" + GetName(oPlc) + " unlocked.");
                        SetLocked(oPlc, FALSE);
                        return;
                }
        }
        db("Could not find anything to unlock in " + FloatToString(UNLOCKRANGE) + " meters in PC's facing.");
}
void dbg_doLock(object oPC, int nDC) {
        float LOCKRANGE = 5.0;
        object oDoor = GetNearestObject(OBJECT_TYPE_DOOR, oPC, 1);
        if (GetIsObjectValid(oDoor)) {
                if (GetDistanceBetween(oPC, oDoor) < LOCKRANGE
                        && GetIsFacingTarget(oPC, oDoor, 90)
                        && !GetLocked(oDoor)) {
                        db("Door " + GetTag(oDoor) + " :" + GetName(oDoor) + " locked.");
                        SetLocked(oDoor, TRUE);
                        return;
                }
        }

        object oPlc = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, 1);
        if (GetIsObjectValid(oPlc)) {
                if (GetDistanceBetween(oPC, oPlc) < LOCKRANGE
                        && GetIsFacingTarget(oPC, oPlc, 90)
                        && !GetLocked(oPlc)) {
                        db("Placeable " + GetTag(oPlc) + " :" + GetName(oPlc) + " locked.");
                        SetLocked(oPlc,TRUE);
                        return;
                }
        }
        db("Could not find anything to unlock in " + FloatToString(LOCKRANGE) + " meters in PC's facing.");
}

void dumpFeatsInternal(object oCreature, object oPC, int nStart, int nEnd) {

        string sName;
        int nIdx;

        for (nIdx = nStart; nIdx < nEnd; nIdx++ ) {
                if (GetHasFeat(nIdx, oCreature)) {
                        sName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nIdx)));
                        SendMessageToPC(oPC, sName + "(" + IntToString(nIdx) + ")");
                }

        }
}

void dumpCreatureFeats(object oCreature, object oPC) {

        string sName;
        int idx;

        SendMessageToPC(oPC, GetName(oCreature) + " has these feats:");

        DelayCommand(0.0, dumpFeatsInternal(oCreature, oPC, 0, 500));
        DelayCommand(0.01, dumpFeatsInternal(oCreature, oPC, 500, 1000));
        DelayCommand(0.02, dumpFeatsInternal(oCreature, oPC, 1000, 1230));
        DelayCommand(0.03, dumpFeatsInternal(oCreature, oPC, 1945, 2000));

}



// Print out the list of available commands
// Remember to update this routine when adding new commands
void debugDoHelp(object oPC) {
    info("Debug help: all commands prefixed with '#dbg ' :");
    //info(ColorString("area reset", TEXT_COLOR_RED) + ": reset the current area if PWH managed.");
    info(ColorString("area", TEXT_COLOR_RED) + ": Dump the area information.");
    //info(ColorString("armor  [repair|break|wear]", TEXT_COLOR_RED) + ": repair, break or age(lower condition lvl) worn armor.");
    info(ColorString("armor", TEXT_COLOR_RED) + ": dump equipped armor info.");
    //info(ColorString("ccs [on|off]", TEXT_COLOR_RED) + ": Turn on or off the CCS leveling restrictions for the PC.");
    info(ColorString("citem <resref> [stack]", TEXT_COLOR_RED) + ": Create item <resref> on PC, with given stack size.");
    //info(ColorString("coins [x] [type]", TEXT_COLOR_RED) + ": Give the PC 1000 or X gold value in coin type (or default).");
    //info(ColorString("deity [favor]", TEXT_COLOR_RED) + ": Set deity favor to favor or display deity info.");
    info(ColorString("ditem <tag>", TEXT_COLOR_RED) + ": Delete first item with <tag> on PC.");
    //info(ColorString("equi[pment] [repair|break|wear]", TEXT_COLOR_RED) + ":repair.break or wear PC equipped items.");
    //info(ColorString("equi[pment]", TEXT_COLOR_RED) + ":Show PC equipped item status.");
    //info(ColorString("equi[pment] sta[rt]", TEXT_COLOR_RED) + ":Give PC basic starting gear.");
    //info(ColorString("equi[pment] loot", TEXT_COLOR_RED) + ": Dump PC loot bag as if dead.");
    //info(ColorString("equi[pment] debug", TEXT_COLOR_RED) + ": Give PC a pile of gear for debugging.");
    info(ColorString("exec <script>", TEXT_COLOR_RED) + ": Run given script as the PC.");
    info(ColorString("fix", TEXT_COLOR_RED) + ": Try to fix the PC (make commandable etc).");
    info(ColorString("gold  [x]", TEXT_COLOR_RED) + ":Give the PC 1000 or x gold (in default coins if enabled).");
    info(ColorString("harm disease", TEXT_COLOR_RED) + ":Given the PC a case of Filth fever.");
    info(ColorString("harm poison ", TEXT_COLOR_RED) + ":Give the PC a dose of Large spider venom.");
    info(ColorString("harm [x] [cold|fire|slash]", TEXT_COLOR_RED) + ": Harm the PC by 1 or X hps magical or the given type.");
    info(ColorString("heal [x]", TEXT_COLOR_RED) + ":Heal the PC by 1 or X hps, magical.");
    //info(ColorString("hench <harm|heal|dump> ...", TEXT_COLOR_RED) + ": do given command to first hench or familiar or ac - as other named commands.");
    //info(ColorString("hench expire X", TEXT_COLOR_RED) + ": set hench's hourly expire timer to X.");
    info(ColorString("help", TEXT_COLOR_RED) + ":display this message.");
    //info(ColorString("htf <(f)atigue|(h)unger|(t)hirst|(a)ll>  <x>", TEXT_COLOR_RED) + ":  Set given counter to x percent.");
    //info(ColorString("htf", TEXT_COLOR_RED) + ": Show PC htf information.");
    info(ColorString("id [Tag [Num]] | [Num]", TEXT_COLOR_RED) + ": Identify all items held by PC (or num items of tag).");
    //info(ColorString("jail", TEXT_COLOR_RED) + ": Dump PCs jail status.");
    //info(ColorString("jail clear", TEXT_COLOR_RED) + ": Clear PC guard hold.");
    info(ColorString("jump <area_tag>", TEXT_COLOR_RED) + ":Attempt to jump the the area way point for the given area.");
    info(ColorString("level  [x]", TEXT_COLOR_RED) + ":Set the debug level to x, default 0, use ff for all.");
    info(ColorString("level  [+|-] <name>", TEXT_COLOR_RED) + ": add or remove the debug level setting for given name (e.g. +coin, -pw).");
    //info(ColorString("lives <x>", TEXT_COLOR_RED) + ": Set the PCs number of lives. If setting to > 0 will allow respawn.");
    info(ColorString("lock [x]", TEXT_COLOR_RED) + ": lock nearest door or placeable and set DC to X (25 default).");
    info(ColorString("module", TEXT_COLOR_RED) + ":Dump the module settings information.");
    info(ColorString("npc", TEXT_COLOR_RED) + ":Dump nearest NPC's debug information.");
    info(ColorString("nuke", TEXT_COLOR_RED) + ": Kill all nearby hostile creatures.");
    info(ColorString("off", TEXT_COLOR_RED) + ":disable the rest of the debug commands and the debug flag.");
    info(ColorString("on", TEXT_COLOR_RED) + ":enable the rest of the debug commands and the debug flag.");
    //info(ColorString("nl <heal>", TEXT_COLOR_RED) + ": Report NL state or heal all NL damage.");
    info(ColorString("plc", TEXT_COLOR_RED) + ": Dump info about nearest usable placeable.");
    //info(ColorString("prr <up/down> <val>", TEXT_COLOR_RED) + ": Report PRR status of nearest NPC and optionally raise/lower by val (or 10)."); 
    info(ColorString("pwtest <val>", TEXT_COLOR_RED) + ": run pw data test.");
    //info(ColorString("potion <clear>", TEXT_COLOR_RED) + ":Show or clear PC's current potion DC if potion system enabled.");
    //info(ColorString("poison <clear>|<x>", TEXT_COLOR_RED) + ":Show or clear PC's current poison status or give PC poison x.");
    info(ColorString("reload", TEXT_COLOR_RED) + ":Reload the current module in 3 seconds.");
    //info(ColorString("rest area", TEXT_COLOR_RED) + ":display the area's rest type setting.");
    //info(ColorString("rest area <x> ", TEXT_COLOR_RED) + ":set the area's rest type to X (0 to 7).");
    //info(ColorString("rest fire", TEXT_COLOR_RED) + ":Toggle the area's rest_fire flag.");
    //info(ColorString("rest force", TEXT_COLOR_RED) + ":force rest the PC.");
    info(ColorString("restore", TEXT_COLOR_RED) + ": Jump the PC to the previously stored location.");
    //info(ColorString("rest time", TEXT_COLOR_RED) + ":Toggle the rest time limit flag.");
    //info(ColorString("quest", TEXT_COLOR_RED) + ": Dump basic status of PCs quests.");
    //info(ColorString("quest <questTag> [state]", TEXT_COLOR_RED) + ": Set journal entry of given quest to state (default 1, use 0) to reset.");
    info(ColorString("save", TEXT_COLOR_RED) + ":Save the PC's information.");
    info(ColorString("self", TEXT_COLOR_RED) + ":Dump PC's debug information.");
    //info(ColorString("secrets|sec", TEXT_COLOR_RED) + ":Reveal all crp secret placables in the area.");
    info(ColorString("self feats", TEXT_COLOR_RED) + ":Dump PC's feats.");
    info(ColorString("self vars", TEXT_COLOR_RED) + ":Dump PC's local variables (reqs NWNX)");
    info(ColorString("self fix", TEXT_COLOR_RED) + ": attempt to fix PCs appearance.");
    //info(ColorString("sky [x]", TEXT_COLOR_RED) + ":Advance to next skybox or set skybox to x.");
    //info(ColorString("spell comps", TEXT_COLOR_RED) + ": Give caller 1 of each component needed to cast all memorized spells.");
    info(ColorString("spawn <resref> <x>", TEXT_COLOR_RED) + ": spawn x copies of the given creature by resref, default 1.");
    info(ColorString("store", TEXT_COLOR_RED) + ":Store the PC's current location for later restore.");
    info(ColorString("target clear", TEXT_COLOR_RED) + ":clear the default debug target.");
    info(ColorString("target show", TEXT_COLOR_RED) + ":show the current debug target.");
    info(ColorString("target", TEXT_COLOR_RED) + ":set the debug target to this PC.");
    //info(ColorString("time day <days>", TEXT_COLOR_RED) + ":advance the calendar by <days> days.");
    //info(ColorString("time <hours>", TEXT_COLOR_RED) + ":advance the clock by <hours> hours.");
    //info(ColorString("time mon[th]  <months>", TEXT_COLOR_RED) + ":advance the calendar by <months> months.");
    //info(ColorString("time motd", TEXT_COLOR_RED) + ":print the current calendar motd.");
    //info(ColorString("time now", TEXT_COLOR_RED) + ":dump the current time stamps.");
    info(ColorString("unlock", TEXT_COLOR_RED) + ": unlock nearest door or placeable.");
    info(ColorString("unstore", TEXT_COLOR_RED) + ": Delete the previously stored location.");
    //info(ColorString("weapon|wpn  [repair|break|wear]", TEXT_COLOR_RED) + ": repair, break or age right hand item.");
    //info(ColorString("weapon|wpn", TEXT_COLOR_RED) + ": dump equipped weapon info.");
    //info(ColorString("weather rain|snow|clear", TEXT_COLOR_RED) + ":Set area's current weather to given.");
    //info(ColorString("weather reset", TEXT_COLOR_RED) + ":Cause area to recalculate weather - regardless of time.");
    //info(ColorString("weather temp [-]", TEXT_COLOR_RED) + ": Change the area temp band one higher ([-] or lower).");
    //info(ColorString("weather", TEXT_COLOR_RED) + ":Display area's current weather.");
    info(ColorString("xp [amount]", TEXT_COLOR_RED) + ":Give PC amount of XP (or 1000 if amount not set).");
    info(ColorString("xpk [amount]", TEXT_COLOR_RED) + ":Give PC amount of kill XP (or 1000 if amount not set).");
}

// Given then trimmed lowercased string see if it's a debug string
// If so do the work and return TRUE
// else return FALSE
int debugChatCommand(string sChat, object oPC) {

        sChat = tbTrim(sChat);

        if (GetStringLeft(sChat, 4) != "#dbg") {
                return FALSE;
        }

        object oMod = GetModule();
        string sCommand = GetStringRight(sChat, GetStringLength(sChat) - 4);
        int nLog = GetLocalInt(oMod,"DEBUGLOG");

        sCommand = tbTrim(sCommand);
        struct sStringTokenizer stTok = GetStringTokenizer(sCommand, " ");

        // Check for valid CD key.
        string sKey = GetPCPublicCDKey(oPC);
        if (sKey != "") {
                // TODO - only PCs with ADMIN level KEYS can do debug commands.
                //SendMessageToPC(oPC, "Your CD Key is " + sKey);
                // check against allowed keys.
                if (GetLocalInt(oMod, "DEBUGRESTRICT")) {
                        // TODO - this should be in the database
                        if (sKey != "FFUQ43VJ" && sKey != "UPWPDJFW"
			    && sKey != "UPFWAMRF"    // oldfog
				&& sKey != "QRM7AVCW"
				) {
                                WriteTimestampedLogEntry("DENIED: Player " + GetPCPlayerName(oPC) + " CD Key " + sKey + " attempted Debug command '" + sChat + "'");
                                // Return true to swallow the command.
                                return TRUE;
                        }
                }
        }
        WriteTimestampedLogEntry("Player " + GetPCPlayerName(oPC) + " CD Key " + sKey + " used Debug command '" + sChat + "'");

        if (!HasMoreTokens(stTok)) {
                return TRUE;
        }

        stTok = AdvanceToNextToken(stTok);
        string sCmnd = GetNextToken(stTok);
        sCmnd = GetStringLowerCase(sCmnd);

    // Toggle debug flag
        if (sCmnd == "on" && !GetLocalInt(oMod, "NO_DEBUG_MODE")) {
                SetLocalInt(oMod, "DEBUG", 1);
                db("Debug is enabled", -1, "", -1, nLog, oPC);
                return TRUE;
        }
        if (sCmnd == "off") {
                db("Debug is disabled", -1, "", -1, nLog, oPC);
                SetLocalInt(oMod, "DEBUG", 0);
                return TRUE;
        }

        if (sCmnd == "help") {
                debugDoHelp(oPC);
                return TRUE;
        }

    // Don't do anything if not enabled
        //if (!GetLocalInt(oMod, "DEBUG")) {
        //        return TRUE;
        //}

        /* 
        if (sCmnd == "time") {
                int nVal;
                if (!HasMoreTokens(stTok)) {
                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);
                if (sVal == "day")  {
                        if (!HasMoreTokens(stTok)) {
                                nVal = 1;
                        } else {
                                stTok = AdvanceToNextToken(stTok);
                                sVal = GetNextToken(stTok);
                                nVal = StringToInt(sVal);
                                if (nVal == 0) nVal = 1;
                        }
                        SetCalendar(GetCalendarYear(), GetCalendarMonth(), GetCalendarDay() + nVal);
                        info("Day advanced " + IntToString(nVal) + " Day(s) : now month ",GetCalendarMonth() ," day", GetCalendarDay() ,nLog,oPC);

                } else if (sVal ==  "mon" || sVal == "month") {
                        if (!HasMoreTokens(stTok)) {
                                nVal = 1;
                        } else {
                                stTok = AdvanceToNextToken(stTok);
                                sVal = GetNextToken(stTok);
                                nVal = StringToInt(sVal);
                                if (nVal == 0) nVal = 1;
                        }
                        SetCalendar(GetCalendarYear(), GetCalendarMonth() + nVal, GetCalendarDay());
                        info("Month advanced " + IntToString(nVal) + " Month(s) : now month ",GetCalendarMonth() ," day", GetCalendarDay() ,nLog,oPC);

                }  else if (sVal ==  "now") {
        // print the current time stamps
                        info("Current timestamp " + IntToString(CurrentTimeStamp()) + " Hour :  ", CurrentTime() ," Day", CurrentDay() ,nLog,oPC);
                }  else if (sVal ==  "motd") {
        // print the current motd
                        ExecuteScript("calend_motd", oPC);
                } else {
                    nVal = StringToInt(sVal);
                    if (nVal == 0) nVal = 1;

                    int iHour = GetTimeHour();
                    iHour = iHour + nVal;
                    SetTime(iHour, GetTimeMinute(),GetTimeSecond(),0);

                    info("Time advanced " + IntToString(nVal) + " Hour(s): now day ",GetCalendarDay() ," hour", GetTimeHour() ,nLog,oPC);
                }
                return TRUE;

        } // time commands
        */

        if (sCmnd == "xp") {
                int nVal = 0;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                if (nVal == 0) nVal = 1000;
                SetXP(oPC, GetXP(oPC) + nVal);
                //GiveXPToCreature(oPC, nVal);
                db("debug Xp granted: ", nVal ,"", -1 ,nLog,oPC);

                return TRUE;
        }
        if (sCmnd == "xpk") {
                int nVal = 0;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                if (nVal == 0) nVal = 1000;
                nVal = XPPoolGetXPAward(oPC, nVal);
                GiveXPToCreature(oPC, nVal);
                db("debug kill XP granted: ", nVal ,"", -1 ,nLog,oPC);

                return TRUE;
        }
        /* Lives
        if (GetStringLeft(sCmnd,2) == "li") {
                int nVal = 0;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                if (nVal > 0) {
                        //object oDD = GetItemPossessedBy(oPC, "deathdeed");
                        //if(GetIsObjectValid(oDD)) {
                        //        SetPlotFlag(oDD, FALSE);
                        //        DestroyObject(oDD);
                        //}
                }
                int nLives = GetNumItemsByTag(oPC, "soulrune", TRUE);
                if (nLives > nVal) {
                        DestroyNumItems(oPC, "soulrune", nLives - nVal);
                } else if (nLives < nVal) {
                        object oSoulRune;
                        int i;
                        for(i= 0; i < nVal - nLives; i++) {
                                oSoulRune = CreateItemOnObject("soulrune", oPC, 1);
                        }
                }
                return TRUE;
        }
        */
        if (sCmnd == "exec") {
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        SendMessageToPC(oPC, "Executing '" + sVal + "'");
                        ExecuteScript(sVal, oPC);
                }
                return TRUE;
        }
        if (sCmnd == "fix") {
                SetCommandable(TRUE,oPC);
		AssignCommand(oPC, ClearAllActions());
                // other things - clean up horse tails?
                // set appearance normal - remove cutscene and black screen etc
                //DeleteLocalInt(oPC, "UnderWater");
                //DeletePersistentInt(oPC, "InFloodTrap");
                //SetLocalInt(oPC, "uwater_tmp_op", 1);
                //ExecuteScript("uwater_do_op", oPC);
                return TRUE;
        }
        /*
        if (sCmnd == "rest") {
        //
                object oArea = GetArea(oPC);
                if (!HasMoreTokens(stTok)) {
                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);

        // disable the time requirement for resting
                if (sVal == "time") {
                        int nCur = GetLocalInt(oMod, "rest_no_time_penalty");
                        SetLocalInt(oMod, "rest_no_time_penalty", !nCur);
                        db("Setting rest_no_time_penalty to ", !nCur);
                        return TRUE;
                }

        // Toggle the allow fire flag on the area
                if (sVal == "fire") {
                        int nCur = GetLocalInt(oArea, "rest_fire");
                        SetLocalInt(oArea, "rest_fire", !nCur);
                        db("Setting area rest_fire to ", !nCur);
                        return TRUE;
                }

        // set the area rest_type to the given value
                if (sVal == "area") {
                        if (!HasMoreTokens(stTok)) {
                                db("Area " + GetTag(oArea) + " has rest type " ,
                                   GetLocalInt(oArea, "rest_type"), " rest_fire = ", GetLocalInt(oArea, "rest_fire"), nLog, oPC);
                                return TRUE;

                        }
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        int nVal = StringToInt(sVal);
            //if (nVal < REST_TYPE_NONE || nVal > REST_TYPE_INT_FULL) {
                        if (nVal < 0 || nVal > 7) {
                                nVal = 1;
                        }
                        SetLocalInt(oArea, "rest_type", nVal);
                        db("Setting Area " + GetTag(oArea), -1, " rest_type to " , nVal, nLog, oPC);
                        return TRUE;
                }

        // TODO - update this when HTF is more complete -
        // Need to update fatigue etc.
                if (sVal == "force" ) {
                        db("Doing force rest on PC ", -1, "" , -1, nLog, oPC);
                        SetLocalInt(oPC, "rest_tmp_op", 3);
                        SetLocalInt(oPC, "rest_tmp_food", TRUE);
                        ExecuteScript("rest_do_op", oPC);
                        return TRUE;
                }
                return TRUE;

        }
        */

        /*
        if (sCmnd == "htf") {

                if (!HasMoreTokens(stTok)) {
                        //htfDumpInfo(oPC);
                        ExecuteScript("htf_do_op", oPC);
                        ExecuteScript("nl_do_report", oPC);
                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);
                int nPerc = 100;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sTmp = GetNextToken(stTok);
                        nPerc = StringToInt(sTmp);
                        // Allow setting a bit over 100 percent for buffer.
                        if (nPerc < 0 || nPerc > 105)
                                nPerc = 100;
                }
                int nOp = 0;
                if (sVal == "f" || sVal == "fatigue" || sVal == "fat") {
                        nOp = 1;
                }
                if (sVal == "h"|| sVal == "hunger") {
                        nOp = 2;
                }
                if (sVal == "t" || sVal == "thirst") {
                        nOp = 3;
                }
                if (sVal == "a" || sVal == "all") {
                        nOp = 4;
                }

                SetLocalInt(oPC, "htf_tmp_op", nOp);
                SetLocalInt(oPC, "htf_tmp_perc", nPerc);
                ExecuteScript("htf_do_op", oPC);

                return TRUE;
        }
        */

        /*
        if (GetStringLeft(sCmnd,4) == "weat") {
        // no command dump the weather for the area
                object oArea = GetArea(oPC);
                if (!HasMoreTokens(stTok)) {
                        SetLocalInt(oPC, "weather_tmp_op", 1);
                        ExecuteScript("weather_do_op", oPC);
                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);

                if (sVal == "rain") {
                        SetWeather(oArea , WEATHER_RAIN);
                        return TRUE;
                } else if (sVal == "snow") {
                        SetWeather(oArea, WEATHER_SNOW);
                        return TRUE;
                } else if (sVal == "clear") {
                        SetWeather(oArea, WEATHER_CLEAR);
                        return TRUE;
                }
        // #dbg weather reset  - cause area to redo the weather calculations - regardless of time.
                else if (sVal == "reset") {
                        SetLocalInt(oPC, "weather_tmp_op", 2);
                        ExecuteScript("weather_do_op", oPC);
                        return TRUE;
                }
        // #dbg weather temp  <+/->  increase or decrease temp one band (default increase - will cycle around)
                else if (sVal == "temp") {
                        int bRaise =  TRUE;
                        if (HasMoreTokens(stTok)) {
                                stTok = AdvanceToNextToken(stTok);
                                string sNext = GetNextToken(stTok);
                                if (sNext == "-") bRaise = FALSE;
                        }
                        SetLocalInt(oPC, "weather_tmp_op", 4);
                        SetLocalInt(oPC, "weather_tmp_val", bRaise);
                        ExecuteScript("weather_do_op", oPC);
                }
                return TRUE;
        }
        */

        if (sCmnd == "reload") {
        // reload the module
                string sName = "";
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        sName = GetNextToken(stTok);
                }
                dbg_reload(sName, nLog, oPC);
                return TRUE;
        }

        /*
        if (sCmnd == "quest") {

                if (HasMoreTokens(stTok)) {
                        string sName = "";
                        int nState = 1;
                        stTok = AdvanceToNextToken(stTok);
                        sName = GetNextToken(stTok);
                        if (HasMoreTokens(stTok)) {
                                stTok = AdvanceToNextToken(stTok);
                                string sTmp = GetNextToken(stTok);

                                nState = StringToInt(sTmp);
                                if (nState == 0 && sTmp != "0") {
                                        SendMessageToPC(oPC, "Bad quest state given");
                                        return TRUE;
                                }
                        }
                        // Allow quest ID instead of name - all IDs are 5 chars.
                        int nLen = GetStringLength(sName);
                        if (nLen < 5) {
                                SendMessageToPC(oPC, "Bad quest name given");
                                return TRUE;
                        }
                        SetLocalInt(oPC, "quest_temp_op", 2);
                        SetLocalInt(oPC, "quest_temp_val", nState);
                        SetLocalString(oPC, "quest_tmp_name", sName);
                        return TRUE;
                }

                // Dump quest info
                SetLocalInt(oPC, "quest_temp_op", 1);
                SetLocalInt(oPC, "quest_temp_val", TRUE);
                ExecuteScript("quest_dbg_dump", oPC);
                ExecuteScript("contracts_dump", oPC);
                return TRUE;
        }
        */

        /*
        if (sCmnd == "sky") {
        // set skybox to give value or cycle to next
                int nVal = 0;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                SetLocalInt(oPC, "weather_tmp_op", 3);
                SetLocalInt(oPC, "weather_tmp_val", nVal);
                ExecuteScript("weather_do_op", oPC);

                return TRUE;
        }
        */

        /*
        if (sCmnd == "ccs") {
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        if (sVal == "off") {
                                SetLocalInt(oPC, "CCS_BYPASS", 1);
                                SendMessageToPC(oPC, "CCS Disabled");
                        } else if (sVal == "on") {
                                DeleteLocalInt(oPC, "CCS_BYPASS");
                                SendMessageToPC(oPC, "CCS Enabled");
                        }
                        if (!HasMoreTokens(stTok)) {
                                return TRUE;
                        }
                        if (GetStringLeft (sVal, 2) == "tr") {
                                stTok = AdvanceToNextToken(stTok);
                                string sVal2 = GetNextToken(stTok);
                                int nClass = -1;

                                        // Set the PC training in the given classi
                                if (GetStringLeft(sVal2, 4) == "barb")
                                        nClass = CLASS_TYPE_BARBARIAN;
                                else if (GetStringLeft(sVal2, 4) == "bard")
                                        nClass = CLASS_TYPE_BARD;
                                else if (GetStringLeft(sVal2, 2) == "cl")
                                        nClass = CLASS_TYPE_CLERIC;
                                else if (GetStringLeft(sVal2, 2) == "dr")
                                        nClass = CLASS_TYPE_DRUID;
                                else if (GetStringLeft(sVal2, 2) == "fi")
                                        nClass = CLASS_TYPE_FIGHTER;
                                else if (GetStringLeft(sVal2, 2) == "mo")
                                        nClass = CLASS_TYPE_MONK;
                                else if (GetStringLeft(sVal2, 2) == "pa")
                                        nClass = CLASS_TYPE_PALADIN;
                                else if (GetStringLeft(sVal2, 2) == "ra")
                                        nClass = CLASS_TYPE_RANGER;
                                else if (GetStringLeft(sVal2, 2) == "ro")
                                        nClass = CLASS_TYPE_ROGUE;
                                else if (GetStringLeft(sVal2, 2) == "so")
                                        nClass = CLASS_TYPE_SORCERER;
                                else if (GetStringLeft(sVal2, 2) == "wi")
                                        nClass = CLASS_TYPE_WIZARD;

                                        // TODO - add prestige classes
                                if (nClass >= 0) {
                                        SetPersistentInt(oPC, "CCS_TRAIN_CLASS", nClass);
                                }
                        }
                }
                return TRUE;
        }
        */

        /* Spells
        if (GetStringLeft(sCmnd, 3) == "spe") {

                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        //nVal = StringToInt(sVal);
                        if (GetStringLeft(sVal, 2) == "co") {
                                SetLocalInt(oPC, "spell_tmp_op", 1);
                                ExecuteScript("spells_do_op", oPC);

                                SetLocalInt(oPC, "spell_tmp_op", 2);
                                ExecuteScript("spells_do_op", oPC);
                        }
                }
                return TRUE;
        }
        */

        /* Spawn   */
        if (GetStringLeft(sCmnd, 3) == "spa") {

                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);

                        int nNum = 1;
                        if (HasMoreTokens(stTok)) {
                                stTok = AdvanceToNextToken(stTok);
                                nNum = StringToInt(GetNextToken(stTok));
                                if (nNum < 0 || nNum > 10) {
                                        nNum = 1;
                                }
                        }
                        location lLoc = tbGetCustomAheadLocation(oPC, 10.0);
                        int i;
                        object oCreature;
                        for (i= 0; i < nNum; i ++) {
                                oCreature = CreateObject(OBJECT_TYPE_CREATURE, sVal, lLoc);
                                if (!GetIsObjectValid(oCreature) && i == 0) {
                                        SendMessageToPC(oPC, "Debug: unable to create " + sVal);
                                }
                        }
                }
                return TRUE;
        }

        /* Secrets 
        if (GetStringLeft(sCmnd, 3) == "sec") {
                SendMessageToPC(oPC, "Revealing ALL secrets in area. Use #dbg area reset if pw area to re-hide them.");
                SetLocalInt(oPC, "track_tmp_op", 10);
                ExecuteScript("tracking_do_op", oPC);
                return TRUE;
        }
        */

        /* JUMP - TODO - this needs to be fixed up  */
        if (GetStringLeft(sCmnd,2) == "ju") {
                //Jump to area
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        if (sVal != "") {
                                object oWP = GetWaypointByTag(sVal);
                                if (!GetIsObjectValid(oWP)) oWP = GetWaypointByTag("WP" + sVal);
                                if (GetIsObjectValid(oWP))
                                        AssignCommand(oPC, ActionJumpToObject(oWP));
                                else
                                        SendMessageToPC(oPC, "Unable to find WP " + sVal + " or WP" + sVal);
                        }
                }
                return TRUE;
        }

        /* Jail 
        if (GetStringLeft(sCmnd,2) == "ja") {
                //Jail
                if (!HasMoreTokens(stTok)) {
                        SetLocalInt(oPC, "tnp_tmp_op", 1);
                        ExecuteScript("tnp_do_op", oPC);

                } else {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        if (GetStringLeft(sVal, 2) == "cl") {
                                SetLocalInt(oPC, "tnp_tmp_op", 2);
                                ExecuteScript("tnp_do_op", oPC);
                        }
                }
                return TRUE;
        }
        */
        if (GetStringLeft(sCmnd, 2) == "pl") {
                int nNth = 1;

                object oPlc =  GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth ++);
                while (GetIsObjectValid(oPlc)) {
                        if (GetUseableFlag(oPlc)) {
                                dbg_dumpObject(oPlc, "dialog", "quest_info_list",  nLog, oPC);
                                return TRUE;
                        }
                        oPlc = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth ++);
                }
                return TRUE;
        }
        /* persistent reputation
        if (sCmnd == "prr") {
                // Report or modify nearest NPC's PRR value
                object oNPC =  GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,  PLAYER_CHAR_NOT_PC , oPC);
                if (GetIsObjectValid(oNPC)) {
                        if (HasMoreTokens(stTok)) {
                                int nVal = 10;
                                stTok = AdvanceToNextToken(stTok);
                                string sVal = GetNextToken(stTok);

                                if (HasMoreTokens(stTok)) {
                                        stTok = AdvanceToNextToken(stTok);
                                        string sVal2 = GetNextToken(stTok);
                                        nVal = StringToInt(sVal2);
                                        if (nVal <= 0) nVal = 10;
                                }
                                if (sVal == "up") {
                                        SendMessageToPC(oPC, "Adjusting Reputation with " + GetName(oNPC) + " up by " + IntToString(nVal));
                                        //PRR_AdjustHistoricalValue (oPC, oNPC, nVal);
                                        prrWrapAdjustRep(oPC, oNPC, nVal);
                                } else if (sVal == "down") {
                                        SendMessageToPC(oPC, "Adjusting Reputation with " + GetName(oNPC) + " down by " + IntToString(nVal));
                                        nVal = -nVal;
                                        //PRR_AdjustHistoricalValue (oPC, oNPC, nVal);
                                        prrWrapAdjustRep(oPC, oNPC, nVal);
                                }
                        }
                        prrWrapDump(oNPC, oPC);
                        //int nRep = GetPersonalReaction(oNPC, OBJECT_SELF);
                        //int nLevel = PRR_GetLevelFromRep(nRep);
                        //SendMessageToPC(oPC, "PRR: " + GetName(oNPC) + " is " + PRR_RepLevelToString(nLevel) + "(" + IntToString(nRep) + ")");
                }
                return TRUE;
        }
        */
        if (sCmnd == "pwtest") {
                int nVal = 0;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                if (nVal < 0) nVal = 0;
                SetLocalInt(oPC, "pw_data_op", nVal);
                ExecuteScript("pw_data_test", oPC);
                return TRUE;
        }


        if (sCmnd == "heal") {
        // Heal PC
        int nVal = 0;
                int nType = DAMAGE_TYPE_MAGICAL;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                if (nVal <= 0) nVal = 1;
                effect eHeal = EffectHeal(nVal);
                effect eVis = EffectVisualEffect(VFX_IMP_HEALING_G);
                eHeal = EffectLinkEffects(eHeal, eVis);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oPC);

                //SetLocalInt(oPC, "tmp_pc_op", 10);
                //SetLocalInt(oPC, "tmp_pc_val", 1); // STABILIZED
                //ExecuteScript("pc_do_op", oPC);

                return TRUE;
        }

        if (sCmnd == "harm") {
        // damage PC by given amount or 1 point
                int nVal = 0;
                int nType = DAMAGE_TYPE_MAGICAL;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        sVal = GetStringLowerCase(sVal);
                        if (sVal == "poison") {
                                effect ePois = EffectPoison(POISON_LARGE_SPIDER_VENOM);
                                ApplyEffectToObject(DURATION_TYPE_PERMANENT,ePois,oPC,120.0f);// Lex says do poison permanent
                                return TRUE;
                        } else if (sVal == "disease") {
                                effect eDis = EffectDisease(DISEASE_FILTH_FEVER);
                                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDis,oPC,120.0f);
                                return TRUE;
                        } else
                                nVal = StringToInt(sVal);
                }
                if (nVal == 0) nVal = 1;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        sVal = GetStringLowerCase(sVal);
                        if (sVal == "cold") {
                                nType = 32;
                        } else if (sVal == "fire") {
                                nType = 256;
                        } else if (sVal == "slash") {
                                nType = 4;
                        } // etc...
                }

                effect eDamage = EffectDamage(nVal, nType, DAMAGE_POWER_ENERGY);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oPC);
                DeleteLocalInt(oPC, "bandaged");
		//DeleteLocalInt(oPC, "PC_STABILIZED");

                //SetLocalInt(oPC, "tmp_pc_op", 10);
                //SetLocalInt(oPC, "tmp_pc_val", 0); // STABILIZED
                //ExecuteScript("pc_do_op", oPC);

                return TRUE;
        }

        /* henchperson debug
        if (sCmnd == "hench") {

                object oHench = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 1);
                if (!GetIsObjectValid(oHench)) {
                        oHench = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 1);
                }
                if (!GetIsObjectValid(oHench)) {
                        oHench = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 1);
                }
                if (!GetIsObjectValid(oHench)) {
                        SendMessageToPC(oPC, "You have no henchperson, familiar or animal companion.");
                        return TRUE;
                }

                if (!HasMoreTokens(stTok)) {
                        // Report on hench?

                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                if (sVal == "heal") {

                    // Heal hench by given amount or 1
                        int nVal = 0;
                        int nType = DAMAGE_TYPE_MAGICAL;
                        if (HasMoreTokens(stTok)) {
                                stTok = AdvanceToNextToken(stTok);
                                string sVal2 = GetNextToken(stTok);
                                nVal = StringToInt(sVal2);
                        }
                        if (nVal == 0) nVal = 1;
                        effect eHeal = EffectHeal(nVal);
                        effect eVis = EffectVisualEffect(VFX_IMP_HEALING_G);
                        eHeal = EffectLinkEffects(eHeal, eVis);
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oHench);
                } else if (sVal == "harm") {
                        // damage hench by given amount or 1 point
                        int nVal = 0;
                        int nType = DAMAGE_TYPE_MAGICAL;
                        if (HasMoreTokens(stTok)) {
                                stTok = AdvanceToNextToken(stTok);
                                nVal = StringToInt(GetNextToken(stTok));
                        }
                        if (nVal == 0) nVal = 1;
                        if (HasMoreTokens(stTok)) {
                                stTok = AdvanceToNextToken(stTok);
                                sVal = GetStringLowerCase(GetNextToken(stTok));
                                if (sVal == "cold") {
                                        nType = 32;
                                } else if (sVal == "fire") {
                                        nType = 256;
                                } else if (sVal == "slash") {
                                        nType = 4;
                                } // etc...
                        }
                        // Have the module do it
                        AssignCommand(oMod, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nVal, nType, DAMAGE_POWER_ENERGY), oHench));
                        DeleteLocalInt(oHench, "bandaged");

                } else if (GetStringLeft(sVal,3) == "exp") {
                        int nVal = 0;
                        if (HasMoreTokens(stTok)) {
                                stTok = AdvanceToNextToken(stTok);
                                nVal = StringToInt(GetNextToken(stTok));
                        }
                        SetLocalInt(oHench, "hire_expire", nVal);
                        dbstr("Setting " + GetName(oHench) + "'s expire time to " + IntToString(GetLocalInt(oHench, "hire_expire")));

                } else if (sVal == "dump") {
                        SetLocalInt(oHench, "hench_tmp_op", 4);
                        SetLocalObject(oHench, "hench_tmp_obj", oPC);
                        ExecuteScript("hench_do_op", oHench);
                }
                return TRUE;
        }
        */

        if (sCmnd == "level") {
        // adjust the debug level
                int nOld = GetLocalInt(oMod, "DEBUG_LEVEL");
                int nLevel = 0;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        sVal = GetStringLowerCase(sVal);
                        string sLeft = GetStringLeft(sVal,1);
                        if (sLeft == "-" || sLeft == "+") {
                              dbgSetLevelFromStr(sVal, nOld, oPC);
                              return TRUE;
                        }
                        if (sVal == "ff") {
                                nLevel = DEBUGLEVEL_ALL;
                        } else
                                nLevel = StringToInt(sVal);
                        if (nLevel == -1)
                                nLevel = 0;
                        nLevel = nLevel &  DEBUGLEVEL_ALL;
                        db("Debug level changed from " + IntToHexString(nOld), -1, " to " + IntToHexString(nLevel), -1, nLog, oPC);
                        SetLocalInt(oMod, "DEBUG_LEVEL", nLevel);
                        return TRUE;
                }
                db("Debug level is " + IntToHexString(nOld), -1, "", -1, nLog, oPC);
                return TRUE;
        }

        /* non-lethal damage
        if (sCmnd == "nl") {
                // Report or  heal NL damage
                if (!HasMoreTokens(stTok)) {
                        ExecuteScript("nl_do_report", oPC);
                        return TRUE;
                }

                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                if (sVal == "heal") {
                        ExecuteScript("nl_dam_heal_all", oPC);
                }
                return TRUE;
        }
        */

        /* potions
        if (GetStringLeft(sCmnd, 3) == "pot") {
                // Report or clear potion count
                if (!HasMoreTokens(stTok)) {
                        SendMessageToPC(oPC, "Current Potion DC = " + IntToString(GetPersistentInt(oPC, "potion_count")));
                        return TRUE;
                }

                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                if (GetStringLeft(sVal,2) == "cl") {
                        SetLocalInt(oPC, "potion_tmp_op", 3);
                        ExecuteScript("potion_do_op", oPC);
                }
                return TRUE;
        }
        */
        /* poisons
        if (GetStringLeft(sCmnd, 3) == "poi") {
                // Report or clear poison status
                if (!HasMoreTokens(stTok)) {
                        SetLocalInt(oPC, "poison_tmp_op", 4);
                        ExecuteScript("poison_do_op", oPC);
                        return TRUE;
                }

                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                if (GetStringLeft(sVal,2) == "cl") {
                        SetLocalInt(oPC, "poison_tmp_op", 2);
                        ExecuteScript("poison_do_op", oPC);
                } else {
                        int nPois = StringToInt(sVal);
                        if (nPois == 0 && sVal != "0")
                               return TRUE;
                        effect ePoison = EffectPoison(nPois);
                        poisonApplyEffectPoison(ePoison, oPC, nPois);
                }
                return TRUE;
        }
        */

        /* deity  pantheon system
        if (sCmnd == "deity") {
                // Report or set deity favor
                if (!HasMoreTokens(stTok)) {
                        SetLocalInt(oPC, "deity_tmp_op", 3);
                        ExecuteScript("deity_do_op", oPC);
                        return TRUE;
                }

                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                int nVal = StringToInt(sVal);
                SetLocalInt(oPC, "deity_tmp_op", 6);
                SetLocalInt(oPC, "deity_tmp_val", nVal);
                ExecuteScript("deity_do_op", oPC);
                return TRUE;
        }
        */
        if (sCmnd == "area") {
                /* 
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        sVal = GetStringLowerCase(sVal);
                        if (sVal == "reset") {
                                object oArea = GetArea(oPC);
                                if (HasMoreTokens(stTok)) {
                                        stTok = AdvanceToNextToken(stTok);
                                        string sTag = GetNextToken(stTok);
                                        oArea = GetObjectByTag(sTag);
                                        if (!GetIsObjectValid(oArea)) {
                                                db("Unable to find area " + sTag + " to reset.");
                                                return TRUE;
                                        }
                                }
                                if (GetLocalInt(oArea, "PW_MANAGED_AREA")) {
                                        ExecuteScript("pw_area_reset",GetArea(oPC));
                                } else {
                                        //db("Area is not managed by PWH - no reset.");
                                        // For testing
                                        db("Area is not managed by PWH - just doing q trap reset.");
                                        ExecuteScript("q1_trap_reset", GetArea(oPC));
                                }
                        }

                        return TRUE;
                }
                */
                dbg_dumpArea(GetArea(oPC), GetLocation(oPC), oPC, nLog);
                return TRUE;
        }
        if (sCmnd == "module") {
                dbg_dumpModule(nLog, oPC);
                return TRUE;
        }
        if (sCmnd == "unlock") {
                dbg_doUnlock(oPC);
                return TRUE;
        }
        if (sCmnd == "lock") {
                int nDC = 25;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nDC = StringToInt(sVal);
                }
                dbg_doLock(oPC, nDC);
                return TRUE;
        }

        /* identiry PC items */
        if (sCmnd == "id") {
                int nCount = 0;
                string sTag = "";
                if (!HasMoreTokens(stTok)) {
                        nCount = utilIdentifyItems(oPC);
                        SendMessageToPC(oPC, "Identified " + IntToString(nCount) + " items.");
                        return TRUE;
                }

                // This functionality is mostly to test the id code
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                // Check for a number.
                nCount = StringToInt(sVal);
                if (!nCount) {
                        sTag = sVal;
                }
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        sVal = GetNextToken(stTok);
                        nCount = StringToInt(sVal);
                }
                nCount = utilIdentifyItems(oPC, sTag, nCount);
                SendMessageToPC(oPC, "Identified " + IntToString(nCount) + " items.");

                return TRUE;
        }

        /* PC self debug */
        if (sCmnd == "self") {
                if (!HasMoreTokens(stTok)) {
                         dbg_dumpCreature(oPC, nLog, oPC);
                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);
                if (GetStringLeft(sVal,2) == "fe") {
                        dumpCreatureFeats(oPC, oPC);
                } else if (GetStringLeft(sVal, 2) == "fi") {
                        // TODO - make sure not polymorphed
                        SendMessageToPC(oPC, "Attempting to fix PC's appearance");
                        SetCreatureAppearanceType(oPC, GetAppearanceType(oPC));
                } else if (GetStringLeft(sVal, 2) == "va") {
			int op = 1;
			if (HasMoreTokens(stTok)) op = 2;
                        SendMessageToPC(oPC, "Attempting to dump PC's local variables");
                        SetLocalInt(oPC, "nwnx_tmp_op", op);
                        SetLocalObject(oPC, "nwnx_tmp_obj", oPC);
                        ExecuteScript("nwnx_do_op", oPC); 
			SendMessageToPC(oPC, "Attempting to dump PC's skin variables");
                        SetLocalInt(oPC, "nwnx_tmp_op", op);
                        SetLocalObject(oPC, "nwnx_tmp_obj", SkinGetSkin(oPC));
                        ExecuteScript("nwnx_do_op", oPC);
                } else if (GetStringLeft(sVal, 3) == "cle") {
                        int op = 3;
                        SendMessageToPC(oPC, "Attempting to clear PC's skin variables");
                        SetLocalInt(oPC, "nwnx_tmp_op", op);
                        SetLocalObject(oPC, "nwnx_tmp_obj", SkinGetSkin(oPC));
                        ExecuteScript("nwnx_do_op", oPC);
                }

                return TRUE;
        }

        /* equipment debug
        if (GetStringLeft(sCmnd, 4)  == "equi") {
                if (!HasMoreTokens(stTok)) {
                        DeleteLocalInt(oPC, "wpn_tmp_op");
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }

                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);
                if (sVal == "rep" || sVal == "repair") {
                        SetLocalInt(oPC, "wpn_tmp_op", 2);
                        SetLocalObject(oPC, "wpn_tmp_item", oPC);
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }
                if (sVal == "break") {
                        SetLocalInt(oPC, "wpn_tmp_op", 4);
                        SetLocalObject(oPC, "wpn_tmp_item", oPC);
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }
                if (sVal == "wear") {
                        SetLocalInt(oPC, "wpn_tmp_op", 3);
                        SetLocalObject(oPC, "wpn_tmp_item", oPC);
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }
                if (GetStringLeft(sVal,3) == "sta") {
                        SetLocalInt(oPC, "tmp_pc_op", 0);
                        ExecuteScript("pc_do_op", oPC);
                        return TRUE;
                }
                // Dump loot bag
                if (GetStringLeft(sVal,3) == "loo") {
                        SetLocalInt(oPC, "death_tmp_op", 10);
                        ExecuteScript("death_do_op", oPC);
                        return TRUE;
                }

                if (GetStringLeft(sVal,3) == "deb") {
                        object oItem;
                        CreateItemOnObject("it_thvpick_comm", oPC, 1);
                        CreateItemOnObject("it_thvtool_comm", oPC, 1);
                        CreateItemOnObject("it_cr_huntknife", oPC, 1);
                        CreateItemOnObject("it_dig_shovel", oPC, 1);
                        CreateItemOnObject("it_coin_bag", oPC, 1);
                        oItem = CreateItemOnObject("it_pot_heal1", oPC, 5);SetIdentified(oItem, TRUE);
                        CreateItemOnObject("it_healing_kit", oPC, 1);
                        CreateItemOnObject("it_coin_counter", oPC, 1);
                        CreateItemOnObject("it_canteenf", oPC, 1);
                        oItem = CreateItemOnObject("it_healing_salv", oPC, 1); SetIdentified(oItem, TRUE);
                        CreateItemOnObject("it_waterskinf", oPC, 1);
                        CreateItemOnObject("crpi_graprope", oPC, 1);
                        CreateItemOnObject("crpi_spk_mallet", oPC, 1);
                        CreateItemOnObject("crpi_ironspikes", oPC, 10);
                        CreateItemOnObject("tinderbox", oPC, 1);
                        CreateItemOnObject("whetstone", oPC, 1);
                        CreateItemOnObject("tb_torch_oil", oPC, 10);
                        CreateItemOnObject("tb_torch_unlit", oPC, 1);
                        CreateItemOnObject("sewing_kit", oPC, 1);
                        CreateItemOnObject("rest_tent", oPC, 1);
                        CreateItemOnObject("rawchicken", oPC, 1);
                        CreateItemOnObject("kindling", oPC, 1);
                        CreateItemOnObject("kindling", oPC, 1);
                        CreateItemOnObject("fishingrod", oPC, 1);
                        CreateItemOnObject("dry_wood", oPC, 1);
                        CreateItemOnObject("cnrskinwolf", oPC, 1);
                        CreateItemOnObject("bedroll", oPC, 1);
                        oItem = CreateItemOnObject("it_holy_water", oPC, 1); SetIdentified(oItem, TRUE);
                        return TRUE;
                }
        }
        */
        
        /* Store PC location
        TODO 
        if (sCmnd == "store") {
        // Store the PC's current location
                object oArea = GetArea(oPC);
                vector v = GetPosition(oPC);
                SetPersistentFloat(oPC,"DEBLOC_X",v.x);
                SetPersistentFloat(oPC,"DEBLOC_Y",v.y);
                SetPersistentFloat(oPC,"DEBLOC_Z",v.z);
                SetPersistentFloat(oPC,"DEBLOC_O",GetFacing(oPC));
                SetPersistentString(oPC,"DEBLOC_A",GetTag(oArea));
                db("Stored location (area tag = " + GetTag(oArea) + " )");
                return TRUE;
        }

        if (sCmnd == "restore") {
        // jump to PC's saved location if any
                string sArea = GetPersistentString(oPC,"DEBLOC_A");
                object oArea = GetObjectByTag(sArea);
                if (GetIsObjectValid(oArea)) {
                        db("Jumping to stored location (area tag = " + sArea + " )");
                        float x = GetPersistentFloat(oPC,"DEBLOC_X");
                        float y = GetPersistentFloat(oPC,"DEBLOC_Y");
                        float z = GetPersistentFloat(oPC,"DEBLOC_Z");
                        float o = GetPersistentFloat(oPC,"DEBLOC_O");
                        location lLoc = Location(oArea,Vector(x,y,z),o);
                        AssignCommand(oPC, JumpToLocation(lLoc));
                } else {
                        db("Stored location not valid (area tag = " + sArea + " )");
                }
                return TRUE;
        }
        if (sCmnd == "unstore") {
        // remove the PCs saved location
                db("Clearing stored debug location.");
                DeletePersistentFloat(oPC,"DEBLOC_X");
                DeletePersistentFloat(oPC,"DEBLOC_Y");
                DeletePersistentFloat(oPC,"DEBLOC_Z");
                DeletePersistentFloat(oPC,"DEBLOC_O");
                DeletePersistentString(oPC,"DEBLOC_A");
                return TRUE;
        }
        */

        /* force Save of PC 
        if (sCmnd == "save") {
            // save the PC's info
                ExecuteScript("pw_do_op", oPC);
                return TRUE;
        }
        */

        /* Set default target of debug messages to this PC
        */
        if (sCmnd == "target") {
                object oTarg = oPC;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        sVal = GetStringLowerCase(sVal);
                        if (sVal == "show") {
                                oTarg = dbGetDebugPC();
                                db("debug target is (" + ObjectToString(oTarg) + " " + GetName(oTarg), -1, "", -1, nLog, oPC);
                                return TRUE;
                        }
                        if (sVal == "clear")
                                oTarg = OBJECT_INVALID;
                }
                dbSetDebugPC(oTarg);
                db("Set debug target to (" + ObjectToString(oTarg) + " " + GetName(oTarg), -1, "", -1, nLog, oPC);
                return TRUE;
        }

        /* give gold to PC */
        // TODO 
        if (sCmnd == "gold") {
                int nVal = 0;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                if (nVal == 0) nVal = 1000;
                GiveGoldToCreature(oPC, nVal);
                //tbGiveGold(oPC, nVal);
                db("debug Gold given: ", nVal ,"", -1 ,nLog,oPC);
                return TRUE;
        }

        /* coin system debug commands
        if (sCmnd == "coins") {
                int nVal = 0;
                string sType = "";
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        string sVal = GetNextToken(stTok);
                        nVal = StringToInt(sVal);
                }
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        sType = GetNextToken(stTok);
                        sType = GetStringLowerCase(sType); // these are resrefs and tags - must be lower.
                }

                if (nVal == 0) nVal = 1000;
                tbGiveGold(oPC, nVal, sType);
                db("debug Gold in Coins given: ", nVal ,"", -1 ,nLog,oPC);
                return TRUE;
        }
        */

        /* create the given item by resref on the PC */
        if (sCmnd == "citem") {
                if (!HasMoreTokens(stTok)) {
                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);

                int nStack = 1;
                if (HasMoreTokens(stTok)) {
                        stTok = AdvanceToNextToken(stTok);
                        nStack = StringToInt(GetNextToken(stTok));
                        if (nStack <= 0)
                                nStack = 1;
                }
                CreateItemOnObject(sVal, oPC, nStack);
                db("debug Creating item : " + sVal, -1 ," stack ", nStack ,nLog,oPC);
                return TRUE;
        }
        /* destroy first item with given resref. */
        if (sCmnd == "ditem") {
                if (!HasMoreTokens(stTok)) {
                        return TRUE;
                }
                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);

                DestroyNumItems(oPC, sVal, 1);
                db("debug destroying item : " + sVal, -1 ,"", -1 ,nLog,oPC);
                return TRUE;
        }

        /* Dump the nearest NPC data */
        if (sCmnd == "npc" ) {
                object oNPC =  GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,  PLAYER_CHAR_NOT_PC , oPC);
                if (GetIsObjectValid(oNPC)) {
                        dbg_dumpCreature(oNPC, nLog, oPC);
                }
                return TRUE;
        }
        /* Nuke - kill all nearby hostiles */
        if (GetStringLeft(sCmnd,2) == "nu" ) {
               int nHP;
                effect eDam;
                int nNth =1;
                object oNPC =  GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,  PLAYER_CHAR_NOT_PC , oPC, nNth++, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
                while (GetIsObjectValid(oNPC) && GetDistanceBetween(oNPC, oPC) < 20.0) {
                        nHP = GetCurrentHitPoints(oNPC);
                        db("Killing " + GetName(oNPC) + " damage " + IntToString(nHP));
                        AssignCommand(oPC, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nHP, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY), oNPC));
                       //AssignCommand(oPC, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oNPC));
                       oNPC =  GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,  PLAYER_CHAR_NOT_PC , oPC, nNth++, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
                }
                return TRUE;
        }
        /* Weapon system debug
        if (sCmnd == "weapon" || sCmnd == "wpn") {

                if (!HasMoreTokens(stTok)) {
                        DeleteLocalInt(oPC, "wpn_tmp_op");
                        ExecuteScript("wpn_do_op", oPC);
                        //wpnPrintWeapons(oPC);
                        return TRUE;
                }

                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);
                if (sVal == "rep" || sVal == "repair") {
                        SetLocalInt(oPC, "wpn_tmp_op", 2);
                        SetLocalObject(oPC, "wpn_tmp_item", GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }
                if (sVal == "break") {
                        // break weapon in right hand
                        SetLocalInt(oPC, "wpn_tmp_op", 4);
                        SetLocalObject(oPC, "wpn_tmp_item", GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }
                if (sVal == "wear") {
                        // Lower the level of weapon in right hand
                        SetLocalInt(oPC, "wpn_tmp_op", 3);
                        SetLocalObject(oPC, "wpn_tmp_item", GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }


                return TRUE;
        }
        */

        /* armor system debug
        if (sCmnd == "armor") {

                if (!HasMoreTokens(stTok)) {
                        DeleteLocalInt(oPC, "wpn_tmp_op");
                        ExecuteScript("wpn_do_op", oPC);
                        //wpnPrintArmor(oPC);
                        debugDumpArmor(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC), oPC);
                        return TRUE;
                }

                stTok = AdvanceToNextToken(stTok);
                string sVal = GetNextToken(stTok);
                sVal = GetStringLowerCase(sVal);
                if (sVal == "rep" || sVal == "repair") {
                        // repair armor
                        SetLocalInt(oPC, "wpn_tmp_op", 2);
                        SetLocalObject(oPC, "wpn_tmp_item", GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }
                if (sVal == "break") {
                        // break armor
                        SetLocalInt(oPC, "wpn_tmp_op", 4);
                        SetLocalObject(oPC, "wpn_tmp_item", GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }
                if (sVal == "wear") {
                        // Lower the level of armor
                        SetLocalInt(oPC, "wpn_tmp_op", 3);
                        SetLocalObject(oPC, "wpn_tmp_item", GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
                        ExecuteScript("wpn_do_op", oPC);
                        return TRUE;
                }


                return TRUE;
        }
        */

        return TRUE;
}

void dbg_dumpInventory(object oTarget, int nLog = TRUE, object oPC = OBJECT_INVALID) {


        db("Checking items:", -1, "", -1, nLog, oPC);
        object oItem = GetFirstItemInInventory(oTarget);
        int nCount = 0;
        while (GetIsObjectValid(oItem)) {
                nCount ++;
                db("", nCount,  ": " + GetName(oItem) + GetTag(oItem), -1, nLog, oPC);
                oItem = GetNextItemInInventory(oTarget);
        }
        db("Found ", nCount,  " items.", -1, nLog, oPC);
        int nSlot;
        db("Checking equipped items:", -1, "", -1, nLog, oPC);
        for (nSlot=0; nSlot<NUM_INVENTORY_SLOTS; nSlot++) {
                oItem=GetItemInSlot(nSlot, oTarget);
                if(GetIsObjectValid(oItem))
                        db("slot ", nSlot, " : " + GetName(oItem) + GetTag(oItem), -1, nLog, oPC);
        }
}


void dbg_dumpCreature(object oTarget, int nLog, object oPC) {
    object oMaster = GetMaster(oTarget);

    int iClass_1 = GetClassByPosition(1,oTarget);
    int iClass_2 = GetClassByPosition(2,oTarget);
    int iClass_3 = GetClassByPosition(3,oTarget);
    int iLevel_1 = GetLevelByPosition(1,oTarget);
    int iLevel_2 = GetLevelByPosition(2,oTarget);
    int iLevel_3 = GetLevelByPosition(3,oTarget);
    int iLevel_T = GetHitDice(oTarget);
    db("Appearance Type = ",GetAppearanceType(oTarget),"\nRacial Type = ",GetRacialType(oTarget),nLog,oPC);
    db("Class Position 1 = "+GetClassString(iClass_1)+" (",iClass_1,") Level = ",iLevel_1,nLog,oPC);
    db("Class Position 2 = "+GetClassString(iClass_2)+" (",iClass_2,") Level = ",iLevel_2,nLog,oPC);
    db("Class Position 3 = "+GetClassString(iClass_3)+" (",iClass_3,") Level = ",iLevel_3,nLog,oPC);
    db("Total Levels = ",iLevel_T,"\nCR Rateing = "+FloatToString(GetChallengeRating(oTarget)),-1,nLog,oPC);
    db("Hit Points = ",GetCurrentHitPoints(oTarget)," Out of ",GetMaxHitPoints(oTarget),nLog,oPC);
    db("Alignment = "+GetAlignString(oTarget),-1,"\nCommandable = ",GetCommandable(oTarget),nLog,oPC);
    db("Is a PC = ",GetIsPC(oTarget),"\nIs a DM = ",GetIsDM(oTarget),nLog,oPC);
    //db("Has a POST_ or WAYPOINTS = ",aww_GetIsPostOrWalking(oTarget),"",-1,nLog,oPC);
    if(GetIsObjectValid(oMaster)) {
        db("Has a Master:\n    Master Name = "+GetName(oMaster),-1,"    Master TAG = "+GetTag(oMaster),-1,nLog,oPC);
        db("    Master Is a PC = ",GetIsPC(oMaster),"",-1,nLog,oPC);
        }
    effect eEffect = GetFirstEffect(oTarget);
    int i = 1;
    while(GetIsEffectValid(eEffect)) {
        db("Effect ",i,":",-1,nLog,oPC);
        db("  Effect Type = ",GetEffectType(eEffect),"\n  Effect Subtype = ",GetEffectSubType(eEffect),nLog,oPC);
        db("  Effect Creator Name = "+GetName(GetEffectCreator(eEffect)),-1,"\n  Effect Creator TAG = "+GetTag(GetEffectCreator(eEffect)),-1,nLog,oPC);
        db("  Effect Duration Type = ",GetEffectDurationType(eEffect),"\n  Effect Spell ID = ",GetEffectSpellId(eEffect),nLog,oPC);
        eEffect = GetNextEffect(oTarget);
        i++;
        }
        if (GetIsPC(oTarget)) {
        // system related variables
        //db("rest_bedroll = ", GetIsObjectValid(GetLocalObject(oTarget, "rest_bedroll")),
        //   "  rest_tent =",GetIsObjectValid(GetLocalObject(oTarget, "rest_tent")), nLog, oPC);

        // plot related variables

                dbg_dumpInventory(oTarget);
                object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget);
                if (!GetIsObjectValid(oSkin)) {
                        db("PC has no skin equipped.", -1, "", -1, nLog, oPC);
                } else {
                        db("PC has skin " + GetTag(oSkin) + " equipped.", -1, "", -1, nLog, oPC);
                }
        } else {
                // NPC specific varaibles TBD
        }

        // this would dump oPCs current body parts by 2da line
        //SetLocalInt(oPC, "tlr_tmp_op", 1);
        //SetLocalObject(oPC, "tlr_tmp_obj", oTarget);
        //ExecuteScript("tlr_do_op", oPC);
}

void dbg_dumpArea(object oArea, location lTarget, object oPC, int nLog = FALSE) {


    if (!GetIsObjectValid(GetAreaFromLocation(lTarget)))
        lTarget = GetLocation(oPC);

    vector v = GetPositionFromLocation(lTarget);
        string sVector = FloatToString(v.x)+","+FloatToString(v.y)+","+FloatToString(v.z);
        string sFace = FloatToString(GetFacingFromLocation(lTarget));
    string sAreaT = GetTag(oArea);
        string sAreaN = GetName(oArea);
    db("Area Name = "+sAreaN,-1,"\nArea Tag = "+sAreaT,-1,nLog,oPC);
        db("Area Type = "+Area_AorU(oArea),-1," / "+Area_NorA(oArea),-1,nLog,oPC);
        db("Vector = "+sVector,-1,"\nFacing = "+sFace,-1,nLog,oPC);
        db("Distance = "+FloatToString(GetDistanceBetweenLocations(GetLocation(oPC),lTarget)),-1,"",-1,nLog,oPC);
        //db("PWH managed = ", GetLocalInt(oArea, "PW_MANAGED_AREA"), " Custom enter = '" + GetLocalString(oArea, "AREA_CUSTOM_ENTER") + "'.", -1, nLog, oPC);
        //db("tnp_weaponchk = ", GetLocalInt(oArea, "tnp_weaponchk"), " tnp_sneakchk = ", GetLocalInt(oArea, "tnp_sneakchk"), nLog, oPC);
        //db("tnp_hide_mod = ", GetLocalInt(oArea, "tnp_hide_modified"), " tnp_day_penalty = ", GetLocalInt(oArea, "tnp_day_penalty"), nLog, oPC);
        //db("rest_type " ,   GetLocalInt(oArea, "rest_type"), " rest_fire = ", GetLocalInt(oArea, "rest_fire"), nLog, oPC);
        //SetLocalInt(oPC, "weather_tmp_op", 1);
        //ExecuteScript("weather_do_op", oPC);
        //if (GetLocalInt(oArea, "nCommonerMax") > 0) {
        //        db("Max commoners " ,   GetLocalInt(oArea, "nCommonerMax"), " Current = ", GetLocalInt(oArea, "nCommonerCount"), nLog, oPC);
        //        db("Max subgroup " ,   GetLocalInt(oArea, "nCommonerMax2"), " current = ", GetLocalInt(oArea, "nCommonerCount2"), nLog, oPC);
        //        db("Num walkpoints " ,   GetLocalInt(oArea, "nWalkWayPoints"), "", -1, nLog, oPC);
        //}
}

void dbg_dumpModule(int nLog, object oPC) {

        object oModule = GetModule();

        db("Module Name = " +  GetName(oModule) , -1, "" ,-1,nLog,oPC);
        db("Debug = " , GetLocalInt(oModule, "DEBUG"), " DEBUGLEVEL = " + IntToHexString( GetLocalInt(oModule, "DEBUG_LEVEL"))
         + " DEBUG_LOG = " ,  GetLocalInt(oModule, "DEBUGLOG"), nLog, oPC);
        db("No Debug = " , GetLocalInt(oModule, "NO_DEBUG_MODE"), " Debug start = " + GetLocalString(oModule, "tbDebugStart") , -1, nLog, oPC);
        db("default_script = " + GetLocalString(oModule, "default_script"), -1, "SPELLSCRIPT = "
         +  GetLocalString(oModule, "X2_S_UD_SPELLSCRIPT"), -1, nLog, oPC);

        db("dawn hour = " ,  GetLocalInt(oModule, "tb_dawn_hour") -1, " dusk hour = ", GetLocalInt(oModule, "tb_dusk_hour") - 1 , nLog, oPC);
        db(" roundsPerMinute = ", GetLocalInt(GetModule(), "rounds_per_min"), " roundsPerHour = ",  GetLocalInt(GetModule(), "rounds_per_hour"), nLog, oPC);
        db(" roundsPerTen = ", GetLocalInt(GetModule(), "rounds_per_ten"), " hourstoseconds(1) = ", FloatToInt(HoursToSeconds(1)), nLog, oPC);

}

//void main() {}

