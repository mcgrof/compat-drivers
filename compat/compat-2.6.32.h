#ifndef LINUX_26_32_COMPAT_H
#define LINUX_26_32_COMPAT_H

#include <linux/autoconf.h>
#include <linux/version.h>
#include <linux/compat_autoconf.h>

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,32))

#include <linux/netdevice.h>
#include <linux/pm.h>
#include <net/iw_handler.h>

#define SDIO_VENDOR_ID_INTEL			0x0089
#define SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX	0x1402
#define SDIO_DEVICE_ID_INTEL_IWMC3200WIFI	0x1403
#define SDIO_DEVICE_ID_INTEL_IWMC3200TOP	0x1404
#define SDIO_DEVICE_ID_INTEL_IWMC3200GPS	0x1405
#define SDIO_DEVICE_ID_INTEL_IWMC3200BT		0x1406

/*
 * struct genl_multicast_group was made netns aware through
 * patch "genetlink: make netns aware" by johannes, we just
 * force this to always use the default init_net
 */
#define genl_info_net(x) &init_net
/* Just use init_net for older kernels */
#define get_net_ns_by_pid(x) &init_net

/* net namespace is lost */
#define genlmsg_multicast_netns(a, b, c, d, e)	genlmsg_multicast(b, c, d, e)
#define genlmsg_multicast_allns(a, b, c, d)	genlmsg_multicast(a, b, c, d)

#define dev_change_net_namespace(a, b, c) (-EOPNOTSUPP)

#define SET_NETDEV_DEVTYPE(netdev, type)

#ifdef __KERNEL__
/* Driver transmit return codes */
enum netdev_tx {
	BACKPORT_NETDEV_TX_OK = NETDEV_TX_OK,       /* driver took care of packet */
	BACKPORT_NETDEV_TX_BUSY = NETDEV_TX_BUSY,         /* driver tx path was busy*/
	BACKPORT_NETDEV_TX_LOCKED = NETDEV_TX_LOCKED,  /* driver tx lock was already taken */
};
typedef enum netdev_tx netdev_tx_t;
#endif /* __KERNEL__ */


/*
 * dev_pm_ops is only available on kernels >= 2.6.29, for
 * older kernels we rely on reverting the work to old
 * power management style stuff.
 */
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29))
/*
 * Use this if you want to use the same suspend and resume callbacks for suspend
 * to RAM and hibernation.
 */
#define SIMPLE_DEV_PM_OPS(name, suspend_fn, resume_fn) \
struct dev_pm_ops name = { \
	.suspend = suspend_fn, \
	.resume = resume_fn, \
	.freeze = suspend_fn, \
	.thaw = resume_fn, \
	.poweroff = suspend_fn, \
	.restore = resume_fn, \
}
#else
#define SIMPLE_DEV_PM_OPS(name, suspend_fn, resume_fn)
#endif /* >= 2.6.29 */

#define wireless_send_event(a, b, c, d) wireless_send_event(a, b, c, (char * ) d)

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,32)) */

#endif /* LINUX_26_32_COMPAT_H */
