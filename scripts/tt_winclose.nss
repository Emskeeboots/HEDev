void main()
{

object oPC = GetLastOpenedBy();

if (!GetIsPC(oPC)) return;

DelayCommand (3.0, ActionSpeakString("Thank you!"));

}







