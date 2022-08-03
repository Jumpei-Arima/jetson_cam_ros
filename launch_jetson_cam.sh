#!/bin/bash

IMAGE_NAME=jetson_cam_ros
CONTAINER_NAME=jetson_cam_ros

TAG_NAME=latest

ROS_MASTER_URI="http://`hostname -I | cut -d' ' -f1`:11311"
ROS_IP=`hostname -I | cut -d' ' -f1`

if [ ! $# -eq 0 ]; then
    IP_CHECK=$(echo $1 | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$")
    if [ "${IP_CHECK}" ]; then
        ROS_MASTER_URI="http://$1:11311"
        if [ $# -ge 2 ]; then
            LAUNCH=${@:2}
        fi
    else
        LAUNCH=$@
    fi
fi

echo "IMAGE_NAME=${IMAGE_NAME}:${TAG_NAME}"
echo "CONTAINER_NAME=${CONTAINER_NAME}"
echo "ROS_MASTER_URI=${ROS_MASTER_URI}"
echo "ROS_IP=${ROS_IP}"

docker run -it --rm \
    --privileged \
    --runtime nvidia \
    --net host \
    --volume /dev:/dev \
    --volume /tmp/argus_socket:/tmp/argus_socket \
    --env ROS_MASTER_URI=${ROS_MASTER_URI} \
    --env ROS_IP=${ROS_IP} \
    --name ${CONTAINER_NAME} \
    ${IMAGE_NAME}:${TAG_NAME} \
    bash -c "roslaunch jetson_cam_ros jetson_csi_cam.launch"
