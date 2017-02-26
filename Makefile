IMAGE_NAME ?= me/plumi-unofficial
CONTAINER_NAME ?= plumi
CONTAINER_HOSTNAME ?= plumi_server
EXTERNAL_STORAGE = /optional/host/volume/here

default:
	@echo "make [build|buildnew|run|clean|logs|shell|stop|kill]"

build:
	docker build --tag=${IMAGE_NAME}:latest .

buildnew:
	docker build --no-cache --tag=${IMAGE_NAME}:latest .

run:
	docker run -ti -h "${CONTAINER_HOSTNAME}" -d -v "${EXTERNAL_STORAGE}:/tmp/FIXME" -p 1080:80 --name=${CONTAINER_NAME} ${IMAGE_NAME}:latest /sbin/my_init /bin/bash

clean:
	@echo "docker rm -v ${CONTAINER_NAME}"
	@docker rm -v ${CONTAINER_NAME} >/dev/null || echo "Container removed already"
	@echo docker rmi ${IMAGE_NAME}:latest 
	@docker rmi ${IMAGE_NAME}:latest 2>/dev/null || echo "Image removed already"

logs:
	docker logs -f ${CONTAINER_NAME}

shell:
	docker exec -it ${CONTAINER_NAME} /bin/bash

stop:
	docker stop ${CONTAINER_NAME}

kill:
	docker kill ${CONTAINER_NAME}
	docker rm ${CONTAINER_NAME}

