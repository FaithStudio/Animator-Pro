/* fccomp.c -  code used to delta compress colors. */

#include "jimk.h"
#include "fccomp.h"
#include "peekpok_.h"
#include "ptr.h"

UWORD *
fccomp(const char *s1, const char *s2, UWORD *cbuf, unsigned int count)
{
unsigned wcount, i;
char *c;
unsigned op_count;
unsigned dif_count;
unsigned same_count;
unsigned next_match;
unsigned bcount;
char *s2x;
unsigned c3;

c = (char *)(cbuf+1);
op_count = 0;
count *= 3;
wcount = fcompare((UWORD *)s1, (UWORD *)s2, count>>1);
wcount <<= 1;
if (wcount == count)
	return (UWORD *)c; /* stupid way to say got nothing... */
for (;;)
	{
	/* first find out how many words to skip... */
	c3 = (bcompare(s1, s2, count)/3);
	wcount = c3*3;
	if ((count -= wcount) == 0)
		goto OUT;	/* same until the end... */
	*c++ = c3;
	s1 += wcount;
	s2 += wcount;
	op_count++;

	/* figure out how long until the next worthwhile 'skip' */
	dif_count = 0;
	bcount = count;
	for (;;)
		{
		wcount = bcontrast(s1,s2,bcount)/3;
		dif_count += wcount;
		wcount *= 3;
		s1 += wcount;
		s2 += wcount;
		bcount -= wcount;
		if (bcount >= 3)
			{
			if ((wcount = bcompare(s1,s2,3)) == 3)
				{
				break;
				}
			else
				{
				dif_count += 1;
				s1 += 3;
				s2 += 3;
				bcount -= 3;
				}
			}
		else
			{
			break;
			}
		}
	*c++ = dif_count;
	dif_count *= 3;
	s2 -= dif_count;
	count -= dif_count;
	for (;;)
		{
		if (dif_count == 0)
			break;
		dif_count -= 1;
		*c++ = *s2++;
		}
	if (count <= 0)
		break;
	}
OUT:
*cbuf = op_count;

if (((intptr_t)c) & 1)
	*c = '\0';

return (UWORD *)enorm_pointer(c);
}
