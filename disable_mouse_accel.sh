#!/bin/bash

#wait for the desktop to settle
sleep 5

#gets the hardware id's of all mice plugged into the system
hardwareIds=$(xinput | grep -i mouse | awk '{print substr($(NF-3),4)}')

#turn off mouse acceleration
for i in $hardwareIds
do
xinput set-prop ${i} 'Device Accel Profile' -1
xinput set-prop ${i} 'Device Accel Velocity Scaling' 1
done

#gets the hardware id's of all mice plugged into the system
hardwareIds=$(xinput | grep -i pointer | awk '{print substr($(NF-3),4)}')

#turn off mouse acceleration
for i in $hardwareIds
do
xinput set-prop ${i} 'Device Accel Profile' -1
xinput set-prop ${i} 'Device Accel Velocity Scaling' 1
done

# turn off mouse acceleration
# xinput set-prop 'PIXART USB OPTICAL MOUSE' 'Device Accel Profile' -1
# xinput set-prop 'PIXART USB OPTICAL MOUSE' 'Device Accel Velocity Scaling' 1