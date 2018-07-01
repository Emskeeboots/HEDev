void main()
{
    object oVic = GetLastUsedBy();
    AssignCommand(oVic, JumpToObject(GetWaypointByTag("dst_test")) );
}
