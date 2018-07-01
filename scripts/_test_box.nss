
void main()
{
    object oVic = GetLastUsedBy();
    object corpse_store = GetObjectByTag("corpse_storage");

    SendMessageToPC(oVic, "Corpse store("+GetName(corpse_store)+")");

    object oItem    = GetFirstItemInInventory(corpse_store);
    while(GetIsObjectValid(oItem))
    {
        SendMessageToPC(oVic, "Corpse("+GetName(oItem)+")");


        oItem   = GetNextItemInInventory(corpse_store);
    }
}

