void main()
{


    string sConv      = GetLocalString(OBJECT_SELF,"conversation");


object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

//ActionStartConversation(oPC, "tt_orderfood");
ActionStartConversation(oPC, sConv, FALSE);

}
