// _inc_corpse.nss
// Corpse handling routines.
// Modifed by meaglyn to handle non-persistent corpses more simply.  
// See spawn_corpse_dth and spawn_corpse_dcy. 
// Only PCs and NPCs marked "UNIQUE" are treated as persistent. 

#include "_inc_death"
#include "_inc_data"
#include "tb_inc_util"

// corpse type
const int   CORPSE_TYPE_PERSISTENT  = 2;
const int   CORPSE_TYPE_SKINNABLE   = 4;
const int   CORPSE_TYPE_RAISEABLE   = 8;
const int   CORPSE_TYPE_ANIMATEABLE = 16;
const int   CORPSE_TYPE_PC          = 32;

// CORPSES -----
struct CORPSE
{
    int type;
    string pcid;
    string name;
    string description;
    string body_bones;
    string resref;
    int race;
    int gender;
    int appearance;
    int phenotype;
    int wings;
    int tail;
};
// transfers local vars and loads up the struct - [FILE: _inc_corpse]
struct CORPSE TransferCorpseData(object source, object target);
// module load event for persistent corpses - [FILE: _inc_corpse]
void CorpsesOnLoad();
//Sets corpse flags on corpse (persistent, raisable, animateable, skinnable) - [FILE: _inc_corpse]
int CreatureGetCorpseType(object oCreature);
//Drop corpse item - [FILE: _inc_corpse]
void CorpseItemDropped(object oLoser, object oCorpseItem, location lLoc);
// creates the corpse node where a PC respawns or where the carryable PC corpse is dropped [File: _inc_corpse]
object CreateCorpseNodeFromBody(object oBody, location lDeath, string node_ref="invis_corpse_obj");
// creates the corpse item on the PC picking up the body [File: _inc_corpse]
object CreateCorpseItemFromCorpseNode(object oCorpseNode, object oTaker);
// when all you want to do is make a doppelganger of the corpse's body [File: _inc_corpse]
object GetPrettyBodyFromCorpse(object corpse_object, string corpse_resref, location lBody, string corpse_tag="");
// creates the body to dress up when a PC corpse is on ground   [File: _inc_corpse]
void CreateCorpseFromCorpseNode(object oCorpseNode, location lDeath, int kill=TRUE, int dress=TRUE);
// used by CreateCorpseFromCorpseNode to dress up the body with equipped items   [File: _inc_corpse]
void CorpseDress(object oCorpse, object oCorpseNode, int corpse_equip=TRUE);
// check the PC for corpses, if no longer the "holder", destroy [File: _inc_corpse]
void PCLoginCorpseCheck(object oPC=OBJECT_SELF);
// casting of a raise spell on a corpseNode (plc) or corpseItem (item) [File: _inc_corpse]
// resurrect, raisedead... potentially other types as well
// returns FALSE on failure
int SpellRaiseCorpse(object oCorpse, int spell_id, location loc_raise, object spell_caster=OBJECT_INVALID);
// clear effects and jump the character to their desired location [File: _inc_corpse]
void PrepPCForRespawn(object oPC, location loc_raise);
// final step of raising a corpse from the dead [File: _inc_corpse]
void CharacterRaiseCompletes(location loc_raise, string status);
// corpse garbage collection [File: _inc_corpse]
void DestroyCorpse(string pcid, int strip_corpse=FALSE);
// Get the right location to respawn the PC into the world - based on location of corpse item or plc
location corpseGetRespawnLocation(object oPC);


// CORPSES ---------------------------------------------------------------------
const int CORPSE_DEBUG = TRUE;
void corpseDebug(string sMsg, object oPC = OBJECT_INVALID) {
        if (CORPSE_DEBUG) dbstr(sMsg, oPC);
        //dblvlstr(DEBUGLEVEL_CORPSE, sMsg, oPC);
}


struct CORPSE TransferCorpseData(object source, object target)
{
    struct CORPSE corpse;
    int type  = GetObjectType(source);
    if(type==OBJECT_TYPE_CREATURE)
    {
        corpse.type         = CreatureGetCorpseType(source);
        corpse.pcid         = GetPCID(source);
        corpse.name         = GetName(source);
        corpse.description  = GetDescription(source);
        corpse.body_bones;  // this is set later
        corpse.resref       = GetResRef(source);
        corpse.race         = GetRacialType(source);
        corpse.gender       = GetGender(source);
        corpse.appearance   = GetAppearanceType(source);
        if(     corpse.appearance<=6
            ||( corpse.appearance==474||corpse.appearance==475)
            ||(corpse.appearance>=1281&&corpse.appearance<=1296)
          )
        {
            corpse.phenotype= GetPhenoType(source);
            int nPart;
            for (nPart=0; nPart<=20; nPart++)
            {
                SetLocalInt(    target,
                                "CORPSE_PART"+IntToString(nPart),
                                GetCreatureBodyPart(nPart,source)
                       );
            }
        }
        int nColor;
        for (nColor=0; nColor<=3; nColor++)
        {
            SetLocalInt(    target,
                            "CORPSE_COLOR"+IntToString(nColor),
                            GetColor(source,nColor)
                       );
        }
        corpse.wings        = GetCreatureWingType(source);
        corpse.tail         = GetCreatureTailType(source);
    }
    else
    {
        corpse.type         = GetLocalInt(source,   "CORPSE");
        corpse.pcid         = GetLocalString(source,"CORPSE_PCID");
        corpse.name         = GetLocalString(source,"CORPSE_NAME");
        corpse.description  = GetLocalString(source,"CORPSE_DESCRIPTION");
        corpse.body_bones   = GetLocalString(source,"CORPSE_BONES");
        corpse.resref       = GetLocalString(source,"CORPSE_BODY_RESREF");
        corpse.race         = GetLocalInt(source,   "CORPSE_RACE");
        corpse.gender       = GetLocalInt(source,   "CORPSE_GENDER");
        corpse.appearance   = GetLocalInt(source,   "CORPSE_APPEARANCE");
        if(     corpse.appearance<=6
            ||( corpse.appearance==474||corpse.appearance==475)
            ||(corpse.appearance>=1281&&corpse.appearance<=1296)
          )
        {
            corpse.phenotype= GetPhenoType(source);
            int nPart;
            for (nPart=0; nPart<=20; nPart++)
            {
                SetLocalInt(    target,
                                "CORPSE_PART"+IntToString(nPart),
                                GetCreatureBodyPart(nPart,source)
                       );
            }
        }
        int nColor;
        for (nColor=0; nColor<=3; nColor++)
        {
            SetLocalInt(    target,
                            "CORPSE_COLOR"+IntToString(nColor),
                            GetColor(source,nColor)
                       );
        }
        corpse.wings        = GetLocalInt(source, "CORPSE_WINGS");
        corpse.tail         = GetLocalInt(source, "CORPSE_TAIL");
    }

