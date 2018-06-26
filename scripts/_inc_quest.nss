// _inc_quest.nss
// Quest state handling routines


#include "_inc_data"

// QUEST functions

// returns TRUE if pc has quest named quest_name [File: _inc_quest]
int GetPCHasQuest(object pc, string quest_name);
// PC has the quest of quest_name if has_quest is TRUE [File: _inc_quest]
void SetPCHasQuest(object pc, string quest_name, int has_quest=TRUE);
// returns TRUE if pc has completed the quest named quest_name [File: _inc_quest]
int GetPCCompletedQuest(object pc, string quest_name);
// PC has completed the quest of quest_name if completed_quest is TRUE [File: _inc_quest]
void SetPCCompletedQuest(object pc, string quest_name, int completed_quest=TRUE);
// returns pc's progress in the quest named quest_name [File: _inc_quest]
int GetPCQuestState(object pc, string quest_name);
// set the pc's progress to quest_state in the quest named quest_name [File: _inc_quest]
void SetPCQuestState(object pc, string quest_name, int quest_state);
// QUESTS ----------------------------------------------------------------------

// returns TRUE if pc has quest named quest_name [File: _inc_quest]
int GetPCHasQuest(object pc, string quest_name)
{
    return (StringToInt( Data_GetCampaignString("QUEST_"+quest_name+"_HAS",pc,GetPCID(pc)) )==TRUE);
}

// PC has the quest of quest_name if has_quest is TRUE [File: _inc_quest]
void SetPCHasQuest(object pc, string quest_name, int has_quest=TRUE)
{
    Data_SetCampaignString("QUEST_"+quest_name+"_HAS", IntToString(has_quest), pc, GetPCID(pc));
}

// returns TRUE if pc has completed the quest named quest_name [File: _inc_quest]
int GetPCCompletedQuest(object pc, string quest_name)
{
    return (StringToInt( Data_GetCampaignString("QUEST_"+quest_name+"_COMPLETE",pc,GetPCID(pc)) )==TRUE);
}

// PC has completed the quest of quest_name if completed_quest is TRUE [File: _inc_quest]
void SetPCCompletedQuest(object pc, string quest_name, int completed_quest=TRUE)
{
    Data_SetCampaignString("QUEST_"+quest_name+"_COMPLETE", IntToString(completed_quest), pc, GetPCID(pc));
}

// returns pc's progress in the quest named quest_name [File: _inc_quest]
int GetPCQuestState(object pc, string quest_name)
{
    return StringToInt( Data_GetCampaignString("QUEST_"+quest_name+"_STATE",pc,GetPCID(pc)) );
}

// set the pc's progress to quest_state in the quest named quest_name [File: _inc_quest]
void SetPCQuestState(object pc, string quest_name, int quest_state)
{
    Data_SetCampaignString("QUEST_"+quest_name+"_STATE", IntToString(quest_state), pc, GetPCID(pc));
}

