#ifndef __CMYSQL_SHIM_H__
#define __CMYSQL_SHIM_H__

#include <mysql/mysql.h>

#if LIBMYSQL_VERSION_ID >= 80000
typedef int my_bool;
#endif

#endif

