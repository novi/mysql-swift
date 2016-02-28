BUILDOPTS=-Xlinker -L/usr/lib -Xcc -IPackages/CMySQL-1.0.0

SWIFTC=swiftc
SWIFT=swift
ifdef SWIFTPATH
    SWIFTC=$(SWIFTPATH)/bin/swiftc
    SWIFT=$(SWIFTPATH)/bin/swift
endif
OS := $(shell uname)
ifeq ($(OS),Darwin)
    SWIFTC=xcrun -sdk macosx swiftc
	BUILDOPTS=-Xlinker -L/usr/local/lib
endif

all: build test
	
build:
	$(SWIFT) build -v $(BUILDOPTS)
	
test:
	$(SWIFT) test
