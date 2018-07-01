//::///////////////////////////////////////////////
//:: _plcspawn_ent
//:://////////////////////////////////////////////
/*
    This script is set on an Area of Effect that is applied to the placeable when it is created

    Event: onEnter of an AOE
    spawns monster by ResRef with visual effect.

    LOCAL VARIABLES DECLARED ON OBJECT THAT THIS SCRIPT RECOGNIZES
    PLCSPAWN           -   (string) ResRef of the creature to spawn (when monster is spawned).
    PLCSPAWN_PLACE     -   (string) ResRef of the placeable to spawn (when monster is despawned).
    PLCSPAWN_VFX       -   (string) string representing the VFX constant. Default: VFX_NONE
                            GetSpawnVFX will use this string once then store the int for future ref
    PLCSPAWN_VFX       -   (int) int representing the index of the VFX in visualeffects.2da
                            this takes precedence over the string version.
    PLCSPAWN_APPEAR    -   (int) Boolean. If True, Appear animation is played
    PLCSPAWN_DISTANCE  -   (float) Distance to nearest PC, at which monster despawns if not in combat.
    PLCSPAWN_DELAY     -   (int) Time in Seconds of delay between Placeable Spawn and Monster Spawn. This has a minimum value of 1.

    Inspiration
    BASED on NW_O2_GARGOYLE.nss and inspired by Vives Dark Tree (vv_o2_darktree).
    Intention is to grab local variables from the placeable rather than hardcode these values in script.
*/
//:://////////////////////////////////////////////
//:: Created:  The Magus (2012 oct 8) minimal AOE enter event for AOE gargoyles
//:: Modified: The Magus (2012 oct 13) added shortcut in GetSpawnVFX()
//::                                   spawned monsters no longer attack creatures they can't see
//:://////////////////////////////////////////////
//:: Modified: The Magus (2013 dec 7) adjustments for vives2

#include "nw_i0_generic"

#include "_inc_util"

//////////////////////////////////////////////////////////
// DECLARE CONSTANTS
//////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////
// DECLARE FUNCTIONS
//////////////////////////////////////////////////////////

// each of these execute on the placeable, while this enter script executes on the AOE
void    storeLocalsOnMonster(object oMonster);
int     GetSpawnVFX();
void    SpawnMonster(object oDisturber, int nSecondsDormant);


//////////////////////////////////////////////////////////
// FUNCTION BODIES
//////////////////////////////////////////////////////////

void storeLocalsOnMonster(object oMonster)
{
    SetLocalString(oMonster, "PLCSPAWN", GetLocalString(OBJECT_SELF, "PLCSPAWN"));
    SetLocalString(oMonster, "PLCSPAWN_PLACE", GetResRef(OBJECT_SELF));
    SetLocalString(oMonster, "PLCSPAWN_VFX", GetLocalString(OBJECT_SELF, "PLCSPAWN_VFX"));
    SetLocalInt(oMonster, "PLCSPAWN_VFX", GetLocalInt(OBJECT_SELF, "PLCSPAWN_VFX"));
    SetLocalFloat(oMonster, "PLCSPAWN_DISTANCE", GetLocalFloat(OBJECT_SELF, "PLCSPAWN_DISTANCE"));
    SetLocalInt(oMonster, "PLCSPAWN_APPEAR", GetLocalInt(OBJECT_SELF, "PLCSPAWN_APPEAR"));
    SetLocalInt(oMonster, "PLCSPAWN_DELAY", GetLocalInt(OBJECT_SELF, "PLCSPAWN_DELAY"));
    SetLocalInt(oMonster,"PLCSPAWN_SECONDS_PER_1HP_HEALED",GetLocalInt(OBJECT_SELF, "PLCSPAWN_SECONDS_PER_1HP_HEALED"));
}

