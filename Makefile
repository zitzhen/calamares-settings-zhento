#!/usr/bin/make -f

#SUBDIRS :=

all:
	# Desktop file
	(cd lubuntu/po/ && make)
	(cd kzhento/po/ && make)
	(cd ubuntuunity/po && make)
	# Slideshow
	(cd lubuntu/branding/lubuntu/lang/ && make)
	# basicwallpaper
	(cd common/basicwallpaper && mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make)
	# Lubuntu OEM setup stuff
	(cd lubuntu && mkdir oemconfig && cd oemconfig && mkdir -p usr/bin && mkdir -p etc/calamares && mkdir -p usr/share/xsessions && mkdir -p usr/libexec && mkdir -p etc && mkdir -p usr/share/applications && mkdir -p home/oem/Desktop)
	(cp lubuntu/calamares-logs-helper lubuntu/oemconfig/usr/bin/)
	(cp lubuntu/oem/sddm.conf lubuntu/oemconfig/etc/)
	(cp lubuntu/oem/sudoers.oem lubuntu/oemconfig/etc/ && chmod 400 lubuntu/oemconfig/etc/sudoers.oem)
	(cp lubuntu/oem/calamares-oemfinish.sh lubuntu/oemconfig/usr/libexec/)
	(cp lubuntu/oem/calamares-finish-oem lubuntu/oemconfig/usr/bin/)
	(cp lubuntu/oem/calamares-finish-oem.desktop lubuntu/oemconfig/usr/share/applications/)
	(cp -r lubuntu/branding lubuntu/oemconfig/etc/calamares/)
	(cp -r lubuntu/oem/modules/ lubuntu/oemconfig/etc/calamares/)
	(cp lubuntu/oem/settings.conf lubuntu/oemconfig/etc/calamares/)
	(cp lubuntu/oem/lubuntu-oem-env/lubuntu-oem-environment.desktop lubuntu/oemconfig/usr/share/xsessions/)
	(cp lubuntu/oem/lubuntu-oem-env/start-lubuntu-oem-env lubuntu/oemconfig/usr/libexec/)
	(cp common/basicwallpaper/build/basicwallpaper lubuntu/oemconfig/usr/bin/)
	(cp lubuntu/oem/calamares-finish-oem.desktop lubuntu/oemconfig/home/oem/Desktop/)
	(fakeroot bash -c "chown -R root:root lubuntu/oemconfig && tar cvzf lubuntu/oemconfig.tar.gz lubuntu/oemconfig")
	# Kubuntu OEM setup stuff
	(cd kzhento && mkdir oemconfig && cd oemconfig && mkdir -p usr/bin && mkdir -p etc/calamares && mkdir -p usr/share/wayland-sessions && mkdir -p usr/libexec && mkdir -p etc && mkdir -p usr/share/applications && mkdir -p home/oem/Desktop)
	(cp kzhento/calamares-logs-helper kzhento/oemconfig/usr/bin/)
	(cp kzhento/oem/sddm.conf kzhento/oemconfig/etc/)
	(cp kzhento/oem/sudoers.oem kzhento/oemconfig/etc/ && chmod 400 kzhento/oemconfig/etc/sudoers.oem)
	(cp kzhento/oem/calamares-oemfinish.sh kzhento/oemconfig/usr/libexec/)
	(cp kzhento/oem/calamares-finish-oem kzhento/oemconfig/usr/bin/)
	(cp kzhento/oem/calamares-finish-oem.desktop kzhento/oemconfig/usr/share/applications/)
	(cp -r kzhento/branding kzhento/oemconfig/etc/calamares/)
	(cp -r kzhento/oem/modules/ kzhento/oemconfig/etc/calamares/)
	(cp kzhento/oem/settings.conf kzhento/oemconfig/etc/calamares/)
	(cp kzhento/oem/kubuntu-oem-env/kubuntu-oem-environment.desktop kzhento/oemconfig/usr/share/wayland-sessions/)
	(cp kzhento/oem/kubuntu-oem-env/start-kubuntu-oem-env kzhento/oemconfig/usr/libexec/)
	(cp kzhento/oem/kubuntu-oem-env/kubuntu-oem-env-shim kzhento/oemconfig/usr/libexec/)
	(cp common/basicwallpaper/build/basicwallpaper kzhento/oemconfig/usr/bin/)
	(cp kzhento/oem/calamares-finish-oem.desktop kzhento/oemconfig/home/oem/Desktop/)
	(fakeroot bash -c "chown -R root:root kzhento/oemconfig && tar cvzf kzhento/oemconfig.tar.gz kzhento/oemconfig")
	# Ubuntu Unity OEM setup stuff
	(cd ubuntuunity && mkdir oemconfig && cd oemconfig && mkdir -p usr/bin && mkdir -p etc/calamares && mkdir -p usr/share/xsessions && mkdir -p usr/libexec && mkdir -p etc/lightdm && mkdir -p usr/share/applications && mkdir -p home/oem/Desktop)
	(cp ubuntuunity/calamares-logs-helper ubuntuunity/oemconfig/usr/bin/)
	(cp ubuntuunity/oem/lightdm.conf ubuntuunity/oemconfig/etc/lightdm/)
	(cp ubuntuunity/oem/sudoers.oem ubuntuunity/oemconfig/etc/ && chmod 400 ubuntuunity/oemconfig/etc/sudoers.oem)
	(cp ubuntuunity/oem/calamares-oemfinish.sh ubuntuunity/oemconfig/usr/libexec/)
	(cp ubuntuunity/oem/calamares-finish-oem ubuntuunity/oemconfig/usr/bin/)
	(cp ubuntuunity/oem/calamares-finish-oem.desktop ubuntuunity/oemconfig/usr/share/applications/)
	(cp -r ubuntuunity/branding ubuntuunity/oemconfig/etc/calamares/)
	(cp -r ubuntuunity/oem/modules/ ubuntuunity/oemconfig/etc/calamares/)
	(cp ubuntuunity/oem/settings.conf ubuntuunity/oemconfig/etc/calamares/)
	(cp ubuntuunity/oem/ubuntu-unity-oem-env/ubuntu-unity-oem-environment.desktop ubuntuunity/oemconfig/usr/share/xsessions/)
	(cp ubuntuunity/oem/ubuntu-unity-oem-env/start-ubuntu-unity-oem-env ubuntuunity/oemconfig/usr/libexec/)
	(cp common/basicwallpaper/build/basicwallpaper ubuntuunity/oemconfig/usr/bin/)
	(cp ubuntuunity/oem/calamares-finish-oem.desktop ubuntuunity/oemconfig/home/oem/Desktop/)
	(fakeroot bash -c "chown -R root:root ubuntuunity/oemconfig && tar cvzf ubuntuunity/oemconfig.tar.gz ubuntuunity/oemconfig")
	# Get rid of the unnecessary files
	find lubuntu/ -type f -iname "*.in" | xargs rm -f
	find lubuntu/ -type f -iname "Makefile" | xargs rm -f
	find kzhento/ -type f -iname "*.in" | xargs rm -f
	find kzhento/ -type f -iname "Makefile" | xargs rm -f
	find ubuntuunity/ -type f -iname "*.in" | xargs rm -f
	find ubuntuunity/ -type f -iname "Makefile" | xargs rm -f
	rm -rf kzhento/oemconfig
	rm -rf lubuntu/oemconfig
	rm -rf ubuntuunity/oemconfig
	rm -rf common/basicwallpaper/build
# vim:ts=4
