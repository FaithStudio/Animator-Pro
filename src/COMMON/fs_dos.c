/* fs_dos.c */

#include <string.h>
#include "jimk.h"
#include "fs.h"
#include "ptr.h"

struct fndata
{
	char reserved[21];
	char attribute;
	int time, date;
	long size;
	char name[13];
};

int
make_path_name(const char *drawer, char *file, char *path)
{
	int len, flen;

	/* say hey it's got the drive in file string */
	if (file[1] == ':') {
		if (!valid_device(file[0] - 'A') )
			return 0;

		strcpy(path, file);
		return 1;
	}

	strcpy(path, drawer);

	/* if no : or \ at end of drawer better add it */
	if ((len = strlen(drawer)) != 0) {
		char c = drawer[len-1];
		if (c != ':' && c != DIR_SEPARATOR_CHAR)
			strcat(path, DIR_SEPARATOR_STR);
	}

	strcat(path, file);
	return 1;
}

void
fs_go_rootdir(char *drawer, unsigned int size)
{
	if (drawer[1] == ':')
		strcpy(drawer+2, DIR_SEPARATOR_STR);
	else
		strcpy(drawer, DIR_SEPARATOR_STR);
}

void
fs_go_updir(char *drawer)
{
	int len = strlen(drawer);
	char *d = drawer;

	/* move 'd' pointer past device if any */
	if (len >= 2) {
		if (d[1] == ':') {
			d += 2;
			len -= 2;
		}
	}

	if (len > 0) {
		if (d[0] == DIR_SEPARATOR_CHAR) {
			d++;
			len--;
		}
	}

	while (--len >= 0) {
		char c = d[len];
		d[len] = '\0';
		if (c == DIR_SEPARATOR_CHAR)
			break;
	}
}

static void
attr_wild_list(int attr, const char *pat, enum FileType type)
{
	union regs reg;
	int err;
	struct fndata *fn;

	/* get the 'DTA' area for directory search */
	reg.b.ah = 0x2f;
	sysint(0x21,&reg,&reg);
	fn = make_ptr(reg.w.bx, reg.w.es);

	/* now do the find first... */
	reg.b.ah = 0x4e; /* int 21 function # */
	reg.w.cx = attr; /* 'attribute' */
	reg.w.dx = ptr_offset(pat);
	reg.w.ds = ptr_seg(pat);
	if (!(sysint(0x21, &reg, &reg) & 1)) { /* check 'carry' flag for error... */
		if ((fn->attribute & 16) == attr)
			add_wild(fn->name, type);

		for (;;) {
			reg.b.ah = 0x4f;
			if (sysint(0x21, &reg, &reg) & 1)
				break;
			if ((fn->attribute & 16) == attr)
				add_wild(fn->name, type);
		}
	}
}

void
fs_build_wild_list(const char *drawer, const char *wild)
{
	attr_wild_list(16, "*.*", FILETYPE_DIRECTORY); /* get all directories */
	attr_wild_list(0, wild, FILETYPE_REGULAR); /* and other files matching wild */
}
