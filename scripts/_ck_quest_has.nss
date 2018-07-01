/////////////////////////////
//_ck_has_quest
//
// This checks whether the PC in convo has the quest
// NPCs can have only one QUEST
// ID this with local string QUEST
// see the forums for a list of QUEST identifiers
/////////////////////////////
//::   Created:     Oldfog with major help from Henesua (2016-12-03)
////////////////////////////////////////////////////

#include "_inc_quest"

int StartingConditional()
{
            return GetPCHasQuest(GetPCSpeaker() , GetLocalString(OBJECT_SELF,"QUEST"));
}
