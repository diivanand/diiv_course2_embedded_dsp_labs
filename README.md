# Diiv.io — Custom Course Workspaces

Companion repository for the lab-based courses on [diiv.io](https://www.diiv.io) — one top-level folder per course, all peers:

| Folder | Course | What's in it |
|---|---|---|
| [`course2/`](course2/) | [Course 2 — Embedded DSP](https://www.diiv.io/course2/) | 45 bench labs: instruments → mixed-signal I/O → STM32 real-time DSP firmware → edge ML → host-in-the-loop media |
| [`course3/`](course3/) | [Course 3 — Computer Architecture, ARM Assembly & Modern Embedded C](https://www.diiv.io/course3/) | Per-module A64 assembly + modern-C workspaces (Makefiles, sources, notes) |
| [`course4/`](course4/) | [Course 4 — Real-Time Rendering & GPU Engineering](https://www.diiv.io/course4/) | A self-contained C++20/CMake project: Vulkan + Metal engine, Swift Metal apps, CUDA labs — build scaffolding fully set up (see [`course4/README.md`](course4/README.md)) |

**Lab instructions live on the website, not here** — this repo holds what working the labs produces: notes, code, captures, benchmarks, models. Like the site, it's expanded on weekends when I have time, so it may not be complete for a long while. But it's my weekend hobby project when I'm not dealing with work stuff that spills into weeks or family things with my wife (and I guess kids if that happens). My main priorities are my full-time job and my family, but I hope to have this fully complete at some point, enjoy the incremental progress as it updates, and hope it's useful to others.

NOTE on AI Use: I have a strong NO-AI policy for any Code and Reports you find in this repo beyond the boilerplate skeleton repo structure and build scaffolding that I used AI to help setup. The whole point of this repo is for me to learn which is why using AI to generate any code or write ups or reports would completely defeat that purpose of learning and analyzing.

## Hardware targets

| Target | Used by |
|---|---|
| **Apple Silicon Mac (M-series)** | Course 3 (A64 assembly, host clang/lldb); Course 4 (Metal natively, Vulkan via MoltenVK, Xcode GPU capture) |
| **NUCLEO-L476RG** (STM32L476RG, Cortex-M4F @ 80 MHz) | Course 2 real-time firmware (Modules 2–3, 5–7, 9); Course 3 cross-disassembly target |
| **Raspberry Pi 5** | Course 2 edge Linux target (Modules 8–9) |
| **NVIDIA Jetson Orin Nano** | Course 2 edge GPU (Modules 8–9) |
| **Linux desktop (NVIDIA RTX 4090)** | Course 4 native Vulkan + CUDA + Nsight — driven remotely from the Mac via CLion's SSH toolchain |

Plus the Course 2 bench: PSU, Fluke DMM, LCR meter, Siglent scope, Saleae logic analyzer.

## Python: one uv project for the whole repo

A single [uv](https://docs.astral.sh/uv/) project at the repo root, pinned to **Python 3.13** (`.python-version`), shared by every course's Python work — Course 2's simulate-first prototypes and analysis notebooks, and Course 4's CUDA-Python track:

```bash
uv sync                 # core: numpy/scipy/matplotlib/jupyter/pyserial/…
uv sync --group ml      # Course 2 Module 8: torch/onnx/onnxruntime/tensorflow
uv run jupyter lab
```

Device-side Python on the Pi/Jetson (CuPy, TensorRT, tflite-runtime, smbus2) is platform-specific — see `course2/docs/edge-setup.md`; Course 4's Linux-desktop CUDA group (`numba`, `cupy-cuda12x`) is described in `course4/docs/setup.md`.

## Layout

```
diiv_website_custom_courses/
  README.md
  pyproject.toml              # shared uv project (all courses' Python work)
  course2/                    # ── Embedded DSP labs ──────────────────────────
    docs/                     #   reading-map.md, edge-setup.md (Pi 5 / Jetson + C++20 CMake template)
    firmware/                 #   STM32 CMake projects (C18), one per module + arm-none-eabi toolchain file
    labs/lab-<M>-<N>/         #   one folder per lab: notes.md, host/, captures/, edge/ (M8–9)
    media/in|out/             #   Module 9 host-in-the-loop test media
    hardware/                 #   breadboard photos, LTspice .asc schematics, datasheets
  course3/                    # ── Computer architecture & ARM assembly ───────
    m0/ … m8/                 #   one folder per module: Makefile, .s/.c sources, notes.md
  course4/                    # ── Rendering & GPU engineering ────────────────
    CMakeLists.txt            #   self-contained C++20 CMake project (presets: debug/release/profile/linux-*)
    engine/  shaders/  cuda/  #   the growing engine, GLSL/MSL shaders, CUDA C++ + python/
    metal-swift/              #   SwiftPM package for the Swift/Metal lab apps
    labs/lab-<M>-<N>/         #   notes.md, captures/, benchmarks/, src/ (C++ labs)
```

**Naming convention (all courses):** everything a lab produces lives in its folder — e.g. `course2/labs/lab-2-1/notes.md`, `course4/labs/lab-5-2/captures/`. A lab is **done** when its `notes.md` has every Measured cell filled and its `captures/` folder holds the raw evidence.

## Course 2 toolchains

- **STM32 firmware** — CMake projects targeting **C18** (`-std=gnu17`; arm-none-eabi-gcc has full C17/C18 support). One project per module (labs within a module share it), generated via STM32CubeMX's CMake toolchain option with HAL/LL drivers; CMSIS-DSP for the math, FreeRTOS for Module 7. See `course2/firmware/README.md`.
- **Pi 5 / Jetson C++** — CMake projects targeting **C++20** (OpenCV, ALSA/PortAudio, and on the Jetson CUDA/cuFFT/TensorRT). See `course2/docs/edge-setup.md`.
- **Workflow: simulate in Python first.** Every algorithm is prototyped and verified in Python (NumPy/SciPy, Jupyter) in the lab's `host/` folder **before** any C or C++ is written; the compiled implementation is then validated against the Python reference, measured on real hardware, and reconciled in the lab's `notes.md`.

## Math in write-ups

Bench notes and reports use standard LaTeX math in Markdown — `$f_c = \frac{1}{2\pi RC}$` inline, `$$ … $$` display. GitHub renders this natively (MathJax), and Jupyter notebooks render it in Markdown cells out of the box. For a PDF report, export with `uv run jupyter nbconvert --to pdf` (notebooks) or `pandoc --katex` (Markdown notes).
