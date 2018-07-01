//::///////////////////////////////////////////////
//:: _ai_scrysensor
//:://////////////////////////////////////////////
/*
    SCRY SENSOR On User Defined Event script
    this uses the v2_ai_mg_* set of ai scripts for other events

    pre and post spawn events set with
    Local Int "X2_USERDEFINED_ONSPAWN_EVENTS"
    1 = Pre Spawn
    2 = Post Spawn
    3 = Both Pre and Post Spawn

    Identify other userdef events
    in the postspawn event.

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 20)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_switches"
#include "x0_i0_anims"

#include "_inc_constants"
#include "_inc_util"
#include "_inc_spells"
#include "_inc_xp"

const int EVENT_USER_DEFINED_PRESPAWN = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN = 1511;

int GetKnowsCreatureType(object oCaster, object oCreature);
string GetCreatureTypeDescription(object oCaster, object oCreature);
// used OnSpawn to understand which creatures are audible near the sensor
void DetectCreaturesNearSensor();

int GetKnowsCreatureType(object oCaster, object oCreature)
{
    if(GetLocalInt(oCreature, ObjectToString(oCaster)+"_IDENTIFIED_TYPE"))
        return TRUE;

    int nCRace  = GetRacialType(oCaster); // caster's race - making racist assumptions about caster's background
    int nRace   = GetRacialType(oCreature);
    int nAppear = GetAppearanceType(oCreature);

    if(nRace==nCRace)
        return TRUE;

    if(nCRace==RACIAL_TYPE_GNOME)
    {
        /*
        // earth
        if( nAppear==56 || nAppear==57
            || nAppear==107 || nAppear==108 || nAppear==114
          )
        {
            return TRUE;
        }
        */

        if(nRace==RACIAL_TYPE_CONSTRUCT)
            return(     GetIsSkillSuccessful(oCaster,SKILL_LORE,10)
                    ||  GetIsSkillSuccessful(oCaster,SKILL_SPELLCRAFT,10)
                  );

    }
    /*
    if(nCRace==RACIAL_TYPE_ELF && nRace==RACIAL_TYPE_FEY)
    {
        return GetIsSkillSuccessful(oCaster, SKILL_LORE, 15);
    }
    */
    if(GetFavoredEnemyBonus(oCaster, oCreature))
        return TRUE;
    if(GetLevelByClass(CLASS_TYPE_DRUID, oCaster))
    {
        if(nRace == RACIAL_TYPE_ANIMAL)
            return TRUE;
        else if(nRace == RACIAL_TYPE_BEAST)
            return GetIsSkillSuccessful(oCaster, SKILL_LORE, 10);
        else if(nRace == RACIAL_TYPE_MAGICAL_BEAST)
            return GetIsSkillSuccessful(oCaster, SKILL_LORE, 15);
        if(     (nAppear>=5063 && nAppear<=5072)
            ||  (nAppear>=5079 && nAppear<=5081)
            ||  (nAppear>=5010 && nAppear<=5014)
            ||  nAppear==5020
            ||  (nAppear>=942 && nAppear<=944)
            ||  nAppear==923
          )
            return TRUE;
    }
    if( nRace==RACIAL_TYPE_OUTSIDER
        &&  (       GetLevelByClass(CLASS_TYPE_CLERIC, oCaster)
                ||  GetLevelByClass(CLASS_TYPE_PALADIN, oCaster)
                ||  GetLevelByClass(CLASS_TYPE_MONK, oCaster)
            )
      )
    {
        return GetIsSkillSuccessful(oCaster, SKILL_LORE, 20);
    }

    if(nRace<=6 || nRace==RACIAL_TYPE_ANIMAL)
        return GetIsSkillSuccessful(oCaster, SKILL_LORE, 10);
    else if(nRace==RACIAL_TYPE_BEAST)
        return GetIsSkillSuccessful(oCaster, SKILL_LORE, 15);
    else if(nRace==RACIAL_TYPE_MAGICAL_BEAST)
        return GetIsSkillSuccessful(oCaster, SKILL_LORE, 25);
    else if(nRace==RACIAL_TYPE_CONSTRUCT)
        return GetIsSkillSuccessful(oCaster, SKILL_SPELLCRAFT, 15);
    else if(nRace==RACIAL_TYPE_FEY || nRace==RACIAL_TYPE_HUMANOID_GOBLINOID)
        return GetIsSkillSuccessful(oCaster, SKILL_LORE, 20);

    return GetIsSkillSuccessful(oCaster, SKILL_LORE, 30);
}

