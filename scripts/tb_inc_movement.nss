// tb_inc_movement
// Armor encumbrance and racial movement rate
//
//

// parts adapted from Mad Rabbit's Roleplaying World

#include "tb_inc_util"
#include "00_debug"

//Set to TRUE to enable the armor encumbrance system. Set to FALSE to disable
//Default : TRUE
const int TB_ARMOR_ENCUMBRANCE = TRUE;
const int TB_ARMOR_DELAY = TRUE;
const int TB_RACIAL_MOVERATES = TRUE;

///////////////////////////////Constants///////////////////////////////////////

//Tag of the Effect Generator for the Encumbrance Systen
// Create a placeable with this tag in the module somewhere.
const string TB_ARMOR_ENC_GENERATOR_TAG = "tb_armor_enc_gen";
const string TB_RACIAL_MOVEMENT_GENERATOR_TAG = "tb_racial_move_gen";

const int LIGHT_ARMOR_PENALTY   = 0;
const int MED_ARMOR_PENALTY     = 15;
const int HEAVY_ARMOR_PENALTY   = 30;
const int SMALL_ARMOR_BONUS     = 5;
const int SMALL_RACE_PENALTY    = 30; // 20' instead of 30' in PHB

// delay to equip armor  in rounds.
const int LIGHT_ARMOR_DELAY     = 1;
const int MEDIUM_ARMOR_DELAY    = 2;
const int HEAVY_ARMOR_DELAY     = 4;

//Apply Movement Speed Penalty if oItem is heavy or medium or light armor that is equipped
void tbArmorEncApplyPenalty(object oPC, int nPenalty, int bRemove = FALSE);

//Remove Movement Speed Penalty if oItem is heavy or medium or light armor that is unequipped
void tbArmorEncRemovePenalty(object oPC);


void armorRemoveEffects(object oPC, object oGenerator) {
    object oCreator;
    effect eEffect = GetFirstEffect(oPC);

    while (GetIsEffectValid(eEffect)) {
        oCreator = GetEffectCreator(eEffect);
        if (oCreator == oGenerator) {
            RemoveEffect(oPC, eEffect);
            SendMessageToPC(oPC, "Armor Encumbrance penalty removed.");
        }
        eEffect = GetNextEffect(oPC);
    }
}

object getGenerator(string sTag) {
      object oGenerator = GetObjectByTag(sTag);
      if(!GetIsObjectValid(oGenerator)) {
          err("ERROR: Effect generator (" + sTag + ") not found!");
      }
      return oGenerator;
}

// Executed as the TB_ARMOR_ENC_TAG_GENERATOR object
void tbArmorEncApplyPenalty(object oPC, int nPenalty, int bRemove = FALSE) {
    effect eEffect = SupernaturalEffect(EffectMovementSpeedDecrease(nPenalty));

    // Can only ever have one armor encumbrance penalty so remove first just.
    if (bRemove) armorRemoveEffects(oPC, OBJECT_SELF);
    //ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oPC);
    ApplyEffectToPCAndHideIcon(DURATION_TYPE_PERMANENT, eEffect, oPC);
}


// Executed as the TB_ARMOR_ENC_TAG_GENERATOR object
void tbArmorEncRemovePenalty(object oPC) {
    //Remove any effects created by the generator
    armorRemoveEffects(oPC, OBJECT_SELF);
}


        // In rounds
int tbArmorGetDelay(int nArmorType) {

        if (!TB_ARMOR_DELAY)
                return 0;

        switch(nArmorType) {
                case ARMOR_TYPE_LIGHT: return LIGHT_ARMOR_DELAY;
                case ARMOR_TYPE_MEDIUM: return MEDIUM_ARMOR_DELAY;
                case ARMOR_TYPE_HEAVY: return HEAVY_ARMOR_DELAY;
        }
        return 0;
}

string tbArmorGetName(int nArmorType) {

        switch(nArmorType) {
                case ARMOR_TYPE_LIGHT: return "Light";
                case ARMOR_TYPE_MEDIUM: return "Medium";
                case ARMOR_TYPE_HEAVY: return "Heavy";

        }
        return "";
}