    // store struct values on target
    SetLocalInt(target,     "CORPSE",               corpse.type);
    SetLocalString(target,  "CORPSE_PCID",          corpse.pcid );
    SetLocalString(target,  "CORPSE_NAME",          corpse.name );
    SetLocalString(target,  "CORPSE_DESCRIPTION",   corpse.description);
    SetLocalString(target,  "CORPSE_NODE_RESREF",   GetLocalString(source,"CORPSE_NODE_RESREF"));
    SetLocalString(target,  "CORPSE_BONES",         corpse.body_bones);
    SetLocalString(target,  "CORPSE_BODY_RESREF",   corpse.resref);
    SetLocalInt(target,     "CORPSE_RACE",          corpse.race );
    SetLocalInt(target,     "CORPSE_GENDER",        corpse.gender);
    SetLocalInt(target,     "CORPSE_APPEARANCE",    corpse.appearance);

    // these are only local variables since we don't reference them any other way
    SetLocalInt(target,"CORPSE_DECAY", GetLocalInt(source,"CORPSE_DECAY") );
    SetLocalFloat(target,"CorpseDecay", GetLocalFloat(source,"CorpseDecay") );
    // skinning variables
    SetLocalString(target,"CORPSE_BONES",GetLocalString(source,"CORPSE_BONES"));;
    if( corpse.type & CORPSE_TYPE_SKINNABLE )
    {
        // probably need a separate function for transferring skin and meat variables
        SetLocalString(target,"SKIN_TYPE",GetLocalString(source, "SKIN_TYPE"));
        SetLocalInt(target,"SKINNED",GetLocalInt(source, "SKINNED"));
        SetLocalString(target,"SKIN_NAME",GetLocalString(source, "SKIN_NAME"));
        SetLocalString(target,"SKIN_TAG",GetLocalString(source, "SKIN_TAG"));
        //SetLocalInt(target,"SKIN_DAMAGE",GetLocalInt(source, "SKIN_DAMAGE"));
        //SetLocalInt(target,"SKIN_MAXHP",GetLocalInt(source, "SKIN_MAXHP"));
        SetLocalInt(target,"SKIN_MEAT",GetLocalInt(source, "SKIN_MEAT"));
        SetLocalString(target,"SKIN_MEAT_TAG",GetLocalString(source, "SKIN_MEAT_TAG"));
        SetLocalString(target,"SKIN_MEAT_NAME",GetLocalString(source, "SKIN_MEAT_NAME"));
    }

    return corpse;
}

void CorpsesOnLoad()
{
    location location_corpse_store  = GetLocation(GetWaypointByTag("wp_corpse_store"));
    // the corpse store is a persistent storage of all persistent corpses

     // Now it's a creature so it will work with nwnxee.  
    //object corpse_store = Data_RetrieveCampaignObject("corpse_storage", location_corpse_store, OBJECT_INVALID, OBJECT_INVALID, "0", OBJECT_TYPE_STORE);
    object corpse_store = GetPersistentObjectLoc(GetModule(), "corpse_storage", location_corpse_store, OBJECT_INVALID, "0");
    WriteTimestampedLogEntry("CORPSES onload : Retrieving store("+GetName(corpse_store)+")");
    if(!GetIsObjectValid(corpse_store))
    {
         corpse_store = CreateObject(OBJECT_TYPE_CREATURE, "inventory", location_corpse_store, FALSE, "corpse_storage");
         SetName(corpse_store, "Persistent Corpse Storage");
         WriteTimestampedLogEntry("CORPSES onload : Made a store("+GetName(corpse_store)+")");
    }
    
    // use the corpse store's inventory as a list of all the active corpses
    // iterate over them
    // any persistent corpses which are not
    location where; string pcid;
    object corpse_node;
    object corpse       = GetFirstItemInInventory(corpse_store);
    while(GetIsObjectValid(corpse))
    {
        // is this a persistent corpse?
        if(GetLocalInt(corpse,"CORPSE")&CORPSE_TYPE_PERSISTENT)
        {
            pcid    = GetLocalString(corpse,"CORPSE_PCID");
            // is anyone holding this corpse? (is it in anyone's inventory?)
            int nHolder = StringToInt(Data_GetCampaignString("corpse_holder",OBJECT_INVALID,pcid));
            corpseDebug("CORPSE onload: Got corpse for " + pcid  + " holder = " + IntToString(nHolder));
            if(!nHolder) {
                // since no one is holding the corpse, create it at its last known location
                where       = Data_GetLocation("CORPSE",OBJECT_INVALID,pcid);
                if( GetIsObjectValid(GetAreaFromLocation(where)) )
                {
                    corpse_node = CreateCorpseNodeFromBody(corpse, where);
                    DelayCommand(0.2, CreateCorpseFromCorpseNode( corpse_node, where) );
                }
            }
        }
        else
        {
            // if its not a corpse or not a persistent one... destroy it
            DestroyObject(corpse);
        }

        corpse          = GetNextItemInInventory(corpse_store);
    }
    SetLocalInt(corpse_store, "CORPSE_STORE_DIRTY", TRUE);
}

int CreatureGetCorpseType(object oCreature)
{
    int corpse_type = 1; // this is a corpse
    int racial_type = GetRacialType(oCreature);

    int bPC         = FALSE;
    int bPersist    = FALSE;
    int bRaise      = FALSE;  // not raise-able by default
    int bAnimate    = TRUE;
    int bSkin       = TRUE;

    if(     racial_type==RACIAL_TYPE_ANIMAL
        ||  racial_type==RACIAL_TYPE_BEAST
        ||  racial_type==RACIAL_TYPE_MAGICAL_BEAST
        ||  racial_type==RACIAL_TYPE_DRAGON
        ||  racial_type==RACIAL_TYPE_GIANT
      )
    {
        bAnimate    = FALSE;
    }
    else if(racial_type==RACIAL_TYPE_UNDEAD
        ||  racial_type==RACIAL_TYPE_OUTSIDER
        ||  racial_type==RACIAL_TYPE_OOZE
        ||  racial_type==RACIAL_TYPE_CONSTRUCT
        ||  racial_type==RACIAL_TYPE_ELEMENTAL
        ||  racial_type==RACIAL_TYPE_FEY
        ||  racial_type==RACIAL_TYPE_VERMIN
        ||  racial_type==RACIAL_TYPE_ABERRATION
        ||  racial_type==RACIAL_TYPE_PLANT
      )
    {
        bRaise      = FALSE;
        bAnimate    = FALSE;
        bSkin       = FALSE;
    }

    if(GetIsPC(oCreature))
    {
        bPC         = TRUE;
        bPersist    = TRUE;
        bRaise      = TRUE;
    }
    else if(GetLocalInt(oCreature, "UNIQUE"))
    {
        bPersist    = TRUE;
        bRaise      = TRUE;
    }

    if(bPC)
        corpse_type += CORPSE_TYPE_PC;          // special treatment when respawned
    if(bPersist)
        corpse_type += CORPSE_TYPE_PERSISTENT;  // saved to DB and tracked
    if(bRaise)
        corpse_type += CORPSE_TYPE_RAISEABLE;   // can be raised or resurrected
    if(bAnimate)
        corpse_type += CORPSE_TYPE_ANIMATEABLE; // can be made into undead
    if(bSkin)
        corpse_type += CORPSE_TYPE_SKINNABLE;   // can be skinned

    return corpse_type;
}

