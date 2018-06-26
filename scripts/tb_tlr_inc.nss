//::///////////////////////////////////////////////
//:: Meaglyn's Tailor system
//::
//:: Adapted from milambus' tailor stuff and bloodsong's symmetry additions
//:: By Meaglyn
//::

#include "tlr_inc_utils"

/*
        Meaglyn's clothing tailoring system.

        This is based on Milambus's tailor, but was almost completely rewritten
        and converted to use zldg. It was extended with real lists to control the
        allowed or denied part numbers.


        Variables on the model:

        "TLR_BASE_RESREF" string  : Specifies the clothing to start with. If unset defaults
                    to TAILOR_MALE_CLOTH and TAILOR_FEMALE_CLOTH defined below.


        "TLR_ALLOWED_AC"  int   : Restrict the model to using only the specified AC.
                                Default it 0 (clothing). Set it to -1 to allow all
                                ACs. Currently only a single AC is allowed.

        "TLR_ALLOW_SPECIAL" int : If TLE_ALLOW_SPECIAL and this is set the model will
                                  allow the restricted parts for torso and pelvis.



*/

const int TLR_GENDER_RESTRICT = TRUE;
const int TLR_ALLOW_SPECIAL = TRUE;


// The default clothing models
// These may be overridden by TLR_BASE_RESEREF on the model.
// This needs to be done for models which build armors or they start
// with skimpy clothing which cannot be used in the armor.
//const string TAILOR_MALE_CLOTH = "mil_clothing668";
//const string TAILOR_FEMALE_CLOTH = "mil_clothing669";
const string TAILOR_MALE_CLOTH = "mil_clothing_def";
const string TAILOR_FEMALE_CLOTH = "mil_clothing_def";



void tlrRemoveEffects(object oModel = OBJECT_SELF){

        effect eLoop = GetFirstEffect(oModel);

        while (GetIsEffectValid(eLoop)) {
                SendMessageToPC(GetFirstPC(), "Found Effect : " + IntToString(GetEffectType(eLoop)));
                RemoveEffect(oModel, eLoop);

                eLoop = GetNextEffect(oModel);
        }
}


void tlrFreezeModel(object oModel = OBJECT_SELF) {

        //tlrRemoveEffects(oModel);

        effect e = EffectCutsceneParalyze();
        effect v = EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION);

    //effect eLink = EffectLinkEffects(e,v);
    //ApplyEffectToObject(DURATION_TYPE_PERMANENT,eLink, oModel);

        ApplyEffectToObject(DURATION_TYPE_PERMANENT,e, oModel);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,v, oModel);

        //ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e, oModel, 10000.0);
        //ApplyEffectToObject(DURATION_TYPE_TEMPORARY,v, oModel, 10000.0);

        tlrDebug("Apply Freeze effect now (e = " + IntToString(GetEffectType(e)) + " v = "
            + IntToString(GetEffectType(v)) + ").");
}

int tlrGetAppearanceFromRace(int nRace) {
        int nAppear = APPEARANCE_TYPE_HUMAN;

        switch (nRace) {
                case RACIAL_TYPE_DWARF: nAppear = APPEARANCE_TYPE_DWARF; break;
                case RACIAL_TYPE_ELF: nAppear = APPEARANCE_TYPE_ELF; break;
                case RACIAL_TYPE_GNOME: nAppear = APPEARANCE_TYPE_GNOME; break;
                case RACIAL_TYPE_HALFELF: nAppear = APPEARANCE_TYPE_HALF_ELF; break;
                case RACIAL_TYPE_HALFLING: nAppear = APPEARANCE_TYPE_HALFLING; break;
                case RACIAL_TYPE_HALFORC: nAppear = APPEARANCE_TYPE_HALF_ORC; break;
                case RACIAL_TYPE_HUMAN: nAppear = APPEARANCE_TYPE_HUMAN; break;
        }
        return nAppear;
}

 //string sRef = GetResRef(OBJECT_SELF);
//ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), OBJECT_SELF);
    //CreateObject(OBJECT_TYPE_CREATURE, sRef, GetLocation(OBJECT_SELF));
    //DestroyObject(OBJECT_SELF);
