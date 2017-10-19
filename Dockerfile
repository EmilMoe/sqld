FROM amd64/debian:latest

MAINTAINER Emil Moe

ENV DEBIAN_FRONTEND noninteractive

ARG DATABASE

RUN apt-get update
RUN apt-get upgrade -y

RUN echo mariadb-server mysql-server/root_password password secret | debconf-set-selections
RUN echo mariadb-server mysql-server/root_password_again password secret | debconf-set-selections

RUN apt-get install -y mariadb-server mariadb-client bash

RUN sed -i -e 's/bind-address/# bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf
RUN /etc/init.d/mysql start && mysql -u root -psecret -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'secret';"

RUN echo "" > /empty.log

# RUN echo "#!/bin/bash" > /cmd.sh
# RUN chmod +x /cmd.sh
# RUN echo "/etc/init.d/mysql start && mysql -u root -psecret -e \"CREATE DATABASE IF NOT EXISTS ${DATABASE} COLLATE = 'utf8mb4_unicode_ci' CHARACTER SET = 'utf8mb4'\"" >> /cmd.sh
# RUN echo "echo Welcome to the server" >> /cmd.sh

COPY ./db.setup.docker /cmd.sh
RUN chmod +x /cmd.sh

EXPOSE 3306

ENTRYPOINT /bin/sh /cmd.sh && /etc/init.d/mysql start && tail -f /empty.log