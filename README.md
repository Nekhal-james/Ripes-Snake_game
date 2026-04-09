# 🐍 RISC-V Bare-Metal Snake

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![RISC-V](https://img.shields.io/badge/Architecture-RISC--V-orange)
![Simulator: Ripes](https://img.shields.io/badge/Simulator-Ripes-blue)

> **A high-performance, responsive Snake engine written in pure RV32I Assembly.**

---

## 🎮 Gameplay Preview
<p align="center">
  <img src="Media/Snake_game.gif" width="400" alt="RISC-V Snake Gameplay">
</p>
<p align="center">
  <img src="Media/Processor.gif" width="400" alt="RISC-V Snake Gameplay">
</p>
## 🚀 Key Features
* **Zero-Lag Input:** Custom delay-polling logic ensures high-frequency D-pad checks.
* **Manual Graphics Engine:** Direct buffer writes to a **20x20 LED Matrix**.
* **Hardware Interfacing:** Full implementation of **Memory-Mapped I/O (MMIO)**.
* **Pure Assembly:** Optimized RV32I logic with manual coordinate math (no hardware multiplier required).

---

## 🛠 Hardware Configuration
To run this in the **Ripes Simulator**, set up your I/O tab as follows:

| Peripheral | Base Address | Settings |
| :--- | :--- | :--- |
| **🕹️ D-Pad 0** | `0xf0000000` | Standard layout |
| **📺 LED Matrix 0** | `0xf0000010` | **20x20** Resolution |

### 🧠 The Memory Map
The CPU communicates with the game world through these specific addresses:
* `0xf0000000`: D-Pad **UP**
* `0xf0000010`: **Display Buffer Start**

---

## 🏗️ Project Evolution
This project started as a **C prototype** to validate the game logic. It was then hand-ported to **RISC-V Assembly** to achieve:
1.  **Lower Latency:** Removed compiler overhead for instantaneous control.
2.  **Portability:** Runs on any Ripes instance without requiring a GCC toolchain.
3.  **Resource Efficiency:** Minimized memory footprint through manual register allocation.

---

## 🕹️ Installation & Play
1.  Open [Ripes](https://github.com/mortbopet/Ripes).
2.  Select the **Single-cycle processor**.
3.  Paste the contents of `snake.s` into the **Editor**.
4.  Configure the **I/O Tab** as described above.
5.  Set speed to **Unlimited** and slither away!

---

Developed with ❤️ for the RISC-V Architecture.
