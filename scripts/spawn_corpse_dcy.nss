//
// NESS V8.0
// Spawn: Corpse Decay Script
//
//
//   Do NOT Modify this File
//   See 'spawn__readme' for Instructions
//
//:: Modified: The Magus (2012 nov 4) prevent decay of UNIQUE NPCs
//:: Modified: henesua (2016 jul 7) integration with PC corpse as well

#include "spawn_functions"
#include "_inc_corpse"

/*
void main()
{
    object oHostBody = OBJECT_SELF;
    object oLootCorpse = GetLocalObject(oHostBody, "Corpse");
    object oItem;
    float fCorpseDecay;

    // Don't Decay while Someone is Looting
    if (GetIsOpen(oLootCorpse) == TRUE)
    {
        // try again
        fCorpseDecay = GetLocalFloat(oHostBody, "CorpseDecay");
        DelayCommand(fCorpseDecay, ExecuteScript("spawn_corpse_dcy", oHostBody));
        return;
    }

    // Don't Decay if not Empty and Timer not Expired
    oItem = GetFirstItemInInventory(oLootCorpse);
    int nDecayTimerExpired = GetLocalInt(oHostBody, "DecayTimerExpired");

    // Don't think this should ever happen, since nDecayTimerExpired should
    // be set to try by the command immediately beforethe one invoking this
    // script!
    if (oItem != OBJECT_INVALID && nDecayTimerExpired == FALSE)
    {
        fCorpseDecay = GetLocalFloat(oHostBody, "CorpseDecay");
        DelayCommand(fCorpseDecay  - 0.1, SetLocalInt(oHostBody, "DecayTimerExpired", TRUE));
        DelayCommand(fCorpseDecay, ExecuteScript("spawn_corpse_dcy", oHostBody));
        return;
    }

    int bDeleteLootOnDecay = GetLocalInt(oHostBody, "CorpseDeleteLootOnDecay");

    // To avoid potential memory leaks, we clean everything that might be left on the
    // original creatures body
    NESS_CleanCorpse(oHostBody);

    // Destroy all loot if indicated (R7 subflag)
    if (bDeleteLootOnDecay)
    {
        NESS_CleanInventory(oLootCorpse);
    }

    // Destroy the invis corpse and drop a loot bag (if any loot left)
    SetPlotFlag(oLootCorpse, FALSE);
    DestroyObject(oLootCorpse);

    // Destroy the visible corpse
    SetObjectIsDestroyable(oHostBody, TRUE, FALSE, FALSE);
    DestroyObject(oHostBody, 0.2);
}
*/



void main()
{
    object oHostBody    = OBJECT_SELF;
    object oLootCorpse  = GetLocalObject(oHostBody, "CORPSE_NODE");


    corpseDebug("spawn_corpse_dcy called for '" + GetName(oLootCorpse) + "' decay = " 
        + IntToString(GetLocalInt(oLootCorpse, "CORPSE_DECAY")));
    if(!GetLocalInt(oLootCorpse,"CORPSE_DECAY"))
        return; // we've cancelled the corpse decay

    corpseDebug("spawn_corpse_dcy open = " + IntToString(GetIsOpen(oLootCorpse)) 
    	    + "in_use_by = " + GetLocalString(oLootCorpse,"IN_USE_BY"));
    // Don't Decay while Someone is Looting or messing with the corpse
    if(     GetIsOpen(oLootCorpse)
        ||  GetLocalString(oLootCorpse,"IN_USE_BY")!=""
      )
    {
        // try again
        DelayCommand(   GetLocalFloat(oHostBody, "CorpseDecay"),
                        ExecuteScript("spawn_corpse_dcy", oHostBody)
                    );
        return;
    }

    // Don't Decay if Timer not Expired
    //object oItem = GetFirstItemInInventory(oLootCorpse);
    int nDecayTimerExpired = GetLocalInt(oHostBody, "DecayTimerExpired");

    // Don't think this should ever happen, since nDecayTimerExpired should
    // be set to try by the command immediately beforethe one invoking this
    // script!
    if (    //oItem != OBJECT_INVALID &&
            nDecayTimerExpired == FALSE
        )
    {
        float fCorpseDecay = GetLocalFloat(oHostBody, "CorpseDecay");
        DelayCommand(fCorpseDecay  - 0.1, SetLocalInt(oHostBody, "DecayTimerExpired", TRUE));
        DelayCommand(fCorpseDecay, ExecuteScript("spawn_corpse_dcy", oHostBody));
        return;
    }

    // handle garbage collection for the persistent inventory
    string pcid = GetLocalString(oLootCorpse,"CORPSE_PCID"); 
    int corpse_type     = GetLocalInt(oLootCorpse,"CORPSE");
    corpseDebug("spawn_corpse_dcy pcid = " + pcid + " corpse_type= " + IntToString(corpse_type)); 

    if (corpse_type & CORPSE_TYPE_PERSISTENT) {
	    // If were here we're doing corpse decay so we need to clean up the corpse or we leave a loot bag.
	    DestroyCorpse(pcid, TRUE);
    } else { 
	    int bDeleteLootOnDecay = GetLocalInt(oHostBody, "CorpseDeleteLootOnDecay");
	    
            //SendMessageToPC(GetFirstPC(), "DEBUG: spawn_corpse_dcy " + GetResRef(oHostBody) 
            //    +  " corpse = " + GetResRef(oLootCorpse) + " deleteloot = " + IntToString(bDeleteLootOnDecay));
	    // To avoid potential memory leaks, we clean everything that might be left on the
	    // original creatures body
	    NESS_CleanCorpse(oHostBody);
	    
	    // Destroy all loot if indicated (R7 subflag)
	    if (bDeleteLootOnDecay)
	    {
		    NESS_CleanInventory(oLootCorpse);
	    }
	    
	    // Destroy the invis corpse and drop a loot bag (if any loot left)
	    SetPlotFlag(oLootCorpse, FALSE);
	    DestroyObject(oLootCorpse);
	    
	    // Destroy the visible corpse
	    SetObjectIsDestroyable(oHostBody, TRUE, FALSE, FALSE);
	    DestroyObject(oHostBody, 0.2);
	    
    }

}
