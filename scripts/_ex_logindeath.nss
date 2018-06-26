// _ex_logindeath.nss

// Run as the PC on login to handle login while dead or rezzed.
#include "_inc_corpse"

void main() {
        object oPC = OBJECT_SELF;
        DelayCommand(5.0, deathCheckReentry(oPC));
}
