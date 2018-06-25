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

    //end Kinarr's

    //determine who is interacting with this object
    object oPC = GetPCSpeaker();

    //open the linked container
    if (GetIsObjectValid(oPC)) {
        object myChild = GetLocalObject(OBJECT_SELF, "md_gemchild");

        if (GetIsObjectValid(myChild)) {
            AssignCommand(oPC, ActionInteractObject(myChild));
        }
    }
}
