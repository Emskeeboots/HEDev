void main()
{


object oPC = GetPCSpeaker();


int nint;nint = d6();

if(nint==1)
{

if (GetIsNight())
    AssignCommand(OBJECT_SELF, SpeakString("Yeah?"));

else AssignCommand(OBJECT_SELF, SpeakString("Hello there"));}

else if (nint==2){AssignCommand(OBJECT_SELF, SpeakString("What is it?"));}

else if (nint==3){AssignCommand(OBJECT_SELF, SpeakString("Hmm?"));}

else if (nint==4){AssignCommand(OBJECT_SELF, SpeakString("What do you want?"));}

else if (nint==5){AssignCommand(OBJECT_SELF, SpeakString("Can I help you?"));}

else if (nint==6){AssignCommand(OBJECT_SELF, SpeakString("Hey there"));

     }

   }







