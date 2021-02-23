import time
import numpy as np

from muselsl.constants import LSL_EEG_CHUNK, LSL_PPG_CHUNK
from pylsl import StreamInlet, resolve_streams

def record_multiple(duration, filename=None):
    print("Looking for streams")
    # Gets all LSL streams within the system
    streams = resolve_streams()
    if len(streams) < 3:
        raise ValueError("Insufficient Streams")
    # Assign each used stream to an inlet
    for stream in streams:
        if stream.type() == 'EEG':
            inlet_eeg = StreamInlet(stream, max_chunklen=LSL_EEG_CHUNK)
        elif stream.type() == 'PPG':
            inlet_ppg = StreamInlet(stream, max_chunklen=LSL_PPG_CHUNK)
        elif stream.type() == 'Markers':
            inlet_markers = StreamInlet(stream)

    # Get info and description of channels names for data dumping
    # Info for PPG
    info_eeg = inlet_eeg.info()
    description_eeg = info_eeg.description()
    nchan_eeg = info_eeg.channel_count()
    ch_eeg = description_eeg.child('channels').first_child()
    ch_names_eeg = [ch_eeg.child_value('label')]
    for i in range(1, nchan_eeg):
        ch_eeg = ch_eeg.next_sibling()
        ch_names_eeg.append(ch_eeg.child_value('label'))
    
    # Info for PPG
    info_ppg = inlet_ppg.info()
    description_ppg = info_ppg.description()
    nchan_ppg = info_ppg.channel_count()
    ch_ppg = description_ppg.child('channels').first_child()
    ch_names_ppg = [ch_ppg.child_value('label')]
    for i in range(1, nchan_ppg):
        ch_ppg = ch_ppg.next_sibling()
        ch_names_ppg.append(ch_ppg.child_value('label'))

    res_eeg = []
    timestamp_eeg = []
    res_ppg = []
    timestamp_ppg = []
    markers = []
    timestamp_markers = []
    t_init = time.time()
    time_correction_eeg = inlet_eeg.time_correction()
    time_correction_ppg = inlet_ppg.time_correction()

    while True:
        try:
            chunk_eeg, timestamp_eeg = inlet_eeg.pull_chunk(time_out=1.0)
            chunk_ppg, timestamp_ppg = inlet_ppg.pull_chunk(time_out=1.0)
            chung_marker, timestamp_markers = inlet_markers.pull_chunk(time_out=1.0)
            if timestamp_markers and timestamp_eeg and timestamp_ppg:
                timestamps1 = np.array(timestamp_eeg) - timestamp_markers
                timestamps2 = np.array(timestamp_ppg) - timestamp_markers
    #             print("""timestamp_markers {};
    # sample {}//\n
    # timestamp_eeg {};
    # chunk_eeg {} //\n
    # timestamp_ppg {};
    # chunk_ppg\n\n""".format(timestamp_markers, sample, 
    #                     timestamp_eeg, chunk_eeg, timestamp_ppg, chunk_ppg))
                print("Difference betwwen EEG and markers {}".format(timestamps1))
                print("Difference betwwen PPG and markers {}".format(timestamps2))
                print('\n\n\n\nNEXT_CHUNK\n\n\n