float tbArmorDoEquipDelay(object oPC, int nArmorType) {

        // Don't do the equip delay if this is the PC entering the module
        // i.e. if the onenter code has not completed.
        // All pre-equipped things fire on equip before on client enter runs.
        if (!GetLocalInt(oPC, "PC_ENTERED"))
                return 0.0;

        //SendMessageToPC(oPC, "PC not marked as entering - doing armor equip");
        WriteTimestampedLogEntry("PC not marked as entering - doing armor equip");
        int nDelay = tbArmorGetDelay(nArmorType);
        if (nDelay <= 0)
                return 0.0;

        float fTime =  RoundsToSeconds(nDelay);
        effect eVisual  = EffectVisualEffect(VFX_DUR_PARALYZED);
        effect eChangingarmor = EffectCutsceneImmobilize();

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eChangingarmor, oPC, fTime);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVisual, oPC, fTime);

        AssignCommand(oPC, DelayCommand(2.0, ActionDoCommand(ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, fTime-2.0))));
        string s = "s";
        if (nDelay == 1) s = "";
        SendMessageToPC(oPC,"*Equipping this armor will take "+ IntToString(nDelay) + " round" + s + "*");
        DelayCommand(fTime, SendMessageToPC(oPC,"*Equipped " + tbArmorGetName(nArmorType) + " Armor*"));

        return fTime;
}

int tbGetBaseArmorPenalty(object oItem, object oPC, int nArmorType = -1) {
        if (nArmorType < 0) nArmorType = GetItemArmorType(oItem);
  
        // We're not using a penalty for LIGHT either in HE so skip it here.
        if (nArmorType <= ARMOR_TYPE_LIGHT)
                return 0;

    //Determine the penalty based on race and AC Value
        int nRacialType = GetRacialType(oPC);
    // Dwarves suffer on armor penatly
        if (nRacialType == RACIAL_TYPE_DWARF)
                return 0;

        int nPenalty =  LIGHT_ARMOR_PENALTY ;
        if (nArmorType == ARMOR_TYPE_MEDIUM)
                nPenalty = MED_ARMOR_PENALTY;
        else if (nArmorType == ARMOR_TYPE_HEAVY)
                nPenalty = HEAVY_ARMOR_PENALTY;

        if (nRacialType == RACIAL_TYPE_HALFLING || nRacialType == RACIAL_TYPE_GNOME)
                nPenalty -= SMALL_ARMOR_BONUS;

        return nPenalty;
}

int tbArmorGetModifiedPenalty(object oPC, int nPenalty) {
        // Reduce penalty by 5% per STR bonus.  - by that token though it goes up for low str :)
        int nModified = nPenalty - (GetAbilityModifier(ABILITY_STRENGTH, oPC) * 5);
        if (nModified < 0) nModified = 0;

        return nModified;
}


// This can be used to re-apply a penalty as well.
int tbArmorDoApplyPenalty(object oPC, int nPenalty) {
        object oGenerator = getGenerator(TB_ARMOR_ENC_GENERATOR_TAG);

        int nCur = GetLocalInt(oPC, "armor_enc_penalty");
        int bRemove = (nCur > 0);

        int nModified = tbArmorGetModifiedPenalty(oPC, nPenalty);
        dbstr("Armor enc penalty " + IntToString(nPenalty) + " after str mod = " + IntToString(nModified ));
        if (nModified > 0) {
                AssignCommand(oGenerator, tbArmorEncApplyPenalty(oPC, nModified, bRemove));
        } else if (nCur > 0) {
                AssignCommand(oGenerator, tbArmorEncRemovePenalty(oPC));
        }
        // Track the str and base penalty when we applied the penalty - even if there's no current 
        // penalty due to STR bonus.
        SetLocalInt(oPC, "armor_enc_last_str", GetAbilityScore(oPC, ABILITY_STRENGTH)); 
        SetLocalInt(oPC, "armor_enc_base_penalty", nPenalty); 
        SetLocalInt(oPC, "armor_enc_penalty", nModified); 
        return nModified;
}

void tbArmorDoRemovePenalty(object oPC) {

        int nCur =  GetLocalInt(oPC, "armor_enc_penalty"); 

        if (nCur) {
                object oGenerator = getGenerator(TB_ARMOR_ENC_GENERATOR_TAG);
                AssignCommand(oGenerator, tbArmorEncRemovePenalty(oPC)); 
        }

        DeleteLocalInt(oPC, "armor_enc_last_str"); 
        DeleteLocalInt(oPC, "armor_enc_base_penalty"); 
        DeleteLocalInt(oPC, "armor_enc_penalty"); 
}

