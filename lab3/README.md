# Lab 3 — Fixed-Point Newton-Raphson Divider

## Objective

Implement a 16-bit fixed-point hardware divider on FPGA using the Newton-Raphson iterative method. The design replaces the division `A/D` with `A × (1/D)`, where the reciprocal `1/D` is computed iteratively with quadratic convergence. The result is verified against a reference non-restoring integer divider and synthesised for multiple technology targets.

---

## What Was Implemented

### Algorithm
The Newton-Raphson method finds `1/D` by iterating:

```
x_{i+1} = x_i × (2 − x_i × D)
```

Starting from an initial approximation:

```
x₀ = 48/17 − (32/17) × D
```

This converges to full 16-bit precision in **4–5 iterations**, with the number of correct bits doubling each cycle (quadratic convergence).

### Fixed-Point Format
All values use **Q7.9 fixed-point** format with scale factor `512 = 2⁹`:

| Real Value | Q7.9 Hex | Notes |
|---|---|---|
| 0.5 | `0x100` | minimum valid divisor |
| 1.0 | `0x200` | |
| 2.0 | `0x400` | constant in iteration |
| 48/17 | `0x5A5` | x₀ constant |
| 32/17 | `0x3C3` | x₀ constant |

After each 18×18-bit multiply, bits `[26:9]` are selected to remove one scale factor (`÷ 512`).

### Module Hierarchy

```
Newton_Raphson_Divider (top)
├── prescaler        — scales divisor into valid range (0.5, 1.0]
├── DFF_rg           — parameterised D flip-flop register
├── start1_reg       — converts start pulse into sustained enable
├── NRD              — iterative reciprocal calculator
│   ├── Mult0        — computes 32/17 × D for x₀
│   ├── Add0         — computes x₀ = 48/17 − Mult0
│   ├── reg3         — stores x₀
│   ├── mux_unit     — selects x₀ (first cycle) or feedback (subsequent)
│   ├── reg2         — stores current x_i
│   ├── Mult1        — computes x_i × D
│   ├── adsub1       — computes 2 − (x_i × D)
│   ├── Mult2        — computes x_{i+1} = x_i × (2 − x_i×D)
│   └── reg4         — stores x_{i+1}
└── postscaler       — corrects quotient for prescaler shifts
```

### Pre/Post Scaling
To handle divisors outside `(0.5, 1.0]`, a prescaler and postscaler were added:

```
D > 1.0  → shift D right until in range → shift_count = negative
D ≤ 0.5  → shift D left  until in range → shift_count = positive
quotient is then shifted in the opposite direction to correct
```

---

## Files

```
lab3/
├── Newton_Raphson_Divider.v   — top-level module
├── NRD.v                      — iterative reciprocal submodule
├── DFF_rg.v                   — D flip-flop register
├── start1_reg.v               — start pulse to enable converter
├── mux_unit.v                 — 2-to-1 feedback multiplexer
├── prescaler.v                — scales divisor into valid NRD range
├── postscaler.v               — corrects quotient after NRD
├── tb_divider_verify.v        — self-checking testbench (10 test cases)
├── synth.ys                   — Yosys synthesis script
└── README.md
```

---

## Tools and Technology Libraries

| Tool | Version | Purpose |
|---|---|---|
| Icarus Verilog (`iverilog`) | 11+ | Simulation |
| GTKWave | 3.3+ | Waveform viewing |
| Yosys | 0.9+ | Synthesis |
| Skywater 130nm PDK | `sky130` | ASIC synthesis target |
| GF180MCU PDK | `gf180mcu` | ASIC synthesis target |
| iCE40 / Cyclone LP | — | FPGA synthesis target |

---

## Key Results

### Simulation
All 10 testbench cases pass with exact integer match after rounding:

| TC | Division | D Status | Result |
|---|---|---|---|
| TC1 | 2.0 / 1.0 = 2 | in range | ✅ PASS |
| TC2 | 1.5 / 0.75 = 2 | in range | ✅ PASS |
| TC3 | 1.0 / 0.5 = 2 | boundary | ✅ PASS |
| TC4 | 3.0 / 1.0 = 3 | in range | ✅ PASS |
| TC5 | 2.0 / 2.0 = 1 | too large | ✅ PASS |
| TC6 | 4.0 / 2.0 = 2 | too large | ✅ PASS |
| TC7 | 3.0 / 3.0 = 1 | too large | ✅ PASS |
| TC8 | 3.0 / 1.5 = 2 | too large | ✅ PASS |
| TC9 | 2.0 / 0.25 = 8 | too small | ✅ PASS |
| TC10 | 4.0 / 0.5 = 8 | boundary | ✅ PASS |

### FPGA Utilisation (Xilinx target)

| Resource | Utilisation | Available | % |
|---|---|---|---|
| LUT | 30 | 303,600 | 0.01% |
| FF | 126 | 607,200 | 0.02% |
| DSP | 8 | 2,800 | 0.29% |
| IO | 74 | 600 | 12.33% |

The design is extremely resource-efficient. Both optimised and non-optimised synthesis runs produce **identical** resource numbers, confirming the design is already optimal as written. The 8 DSP blocks confirm that all Newton-Raphson multiplications are mapped to dedicated embedded DSP hardware, leaving the general logic fabric nearly untouched at only 0.01% utilisation.

### Comparison with Reference Paper (Bureneva et al., 2023)

| Implementation | Logic Elements | Registers | DSP Blocks | Fmax |
|---|---|---|---|---|
| LPM_Divider (library) | 1039 | 99 | — | 17 MHz |
| Non-restoring divider | 101 | 75 | — | 233 MHz |
| Newton-Raphson (paper) | 95 | 40 | 9 | 86 MHz |
| Newton-Raphson (this work) | 30 LUTs | 126 FFs | 8 | — |

---

## How to Reproduce

### Simulation

```bash
# compile
iverilog -o sim \
    Newton_Raphson_Divider.v \
    NRD.v \
    DFF_rg.v \
    start1_reg.v \
    mux_unit.v \
    prescaler.v \
    postscaler.v \
    tb_divider_verify.v

# run
vvp sim

# view waveforms
gtkwave divider_verify.vcd
```

### Synthesis (Yosys)

```bash
yosys synth.ys
```

The `synth.ys` script reads all Verilog files, shows the RTL schematic before and after optimisation, and synthesises for all three technology targets:

```tcl
read_verilog Newton_Raphson_Divider.v
read_verilog NRD.v
read_verilog DFF_rg.v
read_verilog start1_reg.v
read_verilog mux_unit.v
read_verilog prescaler.v
read_verilog postscaler.v

hierarchy -check -top Newton_Raphson_Divider
proc

# show before optimisation
show -format png -prefix before_opt Newton_Raphson_Divider

# optimise
opt_expr
opt_clean
opt
flatten
opt

# show after optimisation
show -format png -prefix after_opt Newton_Raphson_Divider

# synthesise
synth -top Newton_Raphson_Divider
stat
```

---

## Reference

> O. I. Bureneva and O. U. Kaidanovich, "FPGA-based Hardware Implementation of Fixed-point Division using Newton–Raphson Method," *2023 IV International Conference on Neural Networks and Neurotechnologies (NeuroNT)*, 2023. DOI: 10.1109/NEURONT58640.2023.10175844
