FROM ubuntu:21.04
LABEL org.opencontainers.image.authors=aftaylor2@gmail.com
LABEL org.opencontainers.image.title="NeoVim - LunarVim"
LABEL org.opencontainers.image.licenses=UNLICENSED

# export DOCKER_BUILDKIT=1; docker build -t neovim:dev .
# docker run -it --rm -v /home/ataylor/projects:/home/dev/projects --name neovim neovim:dev /bin/bash


ENV TZ=GMT
ENV URL=https://raw.githubusercontent.com/ChristianChiarulli/lunarvim/master/utils/installer/install.sh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -ms /bin/bash dev
RUN export DEBIAN_FRONTEND=noninteractive; apt update; \
  apt install -y gettext libtool libtool-bin autoconf automake cmake g++  \
  pkg-config unzip build-essential git python3 python3-pip nodejs npm \
  ripgrep fzf ranger && \
  cd /tmp && git clone https://github.com/neovim/neovim --depth 1 && \
  cd neovim; make CMAKE_BUILD_TYPE=Release install; cd ..; rm -rf neovim;

USER dev
WORKDIR /home/dev

RUN cd /tmp && curl -s $URL > install.sh; \
  chmod +x install.sh; ./install.sh --no-install-dependencies; \
  # try getting --install-dependencies working
  # or adding dependencies in apt process above
  # nvim --headless -u $HOME/.config/nvim/init.lua +PackerInstall +qa; \
  /home/dev/.local/bin/lvim --headless +PackerInstall +qa \ 
  /home/dev/.local/bin/lvim --headless +PackerCompile +qa \
  exit 0

# COPY --chown=node:node package.json package-lock.json* ./
# Copy app after building dependencies
# COPY --chown=node:node . .

# USER node

CMD ["nvim"]