void CorpseItemDropped(object oLoser, object oCorpseItem, location lLoc)
{
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectCutsceneGhost(),oLoser,3.0);
    // create a creature to test the location
    object oTmp = CreateObject(OBJECT_TYPE_CREATURE,"invisible",lLoc);
    lLoc    = GetLocation(oTmp);
    DestroyObject(oTmp);

    // tweak the facing
    float fDir  = GetFacing(oLoser)-(90.0+IntToFloat(Random(13)) );
    if(fDir<0.0)
        fDir += 2.0*fDir;
    lLoc    = Location(GetAreaFromLocation(lLoc),GetPositionFromLocation(lLoc),fDir);

    string pcid         = GetLocalString(oCorpseItem,"CORPSE_PCID");
    object oInventory   = GetPersistentInventory("INV_CORPSE_"+pcid, pcid);
    //corpseDebug("Corpse item drop for " + pcid + " inventory = " + GetTag(oInventory));

    int nItemsMoved     = MoveInventory(oCorpseItem,oInventory);
    if(nItemsMoved)
        // let the mule know that it should save itself
        SignalEvent(oInventory, EventUserDefined(EVENT_COMMIT_OBJECT_TO_DB));

    // create corpse
    object oCorpseNode = CreateCorpseNodeFromBody(oCorpseItem, lLoc);
    DelayCommand(0.2, CreateCorpseFromCorpseNode( oCorpseNode, lLoc) );

    DestroyObject(oCorpseItem,0.2);
}

object Corpse_CopyCorpseItem(object oSource, object oInventory)
{
    int bWasPlot = GetPlotFlag(oSource);
    object oNewItem = CopyItem(oSource, oInventory);
    if (bWasPlot == TRUE)
    {
        SetPlotFlag(oNewItem,TRUE);
    }

    return oNewItem;
}

void CorpseCopyInventory(object oVictim, object oCorpse, int bDelete = FALSE) {
	object oLoot    = GetFirstItemInInventory(oVictim);
	while (GetIsObjectValid(oLoot)) {
		object oTmp = Corpse_CopyCorpseItem(oLoot, oCorpse);
		//corpseDebug("corpse copied " + GetTag(oTmp));
		if (bDelete) DestroyObject(oLoot);
		oLoot    = GetNextItemInInventory(oVictim);
	}
}

// This function is used to determine if the victim is the type
// of creature that "wears" its clothing, so we don't strip them
// naked.
int CorpseGetIsVictimDressed(object oVictim)
{
    int nAppearance = GetAppearanceType(oVictim);
    switch (nAppearance) {
    case APPEARANCE_TYPE_DWARF:
    case APPEARANCE_TYPE_ELF:
    case APPEARANCE_TYPE_GNOME:
    case APPEARANCE_TYPE_HALF_ELF:
    case APPEARANCE_TYPE_HALF_ORC:
    case APPEARANCE_TYPE_HALFLING:
    case APPEARANCE_TYPE_HUMAN:
        return TRUE;
    }

    return FALSE;
}

// pulled this from spawn_functions. Only called by this code.
void CorpseTransferAllInventorySlots(object oVictim, object oCorpse, int bDropWielded=FALSE)
{
    int i=0;
    object oDressing = OBJECT_INVALID;
    location locItem;
    float fDir  = GetFacing(oVictim);
    object oLoot;
    for (i=0; i < NUM_INVENTORY_SLOTS; i++)
    {
        oDressing = GetItemInSlot(i, oVictim);

        // See if we're going to allow looting of this item.
        if (GetIsObjectValid(oDressing) && GetDroppableFlag(oDressing))
        {
            // Handle different items slightly differently.

            if(CorpseGetIsVictimDressed(oVictim) 
	       && (i == INVENTORY_SLOT_CHEST ||  i == INVENTORY_SLOT_CLOAK)) {
                // The victim is wearing the armor/cloak. So unless it is looted, leave it visible on the body
                oLoot = Corpse_CopyCorpseItem(oDressing, oCorpse);
                SetLocalObject(oLoot, "PAIRED", oDressing); // track so that we destroy the dressing when it is looted
                //corpseDebug("CorpseTransferAll 1 copies " + GetName(oDressing) + " to plc.");
                SetLocalInt(oLoot,"EQUIPPED_SLOT",i+100);
                SetLocalObject(oCorpse,"CORPSE_LOOT_SLOT_"+IntToString(i),oLoot);
            }

            else if(    i == INVENTORY_SLOT_HEAD
                    ||  i == INVENTORY_SLOT_RIGHTHAND
                    ||  i == INVENTORY_SLOT_LEFTHAND
                   )
            {
                if (bDropWielded)
                {
                  // This is a wielded item. Drop it nearby.
                  if(i == INVENTORY_SLOT_HEAD)
                  {
                    locItem = GenerateNewLocation(  oVictim,
                                                    DISTANCE_TINY,
                                                    GetOppositeDirection(fDir),
                                                    fDir);
                  }
                  else if(i == INVENTORY_SLOT_RIGHTHAND)
                  {
                    locItem  = GenerateNewLocation(  oVictim,
                                                    DISTANCE_TINY,
                                                    GetHalfRightDirection(fDir),
                                                    fDir);
                  }
                  else if(i == INVENTORY_SLOT_LEFTHAND)
                  {
                    locItem = GenerateNewLocation(  oVictim,
                                                    DISTANCE_TINY,
                                                    GetHalfLeftDirection(fDir),
                                                    fDir);
                  }
		  //corpseDebug("CorpseTransferAll drops equipped " + GetName(oDressing));
                // TODO - this only works if there are no variables on items - can be fixed
		  CreateObject(OBJECT_TYPE_ITEM, GetResRef(oDressing), locItem);
		  DestroyObject(oDressing, 0.1);
                }
                else
                {
                    oLoot = Corpse_CopyCorpseItem(oDressing, oCorpse);
                    //corpseDebug("CorpseTransferAll 2 copies " + GetName(oDressing) + " to plc.");
		    //SetName(oLoot, "Copy of " + GetName(oDressing)); 
		    //SetName(oDressing, "Original " + GetName(oDressing));
                    SetLocalObject(oLoot, "PAIRED", oDressing);
                    SetLocalInt(oLoot,"EQUIPPED_SLOT",i+100);
                    SetLocalObject(oCorpse,"CORPSE_LOOT_SLOT_"+IntToString(i),oLoot);
                }
            }
            // all other droppable items are copied to the lootable corpse
            else
            {
                oLoot = Corpse_CopyCorpseItem(oDressing, oCorpse);
                //corpseDebug("CorpseTransferAll 3 copies " + GetName(oDressing) + " to plc.");
                SetLocalInt(oLoot,"EQUIPPED_SLOT",i+100);
                SetLocalObject(oCorpse,"CORPSE_LOOT_SLOT_"+IntToString(i),oLoot);
                DestroyObject(oDressing, 0.1);
            }
        }
    }
}

