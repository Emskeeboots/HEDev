//::///////////////////////////////////////////////
//:: _trg_footstep_en
//:://////////////////////////////////////////////
/*
    intended for use in a trigger's onenter event and paired with aa_trg_ex_carpet in the onexit event
    this is used to solve the problem of placeable carpets not changing the footstep type

    changes footstep sounds within a trigger to correspond with an imposed material type

    FOOTSTEP_TYPE
    1   dirt
    2   grass
    3   stone
    4   wood
    5   water
    6   carpet
    7   metal
    8   puddle
    9   leaves
    10  sand
    11  snow

    default is carpet

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2011 apr 5)
//:: Modified: The Magus (2011 dec 30) enabled different footstep types w/ carpet as the default
//:: Modified: The Magus (2012 aug 21) reworked the footsteps 2da and this script
//:://////////////////////////////////////////////

#include "_inc_terrain"

void main()
{
 object oCreature = GetEnteringObject();
 if ( !GetIsObjectValid(oCreature) )
    return;

    // Set new footsteps
    int nFootstepType = GetLocalInt(OBJECT_SELF,"FOOTSTEP_TYPE");
    if(!nFootstepType)
        nFootstepType = 6;

    TerrainSetFootsteps(oCreature, nFootstepType);
}
