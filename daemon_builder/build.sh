#!/bin/bash
set -e

REGISTRY="registry.your.domain.tld"
REGISTRY_USER="user"
REGISTRY_PWD="pass"

DAEMON_LIST="WPclient:AMQPcommandStart WPclient:receive WPclient:register WPclient:storeWpFilesList WPclient:updateWpInfo WPclient:updateRestoreFileResult"

# get version tag and release date from external file
VERSION_FILENAME='_VERSION_'
RELEASE_DATE_FILENAME='_RELEASE_DATE_'

if [ ! -f ${VERSION_FILENAME} ] ; then
        echo "Cannot find ${VERSION_FILENAME}!"
        exit 1
fi

if [ ! -f ${RELEASE_DATE_FILENAME} ] ; then
        echo "Cannot find ${RELEASE_DATE_FILENAME}!"
        exit 1
fi

TAG=$(< ${VERSION_FILENAME})
RELEASE_DATE=$(< ${RELEASE_DATE_FILENAME})


function build_images()
{
for DAEMON_NAME in ${DAEMON_LIST}
do
    echo -e "\e[4mBuilding ${DAEMON_NAME}\e[0m"

    # generate different startup files for daemons
    cp -f docker-entrypoint.sh.template docker-entrypoint.sh
    echo "php artisan ${DAEMON_NAME}" >> docker-entrypoint.sh

    # image names cannot contain some characters
    IMAGE_NAME=$(echo ${DAEMON_NAME} | sed 's/:/-/g' | tr '[:upper:]' '[:lower:]')

    docker build -t "${REGISTRY}/${IMAGE_NAME}:${TAG}" . --label "your.label.version=${TAG}" --label "your.label.release-date=${RELEASE_DATE}"

    # tag image as latest
    # pushing identical images with different tags is "cheap" as it uses the same layers
    docker tag "${REGISTRY}/${IMAGE_NAME}:${TAG}" "${REGISTRY}/${IMAGE_NAME}:latest"

    # push images to registry
    docker login -u ${REGISTRY_USER} -p ${REGISTRY_PWD} ${REGISTRY}
    docker push "${REGISTRY}/${IMAGE_NAME}:${TAG}"
    docker push "${REGISTRY}/${IMAGE_NAME}:latest"

done
}

echo -e "\e[91m Have you changed version tag and/or release date in relevant files (y/n)\e[0m"
read answer
case ${answer:0:1} in
    y|Y|t|T )
        echo "OK!";
        build_images;
    ;;
    * )
       editor ${VERSION_FILENAME};
       editor ${RELEASE_DATE_FILENAME};
       echo Run the script again.;
       exit;
    ;;
esac


docker images | egrep "wpclient-"
