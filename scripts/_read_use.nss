//::///////////////////////////////////////////////
//:: _read_use
//:://////////////////////////////////////////////
/*
    Use Event for a placeable with text

    Local Variables (required)
        read            string  text to read
        readlanguage    string  name of the language that the text is written in
                                        character needs to know this language to read it
                                        if they do not know it they make a lore check to identify which language it was written in

    Locals (optional)
    if you want to make the text harder to read than normal you can add a skill check
    This skillcheck only occurs if the character already knows the language
    use it for something written in code, or perhaps almost illegible or something.
        readdc          int     DC of a skillcheck to read the language
        readskill       int     index of skills.2da to the skill to use for the skillcheck


        onread          string  special script for read behavior



*/
//:://////////////////////////////////////////////
//:: Created:  henesua (2017 mar 8)
//:: Modified:

#include "aid_inc_fcns"
#include "_inc_constants"
#include "_inc_util"
#include "_inc_languages"


void main()
{
    // get "user"
    int return_aid = FALSE;
    object oPC  = GetLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    DeleteLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    if(!GetIsObjectValid(oPC))
        oPC     = GetLastUsedBy();
    else
        return_aid = TRUE;

    SetLocalInt(OBJECT_SELF,"checkread",TRUE);

    // old stuff from the aid DoRead function
    string sVerb        = "read";
    string sRead        = GetLocalString(OBJECT_SELF, sVerb);
    string read_object  = GetLocalString(OBJECT_SELF, "readobjecttag");
    string language_name= LanguageToName(GetLocalString(OBJECT_SELF, "readlanguage"));

    if(read_object != "")
    {
        object object_to_read   = GetObjectByTag(read_object);

        if(GetIsObjectValid(object_to_read))
        {
            // we do this only once
            DeleteLocalString(OBJECT_SELF, "readobjecttag");
            sRead        = GetDescription(object_to_read);
            SetLocalString(OBJECT_SELF, sVerb, sRead);
        }

    }

    if(!return_aid)
    {
        FloatingTextStringOnCreature(WHITE+GetName(oPC)+" tries reading "+GREEN+GetName(OBJECT_SELF)+WHITE+".",oPC);
    }

    int bSuccess        = GetLocalInt(oPC, ObjectToString(OBJECT_SELF)+sRead);
    if(!bSuccess)
        bSuccess        = SkillCheck(OBJECT_SELF, oPC, sVerb);

    if (sRead != "")
    {

        float fDelay = 0.3;

        if(return_aid)
        {
            fDelay = FindDelay(oPC, OBJECT_SELF);
            DoManipulate(oPC, OBJECT_SELF, ANIMATION_LOOPING_GET_MID, 1.0f);
        }

        if(bSuccess)
        {
            string text_header  = BR+WHITE+"------------ The text of "+GetName(OBJECT_SELF)+" as written in "+language_name+" ------------"+BR+Q;
            string text_body    = LIGHTGREEN+sRead;
            string text_footer  = WHITE+Q+BR;


            if(!return_aid)
                DelayCommand((fDelay-0.15), SendMessageToPC(oPC, text_header));
            else
                DelayCommand((fDelay-0.2), FloatingTextStringOnCreature(text_header,oPC,FALSE));
            DelayCommand((fDelay-0.1), SendMessageToPC(oPC, text_body));
            DelayCommand((fDelay), SendMessageToPC(oPC, text_footer));
        }
    }
    else
    {
        SendMessageToPC(oPC, sNoRead);
        bSuccess = FALSE;
    }
    // Once an item is successfully read, it is thereafter legible to the PC
    if(bSuccess)
        SetLocalInt(oPC, ObjectToString(OBJECT_SELF)+sRead, TRUE);

    if(return_aid)
    {
        SetLocalInt(oPC,"AID_SUCCESS",bSuccess);
        DelayCommand(0.5, DeleteLocalInt(oPC,"AID_SUCCESS") );
    }
}