int tlrSetModelType(int nRace) {
        int nAppear =  tlrGetAppearanceFromRace(nRace);

        //tlrRemoveEffects(OBJECT_SELF);
        if (GetAppearanceType(OBJECT_SELF) != nAppear) {
            tlrRemoveEffects(OBJECT_SELF);
            tlrDebug("Pre Appearance = " + IntToString(GetAppearanceType(OBJECT_SELF))
                + " race = " + IntToString(GetRacialType(OBJECT_SELF)));
            SetCreatureAppearanceType(OBJECT_SELF, nAppear);
            tlrDebug("Post Appearance = " + IntToString(GetAppearanceType(OBJECT_SELF))
                + " race = " + IntToString(GetRacialType(OBJECT_SELF)));

            ActionPlayAnimation(ANIMATION_LOOPING_PAUSE2, 1.0,4.0);
            // TODO this probably needs to be adjusted for the new stance.
            DelayCommand(5.1, tlrFreezeModel());
            return TRUE;
        }
        return FALSE;
}

void tlrDoModelType(int nRace) {
        int nAppear =  tlrGetAppearanceFromRace(nRace);
        if (GetAppearanceType(OBJECT_SELF) != nAppear) {
                tlrRemoveEffects(OBJECT_SELF);
                SetCreatureAppearanceType(OBJECT_SELF, nAppear);
                //ActionPlayAnimation(ANIMATION_LOOPING_PAUSE2, 1.0,4.0);
                DelayCommand(5.1, tlrFreezeModel());
        }
}

string tlrGetBaseResref(object oModel) {
        string sRef = GetLocalString(oModel, "TLR_BASE_RESREF");
        if (sRef != "")
                return sRef;

        if (GetGender(OBJECT_SELF) == GENDER_FEMALE)
                return TAILOR_FEMALE_CLOTH;


        return TAILOR_MALE_CLOTH;
}


void tlrReset() {
        object oCloth = GetItemInSlot(INVENTORY_SLOT_CHEST);

        string sBP = tlrGetBaseResref(OBJECT_SELF);
        object oNew = CreateItemOnObject(sBP);

        tlrDebug(" Got " + sBP + " for default tag = '" + GetTag(oNew) + "'");
        if (TLR_GENDER_RESTRICT) {
                if (GetGender(OBJECT_SELF) == GENDER_FEMALE) {
                        SetLocalInt(oNew, "GENDER_FEMALE",1);
                        DeleteLocalInt(oNew, "GENDER_MALE");
                } else {
                        SetLocalInt(oNew, "GENDER_MALE",1);
                        DeleteLocalInt(oNew, "GENDER_FEMALE");
                }
        }
        DeleteLocalInt(OBJECT_SELF, "TLR_COPIED_AC");

        DelayCommand(0.5, ActionEquipItem(oNew, INVENTORY_SLOT_CHEST));
        DestroyObject(oCloth, 0.8);
}

void tlrReEquip(object oModel = OBJECT_SELF) {
        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);
        AssignCommand(oModel, ActionUnequipItem(oArmor));
        //AssignCommand(oModel, ActionEquipItem(oArmor, INVENTORY_SLOT_CHEST));
        DelayCommand(0.1, AssignCommand(oModel, ActionEquipItem(oArmor, INVENTORY_SLOT_CHEST)));
}

//Oldfog changed 2.0 to 0.0
int tlrGetBuyCost(object oPC, object oModel = OBJECT_SELF) {
        int nBaseCost = 0; //-- change to raise prices
        float BaseMultiplyer = 0.0; //-- milamber's default


        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        int nCost = nBaseCost + FloatToInt((IntToFloat(GetGoldPieceValue(oItem)) * BaseMultiplyer));

        SetLocalInt(oPC, "TLR_CURRENTPRICE", nCost);

        return nCost;
}
//Oldfog changed 0.5 to 0.0
int tlrGetCopyCost(object oPC, object oModel = OBJECT_SELF) {
        int nBaseCost = 0; //-- change to raise prices
        float BaseDivider = 0.0; //-- milamber's default

        object oNPCItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        object oPCItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);

        int nCost = nBaseCost + GetGoldPieceValue(oNPCItem) + FloatToInt(IntToFloat(GetGoldPieceValue(oPCItem)) * BaseDivider);

        SetLocalInt(oPC, "TLR_CURRENTPRICE", nCost);

        return nCost;
}

