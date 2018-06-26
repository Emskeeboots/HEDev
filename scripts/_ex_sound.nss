//::///////////////////////////////////////////////
//:: _ex_sound
//:://////////////////////////////////////////////
/*
    Use: Executed by an object

    Recursive script function that plays a sound.
    Local string: SOUND

    if the local string is empty recursion stops
    --> that is how you turn it off

*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 mar 11)
//:: Modified:
//:://////////////////////////////////////////////

float GetSoundLength(string sSnd)
{
    if(sSnd=="al_cv_firepit1")
        return 5.0;
    else if(sSnd=="al_cv_firecppot1")
        return 5.6;
    else
        return 5.9;
}

void main()
{
    string sSnd = GetLocalString(OBJECT_SELF,"SOUND");

    //SendMessageToPC(GetFirstPC(), "_ex_sound("+sSnd+")");

    if(sSnd!="")
    {
        PlaySound(sSnd);
        DelayCommand(   GetSoundLength(sSnd),
                        ExecuteScript("_ex_sound", OBJECT_SELF)
                    );
    }
}

