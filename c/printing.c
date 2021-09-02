#include "printing_defines.h"

// Framebuffer pointer for tracking the next address to push memory too
char * fb_pointer = (char*)FB_START;
// Current collumn for tracking which collumn we're at, inverted
int cur_collumn = VGA_W;
// Current row for tracking which row we're printing to, inverted
int cur_row = VGA_H;


void dec_cur_collumn(int times)
{
	while(times > 0)
	{
		cur_collumn--;
		if(cur_collumn == 0)
			cur_collumn = VGA_W;
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
	cur_collumn = VGA_W;
}

void clr_line()
{
	dec_fb_pointer(VGA_W - cur_collumn);
	for(int i = 0; i < VGA_W; i++)
	{
		print_ch(' ');
	}
}

void reset_fb_pointer()
{
	fb_pointer = (char*)FB_START;
	cur_collumn = VGA_W;
	cur_row = VGA_H;
}

void move_to(int col, int row)
{
	reset_fb_pointer();
	inc_fb_pointer(col * row);
}

void print_crossbar()
{
	while(cur_collumn > 1)
	{
		print_ch(CROSSBAR_CHAR);
	}
	print_ch(CROSSBAR_CHAR);
}

void clr_screen()
{
	reset_fb_pointer();
	for(int i = 0; i < VGA_H; i++)
	{
		clr_line();
		print_newline();
	}
	reset_fb_pointer();
}


void print_string(char * print_str/*, int offset*/)
{
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

// Will need to deal with memory allocation first
//void strcpy(char * targ_str, const char * source_str)
//{
	
//}