string GetCreatureTypeDescription(object oCaster, object oCreature)
{
    string sDescription;

    if(GetObjectType(oCreature)!=OBJECT_TYPE_CREATURE)
        return GetName(oCreature);

    int bKnowsIndividual;
    if(GetMeetings(oCaster, oCreature))
        bKnowsIndividual    = 1;
    int bKnowsType          = GetKnowsCreatureType(oCaster, oCreature);
    if(bKnowsType)
        SetLocalInt(oCreature, ObjectToString(oCaster)+"_IDENTIFIED_TYPE", TRUE);
    int cRace               = GetRacialType(oCaster);
    int nSize               = GetCreatureSize(oCreature);
    int nRace               = GetRacialType(oCreature);
    int nType               = GetAppearanceType(oCreature);

    string sSize;
    switch(nSize)
    {
        case CREATURE_SIZE_TINY: sSize = " tiny"; break;
        case CREATURE_SIZE_SMALL: sSize = " small"; break;
        case CREATURE_SIZE_LARGE: sSize = " large"; break;
        case CREATURE_SIZE_HUGE: sSize = " huge"; break;
        default: break;
    }

    string sRace;
    switch(nRace)
    {
        case RACIAL_TYPE_HALFELF:
        case RACIAL_TYPE_HALFLING:
        case RACIAL_TYPE_DWARF:
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFORC:
            sRace = " person";
        break;
        case RACIAL_TYPE_FEY:
        case RACIAL_TYPE_HUMANOID_GOBLINOID:
            if(     cRace==RACIAL_TYPE_GNOME
                ||  cRace==RACIAL_TYPE_ELF
              )
                sRace = " person";
            else
                sRace = " humanoid";
        break;
        case RACIAL_TYPE_HUMANOID_MONSTROUS:
        case RACIAL_TYPE_HUMANOID_ORC:
        case RACIAL_TYPE_HUMANOID_REPTILIAN:
        case RACIAL_TYPE_GIANT:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_SHAPECHANGER:
        case RACIAL_TYPE_ANIMAL:
        case RACIAL_TYPE_BEAST:
        case RACIAL_TYPE_MAGICAL_BEAST:
        case RACIAL_TYPE_OUTSIDER:
        case RACIAL_TYPE_UNDEAD:
            sRace = " "+Get2DAString("appearance","NAME",nType);
        break;
        case RACIAL_TYPE_CONSTRUCT:
            sRace = " thing";
        break;
        case RACIAL_TYPE_DRAGON:
            sRace = " dragon";
        break;
        case RACIAL_TYPE_OOZE:
            sRace = " wet thing";
        break;
        case RACIAL_TYPE_VERMIN:
            sRace = " bug";
        break;
        case RACIAL_TYPE_ABERRATION:
            sRace = " monster";
        break;
        default:sRace = " creature"; break;
    }

    switch(bKnowsType+bKnowsIndividual)
    {
        case 0:
            sDescription = "a"+sSize+" creature";
        break;
        case 1:
            sDescription = "a"+sSize+sRace;
        break;
        case 2:
            sDescription = GetName(oCreature);
        break;
        default:
            sDescription = "a"+sSize+" creature";
        break;
    }

    if(sDescription=="")
        sDescription = " something";

    return sDescription;
}

void DetectCreaturesNearSensor()
{
    string sArea        = LIME+"["+GREEN+GetName(GetArea(OBJECT_SELF))+LIME+"] ";
    string sDesc        = " is near the sensor.";
    object oCaster      = GetLocalObject(OBJECT_SELF, "CREATOR");
    location lLoc       = GetLocation(OBJECT_SELF);
    object oCreature    = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lLoc, TRUE);
    while(GetIsObjectValid(oCreature))
    {
        if(oCreature!=OBJECT_SELF)
        {
            SetAILevel(oCreature, AI_LEVEL_NORMAL);
            if( GetObjectHeard(oCreature, OBJECT_SELF)||GetObjectSeen(oCreature, OBJECT_SELF))
                SendMessageToPC(oCaster, sArea+GetCreatureTypeDescription(oCaster, oCreature)+sDesc);
        }

        oCreature    = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lLoc, TRUE);
    }
}

