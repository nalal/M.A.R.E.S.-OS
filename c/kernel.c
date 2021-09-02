#include "printing.h"
#include "printing_defines.h"

void print_loaded()
{
	char * load_complete_str = "Multitasking Automated Resource and Execution System initialized.\nKERNEL VERSION:\n    1.0.0\n";
	print_string(load_complete_str, STARTING_FB);
}

extern void main()
{
	print_loaded();
	
	char * str = "Written, developed and tested by:\n    Nac/Nalal/Host/Noah\n";
	print_string(str, 0);
	return;
}
