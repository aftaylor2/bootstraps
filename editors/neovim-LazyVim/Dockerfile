FROM ubuntu:24.04
LABEL org.opencontainers.image.authors=aftaylor2@gmail.com
LABEL org.opencontainers.image.title="NeoVim - LazyVim"
LABEL org.opencontainers.image.licenses=UNLICENSED

ENV TZ=GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -ms /bin/bash dev

# Update and install dependencies
RUN export DEBIAN_FRONTEND=noninteractive; apt update && apt install -y \
  gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip \
  build-essential git python3 python3-pip nodejs npm ripgrep fzf ranger curl \
  && rm -rf /var/lib/apt/lists/*

# Build and install Neovim
RUN cd /tmp && git clone https://github.com/neovim/neovim --depth 1 && \
  cd neovim && make CMAKE_BUILD_TYPE=Release install && \
  cd .. && rm -rf neovim

USER dev
WORKDIR /home/dev

# Install LazyVim starter configuration
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim && \
  nvim --headless "+Lazy sync" +qa

CMD ["nvim"]
