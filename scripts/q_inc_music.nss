void CleanUp(object oPC)
{
    int iPheno = GetLocalInt(oPC,"PHENO_ORIGIN");
    SetPhenoType(iPheno,oPC);
    AssignCommand(oPC, ClearAllActions());
}

void PlayInstrument(int nEffect)
{
    //OBJECT_SELF is now the assigned object

    // location to play sound from
    location lLoc = GetLocation(OBJECT_SELF);

    // create object to play sound
    object oSound = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_invisobj",lLoc,FALSE,"TBX_SOUND_OBJ");

    // sound to play with animation
    string sSound;
    int iSwitch = d100();
    if (iSwitch < 51) sSound = "as_cv_lute1";
    else sSound = "as_cv_lute1b";
    AssignCommand(oSound,DelayCommand(2.8,PlaySound(sSound)));
    AssignCommand(oSound,DelayCommand(7.8,PlaySound(sSound)));
    AssignCommand(oSound,DelayCommand(12.8,PlaySound(sSound)));
    AssignCommand(oSound,DelayCommand(17.8,PlaySound(sSound)));
    AssignCommand(oSound,DelayCommand(22.8,PlaySound(sSound)));
    AssignCommand(oSound,DelayCommand(27.8,PlaySound(sSound)));

    // make pc do the play music animation
    DelayCommand(1.0,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(nEffect),OBJECT_SELF,32.0));
    ActionPlayAnimation(ANIMATION_LOOPING_CUSTOM1,1.0,30.0);
    ActionDoCommand(SetCommandable(TRUE));
    SetCommandable(FALSE);
    DestroyObject(oSound,33.0);
    DelayCommand(33.0,CleanUp(OBJECT_SELF));
}

int GetInstrumentVFX(object oPC, object oItem)
{
    int nEffect;
    int iRace = GetAppearanceType(oPC);
    int iSex = GetGender(oPC);
    string sResRef = GetResRef(oItem);

    if (sResRef == "qit_banjo001")
    {
        //Get visual effect from gender and race
        switch (iSex)
        {
            case GENDER_MALE:
            {
                switch (iRace)
                {
                    case APPEARANCE_TYPE_HALFLING: nEffect = 751; break;
                    case APPEARANCE_TYPE_DWARF: nEffect = 753; break;
                    case APPEARANCE_TYPE_ELF: nEffect = 755; break;
                    case APPEARANCE_TYPE_GNOME: nEffect = 757; break;
                    case APPEARANCE_TYPE_HUMAN:
                    case APPEARANCE_TYPE_HALF_ELF: nEffect = 759; break;
                    case APPEARANCE_TYPE_HALF_ORC: nEffect = 761; break;
                }
            }
            break;

            case GENDER_FEMALE:
            {
                switch (iRace)
                {
                    case APPEARANCE_TYPE_HALFLING: nEffect = 752; break;
                    case APPEARANCE_TYPE_DWARF: nEffect = 754; break;
                    case APPEARANCE_TYPE_ELF: nEffect = 756; break;
                    case APPEARANCE_TYPE_GNOME: nEffect = 758; break;
                    case APPEARANCE_TYPE_HUMAN:
                    case APPEARANCE_TYPE_HALF_ELF: nEffect = 760; break;
                    case APPEARANCE_TYPE_HALF_ORC: nEffect = 762; break;
                }
            }
            break;
        }
    }
    else if (sResRef == "qit_lute002")
    {
        switch (iSex)
        {
            case GENDER_MALE:
            {
                switch (iRace)
                {
                    case APPEARANCE_TYPE_HALFLING: nEffect = 775; break;
                    case APPEARANCE_TYPE_DWARF: nEffect = 777; break;
                    case APPEARANCE_TYPE_ELF: nEffect = 779; break;
                    case APPEARANCE_TYPE_GNOME: nEffect = 781; break;
                    case APPEARANCE_TYPE_HUMAN:
                    case APPEARANCE_TYPE_HALF_ELF: nEffect = 783; break;
                    case APPEARANCE_TYPE_HALF_ORC: nEffect = 785; break;
                }
            }
            break;

            case GENDER_FEMALE:
            {
                switch (iRace)
                {
                    case APPEARANCE_TYPE_HALFLING: nEffect = 776; break;
                    case APPEARANCE_TYPE_DWARF: nEffect = 778; break;
                    case APPEARANCE_TYPE_ELF: nEffect = 780; break;
                    case APPEARANCE_TYPE_GNOME: nEffect = 782; break;
                    case APPEARANCE_TYPE_HUMAN:
                    case APPEARANCE_TYPE_HALF_ELF: nEffect = 784; break;
                    case APPEARANCE_TYPE_HALF_ORC: nEffect = 786; break;
                }
            }
            break;
        }
    }
    else if (sResRef == "qit_guitar002")
    {
        switch (iSex)
        {
            case GENDER_MALE:
            {
                switch (iRace)
                {
                    case APPEARANCE_TYPE_HALFLING: nEffect = 763; break;
                    case APPEARANCE_TYPE_DWARF: nEffect = 765; break;
                    case APPEARANCE_TYPE_ELF: nEffect = 767; break;
                    case APPEARANCE_TYPE_GNOME: nEffect = 769; break;
                    case APPEARANCE_TYPE_HUMAN:
                    case APPEARANCE_TYPE_HALF_ELF: nEffect = 771; break;
                    case APPEARANCE_TYPE_HALF_ORC: nEffect = 773; break;
                }
            }
            break;

            case GENDER_FEMALE:
            {
                switch (iRace)
                {
                    case APPEARANCE_TYPE_HALFLING: nEffect = 764; break;
                    case APPEARANCE_TYPE_DWARF: nEffect = 766; break;
                    case APPEARANCE_TYPE_ELF: nEffect = 768; break;
                    case APPEARANCE_TYPE_GNOME: nEffect = 770; break;
                    case APPEARANCE_TYPE_HUMAN:
                    case APPEARANCE_TYPE_HALF_ELF: nEffect = 772; break;
                    case APPEARANCE_TYPE_HALF_ORC: nEffect = 774; break;
                }
            }
            break;
        }
    }
    return nEffect;
}
