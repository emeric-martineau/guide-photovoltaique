FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt-get install -y \
        asciidoctor \
        ruby-full \
        build-essential \
        zlib1g-dev

RUN gem install asciidoctor-pdf
RUN gem install coderay pygments.rb
RUN gem install jekyll bundler

WORKDIR /data