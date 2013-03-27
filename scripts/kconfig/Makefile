export COMPAT_BASE=$(shell cat $(PWD)/.compat_base)
export COMPAT_BASE_TREE=$(shell cat $(PWD)/.compat_base_tree)
export COMPAT_BASE_TREE_VERSION=$(shell cat $(PWD)/.compat_base_tree_version)
export COMPAT_PROJECT=compat-drivers
export COMPAT_VERSION=$(shell cat $(PWD)/.compat_version)

menuconfig:
	gcc -Wp,-MD,scripts/kconfig/.conf.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/conf.o scripts/kconfig/conf.c
	gcc -Wp,-MD,scripts/kconfig/lxdialog/.checklist.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/lxdialog/checklist.o scripts/kconfig/lxdialog/checklist.c
	gcc -Wp,-MD,scripts/kconfig/lxdialog/.inputbox.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/lxdialog/inputbox.o scripts/kconfig/lxdialog/inputbox.c
	gcc -Wp,-MD,scripts/kconfig/lxdialog/.menubox.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/lxdialog/menubox.o scripts/kconfig/lxdialog/menubox.c
	gcc -Wp,-MD,scripts/kconfig/lxdialog/.textbox.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/lxdialog/textbox.o scripts/kconfig/lxdialog/textbox.c
	gcc -Wp,-MD,scripts/kconfig/lxdialog/.util.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/lxdialog/util.o scripts/kconfig/lxdialog/util.c
	gcc -Wp,-MD,scripts/kconfig/lxdialog/.yesno.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/lxdialog/yesno.o scripts/kconfig/lxdialog/yesno.c
	gcc -Wp,-MD,scripts/kconfig/.mconf.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/mconf.o scripts/kconfig/mconf.c
	gcc -Wp,-MD,scripts/kconfig/.zconf.tab.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -DCURSES_LOC="<ncurses.h>" -DLOCALE  -Iscripts/kconfig -c -o scripts/kconfig/zconf.tab.o scripts/kconfig/zconf.tab.c
	gcc  -o scripts/kconfig/mconf scripts/kconfig/mconf.o scripts/kconfig/zconf.tab.o scripts/kconfig/lxdialog/checklist.o scripts/kconfig/lxdialog/util.o scripts/kconfig/lxdialog/inputbox.o scripts/kconfig/lxdialog/textbox.o scripts/kconfig/lxdialog/yesno.o scripts/kconfig/lxdialog/menubox.o  -lncurses
	./scripts/kconfig/mconf Kconfig
