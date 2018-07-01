//tb_spell_router.nss
// This is the master spell router code.
// ALL spells fire through here but it will
// farm some of them off to different subrouters if needed.

#include "nw_i0_spells"
#include "x2_inc_spellhook"
#include "tb_spells_impl"

int spellGetRouter(int nSpell) {
        int nRet = -1; // default to using impact script

        switch(nSpell) {
                case 844: return 0;  // this script
        }


        return nRet;
}



void main() {

        object oCaster = OBJECT_SELF;
        object oSpellItem = GetSpellCastItem();
        int nSpell = GetSpellId();
        int nCastLvl = -1;

        //Debug
        spell_debug("Spell: " + IntToString(nSpell), oCaster);
        spell_debug("Cast by: "+GetName(oCaster), oCaster);
        spell_debug("Casting Item : '" +  GetName(oSpellItem) + "'", oCaster);
  
  /*
        string sPatched = Get2DAString("spells_extra","Patch",nSpell);
        if (sPatched == "0") {
                spell_debug("Spell not patched - using original", oCaster);
                //SendMessageToPC(oCaster, "Spell not patched - using original");
                SetLocalInt(oCaster,"X2_L_BLOCK_LAST_SPELL",FALSE);
                return;
        }
*/

        int nRouter  = spellGetRouter(nSpell);
        switch (nRouter) {
                case -1: spell_debug("Spell not patched - using original", oCaster);
                //SendMessageToPC(oCaster, "Spell not patched - using original");
                SetLocalInt(oCaster,"X2_L_BLOCK_LAST_SPELL",FALSE);
                return;
                
                case 0: break; // handled here
                /*
                case 1: ExecuteScript("tb_spell_router1", oCaster);
                        return;

                case 2: ExecuteScript("tb_feat_router", oCaster);
                        return;

                case 3: ExecuteScript("tb_spell_router2", oCaster);
                        return;

                case 4: ExecuteScript("ifam_spell_route", oCaster);
                        return;
                */
        }
   
        object oTarget = GetSpellTargetObject();
        location lTarget = GetSpellTargetLocation();
        if (nCastLvl < 0)
                nCastLvl = tbGetCasterLevel(oCaster, oSpellItem);
        int nMeta = tbGetMetaMagicFeat(oCaster, oSpellItem);
        int nDC = tbGetSpellSaveDC(oCaster, oSpellItem, nCastLvl);
        spell.Level = nCastLvl;
        spell_debug("Spellrouter: spell = " + IntToString(nSpell) + " castlvl = " + IntToString(nCastLvl)
         + " nDC = " + IntToString(nDC) + " nMeta = " + IntToString(nMeta), oCaster);      

        int bDone = FALSE;
        object oFamiliar = OBJECT_INVALID;
        object oAnimalCom = OBJECT_INVALID;
        switch(nSpell) {

                // PRAY
                case 844:  sp_Pray_Feat(oCaster);     bDone = TRUE; break;

        }

        if (bDone)
           SetModuleOverrideSpellScriptFinished();
}