import sys, os
import muselsl
import utils
from pylsl import StreamInlet, resolve_byprop
import numpy as np
import matplotlib.pyplot as plt
from time import sleep, localtime, strftime

from DriveAPI.driveUploader import Uploader
import markersStream
import readMultipleStreams

# from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QWidget, QPushButton, QLabel, QApplication, QSpinBox, QMessageBox
from PyQt5.QtWidgets import QVBoxLayout, QHBoxLayout, QFormLayout, QGridLayout
from PyQt5.QtGui import QFont

class MainWindow(QWidget):
    title = "Muse GUI"
    _id = 'test_subject'
    def __init__(self):
        super().__init__()
        self.setWindowTitle(self.title)
        font = QFont("Poppins", 10)
        self.setFont(font)
        
        # Create Widgets
        self.lbl_title = QLabel(self.title)
        ss = "color:black; font-size:14sp; text-align:center"
        self.lbl_title.setStyleSheet(ss)
        
        
        # Create Buttons and Info
        self.btn_stream = QPushButton("Stream")
        self.btn_stream.clicked.connect(self.evt_btn_stream_clicked)

        self.btn_record = QPushButton("Record")
        self.btn_record.clicked.connect(self.evt_btn_record_clicked)

        self.btn_markers = QPushButton("Start Markers Stream")
        self.btn_markers.clicked.connect(self.evt_btn_markers_clicked)

        self.spb_duration = QSpinBox()
        self.spb_duration.setRange(1, 300)
        self.spb_duration.setSingleStep(1)
        self.spb_duration.setValue(5)
        # self.spb_duration.setSuffix(" seconds")

        # Create Plot Widgets
        self.lbl_tp9 = QLabel("TP9")
        self.lbl_af7 = QLabel("AF7")
        self.lbl_af8 = QLabel("AF8")
        self.lbl_tp10 = QLabel("TP10")

        self.setup_layout()

    def setup_layout(self):
        self.lyt_main = QVBoxLayout()
        self.lyt_data = QFormLayout()
        self.lyt_plots = QGridLayout()

        self.lyt_plots.addWidget(self.lbl_tp9, 0, 0)
        self.lyt_plots.addWidget(self.lbl_af7, 0, 1)
        self.lyt_plots.addWidget(self.lbl_af8, 1, 1)
        self.lyt_plots.addWidget(self.lbl_tp10, 1, 0)

        self.lyt_data.addRow(self.btn_stream)
        self.lyt_data.addRow(self.btn_record)
        self.lyt_data.addRow(self.btn_markers)
        self.lyt_data.addRow("Record Time (s):", self.spb_duration)

        self.lyt_main.addWidget(self.lbl_title)
        self.lyt_main.addLayout(self.lyt_data)
        self.lyt_main.addLayout(self.lyt_plots)

        self.setLayout(self.lyt_main)
        
        
    def evt_btn_stream_clicked(self):
        muselsl.list_muses()
        print("Looking for Streams")
        streams = resolve_byprop('type', 'EEG', timeout=10)
        if len(streams) == 0:
            raise RuntimeError('Can\'t find EEG stream.')
        
        print("Start Acquiring Data")
        

    def evt_btn_record_clicked(self):
        recordings_path = os.path.join(os.getcwd(), 'recordings')
        if not os.path.exists(recordings_path):
            os.mkdir(recordings_path)
        os.chdir(recordings_path)
        fn = '{0}_{1}'.format(self._id, strftime('%Y-%m-%d-%H_%M_%S', localtime()))
        # muselsl.record(self.spb_duration.value(), filename=fn)
        readMultipleStreams.record_multiple(self.spb_duration.value(), filename=fn)
        sleep(2)
        os.chdir('..')
        description = """You're about to upload the files to the Google Drive.
        Are you sure you want to do this?
        If not, no file will be saved in your system. :)
        """
        res = QMessageBox.question(self, 'Upload Files?', description)
        if res == QMessageBox.Yes:
            uploader = Uploader('1BpPY3tQSjbjz6LM9vD5BB1nBDfoZ42xG')
            print(fn)
            uploader.upload(recordings_path, fn)
            print('\n\n\n\nDONE! Files Uploaded to Drive')
        else:
            # os.remove(os.path.join(recordings_path, fn))
            pass

    def evt_btn_markers_clicked(self):
        markersStream.stream_markers()
        # pass




if __name__ == "__main__":
    app = QApplication([sys.argv])
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())
