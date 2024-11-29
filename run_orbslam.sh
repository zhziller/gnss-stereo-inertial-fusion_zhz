#!/bin/bash
# TODO doc

# 开启错误处理
set -eE # Any subsequent commands which fail will cause the shell script to exit immediately

# Get full directory name of the script no matter where it is being called from
# 获取当前脚本所在完整目录路径
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BAGNAME=lab_loop

# 默认参数文件和launch文件
# GNSS_IMU_STEREO
# SETTINGS_FILE=$CURRENT_DIR/Examples/Stereo-Inertial/rosario_dataset/t265_param0.yaml
# LAUNCH_FILE=$CURRENT_DIR/Examples/ROS/GNSS_SI/launch/gnss_imu_stereo_t265.launch
# OUTPUT_DIR=/home/zou/traj/GNSS_orbslam/$BAGNAME_GIS_$(date '+%Y%m%d_%H%M%S')

# IMU_STEREO
SETTINGS_FILE=$CURRENT_DIR/Examples/Stereo-Inertial/RealSense_T265.yaml
LAUNCH_FILE=$CURRENT_DIR/Examples/ROS/GNSS_SI/launch/imu_stereo_t265.launch
OUTPUT_DIR=/home/zou/traj/GNSS_orbslam/$BAGNAME_IS_$(date '+%Y%m%d_%H%M%S')

# STEREO
# SETTINGS_FILE=$CURRENT_DIR/Examples/Stereo/RealSense_T265.yaml
# LAUNCH_FILE=$CURRENT_DIR/Examples/ROS/GNSS_SI/launch/stereo_t265.launch
# OUTPUT_DIR=/home/zou/traj/GNSS_orbslam/$BAGNAME_S_$(date '+%Y%m%d_%H%M%S')

BAG=/home/zou/data/realsense/$BAGNAME.bag


# 帮助函数解释如何使用脚本
function echoUsage()
{
    echo -e "Usage: $0 [FLAG] ROSBAG\n\
            \t -o path to output folder \n\
            \t -s path to yaml configuration file \n\
            \t -l launchfile
            \t -h help" >&2
}

while getopts "l:s:ho:" opt; do
    case "$opt" in
        s)  case $OPTARG in
                -*) echo "ERROR: a path to settings-file must be provided"; echoUsage; exit 1 ;;
                *) SETTINGS_FILE=$OPTARG ;;
            esac
            ;;
        l)  case $OPTARG in
                -*) echo "ERROR: a path to settings-file must be provided"; echoUsage; exit 1 ;;
                *) LAUNCH_FILE=$OPTARG ;;
            esac
            ;;            
        h)  echoUsage
            exit 0
            ;;
        o)  case $OPTARG in
                -*) echo "ERROR: a path to output directory must be provided"; echoUsage; exit 1 ;;
                *) OUTPUT_DIR=$OPTARG ;;
            esac
            ;;
        *)
            echoUsage
            exit 1
            ;;
    esac
done

# 从命令行中提取bag文件路径
# shift $((OPTIND -1))
# BAG=$1

mkdir -p $OUTPUT_DIR
echo "Create $OUTPUT_DIR"
echo "Using settings: $SETTINGS_FILE"
echo "Using launchfile: $LAUNCH_FILE"


roslaunch $CURRENT_DIR/launch/play_bag_and_run.launch bagfile:=$BAG settings:=$SETTINGS_FILE launchfile:=$LAUNCH_FILE &
P1=$!

# Wait some seconds until roscore is running...
sleep 3
LOG_OUTPUT_DIR=$(roslaunch-logs)

# Wait for roslaunch
wait $P1

# Save trajectory file
TRAJECTORY_FILE=/home/zou/traj/GNSS_orbslam/FrameTrajectory_TUM_Format.txt
cp $TRAJECTORY_FILE $OUTPUT_DIR
TRAJECTORY_FILE=/home/zou/traj/GNSS_orbslam/KeyFrameTrajectory_TUM_Format.txt
cp $TRAJECTORY_FILE $OUTPUT_DIR
TRAJECTORY_FILE=/home/zou/traj/GNSS_orbslam/ground_truth.txt
cp $TRAJECTORY_FILE $OUTPUT_DIR

# Save log file
cp $LOG_OUTPUT_DIR/orbslam3*.log $OUTPUT_DIR

echo "Results saved to $OUTPUT_DIR"