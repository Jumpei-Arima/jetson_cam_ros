cmake_minimum_required(VERSION 3.0.2)
project(jetson_cam_ros)

find_package(catkin REQUIRED COMPONENTS
)

catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES jetracer_bringup
#  CATKIN_DEPENDS geometry_msgs rospy sensor_msgs
#  DEPENDS system_lib
)

include_directories(
# include
  ${catkin_INCLUDE_DIRS}
)
