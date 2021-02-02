all: build

Docker/loader: loader
	cp loader Docker/loader

build: Docker/loader
	podman build -t logging-load-driver Docker
