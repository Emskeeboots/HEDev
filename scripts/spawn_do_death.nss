// spawn_do_death.nss
// Notify NESS of a spawn's death.
// Executed as the dead creature from the ondeath event handler.

#include "spawn_functions"

void main() {
        object oNPC = OBJECT_SELF;
        NESS_ProcessDeadCreature(oNPC);   
}