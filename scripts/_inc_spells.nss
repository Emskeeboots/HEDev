// _inc_spells.nss
// Spell related routines


#include "_inc_data"

// Spell related constants and settings
const int SPELL_POOL_REPLENISH      = 9999;
const string SCRY_SENSOR_REF        = "scrysensor";
const int AOE_PER_CLAIRAUDIENCE     = 50;

const int SPELL_ACT_SPIDER_CLIMB    = 866;
const int SPELL_ACT_FLIGHT          = 856;
const int SPELL_ACT_PASSDOOR        = 858;
const int SPELL_ACT_TRACK           = 860;
const int SPELL_ACT_SCENT           = 868;

const int SPELL_FAERIE_FIRE         = 847;

const int SPELL_TARGET              = 1001;
const int SPELL_MARK_TARGET         = 1002; //familiar mark target
const int SPELL_FAMILIAR_EFFECTS    = 1003;
//const int SPELL_META_TARGET         = 1004;

const int SPELL_BIND_FAMILIAR       = 1053;
const int SPELL_DIMENSIONAL_PORTAL  = 1054;
const int SPELL_TRANSDIMENSIONAL_PORTAL = 1055;
const int SPELL_TELEPORT_LESSER     = 1056;
const int SPELL_TELEPORT            = 1057;
const int SPELL_DIMENSIONAL_SWAP    = 1058;
const int SPELL_BLINK               = 1059;
const int SPELL_SPIDER_CLIMB        = 1060;
const int SPELL_DANCING_LIGHTS      = 1061;
const int SPELL_PASS_WITH_NO_TRACE  = 1062;
const int SPELL_STEADY_STRIDE       = 1063;
const int SPELL_TOTEMIC_FORM        = 1064;
const int SPELL_BALEFUL_POLYMORPH   = 1065;
const int SPELL_ATONEMENT           = 1066;
const int SPELL_SPEAK_WITH_ANIMALS  = 1067;
const int SPELL_SCRY                = 1068;
const int SPELL_ERUPTION            = 1069;
const int SPELL_MASS_HASTE_SLOW     = 1070;
const int SPELL_AIR_BUBBLE          = 1071;
const int SPELL_WATER_BREATHING     = 1072;
const int SPELL_JUMP                = 1074;
const int SPELL_FEATHER_FALL        = 1075;
const int SPELL_COMPREHEND          = 1076;
const int SPELL_TONGUES             = 1077;
const int SPELL_IMPOSTOR            = 1078;
const int SPELL_GASEOUS_FORM        = 1079;


// spell focuses
const string SPELLFOCUS_RESREF      = "spellfocus"; // resref of spellfocus item
const int SPELLFOCUS_ONE_USE        = TRUE;     // if TRUE all spell focuses are destroyed when used successfully

const string SPELLFOCUS_SINGLEPPLAYER_ONLY = "SPFOC_NONPW"; // special flag for a spell focus which would not function after a server reset
const string SPELLFOCUS_USE         = "SPFOC_USE";  // TRUE or FALSE
const string SPELLFOCUS_OBJECT      = "SPFOC_OBJ";  // pointer to spell focus being used
const string SPELLFOCUS_TYPE        = "SPFOC_TYP";  // type. 1=location, 2=NPC, 3=PC
const string SPELLFOCUS_CREATURE    = "SPFOC_CRE";  // creature target (PC or NPC) is stored here
const string SPELLFOCUS_LOCATION_TAG= "SPFOC_LOCT"; // location area tag
const string SPELLFOCUS_LOCATION_X  = "SPFOC_LOCX"; // location X position
const string SPELLFOCUS_LOCATION_Y  = "SPFOC_LOCY"; // location Y position
const string SPELLFOCUS_LOCATION_Z  = "SPFOC_LOCZ"; // location Z position
const string SPELLFOCUS_LOCATION_F  = "SPFOC_LOCF"; // location facing


// CPP defined this 
int SAVING_THROW_TYPE_PARALYSE          = 20;

const int SPELL_DEBUG = TRUE;
void spell_debug(string sMsg, object oPC = OBJECT_INVALID) {
        if (SPELL_DEBUG) {
                dbstr(sMsg, oPC);
        }
}

// SPELLS

