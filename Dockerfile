FROM ubuntu:18.04 as cacher

# Set working directory
RUN mkdir /vsss_ws
WORKDIR /vsss_ws

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    git \
    qt5-default \
    libqt5opengl5-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libode-dev \
    libboost-dev \
    sudo && \
    apt-get clean && \
    cd /tmp && \
    git clone https://github.com/jpfeltracco/vartypes.git &&\
    cd vartypes && \
    mkdir build && cd build && \
    cmake .. && make && sudo make install

# Dependencies for glvnd and X11.
RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
  && rm -rf /var/lib/apt/lists/*

FROM cacher as builder

# Install FIRASim and VSSReferee
RUN cd /vsss_ws && \
    git clone https://github.com/VSSSLeague/FIRASim.git && \
    cd FIRASim && \
    git checkout tags/v3.0 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cd /vsss_ws && \
    git clone https://github.com/VSSSLeague/VSSReferee.git && \
    cd VSSReferee && \
    git checkout CBFRS

RUN cd /vsss_ws/VSSReferee && \
    mkdir build && cd build && qmake .. && make

FROM builder as runner

# Set enviroment variables
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

RUN mkdir -m 700 /tmp/runtime-root
ENV XDG_RUNTIME_DIR=/tmp/runtime-root

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

COPY constants.json /vsss_ws/VSSReferee/src/constants/

# Run FIRASim and VSSReferee
CMD /vsss_ws/VSSReferee/bin/VSSReferee --3v3 --record false & /vsss_ws/FIRASim/bin/FIRASim
# CMD /vsss_ws/FIRASim/bin/FIRASim
