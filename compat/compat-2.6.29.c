/*
 * Copyright 2007	Luis R. Rodriguez <mcgrof@winlab.rutgers.edu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Compatibility file for Linux wireless for kernels 2.6.29.
 */

#include <net/compat.h>

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29))

#include <linux/usb.h>

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,23))
/**
 * usb_unpoison_anchored_urbs - let an anchor be used successfully again
 * @anchor: anchor the requests are bound to
 *
 * Reverses the effect of usb_poison_anchored_urbs
 * the anchor can be used normally after it returns
 */
void usb_unpoison_anchored_urbs(struct usb_anchor *anchor)
{
	unsigned long flags;
	struct urb *lazarus;

	spin_lock_irqsave(&anchor->lock, flags);
	list_for_each_entry(lazarus, &anchor->urb_list, anchor_list) {
		usb_unpoison_urb(lazarus);
	}
	//anchor->poisoned = 0; /* XXX: cannot backport */
	spin_unlock_irqrestore(&anchor->lock, flags);
}
EXPORT_SYMBOL_GPL(usb_unpoison_anchored_urbs);
#endif

#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29) */

