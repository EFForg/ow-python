#
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2014 EFF
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-mini-eff
PKG_VERSION:=2.7.3
PKG_RELEASE:=4

PKG_SOURCE:=Python-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.python.org/ftp/python/$(PKG_VERSION)
PKG_MD5SUM:=62c4c1699170078c469f79ddfed21bc0

PKG_LICENSE:=PSF
PKG_LICENSE_FILES:=LICENSE Modules/_ctypes/libffi_msvc/LICENSE Modules/_ctypes/darwin/LICENSE Modules/_ctypes/libffi/LICENSE Modules/_ctypes/libffi_osx/LICENSE Tools/pybench/LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/Python-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Python-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=python/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
-include $(if $(DUMP),,./files/python-package.mk)

define Package/python-mini-eff/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python $(PYTHON_VERSION) programming language (EFF OpenWifi)
  URL:=http://www.python.org/
endef



define Package/python-mini-eff
$(call Package/python-mini-eff/Default)
  TITLE+= (minimal)
  DEPENDS:=+libpthread +zlib
endef

define Package/python-mini/description
$(call Package/python/Default/description)
  .
  This package contains only a minimal Python install, for EFF OpenWifi
endef


MAKE_FLAGS:=\
	$(TARGET_CONFIGURE_OPTS) \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	CROSS_COMPILE=yes \
	CFLAGS="$(TARGET_CFLAGS) -DNDEBUG -fno-inline" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LD="$(TARGET_CC)" \
	HOSTPYTHON=./hostpython \
	HOSTPGEN=./hostpgen

ENABLE_IPV6:=
ifeq ($(CONFIG_IPV6),y)
	ENABLE_IPV6 += --enable-ipv6
endif

define Build/Configure
	-$(MAKE) -C $(PKG_BUILD_DIR) distclean
	(cd $(PKG_BUILD_DIR); autoreconf --force --install || exit 0)
	# The python executable needs to stay in the rootdir since its location will
	# be used to compute the path of the config files.
	$(CP) $(STAGING_DIR_HOST)/bin/pgen $(PKG_BUILD_DIR)/hostpgen
	$(CP) $(STAGING_DIR_HOST)/bin/python$(PYTHON_VERSION) $(PKG_BUILD_DIR)/hostpython
	$(call Build/Configure/Default, \
		--sysconfdir=/etc \
		--disable-shared \
		--without-cxx-main \
		--with-threads \
		--with-system-ffi="$(STAGING_DIR)/usr" \
		$(ENABLE_IPV6) \
		ac_cv_have_chflags=no \
		ac_cv_have_lchflags=no \
		ac_cv_py_format_size_t=no \
		ac_cv_have_long_long_format=yes \
		ac_cv_buggy_getaddrinfo=no \
		OPT="$(TARGET_CFLAGS)" \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include $(1)/usr/lib
	$(INSTALL_DIR) $(STAGING_DIR)/mk/
	$(INSTALL_DATA) ./files/python-package.mk $(STAGING_DIR)/mk/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/python$(PYTHON_VERSION) \
		$(1)/usr/include/
	$(CP) \
		$(STAGING_DIR_HOST)/lib/python$(PYTHON_VERSION) \
		$(PKG_BUILD_DIR)/libpython$(PYTHON_VERSION).a \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON_VERSION)/config \
		$(1)/usr/lib/python$(PYTHON_VERSION)/

	$(CP) \
		$(STAGING_DIR_HOST)/bin/python$(PYTHON_VERSION) \
		$(1)/usr/bin/hostpython
	(cd $(2)/bin; \
	ln -sf ../../usr/bin/hostpython python$(PYTHON_VERSION); \
	ln -sf python$(PYTHON_VERSION) python)

	$(CP) \
		$(STAGING_DIR_HOST)/bin/python$(PYTHON_VERSION)-config \
		$(2)/bin/
	$(SED) 's,^#!.*,#!/usr/bin/env python$(PYTHON_VERSION),g' $(2)/bin/python$(PYTHON_VERSION)-config

	(cd $(2)/bin; \
	ln -sf python$(PYTHON_VERSION)-config python-config;)
endef


