FROM ubuntu:20.04
RUN export TZ=Asia/Tokyo && \
      ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
      echo $TZ > /etc/timezone
RUN apt-get update -y && apt-get install -y \
      libjson-perl=4.02000-2 \
      libany-uri-escape-perl=0.01-3 \
      libwww-perl=6.43-1 \
      curl=7.68.0-1ubuntu2.7 \
      wget=1.20.3-1ubuntu1 \
      gawk=1:5.0.1+dfsg-1 \
      python3=3.8.2-0ubuntu2 \
      ruby-full=1:2.7+1 \
      awscli=1.18.69-1ubuntu0.20.04.1 && \
      rm -fr /usr/bin/python && \
      ln -s /usr/bin/python3.8 /usr/bin/python && \
      ln -s bash /bin/sh.bash && \
      mv /bin/sh.bash /bin/sh

ADD . /togoid
WORKDIR /togoid
CMD ["rake", "-T"]
