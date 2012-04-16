#
# Enhanced Seccomp Library Makefile
#
# Copyright (c) 2012 Red Hat <pmoore@redhat.com>
# Author: Paul Moore <pmoore@redhat.com>
#

#
# This library is free software; you can redistribute it and/or modify it
# under the terms of version 2.1 of the GNU Lesser General Public License as
# published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library; if not, see <http://www.gnu.org/licenses>.
#

#
# macros
#

include macros.mk

#
# configuration
#

-include version_info.mk
-include configure.mk
include install.mk

#
# targets
#

CONFIGS = configure.mk configure.h version_info.mk
SUBDIRS_BUILD = src tests tools
SUBDIRS_INSTALL = src include doc

.PHONY: tarball install ctags cstags clean dist-clean $(SUBDIRS_BUILD)

all: $(SUBDIRS_BUILD)

$(CONFIGS): version_info
	@echo "INFO: automatically generating configuration ..."; \
	./configure

tarball: clean
	@ver=$(VERSION_RELEASE); \
	tarball=libseccomp-$$ver.tar.gz; \
	echo "INFO: creating the tarball ../$$tarball"; \
	tmp_dir=$$(mktemp -d /tmp/libseccomp.XXXXX); \
	rel_dir=$$tmp_dir/libseccomp-$$ver; \
	mkdir $$rel_dir; \
	tar cf - --exclude=*~ --exclude=.git* --exclude=.stgit* . | \
		(cd $$rel_dir; tar xf -); \
	(cd $$tmp_dir; tar zcf $$tarball libseccomp-$$ver); \
	mv $$tmp_dir/$$tarball ..; \
	rm -rf $$tmp_dir;

$(VERSION_HDR): version_info.mk
	@echo "INFO: creating the version header file"
	@hdr="$(VERSION_HDR)"; \
	echo "/* automatically generated - do not edit */" > $$hdr; \
	echo "#ifndef _VERSION_H" >> $$hdr; \
	echo "#define _VERSION_H" >> $$hdr; \
	echo "#define VERSION_RELEASE \"$(VERSION_RELEASE)\"" >> $$hdr; \
	echo "#endif" >> $$hdr;

$(SUBDIRS_BUILD): $(VERSION_HDR) $(CONFIGS)
	@echo "INFO: building in directory $@/ ..."
	@$(MAKE) -s -C $@

install: $(SUBDIRS_BUILD)
	@echo "INFO: installing in $(INSTALL_PREFIX) ..."
	@for dir in $(SUBDIRS_INSTALL); do \
		echo "INFO: installing from $$dir/"; \
		$(MAKE) -s -C $$dir install; \
	done

ctags:
	@echo "INFO: generating ctags for the project ..."
	@ctags -R *

cstags:
	@echo "INFO: generating cscope tags for the project ..."
	@find -iname *.[ch] > cscope.files
	@cscope -b -q -k

clean:
	@for dir in $(SUBDIRS_BUILD); do \
		echo "INFO: cleaning in $$dir/"; \
		$(MAKE) -s -C $$dir clean; \
	done

dist-clean: clean
	@echo "INFO: removing the configuration files"; \
	rm -f $(CONFIGS)
