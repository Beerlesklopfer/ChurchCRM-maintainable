VERSION="5.8.0"
PWD=$(shell pwd )
SOURCE=${PWD}/src
TARGET=${PWD}/ChurchCRM-${VERSION}

prepare:
	@sudo apt -y install php-cli php-curl php-gd php-mysql php-zip  php-xml wget
	@php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 2>&1 > /dev/null
	@php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	@php composer-setup.php  2>&1 > /dev/null
	@php -r "unlink('composer-setup.php');"  1>&2 > /dev/null
	@sudo mv composer.phar /usr/local/bin/composer 

	@wget -q https://nodejs.org/dist/v20.13.1/node-v20.13.1-linux-x64.tar.xz -O /tmp/node-v20.13.1.tar.gz 2>&1 > /dev/null
	@tar -xf /tmp/node-v20.13.1.tar.gz -C /tmp/
	
	@/tmp/node-v20.13.1-linux-x64/bin/npm install husk 1>&2 > /dev/null
	@/tmp/node-v20.13.1-linux-x64/bin/npm install run-s 1>&2 > /dev/null
	@cd ${SOURCE};  /tmp/node-v20.13.1-linux-x64/bin/npm run deploy 
	
common:
        ifeq ($(shell id -u), 0 )
	  echo "You are root, run this target as ordinary user, please"
	  exit 1
        endif
	@echo "Building package in ${TARGET}"
	@mkdir -p ${TARGET} ${TARGET}/etc 
	@for VER in 8.1 8.2 8.3 8.4; do \
	  mkdir -p ${TARGET}/etc/php/$$VER/fpm/pool.d; \
	  cp install/php-fpm/pool.d/churchcrm.conf ${TARGET}/etc/php/$$VER/fpm/pool.d/; done
	@mkdir -p ${TARGET}/usr/share/churchcrm/ChurchCRM-${VERSION}
	@mkdir -p ${TARGET}/usr/share/doc/ChurchCRM-${VERSION}
	@cp -arp ${PWD}/CHANGELOG.md ${PWD}/CONTRIBUTING.md  ${PWD}/README.md ${PWD}/install/examples/nginx ${PWD}/SECURITY.md ${TARGET}/usr/share/doc/ChurchCRM-${VERSION} 
	@cp -arp ${PWD}/install/examples/nginx ${TARGET}/etc/
	@cp  -arp src/* ${TARGET}/usr/share/churchcrm/ChurchCRM-${VERSION}
	@cp  -arp install/DEBIAN ${TARGET}
	@sed -i s/{{VERSION}}/${VERSION}/ ${TARGET}/DEBIAN/*
	@cp ${PWD}/CHANGELOG.md ${TARGET}/DEBIAN/changelog

all: prepare common

debian: common
	dpkg --build ${TARGET}

clean:
	rm -rf ${TARGET} ${TARGET}.deb

