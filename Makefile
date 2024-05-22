VERSION="5.8.0"
PWD=$(shell pwd )
SOURCE=${PWD}/src
TARGET=${PWD}/ChurchCRM-${VERSION}

common:
        ifeq ($(shell id -u), 0 )
	  echo "You are root, run this target as ordinary user, please"
	  exit 1
        endif
	@echo "Building package in ${TARGET}"
	@mkdir -p ${TARGET}
	@mkdir -p ${TARGET}/usr/share/churchcrm/ChurchCRM-${VERSION}
	@mkdir -p ${TARGET}/usr/share/doc/ChurchCRM-${VERSION}
	@cp -arp ${PWD}/CHANGELOG.md ${PWD}/CONTRIBUTING.md  ${PWD}/README.md ${PWD}/install/examples/nginx ${PWD}/SECURITY.md -p ${TARGET}/usr/share/doc/ChurchCRM-${VERSION}
	@cp -arp src/* ${TARGET}/usr/share/churchcrm/ChurchCRM-${VERSION}
	@cp -arp install/DEBIAN ${TARGET}
	@sed -i s/{{VERSION}}/${VERSION}/ ${TARGET}/DEBIAN/control
	@cp ${PWD}/CHANGELOG.md ${TARGET}/DEBIAN/changelog
	@cd ${TARGET}/usr/share/churchcrm/ChurchCRM-${VERSION} && ${PWD}/install/composer.phar install

all: common

debian: common
	dpkg --build ${TARGET}

