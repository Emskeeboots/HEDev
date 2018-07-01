void main()
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    object oPC = OBJECT_SELF;

    //turns off touching

   // Apply Ghost Effect/etc
    effect eGhost = EffectCutsceneGhost();
    eGhost = SupernaturalEffect( eGhost );
    RemoveEffect(oPC, eGhost);
    SendMessageToPC(oPC, "Touching Off");

}
