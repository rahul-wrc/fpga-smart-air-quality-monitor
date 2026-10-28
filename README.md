
# FPGA-Based Smart Air Quality Monitoring System

**Verilog HDL | Xilinx Vivado | Basys 3 FPGA | UART | Sensor Interfacing**

An FPGA-based air-quality monitoring system designed using Verilog HDL and the Xilinx Basys 3 development board. The design interfaces with the Sensirion SPS30 particulate matter sensor, processes PM2.5 data, displays readings on a seven-segment display, and indicates air-quality levels using LEDs.

## Project Overview

This project implements a modular RTL architecture for FPGA-based particulate matter monitoring. Custom Verilog modules handle UART communication, sensor command transmission, packet parsing, binary-to-BCD conversion, display control, and threshold-based LED indication.

An additional UART transmitter formats PM2.5 readings as ASCII data for optional communication with an ESP32.

## System Architecture

```text
Sensirion SPS30 Sensor
          |
       UART RX
          |
     SPS30 Parser
          |
      PM2.5 Data
          |
    +-----+------+
    |            |
 Binary-to-BCD  AQI LED
    |            |
 Seven-Segment  Status LEDs
    Display
          |
   UART PM2.5 Sender
          |
        ESP32
      (Optional)
```

## Key Features

- Custom UART receiver and transmitter modules.
- SPS30 sensor command sequencing and serial communication.
- PM2.5 data extraction from received UART bytes.
- Binary-to-BCD conversion for decimal display.
- Multiplexed four-digit seven-segment display interface.
- Configurable threshold-based air-quality LED indication.
- ASCII formatting and UART transmission of PM2.5 readings to an ESP32.
- Top-level integration of the functional RTL modules.
- XDC constraints for FPGA pin assignment and clock definition.

## Hardware Components

| Component | Description |
|---|---|
| FPGA Board | Digilent Basys 3 |
| FPGA | Xilinx Artix-7 |
| Particulate Matter Sensor | Sensirion SPS30 |
| Optional Controller | ESP32 |
| Sensor Interface | UART |
| Display | Four-digit seven-segment display |
| Indicators | FPGA LEDs |

## RTL Modules

| Module | Function |
|---|---|
| `top_final` | Top-level system integration |
| `sps30_cmd_controller` | Sends configured SPS30 commands |
| `uart_rx` | Receives serial data |
| `uart_tx` | Transmits sensor command bytes |
| `sps30_parser` | Extracts PM2.5 data from received bytes |
| `bin_to_bcd` | Converts binary data to decimal digits |
| `uart_tx_esp` | Transmits serial data to the ESP32 |
| `uart_pm25_sender` | Formats PM2.5 readings as ASCII and schedules transmission |
| `aqi_led` | Generates LED outputs using configured thresholds |

## Repository Structure

```text
fpga-smart-air-quality-monitor/
├── rtl/
│   └── air_quality_monitor.v
├── constraints/
│   └── constraints_updated.xdc
└── README.md
```

## Tools and Technologies

- Verilog HDL
- Xilinx Vivado
- FPGA RTL design
- UART serial communication
- XDC pin and timing constraints
- Digital system integration

## Implementation Workflow

1. Develop the RTL modules in Verilog HDL.
2. Integrate the modules through the top-level design.
3. Configure FPGA pin assignments using the XDC file.
4. Elaborate and synthesize the design in Vivado.
5. Run implementation and review timing and constraint reports.
6. Validate UART communication, PM2.5 display output, LED indication, and optional ESP32 integration on hardware.

## Engineering Concepts Demonstrated

- Modular RTL design and integration
- UART serial communication
- Control sequencing and finite-state-machine concepts
- Serial data parsing
- Binary-to-decimal conversion
- Multiplexed seven-segment display control
- FPGA pin mapping and timing constraints
- Hardware interfacing with external sensors

## Current Status

The combined RTL source and initial FPGA constraints are included in the repository. Simulation, protocol correctness, synthesis results, and complete hardware operation still require verification.

## Future Improvements

- Develop a self-checking Verilog testbench.
- Verify UART timing and SPS30 packet parsing.
- Improve reset handling and invalid-packet detection.
- Validate PM2.5 scaling and air-quality thresholds.
- Add simulation waveforms and synthesis reports.
- Document hardware testing results and demonstration evidence.

---

**Project Focus:** FPGA Design | RTL Development | UART | Sensor Interfacing | Digital Systems