// Checks whether specified spell compents (v, s, vs) are required by the spell - [FILE: _inc_spells]
int GetSpellComponent(string sComponent, int nSpellID);
// Clears self of Overrides used in the Community Patch - [FILE: _inc_spells]
void CasterClearsSpellOverrides();
// Self must maintain concentration to sustain oConcentrate's existence - [FILE: _inc_spells]
void CasterSetConcentration(object oConcentrate, string sScript="");
// Dispel a magical object - [FILE: _inc_spells]
// returns TRUE on success FALSE on failure
int DispelObject(int nSpellID, int nLevel, int nDC, int bAutoDispel=FALSE);
// OBJECT_SELF is a familiar. - [FILE: _inc_spells]
// nMax is the total spellfoci the creature can carry
// we assume that the familiar is about to pick up a spellfocus, and destroy all that are extra
void FamiliarDestroyExtraSpellFocus(int nMax=1);
// Create a tag for a spell focus (to eliminate stacking problem). - [FILE: _inc_spells]
string GetSpellFocusTag(int nType, location lTarget, object oTarget=OBJECT_INVALID);
// Returns TRUE if spell cast on focus succeeds. - [FILE: _inc_spells]
// OBJECT_SELF is Spell Caster
int GetIsSpellFocusSuccessful(object oFocus, int nSpellID);
// Returns a location stored on a spell focus. - [FILE: _inc_spells]
location GetSpellFocusLocation(object oFocus);
// Stores a location on a spell focus. - [FILE: _inc_spells]
void StoreSpellFocusLocation(object oFocus, location lLoc);
// Helps track creator of AOE - [FILE: _inc_spells]
// Pointer to Caster is set in module variable.
// Save AOE Index according to spellid on caster
void SetAOECaster(int nSpellId, object oCaster);
// Scry related functions.....

// Checks to see if a target is warded from scrying - [FILE: _inc_spells]
int GetIsScryTargetWarded(location lTarget, object oTarget);
// Garbage collection for the clairaudience spell - [FILE: _inc_spells]
void ClairaudienceEnd(object oCreator);
// Garbage collection for the clairaudience spell - [FILE: _inc_spells]
void EndScrying(object oPC);

// Determines whether the caller can control another weapon - [file: _inc_spells]
// nLevel = GetCasterLevel
// IF TRUE, increment the count and return TRUE, ELSE return FALSE
int IncrementAnimatedWeaponCount(int nLevel);
// decreases master's animate weapon count- [file: _inc_spells]
// Executes on the Animated Weapon
void DecrementAnimatedWeaponCount();
// Destroys wielder, drops weapon, cleans up data, calls DecrementAnim... - [file: _inc_spells]
// Executes on the Animated Weapon
void CancelDancingWeapon(int nDispel=FALSE);
// ........  SPELLS ............................................................

int GetSpellComponent(string sComponent, int nSpellID)
{
    string sReq = GetStringLowerCase(Get2DAString("spells", "VS", nSpellID));
    sComponent  = GetStringLowerCase(sComponent);

    if (FindSubString(sReq, sComponent)!=-1)
        return TRUE;
    else
        return FALSE;
}

void CasterClearsSpellOverrides()
{
    // Used By Community Patch
    DeleteLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE");
    DeleteLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_DC_OVERRIDE");
    DeleteLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_METAMAGIC_OVERRIDE");
}

void CasterSetConcentration(object oConcentrate, string sScript="")
{
    SetLocalInt(OBJECT_SELF, "CONCENTRATION", TRUE);
    SetLocalString(OBJECT_SELF,"CONCENTRATION_SCRIPT",sScript);
    SetLocalObject(OBJECT_SELF,"CONCENTRATION_OBJECT",oConcentrate);
}

int DispelObject(int nSpellID, int nLevel, int nDC, int bAutoDispel=FALSE)
{
    // determine max spell level for caster
    int nMax;
    switch(nSpellID)
    {
        case SPELL_MORDENKAINENS_DISJUNCTION: nMax = 40; break;
        case SPELL_GREATER_DISPELLING: nMax = 15; break;
        case SPELL_DISPEL_MAGIC: nMax = 10; break;
        case SPELL_LESSER_DISPEL: nMax = 5; break;
        default: return FALSE; break;
    }

    if(bAutoDispel)
        return TRUE;

    int nMod;
    if (nLevel == 0)
        nMod = 1;
    else if (nLevel>nMax)
        nMod = nMax;
    else
        nMod = nLevel;

    // dispel?
    if ( (nMod + d20()) >= nDC)
    {
        if(nDC>=30)
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_MYSTICAL_EXPLOSION), GetLocation(OBJECT_SELF));
        else if(nDC>=26)
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION), GetLocation(OBJECT_SELF));
        else if(nDC>=21)
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL_GREATER), GetLocation(OBJECT_SELF));
        else
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), GetLocation(OBJECT_SELF));

        return TRUE;
    }
    return FALSE;
}

