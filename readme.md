# Projekt Automatic Rocketship

## Motivation

Das Programm Rocketship wird durch ein UI ausgeführt.
Für jede Ausführung muss manuell die Daten hochgeladen und die Werte eingetragen werden.
Das kann bis zu 5 Min Pro Eintragung dauern. Dazu dauert die Ausführung auch noch zusätzlich Zeit.

Wenn man eine ganze Reihe von Patienten (mehr als 10) damit berechnen wollen.
Um mehr als 10 Patienten damit zu berechnen wird damit sehr mühselig und zeitraubend sein. 

Darum wurde diese Programm geschrieben. Damit wird das Berechnen von mehreren Patien automatisiert.
Man muss nur die Pfade zu Daten eintragen.

https://www.youtube.com/watch?v=a_986KPguXM&t=5s&ab_channel=UTemuulen

![Shopping Cart Demo](vid.gif)

## Installation
Um das Software zu benutzen braucht man Matlab.  (Wir benutzen die Version R2018a)

Auch Rocketship muss runtergeladen werden. 

https://github.com/petmri/ROCKETSHIP

Die Runtergeladenen Daten mit 
rocket_ship_projekt.m
A_make_R1maps_func_conf.m
B_AIF_fitting_func_conf.m
D_fit_voxels_func_conf.m
loadIMGVOL_conf.m

müssen alle in dem selben Ordner sein. 

Öffne: rocket_ship_projekt.m

Die Pfad  mfilepath setzen wo der ROCKETSHIP liegt.

mfilepath = "../ROCKETSHIP/";

## Benutzung und Einstellung

Die Pfad  data_path setzen wo der die Patienten Daten liegen liegen.

data_path = "../rocketship_data/";

Die hematocrit_table.xlsx in die "../rocketship_data/" reinkopieren. 
Ansonsten so lassen.  

%path to the hematocrit table
xml_data_path = data_path + 'hematocrit_table.xlsx';

von 
%parameter starts ############################################################

bis 
%parameter ends############################################################

die Parameter für die Berechnung einsetzen. 


Und dann auf "Run" Klicken.


## Implementation






# rocketship_automatic
