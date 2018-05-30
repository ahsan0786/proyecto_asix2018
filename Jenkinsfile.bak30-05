env.DOCKERHUB_USERNAME = 'ahsan0786'
  node("docker-test") {
    checkout scm
    stage("Testing imagenes") {
      try {
        sh " docker run --restart=always --name mysql -p 3307:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql "
     sh "docker run --rm --name wordpress --link mysql:mysql -p 8081:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress"
		}
      catch(e) {
        error "Integration Test failed"
      }finally {
        sh "docker rm -f wordpress || true"
        sh "docker rm -f mysql || true"
        sh "docker ps -aq | xargs docker rm || true"
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
	sh "docker run --rm --name wordpress --link mysql:mysql -p 8081:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress"
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
         SERVICES=$(docker service ls --filter name=wordpress-mysql --quiet | wc -l)
          if [[ "$SERVICES" -eq 0 ]]; then
		if [[ -d ${HOME}/proyecto_asix2018/ ]]; then 
                        cd ${HOME}/proyecto_asix2018/cliente
                        docker stack deploy -c docker-compose.traefik.yml traefik
                        docker stack deploy -c docker-compose.webapps.yml dns-jenkins
                        docker stack deploy -c ./swarmprom/docker-compose.yml mon
		else
                        cd ${HOME}
                        git clone https://github.com/ahsan0786/proyecto_asix2018.git
                        cd ${HOME}/proyecto_asix2018/cliente
                        docker stack deploy -c docker-compose.traefik.yml traefik
                        docker stack deploy -c docker-compose.webapps.yml dns-jenkins
                        docker stack deploy -c ./swarmprom/docker-compose.yml mon
		fi
          else
                if [[ -d ${HOME}/proyecto_asix2018/ ]]; then
                        docker config rm mon_dockerd_config || true
                        docker config rm mon_node_rules || true
                        docker config rm mon_task_rules || true
                        docker config rm traefik_nginx_conf || true
                        docker config rm traefik_traefik_toml_v2 || true
                        docker secret rm traefik_traefik_cert || true
                        docker secret rm traefik_traefik_key || true
                        docker network create -d overlay proxy
                        cd ${HOME}/proyecto_asix2018/cliente
                        docker stack deploy -c docker-compose.traefik.yml traefik
                        docker stack deploy -c docker-compose.webapps.yml dns-jenkins
                        docker stack deploy -c ./swarmprom/docker-compose.yml mon
                else
                        cd ${HOME}
                        git clone https://github.com/ahsan0786/proyecto_asix2018.git
                        cd ${HOME}/proyecto_asix2018/cliente
                        docker config rm mon_dockerd_config || true
                        docker config rm mon_node_rules || true
                        docker config rm mon_task_rules || true
                        docker config rm traefik_nginx_conf || true
                        docker config rm traefik_traefik_toml_v2 || true
                        docker secret rm traefik_traefik_cert || true
                        docker secret rm traefik_traefik_key || true
                        docker network create -d overlay proxy
                        docker stack deploy -c docker-compose.traefik.yml traefik
                        docker stack deploy -c docker-compose.webapps.yml dns-jenkins
                        docker stack deploy -c ./swarmprom/docker-compose.yml mon
                fi
          fi
          '''
        checkout scm
      }catch(e) {
        error "Error en el nodo Prod"
      }
    }
  }