object CreateCorpseNodeFromBody(object oBody, location lDeath, string node_ref="invis_corpse_obj")
{
    int body_type  = GetObjectType(oBody); 
    int bDropWielded = GetLocalInt(oBody, "CorpseDropWielded");
    // vars we need now
    string corpse_tag, resref;
    string pcid = GetPCID(oBody);
    if(body_type==OBJECT_TYPE_CREATURE)
    {
        corpse_tag  = "CORPSE_"+pcid;
        resref      = node_ref;
        SetLocalString(oBody,"CORPSE_NODE_RESREF", node_ref);
    }
    else
    {
        corpse_tag  = "CORPSE_"+GetLocalString(oBody, "CORPSE_PCID");
        resref      = GetLocalString(oBody, "CORPSE_NODE_RESREF");
    }

    // create the interactive placeable "corpse node" for the corpse
    object oCorpseNode      = CreateObject( OBJECT_TYPE_PLACEABLE, resref, lDeath, FALSE, corpse_tag );
    struct CORPSE corpse    = TransferCorpseData(oBody, oCorpseNode);

    // update persistent corpse data
    if(corpse.type & CORPSE_TYPE_PERSISTENT)
    {
        // TODO - this maybe should get persistent inventory first and check before creating
	if (!corpse.type & CORPSE_TYPE_PC) 
	    CreatePersistentInventory("INV_CORPSE_"+pcid, oBody, pcid, FALSE);
        
            // local variables saved
        object corpse_persistent= GetObjectByTag(corpse_tag+"_PERSISTENT");
	//corpseDebug("createcorpsenode: got persistent '"+ GetTag(corpse_persistent) + "' for " + GetName(oBody));
        if(!GetIsObjectValid(corpse_persistent)) {
            object corpse_store = GetObjectByTag("corpse_storage");
            corpse_persistent   = CreateItemOnObject("corpse_pc",corpse_store,1,corpse_tag+"_PERSISTENT");
            //corpseDebug("createcorpsenode: created " + GetTag(corpse_persistent)); 
            SetName(corpse_persistent, corpse.name);
            SetDescription(corpse_persistent, corpse.description);
        }
        TransferCorpseData(oCorpseNode, corpse_persistent);
        //SetLocalInt(corpse_store, "CORPSE_STORE_DIRTY", TRUE);

        // store the location for the corpse
        Data_SetLocation("CORPSE", lDeath, OBJECT_INVALID, corpse.pcid);
        // no one is holding this corpse in inventory
        Data_SetCampaignString("corpse_holder", "0", OBJECT_INVALID, corpse.pcid); 
	
	SetLocalInt(oCorpseNode,"SUPPRESS_DISTURB",TRUE);   // disturb event unnecessary during init
	DelayCommand(0.1, RetrievePersistentInventory("INV_CORPSE_"+corpse.pcid, oCorpseNode, corpse.pcid));
	DelayCommand(0.2, DeleteLocalInt(oCorpseNode,"SUPPRESS_DISTURB") );     // turn disturb event back on
    } else {
	    // all non persistent corpses - need to copy the inventory from the body to the node
	    CorpseTransferAllInventorySlots(oBody, oCorpseNode,  bDropWielded); 
	    CorpseCopyInventory(oBody, oCorpseNode, TRUE);
    }

    // name
    SetName(oCorpseNode,corpse.name);
    // description
    SetDescription(oCorpseNode,corpse.description);

    //SetLocalInt(oCorpseNode,"SUPPRESS_DISTURB",TRUE);   // disturb event unnecessary during init
    //DelayCommand(0.1, RetrievePersistentInventory("INV_CORPSE_"+corpse.pcid, oCorpseNode, corpse.pcid));
    //DelayCommand(0.2, DeleteLocalInt(oCorpseNode,"SUPPRESS_DISTURB") );     // turn disturb event back on

    return oCorpseNode;
}

object CreateCorpseItemFromCorpseNode(object oCorpseNode, object oTaker)
{
    string corpse_item_resref   = "corpse_pc";
    string corpse_item_tag      = "CORPSE_"+GetLocalString(oCorpseNode,"CORPSE_PCID");

    object oCorpseItem          = CreateItemOnObject(corpse_item_resref,oTaker,1,corpse_item_tag);
    struct CORPSE corpse        = TransferCorpseData(oCorpseNode, oCorpseItem);

    SetName(oCorpseItem, corpse.name);
    SetDescription(oCorpseItem, corpse.description);

    // update persistent corpse data
    if(corpse.type & CORPSE_TYPE_PERSISTENT)
    {
        // local variables saved
        object corpse_persistent= GetObjectByTag(corpse_item_tag+"_PERSISTENT");
        if(!GetIsObjectValid(corpse_persistent))
        {
            object corpse_store = GetObjectByTag("corpse_storage");
            corpse_persistent   = CreateItemOnObject("corpse_pc",corpse_store,1,corpse_item_tag+"_PERSISTENT");
            SetName(corpse_persistent, corpse.name);
            SetDescription(corpse_persistent, corpse.description);
        }
        TransferCorpseData(oCorpseItem, corpse_persistent);

        // store the location for the corpse
        Data_SetLocation("CORPSE", GetLocation(oTaker), OBJECT_INVALID, corpse.pcid);
        // no one is holding this corpse in inventory
        Data_SetCampaignString("corpse_holder", GetPCID(oTaker), OBJECT_INVALID, corpse.pcid);
    }

    // determine how much the corpse should weigh
    int nWeight;
    int nSize   = StringToInt(Get2DAString("appearance","SIZECATEGORY",corpse.appearance));
    switch(nSize)
    {
        case CREATURE_SIZE_TINY:    nWeight=10; break;
        case CREATURE_SIZE_SMALL:   nWeight=500; break;
        case CREATURE_SIZE_MEDIUM:  nWeight=1400; break;
        case CREATURE_SIZE_LARGE:   nWeight=4000; break;
        case CREATURE_SIZE_HUGE:    nWeight=15000; break;
        default:                    nWeight=1350; break;
    }

    if(corpse.phenotype==2)
        nWeight += nWeight;
    if(corpse.body_bones!="")
        nWeight -= FloatToInt(nWeight*(0.90));

    // get equipment weight of equipment
    object oItem    = GetFirstItemInInventory(oCorpseNode);
    while(GetIsObjectValid(oItem))
    {
        nWeight += GetWeight(oItem);
        oItem   = GetNextItemInInventory(oCorpseNode);
    }

    // adjust the weight of the corpseitem
    ItemIncreaseWeight(nWeight, oCorpseItem);

    return oCorpseItem;
}

object GetPrettyBodyFromCorpse(object corpse_object, string corpse_resref, location lBody, string corpse_tag="")
{
    object oBody = CreateObject( OBJECT_TYPE_CREATURE, corpse_resref, lBody, FALSE, corpse_tag);

