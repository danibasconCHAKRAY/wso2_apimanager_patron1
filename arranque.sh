#!/bin/bash
#wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.zip
#unzip mysql-connector-java-5.1.47.zip

#wget http://www.java2s.com/Code/JarDownload/sqljdbc4/sqljdbc4-2.0.jar.zip
#unzip sqljdbc4-2.0.jar.zip

#wget https://netix.dl.sourceforge.net/project/webolab/0.9/lib/ojdbc14.jar


docker build -t wso2_base:2.5.0 .
wget https://github.com/wso2/product-apim/releases/download/v2.5.0/wso2am-2.5.0.zip
unzip wso2am-2.5.0.zip .
docker network create wso2
cp -r wso2am-2.5.0/repository/deployment/ sin_deployment
docker run -d --hostname="maq1" --net=wso2 --name=maq1 -v $PWD/sin_deployment:/home/wso2am-2.5.0/repository/deployment -p 9443-9447:9443-9447 -p 82:8280 -p 8243:8243 wso2_base:2.5.0  /bin/sh -c "while true; do echo Hello world; sleep 1; done"
docker run -d --hostname="maq2" --net=wso2 --name=maq2 -v $PWD/sin_deployment:/home/wso2am-2.5.0/repository/deployment -p 9453-9457:9443-9447 -p 81:8280 -p 8253:8243 wso2_base:2.5.0  /bin/sh -c "while true; do echo Hello world; sleep 1; done"
docker run -d -p 3306:3306 --hostname="mysql" --net=wso2 --env MYSQL_ROOT_PASSWORD=root --name mysql -v $PWD/mysql:/var/lib/mysql  mysql:5.6


sleep 10s
docker cp wso2am-2.5.0/dbscripts/apimgt/mysql5.7.sql mysql:/mysql-api5.7.sql
docker cp wso2am-2.5.0/dbscripts/mb-store/mysql-mb.sql mysql:/
docker cp wso2am-2.5.0/dbscripts/mysql5.7.sql mysql:/mysql5.7.sql


docker exec mysql mysql -u root -proot -e 'create database apimgtdb'
docker exec mysql mysql -u root -proot -e 'create database userdb'
docker exec mysql mysql -u root -proot -e 'create database regdb'
docker exec mysql mysql -u root -proot -e 'create database statdb'
docker exec mysql mysql -u root -proot -e 'create database mbstoredb'

docker exec mysql mysql -u root -proot -e "GRANT ALL ON apimgtdb.* TO root@'%' IDENTIFIED BY 'root'"
docker exec mysql mysql -u root -proot -e "GRANT ALL ON userdb.* TO root@'%' IDENTIFIED BY 'root'"
docker exec mysql mysql -u root -proot -e "GRANT ALL ON regdb.* TO root@'%' IDENTIFIED BY 'root'"
docker exec mysql mysql -u root -proot -e "GRANT ALL ON statdb.* TO root@'%' IDENTIFIED BY 'root'"
docker exec mysql mysql -u root -proot -e "GRANT ALL ON mbstoredb.* TO root@'%' IDENTIFIED BY 'root'"

echo "mysql -u root -proot apimgtdb < mysql-api5.7.sql" > import.sh
echo "mysql -u root -proot userdb < mysql5.7.sql" >> import.sh
echo "mysql -u root -proot regdb < mysql5.7.sql" >> import.sh
echo "mysql -u root -proot statdb < mysql5.7.sql" >> import.sh
echo "mysql -u root -proot mbstoredb < mysql-mb.sql" >> import.sh


chmod +x import.sh
docker cp $PWD/import.sh mysql:/
docker exec mysql bash /import.sh
echo '''
127.0.0.1	localhost
::1	localhost ip2-localhost ip2-loopback
fe00::0	ip2-localnet
ff00::0	ip2-mcastprefix
ff02::1	ip2-allnodes
ff02::2	ip2-allrouters

''' > hosts

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Config.Hostname}}' $(docker ps -aq) >> hosts
for i in {1..3} ; do docker cp hosts  $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/ ; done

for i in {1..3} ; do docker cp script.sh  $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/ ; done

for i in {1..3} ; do docker exec -it  $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1) bash /script.sh ; done

for i in {1..3} ; do docker cp wso2am-2.5.0/  $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/ ; done


for i in {1..3} ; do docker exec -it $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1) mv wso2am-2.5.0 /home/$(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1)/ ; done

for i in {2..3} ; do docker exec -it $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1) rm /home/wso2am-2.5.0/repository/conf/datasources/master-datasources.xml ; done
for i in {2..3} ; do docker exec -it $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1) rm /home/wso2am-2.5.0/repository/conf/user-mgt.xml ; done
for i in {2..3} ; do docker exec -it $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1) rm /home/wso2am-2.5.0/repository/conf/registry.xml ; done
for i in {2..3} ; do docker exec -it $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1) rm /home/wso2am-2.5.0/repository/conf/api-manager.xml ; done

for i in {2..3} ; do docker cp master-datasources.xml $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/home/wso2am-2.5.0/repository/conf/datasources/master-datasources.xml ; done
for i in {2..3} ; do docker cp user-mgt.xml $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/home/wso2am-2.5.0/repository/conf/user-mgt.xml ;done
for i in {2..3} ; do docker cp registry.xml $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/home/wso2am-2.5.0/repository/conf/registry.xml ; done


for i in {2..3} ; do docker cp sqljdbc4-2.0.jar $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/home/wso2am-2.5.0/repository/components/lib/sqljdbc4-2.0.jar ;done
for i in {2..3} ; do docker cp mysql-connector-java-5.1.42-bin.jar $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/home/wso2am-2.5.0/repository/components/lib/mysql-connector-java-5.1.42-bin.jar ;done
for i in {2..3} ; do docker cp ojdbc14.jar $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/home/wso2am-2.5.0/repository/components/lib/ojdbc14.jar ; done

docker cp api-manager.xml-1 maq1:/home/wso2am-2.5.0/repository/conf/api-manager.xml
docker cp api-manager.xml-2 maq2:/home/wso2am-2.5.0/repository/conf/api-manager.xml

for i in {2..3} ; do docker cp server.sh  $(docker inspect -f '{{.Config.Hostname}}' $(docker ps -aq) | head -n $i | tail -n 1):/ ; done
echo '-----------'


# export CARBON_HOME=/home/wso2am-2.5.0/ ;  export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
# bash /home/wso2am-2.5.0/bin/wso2server.sh

