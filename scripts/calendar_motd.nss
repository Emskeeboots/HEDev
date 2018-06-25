// calendar_motd
// Print the calendar day message (moon phase, celebrations etc).
// Executed as the PC usually daily, and on login

#include "tb_inc_calendar"

void main() {
	object oPC = OBJECT_SELF;

	tbCalendarPrintDay(oPC, TRUE);
}