void FamiliarDestroyExtraSpellFocus(int nMax=1)
{
    if(nMax==-1)
        return;

    object oFocus   = GetFirstItemInInventory();
    int nCount, bDestroy;
    while(oFocus!=OBJECT_INVALID)
    {
        if(GetLocalInt(oFocus,SPELLFOCUS_TYPE))
        {
            ++nCount;
            if(nCount>=nMax)
            {
                bDestroy    = TRUE;
                DestroyObject(oFocus);
            }
        }

        oFocus   = GetNextItemInInventory();
    }

    if(bDestroy)
        SendMessageToPC(OBJECT_SELF, DMBLUE+GetName(OBJECT_SELF)+" may only carry "+PALEBLUE+IntToString(nMax)+DMBLUE+" Spell Focus at a time.");
}

string GetSpellFocusTag(int nType, location lTarget, object oTarget=OBJECT_INVALID)
{
    string sTag;
    if(nType==1)
    {
        sTag    += GetStringRight(GetTag(GetAreaFromLocation(lTarget)),8);
        vector vPos = GetPositionFromLocation(lTarget);
        sTag    += FloatToString(vPos.x,8)+FloatToString(vPos.y,8)+FloatToString(vPos.z,8);
    }
    else
    {
        sTag    += GetTag(oTarget) + GetName(oTarget);
        if(GetStringLength(sTag)>32)
            sTag    = GetStringRight(sTag,32);
    }

    return sTag;
}

int GetIsSpellFocusSuccessful(object oFocus, int nSpellID)
{
    int bSuccess;
    int nSpellFocusType  = GetLocalInt(oFocus, SPELLFOCUS_TYPE);
    if(nSpellFocusType==1)// location
    {
        location lLoc   = GetSpellFocusLocation(oFocus);

        if(GetIsObjectValid(GetAreaFromLocation(lLoc)))
        {
            if(     nSpellID==SPELL_DIMENSIONAL_PORTAL
                ||  nSpellID==SPELL_TRANSDIMENSIONAL_PORTAL
                ||  nSpellID==SPELL_TELEPORT_LESSER
                ||  nSpellID==SPELL_TELEPORT
              )
                bSuccess=TRUE;
        }
        else
        {
            // feedback about invalid location
        }
    }
    else if(nSpellFocusType==2)// NPC
    {
        object oNPC = GetLocalObject(oFocus, SPELLFOCUS_CREATURE);

        if( oNPC!=OBJECT_INVALID )
        {
            if(     nSpellID==SPELL_DIMENSIONAL_PORTAL
                ||  nSpellID==SPELL_TRANSDIMENSIONAL_PORTAL
                ||  nSpellID==SPELL_TELEPORT_LESSER
                ||  nSpellID==SPELL_TELEPORT
                ||  nSpellID==SPELL_BESTOW_CURSE
              )
                bSuccess=TRUE;
        }
        else
        {
            // feedback about invalid creature
        }
    }
    else if(nSpellFocusType==3)// PC
    {
        object oPC  = GetPCByPCID(GetLocalString(oFocus, SPELLFOCUS_CREATURE));

        if( oPC!=OBJECT_INVALID )
        {
            if(     nSpellID==SPELL_DIMENSIONAL_PORTAL
                ||  nSpellID==SPELL_TRANSDIMENSIONAL_PORTAL
                ||  nSpellID==SPELL_TELEPORT_LESSER
                ||  nSpellID==SPELL_TELEPORT
                ||  nSpellID==SPELL_BESTOW_CURSE
              )
                bSuccess=TRUE;
        }
        else
        {
            // feedback about invalid PC
        }
    }
    else
    {
        // ????
    }
    return bSuccess;
}

