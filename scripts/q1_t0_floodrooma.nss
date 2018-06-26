// Trapporium Flood Trap: Enter Flood Trap Extents

//#include "q_inc_traps"

//#include "_inc_util"
#include "_inc_terrain"



void main()
{
    object oPC  = GetEnteringObject();
    object oTrap= GetLocalObject(OBJECT_SELF,"TRAP_FLOOD");
    object oWaterArea=OBJECT_SELF;
    if(!GetLocalInt(oTrap,"TRP_TRIGGERED"))
        return;

    EnterUnderwaterZone(oPC, oTrap, oTrap);

}
