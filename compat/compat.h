#ifndef LINUX_26_COMPAT_H
#define LINUX_26_COMPAT_H

#include <linux/autoconf.h>
#include <linux/version.h>
#include <linux/compat_autoconf.h>

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,28))
#include <linux/if_ether.h>

#ifndef ETH_P_PAE
#define ETH_P_PAE 0x888E      /* Port Access Entity (IEEE 802.1X) */
#endif

#include <linux/pci.h>

void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar);

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,28)) */

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29))

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29)) */

#endif /* LINUX_26_COMPAT_H */
