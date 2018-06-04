env.DOCKERHUB_USERNAME = 'ahsan0786'
  node("docker-test") {
    checkout scm
    stage("Testing imagenes") {
      try {
	sh "docker rm mysql --force || true"
	sh "docker rm wordpress -forece || true"
        sh " docker run --restart=always --name mysql -p 3307:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql "
     sh "docker run --rm --name wordpress --link mysql:mysql -p 8889:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress"
		}
      catch(e) {
        error "Integration Test failed"
      }finally {
        sh "docker rm -f wordpress || true"
        sh "docker rm -f mysql || true"
      }
    }
    stage("Publicacion de imagenes") {
      withDockerRegistry([credentialsId: 'DockerHub']) {
		sh "docker tag ahsan0786/proyecto_mysql ahsan0786/proyecto_mysql"
		sh "docker tag ahsan0786/proyecto_wordpress ahsan0786/proyecto_wordpress"
		sh "docker push ahsan0786/proyecto_mysql"
		sh "docker push ahsan0786/proyecto_wordpress"
      }
    }
  }

  node("docker-stage") {
    checkout scm

    stage("Testing contenedores") {
      try {
        sh " docker run --restart=always --name mysql -p 3307:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql "
	sh "docker run --rm --name wordpress --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress"
      } catch(e) {
        error "Staging failed"
      } finally {
		sh "docker stop mysql wordpress && docker rm mysql|| true"
	        sh "docker ps -aq | xargs docker rm || true"
		sh "docker rmi ahsan0786/proyecto_mysql"
		sh "docker rmi ahsan0786/proyecto_wordpress"
      }
    }
  }

  node("docker-prod") {
    stage("Production") {
      try {
        // comprueba si existe el servicio
        sh '''
         SERVICES=$(docker service ls --filter name=mysql --quiet | wc -l)
	 SERVICES1=$(docker service ls --filter name=wordpress --quiet | wc -l)
	 SERVICES2=$(docker service ls --filter name=portainer --quiet | wc -l)
          if [[ "$SERVICES" -eq 0 ]] && [[ "$SERVICES1" -eq 0 ]] && [[ "$SERVICES2" -eq 0 ]] ; then
		#docker network create -d overlay wordpress-mysql_db
		docker service create \
		--replicas 4 \
  		--network proxy \
  		--network wordpress-mysql_db \
  		--name wordpress \
  		--container-label "traefik.frontend.rule=Host:webservices.com" \
  		--container-label "traefik.docker.network=proxy" \
  		--container-label "traefik.port=80" \
		--container-label "traefik.enable=true" \
 		--container-label "traefik.backend.loadbalancer.sticky=true" \
  		--mount type=bind,source=/home/ubuntu/docker/containers/wordpress,destination=/var/www/html \
 	 	--env WORDPRESS_DB_HOST=mysql \
  		--env WORDPRESS_DB_USER=root \
  		--env WORDPRESS_DB_PASSWORD=Ausias123@@ \
  		--env WORDPRESS_DB_NAME=wordpress \
  		--restart-condition on-failure \
		 ahsan0786/proyecto_wordpress


		docker service create \
	 	--network proxy \
  		--name portainer \
  		--publish 9000:9000 \
  		--replicas=1 \
  		--constraint 'node.role == manager' \
  		--mode replicated \
  		--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  		--container-label "traefik.frontend.rule=Host:portainer.webservices.com" \
  		--container-label "traefik.docker.network=proxy" \
  		--container-label "traefik.port=9000" \
  		--container-label "traefik.enable=true" \
  		--restart-condition on-failure \
  		portainer/portainer
		docker service create --replicas 1 --name mysql --network proxy --network wordpress-mysql_db --name mysql -p 3306:3306 --mount type=bind,source=/home/ubuntu/docker/containers/mysql,destination=/var/lib/mysql --mount type=bind,source=/home/ubuntu/docker/containers/mysql-config/my.cnf,destination=/etc/mysql/my.cnf -e MYSQL_ROOT_PASSWORD=Ausias123@@ ahsan0786/proyecto_mysql		
          else
		docker service update --image ahsan0786/proyecto_mysql mysql
		docker service update --image ahsan0786/proyecto_wordpress wordpress
          fi
          '''
      }catch(e) {
        sh "docker service update --rollback  proyecto_mysql"
	sh "docker service update --rollback  proyecto_wordpress"
        error "Error en el nodo Prod"
      }
    }
  }