    // name
    SetName(oBody,GetLocalString(corpse_object,"CORPSE_NAME"));
    SetDescription(oBody,GetLocalString(corpse_object,"CORPSE_DESCRIPTION"));

    // make the corpse look like the PC
    // appearance
    int corpse_appearance = GetLocalInt(corpse_object,"CORPSE_APPEARANCE");
    SetCreatureAppearanceType(oBody, corpse_appearance);
    if(     corpse_appearance<=6
        ||( corpse_appearance==474||corpse_appearance==475)
        ||(corpse_appearance>=1281&&corpse_appearance<=1296)
      )
    {
        // pheno
        SetPhenoType(GetLocalInt(corpse_object,"CORPSE_PHENOTYPE"),oBody);
        // parts
        int nPart;
        for (nPart=0; nPart<=20; nPart++)
        {
            SetCreatureBodyPart(    nPart,
                                    GetLocalInt(corpse_object,"CORPSE_PART"+IntToString(nPart)),
                                    oBody
                               );
        }
    }
    // color
    int nColor;
    for (nColor=0; nColor<=3; nColor++)
    {
        SetColor( oBody, nColor, GetLocalInt(corpse_object,"CORPSE_COLOR"+IntToString(nColor)) );
    }
    // wings
    SetCreatureWingType(GetLocalInt(corpse_object,"CORPSE_WINGS"),oBody);
    // tail
    SetCreatureWingType(GetLocalInt(corpse_object,"CORPSE_TAIL"),oBody);

    return oBody;
}

void CreateCorpseFromCorpseNode(object oCorpseNode, location lDeath, int kill=TRUE, int dress=TRUE)
{
    object oCorpse;
    string corpse_tag           = "CORPSE_BODY_PCID_" + GetLocalString(oCorpseNode,"CORPSE_PCID");
    string corpse_bones         = GetLocalString(oCorpseNode,"CORPSE_BONES");
  if(corpse_bones=="")
  {
    int corpse_gender           = GetLocalInt   (oCorpseNode,"CORPSE_GENDER");

    // dif resref for each gender
    string sRefCorpse   = "corpse_pc";
    if(corpse_gender==GENDER_FEMALE)
        sRefCorpse      = "corpse_pc_f";

    // create the corpse creature
    oCorpse = GetPrettyBodyFromCorpse(oCorpseNode, sRefCorpse, lDeath, corpse_tag);

    //corpseDebug("CreateCorpseFromCorpseNode:  Created corpse " + GetName(oCorpse) + " dress = " + IntToString(dress));
    SetLootable(oCorpse,FALSE);
    AssignCommand(oCorpse, SetIsDestroyable(FALSE,FALSE,FALSE));

    if(dress)
        // dress/equip the corpse with some of the items
        CorpseDress(oCorpse, oCorpseNode);

    if(kill)
        DelayCommand(0.2,
                     AssignCommand(  GetArea(oCorpseNode),
                                     ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDeath(),oCorpse)
                                  )
                    );
  }
  else
  {
    oCorpse = CreateObject( OBJECT_TYPE_PLACEABLE, corpse_bones, lDeath, FALSE, corpse_tag);
  }

    // body and corpse node point to one another
    SetLocalObject(oCorpseNode, "CORPSE_BODY", oCorpse);
    SetLocalObject(oCorpse, "CORPSE_NODE", oCorpseNode);

    if(GetLocalInt(oCorpseNode,"CORPSE_DECAY"))
    {
        float fCorpseDecay  = GetLocalFloat(oCorpseNode,"CorpseDecay");
        SetLocalFloat(oCorpse,"CorpseDecay",fCorpseDecay);
        // Set Corpse to Decay
        DelayCommand(fCorpseDecay + 0.1, SetLocalInt(oCorpse, "DecayTimerExpired", TRUE));
        DelayCommand(fCorpseDecay + 0.3, ExecuteScript("spawn_corpse_dcy", oCorpse));
    }
}

void CorpseDress(object oCorpse, object oCorpseNode, int corpse_equip=TRUE)
{
    object oDressing; int nSlot;
    object oLoot    = GetFirstItemInInventory(oCorpseNode);
    while(GetIsObjectValid(oLoot))
    {
        nSlot   = GetLocalInt(oLoot,"EQUIPPED_SLOT");

        //corpseDebug("CorpseDress - found " + GetName(oLoot) + " equipped slot: " + IntToString(nSlot)); 
        if(nSlot)
        {
            nSlot -= 100;
            if(     nSlot<=6    // head, chest (boots, arms), lhand, rhand, cloak
                &&  nSlot!=2 && nSlot!=3    // not boots or arms
              )
            {
                if(corpse_equip)
                {
                    oDressing  = CopyItem(oLoot, oCorpse); 
                    //corpseDebug("CorpseDress copies " + GetName(oDressing) + " back to body");
                    //SetName(oDressing, "Copy of " + GetName(oLoot)); //DEBUG
                    SetDroppableFlag(oDressing, FALSE); 
                    corpseDebug("CorpseDress assigns equip item  " + GetName(oDressing) + " slot " + IntToString(nSlot));
                    AssignCommand(oCorpse, ActionEquipItem(oDressing, nSlot) );
                    DelayCommand(0.1, AssignCommand(oCorpse, ActionEquipItem(oDressing, nSlot)));
                }
                else
                {
                    oDressing   = GetItemInSlot(nSlot,oCorpse);
                }
                
                SetLocalObject(oLoot,"CORPSE_DRESSING", oDressing);
            }
            else if(!corpse_equip)
            {
                DestroyObject(GetItemInSlot(nSlot,oCorpse));
            }
        }
        oLoot   = GetNextItemInInventory(oCorpseNode);
    }
}


// Attempt to re-equip gear on rezz/raise/return from fugue
// If the corpse was moved or the server reset the gear does not get re-equipped
void CorpseDressPC(object oPC) {
	object oDressing; 
	int nSlot;
	object oLoot = GetFirstItemInInventory(oPC);
	
	//corpseDebug("CorpseDressPC called for " + GetName(oPC));
	while(GetIsObjectValid(oLoot)) {
		nSlot   = GetLocalInt(oLoot,"EQUIPPED_SLOT");
		
		//corpseDebug("CorpseDressPC - found " + GetName(oLoot) + " equipped slot: " + IntToString(nSlot)); 
		if(nSlot) {
			nSlot -= 100;
			if( nSlot<=6   &&  nSlot!=2 && nSlot!=3) {
				//corpseDebug("CorpseDressPC assigns equip item  " + GetName(oLoot) + " slot " + IntToString(nSlot));
				if (GetItemInSlot(nSlot, oPC) != oLoot) {
					AssignCommand(oPC, ActionEquipItem(oLoot, nSlot) );
					//DelayCommand(0.1, AssignCommand(oPC, ActionEquipItem(oLoot, nSlot)));
				}
			}
		}
		oLoot   = GetNextItemInInventory(oPC);
	}
}


