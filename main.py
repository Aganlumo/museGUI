import sys, os
import re
import subprocess
import numpy as np
import matplotlib
import seaborn as sns
from time import sleep, localtime, strftime
from pylsl import StreamInlet, resolve_byprop
from muselsl.constants import LSL_SCAN_TIMEOUT

import markersStream
import readMultipleStreams
import plotMuse
from DriveAPI.driveUploader import Uploader

from PyQt5.QtWidgets import *
from PyQt5.QtGui import QFont, QPixmap, QIcon
from PyQt5.QtCore import QThread

class MainWindow(QWidget):
    title = "Muse GUI"
    _id = 'test_subject'
    markers_flag = False
    lslv = None
    def __init__(self):
        super().__init__()
        self.setWindowTitle(self.title)
        self.setWindowIcon(QIcon('icons/brain_icon.png'))
        font = QFont("Poppins", 10)
        self.setFont(font)
        
        # Create Widgets
        self.lbl_title = QLabel(self.title)
        ss = "color:black; font-size:20sp; text-align:center"
        self.lbl_title.setStyleSheet(ss)

        self.lbl_icon = QLabel()
        pxm = QPixmap("icons/brain_icon.png")
        self.lbl_icon.setPixmap(pxm)
                
        # Create Buttons 
        self.btn_stream = QPushButton("Stream")
        self.btn_stream.clicked.connect(self.evt_btn_stream_clicked)

        self.btn_record = QPushButton("Record")
        self.btn_record.clicked.connect(self.evt_btn_record_clicked)
        self.btn_record.setEnabled(self.markers_flag)

        self.btn_markers = QPushButton("Start/Stop Markers Stream")
        self.btn_markers.clicked.connect(self.evt_btn_markers_clicked)
        self.btn_markers.setEnabled(self.markers_flag)

        # Create spinbox for user input time
        self.spb_duration = QSpinBox()
        self.spb_duration.setRange(1, 300)
        self.spb_duration.setSingleStep(1)
        self.spb_duration.setValue(5)

        # Plot from muselsl
        # Use Qt5 background
        matplotlib.use('Qt5Agg')
        sns.set(style="whitegrid")
        # Set size of the plot
        figsize = np.int16("10x5".split('x'))
        # Gets the figures
        self.fig, self.axes = matplotlib.pyplot.subplots(
            1, 1, figsize=figsize, sharex=True)
        # Create canvas that holds the plots
        self.canvas = matplotlib.backends.backend_qt5agg.FigureCanvas(self.fig)

        self.setup_layout()

    # Set all the layouts
    def setup_layout(self):
        self.lyt_main = QVBoxLayout()
        self.lyt_presentation = QHBoxLayout()
        self.lyt_data = QFormLayout()
        self.lyt_functionality = QGridLayout()

        self.lyt_presentation.addStretch()
        self.lyt_presentation.addWidget(self.lbl_icon)
        self.lyt_presentation.addWidget(self.lbl_title)
        self.lyt_presentation.addStretch()

        self.lyt_data.addRow("Record Time (s):", self.spb_duration)
        self.lyt_functionality.addWidget(self.btn_stream,0,0)
        self.lyt_functionality.addWidget(self.btn_markers,0,1)
        self.lyt_functionality.addWidget(self.btn_record,1,0)
        self.lyt_functionality.addLayout(self.lyt_data,1,1)

        self.lyt_main.addLayout(self.lyt_presentation)
        self.lyt_main.addLayout(self.lyt_functionality)
        self.lyt_main.addWidget(self.canvas)

        self.setLayout(self.lyt_main)

    ##############
    # Event Handlers
    ##############
        
    def evt_btn_stream_clicked(self):
        print("Looking for an EEG stream...")
        streams = resolve_byprop('type', 'EEG', timeout=LSL_SCAN_TIMEOUT)
        subprocess.call('start bluemuse:', shell=True)
        if len(streams) == 0:
            # raise(RuntimeError("Can't find EEG stream."))
            self.btn_markers.setEnabled(False)
            print("No streams available")
            self.lslv = None
        elif self.lslv is None:
            print("Start acquiring data.")
            self.lslv = plotMuse.LSLViewer(streams[0], self.fig, self.axes, 5, 100)
            self.fig.canvas.mpl_connect('close_event', self.lslv.stop)
            self.lslv.start()
            self.btn_markers.setEnabled(True)

    def evt_btn_record_clicked(self):
        # Get the path of the recordings 
        self.btn_markers.setEnabled(False)
        self.recordings_path = os.path.join(os.getcwd(), 'recordings')
        # Check for path existance. Create folder if not
        if not os.path.exists(self.recordings_path):
            os.mkdir(self.recordings_path)
        # Change to the directory
        os.chdir(self.recordings_path)
        print(self.recordings_path)
        # Sets filename to (EEG|PPG)_recording_{current_datetime}
        self.fn = '{0}_{1}'.format(self._id, strftime('%Y-%m-%d-%H_%M_%S', localtime()))
        # Starts recording thread
        self.recordings = RecordingThread()
        self.recordings.start()
        self.recordings.finished.connect(self.evt_recording_finished)
        
    def evt_recording_finished(self):
        self.btn_markers.setEnabled(True)
        os.chdir(self.recordings_path)
        os.chdir("..") 
        description = """You're about to upload the files to the Google Drive.
        Are you sure you want to do this?
        If not, no file will be saved in your system. :)
        """
        # Ask user to upload the data
        res = QMessageBox.question(self, 'Upload Files?', description)
        # Upload data if user says it is ok
        if res == QMessageBox.Yes:
            uploader = Uploader('1uaslUJGg9dQLCqc31l7xAG-dYtO4-2Po')
            # print(self.fn)
            uploader.upload(self.recordings_path, self.fn)
            # print('\n\n\n\nDONE! Files Uploaded to Drive')

        # Delete data if user says it is not ok
        else:
            files = " ".join([f for f in os.listdir(
                self.recordings_path) if os.path.isfile(os.path.join(self.recordings_path, f))])
            file_names = re.findall(
                r'((EEG_|PPG)([\w.-]+\.csv\b))', files)
            for fn in file_names:
                os.remove(os.path.join(self.recordings_path, fn[0]))

    def evt_btn_markers_clicked(self):
        if not self.markers_flag:
            # print("Here")
            self.markers = MarkerThread()
            self.markers.start()
        else:
            # print('I am wrong')
            self.markers.terminate()
        self.markers_flag = not self.markers_flag
        self.btn_record.setEnabled(self.markers_flag)


# Threads for executions
class MarkerThread(QThread):
    def run(self):
        markersStream.stream_markers()

class RecordingThread(QThread):
    def run(self):
        readMultipleStreams.record_multiple(w.spb_duration.value(), filename=w.fn)


if __name__ == "__main__":
    subprocess.call('start bluemuse:', shell=True)
    app = QApplication([sys.argv])
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())
