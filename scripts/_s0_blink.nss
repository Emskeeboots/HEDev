//::///////////////////////////////////////////////
//:: _s0_blink
//:://////////////////////////////////////////////
/*
    at present this spell does not function as it should.
    consider placeholder until rewritten

    this spell does have its own VFX which can be applied to location (Rubies and Pearls (2012 nov 28) (VFX))
        int VFX_IMP_BLINK = 1666;

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 29)  set up as placeholder
//::////////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();

    // does nothing
}
