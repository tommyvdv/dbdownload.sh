# dbdownload.sh

## usage

```shell
dbdownload.sh host.prod tmp/
```

* connect using ssh
* use mysqldump
* download file
* remove remote file

## expects

```shell
$ tree tmp/
tmp
├── dbdownload.host.prod.conf
└── download
    └── ...
```

```shell
$ cat tmp/dbdownload.host.prod.conf
var_ssh_host=host.prod
var_mysql_database_host=localhost
var_mysql_database_name=database
var_mysql_database_user=user
var_mysql_database_password='xxxx'
var_mysql_options='--no-tablespaces --set-gtid-purged=OFF \
--ignore-table=database.shop_orders'
```

## delivers

```shell
$ tree tmp/
tmp
├── ...
└── download
    └── 20221108.host.prod.database.sql.gz
```
