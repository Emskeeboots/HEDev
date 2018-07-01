





#include "nw_i0_tool"
void main()
{

object oPC = GetLastUsedBy();

//if (!GetIsPC(oPC)) return;

RewardPartyXP(10, oPC, FALSE);

CreateItemOnObject("tt_campanula", oPC);

object oTarget;
oTarget = OBJECT_SELF;

DestroyObject(oTarget, 0.0);

SendMessageToPC(oPC, "The flower instantly turns to a purple crystal while the rest withers and disappear in the wind.");

}

