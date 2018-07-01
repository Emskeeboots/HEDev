///////////////////////////////////////////////////////////////////////////////
// deity_onload_fr.nss
//
// Created by: The Krit
// Date: 11/06/06
///////////////////////////////////////////////////////////////////////////////
//
// This file defines Forgotten Realms deities.
//
// These deities are based on those I found on Wikipedia
// (http://en.wikipedia.org/wiki/List_of_Forgotten_Realms_deities).
// When Wikipedia lacked info, I turned to a Forgotten Realms wiki
// (http://forgottenrealms.wikia.com/wiki/Portal:Deities).
//
// I included the greater and intermediate deities of the default playable
// races. I improvised a few things. Most notably, I made all the greater
// deities accept all races, with the exception of racial patrons. (Humans
// ended up without a patron.) Intermediate deities accept only their own
// race, unless there was some reason to allow others. This is probably not
// official canon, but it seemed like a nice balance, and I don't have the
// source books to work with.
//
// If you use this file with the sample conversation I wrote, the line about
// humans following Pelor will not fit. C'est la vie. It's only a small change
// to make if you want to use that conversation and this file. (Either delete
// that line from the conversation, or change "Pelor" to a popular human deity.)
//
///////////////////////////////////////////////////////////////////////////////
//
// This is the file you most likely need to change to adapt to your world.
// The provided deities are examples for how to set up your own pantheon.
//
// You may want to change deity_include to allow additional information to be
// stored for each deity.
//
// For the core info concerning allowed alignments, races, and domains, keep
// in mind that the default is to accept all. If you specify certain races,
// then those races are the only ones that will be able to level as clerics
// of that deity (and similarly for alignments and domains).
//
///////////////////////////////////////////////////////////////////////////////
//
// To use this pantheon system, InitializePantheon() needs to be called in
// the module's OnLoad event.
//
// Alternatively, you could rename the function to main() and make this file
// your module's OnLoad event handler.
//
///////////////////////////////////////////////////////////////////////////////
//
// The following comments are intended to give guidance for defining your
// pantheon. This is not the only way to do things, but following these
// examples should keep your code clean and not scare away the non-scripters.
//
// A minimal deity definition would look something like:
//
//    // Name
//    nDeity = AddDeity("Name");
//
//        // Allow all alignments.
//        // AddClericAlignment(nDeity, ALIGNMENT_,  ALIGNMENT_);
//
//        // Allow all races.
//        // AddClericRace(nDeity, RACIAL_TYPE_);
//
//        // Allow all domains,
//        // AddClericDomain(nDeity, DOMAIN_);
//
// A full (but not maximal, especially if you add fields in deity_include)
// deity definition would look something like:
//
//    // Name
//    nDeity = AddDeity("Name");
//        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
//        SetDeityAvatar(nDeity, "AvatarTag");
//        SetDeityGender(nDeity, GENDER_MALE);
//        SetDeityHolySymbol(nDeity, "HolySymbolTag");
//        SetDeityPortfolio(nDeity, "Ice");
//        SetDeitySpawnLoc(nDeity, "StartLocationTag");
//        SetDeitySwear(nDeity, "By Jack's Frosty Face!");
//        SetDeityTitle(nDeity, "Super Cool One");
//        SetDeityTitleAlternates(nDeity, "Frosty the Snowman and Jack Frost");
//        SetDeityWeapon(nDeity, WEAPON_WHIP);
//
//        SetClericGender(nDeity, GENDER_MALE);  // clerics can only be male.  Default is BOTH/ALL
//        // Allowed alignments.
//        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
//        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
//        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
//
//        // Allowed races.
//        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
//        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
//        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);
//
//        // Domain choices.
//        AddClericDomain(nDeity, DOMAIN_GOOD);
//        AddClericDomain(nDeity, DOMAIN_HEALING);
//        AddClericDomain(nDeity, DOMAIN_PROTECTION);
//        AddClericDomain(nDeity, DOMAIN_WATER);
//
///////////////////////////////////////////////////////////////////////////////


#include "deity_include"
// Shorter names for the domains.
const int DOMAIN_AIR         = FEAT_AIR_DOMAIN_POWER;
const int DOMAIN_ANIMAL      = FEAT_ANIMAL_DOMAIN_POWER;
const int DOMAIN_CHAOS       = FEAT_CHAOS_DOMAIN_POWER;
const int DOMAIN_DEATH       = FEAT_DEATH_DOMAIN_POWER;
const int DOMAIN_DESTRUCTION = FEAT_DESTRUCTION_DOMAIN_POWER;
const int DOMAIN_EARTH       = FEAT_EARTH_DOMAIN_POWER;
const int DOMAIN_EVIL        = FEAT_EVIL_DOMAIN_POWER;
const int DOMAIN_FIRE        = FEAT_FIRE_DOMAIN_POWER;
const int DOMAIN_GOOD        = FEAT_GOOD_DOMAIN_POWER;
const int DOMAIN_HEALING     = FEAT_HEALING_DOMAIN_POWER;
const int DOMAIN_KNOWLEDGE   = FEAT_KNOWLEDGE_DOMAIN_POWER;
const int DOMAIN_LAW         = FEAT_LAW_DOMAIN_POWER;
const int DOMAIN_LUCK        = FEAT_LUCK_DOMAIN_POWER;
const int DOMAIN_MAGIC       = FEAT_MAGIC_DOMAIN_POWER;
const int DOMAIN_PLANT       = FEAT_PLANT_DOMAIN_POWER;
const int DOMAIN_PROTECTION  = FEAT_PROTECTION_DOMAIN_POWER;
const int DOMAIN_STRENGTH    = FEAT_STRENGTH_DOMAIN_POWER;
const int DOMAIN_SUN         = FEAT_SUN_DOMAIN_POWER;
const int DOMAIN_TRAVEL      = FEAT_TRAVEL_DOMAIN_POWER;
const int DOMAIN_TRICKERY    = FEAT_TRICKERY_DOMAIN_POWER;
const int DOMAIN_WAR         = FEAT_WAR_DOMAIN_POWER;
const int DOMAIN_WATER       = FEAT_WATER_DOMAIN_POWER;
//const int DOMAIN_DARKNESS    = FEAT_DARKNESS_DOMAIN_POWER;

// Sets some module variables to represent the supported pantheon.
// This pantheon consists of the Forgotten Realms deities.
void InitializePantheon();

