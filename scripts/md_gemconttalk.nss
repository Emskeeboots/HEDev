/*
    Merricksdad's Gem Container Conversation Script

    This script causes the linked invisible container to open when
    a conversation with this object is started.
*/

void main()
{
    //This section taken from Kinarr Graycloak's Armor Stand

    // don't face the speaker
    float fFacing = GetFacing(OBJECT_SELF);
    BeginConversation();
    SetFacing(fFacing);

}
