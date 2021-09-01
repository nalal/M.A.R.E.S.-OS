#define FB_START 0xb8000
#define FB_INCREMENT 0x00002
//#define FB_POINTER 0x1000
#define STARTING_FB (80*4)

char * fb_pointer = (char*)FB_START;
int cur_collumn = 80;

void dec_cur_collumn(int times)
{
	while(times > 0)
	{
		if(cur_collumn == 1)
			cur_collumn = 80;
		else
			cur_collumn--;
		times--;
	}
}

void inc_fb_pointer(int times)
{
	while(times > 0)
	{
		fb_pointer++;
		fb_pointer++;
		times--;
	}
}

void dec_fb_pointer(int times)
{
	while(times > 0)
	{
		fb_pointer--;
		fb_pointer--;
		times--;
	}
}

void print_ch(char ch)
{
	*(char*)fb_pointer = ch;
	inc_fb_pointer(1);
	dec_cur_collumn(1);
}

void print_newline()
{
	inc_fb_pointer(cur_collumn);
	cur_collumn = 80;
}

void clr_line()
{
	dec_fb_pointer(80 - cur_collumn);
	for(int i = 0; i < 80; i++)
	{
		print_ch(' ');
	}
}

void reset_fb_pointer()
{
	fb_pointer = (char*)FB_START;
	cur_collumn = 80;
}

void clr_screen()
{
	reset_fb_pointer();
	for(int i = 0; i < 10; i++)
	{
		clr_line();
		print_newline();
	}
	reset_fb_pointer();
}


void print_string(char * print_str, int offset)
{
	switch(offset)
	{
		case 0:
			break;
		default:
			for(int x = 0; x < offset; x++)
			{
				
				fb_pointer++;
				fb_pointer++;
			}
	}
	int i = 0;
	while(print_str[i] != '\0')
	{
		switch(print_str[i])
		{
			case '\n':
				print_newline();
				break;
			default:
				print_ch(print_str[i]);
		}
		i++;
	}
}

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
