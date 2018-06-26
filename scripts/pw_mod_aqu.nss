// pw_mod_aqu
// Export character on acquire/unacquire to prevent a server crash exploit.
// Relies on SetUserDefinedItemEventNumber()

#include "_inc_pw"
#include "x2_inc_switches"

void main() {
	if (GetLocalInt(GetModule(), "DEVELOPMENT")) 
		return;

	object oModule = OBJECT_SELF;
	int nEvent = GetUserDefinedItemEventNumber();

	// Export the character on every acquire - seems extreme
	//server crash exploit fixing
	object oPC;
	if (nEvent == X2_ITEM_EVENT_ACQUIRE) {
		oPC = GetModuleItemAcquiredBy();
                object oItem = GetModuleItemAcquired();
                object oLoser = GetModuleItemAcquiredFrom();
                 
                if (!GetIsPC(oPC)) 
                        return;

                // Not using his vault (and not a crafting material?)
                // This relies on the vault saving on close/open. 
                // Shadoow says that's still exploitable but of course 
                // does not provide any detail...
                if (!GetLocalInt(oLoser, "Vault") ) {
                        //&& GetStringLeft(sRes, 13) != "ele_material_"
                        //&& GetStringLeft(sRes, 13) != "fey_material_"
                        pwForceDelayedSave(oPC);
                }   

                // Acquired from another PC save that PC - although shouldn't unacquire do that?
                if (!GetIsPC(oLoser)) {
                        pwForceDelayedSave(oLoser);
                } 

                /*  Pick pocket prevention - all these types and heavy items
                if(GetLocalInt(GetModule(),"PickPocketFix")==1) {
        // This will keep the listed item types from being pickpocketable.
                        if ((GetBaseItemType(oItem)== (BASE_ITEM_ARMOR||BASE_ITEM_BASTARDSWORD||
                                BASE_ITEM_BATTLEAXE||BASE_ITEM_BOOTS||BASE_ITEM_DIREMACE||BASE_ITEM_DOUBLEAXE||
                                BASE_ITEM_DWARVENWARAXE||BASE_ITEM_GREATAXE||BASE_ITEM_GREATSWORD||BASE_ITEM_HALBERD||
                                BASE_ITEM_HEAVYCROSSBOW||BASE_ITEM_HEAVYFLAIL||BASE_ITEM_HELMET||BASE_ITEM_KATANA||
                                BASE_ITEM_LARGESHIELD||BASE_ITEM_LIGHTCROSSBOW||BASE_ITEM_LONGBOW||BASE_ITEM_LONGSWORD||
                                BASE_ITEM_MAGICSTAFF||BASE_ITEM_QUARTERSTAFF||BASE_ITEM_RAPIER||BASE_ITEM_SCYTHE||
                                BASE_ITEM_SHORTBOW||BASE_ITEM_SMALLSHIELD||BASE_ITEM_TOWERSHIELD||BASE_ITEM_TWOBLADEDSWORD||
                                BASE_ITEM_WARHAMMER))||(GetWeight(oItem)>=3)) {
                                        SetPickpocketableFlag(oItem, FALSE);
                        }
                }
                */
                /* vg marked items owned by PCs for store clean up help
                if(GetIsObjectValid(oItem)) {
                        SetLocalInt(oItem, "PCItem", 1);
                }
                */




        } else if (nEvent == X2_ITEM_EVENT_UNACQUIRE) {
		oPC = GetModuleItemLostBy();
                object oItem = GetModuleItemLost();

                if (!GetIsPC(oPC)) 
                        return;
                
                int nItType = GetBaseItemType(oItem);
                if (nItType != BASE_ITEM_POTIONS
                        && nItType != BASE_ITEM_ENCHANTED_POTION 
                        && (!GetIsObjectValid(oItem)
                                || GetIsObjectValid(GetArea(oItem))
                                || GetIsObjectValid(GetItemPossessor(oItem)))) 
                {
                        pwForceDelayedSave(oPC);
                }

        }

	// If not vaild GetIsPC will return FALSE
	//if(GetIsPC(oPC) && GetLocalInt(oModule,ObjectToString(oPC))) {
                //SendMessageToPC(oPC, "Acquire/unacquire  exporting character " + GetName(oPC));
                //WriteTimestampedLogEntry("Acquire/unacquire  exporting character " + GetName(oPC));
	//	ExportSingleCharacter(oPC);
	//}

}
