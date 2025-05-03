# Multi-hop-Satellite-Communication
This project is carried out with the objective of a multi-hop satellite communication between two ground stations, and link analysis on the established links.
The simulation and analysis is performed using MATLAB's __Satellite Communication Toolbox__. The project is based on MathWorks's example project "Multi-Hop Satellite Communication" given under the toolbox documentation.

# Scenario
Two satellites orbiting in different orbital planes are created as communication relays, with two ground stations on Earth as transmitter and receiver. The following diagram is a pictorial representation of the scenario:  
![image](https://github.com/user-attachments/assets/7af75a90-1855-4f6a-9c52-7d02ccd8f101)  
The connections between the satellites and ground stations include an uplink from ground station transmitter to the first satellite, which then relays the communication signal to the second satellite with the help of a cross-link. The second satellite relays the information to receiver ground station through downlink connection.  
![image](https://github.com/user-attachments/assets/1a6a6d49-bbe0-43c6-af58-6082507f6832)  

# Link and Antenna Setup
1. Both satellites transmit with a power of 15dBW.
2. Crosslink frequency is 30GHz, and downlink frequency is 27GHz- frequency allocation is practised.
3. The antennas used are of Gaussian-type.

# Link Analysis
1. Latency calculation in uplink, cross-lin, and downlink
2. Link margin calculation at Receiver ground station
3. Signal strength calculation and plot at transmitter and receiver end
4. Timeseries plot of link availability