void PCLoginCorpseCheck(object oPC=OBJECT_SELF)
{
    // check DB for notification of corpses to delete from inventory
    string pcid = GetPCID(oPC);
    corpseDebug("PCLoginCorpseCheck: called for " + GetName(oPC) + " pcid = " + pcid);

    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem)) {
    // Loop through inventory and find any items with resref == "corpse_pc"
        if (GetResRef(oItem) == "corpse_pc") {
    // If found check database Data_GetCampaignString("corpse_holder",OBJECT_INVALID, GetLocalString(oItem, "CORPSE_PCID"));
    // Compare this holder string to my pcid - if not match then destroy oItem;
		string other_pcid = GetLocalString(oItem, "CORPSE_PCID");
		string holder = Data_GetCampaignString("corpse_holder",OBJECT_INVALID, other_pcid);
		corpseDebug("PCLoginCorpseCheck: found corpse for " + other_pcid + " holder = " + holder);
                if (holder != pcid) {
			corpseDebug("PCLoginCorpseCheck: Destrpyong corpse item.");
			SetPlotFlag(oItem, FALSE);
			DestroyObject(oItem, 0.1);
		}
	}
    	oItem = GetNextItemInInventory(oPC);
    }
}

int SpellRaiseCorpse(object oCorpse, int spell_id, location loc_raise, object spell_caster=OBJECT_INVALID)
{
    int success = FALSE;
    // if this object is a CORPSE of CORPSE_TYPE_RAISEABLE, we will proceed
    // else send a failure response
    int corpse_type = GetLocalInt(oCorpse,"CORPSE");

    //corpseDebug("SpellRaiseCorpse : " + GetName(oCorpse) + " type = " + IntToString(corpse_type));
    if( corpse_type & CORPSE_TYPE_RAISEABLE )
    {
        string pcid =  GetLocalString(oCorpse, "CORPSE_PCID");
        // if this PC is no longer dead... exit
        if(corpse_type & CORPSE_TYPE_PERSISTENT &&  !StringToInt( GetPCDeathStatus(pcid))) {
            // destroy persistent copy
            object corpse_persistent    = GetObjectByTag("CORPSE_"+pcid+"_PERSISTENT");
            DestroyObject(corpse_persistent);

            // wipe connection of corpse to PC... it can no longer be used to raise them (if they die again)
            SetLocalInt(oCorpse,"CORPSE_DECAY",TRUE); // it will decay, when next moved
            SetLocalFloat(oCorpse,"CorpseDecay",60.0);// it will decay, in 60 seconds
            SetLocalString(oCorpse,"CORPSE_PCID",ObjectToString(oCorpse)); // connected to nothing but itself
            SetLocalInt(oCorpse,"CORPSE", corpse_type - CORPSE_TYPE_RAISEABLE); // can no longer be raised
            SetLocalInt(oCorpse,"CORPSE", corpse_type - CORPSE_TYPE_PERSISTENT); // no longer tied to persistent inventory
            if(GetObjectType(oCorpse)==OBJECT_TYPE_PLACEABLE) {
                object oBody    = GetLocalObject(oCorpse, "CORPSE_BODY");
                StripInventory(oCorpse,TRUE,FALSE,FALSE); // inventory stripped
                DelayCommand(59.0, SetLocalInt(oBody, "DecayTimerExpired", TRUE));
                DelayCommand(60.0, ExecuteScript("spawn_corpse_dcy", oBody));
            }
            return FALSE;
        }

        // LOCATION ------
        if(!GetIsObjectValid(GetAreaFromLocation(loc_raise)))
        {
            loc_raise   = GetLocation(oCorpse);
            if(!GetIsObjectValid(GetAreaFromLocation(loc_raise)))
            {
              loc_raise = GetLocation(spell_caster);
              if(!GetIsObjectValid(GetAreaFromLocation(loc_raise)))
                return FALSE; // for now consider this a failure
                              // potential for getting a backup location from DB
            }
        }
        // bless the location by trying to put a creature there
        object oTmp = CreateObject(OBJECT_TYPE_CREATURE,"invisible",loc_raise);
        loc_raise   = GetLocation(oTmp);
        DestroyObject(oTmp);

        // TYPE OF RAISE -- and POSIBLE FAILURE --------
        int nVFX; int nHeal; string status;
        // next we need to determine if this is still going to proceed
        // and what effects we apply to the target
        if(GetIsDM(spell_caster))
        {
            status  = "RESURRECTED";
            nVFX    = VFX_IMP_RAISE_DEAD;
            success = TRUE;
        }
        else if(spell_id==SPELL_RAISE_DEAD)
        {
            status  = "RAISED";
            nVFX    = VFX_IMP_RAISE_DEAD;
            success = TRUE;
        }
        else if(spell_id==SPELL_RESURRECTION)
        {
            status  = "RESURRECTED";
            nVFX    = VFX_IMP_RAISE_DEAD;
            success = TRUE;
        }

        // SO FAR SO GOOD SO PROCEED -------------------
        if(success)
        {
            object corpse_raised;
            // gather who we are raising
            if( corpse_type & CORPSE_TYPE_PERSISTENT )
            {
                // PC ------
                if(corpse_type & CORPSE_TYPE_PC)
                {
                    corpse_raised   = GetPCByPCID(pcid);
                    if(GetIsObjectValid(corpse_raised))
                    {
                        // set PC as no longer dead
                        ClearPCDeath(pcid);
                        // PC is online now
                        PrepPCForRespawn(corpse_raised,loc_raise);
                    }
                    else
                    {
			    //corpseDebug("SpellRaiseCorpse : " + GetName(oCorpse) + " is not online - while be alive on next login.");
                        // pc is not online
                        // set PC to be raised or resurrected when they log in
                        ClearPCDeath(pcid, status);
                    }
                    // location to reappear (just in case the PC crashes)
                    Data_SetLocation("LAST", loc_raise, corpse_raised, pcid);
                }
                // NPC ------
                else
                {
                    // retrieve from DB
                    // set creature as no longer dead
                    ClearPCDeath(pcid);
                    // Set HP to > 0 so that PC is not killed again on login
                    Data_StorePCHitPoints(pcid, 1);

                    corpse_raised= Data_RetrieveNPC(pcid, loc_raise);
                }
            }
            else
            {
                // bog standard non persistent creature. lets just raise it.
                corpse_raised = GetPrettyBodyFromCorpse( oCorpse, GetLocalString(oCorpse, "CORPSE_BODY_RESREF"), loc_raise );
            }

            // generate the VFX at the location regardless
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nVFX), loc_raise);

            // is the raised going to make an appearance now?
            if(GetIsObjectValid(corpse_raised))
            {
                // this function will iterate until corpse_raised is in the same area as the loc_raise
                AssignCommand(corpse_raised, CharacterRaiseCompletes(loc_raise, status) );
            }
            // PC is not present... so we put on a show, then fade out the automaton
            else
            {


                // this is a doppelganger of a PC
                string sRef   = "corpse_pc";
                if(GetLocalInt(oCorpse,"CORPSE_GENDER")==GENDER_FEMALE)
                    sRef   = "corpse_pc_f";
                corpse_raised = GetPrettyBodyFromCorpse( oCorpse, sRef, loc_raise );
                AssignCommand(corpse_raised, SpeakString("*Player is not online right now, but "+GetName(corpse_raised)+" is now alive.*") );
                AssignCommand(corpse_raised, ActionPlayAnimation(ANIMATION_FIREFORGET_BOW) );
                DestroyObject(corpse_raised, 6.0);
            }

            // Destroy the corpse ---------------------------
            if(GetObjectType(oCorpse)==OBJECT_TYPE_PLACEABLE)
            {
                // corpse node
                SetLocalInt(oCorpse,"CORPSE_DECAY",TRUE);
                object oBody    = GetLocalObject(oCorpse, "CORPSE_BODY");
                StripInventory(oCorpse,TRUE,FALSE,FALSE); // inventory stripped
                DelayCommand(0.1, SetLocalInt(oBody, "DecayTimerExpired", TRUE));
                DelayCommand(1.0, ExecuteScript("spawn_corpse_dcy", oBody));
            }
            else
            {
                // corpse item
                DestroyObject(oCorpse,0.1);
            }
        }
    }

    return success;
}


