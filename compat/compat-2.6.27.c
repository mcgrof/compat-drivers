/*
 * Copyright 2007	Luis R. Rodriguez <mcgrof@winlab.rutgers.edu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Compatibility file for Linux wireless for kernels 2.6.27
 */

#include <net/compat.h>

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27))

/* rfkill notification chain */
#define RFKILL_STATE_CHANGED            0x0001  /* state of a normal rfkill
							switch has changed */

static BLOCKING_NOTIFIER_HEAD(rfkill_notifier_list);

/**
 * register_rfkill_notifier - Add notifier to rfkill notifier chain
 * @nb: pointer to the new entry to add to the chain
 *
 * See blocking_notifier_chain_register() for return value and further
 * observations.
 *
 * Adds a notifier to the rfkill notifier chain.  The chain will be
 * called with a pointer to the relevant rfkill structure as a parameter,
 * refer to include/linux/rfkill.h for the possible events.
 *
 * Notifiers added to this chain are to always return NOTIFY_DONE.  This
 * chain is a blocking notifier chain: notifiers can sleep.
 *
 * Calls to this chain may have been done through a workqueue.  One must
 * assume unordered asynchronous behaviour, there is no way to know if
 * actions related to the event that generated the notification have been
 * carried out already.
 */
int register_rfkill_notifier(struct notifier_block *nb)
{
	return blocking_notifier_chain_register(&rfkill_notifier_list, nb);
}
EXPORT_SYMBOL_GPL(register_rfkill_notifier);

/**
 * unregister_rfkill_notifier - remove notifier from rfkill notifier chain
 * @nb: pointer to the entry to remove from the chain
 *
 * See blocking_notifier_chain_unregister() for return value and further
 * observations.
 *
 * Removes a notifier from the rfkill notifier chain.
 */
int unregister_rfkill_notifier(struct notifier_block *nb)
{
	return blocking_notifier_chain_unregister(&rfkill_notifier_list, nb);
}
EXPORT_SYMBOL_GPL(unregister_rfkill_notifier);


static void notify_rfkill_state_change(struct rfkill *rfkill)
{
	blocking_notifier_call_chain(&rfkill_notifier_list,
			RFKILL_STATE_CHANGED,
			rfkill);
}

/**
 * rfkill_force_state - Force the internal rfkill radio state
 * @rfkill: pointer to the rfkill class to modify.
 * @state: the current radio state the class should be forced to.
 *
 * This function updates the internal state of the radio cached
 * by the rfkill class.  It should be used when the driver gets
 * a notification by the firmware/hardware of the current *real*
 * state of the radio rfkill switch.
 *
 * It may not be called from an atomic context.
 */
int rfkill_force_state(struct rfkill *rfkill, enum rfkill_state state)
{
	enum rfkill_state oldstate;

	if (state != RFKILL_STATE_SOFT_BLOCKED &&
	    state != RFKILL_STATE_UNBLOCKED &&
	    state != RFKILL_STATE_HARD_BLOCKED)
		return -EINVAL;

	mutex_lock(&rfkill->mutex);

	oldstate = rfkill->state;
	rfkill->state = state;

	if (state != oldstate)
		notify_rfkill_state_change(rfkill);

	mutex_unlock(&rfkill->mutex);

	return 0;
}
EXPORT_SYMBOL(rfkill_force_state);

#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27) */