int GetSpawnVFX()
{
    int nVFX    = GetLocalInt(OBJECT_SELF, "PLCSPAWN_VFX");
    if(nVFX)
        return nVFX;

    string sVFX = GetLocalString(OBJECT_SELF, "PLCSPAWN_VFX");

    if (sVFX==""){ nVFX = VFX_NONE;}
    else if (sVFX=="VFX_IMP_GARG_EXPLOSION"){ nVFX = 1150;}
    else if (sVFX=="VFX_IMP_GARG_EXPLOSION2"){ nVFX = 1151;}
    else if (sVFX=="VFX_IMP_HOLY_AID"){ nVFX = VFX_IMP_HOLY_AID;}
    else if (sVFX=="VFX_IMP_PULSE_COLD"){ nVFX = VFX_IMP_PULSE_COLD;}
    else if (sVFX=="VFX_IMP_PULSE_FIRE"){ nVFX = VFX_IMP_PULSE_FIRE;}
    else if (sVFX=="VFX_IMP_PULSE_HOLY"){ nVFX = VFX_IMP_PULSE_HOLY;}
    else if (sVFX=="VFX_IMP_PULSE_HOLY_SILENT"){ nVFX = VFX_IMP_PULSE_HOLY_SILENT;}
    else if (sVFX=="VFX_IMP_PULSE_NATURE"){ nVFX = VFX_IMP_PULSE_NATURE;}
    else if (sVFX=="VFX_IMP_PULSE_NEGATIVE"){ nVFX = VFX_IMP_PULSE_NEGATIVE;}
    else if (sVFX=="VFX_IMP_PULSE_WATER"){ nVFX = VFX_IMP_PULSE_WATER;}
    else if (sVFX=="VFX_IMP_PULSE_WIND"){ nVFX = VFX_IMP_PULSE_WIND;}
    else if (sVFX=="VFX_IMP_DUST_EXPLOSION"){ nVFX = VFX_IMP_DUST_EXPLOSION;}
    //else if (sVFX=="VFX_IMP_DIVINE_STRIKE_FIRE"){ nVFX = VFX_IMP_DIVINE_STRIKE_FIRE;}
    //else if (sVFX=="VFX_IMP_DIVINE_STRIKE_HOLY"){ nVFX = VFX_IMP_DIVINE_STRIKE_HOLY;}
    else if (sVFX=="VFX_IMP_DOOM"){ nVFX = VFX_IMP_DOOM;}
    //else if (sVFX=="VFX_IMP_FLAME_M"){ nVFX = VFX_IMP_FLAME_M;}
    //else if (sVFX=="VFX_IMP_FLAME_S"){ nVFX = VFX_IMP_FLAME_S;}
    //else if (sVFX=="VFX_IMP_FROST_L"){ nVFX = VFX_IMP_FROST_L;}
    //else if (sVFX=="VFX_IMP_FROST_S"){ nVFX = VFX_IMP_FROST_S;}
    //else if (sVFX=="VFX_IMP_LIGHTNING_M"){ nVFX = VFX_IMP_LIGHTNING_M;}
    //else if (sVFX=="VFX_IMP_LIGHTNING_S"){ nVFX = VFX_IMP_LIGHTNING_S;}
    //else if (sVFX=="VFX_IMP_HEAD_ELECTRICITY"){ nVFX = VFX_IMP_HEAD_ELECTRICITY;}
    //else if (sVFX=="VFX_IMP_HEAD_FIRE"){ nVFX = VFX_IMP_HEAD_FIRE;}
    //else if (sVFX=="VFX_IMP_MAGBLUE"){ nVFX = VFX_IMP_MAGBLUE;}
    else if (sVFX=="VFX_IMP_NEGATIVE_ENERGY"){ nVFX = VFX_IMP_NEGATIVE_ENERGY;}
    else if (sVFX=="VFX_IMP_SONIC"){ nVFX = VFX_IMP_SONIC;}
    else if (sVFX=="VFX_IMP_STARBURST_GREEN"){ nVFX = VFX_IMP_STARBURST_GREEN;}
    else if (sVFX=="VFX_IMP_STARBURST_RED"){ nVFX = VFX_IMP_STARBURST_RED;}
    //else if (sVFX=="VFX_IMP_SUNSTRIKE"){ nVFX = VFX_IMP_SUNSTRIKE;}
    else if (sVFX=="VFX_IMP_TORNADO"){ nVFX = VFX_IMP_TORNADO;}
    else if (sVFX=="VFX_IMP_UNSUMMON"){ nVFX = VFX_IMP_UNSUMMON;}
    else if (sVFX=="VFX_IMP_GREASE"){ nVFX = VFX_IMP_GREASE;}
    //else if (sVFX=="VFX_FNF_BLINDDEAF"){ nVFX = VFX_FNF_BLINDDEAF;}
    //else if (sVFX=="VFX_FNF_DECK"){ nVFX = VFX_FNF_DECK;}
    //else if (sVFX=="VFX_FNF_DEMON_HAND"){ nVFX = VFX_FNF_DEMON_HAND;}
    else if (sVFX=="VFX_FNF_DISPEL"){ nVFX = VFX_FNF_DISPEL;}
    else if (sVFX=="VFX_FNF_DISPEL_DISJUNCTION"){ nVFX = VFX_FNF_DISPEL_DISJUNCTION;}
    else if (sVFX=="VFX_FNF_DISPEL_GREATER"){ nVFX = VFX_FNF_DISPEL_GREATER;}
    else if (sVFX=="VFX_FNF_ELECTRIC_EXPLOSION"){ nVFX = VFX_FNF_ELECTRIC_EXPLOSION;}
    else if (sVFX=="VFX_FNF_FIREBALL"){ nVFX = VFX_FNF_FIREBALL;}
    else if (sVFX=="VFX_FNF_FIRESTORM"){ nVFX = VFX_FNF_FIRESTORM;}
    else if (sVFX=="VFX_FNF_GAS_EXPLOSION_ACID"){ nVFX = VFX_FNF_GAS_EXPLOSION_ACID;}
    else if (sVFX=="VFX_FNF_GAS_EXPLOSION_EVIL"){ nVFX = VFX_FNF_GAS_EXPLOSION_EVIL;}
    else if (sVFX=="VFX_FNF_GAS_EXPLOSION_FIRE"){ nVFX = VFX_FNF_GAS_EXPLOSION_FIRE;}
    else if (sVFX=="VFX_FNF_GAS_EXPLOSION_GREASE"){ nVFX = VFX_FNF_GAS_EXPLOSION_GREASE;}
    else if (sVFX=="VFX_FNF_GAS_EXPLOSION_MIND"){ nVFX = VFX_FNF_GAS_EXPLOSION_MIND;}
    else if (sVFX=="VFX_FNF_GAS_EXPLOSION_NATURE"){ nVFX = VFX_FNF_GAS_EXPLOSION_NATURE;}
    //else if (sVFX=="VFX_FNF_GREATER_RUIN"){ nVFX = VFX_FNF_GREATER_RUIN;}
    else if (sVFX=="VFX_FNF_HORRID_WILTING"){ nVFX = VFX_FNF_HORRID_WILTING;}
    else if (sVFX=="VFX_FNF_HOWL_MIND"){ nVFX = VFX_FNF_HOWL_MIND;}
    else if (sVFX=="VFX_FNF_HOWL_ODD"){ nVFX = VFX_FNF_HOWL_ODD;}
    else if (sVFX=="VFX_FNF_HOWL_WAR_CRY"){ nVFX = VFX_FNF_HOWL_WAR_CRY;}
    else if (sVFX=="VFX_FNF_HOWL_WAR_CRY_FEMALE"){ nVFX = VFX_FNF_HOWL_WAR_CRY_FEMALE;}
    else if (sVFX=="VFX_FNF_ICESTORM"){ nVFX = VFX_FNF_ICESTORM;}
    else if (sVFX=="VFX_FNF_IMPLOSION"){ nVFX = VFX_FNF_IMPLOSION;}
    //else if (sVFX=="VFX_FNF_MASS_HEAL"){ nVFX = VFX_FNF_MASS_HEAL;}
    //else if (sVFX=="VFX_FNF_MASS_MIND_AFFECTING"){ nVFX = VFX_FNF_MASS_MIND_AFFECTING;}
    //else if (sVFX=="VFX_FNF_METEOR_SWARM"){ nVFX = VFX_FNF_METEOR_SWARM;}
    else if (sVFX=="VFX_FNF_MYSTICAL_EXPLOSION"){ nVFX = VFX_FNF_MYSTICAL_EXPLOSION;}
    else if (sVFX=="VFX_FNF_NATURES_BALANCE"){ nVFX =  VFX_FNF_NATURES_BALANCE;}
    //else if (sVFX=="VFX_FNF_PWKILL"){ nVFX = VFX_FNF_PWKILL;}
    //else if (sVFX=="VFX_FNF_PWSTUN"){ nVFX = VFX_FNF_PWSTUN;}
    else if (sVFX=="VFX_FNF_SCREEN_BUMP"){ nVFX = VFX_FNF_SCREEN_BUMP;}
    else if (sVFX=="VFX_FNF_SCREEN_SHAKE"){ nVFX = VFX_FNF_SCREEN_SHAKE;}
    else if (sVFX=="VFX_FNF_SMOKE_PUFF"){ nVFX = VFX_FNF_SMOKE_PUFF;}
    else if (sVFX=="VFX_FNF_SOUND_BURST"){ nVFX = VFX_FNF_SOUND_BURST;}
    else if (sVFX=="VFX_FNF_SOUND_BURST_SILENT"){ nVFX = VFX_FNF_SOUND_BURST_SILENT;}
    //else if (sVFX=="VFX_FNF_STORM"){ nVFX = VFX_FNF_STORM;}
    //else if (sVFX=="VFX_FNF_STRIKE_HOLY"){ nVFX = VFX_FNF_STRIKE_HOLY;}
    else if (sVFX=="VFX_FNF_SUMMON_CELESTIAL"){ nVFX = VFX_FNF_SUMMON_CELESTIAL;}
    else if (sVFX=="VFX_FNF_SUMMON_EPIC_UNDEAD"){ nVFX = VFX_FNF_SUMMON_EPIC_UNDEAD;}
    else if (sVFX=="VFX_FNF_SUMMON_GATE"){ nVFX = VFX_FNF_SUMMON_GATE;}
    else if (sVFX=="VFX_FNF_SUMMON_MONSTER_1"){ nVFX = VFX_FNF_SUMMON_MONSTER_1;}
    else if (sVFX=="VFX_FNF_SUMMON_MONSTER_2"){ nVFX = VFX_FNF_SUMMON_MONSTER_2;}
    else if (sVFX=="VFX_FNF_SUMMON_MONSTER_3"){ nVFX = VFX_FNF_SUMMON_MONSTER_3;}
    else if (sVFX=="VFX_FNF_SUMMON_UNDEAD"){ nVFX = VFX_FNF_SUMMON_UNDEAD;}
    else if (sVFX=="VFX_FNF_SUMMONDRAGON"){ nVFX = VFX_FNF_SUMMONDRAGON;}
    //else if (sVFX=="VFX_FNF_SUNBEAM"){ nVFX = VFX_FNF_SUNBEAM;}
    //else if (sVFX=="VFX_FNF_SWINGING_BLADE"){ nVFX = VFX_FNF_SWINGING_BLADE;}
    //else if (sVFX=="VFX_FNF_TIME_STOP"){ nVFX = VFX_FNF_TIME_STOP;}
    else if (sVFX=="VFX_FNF_UNDEAD_DRAGON"){ nVFX = VFX_FNF_UNDEAD_DRAGON;}
    else if (sVFX=="VFX_FNF_WAIL_O_BANSHEES"){ nVFX = VFX_FNF_WAIL_O_BANSHEES;}
    else if (sVFX=="VFX_FNF_WEIRD"){ nVFX = VFX_FNF_WEIRD;}
    else if (sVFX=="VFX_FNF_WORD"){ nVFX = VFX_FNF_WORD;}
    else
        nVFX = VFX_NONE;

    SetLocalInt(OBJECT_SELF, "PLCSPAWN_VFX", nVFX);
    return nVFX;
}