// not currently used
void corpseRestorePCInventory(object oPC) {

	string pcid = GetPCID(oPC);
	object oInventory   = GetPersistentInventory("INV_CORPSE_"+pcid,pcid);
        corpseDebug("CorpseRestorePCInventory: Got inventory - iscreature = " + IntToString(GetObjectType(oInventory)==OBJECT_TYPE_CREATURE)
		    +  " store in db = " + IntToString(GetLocalInt(oInventory,"STORE_IN_DB")));

        MoveEquippedItems(oInventory, oPC);
        SetLocalInt(oInventory,"count", MoveInventory(oInventory, oPC));
        SetLocalInt(oInventory,"PERMANENT_DELETION", TRUE);
        DelayCommand(0.2, SignalEvent(oInventory, EventUserDefined(EVENT_COMMIT_OBJECT_TO_DB)) );

}

void PrepPCForRespawn(object oPC, location loc_raise)
{

    corpseDebug("PrepPCForRespawn: called for " + GetName(oPC));
    if(GetIsDead(oPC))
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oPC);

    // remove all effects -----------
    effect eLoop=GetFirstEffect(oPC);
    while (GetIsEffectValid(eLoop))
    {
	    corpseDebug("PrepPCForRespawn: Removing effect type " + IntToString(GetEffectType(eLoop)));
	    RemoveEffect(oPC, eLoop);
	    eLoop=GetNextEffect(oPC);
    }
    // restore personal VFX
    DeleteLocalInt(oPC, "vfx_do_op");
    ExecuteScript("_vfx_do_op", oPC);

    // This is an attempt to get the re-equip to happen earlier - but won't work with the force jump
    //corpseRestorePCInventory(oPC);
    // ------------------------------
    // assure that we can make shit happen
    SetCommandable(TRUE,oPC);
    ForceJump(oPC, loc_raise);
    //AssignCommand(oPC,ClearAllActions(TRUE));
    //AssignCommand(oPC,ActionJumpToLocation(loc_raise));
}

// This must be run as the respawning PC
void doFinishRaise(string pcid, string status) {
        object oPC = OBJECT_SELF;

        DestroyCorpse(pcid, TRUE); 
        if(status=="RAISED" || status=="RESURRECTED") {
                ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oPC);
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_RAISE_DEAD),GetLocation(oPC));
                if(status=="RESURRECTED") ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints()+10),oPC);
                SendMessageToPC(oPC, DMBLUE+"You have been raised from the dead!") ;
        }

	CorpseDressPC(oPC);
        PlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 6.0);

        DeleteLocalInt(oPC, "IS_DEAD");
        Data_SavePC(oPC);
        Data_DeleteLocation("RESPAWN", OBJECT_INVALID, pcid);
}

// This must be run as the respawning/raised PC.
void CharacterRaiseCompletes(location loc_raise, string status)
{
   
    // have we arrived?
    object area = GetArea(OBJECT_SELF);
    if(area==GetAreaFromLocation(loc_raise))
    {
        object oPC = OBJECT_SELF;
        string pcid = GetPCID(oPC);
        FadeFromBlack(oPC);
        SetCommandable(TRUE);
        SetLocalInt(oPC, "IS_DEAD", TRUE);
        DelayCommand(0.2, AssignCommand(area, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDeath(),oPC) ) );
        /*
        if(status=="RAISED" || status=="RESURRECTED")
        {
            DelayCommand(1.9, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oPC) );
            DelayCommand(1.9, ApplyEffectAtLocation(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_RAISE_DEAD),loc_raise) );
            DelayCommand(2.0, SendMessageToPC(oPC, DMBLUE+"You have been raised from the dead!") );
        }
        if(status=="RESURRECTED")
        {
            DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints()+10),oPC) );
        }
        */
	
	//corpseRestorePCInventory(oPC);
        object oInventory   = GetPersistentInventory("INV_CORPSE_"+pcid,pcid);
        //corpseDebug("RaiseCompletes: Got inventory - iscreature = " + IntToString(GetObjectType(oInventory)==OBJECT_TYPE_CREATURE)
	//         +  " store in db = " + IntToString(GetLocalInt(oInventory,"STORE_IN_DB")));

        MoveEquippedItems(oInventory, oPC);
        DelayCommand(0.1, SetLocalInt(oInventory,"count", MoveInventory(oInventory, oPC)) );
        SetLocalInt(oInventory,"PERMANENT_DELETION", TRUE);
        DelayCommand(0.2, SignalEvent(oInventory, EventUserDefined(EVENT_COMMIT_OBJECT_TO_DB)) );
	

	DelayCommand(1.0, CorpseDressPC(oPC));
        DelayCommand(1.9, doFinishRaise(pcid, status));
        /*
        DelayCommand(2.1, PlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 6.0) );
        DelayCommand(1.9, DestroyCorpse(pcid, TRUE) );

        DelayCommand(2.0, DeleteLocalInt(oPC, "IS_DEAD"));
        DelayCommand(2.1, Data_SavePC(oPC));
        DelayCommand(2.1, Data_DeleteLocation("RESPAWN", OBJECT_INVALID, pcid));
        */
    }
    // reiterate until PC arrives at destination
    else
    {
	    // TODO - this should try again to jump ...
        SetCommandable(FALSE);
        DelayCommand(0.5, CharacterRaiseCompletes(loc_raise, status));
    }

}

