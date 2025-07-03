IMAGE_NAME := nextjs-app-demo-for-vm
DOCKER_USERNAME := poridhi
TAG = v1.0.4

build:
	@ docker build --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) -f Dockerfile .

push:
	@ docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_USERNAME)/$(IMAGE_NAME):$(TAG)
	@ docker push $(DOCKER_USERNAME)/$(IMAGE_NAME):$(TAG)

run:
	@ docker run -d --name $(IMAGE_NAME) -p 3005:3000 $(IMAGE_NAME):$(TAG)

delete:
	@ docker stop $(IMAGE_NAME) && docker rm $(IMAGE_NAME)

clean:
	@ docker rmi $(IMAGE_NAME):$(TAG)

.PHONY: build push run delete clean