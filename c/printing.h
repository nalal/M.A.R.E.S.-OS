#ifndef PRINTING_H
#define PRINTING_H

void dec_cur_collumn(int times);

void inc_fb_pointer(int times);

void dec_fb_pointer(int times);

void print_ch(char ch);

void print_newline();

void clr_line();

void reset_fb_pointer();

void clr_screen();

void print_string(char * print_str/*, int offset*/);

void print_crossbar();

#endif
