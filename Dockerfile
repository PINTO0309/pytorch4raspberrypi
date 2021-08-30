
FROM pinto0309/raspios_lite_armhf:2021-03-04_buster

ENV DEBIAN_FRONTEND=noninteractive
ENV NO_CUDA=1
ENV NO_DISTRIBUTED=1
ENV NO_MKLDNN=1
ENV USE_NCCL=0
ENV BUILD_TEST=0
ARG TORCHVER=v1.9.0
ARG TORCHVISIONVER=v0.10.0
ARG TORCHAUDIOVER=v0.9.0
# 1.19.5 or 1.21.2
ARG NUMPYVER=1.21.2

RUN apt update --allow-releaseinfo-change \
    && apt upgrade -y \
    && apt install -y \
        openjdk-11-jdk automake autoconf libpng-dev nano \
        curl zip unzip libtool swig zlib1g-dev pkg-config git wget xz-utils \
        libopenblas-dev libblas-dev m4 cmake cython python3-dev python3-yaml \
        python3-setuptools python3-pip python3-mock \
        libpython3-dev libpython3-all-dev g++ gcc

RUN pip3 install numpy==${NUMPYVER} \
    && pip3 install -U six wheel mock \
    && ldconfig

RUN mkdir -p /wheels \
    # PyTorch
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
    # TorchVision
    && git clone -b ${TORCHVISIONVER} https://github.com/pytorch/vision.git \
    && cd vision \
    && git submodule update --init --recursive \
    && pip3 install /pytorch/dist/*.whl \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel \
    && cp dist/* /wheels \
    && cd .. \
    # TorchAudio
    && git clone -b ${TORCHAUDIOVER} https://github.com/pytorch/audio.git \
    && cd audio \
    && git submodule update --init --recursive \
    && apt-get install -y sox libsox-dev \
    && pip3 install ninja \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel \
    && cp dist/* /wheels \
    && cd ..

RUN rm -rf /pytorch \
    && rm -rf /vision \
    && rm -rf /audio \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip cache purge
