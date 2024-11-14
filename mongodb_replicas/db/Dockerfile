FROM mongo:7.0

WORKDIR /data/

RUN mkdir -p ./db

RUN openssl rand -base64 756 > /etc/mongo-keyfile
RUN chmod 400 /etc/mongo-keyfile
RUN chown mongodb:mongodb /etc/mongo-keyfile

COPY mongod.cfg ./

RUN touch mongod.log && \
    chown -R mongodb:mongodb ./* && \
    chmod a+w mongod.log
# set timezone VN
ENV TZ=Asia/Ho_Chi_Minh

CMD ["mongod", "--config", "/data/mongod.cfg"]
