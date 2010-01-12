#ifndef LINUX_26_25_COMPAT_H
#define LINUX_26_25_COMPAT_H

#include <linux/autoconf.h>
#include <linux/version.h>
#include <linux/compat_autoconf.h>

/* Compat work for 2.6.24 */
#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,25))

#include <linux/types.h>
#include <linux/io.h>
#include <linux/hw_random.h>
#include <linux/leds.h>
#include <linux/kernel.h>
#include <linux/netdevice.h>
#include <linux/pm.h>
#include <asm-generic/bug.h>
#include <linux/pm_qos_params.h>

int compat_pm_qos_power_init(void);
int compat_pm_qos_power_deinit(void);

/*
 * 2.6.25 adds PM_EVENT_HIBERNATE as well here but
 * we don't have this on <= 2.6.23)
 */
#define PM_EVENT_SLEEP  (PM_EVENT_SUSPEND)

/* Although we don't care about wimax this is needed for rfkill input stuff */
#define KEY_WIMAX		246

/* Although pm_qos stuff is not implemented on <= 2.6.24 lets keep the define */
#define PM_QOS_DEFAULT_VALUE -1

#define __WARN(foo) dump_stack()

#define dev_emerg(dev, format, arg...)          \
	dev_printk(KERN_EMERG , dev , format , ## arg)
#define dev_alert(dev, format, arg...)          \
	dev_printk(KERN_ALERT , dev , format , ## arg)
#define dev_crit(dev, format, arg...)           \
	dev_printk(KERN_CRIT , dev , format , ## arg)

extern int		__dev_addr_sync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,24))
#define seq_file_net &init_net;
#else
#define seq_file_net NULL
#endif

/* The patch:
 * commit 8b5f6883683c91ad7e1af32b7ceeb604d68e2865
 * Author: Marcin Slusarz <marcin.slusarz@gmail.com>
 * Date:   Fri Feb 8 04:20:12 2008 -0800
 *
 *     byteorder: move le32_add_cpu & friends from OCFS2 to core
 *
 * moves le*_add_cpu and be*_add_cpu functions from OCFS2 to core
 * header (1st) and converted some existing code to it. We port
 * it here as later kernels will most likely use it.
 */
static inline void le16_add_cpu(__le16 *var, u16 val)
{
	*var = cpu_to_le16(le16_to_cpu(*var) + val);
}

static inline void le32_add_cpu(__le32 *var, u32 val)
{
	*var = cpu_to_le32(le32_to_cpu(*var) + val);
}

static inline void le64_add_cpu(__le64 *var, u64 val)
{
	*var = cpu_to_le64(le64_to_cpu(*var) + val);
}

static inline void be16_add_cpu(__be16 *var, u16 val)
{
	u16 v = be16_to_cpu(*var);
	*var = cpu_to_be16(v + val);
}

static inline void be32_add_cpu(__be32 *var, u32 val)
{
	u32 v = be32_to_cpu(*var);
	*var = cpu_to_be32(v + val);
}

static inline void be64_add_cpu(__be64 *var, u64 val)
{
	u64 v = be64_to_cpu(*var);
	*var = cpu_to_be64(v + val);
}

/* 2.6.25 changes hwrng_unregister()'s behaviour by supporting 
 * suspend of its parent device (the misc device, which is itself the
 * hardware random number generator). It does this by passing a parameter to
 * unregister_miscdev() which is not supported in older kernels. The suspend
 * parameter allows us to enable access to the device's hardware
 * number generator during suspend. As far as wireless is concerned this means
 * if a driver goes to suspend it you won't have the HNR available in
 * older kernels. */
static inline void __hwrng_unregister(struct hwrng *rng, bool suspended)
{
	hwrng_unregister(rng);
}

static inline void led_classdev_unregister_suspended(struct led_classdev *lcd)
{
	led_classdev_unregister(lcd);
}

/**
 * The following things are out of ./include/linux/kernel.h
 * The new iwlwifi driver is using them.
 */
extern int strict_strtoul(const char *, unsigned int, unsigned long *);
extern int strict_strtol(const char *, unsigned int, long *);

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,25)) */

#endif /* LINUX_26_25_COMPAT_H */
