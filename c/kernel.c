#include "printing.h"
#include "printing_defines.h"

void print_loaded()
{
	char * headline_str = "[M.A.R.E.S. (v1.0.0)]\n";
	print_string(headline_str);
	print_crossbar();
	char * load_complete_str = "Multitasking Automated Resource and Execution System initialized.\nKERNEL VERSION:\n    1.0.0\n";
	print_string(load_complete_str);

	char * author_str = "Written, developed and tested by:\n    Nac/Nalal/Host/Noah\n";
	print_string(author_str);
}

extern void main()
{
	print_loaded();

	return;
}
