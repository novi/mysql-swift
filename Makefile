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
	BUILD_OPTS=-Xlinker -L/usr/local/opt/mariadb/lib -Xlinker -L/usr/local/opt/openssl/lib -Xcc -I/usr/local/opt/mariadb/include -Xlinker -lmariadbclient -Xlinker -lssl -Xlinker -lcrypto -Xlinker -liconv -Xlinker -lz
endif

all: debug

release: CONF_ENV=release 
release: build_;

debug: CONF_ENV=debug
debug: build_;

build_:
	$(SWIFT) build --configuration $(CONF_ENV) $(BUILD_OPTS)
	
clean:
	$(SWIFT) package clean
	
distclean:
	$(SWIFT) package clean
	
test:
	$(SWIFT) test $(BUILD_OPTS)

genxcodeproj:
	$(SWIFT) package generate-xcodeproj --enable-code-coverage $(BUILD_OPTS) -Xswiftc -I/usr/local/opt/mariadb/include 
	
genxcodeproj31:
	$(SWIFT) package generate-xcodeproj --enable-code-coverage --xcconfig-overrides=Config.xcconfig