location GetSpellFocusLocation(object oFocus)
{


    return  Location(   GetObjectByTag(GetLocalString(oFocus, SPELLFOCUS_LOCATION_TAG)),
                        Vector( GetLocalFloat(oFocus, SPELLFOCUS_LOCATION_X),
                                GetLocalFloat(oFocus, SPELLFOCUS_LOCATION_Y),
                                GetLocalFloat(oFocus, SPELLFOCUS_LOCATION_Z)
                              ),
                        GetLocalFloat(oFocus, SPELLFOCUS_LOCATION_F)
                    );
}

// Stores a location on a spell focus. - [FILE: spellfocus_inc]
void StoreSpellFocusLocation(object oFocus, location lLoc)
{
    vector vPos     = GetPositionFromLocation(lLoc);

    SetLocalString(oFocus, SPELLFOCUS_LOCATION_TAG, GetTag(GetAreaFromLocation(lLoc)));
    SetLocalFloat(oFocus, SPELLFOCUS_LOCATION_X, vPos.x);
    SetLocalFloat(oFocus, SPELLFOCUS_LOCATION_Y, vPos.y);
    SetLocalFloat(oFocus, SPELLFOCUS_LOCATION_Z, vPos.z);
    SetLocalFloat(oFocus, SPELLFOCUS_LOCATION_F, GetFacingFromLocation(lLoc));
}

void SetAOECaster(int nSpellId, object oCaster)
{
    int nIndex;
    string sSpellID = IntToString(nSpellId);
    string sAOEID   = "AOE"+sSpellID+"_ID"+IntToString(nIndex)+"_CASTER";
    object oMod     = GetModule();
    object oC       = GetLocalObject(oMod, sAOEID);

    while (GetIsObjectValid(oC))
    {
        sAOEID  = "AOE"+sSpellID+"_ID"+IntToString(++nIndex)+"_CASTER";
        oC      = GetLocalObject(oMod, sAOEID);
    }

    SetLocalObject(oMod, sAOEID, oCaster);
    SetLocalInt(oCaster,"AOE"+sSpellID+"_ID", nIndex);
}


int GetIsScryTargetWarded(location lTarget, object oTarget)
{
    // warding check
    if(     GetLocalInt(GetAreaFromLocation(lTarget), "SCRY_NO")
        ||  GetLocalInt(oTarget, "SCRY_NO")
      )
        return TRUE;
    else
        return FALSE;
}

void ClairaudienceEnd(object oCreator)
{
    object oSensor  = GetLocalObject(oCreator, "SCRY_SENSOR");
    int nSensorID   = GetLocalInt(oSensor, "SCRY_ID");
    if( GetIsObjectValid(OBJECT_SELF) )
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL), oCreator, 0.1);
        SendMessageToPC(oCreator, PINK+"Your "+RED+"clairaudience"+PINK+" spell ends.");
        // Garbage Collection
        DeleteLocalInt(oCreator, "SCRYING");
        DeleteLocalObject(oCreator, "SCRY_SENSOR");
        object oAOE = GetLocalObject(oSensor, "PAIRED");
        DestroyObject(oAOE, 0.1);

        DestroyObject(oSensor, 0.1);

        if(!GetHasSpellEffect(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, oCreator))
            return;
        // ensure the spell is cancelled
        effect eSpell   = GetFirstEffect(oCreator);
        while(GetIsEffectValid(eSpell))
        {
            if(GetEffectSpellId(eSpell)==SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE)
                RemoveEffect(oCreator, eSpell);
            eSpell = GetNextEffect(oCreator);
        }
    }
}

void EndScrying(object oPC)
{
    int scry_val = GetLocalInt(oPC, "SCRYING");
    if(scry_val)
    {
        ClairaudienceEnd(oPC);
    }
    DeleteLocalInt(oPC, "SCRYING");
}


int IncrementAnimatedWeaponCount(int nLevel)
{
    // OBJECT_SELF = creator / spell caster
    int nWeapons    = GetLocalInt(OBJECT_SELF, "ANIMATED_WEAPON_COUNT")+1;

    int nMax        = 1 + nLevel/3;

    if(nWeapons > nMax)
        return FALSE;
    else
    {
        SetLocalInt(OBJECT_SELF, "ANIMATED_WEAPON_COUNT", nWeapons);
        return TRUE;
    }
}

