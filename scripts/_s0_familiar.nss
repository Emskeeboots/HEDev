//::///////////////////////////////////////////////
//:: _s0_familiar
//:://////////////////////////////////////////////
/*
    Bind Familiar
    Caster Level(s): Wizard / Sorcerer 0
    Innate Level: 0
    School: Necromancy
    Component(s): Verbal, Somatic
    Range: Touch
    Area of Effect / Target: One Animal of the right type
    Duration: Instant
    Additional Counter Spells: None
    Save: Special
    Spell Resistance: No

    This spell has the following uses:
    (1) Restore Familiar. This use costs 200xp per wizard/sorcerer level. When a familiar
    dies a wizard may cast this spell on another animal of like type and thus restore their ability
    to summon a familiar. Otherwise the wizard has to wait until they level up and gain a new familiar.
    (2) Transfer Familiar's consciousness from one form to another. Most familiar types
    can take different forms. Crows and parrots for example are different forms of the
    same familiar type. A wizard with a crow familiar can also have a parrot familiar,
    and most domesticable cats are equivalent with one another as well.

    Use: The wizard or sorcerer must first find an animal of the right type, and target
    it with this spell. If the animal is unwilling or the animal is not of the right
    type, the spell will fail. Most animals however, are not intelligent enough to resist.
    A failed spell does not cost the spellcaster any XP.
*/
//:://////////////////////////////////////////////
//:: Created: The Magus (2013 jan 5)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"
#include "x0_i0_spells"

#include "_inc_util"
#include "_inc_xp"
// THE MAGUS' INNOCUOUS FAMILIARS
#include "_inc_pets"

// Determine if the spell is considered hostile by the target  - [FILE: _s0_familiar]
// intelligent creatures or creaures with spell resistance, must opt to consider the spell non-hostile
// this is done by setting a local integer with a flag specific to the caster on the creature
int GetIsBindFamiliarHostile(object oTarget);
// Determine if the spell is resisted  - [FILE: _s0_familiar]
// performs pre-checks as certain spells will resist even if the spell is not hostile
int GetResistBindFamiliar(object oTarget, int bHostile);

int GetIsBindFamiliarHostile(object oTarget)
{
    // Override
    if( oTarget==OBJECT_SELF || GetLocalInt(oTarget, "FAMILIAR_ALLOW_BIND") )// do not treat the spell as hostile
        return FALSE;

    // Reactions to specific caster
    string sPCID    = GetPCID(OBJECT_SELF);
    if( GetLocalInt(oTarget, "DISALLOW_"+sPCID) )   // creature does not want to be caster's familiar, treats spell as hostile
        return TRUE;
    else if( GetLocalInt(oTarget, "ALLOW_"+sPCID) ) // creature agrees to be caster's familiar, and so will not treat spell as hostile
        return FALSE;

    // Typical situation
    // only creatures with greater than 5 intelligence treat Bind Familiar as hostile
    else
        return (GetAbilityScore(oTarget, ABILITY_INTELLIGENCE)>5);
}

int GetResistBindFamiliar(object oTarget, int bHostile)
{
    if(oTarget==OBJECT_SELF)
        return FALSE;

    if(bHostile)
        return MyResistSpell(OBJECT_SELF, oTarget, 0.25);

    int nGoodEvil   = GetAlignmentGoodEvil(OBJECT_SELF);
    if(     (   (nGoodEvil==ALIGNMENT_EVIL || nGoodEvil==ALIGNMENT_NEUTRAL)
                &&(     GetHasSpellEffect( SPELL_PROTECTION_FROM_EVIL , oTarget)
                    ||  GetHasSpellEffect( SPELL_MAGIC_CIRCLE_AGAINST_EVIL , oTarget)
                  )
            )
            ||
            (   (nGoodEvil==ALIGNMENT_GOOD || nGoodEvil==ALIGNMENT_NEUTRAL)
                &&(     GetHasSpellEffect( SPELL_PROTECTION_FROM_GOOD , oTarget)
                    ||  GetHasSpellEffect( SPELL_MAGIC_CIRCLE_AGAINST_GOOD , oTarget)
                  )
            )
      )
    {
        if(GetIsSkillSuccessful(OBJECT_SELF, SKILL_SPELLCRAFT, 15))
            SendMessageToPC(OBJECT_SELF, PALEBLUE+GetName(oTarget)+DMBLUE+" is shielded by a "+PALEBLUE+"protection from alignment"+DMBLUE+" spell.");
        else
            SendMessageToPC(OBJECT_SELF, PALEBLUE+GetName(oTarget)+DMBLUE+" is protected by a spell.");

        DelayCommand(0.25, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SPELL_MANTLE_USE), oTarget));
        return 2;
    }
    else if( GetHasSpellEffect( SPELL_DEATH_WARD , oTarget) )
    {
        if(GetIsSkillSuccessful(OBJECT_SELF, SKILL_SPELLCRAFT, 24))
            SendMessageToPC(OBJECT_SELF, PALEBLUE+GetName(oTarget)+DMBLUE+" is protected by the "+PALEBLUE+"death ward"+DMBLUE+" spell.");
        else
            SendMessageToPC(OBJECT_SELF, PALEBLUE+GetName(oTarget)+DMBLUE+" is protected by a spell.");

        DelayCommand(0.25, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), oTarget));
        return 2;
    }
    else if(    GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, oTarget)
            ||  GetHasSpellEffect( SPELL_SPELL_MANTLE , oTarget)
            ||  GetHasSpellEffect( SPELL_LESSER_SPELL_MANTLE , oTarget)
            ||  GetHasSpellEffect( SPELL_GREATER_SPELL_MANTLE , oTarget)
           )
    {
        return MyResistSpell(OBJECT_SELF, oTarget, 0.25);
    }

    return 0;
}