void DestroyCorpse(string pcid, int strip_corpse=FALSE)
{
    object oInventory   = GetPersistentInventory("INV_CORPSE_"+pcid, pcid);
    if(!GetLocalInt(oInventory,"STORE_IN_DB"))
        SetLocalInt(oInventory,"PERMANENT_DELETION", TRUE);
    SignalEvent(oInventory, EventUserDefined(EVENT_GARBAGE_COLLECTION));

    corpseDebug("DestroyCorpse : pcid = " +pcid);
    // garbage collection for persistent corpses
    object corpse_persistent= GetObjectByTag("CORPSE_"+pcid+"_PERSISTENT");
    int corpse_type  = GetLocalInt(corpse_persistent,"CORPSE");

    //corpseDebug("DestroyCorpse : corpse_perm = '" + GetTag(corpse_persistent) + "'");
    if(corpse_type & CORPSE_TYPE_PERSISTENT)
    {
        DestroyObject(corpse_persistent);

        Data_SetCampaignString("corpse_holder","0",OBJECT_INVALID,pcid);
	Data_DeleteLocation("CORPSE", OBJECT_INVALID, pcid);
    }
    // garbage collection for the corpse itself
    int nth; 
    string corpse_tag = "CORPSE_"+pcid;

    object oCorpse  = GetObjectByTag(corpse_tag, nth);
    //corpseDebug("DestroyCorpse : got corpse = '" + GetTag(oCorpse) + "'");
    while(GetIsObjectValid(oCorpse))
    {
      int nType = GetObjectType(oCorpse);
      if(nType == OBJECT_TYPE_PLACEABLE)
      {
        // clean up for placeable corpse
        DestroyObject(GetLocalObject(oCorpse,"PAIRED"), 12.0); //Delete paired objects - bloodstain

        // Destroy the invis corpse and drop a loot bag (if any loot left)
        SetPlotFlag(oCorpse, FALSE);
        if(strip_corpse)
            StripInventory(oCorpse);
        DestroyObject(oCorpse, 0.1);

        object oBody    = GetLocalObject(oCorpse, "CORPSE_BODY");  
	//corpseDebug("DestroyCorpse : got body = '" + GetTag(oBody) + "'");

        // To avoid potential memory leaks, we clean everything that might be left on the original creatures body
        StripInventory(oBody);
        // Destroy the visible corpse
        AssignCommand(oBody, SetIsDestroyable(TRUE, FALSE, FALSE));
        DestroyObject(oBody, 0.2);
      } else if (nType == OBJECT_TYPE_ITEM) {
        object oHolder = GetItemPossessor(oCorpse);
	//corpseDebug("DestroyCorpse : destroy item = '" + GetTag(oCorpse) + "' held by " + GetName(oHolder));
	SetPlotFlag(oCorpse, FALSE);
        DestroyObject(oCorpse, 0.1);
	
      }
      oCorpse  = GetObjectByTag(corpse_tag, ++nth);
    }
}


// Call from client enter 
// Check PC dead status -
// if "0"  then done - PC is alive and respawned before leaving.
// else if RAISED/RESURRECTED - PC was rezzed while offline - 
//           Give feedback - make sure not in fugue - set HPs as appropriate 
//           - call PrepPCForRespawn(corpse_raised,loc_raise); and CharacterRaiseCompletes(loc_raise, status));
//           ClearPCDeath(pcid);
// else must be dead still - check for area - if fugue then message about that
//             if regular area then make sure dead and pop gui panel
void deathCheckReentry(object oPC) {


        object oArea = GetArea(oPC);
        if(!GetIsObjectValid(oArea)) {
                DelayCommand(3.0, deathCheckReentry(oPC));
                WriteTimestampedLogEntry("DEBUG: deathCheckReentry - area not valid - trying again later...");
                return;
        }

        // Tag of area with default NWN starting location
        if (GetTag(oArea) == "tt_loginstart") {
                DelayCommand(3.0, deathCheckReentry(oPC));
                WriteTimestampedLogEntry("DEBUG: deathCheckReentry - still in login area - trying again later...");
                return;
        }


        string pcid = GetPCID(oPC);
        string status = GetPCDeathStatus(pcid);

        if (status == "0" || status == "") {
                //SendMessageToPC(oPC, "You are still alive good...");
                WriteTimestampedLogEntry("DEBUG: deathCheckReentry - PC alive - all done.");
                return;
        }
        if (status == "RESURRECTED" || status == "RAISED") {
                WriteTimestampedLogEntry("DEBUG: deathCheckReentry - PC was " + status + ".");

                location lRaise = GetLocation(oPC);
                string sArea = GetTag(GetAreaFromLocation(lRaise));
                if (sArea == "tt_fugue") {
                        // need to jump somewhere first
                        WriteTimestampedLogEntry("DEBUG: deathCheckReentry - PC in fugue - should not be here.");
                        // find new location 
                        lRaise = corpseGetRespawnLocation(oPC);
                        // Check again and use the default starting location maybe? 
                }
                // set PC as no longer dead
                ClearPCDeath(pcid);
                PrepPCForRespawn(oPC,lRaise); // This forcejumps. 
                AssignCommand(oPC, CharacterRaiseCompletes(lRaise, status) );
                return;
        }

         WriteTimestampedLogEntry("DEBUG: deathCheckReentry: " + GetName(oPC) + " is dead. ");
        // TODO
        // PC should be dead - 
        // Check for being in fugue plain - currently using that to detect if 
        // PC has selected respawn or exit.  
        location lRaise = GetLocation(oPC);
        string sArea = GetTag(GetAreaFromLocation(lRaise));
        if (sArea == "tt_fugue") {
		corpseDebug(GetName(oPC) + " is in fugue plain - okay.");
		// TODO - validate we did all the right things? 
	        return;
	}
        // if not make sure PC is dead and pop up death panel
        // HP restore code _ex_restorehp  should take care of this.
	corpseDebug(GetName(oPC) + " should be dead but not respawned - time to die...");


}


location corpseGetRespawnLocation(object oPC) {

        string waypoint = "dst_fugue";
      //string waypoint = "dst_development";
        string pcid = GetPCID(oPC);
        location respawn;

        // first find a corpse location if possible - either item holder or last dropped location.
        string sHolder = Data_GetCampaignString("corpse_holder", OBJECT_INVALID, pcid);
        if (sHolder != "0") {
                object oHolder = GetPCByPCID(sHolder);
                if (GetIsObjectValid(oHolder)) {
                        respawn = GetLocation(oHolder);
                } else {
                        respawn = Data_GetLocation("LAST", OBJECT_INVALID, sHolder);
                }
        }
        if(GetIsObjectValid(GetAreaFromLocation(respawn))) return respawn;

        // This one is set when a visible corpse is created (initially or item drop)
        respawn = Data_GetLocation("CORPSE", oPC, pcid);
        if(GetIsObjectValid(GetAreaFromLocation(respawn))) return respawn;

        // This one is set when the PC clicks the Respawn button in the death panel.
        respawn = Data_GetLocation("RESPAWN", oPC, pcid);
        if( !GetIsObjectValid(GetAreaFromLocation(respawn))) {
                respawn = GetLocation(GetWaypointByTag(waypoint));
        }

        return respawn;
}
