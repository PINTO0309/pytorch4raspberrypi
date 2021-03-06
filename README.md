# pytorch4raspberrypi
Cross-compilation of PyTorch armv7l (32bit) for RaspberryPi OS

**[Cross-compilation of PyTorch v1.9.0 armv7l for RaspberryPi OS Buster](https://zenn.dev/pinto0309/articles/b796e2d6396c1e)**

## 1. Environment
- Ubuntu 20.04 x86_64
- Docker

## 2. Procedure
A very time-consuming but very easy cross-compilation procedure. It will take about three hours. Performed on Ubuntu 20.04 x86_64.
## 2-1. [Method 1] Docker build
```
$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes \
  && docker build -t pytorch4raspberrypi .

##### A pre-built .whl file will be generated directly under the /wheels folder.

$ docker run --rm -it -v ${PWD}:/work pytorch4raspberrypi /bin/bash

# cp /wheels/* work
# exit

$ sudo chmod -R 777 *.whl
```
## 2-2. [Method 2] Manual build
```
$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
$ docker run --rm -it \
  -v ${PWD}:/workdir \
  pinto0309/raspios_lite_armhf:2022-02-10_bullseye \
  /bin/bash
```
All of the following operations were performed on a RaspberryPi OS armv7l 32-bit Docker container running on Ubuntu 20.04 x86_64.
```
# apt update && apt upgrade -y

# apt-get update && apt-get install -y \
  openjdk-11-jdk automake autoconf libpng-dev nano \
  curl zip unzip libtool swig zlib1g-dev pkg-config git wget xz-utils \
  libopenblas-dev libblas-dev m4 cmake python3-dev python3-yaml \
  python3-setuptools python3-pip python3-mock \
  libpython3-dev libpython3-all-dev g++ gcc libatlas-base-dev \
  libtbb-dev sox libsox-dev

# pip3 install pip --upgrade
# pip3 install cython==0.29.27 numpy==1.22.2 cmake==3.21.2 ninja==1.10.2.3 typing_extensions==4.0.1

# pip3 install -U six wheel mock && ldconfig

# TORCH=v1.10.2 \
  && TORCHVISION=v0.11.3 \
  && TORCHAUDIO=v0.10.2

# git clone -b ${TORCH} https://github.com/pytorch/pytorch.git

##########################################################
pytorch/torch/csrc/utils/python_arg_parser.h:415:94
pytorch/torch/csrc/utils/python_arg_parser.h:442:94
pytorch/torch/csrc/autograd/python_function.cpp:439:11

%ld -> %d
##########################################################

# cd pytorch \
    && git submodule update --init --recursive \
    && pip3 install -r requirements.txt \
    && NO_CUDA=1 NO_DISTRIBUTED=1 NO_MKLDNN=1 USE_NCCL=OFF USE_XNNPACK=OFF USE_TBB=ON BUILD_TEST=OFF python3 setup.py build \
    && cd build/lib.linux-armv7l-3.9/torch \
    && ln -s _C.cpython-39-arm-linux-gnueabihf.so _C.so \
    && ln -s _dl.cpython-39-arm-linux-gnueabihf.so _dl.so \
    && cd ../../..
# python3 setup.py bdist_wheel

-- ******** Summary ********
-- General:
--   CMake version         : 3.21.2
--   CMake command         : /usr/local/lib/python3.9/dist-packages/cmake/data/bin/cmake
--   System                : Linux
--   C++ compiler          : /usr/bin/c++
--   C++ compiler id       : GNU
--   C++ compiler version  : 10.2.1
--   Using ccache if found : ON
--   Found ccache          : CCACHE_PROGRAM-NOTFOUND
--   CXX flags             :  -Wno-deprecated -fvisibility-inlines-hidden -DUSE_PTHREADPOOL -fopenmp -DNDEBUG -DUSE_KINETO -DLIBKINETO_NOCUPTI -DUSE_QNNPACK -DUSE_PYTORCH_QNNPACK -DSYMBOLICATE_MOBILE_DEBUG_HANDLE -DEDGE_PROFILER_USE_KINETO -O2 -fPIC -Wno-narrowing -Wall -Wextra -Werror=return-type -Wno-missing-field-initializers -Wno-type-limits -Wno-array-bounds -Wno-unknown-pragmas -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wno-unused-result -Wno-unused-local-typedefs -Wno-strict-overflow -Wno-strict-aliasing -Wno-error=deprecated-declarations -Wno-stringop-overflow -Wno-psabi -Wno-error=pedantic -Wno-error=redundant-decls -Wno-error=old-style-cast -fdiagnostics-color=always -faligned-new -Wno-unused-but-set-variable -Wno-maybe-uninitialized -fno-math-errno -fno-trapping-math -Werror=format -Werror=cast-function-type -Wno-stringop-overflow
--   Build type            : Release
--   Compile definitions   : ONNX_ML=1;ONNXIFI_ENABLE_EXT=1;ONNX_NAMESPACE=onnx_torch;HAVE_MMAP=1;_FILE_OFFSET_BITS=64;HAVE_SHM_OPEN=1;HAVE_SHM_UNLINK=1;HAVE_MALLOC_USABLE_SIZE=1;USE_EXTERNAL_MZCRC;MINIZ_DISABLE_ZIP_READER_CRC32_CHECKS
--   CMAKE_PREFIX_PATH     : /usr/lib/python3.9/site-packages
--   CMAKE_INSTALL_PREFIX  : /pytorch/torch
--   USE_GOLD_LINKER       : OFF
--
--   TORCH_VERSION         : 1.10.0
--   CAFFE2_VERSION        : 1.10.0
--   BUILD_CAFFE2          : ON
--   BUILD_CAFFE2_OPS      : ON
--   BUILD_CAFFE2_MOBILE   : OFF
--   BUILD_STATIC_RUNTIME_BENCHMARK: OFF
--   BUILD_TENSOREXPR_BENCHMARK: OFF
--   BUILD_BINARY          : OFF
--   BUILD_CUSTOM_PROTOBUF : ON
--     Link local protobuf : ON
--   BUILD_DOCS            : OFF
--   BUILD_PYTHON          : True
--     Python version      : 3.9.2
--     Python executable   : /usr/bin/python3
--     Pythonlibs version  : 3.9.2
--     Python library      : /usr/lib/libpython3.9.so.1.0
--     Python includes     : /usr/include/python3.9
--     Python site-packages: lib/python3.9/site-packages
--   BUILD_SHARED_LIBS     : ON
--   CAFFE2_USE_MSVC_STATIC_RUNTIME     : OFF
--   BUILD_TEST            : False
--   BUILD_JNI             : OFF
--   BUILD_MOBILE_AUTOGRAD : OFF
--   BUILD_LITE_INTERPRETER: OFF
--   INTERN_BUILD_MOBILE   :
--   USE_BLAS              : 1
--     BLAS                : open
--   USE_LAPACK            : 1
--     LAPACK              : open
--   USE_ASAN              : OFF
--   USE_CPP_CODE_COVERAGE : OFF
--   USE_CUDA              : OFF
--   USE_ROCM              : OFF
--   USE_EIGEN_FOR_BLAS    : ON
--   USE_FBGEMM            : OFF
--     USE_FAKELOWP          : OFF
--   USE_KINETO            : ON
--   USE_FFMPEG            : OFF
--   USE_GFLAGS            : OFF
--   USE_GLOG              : OFF
--   USE_LEVELDB           : OFF
--   USE_LITE_PROTO        : OFF
--   USE_LMDB              : OFF
--   USE_METAL             : OFF
--   USE_PYTORCH_METAL     : OFF
--   USE_PYTORCH_METAL_EXPORT     : OFF
--   USE_FFTW              : OFF
--   USE_MKL               : OFF
--   USE_MKLDNN            : OFF
--   USE_NCCL              : OFF
--   USE_NNPACK            : ON
--   USE_NUMPY             : ON
--   USE_OBSERVERS         : ON
--   USE_OPENCL            : OFF
--   USE_OPENCV            : OFF
--   USE_OPENMP            : ON
--   USE_TBB               : ON
--     USE_SYSTEM_TBB      : OFF
--   USE_VULKAN            : OFF
--   USE_PROF              : OFF
--   USE_QNNPACK           : ON
--   USE_PYTORCH_QNNPACK   : ON
--   USE_REDIS             : OFF
--   USE_ROCKSDB           : OFF
--   USE_ZMQ               : OFF
--   USE_DISTRIBUTED       : ON
--     USE_MPI               : OFF
--     USE_GLOO              : OFF
--     USE_GLOO_WITH_OPENSSL : OFF
--     USE_TENSORPIPE        : ON
--   USE_DEPLOY           : OFF
--   USE_BREAKPAD         : ON
--   Public Dependencies  : Threads::Threads
--   Private Dependencies : pthreadpool;cpuinfo;qnnpack;pytorch_qnnpack;nnpack;fp16;tensorpipe;aten_op_header_gen;foxi_loader;rt;fmt::fmt-header-only;kineto;gcc_s;gcc;dl
--   USE_COREML_DELEGATE     : OFF
-- Configuring done
-- Generating done
-- Build files have been written to: /pytorch/build

# cp dist/* /workdir
# cd ..

# git clone -b ${TORCHVISION} https://github.com/pytorch/vision.git

# cd vision \
    && git submodule update --init --recursive \
    && pip3 install /pytorch/dist/*.whl \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel

# cp dist/* /workdir
# cd ..

# git clone -b ${TORCHAUDIO} https://github.com/pytorch/audio.git
# cd audio \
    && git submodule update --init --recursive \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel

# cp dist/* /workdir
# cd ..

# exit
```
# 3. Install
Running on RaspberryPi.
```
$ sudo apt install -y libatlas-base-dev libpng-dev nano \
  curl zip unzip libtool swig zlib1g-dev pkg-config git wget xz-utils \
  libopenblas-dev libblas-dev m4 cmake cython python3-dev python3-yaml \
  libtbb-dev

$ sudo pip3 install numpy==1.22.2

$ sudo pip3 install torch-*_armv7l_.whl torchvision-*_armv7l.whl torchaudio-*_armv7l.whl
```
