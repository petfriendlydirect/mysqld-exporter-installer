# mysqld-exporter-installer

Automatically download [Prometheus mysqld_exporter](https://github.com/prometheus/mysqld_exporter) latest tar.gz archive, unpack and configure for automatic startup (via systemd or upstart) on various platforms

Fork of [ClouDesire/node-exporter-installer](https://github.com/ClouDesire/node-exporter-installer)

## Usage

Create a user on the local database that can access everything it needs to. ( change the password )

```sql
CREATE USER 'exporter'@'localhost' IDENTIFIED WITH mysql_native_password BY 'XXXXXXXXX' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
FLUSH PRIVILEGES;
```

Install the script

```bash
curl -sSL https://raw.githubusercontent.com/petfriendlydirect/mysqld-exporter-installer/master/bin/install.sh | sudo sh
```

Update the datasource file with the correct credentials

```bash
sudo vim /etc/mysqld_exporter/datasource
```

Start the service

```bash
sudo systemctl start mysqld-exporter
# or
sudo start mysqld-exporter
```

The metrics endpoint should now be available at http://localhost:90104
