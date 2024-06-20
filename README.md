# TRAFFIC_LIGHT_CONTROLLER_VHDL

Implement a traffic light for an intersection of a main street and a side street. Both streets
have their red, yellow, and green signal lights. Pedestrians have walk buttons which, after
the respective traffic lights had just been red, starts the walk lights. Lastly, there is a sensor
on the main street, which indicates whether the main street is busy or not. This
specification is also illustrated below.

For the signal lights, the respective lights for both directions are wired together. Thus, you
only need to control (and provide outputs) for one instance of the main lights and one
instance of the side lights, respectively.
You need two different walk buttons, and you need to make sure to handle the walk lights
for the main street and the side street separately. However, you don’t need four walk
buttons or walk lights separately; as with the signal lights, the respective buttons and lights
for both directions are wired together.
The sensor on the main street is placed near the intersection to indicate to the controller
whether there are many cars passing over the sensor. You can assume that the sensor
provides a constant signal in case several cars pass over the sensor. 


## Traffic Light Controller Operation Modes

1. The normal operation mode begins with both main and side street showing red light,
for 3 seconds.
2. Then, the main street shows a green light for 10 s, whereas the side street stays red.
3. Then, the main lights turn to yellow for 2 s.
4. After that, both lights turn red again, for 3 s.
5. Next, the side street shows green light for 10 s, whereas the main street stays red.
6. After this, the side street shows 2 s yellow, then both lights turn to red again.
7. Under normal circumstances, this sequence repeats.
   
There are two ways the controller may deviate from the above, normal operation mode.

1. When pedestrians press a walk button at any point in time, their request has to be
memorized. Only once the respective main/side street lights was just red (for its 3 s
period), then the walk light is to be turned on. Toward the end of the green light and
during the yellow light of the respective street light, the walk light has to blink with a
frequency of 2 Hz and for 4 s in total. After that – at the same time the traffic lights turn
red again – the walk light is turned off and the walk request is to be cleared.
2. In case the sensor for the main street is on/high after 8 s of the green light phase, the
green phase has to be extended for 5 s. After that, even if the sensor is still on/high
then, the operation continues normally. Note that the side walk light, if on, would be
implicitly extended as well.