int tlrDoBuyItem(object oPC, object oModel = OBJECT_SELF) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);


        int nCost = GetLocalInt(oPC, "TLR_CURRENTPRICE");

        if (GetGold(oPC) < nCost) {
                return FALSE;
        }


        TakeGoldFromCreature(nCost, oPC, TRUE);

        // This would be better if it unequipped and gave the item itself...
        CopyItem(oItem, oPC, TRUE);

        return TRUE;
}


object tlrMakeNewItemAppearance(object oItem, int nPart, int nNewVal) {

        object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart, nNewVal, TRUE);
        SetDescription(oNewItem, GetDescription(oItem));
        DestroyObject(oItem);

        return oNewItem;
}

object tlrMakeNewItemColor(object oItem, int nChannel, int nNewVal) {

        object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nChannel, nNewVal, TRUE);
        SetDescription(oNewItem, GetDescription(oItem));
        DestroyObject(oItem);

        return oNewItem;
}

int tlrGetNextPartno(int nCur, int nPart, int nGender, int nRace, int bEx = FALSE, int nAC = -1, int bDec = FALSE) {
        string sAllow = "";
        string sDeny = "";
        int nBottom = 1;
        int nTop =255;
        int nACFilter = -1;

        switch (nPart) {

                case ITEM_APPR_ARMOR_MODEL_BELT:
                sAllow="";
                sDeny="";
                nTop=255;
                nBottom = 0;
                break;
                case ITEM_APPR_ARMOR_MODEL_RBICEP:
                case ITEM_APPR_ARMOR_MODEL_LBICEP:
                sAllow="";
                sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_RFOOT:
                case ITEM_APPR_ARMOR_MODEL_LFOOT:
                sAllow="";
                sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_RFOREARM:
                case ITEM_APPR_ARMOR_MODEL_LFOREARM:
                sAllow="";
                sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_RHAND:
                case ITEM_APPR_ARMOR_MODEL_LHAND:
                sAllow="";
                sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_RSHIN:
                case ITEM_APPR_ARMOR_MODEL_LSHIN:
                sAllow="";
                sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
                case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
                sAllow="";
                sDeny="";
                nTop=255;
                nBottom = 0;
                break;
                case ITEM_APPR_ARMOR_MODEL_RTHIGH:
                case ITEM_APPR_ARMOR_MODEL_LTHIGH:
                sAllow="";
                sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_NECK:
                sAllow="";
                sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_PELVIS:
                sAllow="";
                if (bEx) // allow extra stuff
                        sDeny="";
                else // no extra stuff
                        sDeny="";
                nTop=255;
                break;
                case ITEM_APPR_ARMOR_MODEL_ROBE:
                sAllow="";
                if (nRace != RACIAL_TYPE_HUMAN && nRace != RACIAL_TYPE_HALFELF) {
                        if (bEx)
                                sDeny = "";
                        else
                                sDeny = "";

                } else {
                        if (bEx)
                                sDeny="";
                        else
                                sDeny="";
                }
                nTop=255;
                nBottom = 0;
                break;
                case ITEM_APPR_ARMOR_MODEL_TORSO:
                nACFilter = nAC;
                sAllow="";
                if (bEx)
                        sDeny="";
                else
                        sDeny=""
                        + "";
                nTop=255;
                break;
        }

        if (sAllow == "") {
                return tlrNextIn2DAfile(nPart, nCur, nTop, nBottom, nACFilter, bDec, sDeny);
        }

        if (bDec)
                return tlrGetPrevIdx(nCur, nBottom, nTop, sAllow, sDeny);
        return tlrGetNextIdx(nCur, nBottom, nTop, sAllow, sDeny);

}

int tlrGetAllowedAC(object oModel) {
        int nAC = GetLocalInt(oModel, "TLR_COPIED_AC");
        if (nAC > 0 && nAC <= 8) return nAC;

        nAC = GetLocalInt(oModel, "TLR_ALLOWED_AC");
        if (nAC < 0)
                nAC = -1;

        // If invalid just do clothing.
        if (nAC > 8)
                nAC = 0;

        return nAC;
}

