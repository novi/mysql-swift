BUILD_OPTS=-Xlinker -L/usr/lib -Xlinker -lmysqlclient

SWIFTC=swiftc
SWIFT=swift
ifdef SWIFTPATH
	SWIFTC=$(SWIFTPATH)/bin/swiftc
	SWIFT=$(SWIFTPATH)/bin/swift
endif

OS := $(shell uname)
ifeq ($(OS),Darwin)
	SWIFTC=xcrun -sdk macosx swiftc
	BUILD_OPTS=-Xlinker -L/usr/local/opt/mariadb/lib -Xlinker -L/usr/local/opt/openssl/lib -Xcc -I/usr/local/include/mysql -Xcc -I/usr/local/include -Xlinker -lmysqlclient
endif

all: debug test

release: CONF_ENV=release 
release: build_;

debug: CONF_ENV=debug
debug: build_;

build_:
	$(SWIFT) build --configuration $(CONF_ENV) $(BUILD_OPTS)
	
clean:
	$(SWIFT) build --clean build
	
distclean:
	$(SWIFT) build --clean dist
	
test:
	$(SWIFT) test $(BUILD_OPTS)