void DecrementAnimatedWeaponCount()
{
    // OBJECT_SELF = weapon wielder
    if(OBJECT_SELF!=OBJECT_INVALID && !GetLocalInt(OBJECT_SELF, "ANIMATED_WEAPON_COUNT_DEC"))
    {
        object oMaster  = GetMaster(OBJECT_SELF);
        if(GetIsObjectValid(oMaster))
        {
            int nWeapons    = GetLocalInt(oMaster, "ANIMATED_WEAPON_COUNT")-1;
            if(nWeapons<0){ nWeapons = 0; }
            SetLocalInt(oMaster, "ANIMATED_WEAPON_COUNT", nWeapons);
            SetLocalInt(OBJECT_SELF, "ANIMATED_WEAPON_COUNT_DEC", TRUE);
        }
    }
}

void CancelDancingWeapon(int nDispel=FALSE)
{
    DecrementAnimatedWeaponCount();
    SetPlotFlag(OBJECT_SELF, FALSE);

    // Drop weapon -------------------------------------------------------------
    object oWeapon      = GetLocalObject(OBJECT_SELF, "WEAPON");
    string sBlade       = GetLocalString(OBJECT_SELF, "WEAPON_SOUND");
    AssignCommand(OBJECT_SELF, ActionUnequipItem(oWeapon));
    object oItem = CopyObject(oWeapon,GetLocation(OBJECT_SELF));
    AssignCommand(OBJECT_SELF, PlaySound(sBlade));
    DestroyObject(oWeapon, 0.1);
    // -------------------------------------------------------------------------

    if(nDispel)
    {
        location lLoc   = GetLocation(OBJECT_SELF);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(239), lLoc); // spark
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(282), lLoc); // hit elec
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(681), lLoc); // mag blue
    }
    else
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DISPEL), GetLocation(OBJECT_SELF));
    }
    DestroyObject(OBJECT_SELF, 0.5);
}

// Code adapted from 1.71 for fixes
int tbGetMetaMagicFeat(object oCaster, object oItem) {
        int nMeta = METAMAGIC_NONE;

        if(GetIsObjectValid(oItem)) {
                // Spells from items only have metamagci if this is set.
                nMeta = GetLocalInt(oItem,"ITEM_METAMAGIC_OVERRIDE");

                // Usually METAMAGIC_NONE (0)
                return nMeta;
        }

        int nClass = GetLastSpellCastClass();
        if (nClass == CLASS_TYPE_INVALID) {
                nMeta =  GetLocalInt(oCaster,"SPECIAL_ABILITY_METAMAGIC_OVERRIDE");
                if (nMeta != METAMAGIC_NONE)
                        return nMeta;
        } else {
                nMeta = GetLocalInt(oCaster,"SPELL_METAMAGIC_OVERRIDE");
                if (nMeta != METAMAGIC_NONE)
                        return nMeta;
        }


        // only do this for non-items.
        nMeta = GetMetaMagicFeat();
        if(nMeta == METAMAGIC_ANY || nMeta < 0) {
        //odd behavior when spell was cast from item             //bug in actioncastspell
           nMeta = METAMAGIC_NONE;
        }
        else if((nMeta == METAMAGIC_EMPOWER && !GetHasFeat(FEAT_EMPOWER_SPELL,oCaster))
                || (nMeta == METAMAGIC_MAXIMIZE && !GetHasFeat(FEAT_MAXIMIZE_SPELL,oCaster))) {
                 nMeta = METAMAGIC_NONE;//metamagic exploit with polymorph into Rakshasa
        }
        return nMeta;
}

