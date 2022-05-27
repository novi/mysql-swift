#ifndef __CMYSQL_SHIM_H__
#define __CMYSQL_SHIM_H__

#include <mysql/mysql.h>

#if LIBMYSQL_VERSION_ID >= 80000
typedef int my_bool;
#endif

void mysql_swift_set_ssl_option_disabled(MYSQL *mysql)
{
#ifndef LIBMARIADB
    unsigned int mode = SSL_MODE_DISABLED;
    mysql_options(mysql, MYSQL_OPT_SSL_MODE, &mode);
#endif
}

void mysql_swift_set_ssl_option_preferred(MYSQL *mysql)
{
#ifndef LIBMARIADB
    unsigned int mode = SSL_MODE_PREFERRED;
    mysql_options(mysql, MYSQL_OPT_SSL_MODE, &mode);
#endif
}

#endif