int tlrGetAllowSpecial(object oModel) {

        if (!TLR_ALLOW_SPECIAL)
                return FALSE;

        int nEx = GetLocalInt(oModel, "TLR_ALLOW_SPECIAL");
        return nEx;
}

int tlrGetCurrentPartNo(int nPart, object oModel = OBJECT_SELF) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);
        int nCur = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart);
        return nCur;
}
int tlrGetCurrentColorNo(int nChannel, object oModel = OBJECT_SELF) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);
        int nCur = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nChannel);
        return nCur;
}
int tlrIncrementPart(int nPart, object oPC, int bDec = FALSE, object oModel = OBJECT_SELF) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);

        //string s2DAFile = tlrGet2DAFile(nPart);
        //string s2DA_ACBonus;

        int nCur = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart);
        int nGender = GetGender(oPC);
        int nRace = GetRacialType(oPC);
        int bEx = tlrGetAllowSpecial(oModel);
        int nNewApp = tlrGetNextPartno(nCur, nPart, nGender, nRace, bEx, tlrGetAllowedAC(oModel), bDec);

        object oNewItem = tlrMakeNewItemAppearance(oItem, nPart, nNewApp);

        tlrDebug("New Appearance: " + IntToString(nNewApp) + " for part " + IntToString(nPart), oPC);

        AssignCommand(oModel, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
        return nNewApp;
}

int tlrSetSpecificPart(int nPart, object oPC, int nIdx, object oModel = OBJECT_SELF) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);

        int nCur = nIdx - 1;
        int nGender = GetGender(oPC);
        int nRace = GetRacialType(oPC);
        int bEx = tlrGetAllowSpecial(oModel);
        int nNewApp = tlrGetNextPartno(nCur, nPart, nGender, nRace, bEx, tlrGetAllowedAC(oModel),FALSE);

        object oNewItem = tlrMakeNewItemAppearance(oItem, nPart, nNewApp);

        tlrDebug("New Appearance: " + IntToString(nNewApp) + " for part " + IntToString(nPart), oPC);

        AssignCommand(oModel, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
        return nNewApp;
}

int tlrFromOtherSide(int nPart) {

        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        int nOtherPart = tlrGetOppositePart(nPart);
        if (nPart == nOtherPart)
                return nPart;

        int nNewApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nOtherPart);
        object oNewItem = tlrMakeNewItemAppearance(oItem, nOtherPart, nNewApp);
        //DelayCommand(0.5, AssignCommand(OBJECT_SELF, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST)));
        AssignCommand(OBJECT_SELF, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
        return nNewApp;
}
void tlrToOtherSide(int nPart) {

        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        int nOtherPart = tlrGetOppositePart(nPart);
        if (nPart == nOtherPart)
                return;

        int nNewApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart);
        object oNewItem = tlrMakeNewItemAppearance(oItem, nOtherPart, nNewApp);
        //DelayCommand(0.5, AssignCommand(OBJECT_SELF, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST)));
        AssignCommand(OBJECT_SELF, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
}

void tlrRemovePart(int nPart) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        int nNewApp = 0; // Use part 0

        object oNewItem = tlrMakeNewItemAppearance(oItem, nPart, nNewApp);
        //DelayCommand(0.5, AssignCommand(OBJECT_SELF, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST)));
        AssignCommand(OBJECT_SELF, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
}

void tlrRotateModel(int bCounter = FALSE) {

        float fNewFace = GetFacing(OBJECT_SELF);

        if (bCounter) {
                fNewFace += 30.0;
               if (fNewFace > 360.0) fNewFace -= 360.0;
        } else {
               fNewFace -= 30.0;
               if (fNewFace < 0.0) fNewFace += 360.0;
        }

        AssignCommand(OBJECT_SELF, SetFacing(fNewFace));
}

