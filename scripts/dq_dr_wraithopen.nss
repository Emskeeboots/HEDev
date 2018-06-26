object oDoor = OBJECT_SELF;

void main()
{
    AssignCommand(oDoor, SpeakString("As the room grows silent, a grating rasp can be heard as the metal door creaks open."));

//  DelayCommand(59.0, AssignCommand(oDoor, ClearAllActions()));

    DelayCommand(60.0, SetLocalInt(oDoor, "wraith_count", 0));
//  DelayCommand(60.0, SendMessageToPC(GetFirstPC(), "Door Close"));
    DelayCommand(60.0, AssignCommand(oDoor, SpeakString("The door close.")));
    DelayCommand(60.0, AssignCommand(oDoor, ActionCloseDoor(oDoor)));



}
