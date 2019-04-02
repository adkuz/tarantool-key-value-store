FROM ubuntu:16.04

COPY scripts/install-tarantool.sh ./install-tarantool.sh
RUN chmod +x ./install-tarantool.sh
RUN ./install-tarantool.sh

EXPOSE 80

COPY src /opt/tarantool

RUN ls -lA /opt/tarantool

ENTRYPOINT [ "sudo", "tarantool" ]
CMD ["/opt/tarantool/main.lua"]