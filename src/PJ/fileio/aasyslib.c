#ifdef WITH_POCO
/**** host side declaration of aa_syslib vector table ****/

#define REXLIB_INTERNALS
#include "memory.h"
#include "jfile.h"
#include "rexlib.h"
#include "aasyslib.h"
#include "filepath.h"

Syslib aa_syslib = {
	/* header */
	{
		sizeof(Syslib),
		AA_SYSLIB, AA_SYSLIB_VERSION,
	},
/** memory oriented utilities **/
	pj_malloc,
	pj_zalloc,
	pj_free,
	memset,
	memcpy,
	memcmp,
	strcpy,
	strlen,
	strcmp,
	pj_get_path_suffix,
	pj_get_path_name,

/* Might as well let rexlibs load rexlibs... */
	pj_rex_load,
	pj_rex_free,
	pj_rexlib_load,
	pj_rexlib_init,
	pj_rexlib_free,

/* dos unbuffered file io interface */
	pj_ioerr,
	pj_open,
	pj_create,
	pj_close,
	pj_read,
	pj_write,
	pj_seek,
	pj_tell,
	pj_delete,
	pj_rename,
	pj_exists,
/* clock */
	pj_clock_1000,
/* debugging printer */
	boxf,
};
#endif /* WITH_POCO */
