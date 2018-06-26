//::///////////////////////////////////////////////
//:: underwater_exit
//:://////////////////////////////////////////////
/*
    this always exits on the exiting object
*/
//:://////////////////////////////////////////////
//:: Created : henesua (2016 aug 2)
//:://////////////////////////////////////////////

#include "_inc_terrain"

void main()
{
    object creature;
    object zone_source;
    object zone_tracker;

    switch(GetObjectType(OBJECT_SELF))
    {
        case OBJECT_TYPE_CREATURE:
            creature    = OBJECT_SELF;
            zone_source = GetLocalObject(creature, "EXITING_AREA");
            zone_tracker= GetZoneTracker(zone_source);
        break;
        case OBJECT_TYPE_TRIGGER:
            creature    = GetExitingObject();
            zone_source = OBJECT_SELF;
            zone_tracker= OBJECT_SELF;
        break;
        case OBJECT_TYPE_AREA_OF_EFFECT:
            creature    = GetExitingObject();
            zone_source = OBJECT_SELF;
            zone_tracker= OBJECT_SELF;
        break;
        default:
            creature    = GetExitingObject();
            zone_source = OBJECT_SELF;
            zone_tracker= OBJECT_SELF;
        break;
    }

    if(GetIsDM(creature))
        return;


    DelayCommand(1.0, ExitUnderwaterZone(creature,zone_source,zone_tracker) );
}




