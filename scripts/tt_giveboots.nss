void main()
{

object oPC = GetPCSpeaker();

if (GetGold(oPC) >= 50)
    {

    switch (Random(21))
        {
        case 0:
                CreateItemOnObject("tt_wboots_001", oPC);
           break;

        case 1:
                CreateItemOnObject("tt_wboots_002", oPC);
           break;

        case 2:
                CreateItemOnObject("tt_wboots_003", oPC);
             break;
        case 3:
                CreateItemOnObject("tt_wboots_004", oPC);
             break;
        case 4:
                CreateItemOnObject("tt_wboots_005", oPC);
             break;
        case 5:
                CreateItemOnObject("tt_wboots_006", oPC);
            break;
        case 6:
                CreateItemOnObject("tt_wboots_007", oPC);
            break;
        case 7:
                CreateItemOnObject("tt_wboots_008", oPC);
            break;
        case 8:
                CreateItemOnObject("tt_wboots_009", oPC);
             break;
        case 9:
                CreateItemOnObject("tt_wboots_010", oPC);
             break;
        case 10:
                CreateItemOnObject("tt_wboots_011", oPC);
           break;

        case 11:
                CreateItemOnObject("tt_wboots_012", oPC);
           break;

        case 12:
                CreateItemOnObject("tt_wboots_013", oPC);
             break;
        case 13:
                CreateItemOnObject("tt_wboots_014", oPC);
             break;
        case 14:
                CreateItemOnObject("tt_wboots_015", oPC);
             break;
        case 15:
                CreateItemOnObject("tt_wboots_016", oPC);
            break;
        case 16:
                CreateItemOnObject("tt_wboots_017", oPC);
            break;
        case 17:
                CreateItemOnObject("tt_wboots_018", oPC);
            break;
        case 18:
                CreateItemOnObject("tt_wboots_019", oPC);
             break;
        case 19:
                CreateItemOnObject("tt_wboots_020", oPC);
             break;
        case 20:
                CreateItemOnObject("tt_wboots_021", oPC);
             break;

        }

      }

        else
     {
          AssignCommand(GetObjectByTag("tt_npc"), ActionSpeakString("No gold, no boots!"));
     }

}







