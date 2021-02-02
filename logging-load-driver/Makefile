#both podman or docker can be used to build a image from the specified Dockerfile, -t option is used to provide a tag to images built
all: build

Docker/loader: loader
	cp loader Docker/loader

build: Docker/loader
	podman build -t podman-logging-load-driver-image Docker
	docker build -t docker-logging-load-driver-image Docker
