// tb_spell_generic.nss
// This is a wrapper to use as the impact script of any spell which does not use the (or never had an) original 
// impact script. 
// the spell system drives all such spells from the spell hook code so this basically just calls that. 

#include "x2_inc_spellhook"
#include "00_Debug"

void main () {
        
       /*
       Spellcast Hook Code
       Added 2003-06-20 by Georg
       If you want to make changes to all spells,
       check x2_inc_spellhook.nss to find out more
       */

        if (!X2PreSpellCastCode()) {
                // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
                return;
        }

        // Should never get here. 
        int nSpell = GetSpellId();
        err("Spell ", nSpell, " was not handled.");
 
}