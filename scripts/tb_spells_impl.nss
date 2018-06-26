//tb_spells_impl.nss


#include "x2_i0_spells"
//#include "x2_inc_toollib"
#include "x2_inc_spellhook"
//#include "x2_inc_shifter"
#include "_inc_nwnx"
#include "_inc_spells"
//#include "tb_spell_util"


void spellsSetSpellData(object oCaster, object oTarget, location lLoc, int nLevel, int nDC, int nMetaMagic = METAMAGIC_NONE) {
        spell.Caster = oCaster;
        spell.Target = oTarget;
        spell.Loc = lLoc;
        spell.Level = nLevel;
        spell.DC = nDC;
        spell.Meta = nMetaMagic;
}

void sp_Pray_Feat(object oCaster) {
        // If nearby altar of PC's deity pray at that, else just pray to PCs god.
        SetLocalInt(oCaster, "deity_tmp_op", 5);
        ExecuteScript("deity_do_op", oCaster);
}
