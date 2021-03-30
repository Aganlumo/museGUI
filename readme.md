# MuseGUI

## Simple Graphical User Interface for data acquisition with Muse headbands

MuseGUI is a tool for EEG and PPG data acquisition to conduct experiments remotely. There are a couple of versions that have been developed for this purpose. The Student version is intended to only get the required data and upload it to a Google Drive folder provided by the researcher. The requirements for Windows are different to the ones in any Linux/Unix or Mac. Python requirements of this repository are under the file named `requirements`.

### Windows
For Windows it is necessary to use [`BlueMuse`](https://github.com/kowalej/BlueMuse). They provide their own installation instructions and is encorauged to see and use their repo.

### MacOSX & Linux
MacOS & Linux do not require any other software as they support [`MuseLSL`](https://github.com/alexandrebarachant/muse-lsl). The code is untested on these OS.

## Usage
First, you will need to create a [Google Application](https://developers.google.com/drive/api/v3/quickstart/python) and get the `credentials.json` file and insert it into the DriveAPI folder from this repo. This file is a secret key that you do not want to share, as it identifies your application and the use of your account with Google.  

If you want to provide the software to a non-programmer or developer, you need to provide the `credentials.json` file, as without it the app will fail and won't be able to upload the `.csv` files to the Drive folder. Also, you will need to include a `values.txt` with the folder id that will receive all the experiments from any successful run. An example of a valid folder id is presented. (The link is not valid, as it is only an example.)

> https://drive.google.com/drive/u/1/folders/1LuQPt8AreZ_ShxIprEt_dveM6fryTSXY  
> 
> The part that is the folder id is `1LuQPt8AreZ_ShxIprEt_dveM6fryTSXY` ans is what should be put in the `values.txt` file. This file is to be included in the bas folder.  

## Modifying and compiling for Windows
This code is open source and its use and modification is encouraged. If you would like to distribute your own version of the GUI, run the `.spec` file that you would like to build and you should be all setup and good to go.  

**Note:** The `.spec` files have hardcoded paths from the developers' machine, so you will need to use your specific files or create your own `.spec` files. Pyinstaller is recommended for this step.