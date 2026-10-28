FPGA-based PM2.5 monitoring using Verilog HDL, Sensirion SPS30, UART communication, and real-time air-quality classification.

# FPGA-Based Smart Air Quality Monitoring System

An FPGA-based air-quality monitoring project designed to acquire particulate matter measurements from a Sensirion SPS30 sensor, process PM2.5 data using Verilog HDL, and display the measurements with air-quality status indicators.

## Project Overview

This project explores real-time sensor interfacing and digital signal processing using an FPGA. The design includes UART communication, sensor command transmission, data parsing, air-quality classification, numeric conversion, and seven-segment display control.

**Target application:** Embedded sensing and FPGA-based environmental monitoring.

## Key Features

- UART-based serial communication with the SPS30 sensor
- Sensor startup command transmission
- Parsing of sensor measurement frames
- PM2.5 data processing and air-quality classification
- Binary-to-BCD conversion for numeric display
- Multiplexed seven-segment display control
- LED status indication for air-quality categories
- Potential ESP32 integration for wireless monitoring

## Hardware

- FPGA board: Digilent Basys 3 (Artix-7)
- Particulate matter sensor: Sensirion SPS30
- Optional wireless module: ESP32
- Sensor power: Appropriate regulated supply according to the sensor specifications

## Development Tools

- Verilog HDL
- AMD Xilinx Vivado
- FPGA synthesis and implementation tools
- RTL simulation and waveform debugging

## Design Architecture

The intended data flow is:

SPS30 Sensor
    |
    v
UART Receiver
    |
    v
SPS30 Data Parser
    |
    v
PM2.5 Measurement Processing
    |
    +----> Air-Quality Classifier
    |
    v
Binary-to-BCD Converter
    |
    v
Seven-Segment Display

The classifier also drives status indicators according to the configured thresholds.

## RTL Modules

| Module | Responsibility |
|---|---|
| UART RX | Receives serial data |
| SPS30 Start Command | Transmits sensor startup commands |
| SPS30 Parser | Extracts measurement data |
| AQ Classifier | Maps measurements to air-quality categories |
| Binary-to-BCD | Converts numeric data for display |
| Display Multiplexer | Drives the seven-segment display |

Update this list to match the actual source files and interfaces.

## Verification Plan

- Verify UART reception and framing behavior.
- Test parser behavior with valid and invalid frames.
- Check numeric conversion at boundary values.
- Verify air-quality classification thresholds.
- Test display multiplexing and reset behavior.
- Validate the integrated design on the FPGA board.

Only mark tests as passed after running them and recording the results.

## Implementation Status

This project has been developed as a set of RTL modules. The completeness of integration and hardware validation should be updated based on the latest simulation and board-test results.

## Future Improvements

- Complete and validate sensor-to-display integration.
- Improve automated testbench coverage.
- Add regression scripts for repeatable simulations.
- Integrate ESP32-based wireless reporting.
- Add measurement logging and a monitoring dashboard.

## Skills Demonstrated

- RTL design using Verilog HDL
- UART serial communication
- Digital logic design and modular integration
- FPGA synthesis and implementation
- Simulation-based verification and waveform debugging
- Hardware bring-up and troubleshooting

## Author

Rahul R
B.Tech, Applied Electronics & Instrumentation
