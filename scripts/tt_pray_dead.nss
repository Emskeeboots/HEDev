void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0f, 9999.0f));

}
