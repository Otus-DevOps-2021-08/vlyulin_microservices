.PHONY: nothing
nothing : ;

.PHONY: up
up : 
	docker-compose --project-directory ./docker up -d

logging-1
.PHONY: logging-up
logging-up:
	docker-compose --project-directory ./docker --file ./docker/docker-compose-logging.yml --env-file ./docker/.env.logging up -d

.PHONY: bagged-up
bagged-up:
	docker-compose --project-directory ./docker --file ./docker/docker-compose-logging.yml --env-file ./docker/.env.bagged up -d

.PHONY: efk-up
efk-up: 
	docker-compose --project-directory ./docker --file ./docker/docker-compose-efk.yml up -d

.PHONY: stop
stop: 
	docker-compose --project-directory ./docker stop

.PHONY: efk-stop
efk-stop:
	docker-compose --project-directory ./docker --file ./docker/docker-compose-efk.yml stop

.PHONY: logging-stop
logging-stop:
	docker-compose --project-directory ./docker --file ./docker/docker-compose-logging.yml stop

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

.PHONY: bagged-images
bagged-images : ui-bagged-image post-bagged-image comment-bagged-image

.PHONY: ui-bagged-image
ui-bagged-image : set-envs ./src-bagged/ui/*
	cd ./src-bagged/ui && bash docker_build.sh && cd ../..

.PHONY: post-bagged-image
post-bagged-image : set-envs ./src-bagged/post-py/*
	cd ./src-bagged/post-py && bash docker_build.sh && cd ../..

.PHONY: comment-bagged-image
comment-bagged-image : set-envs ./src-bagged/comment/*
	cd ./src-bagged/comment && bash docker_build.sh && cd ../..

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

.PHONY: push-logging-images
push-logging-images : set-envs push-ui-logging push-comment-logging push-post-logging

.PHONY: push-ui-logging
push-ui-logging : docker-login
	docker push $$USER_NAME/ui:logging

.PHONY: push-comment-logging
push-comment-logging : docker-login
	docker push $$USER_NAME/comment:logging

.PHONY: push-post-logging
push-post-logging : docker-login
	docker push $$USER_NAME/post:logging

.PHONY: docker-login
docker-login : 
	docker login

.PHONY: set-envs
set-envs :
	eval $(docker-machine env logging)
	export USER_NAME=vlyulin

