//
// Spawn Groups
//
//
// nChildrenSpawned
// : Number of Total Children ever Spawned
//
// nSpawnCount
// : Number of Children currently Alive
//
// nSpawnNumber
// : Number of Children to Maintain at Spawn
//
// nRandomWalk
// : Walking Randomly? TRUE/FALSE
//
// nPlaceable
// : Spawning Placeables? TRUE/FALSE
//
//
//int ParseFlagValue(string sName, string sFlag, int nDigits, int nDefault);
//int ParseSubFlagValue(string sName, string sFlag, int nDigits, string sSubFlag, int nSubDigits, int nDefault);

#include "tb_inc_util"

object GetChildByTag(object oSpawn, string sChildTag);
object GetChildByNumber(object oSpawn, int nChildNum);
object GetSpawnByID(int nSpawnID);
void DeactivateSpawn(object oSpawn);
void DeactivateSpawnsByTag(string sSpawnTag);
void DeactivateAllSpawns();
void DespawnChildren(object oSpawn);
void DespawnChildrenByTag(object oSpawn, string sSpawnTag);

// user configurable: Add groups and their creatures inside this function [FILE: spawn_cfg_group]
// this function needs to be called in the module's onload event.
void NESSInitializeGroups();
// this function is called by NESSInitializeGroups() [FILE: spawn_cfg_group]
// for each creature you add to a group use the following line:
// NESSAddCreatureToGroup("CreatureResRef", "GroupName", #);
// more explanation:
// "CreatureResRef" - is the resource reference (resref) of the creature blueprint to spawn.
//                    Put the resref between quotes.
// "GroupName"      - is the name you will use to identify this list of creatures.
//                    Put the name between quotes.
// #                - is an integer value of the creature's challenge rating.
//                    CRs of 1 and below should be listed as 1. Do not use fractions or decimal points. Positive, whole numbers only.
void NESSAddCreatureToGroup(string CreatureResRef, string GroupName, int CreatureChallengeRating);
// this function is called by SpawnGroup() [FILE: spawn_cfg_group]
// the return value is a resref for a creature
string NESSGetCreatureFromGroupList(object oSpawn, string sGroupName, int nCR=0);



