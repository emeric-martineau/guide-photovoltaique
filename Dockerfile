FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt-get install -y \
        asciidoctor \
        ruby-full \
        build-essential \
        zlib1g-dev \
        nodejs \
        npm    

RUN gem install asciidoctor-pdf
RUN gem install coderay pygments.rb
RUN gem install jekyll bundler
RUN npm install html-minifier -g

RUN echo "#!/usr/bin/env bash" >> /entrypoint.sh
RUN echo "" >> /entrypoint.sh
RUN echo 'export GEM_HOME="$(ruby -e "puts Gem.user_dir")"' >> /entrypoint.sh
RUN echo 'export PATH="${GEM_HOME}/bin:${PATH}"' >> /entrypoint.sh
RUN echo "" >> /entrypoint.sh
RUN echo "bash" >> /entrypoint.sh

RUN chmod a+x /entrypoint.sh

WORKDIR /data

ENTRYPOINT [ "/entrypoint.sh" ]