void tlrRemoveArms() {

        int nNewApp = 0;
        object oSource = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);

        // Right side
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_RSHOULDER, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_RBICEP, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_RFOREARM, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_RHAND, nNewApp);
         // Left Side
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_LSHOULDER, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_LBICEP, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_LFOREARM, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_LHAND, nNewApp);

        AssignCommand(OBJECT_SELF, ActionEquipItem(oSource, INVENTORY_SLOT_CHEST));
}
void tlrRemoveLegs() {

        int nNewApp = 0;
        object oSource = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);

        // oSource gets marked for delete in the first call to make new item
        // Right side
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_RTHIGH, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_RSHIN, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_RFOOT, nNewApp);
        // Left Side
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_LTHIGH, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_LSHIN, nNewApp);
        oSource = tlrMakeNewItemAppearance(oSource, ITEM_APPR_ARMOR_MODEL_LFOOT, nNewApp);

        AssignCommand(OBJECT_SELF, ActionEquipItem(oSource, INVENTORY_SLOT_CHEST));
}


// ntype 1 == arms, ntype 2 == Legs, ntype 3 == both.
// Set bLeft to true to copy left to right . otherwise does right to left.
void tlrSymmCopy(int nType, int bLeft = FALSE, object oModel = OBJECT_SELF) {

        int nNewApp;  //-- read from parts
        object oNew, oCurrent; //-- items we'll iterate through
        object oSource = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
        int nSrc, nDest;

    //-- step zero: create a duplicate to start modifying.
        //oNew = CopyItem(oSource, OBJECT_SELF);

        //This causes oSource to be deleted on the first call to  tlrMakeNewItemAppearance
        // Bit won't take effect until the script ends so all the getitemappearancs should be
        // fine. Could instead use oCurrent in all those calls.
        oCurrent = oSource;

    //-- step one: copy arms
        if (nType == 1 || nType == 3) {
        //--A: get #s from one side to the other

                // Shoulder
                if (bLeft) {
                        nSrc = ITEM_APPR_ARMOR_MODEL_LSHOULDER; nDest =  ITEM_APPR_ARMOR_MODEL_RSHOULDER;
                } else {
                        nSrc = ITEM_APPR_ARMOR_MODEL_RSHOULDER; nDest =  ITEM_APPR_ARMOR_MODEL_LSHOULDER;
                }
                nNewApp = GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_MODEL, nSrc);
                oCurrent = tlrMakeNewItemAppearance(oCurrent, nDest, nNewApp);

                // Bicep
                if (bLeft) {
                        nSrc = ITEM_APPR_ARMOR_MODEL_LBICEP; nDest =  ITEM_APPR_ARMOR_MODEL_RBICEP;
                } else {
                        nSrc = ITEM_APPR_ARMOR_MODEL_RBICEP; nDest =  ITEM_APPR_ARMOR_MODEL_LBICEP;
                }
                nNewApp = GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_MODEL, nSrc);
                oCurrent = tlrMakeNewItemAppearance(oCurrent, nDest, nNewApp);

               // Forearm
                if (bLeft) {
                        nSrc = ITEM_APPR_ARMOR_MODEL_LFOREARM; nDest =  ITEM_APPR_ARMOR_MODEL_RFOREARM;
                } else {
                        nSrc = ITEM_APPR_ARMOR_MODEL_RFOREARM; nDest =  ITEM_APPR_ARMOR_MODEL_LFOREARM;
                }
                nNewApp = GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_MODEL, nSrc);
                oCurrent = tlrMakeNewItemAppearance(oCurrent, nDest, nNewApp);

                //  Hand
                if (bLeft) {
                        nSrc = ITEM_APPR_ARMOR_MODEL_LHAND; nDest =  ITEM_APPR_ARMOR_MODEL_RHAND;
                } else {
                        nSrc = ITEM_APPR_ARMOR_MODEL_RHAND; nDest =  ITEM_APPR_ARMOR_MODEL_LHAND;
                }
                nNewApp = GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_MODEL, nSrc);
                oCurrent = tlrMakeNewItemAppearance(oCurrent, nDest, nNewApp);

        }  //-- end ARMS copying


        if (nType == 2 || nType == 3) {
       //-- same thing, for leg parts
                // Thigh
                if (bLeft) {
                        nSrc = ITEM_APPR_ARMOR_MODEL_LTHIGH; nDest =  ITEM_APPR_ARMOR_MODEL_RTHIGH;
                } else {
                        nSrc = ITEM_APPR_ARMOR_MODEL_RTHIGH; nDest =  ITEM_APPR_ARMOR_MODEL_LTHIGH;
                }
                nNewApp = GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_MODEL, nSrc);
                oCurrent = tlrMakeNewItemAppearance(oCurrent, nDest, nNewApp);

                // Shin
                if (bLeft) {
                        nSrc = ITEM_APPR_ARMOR_MODEL_LSHIN; nDest =  ITEM_APPR_ARMOR_MODEL_RSHIN;
                } else {
                        nSrc = ITEM_APPR_ARMOR_MODEL_RSHIN; nDest =  ITEM_APPR_ARMOR_MODEL_LSHIN;
                }
                // Foot
                if (bLeft) {
                        nSrc = ITEM_APPR_ARMOR_MODEL_LFOOT; nDest =  ITEM_APPR_ARMOR_MODEL_RFOOT;
                } else {
                        nSrc = ITEM_APPR_ARMOR_MODEL_RFOOT; nDest =  ITEM_APPR_ARMOR_MODEL_LFOOT;
                }
                nNewApp = GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_MODEL, nSrc);
                oCurrent = tlrMakeNewItemAppearance(oCurrent, nDest, nNewApp);
        }  //-- end LEGS

        //-- step last: destroy the original clothing, and put on the new
        //DestroyObject(oSource);

        AssignCommand(OBJECT_SELF, ActionEquipItem(oCurrent, INVENTORY_SLOT_CHEST));
}

