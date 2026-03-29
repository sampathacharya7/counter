# 3-bit Synchronous Counter in Verilog

A complete implementation of a 3-bit synchronous counter with comprehensive documentation, testbench, and detailed theory.

## 📋 Table of Contents
- [Overview](#overview)
- [Theory](#theory)
- [Module Description](#module-description)
- [File Structure](#file-structure)
- [Usage](#usage)
- [Simulation](#simulation)
- [Theory Deep Dive](#theory-deep-dive)
- [Applications](#applications)
- [Future Enhancements](#future-enhancements)

---

## Overview

This project implements a **synchronous 3-bit up counter** in Verilog with the following features:
- **Bit Width**: 3 bits (counts from 0 to 7)
- **Synchronous Design**: All state changes synchronized with clock
- **Asynchronous Reset**: Quick initialization capability
- **Enable Control**: Flexible counting control
- **Complete Testbench**: Full behavioral verification

### Key Specifications
```
Count Range:     0 to 7 (2^3 - 1)
Bit Width:       3 bits
Clock Type:      Synchronous (rising edge triggered)
Reset Type:      Asynchronous (active high)
Overflow:        Wraps around to 0 after 7
Total States:    8 (0, 1, 2, 3, 4, 5, 6, 7)
```

---

## Theory

### What is a Counter?

A **counter** is a sequential digital circuit that counts clock pulses and outputs the count as a binary number. Counters are fundamental building blocks in digital design used for timing, event counting, frequency division, and address generation.

### 3-bit Counter Specifics

A **3-bit counter** uses 3 flip-flops to create 2³ = **8 possible states** (0 through 7).

#### Binary Counting Sequence for 3-bit

```
Decimal  Binary  Hex
0        000     0x0
1        001     0x1
2        010     0x2
3        011     0x3
4        100     0x4
5        101     0x5
6        110     0x6
7        111     0x7
0        000     0x0 (Overflow - wraps)
```

### Types of Counters

#### 1. **Synchronous vs Asynchronous**
| Feature | Synchronous | Asynchronous |
|---------|-------------|--------------|
| Clock | All FFs share same clock | Ripple effect (cascaded) |
| Speed | Faster | Slower (propagation delay) |
| Power | Higher (all toggle) | Lower |
| Design | Complex | Simple |
| **Used Here** | ✅ Yes | ❌ No |

#### 2. **Up Counter**
- Increments on each clock pulse: 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 0
- **Used in this project** ✅

#### 3. **Down Counter**
- Decrements on each clock pulse: 7 → 6 → 5 → ... → 1 → 0 → 7

#### 4. **Up/Down Counter**
- Can count in both directions based on control signal

---

## Module Description

### Verilog Module: `counter`

```verilog
module counter (
    input clk,              // Clock signal
    input reset,            // Asynchronous reset (active high)
    input enable,           // Enable counting
    output reg [2:0] count  // 3-bit counter output
);
```

### Signal Definitions

| Signal | Type | Width | Description |
|--------|------|-------|-------------|
| `clk` | Input | 1 bit | Clock input - increments count on rising edge |
| `reset` | Input | 1 bit | Asynchronous reset - sets count to 0 when HIGH |
| `enable` | Input | 1 bit | Enable signal - allows counting when HIGH, holds when LOW |
| `count` | Output | 3 bits | Counter output (0-7) |

### Operating Modes

| Reset | Enable | Behavior |
|-------|--------|----------|
| 1 | X | Count = 0 (Reset active) |
| 0 | 0 | Hold current value |
| 0 | 1 | Increment by 1 on clock edge |

---

## File Structure

```
counter-repo/
├── README.md                 # This file
├── verilog/
│   ├── counter.v            # Main counter module
│   └── counter_tb.v         # Testbench
└── .gitignore               # Git ignore file
```

---

## Usage

### Instantiation

```verilog
counter my_counter (
    .clk(system_clock),
    .reset(system_reset),
    .enable(count_enable),
    .count(counter_output)
);
```

### Simple Example

```verilog
module top_module;
    reg clk, reset, enable;
    wire [2:0] count;
    
    counter uut(.clk(clk), .reset(reset), .enable(enable), .count(count));
    
    initial begin
        clk = 0;
        reset = 1;
        enable = 0;
        
        #10 reset = 0;      // Release reset
        #10 enable = 1;     // Start counting
        
        #200 $finish;       // Run for 200 time units (8 counts + overflow)
    end
    
    always #5 clk = ~clk;   // 10ns clock period
endmodule
```

---

## Simulation

### Requirements
- Verilog simulator (iverilog, ModelSim, VivadoSim, etc.)
- GTKWave (for waveform viewing - optional)

### Running Simulation (using iverilog)

```bash
# Navigate to verilog directory
cd verilog

# Compile both modules
iverilog -o counter_sim counter.v counter_tb.v

# Run simulation
vvp counter_sim

# View waveforms (optional)
gtkwave dump.vcd
```

### Expected Output

```
Time    Reset   Enable  Count
0       1       0       0
10      0       0       0
20      0       1       0
30      0       1       1
40      0       1       2
50      0       1       3
60      0       1       4
70      0       1       5
80      0       1       6
90      0       1       7
100     0       1       0    <- Overflow!
```

---

## Theory Deep Dive

### How Synchronous 3-bit Counting Works

#### Step 1: Clock Edge Detection
```verilog
always @(posedge clk or posedge reset)
```
- Block executes on **rising edge of clock** or **rising edge of reset**
- `posedge` = positive edge (LOW to HIGH transition)

#### Step 2: Reset Logic (Asynchronous)
```verilog
if (reset)
    count <= 3'b0;
```
- When `reset = 1`, counter immediately sets to 000 (binary)
- **Asynchronous** = happens independently of clock
- Ensures predictable initialization

#### Step 3: Count Logic (Synchronous)
```verilog
else if (enable)
    count <= count + 1;
```
- Only executes if reset is inactive
- Increments count by 1 when `enable = 1`
- **Synchronous** = happens only at clock edge
- After 111 (7), next increment gives 000 (0) - overflow

#### Step 4: Hold Logic
- When `enable = 0`, counter maintains current value
- No explicit code needed (implicit in Verilog)

### Non-blocking Assignment (`<=`)

```verilog
count <= count + 1;  // Non-blocking (CORRECT)
count = count + 1;   // Blocking (WRONG for sequential logic!)
```

**Why non-blocking?**
- Updates at end of time step (prevents race conditions)
- Proper sequential logic behavior
- Multiple assignments don't interfere

### Timing Diagram (Full Cycle)

```
Clock:    ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐
          └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘

Reset:    ──┐
           └────────────────────────────────

Enable:        ┌──────────────────────────────
               │

Count:    0   0  0  1  2  3  4  5  6  7  0
              │10│20│30│40│50│60│70│80│90│100 (time ns)
```

### State Diagram

```
        ┌─────────────────┐
        │   Reset = 1     │
        │   Count = 000   │
        └────────┬────────┘
                 │
                 │ Reset = 0
                 ▼
        ┌─────────────────┐
        │  Reset = 0      │
        │  Enable = 0     │ ◄─────┐
        │  Count = Hold   │       │
        └────────┬────────┘       │
                 │                │
                 │ Enable = 1     │ Enable = 0
                 ▼                │
        ┌─────────────────┐       │
        │ Count = Count+1 │───────┘
        │ (at clk edge)   │
        │ Wraps: 7→0     │
        └─────────────────┘
```

### Flip-Flop Implementation (Logic)

A 3-bit counter internally uses **3 flip-flops**:

```
        ┌─────────────────────────────────┐
        ���    3-bit Counter Internal       │
        │                                 │
    ┌──►│  FF[0] (LSB) ──► count[0]      │
    │   │                                 │
 clk│   │  FF[1]       ──► count[1]      │
    │   │                                 │
    └──►│  FF[2] (MSB) ──► count[2]      │
        │                                 │
        └─────────────────────────────────┘
```

Each flip-flop stores one bit of the count value.

### Maximum Count and Overflow

```
Maximum Value = 2^n - 1
               = 2^3 - 1
               = 8 - 1
               = 7

Binary: 111
Decimal: 7

After 7, next clock edge:
  111 + 1 = 1000 (4 bits)
  Overflow! Only 3 bits kept
  Result: 000 (wraps to 0)
```

---

## Binary Arithmetic in 3-bit

```
  111    (7)
+   1    (1)
------
 1000   (8) ← Overflow! (needs 4 bits)
 
With 3-bit overflow:
  000    (0) ← We get 0 due to overflow
```

---

## Applications

### 1. **Frequency Divider**
Divide clock frequency by 2^n
```
Clock: 100 MHz
Counter bit 0: 50 MHz
Counter bit 1: 25 MHz
Counter bit 2: 12.5 MHz (1/8 of original)
```

### 2. **Event Counter**
Count external events/pulses up to 7

### 3. **State Machine Sequencer**
Sequence through 8 states (0-7)

### 4. **Timer with 8 Steps**
Generate timing signals for 8 phases

### 5. **Address Generator (Memory)**
Access memory locations 0-7 sequentially

### 6. **Multiplex Control**
Select between 8 different inputs/outputs

### 7. **Ring Counter**
Create rotating bit patterns

---

## How the Testbench Works

The testbench (`counter_tb.v`) verifies the counter through:

### 1. **DUT Instantiation**
```verilog
counter uut (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .count(count)
);
```
Creates instance of counter module for testing.

### 2. **Clock Generation**
```verilog
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
```
Continuous 10ns period clock (100 MHz).

### 3. **Test Scenarios**
- Reset verification (count → 0)
- Counter increment (0 → 1 → 2 → ... → 7)
- Enable/disable control (hold/count)
- Overflow behavior (7 → 0)
- Asynchronous reset during counting

### 4. **Output Monitoring**
```verilog
$monitor("%0t\t%b\t%b\t%d", $time, reset, enable, count);
```
Displays signals whenever they change.

---

## Counter Sequence Table

| Clock Cycle | Count (Binary) | Count (Decimal) | Notes |
|-------------|---|---|---|
| 0 | 000 | 0 | Initial after reset |
| 1 | 001 | 1 | |
| 2 | 010 | 2 | |
| 3 | 011 | 3 | |
| 4 | 100 | 4 | |
| 5 | 101 | 5 | |
| 6 | 110 | 6 | |
| 7 | 111 | 7 | Maximum value |
| 8 | 000 | 0 | **Overflow - wraps** |
| 9 | 001 | 1 | Pattern repeats |

---

## Future Enhancements

### Possible Improvements
1. **Modulo Counter** - Count to N instead of 7
2. **Up/Down Counter** - Add direction control
3. **Preset Value** - Load initial count
4. **Synchronous Reset** - Reset only at clock edge
5. **Parameterized Width** - Make bit width configurable
6. **BCD Counter** - Count 0-9 in BCD format

### Example: Parameterized Counter
```verilog
module counter #(parameter WIDTH = 3) (
    input clk,
    input reset,
    input enable,
    output reg [WIDTH-1:0] count
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= {WIDTH{1'b0}};
        else if (enable)
            count <= count + 1;
    end
endmodule
```

---

## Design Principles

| Principle | Benefit |
|-----------|---------|
| **Synchronous Design** | Predictable timing, easier to analyze |
| **Asynchronous Reset** | Quick initialization, essential for startup |
| **Enable Signal** | Flexible control, power saving |
| **Non-blocking Assignment** | Proper sequential behavior |
| **Minimal Bit Width** | Reduces power consumption, area, and cost |

---

## Waveform Example (Complete Cycle)

```
      0ns  10ns 20ns 30ns 40ns 50ns 60ns 70ns 80ns 90ns 100ns
      |    |    |    |    |    |    |    |    |    |    |
clk   ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌─
      └────┘    └────┘    └────┘    └────┘    └────┘    └─

reset ──┐
        └────────────────────────────────────────────────

enable        ┌─────────────────────────────────────────
              │

count [0]     ┌─────┐        ┌─────┐        ┌─────┐   ┌─
      [1]     │     └────┐   │     └────┐   │     └──┐│
      [2]     │          └───┘          └───┘        └┘

      000     000  001  010  011  100  101  110  111 000
```

---

## References

- IEEE Std 1364-2005 (Verilog Language Reference)
- Digital Design Principles and Practices - John F. Wakerly
- Verilog HDL Basics - Amir Roth

---

## Author & License

**Author**: sampathacharya7

**License**: MIT License

Feel free to use this project for educational and commercial purposes.

---

## Contributing

Contributions are welcome! Please feel free to:
- Report bugs
- Suggest improvements
- Submit pull requests
- Add more testcases

---

## Contact & Support

For questions or suggestions, please open an issue on GitHub.

**Repository**: [counter-repo](https://github.com/sampathacharya7/counter-repo)

---

**Last Updated**: 2026-03-29
**Bit Width**: 3 bits
**Count Range**: 0-7
