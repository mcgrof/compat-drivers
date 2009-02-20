export

## NOTE
## Make sure to have each variable declaration start
## in the first column, no whitespace allowed.

ifeq ($(wildcard $(KLIB_BUILD)/.config),)
# These will be ignored by compat autoconf
 CONFIG_PCI=y
 CONFIG_USB=y
 CONFIG_PCMCIA=y
else
include $(KLIB_BUILD)/.config
endif

ifeq ($(CONFIG_MAC80211),y)
$(error "ERROR: you have MAC80211 compiled into the kernel, CONFIG_MAC80211=y, as such you cannot replace its mac80211 driver. You need this set to CONFIG_MAC80211=m. If you are using Fedora upgrade your kernel as later version should this set as modular. For further information on Fedora see https://bugzilla.redhat.com/show_bug.cgi?id=470143. If you are using your own kernel recompile it and make mac80211 modular")
endif

# We will warn when you don't have MQ support or NET_SCHED enabled.
#
# We could consider just quiting if MQ and NET_SCHED is disabled
# as I suspect all users of this package want 802.11e (WME) and
# 802.11n (HT) support.
ifeq ($(shell test -e $(KLIB_BUILD)/Makefile && echo yes),yes)
KERNEL_SUBLEVEL = $(shell $(MAKE) -C $(KLIB_BUILD) kernelversion | sed -n 's/^2\.6\.\([0-9]\+\).*/\1/p')

ifeq ($(shell test $(KERNEL_SUBLEVEL) -lt 27 && echo yes),yes)
$(error "ERROR: You should use compat-wireless-2.6-old for older kernels, this one is for kenrels >= 2.6.27")
endif

ifeq ($(CONFIG_CFG80211),y)
$(error "ERROR: your kernel has CONFIG_CFG80211=y, you should have it CONFIG_CFG80211=m if you want to use this thing.")
endif

# 2.6.27 has FTRACE_DYNAMIC borked, so we will complain if
# you have it enabled, otherwise you will very likely run into
# a kernel panic.
ifeq ($(shell test $(KERNEL_SUBLEVEL) -eq 27 && echo yes),yes)
ifeq ($(CONFIG_DYNAMIC_FTRACE),y)
$(error "ERROR: Your 2.6.27 kernel has CONFIG_DYNAMIC_FTRACE, please upgrade your distribution kernel as newer ones should not have this enabled (and if so report a bug) or remove this warning if you know what you are doing")
endif
endif

# This is because with CONFIG_MAC80211 include/linux/skbuff.h will
# enable on 2.6.27 a new attribute:
#
# skb->do_not_encrypt
#
# and on 2.6.28 another new attribute:
#
# skb->requeue
#
ifeq ($(shell test $(KERNEL_SUBLEVEL) -ge 27 && echo yes),yes)
ifeq ($(CONFIG_MAC80211),)
$(error "ERROR: Your >=2.6.27 kernel has CONFIG_MAC80211 disabled, you should have it CONFIG_MAC80211=m if you want to use this thing.")
endif
endif

ifneq ($(KERNELRELEASE),) # This prevents a warning

ifeq ($(CONFIG_NET_SCHED),)
 QOS_REQS_MISSING+=CONFIG_NET_SCHED
endif

ifeq ($(QOS_REQS_MISSING),) # if our dependencies match for MAC80211_QOS
CONFIG_MAC80211_QOS=y
else # Complain about our missing dependencies
$(warning "WARNING: You are running a kernel >= 2.6.23, you should enable in it $(QOS_REQS_MISSING) for 802.11[ne] support")
endif

endif # build check
endif # kernel Makefile check

# Wireless subsystem stuff
CONFIG_MAC80211=m
# CONFIG_MAC80211_DEBUGFS is not set

# choose between pid and minstrel as default rate control algorithm
CONFIG_MAC80211_RC_DEFAULT=minstrel
# This is the one used by our compat-wireless net/mac80211/rate.c
# in case you have and old kernel which is overriding this to pid.
CONFIG_COMPAT_MAC80211_RC_DEFAULT=minstrel
CONFIG_MAC80211_RC_PID=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_LEDS=y

# enable mesh networking too
CONFIG_MAC80211_MESH=y

CONFIG_CFG80211=m
# CONFIG_CFG80211_REG_DEBUG is not set

CONFIG_LIB80211=m
CONFIG_LIB80211_CRYPT_WEP=m
CONFIG_LIB80211_CRYPT_CCMP=m
CONFIG_LIB80211_CRYPT_TKIP=m

CONFIG_NL80211=y

# We'll disable this as soon major distributions
# start shipping this
CONFIG_WIRELESS_OLD_REGULATORY=y

# mac80211 test driver
CONFIG_MAC80211_HWSIM=m

# PCI Drivers
ifneq ($(CONFIG_PCI),)

CONFIG_ATH5K=m
# CONFIG_ATH5K_DEBUG is not set
CONFIG_ATH9K=m
# CONFIG_ATH9K_DEBUG is not set