void main()
{
    // Spellcast Hook Code
    if (!X2PreSpellCastCode())
        return;// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell

    if ( !GetIsObjectValid(OBJECT_SELF) )
    {
        WriteTimestampedLogEntry("ERR: _s0_familiar - invalid caster");
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    // Intitialize
    int nFamType        = GetFamiliarCreatureType(OBJECT_SELF);
    int bFamDead        = GetSkinInt(OBJECT_SELF, FAMILIAR_DEAD);
    int nRace           = GetRacialType(spell.Target);
    int bHostileSpell   = GetIsBindFamiliarHostile(spell.Target);
    int nXPCost;
    effect eVFXFail     = EffectVisualEffect(VFX_IMP_HEAD_EVIL, TRUE);

    SignalEvent(spell.Target, EventSpellCastAt(OBJECT_SELF, SPELL_BIND_FAMILIAR, bHostileSpell));

    if(bFamDead)
    {
        nXPCost         = spell.Level*FAMILIAR_XP_LOST_PER_LEVEL;
        int nNewXP      = GetXP(OBJECT_SELF) - nXPCost;
        int nShort      = XPGetPCNeedsToLevel(OBJECT_SELF, FALSE)-nNewXP;
        if(nShort<0 || nNewXP<0)
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: you need "+PINK+IntToString(abs(nShort))
                        +RED+" more XP before you can reincarnate your familiar."
                );
            return;
        }
    }



    // Check Typical Failures
    if( nFamType==FAMILIAR_CREATURE_TYPE_NONE )
    {
        SendMessageToPC(OBJECT_SELF, RED+"Fail: you can not have a familiar.");
        return;
    }
    else if(spell.Target==OBJECT_SELF)
    {
        if(!bFamDead)
        {
            SendMessageToPC(OBJECT_SELF, RED+"Fail: your familiar does not need to be reincarnated.");
            return;
        }
    }
    else if(    GetIsObjectValid(GetMaster(spell.Target))
            ||  GetPlotFlag(spell.Target)
            ||  GetIsPossessedFamiliar(spell.Target)
            ||  GetIsPC(spell.Target)
            ||  GetHasEffect(EFFECT_TYPE_POLYMORPH,spell.Target)
           )
    {
        SendMessageToPC(OBJECT_SELF, RED+"Fail: the "+PINK+GetName(spell.Target)+RED+" is unwilling.");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);

        if(GetIsDMPossessed(spell.Target))
            SendMessageToPC(spell.Target, PINK+"Bind Familiar automatically fails on DM Possessed creatures.");
        return;
    }

    /*
    else if(   (nRace==RACIAL_TYPE_ELEMENTAL && !bHostileSpell)
            ||  nRace==RACIAL_TYPE_UNDEAD
            ||  nRace==RACIAL_TYPE_VERMIN
            ||  nRace==RACIAL_TYPE_OOZE
            || (nRace==RACIAL_TYPE_CONSTRUCT && !GetLocalInt(spell.Target, FAMILIAR_CONSTRUCT))
           )
    {
        SendMessageToPC(OBJECT_SELF, RED+"Fail: your target is an innappropriate vessel for your mind.");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);
        return;
    }
    */


    // Spell Resistance and saving throws --------------------------------------
    int nResist = GetResistBindFamiliar(spell.Target, bHostileSpell);
    int nDC     = GetSpellSaveDC();

    // responses may be all the same, but separating them
    // allows a builder to customize this
    if(nResist==1)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);
        return;
    }
    else if(nResist==2)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);
        return;
    }
    else if(nResist==3)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);
        return;
    }

    // saving throw if spell is "hostile"
    if(bHostileSpell && WillSave(spell.Target, nDC, SAVING_THROW_TYPE_MIND_SPELLS))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);
        return;
    }

    // Check for a familiar type
    int nFamIndex;
    if(spell.Target==OBJECT_SELF)
        nFamIndex   = GetSkinInt(OBJECT_SELF,FAMILIAR_INDEX);
    else
        nFamIndex   = GetFamiliarIndex(spell.Target);

    // FAMILIAR_INDEX = -1 can be set on a creature as a local, if this specific creature can NOT be a familiar
    if(nFamIndex==-1)
    {
        SendMessageToPC(OBJECT_SELF, RED+"Fail: "+PINK+GetName(spell.Target)+RED+" can not be bound as a familiar.");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);
        return;
    }

    // Check For Compatibility
    if(GetIsCompatibleFamiliar(spell.Target,OBJECT_SELF))
    {
        // if old familiar is present... it leaves
        if(GetLocalInt(OBJECT_SELF, FAMILIAR_SUMMONED))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,
                                EffectDisappear(),

                                // Only one of the following should be used. See FamiliarSpawnEvent(object oMaster)
                                //GetAssociate(ASSOCIATE_TYPE_FAMILIAR)// more_efficient_familiar
                                GetLocalObject(OBJECT_SELF, FAMILIAR)// more_flexible_familiar

                               );
            DoFamiliarDespawnEvent(OBJECT_SELF);
        }

        // XP Cost for reincarnating a familiar
        if(nXPCost)
            XPPenalty(OBJECT_SELF, nXPCost, RED+"Reincarnating your familiar costs "+YELLOW+IntToString(nXPCost)+RED+" XP!");

        // Update Data ......
        if(bFamDead)
            DeleteSkinInt(OBJECT_SELF, FAMILIAR_DEAD);
        DeleteSkinInt(OBJECT_SELF, FAMILIAR_HP);
        // clear old variables

        if(!GetSkinInt(OBJECT_SELF, FAMILIAR_STICKY))
            MasterWipeFamiliarData();

        // Flag Spell Pool for replenishment
        SetLocalInt(OBJECT_SELF, FAMILIAR_SPELL_POOL, SPELL_POOL_REPLENISH);

        if(spell.Target!=OBJECT_SELF)
        {
            // potential for naming and describing familiar
            // but first need to create a system for naming and describing by PC
            //SetSkinString(OBJECT_SELF, FAMILIAR_NAME, GetName(spell.Target));
            //SetSkinString(OBJECT_SELF, FAMILIAR_DESCRIBE, GetDescription(spell.Target));

            // Gather appropriate alignment for this creature
            int nGood, nLaw;
            if(Get2DAString("ifamiliar","ALIGNED", nFamIndex)!="")
            { // Use Creature's alignment
                nGood   = GetGoodEvilValue(spell.Target);
                nLaw    = GetLawChaosValue(spell.Target);
            }
            else
            { // Use Master's alignment
                nGood   = GetGoodEvilValue(OBJECT_SELF);
                nLaw    = GetLawChaosValue(OBJECT_SELF);
            }
            // record Alignment
            SetSkinInt(OBJECT_SELF, FAMILIAR_GOOD, nGood);    // persistence
            SetSkinInt(OBJECT_SELF, FAMILIAR_LAW, nLaw);    // persistence

            // record form of creature
            SetSkinInt(OBJECT_SELF, FAMILIAR_FORM, GetAppearanceType(spell.Target));    // persistence
            // record type of familiar
            SetSkinInt(OBJECT_SELF, FAMILIAR_INDEX, nFamIndex); // persistence
        }


        // sticky familiar?
        if( StringToInt(Get2DAString("ifamiliar","STICKY",nFamIndex)) )
            SetSkinInt(OBJECT_SELF, FAMILIAR_STICKY, TRUE);

        // Initialize Master
        MasterInitializeFamiliarData();

        // VFX and Garbage Collection ....
        object oCircle  = CreateObject(OBJECT_TYPE_PLACEABLE, "aa_pentagram", GetLocation(spell.Target), TRUE);
        if(spell.Target!=OBJECT_SELF)
        {
            AssignCommand(  spell.Target,
                            DelayCommand(   0.2,
                                            PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT,1.0, 1.5)
                                        )
                        );
            DelayCommand(0.3,
                    ApplyEffectAtLocation(  DURATION_TYPE_INSTANT,
                                            EffectVisualEffect(VFX_IMP_DEATH),
                                            GetLocation(spell.Target)
                                        )
                        );

            DestroyObject(spell.Target, 1.6);
        }
        else
        {


        }

        DestroyObject(oCircle, 4.0);

        DelayCommand(1.95,
                ApplyEffectToObject(DURATION_TYPE_INSTANT,
                                    EffectVisualEffect(VFX_IMP_HOLY_AID),
                                    OBJECT_SELF
                                    )
                    );
    }
    else
    {
        SendMessageToPC(OBJECT_SELF, RED+"Fail: "+PINK+GetName(spell.Target)+RED+" is not compatible with you.");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFXFail, spell.Target);
    }

}