// Add a call to this in module's onequip handler
void tbArmorOnEquip(object oItem, object oPC) {
        if (GetBaseItemType(oItem) != BASE_ITEM_ARMOR)
                return;

        int nArmorType = GetItemArmorType(oItem);
        float fTime = tbArmorDoEquipDelay(oPC, nArmorType);

        int nPenalty = tbGetBaseArmorPenalty(oItem, oPC, nArmorType);
        if (nPenalty <= 0) return;

        // Apply penalty if needed - str bonus reduction happens here so there may 
        // not actually be a penalty. 
        int nApplied = tbArmorDoApplyPenalty(oPC, nPenalty);
        if (nApplied > 0) {
                //DelayCommand(fTime, SendMessageToPC(oPC,"Your movement speed has been decreased."));
                DelayCommand(fTime, SendMessageToPC(oPC, "Armor Encumbrance penalty, movement rate reduced "
                        + IntToString(nApplied) + "%."));
        }
}


void tbArmorOnUnEquip(object oItem, object oPC) {

        if (GetBaseItemType(oItem) != BASE_ITEM_ARMOR)
            return;

        /* Don't need this check anymore
        int nArmorType = GetItemArmorType(oItem);
        // no penalty for less than medium
        if (nArmorType < ARMOR_TYPE_MEDIUM)
            return;
        */

        tbArmorDoRemovePenalty(oPC);
}

void tbArmorCheckPenalty(object oPC) {
        // These are redundant and should go - this check is made in HB before executing the tb_do_moverate script to call this
        //int nLastStr = GetLocalInt(oPC, "armor_enc_last_str");
        //if (!nLastStr) return;

        //int nCur =  GetAbilityScore(oPC, ABILITY_STRENGTH); 
        //if (nCur == nLastStr) return;

        // Str has changed - redo the penalty
        int nPenalty = GetLocalInt(oPC, "armor_enc_base_penalty");
        if (!nPenalty) return;

        int nCur = GetLocalInt(oPC, "armor_enc_penalty");
        int nModified =  tbArmorGetModifiedPenalty(oPC, nPenalty);

        if (nCur == nModified) {
                dbstr("Armor: " + GetName(oPC) + ": str changed but did not effect encumbrance. ");
                return;
        }
        tbArmorDoApplyPenalty(oPC, nPenalty);    
}


void ClearRacialMovementRate(object oCreature) {
        object oGenerator = getGenerator(TB_RACIAL_MOVEMENT_GENERATOR_TAG);
        armorRemoveEffects(oCreature, oGenerator);
}

void SetRacialMovementEffect(object oCreature, int nPenalty) {

        //db("Setting Racial Movement penalty : ", nPenalty, " for " + GetName(oCreature));
        effect eRate = SupernaturalEffect(EffectMovementSpeedDecrease(nPenalty));
        ApplyEffectToPCAndHideIcon(DURATION_TYPE_PERMANENT, eRate, oCreature);
}

// This is called from module onEnter
// or Creature spawn
void SetRacialMovementRate(object oCreature) {


        if(GetLocalInt(oCreature, "tb_did_racial_movement")) return;

        if (!GetLocalInt(GetModule(),"RACIALMOVE")) return;


        ClearRacialMovementRate(oCreature);

        int nType = GetRacialType(oCreature);
        if(nType == RACIAL_TYPE_ANIMAL
                || nType == RACIAL_TYPE_BEAST
                || nType == RACIAL_TYPE_DRAGON
                || nType == RACIAL_TYPE_MAGICAL_BEAST
                || nType == RACIAL_TYPE_VERMIN)
        return;

        if(GetCreatureSize(oCreature) == CREATURE_SIZE_SMALL || nType == RACIAL_TYPE_DWARF) {
                object oGenerator = getGenerator(TB_RACIAL_MOVEMENT_GENERATOR_TAG);
                AssignCommand(oGenerator, SetRacialMovementEffect(oCreature, SMALL_RACE_PENALTY));

                SetLocalInt(oCreature, "tb_did_racial_movement", 1);
                return;
        }
}
