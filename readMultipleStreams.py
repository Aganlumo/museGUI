import os
import time
import numpy as np
import pandas as pd

from muselsl.constants import LSL_EEG_CHUNK, LSL_PPG_CHUNK
from pylsl import StreamInlet, resolve_streams

class Recorder():
    def __init__(self):
        self.recording = False
        self.progress = 0
        self.processing = False

    def record_multiple(self, filename=None):
        self.processing = False
        print("Looking for streams")
        # Gets all LSL streams within the system
        streams = resolve_streams()
        # print(len(streams))
        print(filename)
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
        description_eeg = info_eeg.desc()
        nchan_eeg = info_eeg.channel_count()
        ch_eeg = description_eeg.child('channels').first_child()
        ch_names_eeg = [ch_eeg.child_value('label')]
        for i in range(1, nchan_eeg):
            ch_eeg = ch_eeg.next_sibling()
            ch_names_eeg.append(ch_eeg.child_value('label'))
        
        # Info for PPG
        info_ppg = inlet_ppg.info()
        description_ppg = info_ppg.desc()
        nchan_ppg = info_ppg.channel_count()
        ch_ppg = description_ppg.child('channels').first_child()
        ch_names_ppg = [ch_ppg.child_value('label')]
        for i in range(1, nchan_ppg):
            ch_ppg = ch_ppg.next_sibling()
            ch_names_ppg.append(ch_ppg.child_value('label'))

        res_eeg = []
        timestamps_eeg = []
        res_ppg = []
        timestamps_ppg = []
        markers = []
        # ppgs = []
        # timestamp_markers = []
        t_init = time.time()
        last_timestamp = 0
        time_correction_eeg = inlet_eeg.time_correction()
        time_correction_ppg = inlet_ppg.time_correction()

        print("Start recording")
        while self.recording:
            # print(last_timestamp - t_init)
            try:
                chunk_eeg, ts_eeg = inlet_eeg.pull_chunk(max_samples=LSL_EEG_CHUNK)
                chunk_ppg, ts_ppg = inlet_ppg.pull_chunk(max_samples=LSL_PPG_CHUNK)
                marker, timestamp_markers = inlet_markers.pull_sample()
                # print("Seconds elapsed %.4f" % (time.time() - t_init))
                # if timestamp_markers and ts_eeg and ts_ppg:
                if ts_eeg:
                    # print('I am here')
                    res_eeg.append(chunk_eeg)
                    timestamps_eeg.extend(ts_eeg)
                if ts_ppg:
                    res_ppg.append(chunk_ppg)
                    timestamps_ppg.extend(ts_ppg)
                if timestamp_markers:
                    markers.append([marker, timestamp_markers])
                    last_timestamp = timestamp_markers
                    # print(last_timestamp)
                # progress = (last_timestamp - t_init)/(duration+1.4)*100
                # print(progress)
                if time.time() - t_init +1.2 > (10*60.0):
                    self.recording = False

            except KeyboardInterrupt:
                break

        self.processing = True
        time_correction_eeg = inlet_eeg.time_correction()
        time_correction_ppg = inlet_ppg.time_correction()
        print("Time corrections: EEG {}, PPG {}".format(time_correction_eeg, time_correction_ppg))

        res_eeg = np.concatenate(res_eeg, axis=0)
        res_ppg = np.concatenate(res_ppg, axis=0)
        timestamps_ppg = np.array(timestamps_ppg) + time_correction_ppg
        timestamps_eeg = np.array(timestamps_eeg) + time_correction_eeg
        
        ts_df_eeg = pd.DataFrame(
            np.c_[timestamps_eeg - timestamps_eeg[0]], columns=['timestamps'])
        ts_df_ppg = pd.DataFrame(
            np.c_[timestamps_ppg - timestamps_ppg[0]], columns=['timestamps'])

        res_eeg = np.c_[timestamps_eeg, res_eeg]
        res_ppg = np.c_[timestamps_ppg, res_ppg]
        data_eeg = pd.DataFrame(data=res_eeg, columns=[
                                'timestamps'] + ch_names_eeg)
        data_ppg = pd.DataFrame(data=res_ppg, columns=[
                                'timestamps'] + ch_names_ppg)

        n_markers = len(markers[0][0])
        t = time.time()
        n = 0
        for ii in range(n_markers):
            data_eeg['Marker%d' % ii] = "NaN"
            data_ppg['Marker%d' % ii] = 'NaN'
            # Process markers
            for marker in markers:
                ix_eeg = np.argmin(np.abs(marker[1] - timestamps_eeg))
                ix_ppg = np.argmin(np.abs(marker[1] - timestamps_ppg))
                self.progress = int(n/len(markers) * 100)
                n +=1
                for i in range(n_markers):
                    # print("Time elapsed: {0} (s)".format(time.time()-t))
                    data_eeg.loc[ix_eeg, 'Marker%d' % i] = marker[0][i]
                    data_ppg.loc[ix_ppg, 'Marker%d' % i] = marker[0][i]
        print("Process took {0} seconds to complete".format(time.time() - t))
        data_eeg.update(ts_df_eeg)
        data_ppg.update(ts_df_ppg)

        recordings_path = os.path.join(os.getcwd(), 'recordings')
        if not os.path.exists(recordings_path):
            os.mkdir(recordings_path)
        # Change to the directory
        os.chdir(recordings_path)
        print(recordings_path)
            
        
        data_ppg.to_csv('PPG_' + filename + '.csv', float_format='%.3f', index=False)
        data_eeg.to_csv('EEG_' + filename + '.csv', float_format='%.3f', index=False)
        self.processing = False

        print("Success! Both files written")
        os.chdir('..')


if __name__ == "__main__":
    record_multiple(5, filename='test')
