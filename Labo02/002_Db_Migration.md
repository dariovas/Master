# Database migration

In this task you will migrate the Drupal database to the new RDS database instance.

![Schema](./img/CLD_AWS_INFA.PNG)

## Task 01 - Securing current Drupal data

### [Get Bitnami MariaDb user's password](https://docs.bitnami.com/aws/faq/get-started/find-credentials/)

```bash
[INPUT]
more /home/bitnami/bitnami_credentials

[OUTPUT]
Welcome to the Bitnami package for Drupal

******************************************************************************
The default username and password is 'user' and '*****'.
******************************************************************************

You can also use this password to access the databases and any other component t
he stack includes.

Please refer to https://docs.bitnami.com/ for more details.
```

### Get Database Name of Drupal

```bash
[INPUT]

mysql --user=root --password=****

show databases;

[OUTPUT]
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
6 rows in set (0.003 sec)
```

### [Dump Drupal DataBases](https://mariadb.com/kb/en/mariadb-dump/)

```bash
[INPUT]
mariadb-dump --user=root --password=**** bitnami_drupal > dump_drupal.sql

[OUTPUT]
ls -l
4839331 Mar 21 16:07 dump_drupal.sql
```

### Create the new Data base on RDS

```sql
[INPUT]
CREATE DATABASE bitnami_drupal;
```

### [Import dump in RDS db-instance](https://mariadb.com/kb/en/restoring-data-from-dump-files/)

Note : you can do this from the Drupal Instance. Do not forget to set the "-h" parameter.

```sql
[INPUT]
mysql -h dbi-devopsteam16.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u admin -p bitnami_drupal < dump_drupal.sql

[OUTPUT]
We can see that the tables have been correctly created in the bitnami_drupal database.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
| innodb             |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.001 sec)

MariaDB [(none)]> use bitnami_drupal;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [bitnami_drupal]> show tables;
+----------------------------------+
| Tables_in_bitnami_drupal         |
+----------------------------------+
| block_content                    |
| block_content__body              |
| block_content_field_data         |
| block_content_field_revision     |
| block_content_revision           |
| block_content_revision__body     |
| cache_bootstrap                  |
| cache_config                     |
| cache_container                  |
| cache_data                       |
| cache_default                    |
| cache_discovery                  |
| cache_dynamic_page_cache         |
| cache_entity                     |
| cache_menu                       |
| cache_page                       |
| cache_render                     |
| cache_toolbar                    |
| cachetags                        |
| comment                          |
| comment__comment_body            |
| comment_entity_statistics        |
| comment_field_data               |
| config                           |
| file_managed                     |
| file_usage                       |
| help_search_items                |
| history                          |
| key_value                        |
| menu_link_content                |
| menu_link_content_data           |
| menu_link_content_field_revision |
| menu_link_content_revision       |
| menu_tree                        |
| node                             |
| node__body                       |
| node__comment                    |
| node__field_image                |
| node__field_tags                 |
| node_access                      |
| node_field_data                  |
| node_field_revision              |
| node_revision                    |
| node_revision__body              |
| node_revision__comment           |
| node_revision__field_image       |
| node_revision__field_tags        |
| path_alias                       |
| path_alias_revision              |
| router                           |
| search_dataset                   |
| search_index                     |
| search_total                     |
| semaphore                        |
| sequences                        |
| sessions                         |
| shortcut                         |
| shortcut_field_data              |
| shortcut_set_users               |
| taxonomy_index                   |
| taxonomy_term__parent            |
| taxonomy_term_data               |
| taxonomy_term_field_data         |
| taxonomy_term_field_revision     |
| taxonomy_term_revision           |
| taxonomy_term_revision__parent   |
| user__roles                      |
| user__user_picture               |
| users                            |
| users_data                       |
| users_field_data                 |
| watchdog                         |
+----------------------------------+
72 rows in set (0.001 sec)
```

### [Get the current Drupal connection string parameters](https://www.drupal.org/docs/8/api/database-api/database-configuration)

```bash
[INPUT]
cat /bitnami/drupal/sites/default/settings.php 

[OUTPUT]
# if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
#   include $app_root . '/' . $site_path . '/settings.local.php';
# }
$databases['default']['default'] = array (
  'database' => 'bitnami_drupal',
  'username' => 'bn_drupal',
  'password' => 'b8887d29b3dd1045b2d7b3ccf0fc975ad88dd83f553aee27a1ce9439a1f9610b',
  'prefix' => '',
  'host' => '127.0.0.1',
  'port' => '3306',
  'isolation_level' => 'READ COMMITTED',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);
```

### Replace the current host with the RDS FQDN

```
//settings.php
cat /bitnami/drupal/sites/default/settings.php

$databases['default']['default'] = array (
   [...] 
  'host' => 'dbi-devopsteam16.cshki92s4w5p.eu-west-3.rds.amazonaws.com',
   [...] 
);
```

### [Create the Drupal Users on RDS Data base](https://mariadb.com/kb/en/create-user/)

Note : only calls from both private subnets must be approved.
* [By Password](https://mariadb.com/kb/en/create-user/#identified-by-password)
* [Account Name](https://mariadb.com/kb/en/create-user/#account-names)
* [Network Mask](https://cric.grenoble.cnrs.fr/Administrateurs/Outils/CalculMasque/)

```sql
[INPUT]
CREATE USER bn_drupal@'10.0.16.0/255.255.255.240' IDENTIFIED BY 'b8887d29b3dd1045b2d7b3ccf0fc975ad88dd83f553aee27a1ce9439a1f9610b';

GRANT ALL PRIVILEGES ON bitnami_drupal.* TO bn_drupal@'10.0.16.0/255.255.255.240';

FLUSH PRIVILEGES;
```

```sql
//validation
[INPUT]
SHOW GRANTS for bn_drupal@'10.0.16.0/255.255.255.240';

[OUTPUT]
+----------------------------------------------------------------------------------------------------------------------------------+
| Grants for bn_drupal@10.0.16.0/255.255.255.240                                                                                   |
+----------------------------------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `bn_drupal`@`10.0.16.0/255.255.255.240` IDENTIFIED BY PASSWORD '*7DB04C51C725BAE39C089FFF79067201429025FD' |
| GRANT ALL PRIVILEGES ON `bitnami_drupal`.* TO `bn_drupal`@`10.0.16.0/255.255.255.240`                                            |
+----------------------------------------------------------------------------------------------------------------------------------+
```

### Validate access (on the drupal instance)

```sql
[INPUT]
mysql -h dbi-devopsteam16.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u bn_drupal -p

[INPUT]
show databases;

[OUTPUT]
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
+--------------------+
2 rows in set (0.001 sec)
```

* Repeat the procedure to enable the instance on subnet 2 to also talk to your RDS instance.