int tlrGet2DAAC(int nPart, int nIdx) {

    string sAC = GetCachedACBonus( tlrGet2DAFile(nPart), nIdx);
    return StringToInt(sAC);
}

int CompareAC(object oFirst, object oSecond) {
    int iFirstApp = GetItemAppearance(oFirst, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);
    int iSecondApp = GetItemAppearance(oSecond, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);

    string sFirstAC = GetCachedACBonus("parts_chest", iFirstApp);
    string sSecondAC = GetCachedACBonus("parts_chest", iSecondApp);

    return (StringToInt(sFirstAC) == StringToInt(sSecondAC));
}


// This should not be needed if we only allow this if PC copies to model first.
object CopyItemAppearace(object oSource, object oTarget = OBJECT_SELF) {
        object oChest = GetObjectByTag("ClothingBuilder");
        object oCurrent;

        // Make a copy since we aren't destroying oSource
        oCurrent = CopyItem(oSource, oTarget, TRUE);

        // Not sure this is needed - the above copy should do the trick.

////// Copy Colors
        int nChannel;
        for (nChannel = 0; nChannel <= ITEM_APPR_ARMOR_COLOR_METAL2; nChannel ++) {
                oCurrent = tlrMakeNewItemColor(oCurrent, nChannel,  GetItemAppearance(oSource,ITEM_APPR_TYPE_ARMOR_COLOR,nChannel));
        }
////// Copy Design
        int nPart;
        for (nPart == 0 ; nPart <=ITEM_APPR_ARMOR_MODEL_ROBE ; nPart ++ ) {
                oCurrent = tlrMakeNewItemAppearance(oCurrent, nPart,  GetItemAppearance(oSource,ITEM_APPR_TYPE_ARMOR_MODEL,nPart));
        }
        return oCurrent;
}

int tlrDoCopyItemToPC(object oPC, object oModel = OBJECT_SELF) {
        object oNPCItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);
        object oPCItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);

    //int iCost = GetGoldPieceValue(oNPCItem) + FloatToInt(IntToFloat(GetGoldPieceValue(oPCItem)) * 0.2f);
        int nCost = GetLocalInt(OBJECT_SELF, "TLR_CURRENTPRICE");

        if (GetGold(oPC) < nCost) {
                //SendMessageToPC(oPC, "This outfit costs" + IntToString(nCost) + " gold to copy!");
                return FALSE;
        }

        if (!CompareAC(oNPCItem, oPCItem)) {
                SendMessageToPC(oPC, "You may only copy the appearance of items with the same base AC value.");
                return FALSE;
        }

        TakeGoldFromCreature(nCost, oPC, TRUE);

    // Copy the appearance
        object oNew = CopyItemAppearace(oNPCItem, oPCItem);
        SetLocalInt(oNew, "mil_EditingItem", TRUE);

    // Copy the armor back to the PC
        object oOnPC = CopyItem(oNew, oPC, TRUE);
        SetDescription(oOnPC, GetDescription(oNew));
        DestroyObject(oNew);

    // Equip the armor
        DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oOnPC, INVENTORY_SLOT_CHEST)));

    // Set armor editable again
        DelayCommand(3.0, DeleteLocalInt(oOnPC, "mil_EditingItem"));

        return TRUE;
}


