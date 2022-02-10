FROM pinto0309/raspios_lite_armhf:2022-02-10_bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV NO_CUDA=1
ENV NO_DISTRIBUTED=1
ENV NO_MKLDNN=1
ENV USE_NCCL=OFF
ENV USE_XNNPACK=OFF
ENV USE_TBB=ON
ENV BUILD_TEST=OFF
ARG TORCHVER=v1.10.2
ARG TORCHVISIONVER=v0.11.3
ARG TORCHAUDIOVER=v0.10.2
# 1.22.2
ARG NUMPYVER=1.22.2

RUN apt update --allow-releaseinfo-change \
    && apt upgrade -y \
    && apt install -y \
        automake autoconf libpng-dev nano \
        curl zip unzip libtool swig zlib1g-dev pkg-config git wget xz-utils \
        libopenblas-dev libblas-dev m4 cmake python3-dev python3-yaml \
        python3-setuptools python3-pip python3-mock sox libsox-dev \
        libpython3-dev libpython3-all-dev g++ gcc libatlas-base-dev \
        libtbb-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install pip --upgrade \
    && pip3 install cython==0.29.27 \
    && pip3 install numpy==${NUMPYVER} \
    && pip3 install cmake==3.21.2 \
    && pip3 install ninja==1.10.2.3 \
    && pip3 install typing_extensions==4.0.1 \
    && pip3 install -U six wheel mock \
    && ldconfig \
    && pip cache purge

# PyTorch
RUN mkdir -p /wheels \
    && git clone -b ${TORCHVER} https://github.com/pytorch/pytorch.git \
    && cd pytorch \
    && git submodule update --init --recursive \
    && pip3 install -r requirements.txt \
    && python3 setup.py build \
    && cd build/lib.linux-armv7l-3.7/torch \
    && ln -s _C.cpython-37m-arm-linux-gnueabihf.so _C.so \
    && ln -s _dl.cpython-37m-arm-linux-gnueabihf.so _dl.so \
    && cd ../../.. \
    && python3 setup.py bdist_wheel \
    && cp dist/* /wheels \
    && cd .. \
    && rm -rf /pytorch

# TorchVision
RUN git clone -b ${TORCHVISIONVER} https://github.com/pytorch/vision.git \
    && cd vision \
    && git submodule update --init --recursive \
    && pip3 install /wheels/*.whl \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel \
    && cp dist/* /wheels \
    && cd .. \
    && rm -rf /vision

# TorchAudio
RUN git clone -b ${TORCHAUDIOVER} https://github.com/pytorch/audio.git \
    && cd audio \
    && git submodule update --init --recursive \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel \
    && cp dist/* /wheels \
    && cd .. \
    && rm -rf /audio