define PyPackage/python-mini-eff/filespec
+|/usr/bin/python$(PYTHON_VERSION)
+|/usr/lib/python$(PYTHON_VERSION)/__future__.py
+|/usr/lib/python$(PYTHON_VERSION)/_abcoll.py
+|/usr/lib/python$(PYTHON_VERSION)/abc.py
+|/usr/lib/python$(PYTHON_VERSION)/bisect.py
+|/usr/lib/python$(PYTHON_VERSION)/base64.py
+|/usr/lib/python$(PYTHON_VERSION)/collections.py
+|/usr/lib/python$(PYTHON_VERSION)/cgi.py
+|/usr/lib/python$(PYTHON_VERSION)/cgitb.py
+|/usr/lib/python$(PYTHON_VERSION)/chunk.py
+|/usr/lib/python$(PYTHON_VERSION)/compileall.py
+|/usr/lib/python$(PYTHON_VERSION)/ConfigParser.py
+|/usr/lib/python$(PYTHON_VERSION)/copy.py
+|/usr/lib/python$(PYTHON_VERSION)/copy_reg.py
+|/usr/lib/python$(PYTHON_VERSION)/dis.py
+|/usr/lib/python$(PYTHON_VERSION)/encodings/__init__.py
+|/usr/lib/python$(PYTHON_VERSION)/encodings/aliases.py
+|/usr/lib/python$(PYTHON_VERSION)/encodings/hex_codec.py
+|/usr/lib/python$(PYTHON_VERSION)/fnmatch.py
+|/usr/lib/python$(PYTHON_VERSION)/functools.py
+|/usr/lib/python$(PYTHON_VERSION)/genericpath.py
+|/usr/lib/python$(PYTHON_VERSION)/getopt.py
+|/usr/lib/python$(PYTHON_VERSION)/glob.py
+|/usr/lib/python$(PYTHON_VERSION)/hashlib.py
+|/usr/lib/python$(PYTHON_VERSION)/heapq.py
+|/usr/lib/python$(PYTHON_VERSION)/htmlentitydefs.py
+|/usr/lib/python$(PYTHON_VERSION)/inspect.py
+|/usr/lib/python$(PYTHON_VERSION)/io.py
+|/usr/lib/python$(PYTHON_VERSION)/json/__init__.py
+|/usr/lib/python$(PYTHON_VERSION)/json/decoder.py
+|/usr/lib/python$(PYTHON_VERSION)/json/encoder.py
+|/usr/lib/python$(PYTHON_VERSION)/json/scanner.py
+|/usr/lib/python$(PYTHON_VERSION)/json/tools.py
+|/usr/lib/python$(PYTHON_VERSION)/keyword.py
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_functools.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_collections.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_heapq.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_bisect.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/array.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/binascii.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/cStringIO.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/datetime.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/fcntl.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/grp.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/itertools.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_io.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/math.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/operator.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_random.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/select.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_socket.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/strop.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/_struct.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/syslog.so
+|/usr/lib/python$(PYTHON_VERSION)/lib-dynload/time.so
+|/usr/lib/python$(PYTHON_VERSION)/linecache.py
+|/usr/lib/python$(PYTHON_VERSION)/logging/__init__.py
+|/usr/lib/python$(PYTHON_VERSION)/logging/config.py
+|/usr/lib/python$(PYTHON_VERSION)/logging/handlers.py
+|/usr/lib/python$(PYTHON_VERSION)/mimetools.py
+|/usr/lib/python$(PYTHON_VERSION)/multiprocessing
+|/usr/lib/python$(PYTHON_VERSION)/opcode.py
+|/usr/lib/python$(PYTHON_VERSION)/optparse.py
+|/usr/lib/python$(PYTHON_VERSION)/os.py
+|/usr/lib/python$(PYTHON_VERSION)/pickle.py
+|/usr/lib/python$(PYTHON_VERSION)/pkgutil.py
+|/usr/lib/python$(PYTHON_VERSION)/popen2.py
+|/usr/lib/python$(PYTHON_VERSION)/posixpath.py
+|/usr/lib/python$(PYTHON_VERSION)/py_compile.py
+|/usr/lib/python$(PYTHON_VERSION)/random.py
+|/usr/lib/python$(PYTHON_VERSION)/repr.py
+|/usr/lib/python$(PYTHON_VERSION)/re.py
+|/usr/lib/python$(PYTHON_VERSION)/site.py
+|/usr/lib/python$(PYTHON_VERSION)/socket.py
+|/usr/lib/python$(PYTHON_VERSION)/sre_compile.py
+|/usr/lib/python$(PYTHON_VERSION)/sre_constants.py
+|/usr/lib/python$(PYTHON_VERSION)/sre_parse.py
+|/usr/lib/python$(PYTHON_VERSION)/sre.py
+|/usr/lib/python$(PYTHON_VERSION)/stat.py
+|/usr/lib/python$(PYTHON_VERSION)/StringIO.py
+|/usr/lib/python$(PYTHON_VERSION)/stringprep.py
+|/usr/lib/python$(PYTHON_VERSION)/string.py
+|/usr/lib/python$(PYTHON_VERSION)/struct.py
+|/usr/lib/python$(PYTHON_VERSION)/subprocess.py
+|/usr/lib/python$(PYTHON_VERSION)/sysconfig.py
+|/usr/lib/python$(PYTHON_VERSION)/tempfile.py
+|/usr/lib/python$(PYTHON_VERSION)/textwrap.py
+|/usr/lib/python$(PYTHON_VERSION)/tokenize.py
+|/usr/lib/python$(PYTHON_VERSION)/token.py
+|/usr/lib/python$(PYTHON_VERSION)/traceback.py
+|/usr/lib/python$(PYTHON_VERSION)/types.py
+|/usr/lib/python$(PYTHON_VERSION)/UserDict.py
+|/usr/lib/python$(PYTHON_VERSION)/urllib.py
+|/usr/lib/python$(PYTHON_VERSION)/urlparse.py
+|/usr/lib/python$(PYTHON_VERSION)/warnings.py
+|/usr/lib/python$(PYTHON_VERSION)/weakref.py
+|/usr/lib/python$(PYTHON_VERSION)/_weakrefset.py
+|/usr/lib/python$(PYTHON_VERSION)/config/Makefile
+|/usr/include/python$(PYTHON_VERSION)/pyconfig.h
endef

define PyPackage/python-mini-eff/install
	ln -sf python$(PYTHON_VERSION) $(1)/usr/bin/python
endef




$(eval $(call PyPackage,python-mini-eff))

$(eval $(call BuildPackage,python-mini-eff))
