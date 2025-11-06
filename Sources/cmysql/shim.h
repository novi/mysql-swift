#ifndef __CMYSQL_SHIM_H__
#define __CMYSQL_SHIM_H__

// Xcode 26.1 compatibility: Use absolute path for dependency scanner
#include "/opt/homebrew/opt/mysql-client/include/mysql/mysql.h"

#if LIBMYSQL_VERSION_ID >= 80000
typedef int my_bool;
#endif

#endif

