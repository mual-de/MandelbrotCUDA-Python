# Get the base Ubuntu image from Docker Hub
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Arguments for Installation procedure
ARG OPENCV_VERSION=4.5.3
ARG DEBIAN_FRONTEND="noninteractive" 

# Update apps on the base image
RUN apt-get -y update && apt-get install -y

# Install the Clang compiler
RUN apt-get -y install clang 
RUN echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections
RUN echo 'tzdata tzdata/Zones/Europe select Berlin' | debconf-set-selections
RUN apt install -y tzdata
RUN apt-get -y install build-essential gdb
RUN apt-get -y install cmake
RUN apt-get -y install git
RUN apt-get -y install v4l-utils
RUN apt-get -y install libopencv-dev
RUN apt-get -y install python3-pip
RUN apt-get -y install wget unzip yasm pkg-config libswscale-dev
RUN apt-get -y install libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev
RUN apt-get -y install libavformat-dev libpq-dev libxine2-dev libglew-dev
RUN apt-get -y install libtiff5-dev zlib1g-dev libjpeg-dev libavcodec-dev libavformat-dev
RUN apt-get -y install libavutil-dev libpostproc-dev libeigen3-dev python3-dev
RUN apt-get -y install nano
RUN pip install conan numpy pandas Pillow


# Run the output program from the previous step
CMD ["bash"]

LABEL Name=FIPP_Developement Version=0.0.2
