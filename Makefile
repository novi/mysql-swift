CMySQL=CMySQL-1.0.0
TARGET_TEST=MySQLTest

SWIFTC=swiftc
SWIFT=swift
ifdef SWIFTPATH
    SWIFTC=$(SWIFTPATH)/bin/swiftc
    SWIFT=$(SWIFTPATH)/bin/swift
endif
OS := $(shell uname)
ifeq ($(OS),Darwin)
    SWIFTC=xcrun -sdk macosx swiftc
endif

all: build test
	#
	
build:
	$(SWIFT) build
	
build-test: build
	$(SWIFTC) -I.build/debug Tests/*.swift -v -o .build/debug/$(TARGET_TEST) -IPackages/$(CMySQL) .build/debug/MySQL.build/*.o
	
test: build-test
	.build/debug/$(TARGET_TEST)
