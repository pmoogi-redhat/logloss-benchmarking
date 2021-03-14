# Makefile
all: deploy

deploy: build
	./deploy_logstress_to_openshift.sh

build:
	go build -ldflags "-s -w" check-logs-sequence.go
	go build -ldflags "-s -w" log-stressor.go