void tlrCopyToModel(object oPC, object oModel = OBJECT_SELF) {
        object oSource = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);

        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);

        object oNew = CopyItem(oSource, oModel, TRUE);
        SetDescription(oNew, GetDescription(oSource));

        // Get AC of current item and set that as TLR_COPIED_AC.
        int nAC = GetItemACBase(oNew);
        SetLocalInt(oModel, "TLR_COPIED_AC", nAC);

        DestroyObject(oItem);
        DelayCommand(0.2, AssignCommand(oModel, ActionEquipItem(oNew, INVENTORY_SLOT_CHEST)));
        SetLocalInt(oPC, "TLR_DID_PCITEM", TRUE);

}

int tlrGetNextColor(int nCur, int nChannel, int bRow, int bDec) {

        int nAmt = 1;
        if (bRow) {
                nAmt = 16;
        }

        if (bDec) {
                nCur -= nAmt;
                if (nCur < 0)
                        nCur += 176;

        } else {
                nCur += nAmt;
                if (nCur > 175)
                        nCur -= 176;
        }

        return nCur;
}


int tlrIncrementColor(int nChannel, int bRow = FALSE, int bDec = FALSE, object oModel = OBJECT_SELF) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);
        int nCur = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nChannel);
        tlrDebug("Increment color current = " + IntToString(nCur));
        int nNewApp = tlrGetNextColor(nCur, nChannel, bRow, bDec);

        object oNewItem = tlrMakeNewItemColor(oItem, nChannel, nNewApp);

        AssignCommand(oModel, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
        return nNewApp;
}

int tlrSetSpecificColor(int nChannel, int nIdx, object oModel = OBJECT_SELF) {
        object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oModel);

        // Bit of a hack but it uses all the same validation code - decrement what we're asked for
        // Then increment it back to get the actual color
        int nCur = tlrGetNextColor(nIdx, nChannel, FALSE, TRUE);
        tlrDebug("Set color current = " + IntToString(nCur));

        int nNewApp = tlrGetNextColor(nCur, nChannel, FALSE, FALSE);

        object oNewItem = tlrMakeNewItemColor(oItem, nChannel, nNewApp);

        AssignCommand(oModel, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
        return nNewApp;
}

        //-- MILAMBUS' COLOUR CODES: do not touch anything below this line--------------------------------