void SpawnMonster(object oDisturber, int nSecondsDormant)
{
    float fDir              = GetFacing(OBJECT_SELF);
    effect eSpawnEffect     = EffectVisualEffect(GetSpawnVFX());
    object oMonster         = CreateObject( OBJECT_TYPE_CREATURE,
                                                GetLocalString(OBJECT_SELF, "PLCSPAWN"),
                                                GetLocation(OBJECT_SELF),
                                                GetLocalInt(OBJECT_SELF, "PLCSPAWN_APPEAR")
                                              );
    storeLocalsOnMonster(oMonster);
    // persistent hitpoints
    int nLastHP             = GetLocalInt(OBJECT_SELF, "PLCSPAWN_HITPOINTS");
    if(nLastHP)
    {
        int nDam            = GetMaxHitPoints(oMonster)-nLastHP;

        if(nSecondsDormant>899)
            nDam=0;
        else
        {
            int nHealRate       = GetLocalInt(oMonster,"PLCSPAWN_SECONDS_PER_1HP_HEALED");
            if(nHealRate==-1)
                nDam = 0;
            else if(nHealRate && nDam)
            {
                nDam = nDam - (nSecondsDormant/nHealRate);
                if(nDam<0)
                    nDam=0;
            }
            if(nDam)
                ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(nDam),oMonster);
        }
    }// end persistent hitpoints

    AssignCommand(oMonster, SetFacing(fDir));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eSpawnEffect, GetLocation(OBJECT_SELF));


    // attack the disturber
    if(GetIsEnemy(oDisturber,oMonster))
    {
        if(GetObjectSeen(oDisturber))
            AssignCommand(oMonster, DetermineCombatRound(oDisturber));
        else
            AssignCommand(oMonster, DetermineCombatRound());
    }

    SetPlotFlag(OBJECT_SELF, FALSE);
    DestroyObject(OBJECT_SELF, 0.1);
}

