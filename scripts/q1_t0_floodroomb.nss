// Trapporium Flood Trap: Exit Flood Trap Extents

//#include "q_inc_traps"

#include "_inc_terrain"

void main()
{
    object oPC  = GetEnteringObject();
    object oTrap= GetLocalObject(OBJECT_SELF,"TRAP_FLOOD");
    object oWaterArea=OBJECT_SELF;

    ExitUnderwaterZone(oPC, oTrap, oTrap );
}
