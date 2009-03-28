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

#ifndef WARN_ONCE
#define WARN_ONCE(condition, format...) ({                      \
	static int __warned;                                    \
	int __ret_warn_once = !!(condition);                    \
								\
	if (unlikely(__ret_warn_once))                          \
		if (WARN(!__warned, format))                    \
			__warned = 1;                           \
	unlikely(__ret_warn_once);                              \
})
#endif /* From include/asm-generic/bug.h */

void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar);


/**
 *	__skb_queue_head_init - initialize non-spinlock portions of sk_buff_head
 *	@list: queue to initialize
 *
 *	This initializes only the list and queue length aspects of
 *	an sk_buff_head object.  This allows to initialize the list
 *	aspects of an sk_buff_head without reinitializing things like
 *	the spinlock.  It can also be used for on-stack sk_buff_head
 *	objects where the spinlock is known to not be used.
 */
static inline void __skb_queue_head_init(struct sk_buff_head *list)
{
	list->prev = list->next = (struct sk_buff *)list;
	list->qlen = 0;
}

static inline void __skb_queue_splice(const struct sk_buff_head *list,
				      struct sk_buff *prev,
				      struct sk_buff *next)
{
	struct sk_buff *first = list->next;
	struct sk_buff *last = list->prev;

	first->prev = prev;
	prev->next = first;

	last->next = next;
	next->prev = last;
}

/**
 *	skb_queue_splice_tail - join two skb lists and reinitialise the emptied list
 *	@list: the new list to add
 *	@head: the place to add it in the first list
 *
 *	Each of the lists is a queue.
 *	The list at @list is reinitialised
 */
static inline void skb_queue_splice_tail_init(struct sk_buff_head *list,
					      struct sk_buff_head *head)
{
	if (!skb_queue_empty(list)) {
		__skb_queue_splice(list, head->prev, (struct sk_buff *) head);
		head->qlen += list->qlen;
		__skb_queue_head_init(list);
	}
} /* From include/linux/skbuff.h */

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,28)) */

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29))

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29)) */

#endif /* LINUX_26_COMPAT_H */
