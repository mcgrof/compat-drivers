export KMODDIR?=       updates
KMODDIR_ARG:=   "INSTALL_MOD_DIR=$(KMODDIR)"
ifneq ($(origin $(KLIB)), undefined)
KMODPATH_ARG:=  "INSTALL_MOD_PATH=$(KLIB)"
else
export KLIB:=          /lib/modules/$(shell uname -r)
endif
export KLIB_BUILD ?=	$(KLIB)/build
# Sometimes not available in the path
MODPROBE := /sbin/modprobe
MADWIFI=$(shell $(MODPROBE) -l ath_pci)
OLD_IWL=$(shell $(MODPROBE) -l iwl4965)

ifneq ($(KERNELRELEASE),)

include $(M)/$(COMPAT_CONFIG)

NOSTDINC_FLAGS := -I$(M)/include/ -include $(M)/include/net/compat.h $(CFLAGS)

obj-y := net/wireless/ net/mac80211/
ifeq ($(ONLY_CORE),)
obj-$(CONFIG_B44) += drivers/net/b44.o
obj-y += drivers/ssb/ \
	drivers/misc/eeprom/ \
	drivers/net/usb/ \
	drivers/net/wireless/
endif

else

export PWD :=	$(shell pwd)

# These exported as they are used by the scripts
# to check config and compat autoconf
export COMPAT_CONFIG=config.mk
export CONFIG_CHECK=.$(COMPAT_CONFIG)_md5sum.txt
export COMPAT_AUTOCONF=include/linux/compat_autoconf.h
export CREL=$(shell cat $(PWD)/compat-release)
export CREL_PRE:=.compat_autoconf_
export CREL_CHECK:=$(CREL_PRE)$(CREL)

include $(PWD)/$(COMPAT_CONFIG)

all: modules

modules: $(CREL_CHECK)
	@./scripts/check_config.sh
	$(MAKE) -C $(KLIB_BUILD) M=$(PWD) modules
	@touch $@

# With the above and this we make sure we generate a new compat autoconf per
# new relase of compat-wireless-2.6 OR when the user updates the 
# $(COMPAT_CONFIG) file
$(CREL_CHECK):
	@# Force to regenerate compat autoconf
	@rm -f $(CONFIG_CHECK)
	@./scripts/check_config.sh
	@touch $@
	@md5sum $(COMPAT_CONFIG) > $(CONFIG_CHECK)

install: uninstall modules
	$(MAKE) -C $(KLIB_BUILD) M=$(PWD) $(KMODDIR_ARG) $(KMODPATH_ARG) \
		modules_install
	@# All the scripts we can use
	@mkdir -p /usr/lib/compat-wireless/
	@install scripts/modlib.sh	/usr/lib/compat-wireless/
	@install scripts/madwifi-unload	/usr/sbin/
	@# This is to allow switching between drivers without blacklisting
	@install scripts/athenable	/usr/sbin/
	@install scripts/b43enable	/usr/sbin/
	@install scripts/iwl-enable	/usr/sbin/
	@install scripts/athload	/usr/sbin/
	@install scripts/b43load	/usr/sbin/
	@install scripts/iwl-load	/usr/sbin/
	@if [ ! -z $(MADWIFI) ]; then \
		echo ;\
		echo -n "Note: madwifi detected, we're going to disable it. "  ;\
		echo "If you would like to enable it later you can run:"  ;\
		echo "    sudo athenable madwifi"  ;\
		echo ;\
		echo Running athenable ath5k...;\
		/usr/sbin/athenable ath5k ;\
	fi
	@if [ ! -z $(OLD_IWL) ]; then \
		echo ;\
		echo -n "Note: iwl4965 detected, we're going to disable it. "  ;\
		echo "If you would like to enable it later you can run:"  ;\
		echo "    sudo iwl-load iwl4965"  ;\
		echo ;\
		echo Running iwl-enable iwlagn...;\
		/usr/sbin/iwl-enable iwlagn ;\
	fi
	@# If on distributions like Mandriva which like to
	@# compress their modules this will find out and do
	@# it for you. Reason is some old version of modutils
	@# won't know mac80211.ko should be used instead of
	@# mac80211.ko.gz
	@./scripts/compress_modules
	@/sbin/depmod -ae
	@echo
	@echo "Currently detected wireless subsystem modules:"
	@echo 
	@$(MODPROBE) -l mac80211
	@$(MODPROBE) -l cfg80211
	@$(MODPROBE) -l lib80211
	@$(MODPROBE) -l adm8211
	@$(MODPROBE) -l at76c50x-usb
	@$(MODPROBE) -l ath5k
	@$(MODPROBE) -l ath9k
	@$(MODPROBE) -l b43
	@$(MODPROBE) -l b43legacy
	@$(MODPROBE) -l b44
	@$(MODPROBE) -l ssb
	@$(MODPROBE) -l rc80211_simple
	@$(MODPROBE) -l iwlcore
	@$(MODPROBE) -l iwl3945
	@$(MODPROBE) -l iwlagn
	@$(MODPROBE) -l ipw2100
	@$(MODPROBE) -l ipw2200
	@$(MODPROBE) -l libipw
	@$(MODPROBE) -l lib80211
	@$(MODPROBE) -l lib80211_crypt
	@$(MODPROBE) -l libertas_cs
	@$(MODPROBE) -l libertas_tf
	@$(MODPROBE) -l libertas_tf_usb
	@$(MODPROBE) -l ub8xxx
	@$(MODPROBE) -l p54pci
	@$(MODPROBE) -l p54usb
	@$(MODPROBE) -l rt2400pci
	@$(MODPROBE) -l rt2500pci
	@$(MODPROBE) -l rt2500usb
	@$(MODPROBE) -l rt61pci
	@$(MODPROBE) -l rt73usb
	@$(MODPROBE) -l usbnet
	@$(MODPROBE) -l cdc_ether
	@$(MODPROBE) -l rndis_host
	@$(MODPROBE) -l rndis_wlan
	@$(MODPROBE) -l rtl8180
	@$(MODPROBE) -l rtl8187
	@$(MODPROBE) -l zd1211rw
	@echo 
	@echo Now run:
	@echo 
	@echo make unload
	@echo
	@echo And then load the wireless module you need. If unsure reboot.
	@echo