CONFIG_IWLWIFI=m
CONFIG_IWLWIFI_LEDS=y
# CONFIG_IWLWIFI_RFKILL=y
CONFIG_IWLWIFI_SPECTRUM_MEASUREMENT=y
# CONFIG_IWLWIFI_DEBUG is not set
CONFIG_IWLAGN=m
CONFIG_IWL4965=y
CONFIG_IWL5000=y
CONFIG_IWL3945=m
CONFIG_IWL3945_SPECTRUM_MEASUREMENT=y
CONFIG_IWL3945_LEDS=y
# CONFIG_IWL3945_DEBUG is not set


CONFIG_B43=m
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_PIO=y
CONFIG_B43_LEDS=y
# CONFIG_B43_RFKILL=y
# CONFIG_B43_DEBUG is not set

CONFIG_B43LEGACY=m
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
# CONFIG_B43LEGACY_RFKILL=y
# CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
CONFIG_B43LEGACY_PIO=y
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set

# The Intel ipws
CONFIG_LIBIPW=m
# CONFIG_LIBIPW_DEBUG is not set

CONFIG_IPW2100=m
CONFIG_IPW2100_MONITOR=y
# CONFIG_IPW2100_DEBUG is not set
CONFIG_IPW2200=m
CONFIG_IPW2200_MONITOR=y
CONFIG_IPW2200_RADIOTAP=y
CONFIG_IPW2200_PROMISCUOUS=y
CONFIG_IPW2200_QOS=y
# CONFIG_IPW2200_DEBUG is not set
# The above enables use a second interface prefixed 'rtap'.
#           Example usage:
#
# % modprobe ipw2200 rtap_iface=1
# % ifconfig rtap0 up
# % tethereal -i rtap0
#
# If you do not specify 'rtap_iface=1' as a module parameter then
# the rtap interface will not be created and you will need to turn
# it on via sysfs:
#
# % echo 1 > /sys/bus/pci/drivers/ipw2200/*/rtap_iface

CONFIG_SSB_BLOCKIO=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y

CONFIG_P54_PCI=m

CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y

CONFIG_RTL8180=m

CONFIG_ADM8211=m
CONFIG_PCMCIA_ATMEL=m

CONFIG_RT2X00_LIB_PCI=m
CONFIG_RT2400PCI=m
CONFIG_RT2500PCI=m
CONFIG_RT2800PCI=m
NEED_RT2X00=y

# Two rt2x00 drivers require firmware: rt61pci and rt73usb. They depend on
# CRC to check the firmware. We check here first for the PCI
# driver as we're in the PCI section.
ifneq ($(CONFIG_CRC_ITU_T),)
CONFIG_RT61PCI=m
NEED_RT2X00_FIRMWARE=y
endif

CONFIG_ATMEL=m
CONFIG_PCI_ATMEL=m

endif
## end of PCI

# This is required for some cards
CONFIG_EEPROM_93CX6=m

# USB Drivers
ifneq ($(CONFIG_USB),)
CONFIG_ZD1211RW=m
# CONFIG_ZD1211RW_DEBUG is not set

# Sorry, rndis_wlan uses cancel_work_sync which is new and can't be done in compat...

# Wireless RNDIS USB support (RTL8185 802.11g) A-Link WL54PC
# All of these devices are based on Broadcom 4320 chip which
# is only wireless RNDIS chip known to date.
# Note: this depends on CONFIG_USB_NET_RNDIS_HOST and CONFIG_USB_NET_CDCETHER
# it also requires new RNDIS_HOST and CDC_ETHER modules which we add
CONFIG_USB_NET_RNDIS_HOST=m
CONFIG_USB_NET_RNDIS_WLAN=m
CONFIG_USB_NET_CDCETHER=m


CONFIG_P54_USB=m
CONFIG_RTL8187=m

CONFIG_AT76C50X_USB=m

# RT2500USB does not require firmware
CONFIG_RT2500USB=m
CONFIG_RT2800USB=m
CONFIG_RT2X00_LIB_USB=m
NEED_RT2X00=y
# RT73USB requires firmware
ifneq ($(CONFIG_CRC_ITU_T),)
CONFIG_RT73USB=m
NEED_RT2X00_FIRMWARE=y
endif

endif # end of USB driver list

# Common rt2x00 requirements
ifeq ($(NEED_RT2X00),y)
CONFIG_RT2X00=m
CONFIG_RT2X00_LIB=m
CONFIG_RT2X00_LIB_HT=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
# CONFIG_RT2X00_LIB_RFKILL=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
endif

ifeq ($(NEED_RT2X00_FIRMWARE),y)
CONFIG_RT2X00_LIB_FIRMWARE=y
endif

# p54
CONFIG_P54_COMMON=m


# Sonics Silicon Backplane
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
# CONFIG_SSB_DEBUG is not set

ifneq ($(CONFIG_USB),)
ifneq ($(CONFIG_LIBERTAS_THINFIRM_USB),m)
CONFIG_LIBERTAS_USB=m
NEED_LIBERTAS=y
endif
endif
ifneq ($(CONFIG_PCMCIA),)
CONFIG_LIBERTAS_CS=m
NEED_LIBERTAS=y
endif
ifeq ($(NEED_LIBERTAS),y)
CONFIG_LIBERTAS=m
# Libertas uses the old stack but not fully, it will soon 
# be cleaned.
endif

