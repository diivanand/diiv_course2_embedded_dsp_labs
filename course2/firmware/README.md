# firmware/ — STM32 CMake projects (C18)

One CMake project per module, targeting the **NUCLEO-L476RG** (STM32L476RG, Cortex-M4F, hard FP, 80 MHz). Labs within a module share the module's project.

| Project | Modules / labs |
|---|---|
| `m2-timing/` | Module 2 — GPIO timing, timer interrupts, UART |
| `m3-mixed/`  | Module 3 — I²C DAC/ADC (MCP4725, ADS1115) |
| `m5-daq/`    | Module 5 — ADC single/timer-triggered/DMA-circular acquisition |
| `m6-dsp/`    | Module 6 — FIR, IIR, FFT, PSD, Goertzel, Kalman, matched filter, LMS, CFAR |
| `m7-rtos/`   | Module 7 — watchdog/HardFault, FreeRTOS pipeline, capstone |
| `m9-media/`  | Module 9 — host-in-the-loop streaming DSP (921600-baud harness) |

## Creating a module project

1. **STM32CubeMX** → New Project → board **NUCLEO-L476RG** → configure peripherals/clocks (80 MHz; see the lab's *Project & environment setup* tables on the course pages).
2. Project Manager → Toolchain/IDE: **CMake** → generate into the module folder. CubeMX emits the project's own `CMakeLists.txt` plus a `cmake/gcc-arm-none-eabi.cmake` toolchain file and the HAL/LL drivers.
3. **C standard = C18**: CubeMX generates `set(CMAKE_C_STANDARD 11)` — change it to `17` (CMake's name for the C17/C18 standard; equivalently `-std=gnu17`). arm-none-eabi-gcc fully supports C17/C18.
4. Build:

   ```sh
   cmake --preset Debug     # or: cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/gcc-arm-none-eabi.cmake
   cmake --build --preset Debug
   ```

   Flash with STM32CubeProgrammer or `pyocd`/`st-flash`.

A shared reference toolchain file lives at `cmake/gcc-arm-none-eabi.cmake` for any hand-rolled targets (e.g. host-side unit builds of DSP kernels); CubeMX-generated projects use their own generated copy.

## Libraries

- **HAL/LL drivers** — generated per project by CubeMX.
- **CMSIS-DSP** (`arm_math.h`) — used from Module 6 on. In CubeMX: Software Packs → X-CUBE, or add the [CMSIS-DSP](https://github.com/ARM-software/CMSIS-DSP) sources to the project and define `ARM_MATH_CM4`; link with the FPU flags (`-mfpu=fpv4-sp-d16 -mfloat-abi=hard`).
- **FreeRTOS** (Module 7, and the bare-metal-vs-RTOS comparison labs) — CubeMX Middleware → FREERTOS, interface **CMSIS_V2**; set the HAL timebase to a spare timer (course convention: **TIM6**), never SysTick.
- **DWT cycle counter** — the course's timing convention for benchmarking kernels (`DWT->CYCCNT` at 80 MHz).