uninstall:
	@# New location, matches upstream
	@rm -rf $(KLIB)/$(KMODDIR)/net/mac80211/
	@rm -rf $(KLIB)/$(KMODDIR)/net/wireless/
	@rm -rf $(KLIB)/$(KMODDIR)/drivers/ssb/
	@rm -rf $(KLIB)/$(KMODDIR)/drivers/net/usb/
	@rm -rf $(KLIB)/$(KMODDIR)/drivers/net/wireless/
	@# Lets only remove the stuff we are sure we are providing
	@# on the misc directory.
	@rm -f $(KLIB)/$(KMODDIR)/drivers/misc/eeprom/eeprom_93cx6.ko*
	@rm -f $(KLIB)/$(KMODDIR)/drivers/misc/eeprom_93cx6.ko*
	@rm -f $(KLIB)/$(KMODDIR)/drivers/net/b44.ko*
	@/sbin/depmod -ae
	@echo
	@echo "Your old wireless subsystem modules were left intact:"
	@echo 
	@$(MODPROBE) -l mac80211
	@$(MODPROBE) -l cfg80211
	@$(MODPROBE) -l lib80211
	@$(MODPROBE) -l adm8211
	@$(MODPROBE) -l at76c50x-usb
	@$(MODPROBE) -l ath5k
	@$(MODPROBE) -l ath9k
	@$(MODPROBE) -l b43
	@$(MODPROBE) -l b43legacy
	@$(MODPROBE) -l b44
	@$(MODPROBE) -l ssb
	@$(MODPROBE) -l rc80211_simple
	@$(MODPROBE) -l iwlcore
	@$(MODPROBE) -l iwl3945
	@$(MODPROBE) -l iwlagn
	@$(MODPROBE) -l ipw2100
	@$(MODPROBE) -l ipw2200
	@$(MODPROBE) -l libipw
	@$(MODPROBE) -l lib80211
	@$(MODPROBE) -l lib80211_crypt
	@$(MODPROBE) -l libertas_cs
	@$(MODPROBE) -l libertas_tf
	@$(MODPROBE) -l libertas_tf_usb
	@$(MODPROBE) -l ub8xxx
	@$(MODPROBE) -l p54pci
	@$(MODPROBE) -l p54usb
	@$(MODPROBE) -l rt2400pci
	@$(MODPROBE) -l rt2500pci
	@$(MODPROBE) -l rt2500usb
	@$(MODPROBE) -l rt61pci
	@$(MODPROBE) -l rt73usb
	@$(MODPROBE) -l usbnet
	@$(MODPROBE) -l cdc_ether
	@$(MODPROBE) -l rndis_host
	@$(MODPROBE) -l rndis_wlan
	@$(MODPROBE) -l rtl8180
	@$(MODPROBE) -l rtl8187
	@$(MODPROBE) -l zd1211rw
	@
	@echo 

clean:
	@if [ -d net -a -d $(KLIB_BUILD) ]; then \
		$(MAKE) -C $(KLIB_BUILD) M=$(PWD) clean ;\
	fi
	@rm -f $(CREL_PRE)*
unload:
	@./scripts/unload.sh

load: unload
	@./scripts/load.sh

.PHONY: all clean install uninstall unload load

endif

clean-files += Module.symvers modules modules.order $(CREL_CHECK) $(CONFIG_CHECK)
