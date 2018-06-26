
void main()
{

object oPC = GetLastOpenedBy();

if (!GetIsPC(oPC)) return;

DelayCommand (3.0, ActionSpeakString("*Someone shouts from the inside* Close my window you nincompoop!"));

}


