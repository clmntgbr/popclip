#!/usr/bin/env bash

include .env
export $(shell sed 's/=.*//' .env)

DOCKER_COMPOSE = docker compose -p $(ROOT_PROJECT_NAME)

CONTAINER_PHP := $(shell docker container ls -f "name=$(ROOT_PROJECT_NAME)-php" -q)
CONTAINER_VD := $(shell docker container ls -f "name=$(ROOT_PROJECT_NAME)-video-downloader" -q)
CONTAINER_SE := $(shell docker container ls -f "name=$(ROOT_PROJECT_NAME)-sound-extractor" -q)
CONTAINER_SG := $(shell docker container ls -f "name=$(ROOT_PROJECT_NAME)-subtitle-generator" -q)
CONTAINER_SM := $(shell docker container ls -f "name=$(ROOT_PROJECT_NAME)-subtitle-merger" -q)
CONTAINER_ST := $(shell docker container ls -f "name=$(ROOT_PROJECT_NAME)-subtitle-transformer" -q)

PHP := docker exec -ti $(CONTAINER_PHP)
PHP_SH := docker exec -ti $(CONTAINER_PHP) sh -c
VD := docker exec -ti $(CONTAINER_VD)
SE := docker exec -ti $(CONTAINER_SE)
SG := docker exec -ti $(CONTAINER_SG)
SM := docker exec -ti $(CONTAINER_SM)
ST := docker exec -ti $(CONTAINER_ST)

start:
	cd popclip-api && $(DOCKER_COMPOSE) up -d && cd ..
	cd popclip-video-downloader && $(DOCKER_COMPOSE) up -d && cd ..
	cd popclip-sound-extractor && $(DOCKER_COMPOSE) up -d && cd ..
	cd popclip-subtitle-generator && $(DOCKER_COMPOSE) up -d && cd ..
	cd popclip-subtitle-merger && $(DOCKER_COMPOSE) up -d && cd ..
	cd popclip-subtitle-transformer && $(DOCKER_COMPOSE) up -d && cd ..

stop:
	cd popclip-api && $(DOCKER_COMPOSE) down --remove-orphans && cd ..
	cd popclip-video-downloader && $(DOCKER_COMPOSE) down --remove-orphans && cd ..
	cd popclip-sound-extractor && $(DOCKER_COMPOSE) down --remove-orphans && cd ..
	cd popclip-subtitle-generator && $(DOCKER_COMPOSE) down --remove-orphans && cd ..
	cd popclip-subtitle-merger && $(DOCKER_COMPOSE) down --remove-orphans && cd ..
	cd popclip-subtitle-transformer && $(DOCKER_COMPOSE) down --remove-orphans && cd ..

build: 
	cd popclip-api && $(DOCKER_COMPOSE) build --pull --no-cache && cd ..
	cd popclip-video-downloader && $(DOCKER_COMPOSE) build --pull --no-cache && cd ..
	cd popclip-sound-extractor && $(DOCKER_COMPOSE) build --pull --no-cache && cd ..
	cd popclip-subtitle-generator && $(DOCKER_COMPOSE) build --pull --no-cache && cd ..
	cd popclip-subtitle-merger && $(DOCKER_COMPOSE) build --pull --no-cache && cd ..
	cd popclip-subtitle-transformer && $(DOCKER_COMPOSE) build --pull --no-cache && cd ..

fix:
	cd popclip-api && make php-cs-fixer && cd ..
	cd popclip-video-downloader && make fix && cd ..
	cd popclip-sound-extractor && make fix && cd ..
	cd popclip-subtitle-generator && make fix && cd ..
	cd popclip-subtitle-merger && make fix && cd ..
	cd popclip-subtitle-transformer && make fix && cd ..

setupenv:
	bash setup-env.sh

protobuf:
	cp popclip-protobuf/Message.proto popclip-api
	cp popclip-protobuf/Message.proto popclip-video-downloader
	cp popclip-protobuf/Message.proto popclip-sound-extractor
	cp popclip-protobuf/Message.proto popclip-subtitle-generator
	cp popclip-protobuf/Message.proto popclip-subtitle-merger
	cp popclip-protobuf/Message.proto popclip-subtitle-transformer

	$(PHP_SH) "find /app/src/Protobuf -mindepth 1 ! -name '.gitkeep' -delete"
	
	$(PHP) protoc --proto_path=/app --php_out=src/Protobuf /app/Message.proto
	$(VD) protoc --proto_path=/app --python_out=src/Protobuf /app/Message.proto
	$(SE) protoc --proto_path=/app --python_out=src/Protobuf /app/Message.proto
	$(SG) protoc --proto_path=/app --python_out=src/Protobuf /app/Message.proto
	$(SM) protoc --proto_path=/app --python_out=src/Protobuf /app/Message.proto
	$(ST) protoc --proto_path=/app --python_out=src/Protobuf /app/Message.proto

	$(PHP_SH) "mv /app/src/Protobuf/App/Protobuf/* /app/src/Protobuf"
	$(PHP_SH) "rm -r /app/src/Protobuf/App"
	$(PHP_SH) "rm -r /app/Message.proto"

	rm -r popclip-video-downloader/Message.proto
	rm -r popclip-sound-extractor/Message.proto
	rm -r popclip-subtitle-generator/Message.proto
	rm -r popclip-subtitle-merger/Message.proto
	rm -r popclip-subtitle-transformer/Message.proto