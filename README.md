WSO2 API MANAGER 2.5.0 PATRON 1

En este repositorio vamos a desplegar una api manager con la vesion 2.5.0, la más actualizada  a día de hoy, 02/10/18.

Vamos a desplegar este pequeño script a través de docker, donde levantaremos 1 red y 3 contenedores, 1 mysql y 2  maquinas donde tendremos nuestras api manager

url: https://docs.wso2.com/display/AM250/Configuring+an+Active-Active+Deployment#ConfiguringanActive-ActiveDeployment-Step4-ConfigurethePublisherwiththeGateway

Parto de la documentación oficial, por si la quereis seguir, pero hay muchos pasos que no hago, por que para un entorno aislado, no me han hecho falta.

La infraestructura se levanta:
	- source arranque.sh

Eliminar la infraestrucutra:
	- source eliminar.sh
	- pide la contraseña para borrar 2 carpetas que se generan

Una vez arrancanda la infraestructura, nos conectamos a ellas y lanzamos los script:
	-  docker exec -it maq1 sh server.sh
	-  docker exec -it maq2 sh server.sh

Para ver las máquinas:
	- docker ps -a


rutas maq1 (9443):
	- https://localhost:9443/store
	- https://localhost:9443/publisher
	- https://localhost:9443/carbon

Para la maq2 es igual pero cambiado el 9443 por el 9453
Hay más puertos abierto que podeis ver.
