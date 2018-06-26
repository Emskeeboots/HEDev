//::///////////////////////////////////////////////
//:: _s0_clairaud
//:://////////////////////////////////////////////
/*
    NEW SPELL -- Clairaudience (rewritten) and renamed.

    CLAIRAUDIENCE
    Caster Level(s): Bard 2, Wiz/Sor 3, Knowledge 3
    Innate Level: 3
    School: Divination
    Component(s): Verbal
    Range: Unlimited
    Area of Effect / Target: Sensor
    Duration: 1 Min/Level + 1 Min/Spellcraft
    Additional Counter Spells: Blindness / Deafness
    Save: None
    Spell Resistance: No

    For the duration of the spell, the caster creates an invisible, magic sensor at a fixed location.
    The location must be on the same plane of existence, and meet one of the
    following conditions: accessed through spell focus targeted by the caster,
    visible at the time of casting, or on the other side of a targeted door.
    The sensor enables the caster to eavesdrop upon the location.
    The caster's Spellcraft skill is used in place of their Listen skill for all Listen checks
    made through the magic sensor.

    This spell renders the caster vulnerable to sonic attacks that target the magic ear. Any creature that makes a DC 20 Scry check will notice the magic ear. The caster can dispel the effect at any time with the chat command "/dispel" or "/scry end".

    This spell automatically fails if a target location is warded from scrying.


*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 9)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_constants"
#include "_inc_spells"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();
    object oMod     = GetModule();
    //int nScrySkill = GetSkillRank(SKILL_SCRY, OBJECT_SELF);
    int nScrySkill = GetSkillRank(SKILL_SPELLCRAFT, OBJECT_SELF);
    // THE MAGUS'S SPELL FOCUS SYSTEM ------------------------------------------
    if(GetLocalInt(OBJECT_SELF, SPELLFOCUS_USE))
    {
        object oTarget;
        object oFocus   = GetLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);
        object oAreaAlt;
        int nType       = GetLocalInt(oFocus, SPELLFOCUS_TYPE);
        if(nType==1)
            spell.Loc   = GetSpellFocusLocation(oFocus);
        else if(nType==2)
        {
            spell.Target= GetLocalObject(oFocus, SPELLFOCUS_CREATURE);
            spell.Loc   = GetLocation(spell.Target);
        }
        else if(nType==3)
        {
            spell.Target= GetPCByPCID(GetLocalString(oFocus, SPELLFOCUS_CREATURE));
            spell.Loc   = GetLocation(spell.Target);
        }

        oAreaAlt        = GetAreaFromLocation(spell.Loc);
        // garbage collection
        DeleteLocalInt(OBJECT_SELF, SPELLFOCUS_USE);
        DeleteLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT);

        if(GetIsObjectValid( oAreaAlt ))
        {
            if(GetIsScryTargetWarded(spell.Loc, spell.Target))
            {
                SendMessageToPC(OBJECT_SELF, PINK+"Your target is currently protected from scrying.");
                effect eFail    = EffectVisualEffect(VFX_FNF_DISPEL);
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFail, GetLocation(OBJECT_SELF));
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFail, spell.Loc);
                return;
            }
            // SUCCESS
            else
            {
                // since we have a location... lets cancel out the target object
                // this helps shortcut the door check later on.
                spell.Target    = OBJECT_INVALID;

                SendMessageToPC(OBJECT_SELF, DMBLUE+"Success: Scry sensor for clairaudience created in "+GetName(oAreaAlt)+".");

                // FUTURE dev special focuses that improve the scry
            }

            if(SPELLFOCUS_ONE_USE)
                DestroyObject(oFocus, 0.5);
        }
        else
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: Scry sensor was not transmitted.");
            return;
        }

    }
    // END THE MAGUS'S SPELL FOCUS SYSTEM --------------------------------------


    // continue with target handling
    if(GetIsObjectValid(spell.Target))
    {
        // Door Check
        if(GetObjectType(spell.Target)==OBJECT_TYPE_DOOR)
        {
            // when targetting a door, place scry sensor on other side of door
            object oDest    = GetTransitionTarget(spell.Target);
            if(GetIsObjectValid(oDest))
            {
                if(GetObjectType(oDest)== OBJECT_TYPE_DOOR)
                {
                    vector vNewPos;
                    float fFace = GetFacing(oDest);
                    if (fFace<180.0)
                        fFace=fFace+179.9;
                    else
                        fFace=fFace-179.9;

                    vNewPos     = GetPosition(oDest) +  AngleToVector(fFace);
                    spell.Loc   = Location(
                                            GetArea(oDest),
                                            vNewPos,
                                            fFace
                                          );
                }
                else
                    spell.Loc   = GetLocation(oDest);

            } // End door transitions to other area
            else
            {
                vector vCaster = GetPosition(OBJECT_SELF);
                vector vDoor = GetPosition(spell.Target);
                vector vDoorFromCaster = vDoor-vCaster;
                vector vPastDoor1M = vDoor + VectorNormalize(vDoorFromCaster);
                spell.Loc = Location(
                                        GetArea(spell.Target),
                                        vPastDoor1M,
                                        VectorToAngle(vDoorFromCaster)
                                    );
            }
        } // end door check
        // non-doors
        else
            spell.Loc = GetLocation(spell.Target);
    }

    // Is the target protected from scrying
    if(GetIsScryTargetWarded(spell.Loc, spell.Target))
    {
        SendMessageToPC(OBJECT_SELF, PINK+"Your target is currently protected from scrying.");
        effect eFail    = EffectVisualEffect(VFX_FNF_DISPEL);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFail, GetLocation(OBJECT_SELF));
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFail, spell.Loc);
        return;
    }

    // Cancel previous castings of this spell
    if(GetHasSpellEffect(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, OBJECT_SELF))
    {
        //int nScryId     = GetLocalInt(GetLocalObject(OBJECT_SELF, "SCRY_SENSOR"), "SCRY_ID");
        object oSensor  = GetLocalObject(OBJECT_SELF, "SCRY_SENSOR");
        object oCaster  = OBJECT_SELF;
        AssignCommand(oSensor, ClairaudienceEnd(oCaster));
        SendMessageToPC(OBJECT_SELF, PINK+"You can only concentrate on one scry sensor at a time."
                +" Casting a new scry spell has caused your existing sensor to fade away.");
    }

    //Effects
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_MIND);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eEar = EffectAreaOfEffect(AOE_PER_CLAIRAUDIENCE);

    // Duration
    int nLevel = GetCasterLevel(OBJECT_SELF);
    int nDuration;
    int nMetaMagic = GetMetaMagicFeat();
    nDuration = nLevel+nScrySkill; // more time to those with high scry skills
    if(nDuration<1)
        nDuration = 1;
    //Meta-Magic checks
    if(nMetaMagic == METAMAGIC_EXTEND)
        nDuration *= 2;
    float fDuration = TurnsToSeconds(nDuration);


    // Create Scry Sensor
    object oSensor  = CreateObject(OBJECT_TYPE_CREATURE, SCRY_SENSOR_REF, spell.Loc);
    // initialize Sensor
    SetLocalInt(oSensor, "SCRY_SPELL", SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE);
    SetLocalObject(oSensor, "CREATOR", OBJECT_SELF);
    SetLocalObject(oSensor, "SCRY_PC", OBJECT_SELF);
    SetLocalInt(oSensor, "LEVEL", nLevel);
    SetLocalInt(oSensor, "SCRY_LISTEN", nScrySkill ); // listen ability is based on caster's scry rank

    // Give sensor a perception skill
    effect eListen  = EffectSkillIncrease(SKILL_LISTEN, nScrySkill);
    effect eSpot    = EffectSkillIncrease(SKILL_SPOT, nScrySkill);
    effect eLink    = EffectLinkEffects(eListen, eSpot);

    // Apply AOE at location of sensor
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eEar, spell.Loc, fDuration);

    // Apply perception effect To Sensor
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oSensor, fDuration);

    // initialize Caster
    SetLocalObject(OBJECT_SELF, "SCRY_SENSOR", oSensor);
    SetLocalInt(OBJECT_SELF, "SCRYING", 1);// can still talk. see GetCanNotSpeak() file: _inc_languages
    //Apply effects to caster
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, OBJECT_SELF, fDuration);

    // track AOE on sensor
    object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oSensor);
    SetLocalObject(oSensor, "PAIRED", oAOE);
    SetLocalObject(oAOE, "PAIRED", oSensor);
    SetLocalInt(oSensor, "PAIRED", 1);
}
