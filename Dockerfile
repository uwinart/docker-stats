# Version 0.0.1
FROM uwinart/tarantool:latest

MAINTAINER Yurii Khmelevskii <y@uwinart.com>

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p /data/tarantool

ADD assets /data/tarantool/assets
ADD stats.lua /data/tarantool/stats.lua

VOLUME ["/data/tarantool"]

EXPOSE 3311

CMD ["/data/tarantool/stats.lua"]
