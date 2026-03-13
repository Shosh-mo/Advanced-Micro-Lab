# Session 4 — Asynchronous FIFO with Formal Verification

**Course:** Advanced Microelectronics Lab — ELCT1005  
**Institution:** German University in Cairo  
**Submitted by:** Shrouq Mohamed & Reem Hamada

---

## Project Overview

Design and formal verification of a parameterised asynchronous FIFO in Verilog. The FIFO uses Gray-coded pointers for safe clock domain crossing and two flip-flop synchronisers on each domain. Functional correctness is verified using a self-checking Icarus Verilog testbench, and formal correctness is proven using SymbiYosys with SystemVerilog Assertions (SVA).

---

## Repository Structure

```
session4/
├── FIFO.v            # Parameterised FIFO with embedded SVA assertions
├── FF2.v             # Two flip-flop synchroniser
├── write.v           # Write producer module
├── read.v            # Read consumer module
├── top.v             # Top-level interconnect
├── tb.sv             # Icarus Verilog self-checking testbench
├── formal.sby        # SymbiYosys configuration file
├── README.md         # This file
└── screenshots/      # GTKWave waveforms and cover traces
```

---

## FIFO Architecture

### Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| fifo_width (DATA_WIDTH) | 8 bits | Width of each data entry |
| fifo_depth | 16 entries | Depth of the FIFO |
| max_fifo_addr = $clog2(fifo_depth) | 4 bits | Address width |
| Pointer width | 5 bits (max_fifo_addr+1) | Extra MSB for wrap detection |
| clk_w | 100 MHz | Write clock (independent) |
| clk_r | 50 MHz | Read clock (independent) |

### Gray-Coded Pointer Scheme

Binary pointers can change multiple bits simultaneously at certain transitions (e.g. 0111 → 1000), causing metastability when sampled across clock domains. Gray code ensures only one bit changes per increment, so the two flip-flop synchroniser only ever resolves at most one metastable bit.

Gray code is computed from the next binary value on each clock edge:
```verilog
wr_ptr_g <= (wr_ptr_b + 1) ^ ((wr_ptr_b + 1) >> 1);
```

### Full Flag Logic (wclk domain)
```verilog
assign full = (wr_ptr_g[max_fifo_addr-1]   != rd_ptr_g_sync[max_fifo_addr-1]) &&
              (wr_ptr_g[max_fifo_addr-2:0] == rd_ptr_g_sync[max_fifo_addr-2:0]);
```

### Empty Flag Logic (rclk domain)
```verilog
assign empty = (wr_ptr_g_sync == rd_ptr_g);
```

### Two Flip-Flop Synchroniser

Two FF2 instances cross the Gray pointers in opposite directions:
- `sync_ff_w`: clocked by `clk_r` — brings `wr_ptr_g` into the rclk domain for empty detection
- `sync_ff_r`: clocked by `clk_w` — brings `rd_ptr_g` into the wclk domain for full detection

---

## SVA Formal Properties

All properties are embedded inside `` `ifdef FORMAL `` / `` `endif `` guards in `FIFO.v`. The `-formal` flag in `formal.sby` defines the `FORMAL` macro automatically.

### Property Table

| Type | Property | Description | Result |
|------|----------|-------------|--------|
| assert | no_overflow | FIFO never performs a write when full is asserted | ✅ PASS |
| assert | no_underflow | FIFO never performs a read when empty is asserted | ✅ PASS |
| assert | ptr_in_range | Write pointer never exceeds fifo_depth | ✅ PASS |
| assume | assume_no_wen_when_full | Constrains environment: wr_en never asserted when full | — |
| assume | assume_no_ren_when_empty | Constrains environment: rd_en never asserted when empty | — |
| cover | c_full | FIFO can reach full == 1 | ✅ PASS |
| cover | c_empty | FIFO can reach empty == 1 | ✅ PASS |

### SVA Code

```verilog
`ifdef FORMAL

//ASSUMES
always @(posedge clk_w) begin
    assume_no_wen_when_full  : assume (!(wr_en && full));
end

always @(posedge clk_r) begin
    assume_no_ren_when_empty : assume (!(rd_en && empty));
end

//ASSERTIONS
always @(posedge clk_w) begin
    no_overflow  : assert (!(wr_en && full));
    ptr_in_range : assert (wr_ptr_b <= fifo_depth);
end

always @(posedge clk_r) begin
    no_underflow : assert (!(rd_en && empty));
end

//COVER
always @(posedge clk_w) begin
    c_full  : cover (full);
end

always @(posedge clk_r) begin
    c_empty : cover (empty);
end

`endif
```

---

## SymbiYosys Results

### Terminal Output (Final Summary)

```
SBY [formal_bmc]   summary: engine_0 (smtbmc) returned pass
SBY [formal_bmc]   summary: engine_0 did not produce any traces
SBY [formal_bmc]   DONE (PASS, rc=0)

SBY [formal_cover] summary: engine_0 (smtbmc) returned pass
SBY [formal_cover] summary: cover trace: formal_cover/engine_0/trace0.vcd
SBY [formal_cover] summary:   reached cover statement FIFO.c_full at step 1
SBY [formal_cover] summary: cover trace: formal_cover/engine_0/trace1.vcd
SBY [formal_cover] summary:   reached cover statement FIFO.c_empty at step 1
SBY [formal_cover] DONE (PASS, rc=0)

SBY [formal_prove] summary: engine_0 (smtbmc) returned pass for basecase
SBY [formal_prove] summary: engine_0 (smtbmc) returned pass for induction
SBY [formal_prove] summary: successful proof by k-induction.
SBY [formal_prove] DONE (PASS, rc=0)
```

All three tasks — BMC, cover, and k-induction prove — passed with zero failures.

---

## Simulation Waveforms

Screenshots are located in the `screenshots/` folder.

| File | Description |
|------|-------------|
| `screenshots/task1_terminal.png` | Icarus Verilog terminal — 32 PASS / 0 FAIL |
| `screenshots/task1_gtkwave.png` | GTKWave waveform — clk_w, clk_r, wdata, rdata, wfull, rempty |
| `screenshots/task2_bmc_pass.png` | SymbiYosys BMC terminal output — PASS |
| `screenshots/task2_cover_full.png` | GTKWave cover trace — c_full (trace0.vcd) |
| `screenshots/task2_cover_empty.png` | GTKWave cover trace — c_empty (trace1.vcd) |
| `screenshots/task2_induction.png` | SymbiYosys k-induction — successful proof |

---

## Reproduction Instructions

### 1. Simulate with Icarus Verilog

```bash
iverilog -g2012 -o sim.vvp FF2.v FIFO.v read.v write.v top.v tb.sv
vvp sim.vvp
gtkwave tb.vcd
```

### 2. Run Formal Verification with SymbiYosys

First activate OSS CAD Suite (required once per terminal session):
```bash
source ~/oss-cad-suite/environment
```

Then run:
```bash
sby -f formal.sby
```

This runs three tasks automatically: `formal_bmc`, `formal_cover`, and `formal_prove`.

### 3. View Cover Traces in GTKWave

```bash
gtkwave formal_cover/engine_0/trace0.vcd
gtkwave formal_cover/engine_0/trace1.vcd
```
