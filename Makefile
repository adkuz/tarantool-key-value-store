docker_name := ax_tarantool
docker_tag  := 1
container_name := ax_tarantool_instance
src_dir := src
run_flags := --rm -it 




docker:
	docker build -t ${docker_name}:${docker_tag} -f Dockerfile ./
	
run: 
	docker run ${run_flags} --name ${container_name} \
		-p 80:80 \
		--network="host" \
        ${docker_name}:${docker_tag}

stop:
	docker stop ${container_name}
