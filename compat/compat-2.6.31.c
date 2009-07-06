/*
 * Copyright 2007	Luis R. Rodriguez <mcgrof@winlab.rutgers.edu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Compatibility file for Linux wireless for kernels 2.6.31.
 */

#include <net/compat.h>

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,32))

#include <linux/netdevice.h>

int __dev_addr_add(struct dev_addr_list **list, int *count,
		   void *addr, int alen, int glbl)
{
	struct dev_addr_list *da;

	for (da = *list; da != NULL; da = da->next) {
		if (memcmp(da->da_addr, addr, da->da_addrlen) == 0 &&
		    da->da_addrlen == alen) {
			if (glbl) {
				int old_glbl = da->da_gusers;
				da->da_gusers = 1;
				if (old_glbl)
					return 0;
			}
			da->da_users++;
			return 0;
		}
	}

	da = kzalloc(sizeof(*da), GFP_ATOMIC);
	if (da == NULL)
		return -ENOMEM;
	memcpy(da->da_addr, addr, alen);
	da->da_addrlen = alen;
	da->da_users = 1;
	da->da_gusers = glbl ? 1 : 0;
	da->next = *list;
	*list = da;
	(*count)++;
	return 0;
}

int __dev_addr_delete(struct dev_addr_list **list, int *count,
		      void *addr, int alen, int glbl)
{
	struct dev_addr_list *da;

	for (; (da = *list) != NULL; list = &da->next) {
		if (memcmp(da->da_addr, addr, da->da_addrlen) == 0 &&
		    alen == da->da_addrlen) {
			if (glbl) {
				int old_glbl = da->da_gusers;
				da->da_gusers = 0;
				if (old_glbl == 0)
					break;
			}
			if (--da->da_users)
				return 0;

			*list = da->next;
			kfree(da);
			(*count)--;
			return 0;
		}
	}
	return -ENOENT;
}

int __dev_addr_sync(struct dev_addr_list **to, int *to_count,
		    struct dev_addr_list **from, int *from_count)
{
	struct dev_addr_list *da, *next;
	int err = 0;

	da = *from;
	while (da != NULL) {
		next = da->next;
		if (!da->da_synced) {
			err = __dev_addr_add(to, to_count,
					     da->da_addr, da->da_addrlen, 0);
			if (err < 0)
				break;
			da->da_synced = 1;
			da->da_users++;
		} else if (da->da_users == 1) {
			__dev_addr_delete(to, to_count,
					  da->da_addr, da->da_addrlen, 0);
			__dev_addr_delete(from, from_count,
					  da->da_addr, da->da_addrlen, 0);
		}
		da = next;
	}
	return err;
}
EXPORT_SYMBOL_GPL(__dev_addr_sync);

void __dev_addr_unsync(struct dev_addr_list **to, int *to_count,
		       struct dev_addr_list **from, int *from_count)
{
	struct dev_addr_list *da, *next;

	da = *from;
	while (da != NULL) {
		next = da->next;
		if (da->da_synced) {
			__dev_addr_delete(to, to_count,
					  da->da_addr, da->da_addrlen, 0);
			da->da_synced = 0;
			__dev_addr_delete(from, from_count,
					  da->da_addr, da->da_addrlen, 0);
		}
		da = next;
	}
}
EXPORT_SYMBOL_GPL(__dev_addr_unsync);

/**
 * genl_register_family_with_ops - register a generic netlink family
 * @family: generic netlink family
 * @ops: operations to be registered
 * @n_ops: number of elements to register
 *
 * Registers the specified family and operations from the specified table.
 * Only one family may be registered with the same family name or identifier.
 *
 * The family id may equal GENL_ID_GENERATE causing an unique id to
 * be automatically generated and assigned.
 *
 * Either a doit or dumpit callback must be specified for every registered
 * operation or the function will fail. Only one operation structure per
 * command identifier may be registered.
 *
 * See include/net/genetlink.h for more documenation on the operations
 * structure.
 *
 * This is equivalent to calling genl_register_family() followed by
 * genl_register_ops() for every operation entry in the table taking
 * care to unregister the family on error path.
 *
 * Return 0 on success or a negative error code.
 */
int genl_register_family_with_ops(struct genl_family *family,
	struct genl_ops *ops, size_t n_ops)
{
	int err, i;

	err = genl_register_family(family);
	if (err)
		return err;

	for (i = 0; i < n_ops; ++i, ++ops) {
		err = genl_register_ops(family, ops);
		if (err)
			goto err_out;
	}
	return 0;
err_out:
	genl_unregister_family(family);
	return err;
}
EXPORT_SYMBOL(genl_register_family_with_ops);

#endif /* (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,32)) */