void main () {
       InitializePantheon();
}
///////////////////////////////////////////////////////////////////////////////
// InitializePantheon()
//
// Sets some module variables to represent the supported pantheon.
//
// Customize to suit your world. No string has special meaning to this system,
// so feel free to change them, as well as the alignment, racial, domain, and
// gender constants, and add and delete deities as needed.
void InitializePantheon()
{
    int nDeity; // Index for the deity being added.

    // Only need to do this once
    if (GetLocalInt(GetModule(), "pantheon_initialized"))    return;
    SetLocalInt(GetModule(), "pantheon_initialized", 1);


    // Initializations for unknown deities:
    SetDeitySpawnLoc(-1, "Default_Start");  // (See GetPlayerSpawnLocation() in deity_example.)
    SetDeitySwear(-1, "By the gods!");      // (See Swear() in deity_example.)


    // The pantheon:


    // Abbathor (intermediate god)
    nDeity = AddDeity("Abbathor");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Abbathor_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Abbathor_Symbol");
        SetDeityPortfolio(nDeity, "greed");
        SetDeitySpawnLoc(nDeity, "Abbathor_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "Great Master of Greed, Trove Lord, the Avaricious, and Wyrm of Avarice");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);

    // Aerdrie Faenya (intermediate goddess)
    nDeity = AddDeity("Aerdrie Faenya");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Aerdrie_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Aerdrie_Symbol");
        SetDeityPortfolio(nDeity, "avariel, air, weather, and avians");
        SetDeitySpawnLoc(nDeity, "Aerdrie_Start");
        SetDeityTitle(nDeity, "elven goddess");
        SetDeityTitleAlternates(nDeity, "the Winged Mother, Lady of Air and Wind, Queen of the Avariel, She of the Azure Plumage, and Bringer of Rain and Storms");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        // Required subrace.
        SetClericSubrace(nDeity, "avariel");

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);

    // Akadi (greater goddess)
    nDeity = AddDeity("Akadi");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Akadi_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Akadi_Symbol");
        SetDeityPortfolio(nDeity, "elemental air, air elementalists, movement, speed, flying creaturs, and travel");
        SetDeitySpawnLoc(nDeity, "Akadi_Start");
        SetDeityTitleAlternates(nDeity, "Queen of the Air, Lady of Air, and Lady of the Winds");
        SetDeityWeapon(nDeity, WEAPON_HEAVYFLAIL);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);

    // Angarradh (greater goddess)
    nDeity = AddDeity("Angarradh");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Angarradh_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Angarradh_Symbol");
        SetDeityPortfolio(nDeity, "birth, defense, fertility, planting, spring, and wisdom");
        SetDeitySpawnLoc(nDeity, "Angarradh_Start");
        SetDeityTitle(nDeity, "elven god");
        SetDeityTitleAlternates(nDeity, "Queen of Arvandor, The Triune Goddess, The One and the THree, and The Union of the Three");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
		AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
		AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
		AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
		AddClericDomain(nDeity, DOMAIN_PLANT);

    // Anhur (lesser deity)
    nDeity = AddDeity("Anhur");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Anhur_Avatar");
        SetDeityHolySymbol(nDeity, "Anhur_Symbol");
        SetDeityPortfolio(nDeity, "war, conflict, physical prowess, thunder, rain");
        SetDeitySpawnLoc(nDeity, "Anhur_Start");
        SetDeityTitleAlternates(nDeity, "General of the Gods, Champion of the Physical Prowess, The Falcon of War, Supreme Marshall of All Armies, and God of War, Thunder, Rain, and Storms");
        SetDeityWeapon(nDeity, WEAPON_FALCHION);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_STRENGTH);
        AddClericDomain(nDeity, DOMAIN_WAR);
        AddClericDomain(nDeity, DOMAIN_GOOD);
			
    // Arvoreen (intermediate god)
    nDeity = AddDeity("Arvoreen");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Arvoreen_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Arvoreen_Symbol");
        SetDeityPortfolio(nDeity, "protection, vigilance, and war");
        SetDeitySpawnLoc(nDeity, "Arvoreen_Start");
        SetDeityTitle(nDeity, "halfling god");
        SetDeityTitleAlternates(nDeity, "the Defender, the Vigilant Guardian, and the Wary Sword");
        SetDeityWeapon(nDeity, WEAPON_SHORTSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFLING);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_WAR);


    // Auril (lesser god)
    nDeity = AddDeity("Auril");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Auril_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Auril_Symbol");
        SetDeityPortfolio(nDeity, "air, evil, and water");
        SetDeitySpawnLoc(nDeity, "Auril_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "the Cold Goddess, The Frostmaiden, and Lady Frostkiss");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_WATER);

    // Azuth (lesser god)
    nDeity = AddDeity("Azuth");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Azuth_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Azuth_Symbol");
        SetDeityPortfolio(nDeity, "magic, knowledge, and law");
        SetDeitySpawnLoc(nDeity, "Azuth_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "High One, Patron of Wizards, and The First Magister");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF); //

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_MAGIC);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_LAW);


    // Baervan Wildwanderer (intermediate god)
    nDeity = AddDeity("Baervan Wildwanderer");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Baervan_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Baervan_Symbol");
        SetDeityPortfolio(nDeity, "forests, travel, and nature");
        SetDeitySpawnLoc(nDeity, "Baervan_Start");
        SetDeityTitle(nDeity, "gnomish god");
        SetDeityTitleAlternates(nDeity, "the Masked Leaf, the Forest Gnome, and Father of Fish and Fungus");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Bahamut (lesser god)
    nDeity = AddDeity("Bahamut");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Bahamut_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Bahamut_Symbol");
        SetDeityPortfolio(nDeity, "good dragons, wind and wisdom");
        SetDeitySpawnLoc(nDeity, "Bahamut_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "angel of the Seven , heavens, and the god of dragons");
        SetDeityWeapon(nDeity, WEAPON_HEAVYPICK); //

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_GOOD, ALIGNMENT_LAWFUL);
        AddClericAlignment(nDeity, ALIGNMENT_GOOD, ALIGNMENT_LAWFUL);
        AddClericAlignment(nDeity, ALIGNMENT_GOOD, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Bahgtru (intermediate god)
    nDeity = AddDeity("Bahgtru");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Bahgtru_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Bahgtru_Symbol");
        SetDeityPortfolio(nDeity, "strength and combat");
        SetDeitySpawnLoc(nDeity, "Bahgtru_Start");
        SetDeityTitle(nDeity, "orcish god");
        SetDeityTitleAlternates(nDeity, "the Strong, the Leg-Breaker, and Son of Gruumsh");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);


    // Bane (greater god)
    nDeity = AddDeity("Bane");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Bane_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Bane_Symbol");
        SetDeityPortfolio(nDeity, "strife, hatred, tyranny, and fear");
        SetDeitySpawnLoc(nDeity, "Bane_Start");
        SetDeityTitleAlternates(nDeity, "the Black Lord, the Black Hand, and the Lord of Darkness");
        SetDeityWeapon(nDeity, WEAPON_MORNINGSTAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LAW);


    // Beshaba (intermediate goddess)
    nDeity = AddDeity("Beshaba");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Beshaba_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Beshaba_Symbol");
        SetDeityPortfolio(nDeity, "random mischief, misfortune, bad luck, and accidents");
        SetDeitySpawnLoc(nDeity, "Beshaba_Start");
        SetDeityTitleAlternates(nDeity, "the Maid of Misfortune and Lady Doom");
        SetDeityWeapon(nDeity, WEAPON_WHIP); // Scourge, if that is available.

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);

    // Berronar Truesilver (intermediate goddess)
    nDeity = AddDeity("Berronar Truesilver");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Berronar_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Berronar_Symbol");
        SetDeityPortfolio(nDeity, "safety, truth, home, and healing");
        SetDeitySpawnLoc(nDeity, "Berronar_Start");
        SetDeityTitle(nDeity, "dwarven goddess");
        SetDeityTitleAlternates(nDeity, "the Revered Mother, the Mother Goddess, Matron of Home and Hearth, and Mother of Safety, Truth, and Home");
        SetDeityWeapon(nDeity, WEAPON_HEAVYMACE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_HEALING);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
		
    // Brandobaris (lesser god)
    nDeity = AddDeity("Brandobaris");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Brandobaris_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Brandobaris_Symbol");
        SetDeityPortfolio(nDeity, "stealth, adventuring, halfling rogues");
        SetDeitySpawnLoc(nDeity, "Brandobaris_Start");
		SetDeityTitle(nDeity, "halfling god");
        SetDeityTitleAlternates(nDeity, "The Irresponsible Scamp, master of stealth");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
		AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
		AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFLING);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);
		
    // Callarduran Smoothhands (intermediate god)
    nDeity = AddDeity("Callarduran Smoothhands");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Callarduran_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Callarduran_Symbol");
        SetDeityPortfolio(nDeity, "the svirfneblin, protection, earth, and mining");
        SetDeitySpawnLoc(nDeity, "Callarduran_Start");
        SetDeityTitle(nDeity, "gnomish god");
        SetDeityTitleAlternates(nDeity, "Deep Brother, Master of Stone, Lord of Deepearth, and the Deep Gnome");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);
        // Required subrace.
        SetClericSubrace(nDeity, "svirfneblin");

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EARTH);
        // Doubling up Earth allows Earth + any domain.
        AddClericDomain(nDeity, DOMAIN_EARTH);


    // Chauntea (greater goddess)
    nDeity = AddDeity("Chauntea");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Chauntea_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Chauntea_Symbol");
        SetDeityPortfolio(nDeity, "agriculture, plants cultivated by humans, farmers, gardeners, and summer");
        SetDeitySpawnLoc(nDeity, "Chauntea_Start");
        SetDeityTitleAlternates(nDeity, "the Great Mother, the Grain Goddess, and the Earthmother");
        SetDeityWeapon(nDeity, WEAPON_SCYTHE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Clanggedin Silverbeard (intermediate god)
    nDeity = AddDeity("Clanggedin Silverbeard");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Clanggedin_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Clanggedin_Symbol");
        SetDeityPortfolio(nDeity, "battle");
        SetDeitySpawnLoc(nDeity, "Clanggedin_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "the Father of Battle, Lord of the Twin Axes, the Giantkiller, the Goblinbane, the Wyrmslayer, and the Rock of Battle");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);
        AddClericDomain(nDeity, DOMAIN_WAR);


    // Corellon Larethian (greater god)
    nDeity = AddDeity("Corellon Larethian");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Corellon_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Corellon_Symbol");
        SetDeityPortfolio(nDeity, "the elves, magic, music, arts, crafts, war, poets, poetry, bards, and warriors");
        SetDeitySpawnLoc(nDeity, "Corellon_Start");
        SetDeityTitleAlternates(nDeity, "Creator of the Elves, the Protector, First of the Seldarine, Protector and Preserver of Life, Ruler of All Elves, and Coronal of Arvandor");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_WAR);


    // Cyric (greater god)
    nDeity = AddDeity("Cyric");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Cyric_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Cyric_Symbol");
        SetDeityPortfolio(nDeity, "murder, lies, intrigue, deception, and illusion");
        SetDeitySpawnLoc(nDeity, "Cyric_Start");
        SetDeityTitleAlternates(nDeity, "Prince of Lies, the Dark Sun, the Black Sun, the Mad God, and the Lord of Three Crowns");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);


    // Cyrrollalee (intermediate goddess)
    nDeity = AddDeity("Cyrrollalee");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Cyrrollalee_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Cyrrollalee_Symbol");
        SetDeityPortfolio(nDeity, "friendship, trust, and home");
        SetDeitySpawnLoc(nDeity, "Cyrrollalee_Start");
        SetDeityTitle(nDeity, "halfling goddess");
        SetDeityTitleAlternates(nDeity, "the Hand of Fellowship, the Faithful, and the Hearthkeeper");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFLING);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LAW);

    // Deep Sashelas (intermediate god)
    nDeity = AddDeity("Deep Sashelas");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Sashelas_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Sashelas_Symbol");
        SetDeityPortfolio(nDeity, "creation, knowledge, beauty, and magic");
        SetDeitySpawnLoc(nDeity, "Sashelas_Start");
        SetDeityTitle(nDeity, "elven god");
        SetDeityTitleAlternates(nDeity, "Lord of the Undersea, the Dolphin Prince, the Knowledgeable One, Sailor's Friend, and the Creator");
        SetDeityWeapon(nDeity, WEAPON_TRIDENT);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        // Required subrace.
        SetClericSubrace(nDeity, "aquatic elf");

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_WATER);

    // Deep Duerra (demigoddess)
    nDeity = AddDeity("Deep Duerra");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Duerra_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Duerra_Symbol");
        SetDeityPortfolio(nDeity, "psionics, conquest, expansion");
        SetDeitySpawnLoc(nDeity, "Duerra_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "Queen of the Invisible Art, Axe Princess of Conquest");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_WAR);
		
    // Deneir (lesser god)
    nDeity = AddDeity("Deep Deneir");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Deneir_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Deneir_Symbol");
        SetDeityPortfolio(nDeity, "cartography , glyphs, images , literature and scribes");
        SetDeitySpawnLoc(nDeity, "Deneir_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "Lord of All Glyphs and Images, the Scribe of Oghma, and the First Scribe");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);

    // Dugmaren Brightmantle (lesser god)
    nDeity = AddDeity("Dugmaren Brightmantle");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Dugmaren_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Dugmaren_Symbol");
        SetDeityPortfolio(nDeity, "discovery, invention, scholarship");
        SetDeitySpawnLoc(nDeity, "Dugmaren_Start");
        SetDeityTitle(nDeity, "dawarven god");
        SetDeityTitleAlternates(nDeity, "The Errant Explorer, The Gleam in the Eye, and The Wandering Tinker");
        SetDeityWeapon(nDeity, WEAPON_SHORTSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
		
    // Dumathoin (intermediate god)
    nDeity = AddDeity("Dumathoin");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Dumathoin_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Dumathoin_Symbol");
        SetDeityPortfolio(nDeity, "mining, mountain dwarves, and underground exploration");
        SetDeitySpawnLoc(nDeity, "Dumathoin_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "Keeper of Secrets under the Mountain, the Silent Keeper, and the Mountain Shield");
        SetDeityWeapon(nDeity, WEAPON_MAUL);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Eldath (lesser god)
    nDeity = AddDeity("Eldath");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Eldath_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Eldath_Symbol");
        SetDeityPortfolio(nDeity, "quiet places, springs , pools , peace and waterfalls");
        SetDeitySpawnLoc(nDeity, "Eldath_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "Goddess of Singing Waters, Mother Guardian of Groves, and the Green Goddess");
        SetDeityWeapon(nDeity, WEAPON_SAI); //net ??

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_WATER);

    // Erevan Ilesere (intermediate god)
    nDeity = AddDeity("Erevan Ilesere");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Erevan_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Erevan_Symbol");
        SetDeityPortfolio(nDeity, "mischief, change, and rogues");
        SetDeitySpawnLoc(nDeity, "Erevan_Start");
        SetDeityTitle(nDeity, "elven god");
        SetDeityTitleAlternates(nDeity, "the Trickster, the Chameleon, the Green Changeling, the Evershifting Shapechanger, the Fey Jester, and the Jack of the Seelie Court");
        SetDeityWeapon(nDeity, WEAPON_SHORTSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);

    // Fenmarel Mestarine (lesser god)
    nDeity = AddDeity("Fenmarel Mestarine");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Fenmarel_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Fenmarel_Symbol");
        SetDeityPortfolio(nDeity, "druids, elves, outcasts, scapegoats, isolation");
        SetDeitySpawnLoc(nDeity, "Fenmarel_Start");
        SetDeityTitle(nDeity, "elven god");
        SetDeityTitleAlternates(nDeity, "The Lone Wolf");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELFELVEN);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);
		
    // Finder Wyvernspur (demnigod)
    nDeity = AddDeity("Finder Wyvernspur");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Finder_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Finder_Symbol");
        SetDeityPortfolio(nDeity, "cycles of Life , saurials, and transformation of art");
        SetDeitySpawnLoc(nDeity, "Finder_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "The Nameless Bard");
        SetDeityWeapon(nDeity, WEAPON_BASTARDSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Flandal Steelskin (intermediate god)
    nDeity = AddDeity("Flandal Steelskin");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Flandal_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Flandal_Symbol");
        SetDeityPortfolio(nDeity, "mining, smithing, and fitness");
        SetDeitySpawnLoc(nDeity, "Flandal_Start");
        SetDeityTitle(nDeity, "gnomish god");
        SetDeityTitleAlternates(nDeity, "Master of Metal, Lord of Smiths, the Armorer, the Weaponsmith, the Great Steelsmith, and the Pyromancer");
        SetDeityWeapon(nDeity, WEAPON_WARHAMMER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        // Doubling up Good allows Good + any domain.
        AddClericDomain(nDeity, DOMAIN_GOOD);

    // Gaerdal Ironhand (lesser god)
    nDeity = AddDeity("Gaerdal Ironhand");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Gaerdal_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Gaerdal_Symbol");
        SetDeityPortfolio(nDeity, "vigilance, combat, and martial defence");
        SetDeitySpawnLoc(nDeity, "Gaerdal_Start");
        SetDeityTitle(nDeity, "gnomish god");
        SetDeityTitleAlternates(nDeity, "The Stern, Sheild of the Golden Hills");
        SetDeityWeapon(nDeity, WEAPON_WARHAMMER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_WAR);

    // Garagos (demigod)
    nDeity = AddDeity("Garagos");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Garagos_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Garagos_Symbol");
        SetDeityPortfolio(nDeity, "destruction, plunder, skill-at-arms, and war");
        SetDeitySpawnLoc(nDeity, "Garagos_Start");
        SetDeityTitleAlternates(nDeity, "Lord of War, Master of All Weapons, The Reaver");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);
        AddClericDomain(nDeity, DOMAIN_WAR);


    // Gargauth (demigod)
    nDeity = AddDeity("Gargauth");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Gargauth_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Gargauth_Symbol");
        SetDeityPortfolio(nDeity, "betrayal, cruelty, political corruption, and powerbrokers");
        SetDeitySpawnLoc(nDeity, "Gargauth_Start");
        SetDeityTitleAlternates(nDeity, "The Hidden Lord, The Lord Who Watches, The Outcast");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);


    // Garl Glittergold (greater god)
    nDeity = AddDeity("Garl Glittergold");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Garl_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Garl_Symbol");
        SetDeityPortfolio(nDeity, "the gnomes, protection, humor, trickery, gemcutting, and smithing");
        SetDeitySpawnLoc(nDeity, "Garl_Start");
        SetDeityTitleAlternates(nDeity, "the Joker, the Watchful Protector, the Priceless Gem, and the Sparkling Wit");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);

	
    // Geb (lesser deity)
    nDeity = AddDeity("Geb");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Geb_Avatar");
        SetDeityHolySymbol(nDeity, "Geb_Symbol");
        SetDeityPortfolio(nDeity, "the earth, miners, mines, and mineral resources");
        SetDeitySpawnLoc(nDeity, "Geb_Start");
        SetDeityTitleAlternates(nDeity, "King of the Riches Under the Earth, Father Under the Skies and Sands, and Lord Earth");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
		
        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
		 
    // Gond (intermediate god)
    nDeity = AddDeity("Gond");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Gond_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Gond_Symbol");
        SetDeityPortfolio(nDeity, "invention, artifice, craft, construction, and smithwork");
        SetDeitySpawnLoc(nDeity, "Gond_Start");
        SetDeityTitleAlternates(nDeity, "Wonderbringer and Lord of All Smiths");
        SetDeityWeapon(nDeity, WEAPON_WARHAMMER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_FIRE);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);

    // Gorm Gulthyn (lesser god)
    nDeity = AddDeity("Gorm Gulthyn");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Gorm_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Gorm_Symbol");
        SetDeityPortfolio(nDeity, "guardian of all dwarves, defense, watchfulness");
        SetDeitySpawnLoc(nDeity, "Gorm_Start");
        SetDeityTitle(nDeity, "dwarf god");
        SetDeityTitleAlternates(nDeity, "Fire Eyes, Lord of the Bronze Mask, and the Eternally Vigilant");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);


        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_WAR);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
		
    // Grumbar (greater god)
    nDeity = AddDeity("Grumbar");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Grumbar_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Grumbar_Symbol");
        SetDeitySpawnLoc(nDeity, "Grumbar_Start");
        SetDeityTitle(nDeity, "Elemental Lord of the Earth");
        SetDeityTitleAlternates(nDeity, "Gnarly One, King of the Land Below the Roots, Boss of the Earth Elementals, and Earthlord");
        SetDeityWeapon(nDeity, WEAPON_WARHAMMER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EARTH);
        // Doubling up Earth allows Earth + any domain.
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Gruumsh (greater god)
    nDeity = AddDeity("Gruumsh");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Gruumsh_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Gruumsh_Symbol");
        SetDeityPortfolio(nDeity, "orcs, conquest, survival, strength, and territory");
        SetDeitySpawnLoc(nDeity, "Gruumsh_Start");
        SetDeityTitleAlternates(nDeity, "One-Eye, He-Who-Watches, and He-Who-Never-Sleeps");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);
        AddClericDomain(nDeity, DOMAIN_WAR);


    // Gwaeron Windstrom (greater god)
    nDeity = AddDeity("Gwaeron Windstrom");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Gwaeron_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Gwaeron_Symbol");
        SetDeityPortfolio(nDeity, "tracking and rangers");
        SetDeitySpawnLoc(nDeity, "Gwaeron_Start");
        SetDeityTitleAlternates(nDeity, "Master of Tracking, Tracker Who Never Goes Astray, and Master Tracker");
        SetDeityWeapon(nDeity, WEAPON_GREATSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Hanali Celanil (intermediate goddess)
    nDeity = AddDeity("Hanali Celanil");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Hanali_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Hanali_Symbol");
        SetDeityPortfolio(nDeity, "romantic love and beauty");
        SetDeitySpawnLoc(nDeity, "Hanali_Start");
        SetDeityTitle(nDeity, "elven goddess");
        SetDeityTitleAlternates(nDeity, "the Heart of Gold, Winsome Rose, Archer of Love, Kiss of Romance, and Lady Goldheart");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_MAGIC);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);

    // Haaela Brightaxe (demigoddess)
    nDeity = AddDeity("Haela Brightaxe");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Haela_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Haela_Symbol");
        SetDeityPortfolio(nDeity, "luck in battle, joy of battle, dwarven warriors");
        SetDeitySpawnLoc(nDeity, "Haela_Start");
        SetDeityTitle(nDeity, "dwarven goddess");
        SetDeityTitleAlternates(nDeity, "Lady of the Fray, and Luckmaiden");
        SetDeityWeapon(nDeity, WEAPON_GREATSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LCUK);
        AddClericDomain(nDeity, DOMAIN_WAR);

	// Hathor (lesser deity)
    nDeity = AddDeity("Hathor");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Hathor_Avatar");
        SetDeityHolySymbol(nDeity, "Hathor_Symbol");
        SetDeityPortfolio(nDeity, "motherhood, folk music, dance, the moon, and fate");
        SetDeitySpawnLoc(nDeity, "Hathor_Start");
        SetDeityTitleAlternates(nDeity, "The Nurturing Mother, THe Quiet One, The Dancer of FOrtune, and She Who is There for Those in Need");
        SetDeityWeapon(nDeity, WEAPON_SHORTSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_HEALING);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
	
    // Helm (intermediate god)
    nDeity = AddDeity("Helm");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Helm_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Helm_Symbol");
        SetDeityPortfolio(nDeity, "guardians, protectors, and protection");
        SetDeitySpawnLoc(nDeity, "Helm_Start");
        SetDeityTitleAlternates(nDeity, "the Great Guard, the Watcher, and the Vigilant One");
        SetDeityWeapon(nDeity, WEAPON_BASTARDSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);



    // Hoar (demigod)
    nDeity = AddDeity("Hoar");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Hoar_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Hoar_Symbol");
        SetDeityPortfolio(nDeity, "poetic justice, and retribution");
        SetDeitySpawnLoc(nDeity, "Hoar_Start");
        SetDeityTitleAlternates(nDeity, "Assuran, the Doombringer, and Lord of Three Thunders");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);

			
    // Horus-Re (greater deity)
    nDeity = AddDeity("Horus-Re");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Horus_Avatar");
        SetDeityHolySymbol(nDeity, "Horus_Symbol");
        SetDeityPortfolio(nDeity, "the sun, vengeance, rulership, kings, and life");
        SetDeitySpawnLoc(nDeity, "Horus_Start");
        SetDeityTitleAlternates(nDeity, "Lord of the Sun, Master of Vengeance, Rule of Mulhorand, and Pharaoh of the Gods");
        SetDeityWeapon(nDeity, WEAPON_SICKLE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_SUN);

    // Ilmater (intermediate god)
    nDeity = AddDeity("Ilmater");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Ilmater_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Ilmater_Symbol");
        SetDeityPortfolio(nDeity, "endurance, suffering, martyrdom, and perseverance");
        SetDeitySpawnLoc(nDeity, "Ilmater_Start");
        SetDeityTitleAlternates(nDeity, "the Crying God, the Broken God, the Lord on the Rack, and the One Who Endures");
        SetDeityWeapon(nDeity, WEAPON_UNARMEDSTRIKE); // Includes unarmed strike.

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_HEALING);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);


    // Ilneval (intermediate god)
    nDeity = AddDeity("Ilneval");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Ilneval_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Ilneval_Symbol");
        SetDeityPortfolio(nDeity, "warfare");
        SetDeitySpawnLoc(nDeity, "Ilneval_Start");
        SetDeityTitle(nDeity, "orcish god");
        SetDeityTitleAlternates(nDeity, "Son of Strife, the Horde Leader, the War Maker, and the Lieutenant of Gruumsh");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_WAR);

				
    // Isis (intermediate deity)
    nDeity = AddDeity("Isis");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Isis_Avatar");
        SetDeityHolySymbol(nDeity, "Isis_Symbol");
        SetDeityPortfolio(nDeity, "weather, rivers, agriculture, love, marriage, and good magic");
        SetDeitySpawnLoc(nDeity, "Isis_Start");
        SetDeityTitleAlternates(nDeity, "Bountiful Lady, Lady of All Love, Mistress of Weather, Lady of Rivers, and Mistress of Enchantment");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_MAGIC);
        AddClericDomain(nDeity, DOMAIN_WATER);

    // Istishia (greater god)
    nDeity = AddDeity("Istishia");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Istishia_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Istishia_Symbol");
        SetDeityPortfolio(nDeity, "elemental water and purification");
        SetDeitySpawnLoc(nDeity, "Istishia_Start");
        SetDeityTitleAlternates(nDeity, "the Water Lord and King of the Water Elementals");
        SetDeityWeapon(nDeity, WEAPON_WARHAMMER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_WATER);


    // Jergal (demigod)
    nDeity = AddDeity("Jergal");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Jergal_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Jergal_Symbol");
        SetDeityPortfolio(nDeity, "fatalism, guardian of the tombs and proper burial");
        SetDeitySpawnLoc(nDeity, "Jergal_Start");
        SetDeityTitleAlternates(nDeity, "Lord of the End of Everything, The Pitiless One and The Guardians of Tombs");
        SetDeityWeapon(nDeity, WEAPON_SCYTHE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);


        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_DEATH);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);


    // Kelemvor Lyonsbane (greater god)
    nDeity = AddDeity("Kelemvor Lyonsbane");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Kelemvor_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Kelemvor_Symbol");
        SetDeityPortfolio(nDeity, "death and the dead");
        SetDeitySpawnLoc(nDeity, "Kelemvor_Start");
        SetDeityTitleAlternates(nDeity, "Lord of the Dead, Judge of the Damned, and Master of the Crystal Spire");
        SetDeityWeapon(nDeity, WEAPON_BASTARDSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.

        AddClericDomain(nDeity, DOMAIN_DEATH);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);

    // Kossuth (greater god)
    nDeity = AddDeity("Kossuth");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Kossuth_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Kossuth_Symbol");
        SetDeityPortfolio(nDeity, "elemental fire and purification through fire");
        SetDeitySpawnLoc(nDeity, "Kossuth_Start");
        SetDeityTitleAlternates(nDeity, "the Fire God, the Lord of Flames, and the Firelord");
        SetDeityWeapon(nDeity, WEAPON_MORNINGSTAR); // "Spiked chain", if that was available.

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_FIRE);


    // Labelas Enoreth (intermediate god)
    nDeity = AddDeity("Labelas Enoreth");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Labelas_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Labelas_Symbol");
        SetDeityPortfolio(nDeity, "time and longevity");
        SetDeitySpawnLoc(nDeity, "Labelas_Start");
        SetDeityTitle(nDeity, "elven god");
        SetDeityTitleAlternates(nDeity, "the Lifegiver, Lord of the Continuum, the One-Eyed God, the Philosopher, and the Sage at Sunset");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);


    // Laduguer (intermediate god)
    nDeity = AddDeity("Laduguer");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Laduguer_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Laduguer_Symbol");
        SetDeityPortfolio(nDeity, "the duergar, crafts, magic, and protection");
        SetDeitySpawnLoc(nDeity, "Laduguer_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "the Exile, the Gray Protector, Master of Crate, the Slave Driver, the Taskmaster, and the Harsh");
        SetDeityWeapon(nDeity, WEAPON_WARHAMMER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);
        // Required subrace.
        SetClericSubrace(nDeity, "duergar");

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_MAGIC);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Lathander (greater god)
    nDeity = AddDeity("Lathander");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Lathander_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Lathander_Symbol");
        SetDeityPortfolio(nDeity, "spring, dawn, birth, renewal, creativity, youth, vitality, self-perfection, and athletics");
        SetDeitySpawnLoc(nDeity, "Lathander_Start");
        SetDeityTitleAlternates(nDeity, "the Morninglord");
        SetDeityWeapon(nDeity, WEAPON_MACE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);
        AddClericDomain(nDeity, DOMAIN_SUN);


    // Lliira (lesser god)
    nDeity = AddDeity("Lliira");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Lliira_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Lliira_Symbol");
        SetDeityPortfolio(nDeity, "dance, festivals, happiness, joy, freedom, and liberty");
        SetDeitySpawnLoc(nDeity, "Lliira_Start");
        SetDeityTitleAlternates(nDeity, "Joybringer, Mistress of Revels, and Our Lady of Joy");
        SetDeityWeapon(nDeity, WEAPON_SHURIKEN);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Lolth (intermediate goddess)
    nDeity = AddDeity("Lolth");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Lolth_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Lolth_Symbol");
        SetDeityPortfolio(nDeity, "the drow, spiders, evil, chaos, assassins, and darkness");
        SetDeitySpawnLoc(nDeity, "Lolth_Start");
        SetDeityTitle(nDeity, "Spider Goddess");
        SetDeityTitleAlternates(nDeity, "Lady of Spiders, Demon Queen of Spiders, Queen of the Demonweb Pits, Weaver of Chaos, and Dark Mother of all Drow");
        SetDeityWeapon(nDeity, WEAPON_WHIP);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        // Required subrace.
        SetClericSubrace(nDeity, "drow");

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);



    // Loviatar (lesser god)
    nDeity = AddDeity("Loviatar");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Loviatar_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Loviatar_Symbol");
        SetDeityPortfolio(nDeity, "hurt, agony, torment, suffering, and torture");
        SetDeitySpawnLoc(nDeity, "Loviatar_Start");
        SetDeityTitleAlternates(nDeity, "The Maiden of Pain, The Willing Whip, and the Scourge Mistress");
        SetDeityWeapon(nDeity, WEAPON_WHIP);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);


    // Lurue (demigod)
    nDeity = AddDeity("Lurue");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Lurue_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Lurue_Symbol");
        SetDeityPortfolio(nDeity, "talking beasts, and intelligent nonhumanoid creatures");
        SetDeitySpawnLoc(nDeity, "Lurue_Start");
        SetDeityTitleAlternates(nDeity, "The Unicorn, The Unicorn Queen, and the Queen of Talking Beasts");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_HEALING);

    // Luthic (demigod)
    nDeity = AddDeity("Luthic");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Luthic_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Luthic_Symbol");
        SetDeityPortfolio(nDeity, "caves, fertility, healing, home, orc females, servitude, wisdom");
        SetDeitySpawnLoc(nDeity, "Luthic_Start");
        SetDeityTitle(nDeity, "orc deity");
        SetDeityTitleAlternates(nDeity, "Cave Mother, and Blood Moon Witch");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_HEALING);

    // Malar (demigod)
    nDeity = AddDeity("Malar");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Malar_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Malar_Symbol");
        SetDeityPortfolio(nDeity, "bloodlust, evil lycanthropes, hunters, marauding beasts and monsters and stalking");
        SetDeitySpawnLoc(nDeity, "Malar_Start");
        SetDeityTitleAlternates(nDeity, "The Beastlord, and The Black-Blooded One");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);

    // Marthammor Duin (exarch)
    nDeity = AddDeity("Marthammor Duin");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Marthammor_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Marthammor_Symbol");
        SetDeityPortfolio(nDeity, "expatriates, guides, lightning, and travelers");
        SetDeitySpawnLoc(nDeity, "Marthammor_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "Finder of Trails, Watcher Over Wanderers, and The Watchful Eye");
        SetDeityWeapon(nDeity, WEAPON_HEAVYMACE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);

    // Mask (demigod)
    nDeity = AddDeity("Mask");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Mask_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Mask_Symbol");
        SetDeityPortfolio(nDeity, "shadows, thievery, and thieves");
        SetDeitySpawnLoc(nDeity, "Mask_Start");
        SetDeityTitleAlternates(nDeity, "Lord of Shadows, Master of All Thieves and The Shadowlord");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
//        AddClericDomain(nDeity, DOMAIN_DARKNESS);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);


    // Mielikki (intermediate goddess)
    nDeity = AddDeity("Mielikki");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Mielikki_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Mielikki_Symbol");
        SetDeityPortfolio(nDeity, "autumn, dryads, forest creatures, forests, and rangers");
        SetDeitySpawnLoc(nDeity, "Mielikki_Start");
        SetDeityTitleAlternates(nDeity, "Our Lady of the Forest, the Forest Queen, the Supreme Ranger, and Daughter to Silvanus");
        SetDeityWeapon(nDeity, WEAPON_SCIMITAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Milil (lesser goddess)
    nDeity = AddDeity("Milil");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Milil_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Milil_Symbol");
        SetDeityPortfolio(nDeity, "eloquence, poetry, and song");
        SetDeitySpawnLoc(nDeity, "Milil_Start");
        SetDeityTitleAlternates(nDeity, "Lord of Songs, Lord of All Songs, and Guardian of Singers and Troubadours");
        SetDeityWeapon(nDeity, WEAPON_RAPIER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);



    // Moradin (greater god)
    nDeity = AddDeity("Moradin");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Moradin_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Moradin_Symbol");
        SetDeityPortfolio(nDeity, "dwarves, creation, smithing, protection, metalcraft, and stonework");
        SetDeitySpawnLoc(nDeity, "Moradin_Start");
        SetDeityTitleAlternates(nDeity, "the Soul Forger, the Dwarffather, the All-Father, and the Creator");
        SetDeityWeapon(nDeity, WEAPON_WARHAMMER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Mystra (greater goddess)
    nDeity = AddDeity("Mystra");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Mystra_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Mystra_Symbol");
        SetDeityPortfolio(nDeity, "magic, spells and the weave");
        SetDeitySpawnLoc(nDeity, "Mystra_Start");
        SetDeityTitleAlternates(nDeity, "the Lady of Mysteries and the Mother of All Magic");
        SetDeityWeapon(nDeity, WEAPON_SHURIKEN);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_MAGIC);

		
     // Nephthys (intermediate deity)
    nDeity = AddDeity("Nephthys");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Nephthys_Avatar");
        SetDeityHolySymbol(nDeity, "Nephthys_Symbol");
        SetDeityPortfolio(nDeity, "wealth, trade, and protector of children and the dead");
        SetDeitySpawnLoc(nDeity, "Nephthys_Start");
        SetDeityTitleAlternates(nDeity, "Guardian of Wealth and Commerce, Protector of the Dead, The Devoted Lady, The Lady of Sands, and The Avenging Mother");
        SetDeityWeapon(nDeity, WEAPON_WHIP);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);

    // Nobanion (demigod)
    nDeity = AddDeity("Nobanion");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Nobanion_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Nobanion_Symbol");
        SetDeityPortfolio(nDeity, "royalty, lions and feline beasts and good beasts");
        SetDeitySpawnLoc(nDeity, "Nobanion_Start");
        SetDeityTitleAlternates(nDeity, "Lord Firemane, King of the Beasts and The Lion King");
        SetDeityWeapon(nDeity, WEAPON_HEAVYPICK);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_GOOD);


    // Oghma (greater god)
    nDeity = AddDeity("Oghma");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Oghma_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Oghma_Symbol");
        SetDeityPortfolio(nDeity, "knowledge, invention, inspiration, and bards");
        SetDeitySpawnLoc(nDeity, "Oghma_Start");
        SetDeityTitleAlternates(nDeity, "the Lord of Knowledge and the Binder of What is Known");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);

		
    // Osiris (intermediate deity)
    nDeity = AddDeity("Osiris");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Osiris_Avatar");
        SetDeityHolySymbol(nDeity, "Osiris_Symbol");
        SetDeityPortfolio(nDeity, "vegetation, death, the dead, justice, and harvest");
        SetDeitySpawnLoc(nDeity, "Osiris_Start");
        SetDeityTitleAlternates(nDeity, "Lord of Nature, Judge of the Dead, The White Crown, and Reaper of the Harvest");
        SetDeityWeapon(nDeity, WEAPON_HEAVYFLAIL);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLAN);
        AddClericDomain(nDeity, DOMAIN_DEATH);

    // Red Knight (demigoddess)
    nDeity = AddDeity("Red Knight");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Red_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Red_Symbol");
        SetDeityPortfolio(nDeity, "strategy, planning, and tactics");
        SetDeitySpawnLoc(nDeity, "Red_Start");
        SetDeityTitleAlternates(nDeity, "Lady of Strategy, Grandmaster of the Lanceboard and The Crimson General");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);


        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_WAR);


    // Rillifane Rallathil (intermediate god)
    nDeity = AddDeity("Rillifane Rallathil");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Rillifane_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Rillifane_Symbol");
        SetDeityPortfolio(nDeity, "woodlands, nature, wild elves, and druids");
        SetDeitySpawnLoc(nDeity, "Rillifane_Start");
        SetDeityTitle(nDeity, "elven god");
        SetDeityTitleAlternates(nDeity, "the Leaflord, the Wild One, the Great Oak, the Many-Branched, the Many-Limbed, and Old Man of Yuirwood");
        SetDeityWeapon(nDeity, WEAPON_LONGBOW);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        // Required subrace. - no subraces in HE yet
        //SetClericSubrace(nDeity, "wood elf");

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Savras (demigod)
    nDeity = AddDeity("Savras");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Savras_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Savras_Symbol");
        SetDeityPortfolio(nDeity, "divination, fate, truth");
        SetDeitySpawnLoc(nDeity, "Savras_Start");
        SetDeityTitleAlternates(nDeity, "The All-Seeing, He of the Third Eye and Lord of Divination");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);


        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_MAGIC);

		
    // Sebek (demigod)
    nDeity = AddDeity("Sebek");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Sebek_Avatar");
        SetDeityHolySymbol(nDeity, "Sebek_Symbol");
        SetDeityPortfolio(nDeity, "crocodiles, rivers, river hazards, werecrocodiles, and wetlands");
        SetDeitySpawnLoc(nDeity, "Sebek_Start");
        SetDeityTitleAlternates(nDeity, "Lord of Crocodiles, and THe Smiling Death");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_WATER);
        AddClericDomain(nDeity, DOMAIN_EVIL);

    // Segojan Earthcaller (intermediate god)
    nDeity = AddDeity("Segojan Earthcaller");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Segojan_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Segojan_Symbol");
        SetDeityPortfolio(nDeity, "earth and nature");
        SetDeitySpawnLoc(nDeity, "Segojan_Start");
        SetDeityTitle(nDeity, "gnomish god");
        SetDeityTitleAlternates(nDeity, "Earthfriend, the Rock Gnome, Lord of the Burrow, Digger of Dens, the Badger, and the Wolverine");
        SetDeityWeapon(nDeity, WEAPON_HEAVYMACE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_GOOD);


    // Sehanine Moonbow (intermediate goddess)
    nDeity = AddDeity("Sehanine Moonbow");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Sehanine_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Sehanine_Symbol");
        SetDeityPortfolio(nDeity, "mysticism, dreams, far journeys, death, and transcendence");
        SetDeitySpawnLoc(nDeity, "Sehanine_Start");
        SetDeityTitle(nDeity, "elven goddess");
        SetDeityTitleAlternates(nDeity, "Daughter of the Night Skies, Goddess of Moonlight, the Lunar Lady, Moonlit Mystery, the Mystic Seer, the Luminous Cloud, and Lady of Dreams");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Selûne (intermediate goddess)
    nDeity = AddDeity("Selûne");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Selune_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Selune_Symbol");
        SetDeityPortfolio(nDeity, "the moon, stars, navigation, navigators, wanderers, questers, and nonevil lycanthropes");
        SetDeitySpawnLoc(nDeity, "Selune_Start");
        SetDeityTitleAlternates(nDeity, "Our Lady of Silver and the Moonmaiden");
        SetDeityWeapon(nDeity, WEAPON_HEAVYMACE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);

		
    // Set (intermediate deity)
    nDeity = AddDeity("Set");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Set_Avatar");
        SetDeityHolySymbol(nDeity, "Set_Symbol");
        SetDeityPortfolio(nDeity, "the desert, destruction, drought, night, rot, snakes, hate, betrayal, evil magic, ambition, poison, and murder");
        SetDeitySpawnLoc(nDeity, "Set_Start");
        SetDeityTitleAlternates(nDeity, "Lord of Evil, Defiler of the Dead, Lord of Carrion, Father of Jackals, Brother of Serpents, Outcast of the Gods, King of Malice, God of Darkness, and God of Desert Storms");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_MAGIC);
        AddClericDomain(nDeity, DOMAIN_EVIL);

    // Shar (greater goddess)
    nDeity = AddDeity("Shar");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Shar_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Shar_Symbol");
        SetDeityPortfolio(nDeity, "dark, night, loss, forgetfulness, unrevealed secrets, caverns, dungeons, and the Underdark");
        SetDeitySpawnLoc(nDeity, "Shar_Start");
        SetDeityTitleAlternates(nDeity, "Mistress of the Night, Nightsinger, and Lady of Loss");
        SetDeityWeapon(nDeity, WEAPON_DAGGER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        //AddClericDomain(nDeity, DOMAIN_DARKNESS);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);


    // Sharess (demigoddess)
    nDeity = AddDeity("Sharess");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Sharess_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Sharess_Symbol");
        SetDeityPortfolio(nDeity, "hedonism, sensual fulfillment, festhalls, cats ");
        SetDeitySpawnLoc(nDeity, "Sharess_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "The Dancing Lady, Patroness of Festhalls and The Tawny Temptress");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);


    // Shargaas (intermediate god)
    nDeity = AddDeity("Shargaas");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Shargaas_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Shargaas_Symbol");
        SetDeityPortfolio(nDeity, "darkness and thieves");
        SetDeitySpawnLoc(nDeity, "Shargaas_Start");
        SetDeityTitle(nDeity, "orcish god");
        SetDeityTitleAlternates(nDeity, "the Night Lord, the Blade in the Darkness, and the Stalker Below");
        SetDeityWeapon(nDeity, WEAPON_SHORTSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);

    // Sharindlar (intermediate goddess)
    nDeity = AddDeity("Sharindlar");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Sharindlar_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Sharindlar_Symbol");
        SetDeityPortfolio(nDeity, "courtship, dancing, fertility, healing, mercy, the moon, and romantic love");
        SetDeitySpawnLoc(nDeity, "Sharindlar_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "Lady of Life and Mercy, and The Shining Dancer");
        SetDeityWeapon(nDeity, WEAPON_WHIP);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_HEALING);


    // Shaundakal (lesser god)
    nDeity = AddDeity("Shaundakal");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Shaundakal_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Shaundakal_Symbol");
        SetDeityPortfolio(nDeity, "caravans, exploration, miners, portals and travel");
        SetDeitySpawnLoc(nDeity, "Shaundakal_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "The Helping Hand and The Rider of Winds");
        SetDeityWeapon(nDeity, WEAPON_GREATSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Sheela Peryroyl (intermediate goddess)
    nDeity = AddDeity("Sheela Peryroyl");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Sheela_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Sheela_Symbol");
        SetDeityPortfolio(nDeity, "nature, agriculture, and weather");
        SetDeitySpawnLoc(nDeity, "Sheela_Start");
        SetDeityTitle(nDeity, "halfling goddess");
        SetDeityTitleAlternates(nDeity, "Green Sister, the Wise, and the Watchful Mother");
        SetDeityWeapon(nDeity, WEAPON_SICKLE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFLING);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_PLANT);

    // Shevarash (demigod)
    nDeity = AddDeity("Shevarash");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Shevarash_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Shevarash_Symbol");
        SetDeityPortfolio(nDeity, "crusades, hatred of the drow, loss, and vengeance");
        SetDeitySpawnLoc(nDeity, "Shevarash_Start");
        SetDeityTitle(nDeity, "elven goddess");
        SetDeityTitleAlternates(nDeity, "The Black Archer, The Night Hunter, and Arrow Bringer");
        SetDeityWeapon(nDeity, WEAPON_BOW);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELFELF);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_WAR);

    // Shiallia (demigoddess)
    nDeity = AddDeity("Shiallia");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Shiallia_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Shiallia_Symbol");
        SetDeityPortfolio(nDeity, "the high forest, neverwinter woods, woodland glades, woodland fertility, growth and korreds");
        SetDeitySpawnLoc(nDeity, "Shiallia_Start");
        SetDeityTitle(nDeity, "human goddess");
        SetDeityTitleAlternates(nDeity, "The Golden Dancer in the Glades, Daughter of the High Forest, and The Lady of the Woods");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_GOOD);


    // Siamorphe (demigoddess)
    nDeity = AddDeity("Siamorphe");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Siamorphe_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Siamorphe_Symbol");
        SetDeityPortfolio(nDeity, "nobles, rightful noble rule and human royalty");
        SetDeitySpawnLoc(nDeity, "Siamorphe_Start");
        SetDeityTitle(nDeity, "human goddess");
        SetDeityTitleAlternates(nDeity, "The Divine Right");
        SetDeityWeapon(nDeity, WEAPON_MACE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_EVIL);


    // Silvanus (greater god)
    nDeity = AddDeity("Silvanus");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Silvanus_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Silvanus_Symbol");
        SetDeityPortfolio(nDeity, "wild nature and druids");
        SetDeitySpawnLoc(nDeity, "Silvanus_Start");
        SetDeityTitleAlternates(nDeity, "Oak Father, Forest Father, and Treefather");
        SetDeityWeapon(nDeity, WEAPON_MAUL);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_WATER);


    // Solonor Thelandira (intermediate god)
    nDeity = AddDeity("Solonor Thelandira");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Solonor_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Solonor_Symbol");
        SetDeityPortfolio(nDeity, "archery and hunting");
        SetDeitySpawnLoc(nDeity, "Solonor_Start");
        SetDeityTitle(nDeity, "elven god");
        SetDeityTitleAlternates(nDeity, "Keen-Eye, the Great Archer, and the Forest Hunter");
        SetDeityWeapon(nDeity, WEAPON_LONGBOW);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_ELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_WAR);


    // Sune (greater goddess)
    nDeity = AddDeity("Sune");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Sune_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Sune_Symbol");
        SetDeityPortfolio(nDeity, "beauty, love, and passion");
        SetDeitySpawnLoc(nDeity, "Sune_Start");
        SetDeityTitleAlternates(nDeity, "Lady Firehair");
        SetDeityWeapon(nDeity, WEAPON_WHIP);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Talona (lesser goddess)
    nDeity = AddDeity("Talona");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Talona_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Talona_Symbol");
        SetDeityPortfolio(nDeity, "poison and disease");
        SetDeitySpawnLoc(nDeity, "Talona_Start");
        SetDeityTitleAlternates(nDeity, "Lady of Poison, Mistress of Disease and The Plague-crone");
        SetDeityWeapon(nDeity, WEAPON_UNARMEDSTRIKE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);


    // Talos (greater god)
    nDeity = AddDeity("Talos");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Talos_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Talos_Symbol");
        SetDeityPortfolio(nDeity, "storms, destruction, rebellion, conflagrations, and earthquakes");
        SetDeitySpawnLoc(nDeity, "Talos_Start");
        SetDeityTitleAlternates(nDeity, "the Destroyer and the Storm Lord");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_FIRE);
        AddClericDomain(nDeity, DOMAIN_AIR);


    // Tempus (greater god)
    nDeity = AddDeity("Tempus");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Tempus_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Tempus_Symbol");
        SetDeityPortfolio(nDeity, "war, battle, and warriors");
        SetDeitySpawnLoc(nDeity, "Tempus_Start");
        SetDeityTitleAlternates(nDeity, "Lord of Battles and Foehammer");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);
        AddClericDomain(nDeity, DOMAIN_WAR);



    // Tiamat (lesser goddess)
    nDeity = AddDeity("Tiamat");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Tiamat_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Tiamat_Symbol");
        SetDeityPortfolio(nDeity, "chessenta, evil dragons, evil reptiles and greed");
        SetDeitySpawnLoc(nDeity, "Tiamat_Start");
        SetDeityTitleAlternates(nDeity, "Archdevil, The Dragon Queen and The Undying Queen");
        SetDeityWeapon(nDeity, WEAPON_HEAVYPICK);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);

    // Thard Harr (lesser god)
    nDeity = AddDeity("Thard Harr");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Thard_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Thard_Symbol");
        SetDeityPortfolio(nDeity, "wild dwarves, jungle survival, hunting");
        SetDeitySpawnLoc(nDeity, "Thard_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "Lord of the Jungle Deeps");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PLANT);
		
    // Thoth (intermediate deity)
    nDeity = AddDeity("Thoth");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Thoth_Avatar");
        SetDeityHolySymbol(nDeity, "Thoth_Symbol");
        SetDeityPortfolio(nDeity, "neutral magic, scribes, knowledge, invention, secrets");
        SetDeitySpawnLoc(nDeity, "Thoth_Start");
        SetDeityTitleAlternates(nDeity, "Lord of Magic, Scribe of the Gods, Knower of All Secrets, Keeper of Knowledge, and King of Knowledge");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
		
        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_);
		
        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_MAGIC);
				
    // Torm (lesser deity)
    nDeity = AddDeity("Torm");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Torm_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Torm_Symbol");
        SetDeityPortfolio(nDeity, "duty, loyalty, obedience and paladins");
        SetDeitySpawnLoc(nDeity, "Torm_Start");
        SetDeityTitleAlternates(nDeity, "The True, The Loyal Fury and The Hand of Righteousness");
        SetDeityWeapon(nDeity, WEAPON_GREATSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_HEALING);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);


    // Tymora (intermediate goddess)
    nDeity = AddDeity("Tymora");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Tymora_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Tymora_Symbol");
        SetDeityPortfolio(nDeity, "good fortune, skill, victory, and adventurers");
        SetDeitySpawnLoc(nDeity, "Tymora_Start");
        SetDeityTitleAlternates(nDeity, "Lady Luck, the Lady who Smiles, and Our Smiling Lady");
        SetDeityWeapon(nDeity, WEAPON_SHURIKEN);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Tyr (greater god)
    nDeity = AddDeity("Tyr");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Tyr_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Tyr_Symbol");
        SetDeityPortfolio(nDeity, "justice");
        SetDeitySpawnLoc(nDeity, "Tyr_Start");
        SetDeityTitleAlternates(nDeity, "the Even-Handed, the Maimed God, the Just God, and Grimjaws");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allow all races.
        //AddClericRace(nDeity, RACIAL_TYPE_);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_WAR);



    // Ubtao (demigod)
    nDeity = AddDeity("Ubtao");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Ubtao_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Ubtao_Symbol");
        SetDeityPortfolio(nDeity, "chult, chultans, creation, dinosaurs and jungles");
        SetDeitySpawnLoc(nDeity, "Ubtao_Start");
        SetDeityTitleAlternates(nDeity, "Creator of Chult, Founder of Mezro and The Deceiver");
        SetDeityWeapon(nDeity, WEAPON_HEAVYPICK);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_PLANT);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Ulutiu (demigod)
    nDeity = AddDeity("Ulutiu");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Ulutiu_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Ulutiu_Symbol");
        SetDeityPortfolio(nDeity, "arctic dwellers and glaciers");
        SetDeitySpawnLoc(nDeity, "Ulutiu_Start");
        SetDeityTitleAlternates(nDeity, "The Eternal Sleeper, Father of Giants' Kin and The Lord in the Ice");
        SetDeityWeapon(nDeity, WEAPON_SPEAR);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);


        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);


    // Umberlee (intermediate goddess)
    nDeity = AddDeity("Umberlee");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Umberlee_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Umberlee_Symbol");
        SetDeityPortfolio(nDeity, "oceans, currents, waves, and sea winds");
        SetDeitySpawnLoc(nDeity, "Umberlee_Start");
        SetDeityTitleAlternates(nDeity, "the Bitch Queen and Queen of the Deeps");
        SetDeityWeapon(nDeity, WEAPON_TRIDENT);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFELF);
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_WATER);


    // Urdlen (intermediate deity)
    nDeity = AddDeity("Urdlen");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Urdlen_Avatar");
        SetDeityHolySymbol(nDeity, "Urdlen_Symbol");
        SetDeityPortfolio(nDeity, "greed and blood");
        SetDeitySpawnLoc(nDeity, "Urdlen_Start");
        SetDeityTitleAlternates(nDeity, "the Crawler Below and the Evil One");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_GNOME);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_EVIL);

    // Urogalan (demigod)
    nDeity = AddDeity("Urogalan");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Urogalan_Avatar");
        SetDeityHolySymbol(nDeity, "Urogalan_Symbol");
        SetDeityPortfolio(nDeity, "earth, death, protection of the dead");
        SetDeitySpawnLoc(nDeity, "Urogalan_Start");
        SetDeityTitle(nDeity, "halfling deity");
        SetDeityTitleAlternates(nDeity, "He Who Must Be, The Black Hound, Lord in the Earth, The Protector, and The Shaper");
        SetDeityWeapon(nDeity, WEAPON_HEAVYFLAIL);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFLING);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_DEATH);
        AddClericDomain(nDeity, DOMAIN_EARTH);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
		
    // Uthgar (intermediate deity)
    nDeity = AddDeity("Uthgar");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Uthgar_Avatar");
        SetDeityHolySymbol(nDeity, "Uthgar_Symbol");
        SetDeityPortfolio(nDeity, "physical strength and uthgardt tribes");
        SetDeitySpawnLoc(nDeity, "Uthgar_Start");
        SetDeityTitleAlternates(nDeity, "Battle Father and Father of the Uthgardt");
        SetDeityWeapon(nDeity, WEAPON_BATTLEAXE);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_ANIMAL);
        AddClericDomain(nDeity, DOMAIN_STRENGTH);
        AddClericDomain(nDeity, DOMAIN_WAR);



    // Valkur (demigod)
    nDeity = AddDeity("Valkur");
        SetDeityAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Valkur_Avatar");
        SetDeityHolySymbol(nDeity, "Valkur_Symbol");
        SetDeityPortfolio(nDeity, "favorable winds, naval combat and ships");
        SetDeitySpawnLoc(nDeity, "Valkur_Start");
        SetDeityTitleAlternates(nDeity, "Captain of the Mighty Waves and The Mighty");
        SetDeityWeapon(nDeity, WEAPON_RAPIER);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_AIR);
        AddClericDomain(nDeity, DOMAIN_CHAOS);
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Vergadain (intermediate god)
    nDeity = AddDeity("Vergadain");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Vergadain_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Vergadain_Symbol");
        SetDeityPortfolio(nDeity, "wealth and luck");
        SetDeitySpawnLoc(nDeity, "Vergadain_Start");
        SetDeityTitle(nDeity, "dwarven god");
        SetDeityTitleAlternates(nDeity, "the Merchant King, the Trickster, the Laughing Dwarf, and the Short Father");
        SetDeityWeapon(nDeity, WEAPON_LONGSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_DWARF);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_LUCK);
        AddClericDomain(nDeity, DOMAIN_TRICKERY);


    // Velsharoon (demigod)
    nDeity = AddDeity("Velsharoon");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Velsharoon_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Velsharoon_Symbol");
        SetDeityPortfolio(nDeity, "liches, necromancy, necromancers and undeath");
        SetDeitySpawnLoc(nDeity, "Velsharoon_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "Archmage of Necromancy, Lord of the Forsaken Crypt and The Vaunted");
        SetDeityWeapon(nDeity, WEAPON_QUARTERSTAFF);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_DEATH);
        AddClericDomain(nDeity, DOMAIN_EVIL);
        AddClericDomain(nDeity, DOMAIN_MAGIC);
        AddClericDomain(nDeity, DOMAIN_DEATH);


    // Waukeen (lesser goddess)
    nDeity = AddDeity("Waukeen");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        SetDeityAvatar(nDeity, "Waukeen_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Waukeen_Symbol");
        SetDeityPortfolio(nDeity, "trade");
        SetDeitySpawnLoc(nDeity, "Waukeen_Start");
        SetDeityTitle(nDeity, "human god");
        SetDeityTitleAlternates(nDeity, "Libery's Maiden, The Golden Lady and Our Lady of Gold");
        SetDeityWeapon(nDeity, WEAPON_NUNCHAKU);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_CHAOTIC, ALIGNMENT_NEUTRAL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HUMAN);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_KNOWLEDGE);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);
        AddClericDomain(nDeity, DOMAIN_TRAVEL);


    // Yondalla (greater goddess)
    nDeity = AddDeity("Yondalla");
        SetDeityAlignment(nDeity, ALIGNMENT_LAWFUL, ALIGNMENT_GOOD);
        SetDeityAvatar(nDeity, "Yondalla_Avatar");
        SetDeityGender(nDeity, GENDER_FEMALE);
        SetDeityHolySymbol(nDeity, "Yondalla_Symbol");
        SetDeityPortfolio(nDeity, "halflings, protection, and fertility");
        SetDeitySpawnLoc(nDeity, "Yondalla_Start");
        SetDeityTitleAlternates(nDeity, "the Protector and Provider, the Nurturing Matriarch, and the Blessed One");
        SetDeityWeapon(nDeity, WEAPON_SHORTSWORD);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_GOOD);
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_NEUTRAL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFLING);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_GOOD);
        AddClericDomain(nDeity, DOMAIN_LAW);
        AddClericDomain(nDeity, DOMAIN_PROTECTION);


    // Yurtrus (intermediate god)
    nDeity = AddDeity("Yurtrus");
        SetDeityAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);
        SetDeityAvatar(nDeity, "Yurtrus_Avatar");
        SetDeityGender(nDeity, GENDER_MALE);
        SetDeityHolySymbol(nDeity, "Yurtrus_Symbol");
        SetDeityPortfolio(nDeity, "death and disease");
        SetDeitySpawnLoc(nDeity, "Yurtrus_Start");
        SetDeityTitle(nDeity, "orcish god");
        SetDeityTitleAlternates(nDeity, "White-Hands, the Lord of Maggots, and the Rotting One");
        SetDeityWeapon(nDeity, WEAPON_UNARMED);

        // Allowed alignments.
        AddClericAlignment(nDeity, ALIGNMENT_LAWFUL,  ALIGNMENT_EVIL);
        AddClericAlignment(nDeity, ALIGNMENT_NEUTRAL, ALIGNMENT_EVIL);

        // Allowed races.
        AddClericRace(nDeity, RACIAL_TYPE_HALFORC);

        // Domain choices.
        AddClericDomain(nDeity, DOMAIN_DEATH);
        AddClericDomain(nDeity, DOMAIN_DESTRUCTION);
        AddClericDomain(nDeity, DOMAIN_EVIL);
}

