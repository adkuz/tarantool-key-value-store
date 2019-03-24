docker_name := ax4docker/ax_tarantool
docker_tag  := latest
container_name := ax_tarantool_instance
src_dir := src
run_flags := --rm -it -d

tarantool_log_file := tarantool.log


docker:
	docker build -t ${docker_name}:${docker_tag} -f Dockerfile ./
	
run: 
	docker run ${run_flags} --name ${container_name} \
		-p 127.0.0.1:80:80 \
		--net=host\
        ${docker_name}:${docker_tag}

stop:
	docker stop ${container_name}

nolan:
	docker exec --it  ${container_name} /bin/bash

log:
	docker exec -it  ${container_name}  cat ${tarantool_log_file}