void main()
{
    if(GetLocalInt(OBJECT_SELF, "PLCSPAWNED_MONSTER")){return;} // exit, if the monster has already spawned

    object oDisturber   = GetLocalObject(OBJECT_SELF, "DISTURBER");
    if(oDisturber==OBJECT_INVALID)
           oDisturber   = GetEnteringObject();

    if(!GetIsPC(oDisturber)){return;} // exit, if the disturber is not a PC

    object oPlace       = GetLocalObject(OBJECT_SELF, "PAIRED");
    int nSpawnTime      = GetLocalInt(oPlace, "PLCSPAWN_TIME"); // time that the placeable was spawned
    int nTimeNow        = GetTimeCumulative(TIME_SECONDS);
    int nSpawnDelay     = GetLocalInt(oPlace, "PLCSPAWN_DELAY");
    if(nSpawnDelay<1)
        nSpawnDelay     = 1;

    if(     oDisturber!=GetLocalObject(OBJECT_SELF, "IGNORE")
        &&  (!nSpawnTime || ((nSpawnTime+nSpawnDelay)<nTimeNow) )
       )
    {
        SetLocalInt(OBJECT_SELF, "PLCSPAWNED_MONSTER", TRUE);
        AssignCommand(oPlace, SpawnMonster(oDisturber,nTimeNow-nSpawnTime));
        DestroyObject(OBJECT_SELF, 0.1);
    }
}
