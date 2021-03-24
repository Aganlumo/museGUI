import sys, os
import re
import subprocess
import numpy as np
import matplotlib
import seaborn as sns
from time import sleep, localtime, strftime
from pylsl import StreamInlet, resolve_byprop
from muselsl.constants import LSL_SCAN_TIMEOUT, LSL_EEG_CHUNK, LSL_PPG_CHUNK

import markersStream
import readMultipleStreams
import plotMuse
from DriveAPI.driveUploader import Uploader
import labelstxts
from settingsWindow import SettingsWindow

from PyQt5.QtWidgets import *
from PyQt5.QtGui import QFont, QPixmap, QIcon
from PyQt5.QtCore import QThread

class MainWindow(QMainWindow):
    title = "Muse GUI"
    _id = 'test_subject'
    markers_flag = False
    lslv_eeg = None
    lslv_ppg = None
    lang = 0
    def __init__(self):
        super().__init__()
        self.setWindowTitle(self.title)
        self.setWindowIcon(QIcon('icons/brain_icon.png'))
        font = QFont("Poppins", 10)
        self.setFont(font)
        
        # Create Widgets
        # Create labels
        self.lbl_title = QLabel(self.title)
        ss = "color:black; font-size:20; text-align:center"
        self.lbl_title.setStyleSheet(ss)

        self.lbl_status_value = QLabel(labelstxts.texts["waiting"][self.lang])

        # Create icons
        self.lbl_icon = QLabel()
        pxm = QPixmap("icons/brain_icon.png")
        self.lbl_icon.setPixmap(pxm)
               
        # Create Buttons 
        self.btn_stream = QPushButton(labelstxts.texts["Stream"][self.lang])
        self.btn_stream.clicked.connect(self.evt_btn_stream_clicked)

        self.btn_record = QPushButton(labelstxts.texts["Record"][self.lang])
        self.btn_record.clicked.connect(self.evt_btn_record_clicked)
        self.btn_record.setEnabled(self.markers_flag)

        self.btn_markers = QPushButton(labelstxts.texts["Markers"][self.lang])
        self.btn_markers.clicked.connect(self.evt_btn_markers_clicked)
        self.btn_markers.setEnabled(self.markers_flag)

        # Create spinbox for user input time
        self.spb_duration = QSpinBox()
        self.spb_duration.setRange(1, 3000)
        self.spb_duration.setSingleStep(1)
        self.spb_duration.setValue(5)

        # Plot from muselsl
        # Use Qt5 background
        matplotlib.use('Qt5Agg')
        sns.set(style="whitegrid")
        # Set size of the plot
        figsize = np.int16("17x5".split('x'))
        # Gets the figures
        self.fig1, self.axes_eeg = matplotlib.pyplot.subplots(
            1, 4, figsize=figsize, sharex=True)
        self.fig2, self.axes_ppg = matplotlib.pyplot.subplots(
            1, 3, figsize=figsize, sharex=True)
        # Create canvas that holds the plots
        self.canvas_eeg = matplotlib.backends.backend_qt5agg.FigureCanvas(
            self.fig1)
        self.canvas_ppg = matplotlib.backends.backend_qt5agg.FigureCanvas(
            self.fig2)

        self.setup_layout()

        if not os.path.exists(os.path.join(os.getcwd(), 'values.txt')):
            self.evt_set_folder(first=True)

    # Set all the layouts
    def setup_layout(self):
        # Create Empty Layouts
        self.lyt_main = QVBoxLayout()
        self.lyt_presentation = QHBoxLayout()
        self.lyt_data = QFormLayout()
        self.lyt_status = QHBoxLayout()
        self.lyt_functionality = QGridLayout()

        # Add widgets and stretches to all layouts
        self.lyt_presentation.addStretch()
        self.lyt_presentation.addWidget(self.lbl_icon)
        self.lyt_presentation.addWidget(self.lbl_title)
        self.lyt_presentation.addStretch()

        self.lbl_record_time = QLabel(
            labelstxts.texts["RecordTime"][self.lang] + " (s)")

        self.lyt_data.addRow(self.lbl_record_time, self.spb_duration)
        self.lyt_functionality.addWidget(self.btn_stream,0,0)
        self.lyt_functionality.addWidget(self.btn_markers,0,1)
        self.lyt_functionality.addWidget(self.btn_record,1,0)
        self.lyt_functionality.addLayout(self.lyt_data,1,1)

        self.lbl_status = QLabel(labelstxts.texts["status"][self.lang])
        self.lyt_status.addStretch()
        self.lyt_status.addWidget(self.lbl_status)
        self.lyt_status.addWidget(self.lbl_status_value)
        self.lyt_status.addStretch()
        
        # Add layouts to main layout
        self.lyt_main.addLayout(self.lyt_presentation)
        self.lyt_main.addLayout(self.lyt_functionality)
        self.lyt_main.addLayout(self.lyt_status)
        self.lyt_main.addWidget(self.canvas_eeg)
        self.lyt_main.addWidget(self.canvas_ppg)
        self.lyt_main.addStretch()

        # Add main layout to central widget as super class is MainWindow
        central = QWidget()
        central.setLayout(self.lyt_main)
        self.setCentralWidget(central)
        
        # Create and set menus
        self.menu = self.menuBar()
        self.settings_menu = self.menu.addMenu(
            labelstxts.texts["languageSettings"][self.lang])
        en_settings = QAction(labelstxts.texts["languages"][0], self)
        es_settings = QAction(labelstxts.texts["languages"][1], self)
        en_settings.triggered.connect(self.set_english)
        es_settings.triggered.connect(self.set_spanish)
        self.settings_menu.addAction(en_settings)
        self.settings_menu.addAction(es_settings)
        self.folder_menu = self.menu.addMenu("Folder")
        set_folder = QAction("Select Folder", self)
        set_folder.triggered.connect(self.evt_set_folder)
        self.folder_menu.addAction(set_folder)

    ##############
    # Event Handlers
    ##############
        
    def set_english(self):
        self.lang = 0
        self.update_texts()

    def set_spanish(self):
        self.lang = 1
        self.update_texts()

    def update_texts(self):
        self.btn_stream.setText(labelstxts.texts["Stream"][self.lang])
        self.btn_markers.setText(labelstxts.texts["Markers"][self.lang])
        self.btn_record.setText(labelstxts.texts["Record"][self.lang])
        self.lbl_record_time.setText(
            labelstxts.texts["RecordTime"][self.lang] + " (s)")
        self.lbl_status.setText(labelstxts.texts["status"][self.lang])
        self.lbl_status_value.setText(labelstxts.texts["waiting"][self.lang])

    def evt_set_folder(self, first=False):
        if not first:
            with open('values.txt', 'r+') as f:
                self.folder_id = f.read()
        else:
            self.folder_id = ''
        folder_string, bOk = QInputDialog.getText(
            self, "Set folder id", "Paste your Google Drive Folder full url",
            0, self.folder_id)
        s = re.findall(r'[\w-]+$', folder_string)
        if bOk and s and (('drive.google.com' in folder_string)
            or (self.folder_id in folder_string)):
            with open('values.txt', 'w+') as f:
                f.write(s[0])
        elif first:
            QMessageBox.critical(self, "Invalid Folder",
                                "Please, set a valid url.")
            self.evt_set_folder(True)


    def evt_btn_stream_clicked(self):
        print("Looking for an EEG stream...")
        eeg_streams = resolve_byprop('type', 'EEG', timeout=LSL_SCAN_TIMEOUT)
        ppg_streams = resolve_byprop('type', 'PPG', timeout=LSL_SCAN_TIMEOUT)
        subprocess.call('start bluemuse:', shell=True)
        if len(eeg_streams) == 0 or len(ppg_streams) == 0:
            # raise(RuntimeError("Can't find EEG stream."))
            self.btn_markers.setEnabled(False)
            print("No streams available")
            self.lslv_eeg = None
            self.lslv_ppg = None
        elif self.lslv_eeg is None:
            print("Start acquiring data.")
            self.lslv_eeg = plotMuse.LSLViewer(
                eeg_streams[0], self.fig1, self.axes_eeg, 5, 150)
            self.lslv_ppg = plotMuse.LSLViewer(
                ppg_streams[0], self.fig2, self.axes_ppg, 5, 150,
                chunk=LSL_PPG_CHUNK)
            self.fig1.canvas.mpl_connect('close_event', self.lslv_eeg.stop)
            self.fig2.canvas.mpl_connect('close_event', self.lslv_ppg.stop)
            self.eeg_thread = EEGThread()
            self.ppg_thread = PPGThread()
            self.eeg_thread.start()
            self.ppg_thread.start()
            self.btn_markers.setEnabled(True)

    def evt_btn_record_clicked(self):
        # Get the path of the recordings 
        self.recordings_path = os.path.join(os.getcwd(), 'recordings')
        self.btn_markers.setEnabled(False)
        self.btn_record.setEnabled(False)
        # Sets filename to (EEG|PPG)_recording_{current_datetime}
        self.fn = '{0}_{1}'.format(self._id, strftime('%Y-%m-%d-%H_%M_%S', localtime()))
        # Starts recording thread
        self.recordings = RecordingThread()
        self.recordings.start()
        self.lbl_status_value.setText(labelstxts.texts['recording'][self.lang])
        self.recordings.finished.connect(self.evt_recording_finished)
        
    def evt_recording_finished(self):
        self.btn_markers.setEnabled(True)
        self.btn_record.setEnabled(True)
        self.lbl_status_value.setText(labelstxts.texts["finished"][self.lang])
        # Ask user to upload the data
        with open('values.txt', 'r+') as f:
            self.folder_id = f.read()
        res = QMessageBox.question(self, 'Upload Files?', labelstxts.texts["UploadConfirmation"][self.lang])
        # Upload data if user says it is ok
        if res == QMessageBox.Yes:
            uploader = Uploader(self.folder_id)
            uploader.upload(self.recordings_path, self.fn)

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
            self.markers = MarkerThread()
            self.markers.start()
        else:
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
    
class EEGThread(QThread):
    def run(self):
        w.lslv_eeg.started = True
        w.lslv_eeg.update_plot()

class PPGThread(QThread):
    def run(self):
        w.lslv_ppg.started = True
        w.lslv_ppg.update_plot()


if __name__ == "__main__":
    subprocess.call('start bluemuse:', shell=True)
    app = QApplication([sys.argv])
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())
