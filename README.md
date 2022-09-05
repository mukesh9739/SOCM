# SOCM - Smart Oxygen Cylinder Monitoring

# Project vision:

The amount of oxygen present inside an oxygen cylinder is a vital piece of information, as such cylinders are in use for supply of oxygen in the current COVID scenario.
Since the number of patients infected by COVID are very large, it becomes difficult to monitor all the isolation wards in a hospital simultaneously. 
Therefore, we aim to design a system which continuously monitors the oxygen level in the cyclinder and sends a notification to alert the nearest attendant along with 
the location of the cylinder, whenever the oxygen in the cylinder drops below a pre-defined threshold value. 

# Description and realization:

 Components:

•	Arduino development board – ATMEGA 32U4

•	ESP32 pico kit

•	Pressure transducer – M3031

The amount of oxygen present inside the cylinder is identified by measuring the pressure at the outlet nozzle using a high precision Pressure transducer [M3031] 
which gives an output of range from 0.5-5v for a pressure range of 0-100 psi.
The output of the pressure sensor is read and processed by a microcontroller. Using ESP32 module, the pressure values will be published to the server using MQTT protocol.
An application is developed which will read and display the values that are published by the ESP32 module. The application will generate a notification to alert the 
nearest attendant about the drop in the pressure levels of the oxygen cylinders to initiate actions like replacement of empty cylinders with filled ones. 
The App also features the location of the cylinder and redirects to Google Maps when the attendant wishes to locate the cylinder.

# References: 
1) https://ieeexplore.ieee.org/document/621606
2) https://ieeexplore.ieee.org/abstract/document/8821209 

![image](https://user-images.githubusercontent.com/83449084/118696139-431da000-b80e-11eb-89e9-264a2cf28c09.png)


# Time plan:

Week 21-2021   Acquiring pressure transducer values and sending it to Arduino

Week 22-2021	  Sending values to the ESP 32 pico kit and then to cloud - check MQTT connection using ESP32 pico kit

Week 23-2021	  Acquiring location details of the cylinder using GOOGLE LOCATION API

Week 24-2021	  Calibration and evaluvation of real-time results

Week 25-2021	  Integration

Week 26-2021	  Connect Flutter Mobile APP to MQTT cloud

Week-27-2021   Alerts using Flutter app

Week-28-2021	  Identifying nearest attendant and sending an alert to them

Week-29-2021	  Final presentation

BOM link: 	https://octopart.com/bom-tool/JY80t9N7 

# Evaluation plan:

•	Check correctness of the pressure values from the pressure transducer

•	Extracting location details using geo-location API succesfully

•	Sending alerts to the nearest attendant through the app using haversine formula, as soon as the pressure decreases beyond the threshold value. 