// user configurable: Add groups and their creatures inside this function [FILE: spawn_cfg_group]
// this function needs to be called in the module's onload event.
void NESSInitializeGroups()
{
// for each creature you add to a group use the following line:
//  NESSAddCreatureToGroup("CreatureResRef", "GroupName", #);
// more explanation:
// "CreatureResRef" - is the resource reference (resref) of the creature blueprint to spawn.
//                    Put the resref between quotes.
// "GroupName"      - is the name you will use to identify this list of creatures.
//                    Put the name between quotes.
// #                - is an integer value of the creature's challenge rating.
//                    CRs of 1 and below should be listed as 1. Do not use fractions or decimal points. Positive, whole numbers only.


    // Hill's Edge Commoners
    NESSAddCreatureToGroup("tt_randomcom_m", "commoner", 1);
    NESSAddCreatureToGroup("tt_randomcom_f", "commoner", 1);

    // Hill's Edge Privilegied
    NESSAddCreatureToGroup("tt_randnob_f001", "noble", 1);
    NESSAddCreatureToGroup("tt_randnob_f", "noble", 1);


    // Hill's Edge Tavern
    NESSAddCreatureToGroup("tt_randomcom_001", "tavern", 1);
    NESSAddCreatureToGroup("tt_randomcom_002", "tavern", 1);

    // Hill's Edge Lliira Joybringers
    NESSAddCreatureToGroup("tt_elflliira001", "joybringer", 3);
    NESSAddCreatureToGroup("tt_elflliira", "joybringer", 3);
    NESSAddCreatureToGroup("tt_lliira", "joybringer", 3);
    NESSAddCreatureToGroup("tt_lliira", "joybringer", 3);
    NESSAddCreatureToGroup("tt_lliira", "joybringer", 3);
    NESSAddCreatureToGroup("tt_lliira001", "joybringer", 3);
    NESSAddCreatureToGroup("tt_lliira001", "joybringer", 3);
    NESSAddCreatureToGroup("tt_lliira001", "joybringer", 3);
    NESSAddCreatureToGroup("tt_lliira003", "joybringer", 6);
    NESSAddCreatureToGroup("tt_lliira002", "joybringer", 6);

    //Corm Orp Tavern
    NESSAddCreatureToGroup("tt_randomcom_001", "cormorp", 1);
    NESSAddCreatureToGroup("tt_randomcom_002", "cormorp", 1);
    NESSAddCreatureToGroup("tt_randomcom_003", "cormorp", 1);
    NESSAddCreatureToGroup("tt_randomcom_003", "cormorp", 1);
    NESSAddCreatureToGroup("tt_randomcom_003", "cormorp", 1);
    NESSAddCreatureToGroup("tt_randomcom_004", "cormorp", 1);
    NESSAddCreatureToGroup("tt_randomcom_004", "cormorp", 1);


    //Corm Orp Villagers
    NESSAddCreatureToGroup("tt_randomcom_m", "cormorpout", 1);
    NESSAddCreatureToGroup("tt_randomcom_f", "cormorpout", 1);
    NESSAddCreatureToGroup("tt_randomcom_005", "cormorpout", 1);
    NESSAddCreatureToGroup("tt_randomcom_006", "cormorpout", 1);

    //Hill's Edge - Low class
    NESSAddCreatureToGroup("tt_randnob_f002", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_randnob_f003", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_randnob_f002", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_randnob_f003", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_npc_beggar", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_npc_common043", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_npc_common437", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_npc_common438", "lowclass", 1); // human
    NESSAddCreatureToGroup("tt_npc_common439", "lowclass", 1); // human
















    // tavern typical
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale0", "tavern_male", 1); // dwarf
    NESSAddCreatureToGroup("tavernmale0", "tavern_male", 1); // dwarf
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale0", "tavern_male", 1); // dwarf
    NESSAddCreatureToGroup("tavernmale1", "tavern_male", 1); // elf
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale1", "tavern_male", 1); // elf
    NESSAddCreatureToGroup("tavernmale2", "tavern_male", 1); // gnome
    NESSAddCreatureToGroup("tavernmale3", "tavern_male", 1); // hin
    NESSAddCreatureToGroup("tavernmale3", "tavern_male", 1); // hin
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale3", "tavern_male", 1); // hin
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale5", "tavern_male", 1); // orclun
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_male", 1); // human

    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale0", "tavern_female", 1); // dwarf
    NESSAddCreatureToGroup("tavernfemale0", "tavern_female", 1); // dwarf
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale0", "tavern_female", 1); // dwarf
    NESSAddCreatureToGroup("tavernfemale1", "tavern_female", 1); // elf
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale1", "tavern_female", 1); // elf
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale2", "tavern_female", 1); // gnome
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale3", "tavern_female", 1); // hin
    NESSAddCreatureToGroup("tavernfemale3", "tavern_female", 1); // hin
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale3", "tavern_female", 1); // hin
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale5", "tavern_female", 1); // orclun
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_female", 1); // human

    // tavern dahkessa
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human
    NESSAddCreatureToGroup("tavernmale0", "tavern_dahk_male", 1); // dwarf
    NESSAddCreatureToGroup("tavernmale0", "tavern_dahk_male", 1); // dwarf
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human
    NESSAddCreatureToGroup("tavernmale1", "tavern_dahk_male", 1); // elf
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human
    NESSAddCreatureToGroup("tavernmale3", "tavern_dahk_male", 1); // hin
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human
    NESSAddCreatureToGroup("tavernmale5", "tavern_dahk_male", 1); // orclun
    NESSAddCreatureToGroup("tavernmale6", "tavern_dahk_male", 1); // human

    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale0", "tavern_dahk_female", 1); // dwarf
    NESSAddCreatureToGroup("tavernfemale0", "tavern_dahk_female", 1); // dwarf
    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale1", "tavern_dahk_female", 1); // elf
    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale3", "tavern_dahk_female", 1); // hin
    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human
    NESSAddCreatureToGroup("tavernfemale5", "tavern_dahk_female", 1); // orclun
    NESSAddCreatureToGroup("tavernfemale6", "tavern_dahk_female", 1); // human

    // laborers
    NESSAddCreatureToGroup("labormaleh", "labor_male", 1); // human
    NESSAddCreatureToGroup("labormaled", "labor_male", 1); // dwarf
    NESSAddCreatureToGroup("labormaleo", "labor_male", 1); // orclun
    NESSAddCreatureToGroup("labormaled", "labor_male", 1); // dwarf
    NESSAddCreatureToGroup("labormaleh", "labor_male", 1); // human
    NESSAddCreatureToGroup("labormaleh", "labor_male", 1); // human

    NESSAddCreatureToGroup("laborfemaleh", "labor_female", 1); // human
    NESSAddCreatureToGroup("laborfemaled", "labor_female", 1); // dwarf
    NESSAddCreatureToGroup("laborfemaled", "labor_female", 1); // dwarf
    NESSAddCreatureToGroup("laborfemaleo", "labor_female", 1); // orclun
    NESSAddCreatureToGroup("laborfemaleh", "labor_female", 1); // human
    NESSAddCreatureToGroup("laborfemaleh", "labor_female", 1); // human

    // farmers
    NESSAddCreatureToGroup("farmermaleh", "farm_male", 1); // human
    NESSAddCreatureToGroup("farmermalee", "farm_male", 1); // elf
    NESSAddCreatureToGroup("farmermalea", "farm_male", 1); // hin
    NESSAddCreatureToGroup("farmermalea", "farm_male", 1); // hin
    NESSAddCreatureToGroup("farmermaleh", "farm_male", 1); // human
    NESSAddCreatureToGroup("farmermaleh", "farm_male", 1); // human

    NESSAddCreatureToGroup("farmerfemaleh", "farm_female", 1); // human
    NESSAddCreatureToGroup("farmerfemalee", "farm_female", 1); // elf
    NESSAddCreatureToGroup("farmerfemalea", "farm_female", 1); // hin
    NESSAddCreatureToGroup("farmerfemalea", "farm_female", 1); // hin
    NESSAddCreatureToGroup("farmerfemaleh", "farm_female", 1); // human
    NESSAddCreatureToGroup("farmerfemaleh", "farm_female", 1); // human

    //







    // goblincommoners
    NESSAddCreatureToGroup("goblin_common_f1", "goblincommoners", 1);
    NESSAddCreatureToGroup("goblin_common_m1", "goblincommoners", 1);

    // goblinguards
    NESSAddCreatureToGroup("goblinrogue1", "goblinguards", 1);
    NESSAddCreatureToGroup("goblinrogue3", "goblinguards", 3);
    NESSAddCreatureToGroup("goblinsorc5", "goblinguards", 4);
    NESSAddCreatureToGroup("goblinfighter5", "goblinguards", 5);

    // slime
    NESSAddCreatureToGroup("oozeclear", "slime", 1);
    NESSAddCreatureToGroup("caveslime3", "slime", 3);
    NESSAddCreatureToGroup("grayooze", "slime", 4);
    NESSAddCreatureToGroup("slimespitting3", "slime", 5);

    // frogmen
    NESSAddCreatureToGroup("froggiant", "frogmen", 2);
    NESSAddCreatureToGroup("frogbrute3", "frogmen", 4);
    NESSAddCreatureToGroup("frogrogue4", "frogmen", 5);
    NESSAddCreatureToGroup("froggiant_md", "frogmen", 5);
    NESSAddCreatureToGroup("frogbrute5", "frogmen", 6);
    NESSAddCreatureToGroup("frogdruid7", "frogmen", 8);
    NESSAddCreatureToGroup("froggiant_lg", "frogmen", 8);
    NESSAddCreatureToGroup("frogbrute9", "frogmen", 10);

    // frogs
    NESSAddCreatureToGroup("frog", "frogs", 1);
    NESSAddCreatureToGroup("froggiant", "frogs", 2);
    NESSAddCreatureToGroup("froggiant_md", "frogs", 5);
    NESSAddCreatureToGroup("froggiant_lg", "frogs", 8);

    // boar
    NESSAddCreatureToGroup("boar", "boar", 2);
    NESSAddCreatureToGroup("boardire", "boar", 7);

    //Cloakers
    NESSAddCreatureToGroup("q1_cloaker", "cloaker", 4);
    NESSAddCreatureToGroup("q1_cloaker", "cloaker", 4);
    NESSAddCreatureToGroup("q1_cloaker", "cloaker", 4);
    NESSAddCreatureToGroup("q1_cloaker", "cloaker", 4);
    NESSAddCreatureToGroup("q1_cloaker001", "cloaker", 6);
    NESSAddCreatureToGroup("q1_cloaker002", "cloaker", 6);

    //Curst
    NESSAddCreatureToGroup("tt_curst001", "curst", 6);
    NESSAddCreatureToGroup("tt_curst002", "curst", 6);
    NESSAddCreatureToGroup("tt_curst003", "curst", 6);
    NESSAddCreatureToGroup("tt_curst004", "curst", 6);
    NESSAddCreatureToGroup("tt_curst005", "curst", 6);


//Animals - Plains, All + Hostile
    NESSAddCreatureToGroup("nw_badger", "animals_psh", 2);
    NESSAddCreatureToGroup("aa_bird_crow", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_bird_003", "animals_psh", 1);
    NESSAddCreatureToGroup("aa_bird_pigeon", "animals_psh", 1);
    NESSAddCreatureToGroup("aa_bird_dove", "animals_psh", 1);
    NESSAddCreatureToGroup("brc_cougar", "animals_psh", 3);
    NESSAddCreatureToGroup("kc_fox020", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_rabbit", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_rabbit001", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_racoon", "animals_psh", 2);
    NESSAddCreatureToGroup("tt_rat_001", "animals_psh", 1);
    NESSAddCreatureToGroup("aa_rodent_mouse", "animals_psh", 1);
    NESSAddCreatureToGroup("kc_weasel001", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_adder", "animals_psh", 3);
    NESSAddCreatureToGroup("q1_boar001", "animals_psh", 3);
    NESSAddCreatureToGroup("q1_boar004", "animals_psh", 3);
    NESSAddCreatureToGroup("q1_boar002", "animals_psh", 2);
    NESSAddCreatureToGroup("tt_deer001", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_deer002", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_deer003", "animals_psh", 1);
    NESSAddCreatureToGroup("nw_badger", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_rabbit001", "animals_psh", 1);
    NESSAddCreatureToGroup("tt_rabbit", "animals_psh", 1);


//Animals - Plains, Boar
    NESSAddCreatureToGroup("q1_boar001", "animals_boar", 3);
    NESSAddCreatureToGroup("q1_boar004", "animals_boar", 3);
    NESSAddCreatureToGroup("q1_boar002", "animals_boar", 2);

//Animals - Plains, Deer
    NESSAddCreatureToGroup("tt_deer001", "animals_deer", 1);
    NESSAddCreatureToGroup("tt_deer002", "animals_deer", 1);
    NESSAddCreatureToGroup("tt_deer003", "animals_deer", 1);

//Animals - Plains, ALL
    NESSAddCreatureToGroup("aa_bird_crow", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_bird_003", "animals_ps", 1);
    NESSAddCreatureToGroup("aa_bird_pigeon", "animals_ps", 1);
    NESSAddCreatureToGroup("aa_bird_dove", "animals_ps", 1);
    NESSAddCreatureToGroup("kc_fox020", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_rabbit", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_rabbit001", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_racoon", "animals_ps", 2);
    NESSAddCreatureToGroup("tt_rat_001", "animals_ps", 1);
    NESSAddCreatureToGroup("aa_rodent_mouse", "animals_ps", 1);
    NESSAddCreatureToGroup("kc_weasel001", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_deer001", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_deer002", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_deer003", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_falcon", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_rabbit001", "animals_ps", 1);
    NESSAddCreatureToGroup("tt_rabbit", "animals_ps", 1);

//Animals - Forest, ALL + Hostile
    NESSAddCreatureToGroup("brc_blackbear", "animals_fsh", 1);
    NESSAddCreatureToGroup("brc_grizzlybear1", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_bird_bluejay", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_bird_002", "animals_fsh", 1);
    NESSAddCreatureToGroup("aa_bird_dove", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_bird_003", "animals_fsh", 1);
    NESSAddCreatureToGroup("aa_bird_snowowl", "animals_fsh", 1);
    NESSAddCreatureToGroup("brc_wolfalpha", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_wolf", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_lynx", "animals_fsh", 1);
    NESSAddCreatureToGroup("q1_boar001", "animals_fsh", 1);
    NESSAddCreatureToGroup("q1_boar004", "animals_fsh", 1);
    NESSAddCreatureToGroup("q1_boar002", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_deer001", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_deer002", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_deer003", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_adder", "animals_fsh", 1);
    NESSAddCreatureToGroup("frog001", "animals_fsh", 1);
    NESSAddCreatureToGroup("lizard001", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_bat", "animals_fsh", 1);
    NESSAddCreatureToGroup("brc_moose", "animals_fsh", 1);
    NESSAddCreatureToGroup("brc_moose001", "animals_fsh", 1);
    NESSAddCreatureToGroup("aa_rodent_mouse", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_racoon", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_rat_001", "animals_fsh", 1);
    NESSAddCreatureToGroup("kc_weasel001", "animals_fsh", 1);
    NESSAddCreatureToGroup("tt_falcon", "animals_fsh", 1);
    NESSAddCreatureToGroup("nw_badger", "animals_fsh", 1);
    NESSAddCreatureToGroup("kc_fox020", "animals_fsh", 1);


//Animals - Forest, ALL
    NESSAddCreatureToGroup("tt_bird_bluejay", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_bird_002", "animals_fs", 1);
    NESSAddCreatureToGroup("aa_bird_dove", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_bird_003", "animals_fs", 1);
    NESSAddCreatureToGroup("aa_bird_snowowl", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_deer001", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_deer002", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_deer003", "animals_fs", 1);
    NESSAddCreatureToGroup("frog001", "animals_fs", 1);
    NESSAddCreatureToGroup("lizard001", "animals_fs", 1);
    NESSAddCreatureToGroup("brc_moose", "animals_fs", 1);
    NESSAddCreatureToGroup("brc_moose001", "animals_fs", 1);
    NESSAddCreatureToGroup("aa_rodent_mouse", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_racoon", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_rat_001", "animals_fs", 1);
    NESSAddCreatureToGroup("kc_weasel001", "animals_fs", 1);
    NESSAddCreatureToGroup("tt_falcon", "animals_fs", 1);

//Lakekeep - Bandit Foxes, ALL
    NESSAddCreatureToGroup("tt_lkbandit_005", "banditfox", 2);
    NESSAddCreatureToGroup("tt_lkbandit_006", "banditfox", 3);
    NESSAddCreatureToGroup("tt_lkbandit_007", "banditfox", 4);
    NESSAddCreatureToGroup("tt_lkbandit_008", "banditfox", 6);
    NESSAddCreatureToGroup("tt_lk_bandit008", "banditfox", 3);
    NESSAddCreatureToGroup("tt_lk_bandit010", "banditfox", 7);
    NESSAddCreatureToGroup("tt_lkbandit_1", "banditfox", 2);
    NESSAddCreatureToGroup("tt_lkbandit_002", "banditfox", 3);
    NESSAddCreatureToGroup("tt_lkbandit_003", "banditfox", 5);
    NESSAddCreatureToGroup("tt_lkbandit_004", "banditfox", 6);
    NESSAddCreatureToGroup("tt_lk_bandit002", "banditfox", 3);
    NESSAddCreatureToGroup("tt_lk_bandit004", "banditfox", 6);
    NESSAddCreatureToGroup("tt_lk_bandit1", "banditfox", 2);
    NESSAddCreatureToGroup("tt_lk_bandit003", "banditfox", 4);
    NESSAddCreatureToGroup("tt_lk_bandit007", "banditfox", 6);
    NESSAddCreatureToGroup("tt_lk_bandit006", "banditfox", 3);

//Lakekeep - Bandit Foxes, Archers
    NESSAddCreatureToGroup("tt_lkbandit_005", "banditfoxarcher", 2);
    NESSAddCreatureToGroup("tt_lkbandit_006", "banditfoxarcher", 3);
    NESSAddCreatureToGroup("tt_lkbandit_007", "banditfoxarcher", 4);
    NESSAddCreatureToGroup("tt_lkbandit_008", "banditfoxarcher", 6);

//Lakekeep - Bandit Foxes, Fighters & Rogues
    NESSAddCreatureToGroup("tt_lkbandit_1", "banditfoxmix", 2);
    NESSAddCreatureToGroup("tt_lkbandit_002", "banditfoxmix", 3);
    NESSAddCreatureToGroup("tt_lkbandit_003", "banditfoxmix", 5);
    NESSAddCreatureToGroup("tt_lkbandit_004", "banditfoxmix", 6);
     NESSAddCreatureToGroup("tt_lk_bandit1", "banditfoxmix", 2);
    NESSAddCreatureToGroup("tt_lk_bandit002", "banditfoxmix", 3);
    NESSAddCreatureToGroup("tt_lk_bandit003", "banditfoxmix", 4);
    NESSAddCreatureToGroup("tt_lk_bandit004", "banditfoxmix", 6);

//Lakekeep - Bandit Foxes, Cleric & Sorcerer
    NESSAddCreatureToGroup("tt_lk_bandit008", "banditfoxcaster", 3);
    NESSAddCreatureToGroup("tt_lk_bandit010", "banditfoxcaster", 7);
    NESSAddCreatureToGroup("tt_lk_bandit007", "banditfoxcaster", 6);
    NESSAddCreatureToGroup("tt_lk_bandit006", "banditfoxcaster", 3);

//Lakekeep - Cellar, the Thing
    NESSAddCreatureToGroup("tt_nethzombie001", "thething", 3);
    NESSAddCreatureToGroup("tt_nethzombie001", "thething", 5);
    NESSAddCreatureToGroup("tt_nethzombie001", "thething", 7);
    NESSAddCreatureToGroup("tt_nethzombie001", "thething", 9);

    //Lakekeep - Cellar, the Thing
    NESSAddCreatureToGroup("tt_spore_1", "sporecloud", 1);
    NESSAddCreatureToGroup("tt_spore_005", "sporecloud", 1);
    NESSAddCreatureToGroup("tt_spore_002", "sporecloud", 1);
    //NESSAddCreatureToGroup("tt_spore_006", "sporecloud", 1);
   // NESSAddCreatureToGroup("tt_spore_003", "sporecloud", 1);
   // NESSAddCreatureToGroup("tt_spore_004", "sporecloud", 1);


     //Lakekeep - Cellar, the Thing
    //NESSAddCreatureToGroup("tt_spore_1", "sporecloud", 1);
    //NESSAddCreatureToGroup("tt_spore_005", "sporecloud", 1);
    //NESSAddCreatureToGroup("tt_spore_002", "sporecloud", 1);
    NESSAddCreatureToGroup("tt_spore_006", "sporecloud2", 1);
    NESSAddCreatureToGroup("tt_spore_003", "sporecloud2", 1);
    NESSAddCreatureToGroup("tt_spore_004", "sporecloud2", 1);


    NESSAddCreatureToGroup("tt_body", "corpse", 1);
    NESSAddCreatureToGroup("tt_body001", "corpse", 1);
    NESSAddCreatureToGroup("tt_body002", "corpse", 1);
    NESSAddCreatureToGroup("tt_body003", "corpse", 1);
    NESSAddCreatureToGroup("tt_body004", "corpse", 1);
    NESSAddCreatureToGroup("tt_body005", "corpse", 1);


    NESSAddCreatureToGroup("tt_lk_bandit011", "murderer", 3);
    NESSAddCreatureToGroup("tt_lk_bandit013", "murderer", 3);
    NESSAddCreatureToGroup("tt_lk_bandit009", "murderer", 3);
    NESSAddCreatureToGroup("tt_lk_bandit012", "murderer", 3);
    NESSAddCreatureToGroup("tt_lk_bandit1", "murderer", 3);
    NESSAddCreatureToGroup("tt_lkbandit_1", "murderer", 3);
    NESSAddCreatureToGroup("tt_lkbandit_005", "murderer", 3);



    NESSAddCreatureToGroup("tt_caveweaver_00", "caveweaver", 3);
    NESSAddCreatureToGroup("tt_caveweaver001", "caveweaver", 5);
    NESSAddCreatureToGroup("tt_caveweaver002", "caveweaver", 7);


// Old Edge Mine - Ants (no queen)
    NESSAddCreatureToGroup("q1_gntant001", "ants", 2);
    NESSAddCreatureToGroup("q1_gntant002", "ants", 3);
    NESSAddCreatureToGroup("q1_gntant004", "ants", 4);
//    NESSAddCreatureToGroup("q1_gntant003", "ants", 7);

//Necromancers

    NESSAddCreatureToGroup("tt_necrom", "necromancer", 1);
    NESSAddCreatureToGroup("tt_necrom001", "necromancer", 1);
    NESSAddCreatureToGroup("tt_necrom002", "necromancer", 3);
    NESSAddCreatureToGroup("tt_necrom003", "necromancer", 3);

//Pale Masters
    NESSAddCreatureToGroup("tt_necrom_pm2", "palemaster", 7);
    NESSAddCreatureToGroup("tt_necrom_pm1", "palemaster", 7);



//Skeletons
    NESSAddCreatureToGroup("tt_skeleton001", "cryptskeleton", 1);
    NESSAddCreatureToGroup("tt_skeleton2", "cryptskeleton", 1);
    NESSAddCreatureToGroup("tt_skeleton003", "cryptskeleton", 1);
    NESSAddCreatureToGroup("tt_skeleton007", "cryptskeleton", 1);

//Armored Skeletons
    NESSAddCreatureToGroup("tt_armskelw", "armedskeleton", 2);
    NESSAddCreatureToGroup("tt_armskelr", "armedskeleton", 2);

//Grave Guard Skeleton
    NESSAddCreatureToGroup("tt_armskelm", "graveguard", 2);
    NESSAddCreatureToGroup("tt_skeleton004", "graveguard", 2);
    NESSAddCreatureToGroup("tt_skeleton005", "graveguard", 2);
    NESSAddCreatureToGroup("tt_skeleton006", "graveguard", 2);

//Death Guard Skeleton
    NESSAddCreatureToGroup("tt_mountedske001", "deathguard", 4);
    NESSAddCreatureToGroup("tt_mountedske002", "deathguard", 4);



//Drawn Swords Archer
    NESSAddCreatureToGroup("tt_drawns_archer", "drawnarch", 4);
    NESSAddCreatureToGroup("tt_drawns_arc001", "drawnarch", 4);

//4 Goats
    NESSAddCreatureToGroup("q1_goat001", "mgoats", 1);
    NESSAddCreatureToGroup("q1_goat002", "mgoats", 1);
    NESSAddCreatureToGroup("q1_goat003", "mgoats", 1);
    NESSAddCreatureToGroup("q1_goat004", "mgoats", 1);


// Sorrow Villagers
    NESSAddCreatureToGroup("bo_villager_01", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_02", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_03", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_04", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_05", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_06", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_07", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_08", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_09", "sorrow", 1);
    NESSAddCreatureToGroup("bo_villager_10", "sorrow", 1);

// Ogres
    NESSAddCreatureToGroup("brc_ogre002", "ogres", 8);
    NESSAddCreatureToGroup("brc_ogre004", "ogres", 8);
    NESSAddCreatureToGroup("brc_ogre1", "ogres", 8);
    NESSAddCreatureToGroup("brc_ogre023", "ogres", 8);


//Orcs + Elite
    NESSAddCreatureToGroup("brc_orcrockfa001", "orcse", 3);
    NESSAddCreatureToGroup("brc_orcrockfa002", "orcse", 4);
    NESSAddCreatureToGroup("brc_orcrockfa003", "orcse", 5);
    NESSAddCreatureToGroup("brc_orcrockfa005", "orcse", 4);
    NESSAddCreatureToGroup("brc_orcrockfang1", "orcse", 4);
    NESSAddCreatureToGroup("brc_orcrockfa004", "orcse", 6);

//Orcs
    NESSAddCreatureToGroup("brc_orcrockfa001", "orcs", 3);
    NESSAddCreatureToGroup("brc_orcrockfa002", "orcs", 4);
    NESSAddCreatureToGroup("brc_orcrockfa003", "orcs", 5);
    NESSAddCreatureToGroup("brc_orcrockfa005", "orcs", 4);
    NESSAddCreatureToGroup("brc_orcrockfang1", "orcs", 4);

//Orcs
    NESSAddCreatureToGroup("tt_ghost", "sorrghost", 6);
    NESSAddCreatureToGroup("tt_ghost001", "sorrghost", 6);
    NESSAddCreatureToGroup("tt_ghost002", "sorrghost", 6);
    NESSAddCreatureToGroup("tt_ghost003", "sorrghost", 6);





















}


void NESSAddCreatureToGroup(string CreatureResRef, string GroupName, int CreatureChallengeRating)
{
    object oMod         = GetModule();

    // sanity checks
    if(CreatureResRef=="" || GroupName=="") return;
    if(CreatureChallengeRating<1) CreatureChallengeRating = 1;


    // add creature to master list
    int nIndex  =   GetLocalInt(oMod,"NESS_COUNT_"+GroupName)+1;
                    SetLocalInt(oMod,"NESS_COUNT_"+GroupName,nIndex);

    SetLocalString(oMod, "NESS_"+GroupName+"_"+IntToString(nIndex),CreatureResRef);

    if(CreatureChallengeRating>0)
    {
        // add creature to CR list
        string CRLabel  = IntToString(CreatureChallengeRating);
        int nCRIndex    = GetLocalInt(oMod, "NESS_COUNT_CR"+CRLabel+"_"+GroupName)+1;
                          SetLocalInt(oMod, "NESS_COUNT_CR"+CRLabel+"_"+GroupName, nCRIndex);

        SetLocalString(oMod, "NESS_"+GroupName+"_"+IntToString(CreatureChallengeRating)+"_"+IntToString(nCRIndex),CreatureResRef);
    }
}



string NESSGetCreatureFromGroupList(object oSpawn, string sGroupName, int nCR=0)
{
    string sResRef;

    // set to TRUE below if you want to prevent a spawn
    int bNoSpawn;
    if(sGroupName!="")
    {
        // USER CONFIGURABLE ---------------------------------------------------
        if(sGroupName=="goblincommoners")
        {

        }
        /*
        else if (sGroupName == "gobsnboss")
        {
            if(GetLocalInt(oSpawn, "IsBossSpawned"))
            {
                // Find the Boss
                object oBoss = GetChildByTag(oSpawn, GetLocalString(oSpawn,"BossTag"));

                // Check if Boss is Alive
                if(oBoss==OBJECT_INVALID || GetIsDead(oBoss))
                {
                    // He's dead, Deactivate Camp!
                    SetLocalInt(oSpawn, "SpawnDeactivated", TRUE);
                    bNoSpawn    = TRUE;
                }
                else
                {


                }
            }
            else
            {
                // No Boss, so Let's Spawn Him
                if(!nCR || nCR>=11)
                {
                    sResRef = "nw_goblinboss";
                    if(nCR)
                        SetLocalInt(oSpawn, "NESS_LAST_SPAWN_CR",11);
                }
                else if(nCR>=4)
                {
                    sResRef = "nw_gobchiefa";
                    SetLocalInt(oSpawn, "NESS_LAST_SPAWN_CR",4);
                }
                else
                {
                    sResRef = "nw_gobchiefb";
                    SetLocalInt(oSpawn, "NESS_LAST_SPAWN_CR",3);
                }

                SetLocalString(oSpawn,"BossTag", GetStringUpperCase(sResRef));
                SetLocalInt(oSpawn, "IsBossSpawned", TRUE);
            }
        }
        */
        // END USER CONFIGURABLE -----------------------------------------------

        // we have yet to receive a creature resref so lets randomly select one from our list...
        if(sResRef=="" && !bNoSpawn)
        {
            object oMod = GetModule();
            string sGroupLabel; int nListCount;
            // scaled encounters....
            if(nCR)
            {
                    nListCount  = GetLocalInt(oMod, "NESS_COUNT_CR"+IntToString(nCR)+"_"+sGroupName);
                while( !nListCount && nCR>0 )
                    nListCount  = GetLocalInt(oMod, "NESS_COUNT_CR"+IntToString(--nCR)+"_"+sGroupName);

                if(nListCount)
                {
                    sGroupLabel = "NESS_"+sGroupName+"_"+IntToString(nCR)+"_";
                    SetLocalInt(oSpawn, "NESS_LAST_SPAWN_CR",nCR);
                }
                else
                    DeleteLocalInt(oSpawn, "NESS_LAST_SPAWN_CR");
            }
            // randomly from the entire list
            else
            {
                    nListCount  = GetLocalInt(oMod, "NESS_COUNT_"+sGroupName);
                if(nListCount)
                    sGroupLabel = "NESS_"+sGroupName+"_";
            }

            if(sGroupLabel!="")
            {
                // This line ensures the Random function behaves randomly.
                int iRandomize = Random(Random(GetTimeMillisecond()));

                sResRef = GetLocalString(oMod, sGroupLabel+IntToString(Random(nListCount)+1));
            }
        }

    }

    return sResRef;
}

// - [File: spawn_cfg_group]
string SpawnGroup(object oSpawn, string sTemplate);
string SpawnGroup(object oSpawn, string sTemplate)
{
    // Initialize
    string sRetTemplate;
    int nSpawnNumber    = GetLocalInt(oSpawn, "f_SpawnNumber");

    // BEGIN SCALING -----------------------------------------------------------
    if (GetStringLeft(sTemplate, 7) == "scaled_")
    {
        float fEncounterLevel;
        string sGroupType = GetStringRight(sTemplate, GetStringLength(sTemplate) - 7);

        // First Time in for this encounter?
        if (!GetLocalInt(oSpawn, "ScaledInProgress"))
        {

            // First time in - find the party level
            int nTotalPCs = 0;
            int nTotalPCLevel = 0;

            float fTriggerRadius    = GetLocalFloat(oSpawn, "f_SpawnTrigger");
            if(fTriggerRadius>0.0)
            {
                location lLoc   = GetLocation(oSpawn);
                object oPC  = GetFirstObjectInShape(SHAPE_SPHERE,fTriggerRadius,lLoc);
                while (oPC != OBJECT_INVALID)
                {
                    if(!GetIsDM(oPC) && GetIsPC(oPC))
                    {
                        nTotalPCs++;
                        nTotalPCLevel = nTotalPCLevel + GetHitDice(oPC);
                    }
                    oPC = GetNextObjectInShape(SHAPE_SPHERE,fTriggerRadius,lLoc);
                }
            }
            else
            {
                object oArea = GetArea(OBJECT_SELF);
                object oPC = GetFirstPC();
                while (oPC != OBJECT_INVALID)
                {
                    if(     !GetIsDM(oPC)
                        &&  GetArea(oPC)==oArea
                      )
                    {
                        nTotalPCs++;
                        nTotalPCLevel = nTotalPCLevel + GetHitDice(oPC);
                    }
                    oPC = GetNextPC();
                }
            }

            if (nTotalPCs == 0)
                fEncounterLevel = 0.0;
            else
            {
                float fPCs      = IntToFloat(nTotalPCs);
                fEncounterLevel = (IntToFloat(nTotalPCLevel)/ fPCs)
                                  // *(fPCs/4.0)
                                    ;
            }

            // Save this for subsequent calls
            SetLocalFloat(oSpawn, "ScaledEncounterLevel", fEncounterLevel);

            // We're done when the CRs chosen add up to the desired encounter level
            SetLocalInt(oSpawn, "ScaledCallCount", 0);
            SetLocalInt(oSpawn, "ScaledInProgress", TRUE);
        }

            fEncounterLevel     = GetLocalFloat(oSpawn, "ScaledEncounterLevel");
        int nScaledCallCount    = GetLocalInt(oSpawn, "ScaledCallCount");

        // For simplicity, I'm not supporting creatures with CR < 1.0)
        if (fEncounterLevel < 1.0)
            // We're done... No creatures have CR low enough to add to this encounter
            sRetTemplate = "";
        else
        {
            int nCR;
            if(nScaledCallCount)
            // randomly choose a CR at or below the remaining (uncovered) encounter level
                nCR = Random(FloatToInt(fEncounterLevel)) + 1;
            else
                // on the first call use the largest possible CR
                nCR = FloatToInt(fEncounterLevel);
            sRetTemplate = NESSGetCreatureFromGroupList(oSpawn, sGroupType, nCR);

            // Calculate remaining
            nCR = GetLocalInt(oSpawn, "NESS_LAST_SPAWN_CR");

            float fElRemaining  = 1.0 - ConvertCRToELEquiv(IntToFloat(nCR), fEncounterLevel);

            fEncounterLevel = ConvertELEquivToCR(fElRemaining, fEncounterLevel);
            SetLocalFloat(oSpawn, "ScaledEncounterLevel", fEncounterLevel);
        }

        SetLocalInt(oSpawn, "ScaledCallCount", ++nScaledCallCount);
        if (nScaledCallCount >= nSpawnNumber)
            // reset...
            SetLocalInt(oSpawn, "ScaledInProgress", FALSE);
    }
    // END SCALING -------------------------------------------------------------
    else
    {
        sRetTemplate = NESSGetCreatureFromGroupList(oSpawn, sTemplate);
    }

// -------------------------------------------
// Only Make Modifications Between These Lines
//
    return sRetTemplate;
}
