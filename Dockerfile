#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
ARG IMAGE_VERSION=buster
FROM debian:$IMAGE_VERSION
MAINTAINER Tim Sutton<tim@kartoza.com>

# Reset ARG for version
ARG IMAGE_VERSION
RUN export DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND noninteractive
RUN dpkg-divert --local --rename --add /sbin/initctl

RUN apt -y update; apt -y install gnupg2 wget ca-certificates rpl pwgen
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ ${IMAGE_VERSION}-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

#-------------Application Specific Stuff ----------------------------------------------------
RUN apt install locales -y; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
# We add postgis as well to prevent build errors (that we dont see on local builds)
# on docker hub e.g.
# The following packages have unmet dependencies:
RUN apt -y update; apt install -y postgresql-client-9.6 postgresql-common postgresql-9.6 postgresql-9.6-postgis-2.4 postgresql-9.6-pgrouting netcat

# Open port 5432 so linked containers can see them
EXPOSE 5432

# We will run any commands in this when the container starts
ADD env-data.sh /
ADD docker-entrypoint.sh /
ADD setup-conf.sh /
ADD setup-database.sh /
ADD setup-pg_hba.sh /
ADD setup-replication.sh /
ADD setup-ssl.sh /
ADD setup-user.sh /
RUN chmod +x /*.sh

ENTRYPOINT /docker-entrypoint.sh
