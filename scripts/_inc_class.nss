// _inc_class.nss

// Class constants and helper functions
//

// CONSTANTS
// string constants used to describe class names
const string CLASS_NAME_BARBARIAN       = "Barbarian";
const string CLASS_NAME_BARD            = "Bard";
const string CLASS_NAME_CLERIC          = "Cleric";
const string CLASS_NAME_DRUID           = "Druid";
const string CLASS_NAME_FIGHTER         = "Fighter";
const string CLASS_NAME_MONK            = "Monk";
const string CLASS_NAME_PALADIN         = "Paladin";
const string CLASS_NAME_RANGER          = "Ranger";
const string CLASS_NAME_ROGUE           = "Rogue";
const string CLASS_NAME_SORCERER        = "Sorcerer";
const string CLASS_NAME_WIZARD          = "Wizard";

const string CLASS_NAME_ARCANE_ARCHER   = "Arcane Archer";
const string CLASS_NAME_ASSASSIN        = "Assassin";
const string CLASS_NAME_BLACKGUARD      = "Blackguard";
const string CLASS_NAME_HARPER          = "Harper";
const string CLASS_NAME_SHADOWDANCER    = "Shadowdancer";
const string CLASS_NAME_DIVINECHAMPION  = "Divine Champion";
const string CLASS_NAME_DRAGONDISCIPLE  = "Dragon Disciple";
const string CLASS_NAME_DWARVENDEFENDER = "Dwarven Defender";
const string CLASS_NAME_PALEMASTER      = "Pale Master";
const string CLASS_NAME_SHIFTER         = "Shifter";
const string CLASS_NAME_WEAPON_MASTER   = "Weapons Master";


// returns name of class for constant CLASS_TYPE_XXXX - [FILE: _inc_util]
// returns a blank string if class name not found
string GetClassName (int iClass);
string GetClassName (int iClass)
{
    switch (iClass)
    {
        case CLASS_TYPE_BARBARIAN:
            return CLASS_NAME_BARBARIAN;
        case CLASS_TYPE_BARD:
            return CLASS_NAME_BARD;
        case CLASS_TYPE_CLERIC:
            return CLASS_NAME_CLERIC;
        case CLASS_TYPE_DRUID:
            return CLASS_NAME_DRUID;
        case CLASS_TYPE_FIGHTER:
            return CLASS_NAME_FIGHTER;
        case CLASS_TYPE_MONK:
            return CLASS_NAME_MONK;
        case CLASS_TYPE_PALADIN:
            return CLASS_NAME_PALADIN;
        case CLASS_TYPE_RANGER:
            return CLASS_NAME_RANGER;
        case CLASS_TYPE_ROGUE:
            return CLASS_NAME_ROGUE;
        case CLASS_TYPE_SORCERER:
            return CLASS_NAME_SORCERER;
        case CLASS_TYPE_WIZARD:
            return CLASS_NAME_WIZARD;
        case CLASS_TYPE_ARCANE_ARCHER:
            return CLASS_NAME_ARCANE_ARCHER;
        case CLASS_TYPE_ASSASSIN:
            return CLASS_NAME_ASSASSIN;
        case CLASS_TYPE_BLACKGUARD:
            return CLASS_NAME_BLACKGUARD;
        case CLASS_TYPE_HARPER:
            return CLASS_NAME_HARPER;
        case CLASS_TYPE_SHADOWDANCER:
            return CLASS_NAME_SHADOWDANCER;
        case CLASS_TYPE_DIVINECHAMPION:
            return CLASS_NAME_DIVINECHAMPION;
        case CLASS_TYPE_DRAGONDISCIPLE:
            return CLASS_NAME_DRAGONDISCIPLE;
        case CLASS_TYPE_DWARVENDEFENDER:
            return CLASS_NAME_DWARVENDEFENDER;
        case CLASS_TYPE_PALEMASTER:
            return CLASS_NAME_PALEMASTER;
        case CLASS_TYPE_SHIFTER:
            return CLASS_NAME_SHIFTER;
        case CLASS_TYPE_WEAPON_MASTER:
            return CLASS_NAME_WEAPON_MASTER;
        default:
            return "";
    }
    return "";
}
