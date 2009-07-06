/*
 * Copyright 2007	Luis R. Rodriguez <mcgrof@winlab.rutgers.edu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Compatibility file for Linux wireless for kernels 2.6.23.
 */

#include <net/compat.h>

/* All things not in 2.6.22 */
#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,23))

/* Part of net/core/dev_mcast.c as of 2.6.23. This is a slightly different version.
 * Since da->da_synced is not part of 2.6.22 we need to take longer route when 
 * syncing */

/**
 *	dev_mc_sync	- Synchronize device's multicast list to another device
 *	@to: destination device
 *	@from: source device
 *
 * 	Add newly added addresses to the destination device and release
 * 	addresses that have no users left. The source device must be
 * 	locked by netif_tx_lock_bh.
 *
 *	This function is intended to be called from the dev->set_multicast_list
 *	function of layered software devices.
 */
int dev_mc_sync(struct net_device *to, struct net_device *from)
{
	struct dev_addr_list *da, *next, *da_to;
	int err = 0;

	netif_tx_lock_bh(to);
	da = from->mc_list;
	while (da != NULL) {
		int synced = 0;
		next = da->next;
		da_to = to->mc_list;
		/* 2.6.22 does not have da->da_synced so lets take the long route */
		while (da_to != NULL) {
			if (memcmp(da_to->da_addr, da->da_addr, da_to->da_addrlen) == 0 &&
				da->da_addrlen == da_to->da_addrlen)
				synced = 1;
				break;
		}
		if (!synced) {
			err = __dev_addr_add(&to->mc_list, &to->mc_count,
					     da->da_addr, da->da_addrlen, 0);
			if (err < 0)
				break;
			da->da_users++;
		} else if (da->da_users == 1) {
			__dev_addr_delete(&to->mc_list, &to->mc_count,
					  da->da_addr, da->da_addrlen, 0);
			__dev_addr_delete(&from->mc_list, &from->mc_count,
					  da->da_addr, da->da_addrlen, 0);
		}
		da = next;
	}
	if (!err)
		__dev_set_rx_mode(to);
	netif_tx_unlock_bh(to);

	return err;
}
EXPORT_SYMBOL(dev_mc_sync);


/* Part of net/core/dev_mcast.c as of 2.6.23. This is a slighty different version. 
 * Since da->da_synced is not part of 2.6.22 we need to take longer route when 
 * unsyncing */

/**
 *      dev_mc_unsync   - Remove synchronized addresses from the destination
 *			  device
 *	@to: destination device
 *	@from: source device
 *
 *	Remove all addresses that were added to the destination device by
 *	dev_mc_sync(). This function is intended to be called from the
 *	dev->stop function of layered software devices.
 */
void dev_mc_unsync(struct net_device *to, struct net_device *from)
{
	struct dev_addr_list *da, *next, *da_to;

	netif_tx_lock_bh(from);
	netif_tx_lock_bh(to);

	da = from->mc_list;
	while (da != NULL) {
		bool synced = false;
		next = da->next;
		da_to = to->mc_list;
		/* 2.6.22 does not have da->da_synced so lets take the long route */
		while (da_to != NULL) {
			if (memcmp(da_to->da_addr, da->da_addr, da_to->da_addrlen) == 0 &&
				da->da_addrlen == da_to->da_addrlen)
				synced = true;
				break;
		}
		if (!synced) {
			da = next;
			continue;
		}
		__dev_addr_delete(&to->mc_list, &to->mc_count,
			da->da_addr, da->da_addrlen, 0);
		__dev_addr_delete(&from->mc_list, &from->mc_count,
			da->da_addr, da->da_addrlen, 0);
		da = next;
	}
	__dev_set_rx_mode(to);

	netif_tx_unlock_bh(to);
	netif_tx_unlock_bh(from);
}
EXPORT_SYMBOL(dev_mc_unsync);

/* Added as of 2.6.23 on net/core/dev.c. Slightly modifed, no dev->set_rx_mode on
 * 2.6.22 so ignore that. */

/*
 *	Upload unicast and multicast address lists to device and
 *	configure RX filtering. When the device doesn't support unicast
 *	filtering it is put in promiscous mode while unicast addresses
 *	are present.
 */
void __dev_set_rx_mode(struct net_device *dev)
{
	/* dev_open will call this function so the list will stay sane. */
	if (!(dev->flags&IFF_UP))
		return;

	if (!netif_device_present(dev))
		return;

/* This needs to be ported to 2.6.22 framework */
#if 0
	/* Unicast addresses changes may only happen under the rtnl,
	 * therefore calling __dev_set_promiscuity here is safe.
	 */
	if (dev->uc_count > 0 && !dev->uc_promisc) {
		__dev_set_promiscuity(dev, 1);
		dev->uc_promisc = 1;
	} else if (dev->uc_count == 0 && dev->uc_promisc) {
		__dev_set_promiscuity(dev, -1);
		dev->uc_promisc = 0;
	}
#endif

	if (dev->set_multicast_list)
		dev->set_multicast_list(dev);
}

#ifndef HAVE_PCI_SET_MWI
int pci_try_set_mwi(struct pci_dev *dev)
{
	return 0;
}
EXPORT_SYMBOL(pci_try_set_mwi);
#else

/**
 * pci_try_set_mwi - enables memory-write-invalidate PCI transaction
 * @dev: the PCI device for which MWI is enabled
 *
 * Enables the Memory-Write-Invalidate transaction in %PCI_COMMAND.
 * Callers are not required to check the return value.
 *
 * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
 */
int pci_try_set_mwi(struct pci_dev *dev)
{
	int rc = pci_set_mwi(dev);
	return rc;
}
EXPORT_SYMBOL(pci_try_set_mwi);
#endif

#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2,6,23)) */

