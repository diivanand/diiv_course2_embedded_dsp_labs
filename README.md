# Course 2 — Embedded DSP Labs

Companion repository for [Course 2 — Embedded DSP](https://www.diiv.io/course2/) on [diiv.io](https://www.diiv.io): 45 bench labs from power-supply safety through real-time DSP firmware, edge ML, and host-in-the-loop audio/image/video processing. Each lab is a self-contained folder under `labs/`.

## Hardware targets

| Target | Role |
|---|---|
| **NUCLEO-L476RG** (STM32L476RG, Cortex-M4F @ 80 MHz) | Real-time firmware: Modules 2–3, 5–7, 9 |
| **Raspberry Pi 5** | Edge Linux target: Modules 8–9 |
| **NVIDIA Jetson Orin Nano** | Edge GPU target (CUDA/TensorRT): Modules 8–9 |

Plus the bench: PSU, Fluke DMM, LCR meter, Siglent scope, Saleae logic analyzer.

## Workflow: simulate in Python first

Every algorithm is prototyped and verified in Python (NumPy/SciPy, Jupyter) in the lab's `host/` folder **before** any C or C++ is written. The C18 firmware / C++20 edge implementation is then validated against the Python reference, measured on real hardware, and reconciled in the lab's `notes.md`.

## Toolchains

- **STM32 firmware** — CMake projects targeting **C18** (`-std=gnu17`; arm-none-eabi-gcc has full C17/C18 support). One project per module (labs within a module share it), generated via STM32CubeMX's CMake toolchain option with HAL/LL drivers; CMSIS-DSP for the math, FreeRTOS for Module 7. See `firmware/README.md`.
- **Pi 5 / Jetson C++** — CMake projects targeting **C++20** (OpenCV, ALSA/PortAudio, and on the Jetson CUDA/cuFFT/TensorRT). See `docs/edge-setup.md`.
- **Python** — a single [uv](https://docs.astral.sh/uv/) project at the repo root, pinned to **Python 3.13** (`.python-version`) — the newest version the full dependency set, including the ML group, is known to work on. Per-lab notebooks and scripts live in each lab's `host/` folder and share the one `.venv`:

  ```sh
  uv sync              # core: numpy scipy matplotlib jupyter pyserial sounddevice soundfile librosa opencv pillow
  uv sync --group ml   # + torch/onnx/onnxruntime/tensorflow for the Module 8 training notebooks
  uv run jupyter lab
  ```

  Device-side Python on the Pi/Jetson (CuPy, TensorRT, tflite-runtime, smbus2) is platform-specific — see `docs/edge-setup.md`.

## Layout

```
diiv_course2_embedded_dsp_labs/
  README.md
  pyproject.toml              # shared uv project for all labs' host/ work
  docs/
    reading-map.md            #   which embedded-engineering book helps in which module
    edge-setup.md             #   Pi 5 / Jetson device setup + C++20 CMake template
  firmware/                   # STM32 CMake projects (C18), one per module — shared by that module's labs
    README.md                 #   CubeMX CMake generation, C18, CMSIS-DSP & FreeRTOS setup
    cmake/                    #   shared arm-none-eabi toolchain file
    m2-timing/  m3-mixed/  m5-daq/  m6-dsp/  m7-rtos/  m9-media/
  labs/                       # one folder per lab — everything that lab produces
    lab-<M>-<N>/
      notes.md                #   bench note: setup, predicted-vs-measured, reconciliation
      host/                   #   simulate-first Python + analysis.ipynb + exported plots
      captures/               #   raw instrument data: Siglent CSVs, Saleae .sal, LCR/DMM logs
      edge/                   #   Modules 8–9 only: C++20 CMake app, device Python, models
  media/                      # Module 9: in/ and out/ WAV/PNG/MP4 for the host-in-the-loop labs
    in/  out/
  hardware/                   # shared: breadboard photos, LTspice schematics (lab-<M>-<N>.asc), datasheets
```

**Naming convention:** everything a lab produces lives in its folder — notes in `labs/lab-2-1/notes.md`, scripts in `labs/lab-2-1/host/`, raw data in `labs/lab-2-1/captures/`. A lab is **done** when its `notes.md` has every Measured cell filled and its `captures/` folder holds the raw evidence.

## Math in write-ups

Bench notes and reports use standard LaTeX math in Markdown — `$f_c = \frac{1}{2\pi RC}$` inline, `$$ … $$` display. GitHub renders this natively (MathJax), and Jupyter notebooks render it in Markdown cells out of the box. For a PDF report, export with `uv run jupyter nbconvert --to pdf` (notebooks) or `pandoc --katex` (Markdown notes).