// Returns the name of a color given is index.
string ClothColor(int iColor) {
    switch (iColor) {
        case 00: return "Lightest Tan/Brown";
        case 01: return "Light Tan/Brown";
        case 02: return "Dark Tan/Brown";
        case 03: return "Darkest Tan/Brown";

        case 04: return "Lightest Tan/Red";
        case 05: return "Light Tan/Red";
        case 06: return "Dark Tan/Red";
        case 07: return "Darkest Tan/Red";

        case 08: return "Lightest Tan/Yellow";
        case 09: return "Light Tan/Yellow";
        case 10: return "Dark Tan/Yellow";
        case 11: return "Darkest Tan/Yellow";

        case 12: return "Lightest Tan/Grey";
        case 13: return "Light Tan/Grey";
        case 14: return "Dark Tan/Grey";
        case 15: return "Darkest Tan/Grey";

        case 16: return "Lightest Olive";
        case 17: return "Light Olive";
        case 18: return "Dark Olive";
        case 19: return "Darkest Olive";

        case 20: return "White";
        case 21: return "Light Grey";
        case 22: return "Dark Grey";
        case 23: return "Charcoal";

        case 24: return "Light Blue";
        case 25: return "Dark Blue";

        case 26: return "Light Aqua";
        case 27: return "Dark Aqua";

        case 28: return "Light Teal";
        case 29: return "Dark Teal";

        case 30: return "Light Green";
        case 31: return "Dark Green";

        case 32: return "Light Yellow";
        case 33: return "Dark Yellow";

        case 34: return "Light Orange";
        case 35: return "Dark Orange";

        case 36: return "Light Red";
        case 37: return "Dark Red";

        case 38: return "Light Pink";
        case 39: return "Dark Pink";

        case 40: return "Light Purple";
        case 41: return "Dark Purple";

        case 42: return "Light Violet";
        case 43: return "Dark Violet";

        case 44: return "Shiny White";
        case 45: return "Shiny Black";

        case 46: return "Shiny Blue";
        case 47: return "Shiny Aqua";

        case 48: return "Shiny Teal";
        case 49: return "Shiny Green";

        case 50: return "Shiny Yellow";
        case 51: return "Shiny Orange";

        case 52: return "Shiny Red";
        case 53: return "Shiny Pink";

        case 54: return "Shiny Purple";
        case 55: return "Shiny Violet";

        case 56: return "Silver";
        case 57: return "Obsidian";
        case 58: return "Gold";
        case 59: return "Copper";
        case 60: return "Grey";
        case 61: return "Mirror";
        case 62: return "Pure White";
        case 63: return "Pure Black";
    }

    return "";
}

// Returns the name of a color given is index.
string MetalColor(int iColor) {
    switch (iColor) {
        case 00: return "Lightest Shiny Silver";
        case 01: return "Light Shiny Silver";
        case 02: return "Dark Shiny Obsidian";
        case 03: return "Darkest Shiny Obsidian";

        case 04: return "Lightest Dull Silver";
        case 05: return "Light Dull Silver";
        case 06: return "Dark Dull Obsidian";
        case 07: return "Darkest Dull Obsidian";

        case 08: return "Lightest Gold";
        case 09: return "Light Gold";
        case 10: return "Dark Gold";
        case 11: return "Darkest Gold";

        case 12: return "Lightest Celestial Gold";
        case 13: return "Light Celestial Gold";
        case 14: return "Dark Celestial Gold";
        case 15: return "Darkest Celestial Gold";

        case 16: return "Lightest Copper";
        case 17: return "Light Copper";
        case 18: return "Dark Copper";
        case 19: return "Darkest Copper";

        case 20: return "Lightest Brass";
        case 21: return "Light Brass";
        case 22: return "Dark Brass";
        case 23: return "Darkest Brass";

        case 24: return "Light Red";
        case 25: return "Dark Red";
        case 26: return "Light Dull Red";
        case 27: return "Dark Dull Red";

        case 28: return "Light Purple";
        case 29: return "Dark Purple";
        case 30: return "Light Dull Purple";
        case 31: return "Dark Dull Purple";

        case 32: return "Light Blue";
        case 33: return "Dark Blue";
        case 34: return "Light Dull Blue";
        case 35: return "Dark Dull Blue";

        case 36: return "Light Teal";
        case 37: return "Dark Teal";
        case 38: return "Light Dull Teal";
        case 39: return "Dark Dull Teal";

        case 40: return "Light Green";
        case 41: return "Dark Green";
        case 42: return "Light Dull Green";
        case 43: return "Dark Dull Green";

        case 44: return "Light Olive";
        case 45: return "Dark Olive";
        case 46: return "Light Dull Olive";
        case 47: return "Dark Dull Olive";

        case 48: return "Light Prismatic";
        case 49: return "Dark Prismatic";

        case 50: return "Lightest Rust";
        case 51: return "Light Rust";
        case 52: return "Dark Rust";
        case 53: return "Darkest Rust";

        case 54: return "Light Aged Metal";
        case 55: return "Dark Aged Metal";

        case 56: return "Silver";
        case 57: return "Obsidian";
        case 58: return "Gold";
        case 59: return "Copper";
        case 60: return "Grey";
        case 61: return "Mirror";
        case 62: return "Pure White";
        case 63: return "Pure Black";
    }

    return "";
}

// void main() {}
