void main()
{
    SetPCChatVolume(TALKVOLUME_SILENT_TALK);
    object oPC = OBJECT_SELF;

    //allows characters to get close to each othere

   // Apply Ghost Effect/etc
    effect eGhost = EffectCutsceneGhost();
    eGhost = SupernaturalEffect( eGhost );
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,eGhost,oPC);
    SendMessageToPC(oPC, "Touching On");

}

