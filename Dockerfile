ARG BASE_IMAGE=nvcr.io/nvidia/l4t-base:r32.6.1
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gnupg \
        ca-certificates \
        apt-transport-https \
        software-properties-common \
        curl \
        git \
        lsb-release

# install ROS melodic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ros-melodic-ros-base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python-pip \
        python-rosdep \
        python-rosinstall \
        python-rosinstall-generator \
        python-wstool \
        build-essential

# external ROS setting
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev

WORKDIR /root
RUN mkdir -p catkin_ws/src && \
    cd catkin_ws/src && \
    git clone https://github.com/ros-drivers/gscam.git && \
    cd /root/catkin_ws/src/gscam && \
    sed -e "s/EXTRA_CMAKE_FLAGS = -DUSE_ROSBUILD:BOOL=1$/EXTRA_CMAKE_FLAGS = -DUSE_ROSBUILD:BOOL=1 -DGSTREAMER_VERSION_1_x=On/" -i Makefile && \
    cd /root/catkin_ws/ && \
    bash -c "source /opt/ros/melodic/setup.bash; rosdep init; rosdep update" && \
    apt-get update && \
    bash -c "source /opt/ros/melodic/setup.bash; rosdep install --from-paths src -i -r -y" && \
    bash -c "source /opt/ros/melodic/setup.bash; catkin_make"

COPY ./jetson_cam_ros /root/catkin_ws/src/jetson_cam_ros
WORKDIR /root/catkin_ws
RUN bash -c "source /opt/ros/melodic/setup.bash; catkin_make"

WORKDIR /root/

RUN echo 'source /opt/ros/melodic/setup.bash && \
          source /root/catkin_ws/devel/setup.bash && \
          export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/root/catkin_s/src/ && \
          exec "$@"' \
    > /root/ros_entrypoint.sh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["bash", "/root/ros_entrypoint.sh"]
