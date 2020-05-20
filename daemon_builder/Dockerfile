# base image
FROM debian:stable-slim
MAINTAINER Piotr Szeptynski <p.szeptynski@mybox.pl>
LABEL your.label.maintainer="Piotr Szeptynski <p.szeptynski@mybox.pl>"

# install needed packages
RUN apt-get update -qq && apt-get install -y wget gnupg1 ca-certificates apt-transport-https && \
    wget -q https://packages.sury.org/php/apt.gpg -O- | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - && \
    echo 'deb https://packages.sury.org/php/ stretch main' | tee /etc/apt/sources.list.d/php.list && \
    apt-get update -qq && \
    apt-get install -y php7.2 php7.2-cli php7.2-common php7.2-opcache php7.2-curl php7.2-mbstring php7.2-mysql php7.2-zip php7.2-xml php7.2-bcmath && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# copy project files to container
COPY $PWD/sandbox/temp_public /sandbox/temp_public
COPY $PWD/docker-entrypoint.sh /

# start daemon
ENTRYPOINT ["/docker-entrypoint.sh"]
