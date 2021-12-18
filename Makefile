.PHONY: nothing
nothing : ;

.PHONY: up
up : 
	docker-compose --project-directory ./docker up -d

.PHONY: stop
stop: 
	docker-compose --project-directory ./docker stop

.PHONY: all
all : ui-image post-image comment-image cloudprober-image prometheus-image

.PHONY: ui-image
ui-image : set-envs ./src/ui/docker_build.sh ./src/ui/*
	cd ./src/ui && bash docker_build.sh && cd ../..

.PHONY: post-image
post-image : set-envs ./src/post-py/*
	cd ./src/post-py && bash docker_build.sh && cd ../..

.PHONY: comment-image
comment-image : set-envs ./src/comment/docker_build.sh ./src/comment/*
	cd ./src/comment && bash docker_build.sh && cd ../..

.PHONY: cloudprober-image
cloudprober-image : set-envs ./monitoring/cloudprober/*
	docker build -t $$USER_NAME/cloudprober ./monitoring/cloudprober/

.PHONY: prometheus-image
prometheus-image : set-envs ./monitoring/prometheus/*
	docker build -t $$USER_NAME/prometheus ./monitoring/prometheus/

.PHONY: push-images
push-images : set-envs push-ui push-comment push-post push-prometheus push-cloudprober

.PHONY: push-ui
push-ui : docker-login
	docker push $$USER_NAME/ui

.PHONY: push-comment
push-comment : docker-login
	docker push $$USER_NAME/comment

.PHONY: push-post
push-post : docker-login
	docker push $$USER_NAME/post

.PHONY: push-prometheus
push-prometheus : docker-login
	docker push $$USER_NAME/prometheus

.PHONY: push-cloudprober
push-cloudprober : docker-login
	docker push $$USER_NAME/cloudprober

.PHONY: docker-login
docker-login : 
	docker login

.PHONY: set-envs
set-envs :
	eval $(docker-machine env docker-host)
	export USER_NAME=vlyulin

