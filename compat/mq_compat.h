#ifndef MAC80211_MQ_COMPAT_H
#define MAC80211_MQ_COMPAT_H
#include "wme.h"
/*
 * Copyright 2008       Luis R. Rodriguez <lrodriguez@atheros.com>
 *
 * CONFIG_NETDEVICES_MULTIQUEUE backport support for kernels <= 2.6.22
 *
 * Older kernels we use the old skb callback queue as they don't support
 * CONFIG_NETDEVICES_MULTIQUEUE. CONFIG_NETDEVICES_MULTIQUEUE was
 * added in the kernel to help support on the network stack multiple
 * hardware TX queues.
 *
 * This is an internal mac80211 hack as its using internal mac80211 data
 * structures to keep track of queue for the skb.
 *
 * Please realize there is a penalty for using this -- you don't get
 * to schedule each hardware queue separately, so consider upgrading
 * for better performance on 802.11n. Since this is using what we *used*
 * to use this also of course means older kernels that weren't using MQ
 * support for 802.11n are also affected. This means <= 2.6.26.
 */

#define IEEE80211_DEV_TO_LOCAL(dev) \
	((struct ieee80211_local *)(IEEE80211_DEV_TO_SUB_IF(dev))->local)

/* This was stripped out after MQ patch for mac80211, let bring it
 * back to life */
enum ieee80211_link_state_t {
	IEEE80211_LINK_STATE_XOFF = 0,
	IEEE80211_LINK_STATE_PENDING,
};

/* Note: skb_[get|set]_queue_mapping() was added as of 2.6.24 in
 * include/linux/skbuff.h. We port this and add it into
 * include/net/mac80211.h through compat.diff as this could
 * be used by mac80211 drivers as well. We don't add it to
 * compat.h as we don't want things which require on
 * mac80211.h in compat.h */

/* These are helpers which used to be in mac80211 prior to
 * CONFIG_NETDEVICES_MULTIQUEUE being demanded for CONFIG_MAC80211_QOS
 * The way we fix this for older kernels is resort to the old work. */
static inline int __ieee80211_queue_stopped(struct ieee80211_local *local,
						int queue)
{
	return test_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
}

static inline int __ieee80211_queue_pending(const struct ieee80211_local *local,
						int queue)
{
	return test_bit(IEEE80211_LINK_STATE_PENDING, &local->state[queue]);
}

/* Internal mac80211 hack, note we remove "const" qualifier to net_device
 * to make compiler shutup as <= 2.6.22 doesn't set net_device as const on
 * netdev_priv() */
static inline int __netif_subqueue_stopped(struct net_device *dev,
					u16 queue_index)
{
	return __ieee80211_queue_stopped(IEEE80211_DEV_TO_LOCAL(dev), queue_index);
}

static inline int netif_subqueue_stopped(struct net_device *dev,
					struct sk_buff *skb)
{
	return __netif_subqueue_stopped(dev, skb_get_queue_mapping(skb));
}

/* we port this with the penalty performance that we schedule all queues
 * as well, this isn't exactly MQ support :). We port this to let
 * our compat.diff be smaller as well.
 * XXX: We can probably just run __netif_schedule() here */
static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
{
	if (!ieee80211_qdisc_installed(dev)) {
		if (queue_index == 0)
		netif_wake_queue(dev);
	} else
		__netif_schedule(dev);
}

/* Backport to use old internal mac80211 queue state. "const" qualifier
 * remvoved as netdev_priv() doesn't pass us a const in older kernels. */
static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
{
	set_bit(IEEE80211_LINK_STATE_XOFF,
		&IEEE80211_DEV_TO_LOCAL(dev)->state[queue_index]);
}

#endif /* MAC80211_MQ_COMPAT_H */
