IMAGE_NAME := nextjs-app-demo-for-vm
DOCKER_USERNAME := poridhi
TAG = v1.0.7

# Original build method (legacy)
build:
	@ docker build --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) -f Dockerfile .

# New transformation method using base image
transform:
	@ echo "Transforming application using MicroVM base image..."
	@ docker build --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) -f transform.Dockerfile .

push:
	@ docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_USERNAME)/$(IMAGE_NAME):$(TAG)
	@ docker push $(DOCKER_USERNAME)/$(IMAGE_NAME):$(TAG)

run:
	@ docker run -d --name $(IMAGE_NAME) -p 3005:3000 $(IMAGE_NAME):$(TAG)

delete:
	@ docker stop $(IMAGE_NAME) && docker rm $(IMAGE_NAME)

clean:
	@ docker rmi $(IMAGE_NAME):$(TAG)

# Build base image first (required for transformation)
build-base:
	@ echo "Building MicroVM base image..."
	@ cd base-image && make build-base

# Full workflow: build base, transform app, push
all: build-base transform push

.PHONY: build transform push run delete clean build-base all