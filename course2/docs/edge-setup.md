# Edge targets — Pi 5 + Jetson Orin Nano setup (Modules 8–9)

Device-side work for the edge labs lives in each lab's own folder: `labs/lab-8-1/edge/` … `labs/lab-9-6/edge/`. Everything is prototyped in Python first (`labs/lab-<M>-<N>/host/`, or on-device for GPU-only paths), then ported to **C++20 CMake** where the lab calls for a compiled implementation.

## C++20 CMake template

Each lab that gets a compiled implementation carries its own `CMakeLists.txt` inside its `edge/` folder:

```cmake
cmake_minimum_required(VERSION 3.22)
project(lab_9_5_video_pipeline CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenCV REQUIRED)                    # image/video labs
# find_package(CUDAToolkit REQUIRED)             # Jetson: cuFFT etc. → CUDA::cufft
# find_package(ALSA REQUIRED)                    # audio I/O (or PortAudio)

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})
```

Build on-device: `cmake -B build && cmake --build build -j`.

## Device setup

**Both devices** — system packages for the C++ side, uv for Python:

```sh
sudo apt install build-essential cmake libopencv-dev libasound2-dev portaudio19-dev
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Raspberry Pi 5** (device-side Python, per lab as needed):

```sh
uv venv && uv pip install numpy scipy opencv-python pillow soundfile sounddevice \
    tflite-runtime onnxruntime smbus2
```

**Jetson Orin Nano** — CUDA, cuDNN, and **TensorRT come from JetPack** (not pip). Device-side Python extras:

```sh
uv venv --system-site-packages     # so the JetPack-provided CUDA/TensorRT python bindings are visible
uv pip install numpy scipy opencv-python soundfile cupy-cuda12x pycuda
```

GPU paths: CuPy (`cupyx.scipy.*`) for drop-in NumPy/SciPy on the GPU, cuFFT via CuPy or `CUDA::cufft` from C++, TensorRT for deployed models (ONNX → engine with `trtexec`).

Models exported by the Module 8 training notebooks (`uv sync --group ml`, notebooks in `labs/lab-8-N/host/`) land in the same lab's `edge/` folder (`.onnx` / `.tflite` / TensorRT `.engine`).
