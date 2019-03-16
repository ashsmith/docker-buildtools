FROM alpine
ARG CLOUD_SDK_VERSION=238.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

RUN apk add --no-cache \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
        gnupg

# Install gcloud
ENV PATH /google-cloud-sdk/bin:$PATH
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

# Adds kubectl
RUN export KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
  && chmod u+x kubectl && mv kubectl /usr/bin/kubectl

# Install docker
RUN set -ex \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*-ce\.tgz' | sort -r | head -n 1) \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz

# Install docker-compose
RUN COMPOSE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/docker-compose-latest" \
  && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/docker-compose $COMPOSE_URL \
  && chmod +x /usr/bin/docker-compose \
  && ls -la /usr/bin/docker-compose