// TODO - pass in spell class so we can tell if this is an ability or actual spell.
int tbGetSpellSaveDC(object oCaster = OBJECT_SELF, object oItem = OBJECT_INVALID, int nLevel = 0) {
        int nDC;
        int nMod = 0;

        if (GetIsObjectValid(oItem)) {
                nDC = GetLocalInt(oItem,"ITEM_DC_OVERRIDE");
                if (nDC > 0)
                        return nDC;

                nMod =  GetLocalInt(oItem,"ITEM_DC_MODIFIER");

                // TODO - allow variable on item to override DC
                if (nLevel < 0) nLevel = 0;

                return 10 + nLevel + nMod;
        }

        int nClass = GetLastSpellCastClass();
        // Feats and creature abilities
        if (nClass == CLASS_TYPE_INVALID) {
                nDC =  GetLocalInt(oCaster,"SPECIAL_ABILITY_DC_OVERRIDE");
                if (nDC > 0)
                        return nDC;

                nMod = GetLocalInt(oCaster,"SPECIAL_ABILITY_DC_MODIFIER");

                return 10 + nLevel + nMod;
        }

        // Regular spells
        nDC =  GetLocalInt(oCaster,"SPELL_DC_OVERRIDE");
        if (nDC > 0)
                return nDC;

        // only for non-item and non-feat cases
        // Only returns correct results for actual spells
        nDC =  GetSpellSaveDC();
        nMod = GetLocalInt(oCaster,"SPELL_DC_MODIFIER");

        //DC bug with negative primary ability
        if(nDC > 126) {
                if (nClass != CLASS_TYPE_INVALID) {
                        string primaryAbil = Get2DAString("classes","PrimaryAbil", nClass);//gets the class' primary ability, using 2da for "globallity"
                        int nAbility = ABILITY_CHARISMA;// default ability is charisma
                        if(primaryAbil == "STR")
                                nAbility = ABILITY_STRENGTH;
                        else if(primaryAbil == "DEX")
                                nAbility = ABILITY_DEXTERITY;
                        else if(primaryAbil == "CON")
                                nAbility = ABILITY_CONSTITUTION;
                        else if(primaryAbil == "WIS")
                                nAbility = ABILITY_WISDOM;
                        else if(primaryAbil == "INT")
                                nAbility = ABILITY_INTELLIGENCE;
                        nDC = 10 + GetLevelByClass(nClass, oCaster)+GetAbilityModifier(nAbility,oCaster);//lets recalculate the DC on our own
                } else {
                        nDC = 10 + nLevel;
                }
        }
        return nDC + nMod;
}
int tbGetCasterLevel(object oCaster = OBJECT_SELF, object oItem = OBJECT_INVALID, int nLevel = 0) {

        //return GetCasterLevel(oCaster);
        int nOverLevel;
        int nMod = 0;

        if (GetIsObjectValid(oItem)) {
                nOverLevel = GetLocalInt(oItem,"ITEM_CASTER_LEVEL_OVERRIDE");
                if (nOverLevel > 0)
                        return nOverLevel;

                nMod = GetLocalInt(oItem,"ITEM_CASTER_LEVEL_MODIFIER");

                // Try the normal getcasterlevel. That's what the all the normal spell scripts do.
                // This will not be on hit so only direct ip_castSpells will hit this.
                if (nLevel <= 0)
                        nLevel = GetCasterLevel(oCaster);
                if (nLevel <1) nLevel = 1;
                return nLevel + nMod;
        }
        nLevel  =  GetCasterLevel(oCaster);
        int nClass = GetLastSpellCastClass();

        if (nClass == CLASS_TYPE_INVALID) {
                nOverLevel = GetLocalInt(oCaster,"SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE");
                if (nOverLevel > 0)
                        return nOverLevel;
                nMod = GetLocalInt(oCaster,"SPECIAL_ABILITY_CASTER_LEVEL_MODIFIER");

        } else {
                nOverLevel = GetLocalInt(oCaster,"SPELL_CASTER_LEVEL_OVERRIDE");
                if (nOverLevel > 0)
                        return nOverLevel;
                nMod = GetLocalInt(oCaster,"SPELL_CASTER_LEVEL_MODIFIER");

        //module switch to add PM into CL
                if (GetLevelByClass(CLASS_TYPE_PALE_MASTER, oCaster)
                        && GetLocalInt(GetModule(),"71_PALEMASTER_ADDS_CASTER_LEVEL")) {
                        switch(nClass) {
                                case CLASS_TYPE_BARD:
                                case CLASS_TYPE_SORCERER:
                                case CLASS_TYPE_WIZARD:
                                int nMod = StringToInt(Get2DAString("classes","ArcSpellLvlMod",CLASS_TYPE_PALE_MASTER));
                                nLevel+= (GetLevelByClass(CLASS_TYPE_PALE_MASTER, oCaster) + (nMod != 1))/nMod;
                                break;
                        }
                }
        }

        nLevel += nMod;

        // Sanity check.
        if (nLevel < 1) nLevel = 1;

        return nLevel;
}
