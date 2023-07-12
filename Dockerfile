FROM ubuntu:22.04
RUN export TZ=Asia/Tokyo && \
      ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
      echo $TZ > /etc/timezone
RUN apt-get update -y && apt-get install -y \
      libjson-perl=4.04000-1 \
      libany-uri-escape-perl=0.01-3 \
      libwww-perl=6.61-1 \
      curl=7.81.0-1ubuntu1.10 \
      wget=1.21.2-2ubuntu1 \
      gawk=1:5.1.0-1build3 \
      python3=3.10.6-1~22.04 \
      ruby-full=1:3.0~exp1 \
      awscli=1.22.34-1 && \
      rm -fr /usr/bin/python && \
      ln -s /usr/bin/python3.8 /usr/bin/python && \
      ln -s bash /bin/sh.bash && \
      mv /bin/sh.bash /bin/sh

ADD . /togoid
WORKDIR /togoid
CMD ["rake", "-T"]
