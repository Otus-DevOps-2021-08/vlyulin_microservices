.PHONY: nothing
nothing : ;

.PHONY: up
up : 
	docker-compose --project-directory ./docker up -d

.PHONY: stop
stop: 
	docker-compose --project-directory ./docker stop

.PHONY: make-all
make-all : make-ui-image make-post-image make-comment-image make-prometheus-image

.PHONY: make-ui-image
make-ui-image : set-envs ./src/ui/docker_build.sh ./src/ui/*
	cd ./src/ui && bash docker_build.sh && cd ../..

.PHONY: make-post-image
make-post-image : set-envs ./src/post-py/docker_build.sh ./src/post-py/*
	cd ./src/post-py && bash docker_build.sh && cd ../..

.PHONY: make-comment-image
make-comment-image : set-envs ./src/comment/docker_build.sh ./src/comment/*
	cd ./src/comment && bash docker_build.sh && cd ../..

.PHONY: make-prometheus-image
make-prometheus-image : set-envs ./monitoring/prometheus/Dockerfile ./monitoring/prometheus/prometheus.yml
	docker build -t $$USER_NAME/prometheus ./monitoring/prometheus/

.PHONY: push-images
push-images : set-envs
	docker login
	docker push $$USER_NAME/ui
	docker push $$USER_NAME/comment
	docker push $$USER_NAME/post
	docker push $$USER_NAME/prometheus

.PHONY: set-envs
set-envs :
	eval $(docker-machine env docker-host)
	export USER_NAME=vlyulin

