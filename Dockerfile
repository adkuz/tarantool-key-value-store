FROM ubuntu:16.04

COPY scripts/install-tarantool.sh ./install-tarantool.sh
RUN chmod +x ./install-tarantool.sh
RUN ./install-tarantool.sh

RUN useradd -m myuser
USER myuser

WORKDIR /home/myuser
COPY src /opt/tarantool

RUN ls -lA /opt/tarantool

RUN touch ./tarantool.log

ENTRYPOINT [ "tarantool" ]
CMD ["/opt/tarantool/main.lua"]
