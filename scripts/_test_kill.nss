void main()
{
    object oVic = GetLastUsedBy();
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDeath(),oVic);
}
