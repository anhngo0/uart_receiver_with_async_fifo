# uart_receiver_with_async_fifo

This project demonstrates a simple UART communication system using the **Sipeed Tang Primer 20K Lite** FPGA board. It receives serial data (characters 0–9) sent from a PC running Ubuntu and displays the received digit on a **7-segment LED**. You can press the button after that to reset the display number to 0. 

---

## Device

- Sipeed Tang Primer 20K Lite (FPGA board)
- Sipeed RV-Debugger Plus (for uploading bitstream)
- CH341 UART converter (for UART communication)
- A 7-segment LED display
- Wires, push button, resistors, breadboard

---

## Environment & Tools

- [`iverilog`](https://steveicarus.github.io/iverilog/) and [`gtkwave`](http://gtkwave.sourceforge.net/) for simulation
- Gowin FPGA Designer (for synthesis, place & route)
- [`openFPGALoader`](https://github.com/trabucayre/openFPGALoader) for programming the board
- All running on **Ubuntu**

---

## How to Run

> 📝 Note: You can run Gowin FPGA Designer using `wine` on Ubuntu.  
> However, Gowin Programmer may not detect your board.  
> Instead, use **openFPGALoader**, as recommended in the [Sipeed Wiki](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-Doc/flash-in-linux.html).

### Setup

1. Clone this project:

    ```bash
    git clone https://github.com/anhngo0/uart_receiver_with_async_fifo.git
    cd uart_receiver_with_async_fifo
    ```

2. (Optional) Simulate the UART design using Icarus Verilog and GTKWave:

    ```bash
    iverilog -o uart_receiver.vvp ./*.v
    vvp uart_receiver.vvp
    gtkwave uart_receiver.vcd
    ```

3. Open **Gowin FPGA Designer**:
    - Floorplan the design (My config is in the provided `.cst` file)
    - Synthesize, place & route the project
    - Open the generated `.fs` file in `/impl/pnr` and copy its contents into your project's `.fs` file

4. Load the bitstream to the board using **openFPGALoader**:

    ```bash
    cd ~/openFPGALoader/build # cd in your built openFPGALoader
    openFPGALoader -b tangprimer20k your_file.fs
    ```

5. Compile and run the UART sender C program:

    ```bash
    gcc uart_sender.c -o uart_sender
    ./uart_sender
    ```

---

## Result

The received character (0–9) from the PC is displayed in real time on the **7-segment display** connected to the FPGA.

> 📷 Images and waveform files can be found in the repository.
