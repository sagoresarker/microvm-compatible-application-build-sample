# Makefile for MicroVM Base Image and Transformation
BASE_IMAGE_NAME := poridhi/poridhi-cloud-native-base
BASE_TAG := v0.0.3
TRANSFORM_IMAGE_NAME := poridhi-cloud-native-transformed-app
DOCKER_USERNAME := poridhi

# Build the base image
build-base:
	@echo "Building MicroVM base image..."
	@docker build -t $(BASE_IMAGE_NAME):$(BASE_TAG) -f Dockerfile .

# Push the base image to registry
push-base:
	@echo "Pushing base image to registry..."
	@docker push $(BASE_IMAGE_NAME):$(BASE_TAG)

# Transform any JavaScript application to MicroVM-compatible format
transform-app:
	@echo "Transforming application to MicroVM-compatible format..."
	@docker build -t $(TRANSFORM_IMAGE_NAME):latest -f ../transform.Dockerfile ..

# Build and push the transformed application
build-and-push-app:
	@echo "Building and pushing transformed application..."
	@docker tag $(TRANSFORM_IMAGE_NAME):latest $(DOCKER_USERNAME)/$(TRANSFORM_IMAGE_NAME):latest
	@docker push $(DOCKER_USERNAME)/$(TRANSFORM_IMAGE_NAME):latest

# Run the transformed application locally for testing
run-app:
	@echo "Running transformed application locally..."
	@docker run -d --name $(TRANSFORM_IMAGE_NAME) -p 3000:3000 $(TRANSFORM_IMAGE_NAME):latest

# Stop and remove the running container
stop-app:
	@echo "Stopping application container..."
	@docker stop $(TRANSFORM_IMAGE_NAME) || true
	@docker rm $(TRANSFORM_IMAGE_NAME) || true

# Clean up images
clean:
	@echo "Cleaning up images..."
	@docker rmi $(BASE_IMAGE_NAME):$(BASE_TAG) || true
	@docker rmi $(TRANSFORM_IMAGE_NAME):latest || true

# Full workflow: build base, transform app, and push
all: build-base push-base transform-app build-and-push-app

.PHONY: build-base push-base transform-app build-and-push-app run-app stop-app clean all