void main()
{
    int nUser       = GetUserDefinedEventNumber();

    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {
        int nSpellId    = GetLocalInt(OBJECT_SELF, "SCRY_SPELL");
        object oCreator = GetLocalObject(OBJECT_SELF, "CREATOR");
        if(!GetHasSpellEffect(nSpellId, oCreator))
        {
            ClairaudienceEnd(oCreator);
        }
    }
    else if(nUser == EVENT_PERCEIVE) // PERCEIVE
    {
        // Initialize Event Vars
        object oPercep  = GetLocalObject(OBJECT_SELF, "USERD_PERCEIVED");
        int bSeen       = GetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_SEEN");
        int bHeard      = GetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_HEARD");
        int bVanished   = GetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_VANISHED");
        int bInaudible  = GetLocalInt(OBJECT_SELF, "USERD_PERCEIVED_INAUDIBLE");

        int bIncorporeal= GetCreatureFlag(oPercep, CREATURE_VAR_IS_INCORPOREAL);
        if( !bIncorporeal)
        {
            object oCaster  = GetLocalObject(OBJECT_SELF, "CREATOR");
            string sArea    = LIME+"["+GREEN+GetName(GetArea(OBJECT_SELF))+LIME+"] ";
            string sCreature= GetCreatureTypeDescription(oCaster, oPercep);
            string sMsg     = sArea + sCreature;
            if(bHeard || bSeen)
                sMsg += " moves around.";
            else if(bVanished || bInaudible)
                sMsg += " moves out of earshot.";
            if(sMsg!="")
                SendMessageToPC(oCaster, sMsg);
        }

        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_PERCEIVED");
        DeleteLocalInt(OBJECT_SELF, "USERD_PERCEIVED_SEEN");
        DeleteLocalInt(OBJECT_SELF, "USERD_PERCEIVED_HEARD");
        DeleteLocalInt(OBJECT_SELF, "USERD_PERCEIVED_VANISHED");
        DeleteLocalInt(OBJECT_SELF, "USERD_PERCEIVED_INAUDIBLE");
    }
    else if(nUser == EVENT_DIALOGUE) // ON DIALOGUE
    {
        // Initialize Event Vars
        object oShouter = GetLocalObject(OBJECT_SELF, "USERD_LAST_SHOUTER");
        object oCaster  = GetLocalObject(OBJECT_SELF, "CREATOR");
        if( oShouter==oCaster)
            return;
        int nMatch      = GetLocalInt(OBJECT_SELF, "USERD_LISTEN_PATTERN_NUMBER");
        string sMatch   = GetLocalString(OBJECT_SELF, "USERD_LISTEN_PATTERN_MATCH");
        string sConv;
        object oCreature= oShouter;

        if(nMatch==0)
            sConv   = ": "+GREY+sMatch;
        else if(nMatch==1) // shouter attacked
            sConv   = " is attacked.";
        else if(nMatch==3) // shouter died
            sConv   = " dies.";
        else if(nMatch==10) // shouter bashed by creature
        {
            oCreature   = GetLocalObject(OBJECT_SELF,SHOUT_PLACEABLE_ATTACKED);
            sConv       = " bashes a "+GetName(oShouter)+".";
        }
        else if(nMatch==11) // shouter destroyed by creater
        {
            oCreature   = oShouter;
            sConv       = " is destroyed.";
        }
        //else if(nMatch==101) // inventory
        //    sConv   = " rumaged through.";
        else if(nMatch==1000) // spell cast
            sConv   = " casts a spell.";
        else if(nMatch==1001) // spell bard song
            sConv   = " sings.";
        else if(nMatch==1002) // spell howl
            sConv   = " howls.";

        if(sConv!="")
        {
            SendMessageToPC(oCaster,
                LIME+"["+GREEN+GetName(GetArea(oShouter))+LIME+"] "     // area
                + GetCreatureTypeDescription(oCaster, oCreature)        // creature
                + sConv                                                 // said
                );
        }

        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_LAST_SHOUTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LISTEN_PATTERN_NUMBER");
        DeleteLocalString(OBJECT_SELF, "USERD_LISTEN_PATTERN_MATCH");
    }
    else if(nUser == EVENT_ATTACKED) // ATTACKED
    {
        // Initialize Event Vars
        //object oAttacker= GetLocalObject(OBJECT_SELF, "USERD_ATTACKER");

        SurrenderToEnemies();

        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_ATTACKER");
    }
    else if(nUser == EVENT_SPELL_CAST_AT) // SPELL CAST AT
    {
        // Initialize Event Vars
        int nSpellID    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        object oCaster  = GetLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        int bHarmful    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");

        int nLevel      = GetCasterLevel(oCaster);
        object oCreator = GetLocalObject(OBJECT_SELF, "CREATOR");
        int nDC         = GetLocalInt(OBJECT_SELF, "LEVEL")+11;

        // If dispelled
        if(DispelObject(nSpellID, nLevel, nDC))
        {
            int nScrySpellId    = GetLocalInt(OBJECT_SELF, "SCRY_SPELL");
            //int nScryId         = GetLocalInt(OBJECT_SELF, "SCRY_ID");

            // each scry spell ends differently... handle that here
            if(nScrySpellId==SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE)
                ClairaudienceEnd(oCreator);
        }

        // Garbage Collection
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        DeleteLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");
    }
    else if (nUser == 5550) // enter AOE
    {
        object oPercep  = GetLocalObject(OBJECT_SELF, "USERD_ENTER");
        object oCaster  = GetLocalObject(OBJECT_SELF, "CREATOR");
        string sArea    = LIME+"["+GREEN+GetName(GetArea(oPercep))+LIME+"] ";
        string sCreature= GetCreatureTypeDescription(oCaster, oPercep);
        string sMsg     = sArea + sCreature + " moves near the sensor.";
        SendMessageToPC(oCaster, sMsg);
        DeleteLocalObject(OBJECT_SELF, "USERD_ENTER");
    }
    else if (nUser == 5551) // exit AOE
    {
        object oPercep  = GetLocalObject(OBJECT_SELF, "USERD_EXIT");
        object oCaster  = GetLocalObject(OBJECT_SELF, "CREATOR");
        string sArea    = LIME+"["+GREEN+GetName(GetArea(oPercep))+LIME+"] ";
        string sCreature= GetCreatureTypeDescription(oCaster, oPercep);
        string sMsg     = sArea + sCreature + " moves away from the sensor.";
        SendMessageToPC(oCaster, sMsg);
        DeleteLocalObject(OBJECT_SELF, "USERD_EXIT");
    }
    else if (nUser == EVENT_USER_DEFINED_PRESPAWN)
    {

    }
    else if (nUser == EVENT_USER_DEFINED_POSTSPAWN)
    {
        effect eVFX     = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
        effect eInvis   = EffectEthereal();
               eInvis   = EffectLinkEffects(eVFX,eInvis);
               eInvis   = SupernaturalEffect(eInvis);
        effect eGhost   = EffectCutsceneGhost();
               eGhost   = SupernaturalEffect(eGhost);

        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eInvis, OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, OBJECT_SELF);

        // ***** CUSTOM USER DEFINED EVENTS ***** /
        // * 1001 - EVENT_HEARTBEAT
        SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);
        // * 1002 - EVENT_PERCEIVE
        SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);
        // * 1004 - EVENT_DIALOGUE
        SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);
        // * 1005 - EVENT_ATTACKED
        SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);
        // * EVENT_SPELL_CAST_AT
        SetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT);


        SetListening(OBJECT_SELF, TRUE);
        CreatureSetCommonListeningPatterns();

        SetListenPattern(OBJECT_SELF, TAG_MAGIC+"**"+"SPELL"+"**", 1000);
        SetListenPattern(OBJECT_SELF, TAG_MAGIC+"**"+"BARD"+"**", 1001);
        SetListenPattern(OBJECT_SELF, TAG_MAGIC+"**"+"HOWL"+"**", 1002);

        SetListenPattern(OBJECT_SELF, "**", 0); // everything else

        SetAILevel(OBJECT_SELF, AI_LEVEL_NORMAL);

        DelayCommand(2.0, DetectCreaturesNearSensor());
    }
}
