#ifndef LINUX_26_26_COMPAT_H
#define LINUX_26_26_COMPAT_H

#include <linux/autoconf.h>
#include <linux/version.h>
#include <linux/compat_autoconf.h>

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,26))

#include <linux/device.h>
#include <linux/list.h>
#include <linux/kernel.h>
#include <net/net_namespace.h>

/* This comes from include/linux/input.h */
#define SW_RFKILL_ALL           0x03  /* rfkill master switch, type "any"
					 set = radio enabled */

/* From kernel.h */
#define USHORT_MAX      ((u16)(~0U))
#define SHORT_MAX       ((s16)(USHORT_MAX>>1))
#define SHORT_MIN       (-SHORT_MAX - 1)

extern int dev_set_name(struct device *dev, const char *name, ...)
			__attribute__((format(printf, 2, 3)));

/**
 * clamp_t - return a value clamped to a given range using a given type
 * @type: the type of variable to use
 * @val: current value
 * @min: minimum allowable value
 * @max: maximum allowable value
 *
 * This macro does no typechecking and uses temporary variables of type
 * 'type' to make all the comparisons.
 */
#define clamp_t(type, val, min, max) ({		\
	type __val = (val);			\
	type __min = (min);			\
	type __max = (max);			\
	__val = __val < __min ? __min: __val;	\
	__val > __max ? __max: __val; })


/* from include/linux/device.h */
/* device_create_drvdata() is new */
extern struct device *device_create_drvdata(struct class *cls,
	struct device *parent,
	dev_t devt,
	void *drvdata,
	const char *fmt, ...)
__attribute__((format(printf, 5, 6)));

/* This is from include/linux/list.h */

/**
 * list_is_singular - tests whether a list has just one entry.
 * @head: the list to test.
 */
static inline int list_is_singular(const struct list_head *head)
{
	return !list_empty(head) && (head->next == head->prev);
}

/* This is from include/linux/device.h, which was added as of 2.6.26 */
static inline const char *dev_name(struct device *dev)
{
	/* will be changed into kobject_name(&dev->kobj) in the near future */
	return dev->bus_id;
}

/* This is from include/linux/kernel.h, which was added as of 2.6.26 */ 

/**
 * clamp_val - return a value clamped to a given range using val's type
 * @val: current value
 * @min: minimum allowable value
 * @max: maximum allowable value
 * 
 * This macro does no typechecking and uses temporary variables of whatever
 * type the input argument 'val' is.  This is useful when val is an unsigned
 * type and min and max are literals that will otherwise be assigned a signed
 * integer type.
 */ 

#define clamp_val(val, min, max) ({             \
	typeof(val) __val = (val);              \
	typeof(val) __min = (min);              \
	typeof(val) __max = (max);              \
	__val = __val < __min ? __min: __val;   \
	__val > __max ? __max: __val; })

/* This comes from include/net/net_namespace.h */

#ifdef CONFIG_NET_NS
static inline
int net_eq(const struct net *net1, const struct net *net2)
{
	return net1 == net2;
}
#else
static inline
int net_eq(const struct net *net1, const struct net *net2)
{
	return 1;
}
#endif

/* This comes from include/linux/netdevice.h */

/*
 * Net namespace inlines
 */
static inline
struct net *dev_net(const struct net_device *dev)
{
#ifdef CONFIG_NET_NS
	/*
	 * compat-wirelss backport note:
	 * For older kernels we may just need to always return init_net,
	 * not sure when we added dev->nd_net.
	 */
	return dev->nd_net;
#else
	return &init_net;
#endif
}


/*
 * 2.6.26 added its own unaligned API which the
 * new drivers can use. Lets port it here by including it in older
 * kernels and also deal with the architecture handling here.
 */

#ifdef CONFIG_ALPHA

#include <linux/unaligned/be_struct.h>
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* alpha */
#ifdef CONFIG_ARM

/* arm */
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/be_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* arm */
#ifdef CONFIG_AVR32

/*
 * AVR32 can handle some unaligned accesses, depending on the
 * implementation.  The AVR32 AP implementation can handle unaligned
 * words, but halfwords must be halfword-aligned, and doublewords must
 * be word-aligned.
 * 
 * However, swapped word loads must be word-aligned so we can't
 * optimize word loads in general.
 */ 

#include <linux/unaligned/be_struct.h>
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/generic.h>

#endif
#ifdef CONFIG_BLACKFIN

