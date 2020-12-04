all: build

Docker/loader: loader
	cp loader Docker/loader

build: Docker/loader
	podman build -t new-logging-load-driver Docker
