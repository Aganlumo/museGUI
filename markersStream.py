"""Example program to demonstrate how to send string-valued markers into LSL."""

import random
import time
import keyboard

from pylsl import StreamInfo, StreamOutlet


def main():
    # first create a new stream info (here we set the name to MyMarkerStream,
    # the content-type to Markers, 1 channel, irregular sampling rate,
    # and string-valued data) The last value would be the locally unique
    # identifier for the stream as far as available, e.g.
    # program-scriptname-subjectnumber (you could also omit it but interrupted
    # connections wouldn't auto-recover). The important part is that the
    # content-type is set to 'Markers', because then other programs will know how
    #  to interpret the content
    # info = StreamInfo('Markers', 'Markers', 1, 0, 'string', 'myuidw43536')
    info = StreamInfo('Markers', 'Markers', 1, channel_format='int8', source_id='myuidw37823', )

    # next make an outlet
    outlet = StreamOutlet(info)

    print("Started markers stream...")
    # markernames = ['Test', 'Blah', 'Marker', 'XXX', 'Testtest', 'Test-1-2-3']
    while True:
        try:
            # pick a sample to send an wait for a bit
            if keyboard.is_pressed('space'):
                sample = 1
            else:
                sample = 0
            print(time.time())
            outlet.push_sample([sample], timestamp=time.time())
            time.sleep(0.004)
        except KeyboardInterrupt:
            break

if __name__ == '__main__':
    main()