FROM node:18.11.0-bullseye-slim@sha256:f916ff4bcfc6bbe6e3a4fa24f29109e7446e7bcd1d788066c7c45f705de95e69 as base

RUN apt-get update && \
  # TODO: lock_versions to ensure deterministic behaviour
  apt-get install -y git curl make hunspell tidy

FROM base as dev-container

RUN apt-get update && \
  # TODO: lock_versions to ensure deterministic behaviour
  apt-get install -y zsh less sudo && \
  chsh -s $(which zsh) && \
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
  # Setup sudo and zsh for node user
  usermod --shell $(which zsh) node && \
  adduser node sudo && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER node

# Setup ohmyzsh for root user
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

FROM base as ci

WORKDIR /workspace

# COPY package.json package-lock.json /workspace/
# RUN npm install

COPY . /workspace