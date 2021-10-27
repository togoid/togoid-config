FROM ubuntu:20.04
RUN export TZ=Asia/Tokyo && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -y && apt-get install -y curl wget gawk python3 ruby-full awscli