#include <linux/unaligned/le_struct.h>
#include <linux/unaligned/be_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* blackfin */
#ifdef CONFIG_CRIS

/*
 * CRIS can do unaligned accesses itself. 
 */
#include <linux/unaligned/access_ok.h>
#include <linux/unaligned/generic.h>

#endif /* cris */
#ifdef CONFIG_FRV

#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/be_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* frv */
#ifdef CONFIG_H8300

#include <linux/unaligned/be_memmove.h>
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* h8300 */
#ifdef  CONFIG_IA64

#include <linux/unaligned/le_struct.h>
#include <linux/unaligned/be_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* ia64 */
#ifdef CONFIG_M32R

#if defined(__LITTLE_ENDIAN__)
# include <linux/unaligned/le_memmove.h>
# include <linux/unaligned/be_byteshift.h>
# include <linux/unaligned/generic.h>
#else
# include <linux/unaligned/be_memmove.h>
# include <linux/unaligned/le_byteshift.h>
# include <linux/unaligned/generic.h>
#endif

#endif /* m32r */
#ifdef CONFIG_M68K /* this handles both m68k and m68knommu */

#ifdef CONFIG_COLDFIRE
#include <linux/unaligned/be_struct.h>
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/generic.h>
#else

/*
 * The m68k can do unaligned accesses itself.
 */
#include <linux/unaligned/access_ok.h>
#include <linux/unaligned/generic.h>
#endif

#endif /* m68k and m68knommu */
#ifdef CONFIG_MIPS

#if defined(__MIPSEB__)
# include <linux/unaligned/be_struct.h>
# include <linux/unaligned/le_byteshift.h>
# include <linux/unaligned/generic.h>
# define get_unaligned  __get_unaligned_be
# define put_unaligned  __put_unaligned_be
#elif defined(__MIPSEL__)
# include <linux/unaligned/le_struct.h>
# include <linux/unaligned/be_byteshift.h>
# include <linux/unaligned/generic.h>
#endif

#endif /* mips */
#ifdef CONFIG_MN10300

#include <linux/unaligned/access_ok.h>
#include <linux/unaligned/generic.h>

#endif /* mn10300 */
#ifdef CONFIG_PARISC

#include <linux/unaligned/be_struct.h>
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* parisc */
#ifdef CONFIG_PPC
/*
 * The PowerPC can do unaligned accesses itself in big endian mode.
 */ 
#include <linux/unaligned/access_ok.h>
#include <linux/unaligned/generic.h>

#endif /* ppc */
#ifdef CONFIG_S390

/*
 * The S390 can do unaligned accesses itself. 
 */
#include <linux/unaligned/access_ok.h>
#include <linux/unaligned/generic.h>

#endif /* s390 */
#ifdef CONFIG_SUPERH

/* SH can't handle unaligned accesses. */
#ifdef __LITTLE_ENDIAN__
# include <linux/unaligned/le_struct.h>
# include <linux/unaligned/be_byteshift.h>
# include <linux/unaligned/generic.h>
#else
# include <linux/unaligned/be_struct.h>
# include <linux/unaligned/le_byteshift.h>
# include <linux/unaligned/generic.h>
#endif

#endif /* sh - SUPERH */
#ifdef CONFIG_SPARC

/* sparc and sparc64 */
#include <linux/unaligned/be_struct.h>
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/generic.h>

#endif  /* sparc */
#ifdef CONFIG_UML

#include "asm/arch/unaligned.h"

#endif /* um - uml */
#ifdef CONFIG_V850

#include <linux/unaligned/be_byteshift.h>
#include <linux/unaligned/le_byteshift.h>
#include <linux/unaligned/generic.h>

#endif /* v850 */
#ifdef CONFIG_X86
/*
 * The x86 can do unaligned accesses itself.
 */
#include <linux/unaligned/access_ok.h>
#include <linux/unaligned/generic.h>

#endif /* x86 */
#ifdef CONFIG_XTENSA

#ifdef __XTENSA_EL__
# include <linux/unaligned/le_memmove.h>
# include <linux/unaligned/be_byteshift.h>
# include <linux/unaligned/generic.h>
#elif defined(__XTENSA_EB__)
# include <linux/unaligned/be_memmove.h>
# include <linux/unaligned/le_byteshift.h>
# include <linux/unaligned/generic.h>
#else
# error processor byte order undefined!
#endif

#endif /* xtensa */

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,26)) */

#endif /* LINUX_26_26_COMPAT_H */
