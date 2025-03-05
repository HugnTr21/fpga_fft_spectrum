#FPGA FFT SPECTRUM ANALYZER
FPGA FFT SPECTRUM ANALYZER is a basic audio processing tool. It can accept audio signal via Line-in 3,5mm Jack and analyze it. It also visualizes present frequencies on a Led matrix as a bar graph.
Project is implemented in Verilog HDL hardware description language and was designed to be used on Altera DE1 development board equipped with an Altera Cyclone II FPGA core. It uses WM8731 audio controller for accepting. Audio analysis and modification is done using FFT algorithm. Time-domain audio signal is transformed into frequency-domain. Frequency-domain samples are used to generate visualization.
![image](https://github.com/user-attachments/assets/af29cfa4-4808-46ea-b11e-a1af11c12dc3)
![image](https://github.com/user-attachments/assets/27a77f0d-20a7-4a3b-8628-aa6a190f79fc)
