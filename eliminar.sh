#!/bin/bash

docker stop maq1 maq2 mysql ; docker rm maq1 maq2 mysql
docker network rm wso2
echo "Borrando directorio de mysql y sincro_server (PERSISTENTE)"
sudo rm -rf mysql/ sin_deployment/
