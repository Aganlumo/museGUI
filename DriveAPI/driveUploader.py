from __future__ import print_function
import pickle
import os
import re

from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.http import MediaFileUpload

from DriveAPI.authorizer import Authorizer

class Uploader:
    def __init__(self, folder_id):
        self.SCOPES = ['https://www.googleapis.com/auth/drive']
        self.API_NAME = 'drive'
        self.API_VERSION = 'v3'
        self.folder_id = [folder_id]
        self.credentials_path = os.getcwd()
        self.auth = Authorizer(os.path.join(self.credentials_path,'DriveAPI/credentials.json'), 
                          self.API_NAME,  self.SCOPES)
        self.service = build(self.API_NAME, self.API_VERSION, credentials=self.auth.getCredentials())

    def upload(self, path):
        # print(path)
        self.files = " ".join([f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))])
        # print(self.files)
        self.file_names = re.findall(r'[\w.-]+\.csv', self.files)
        self.mime_type = 'text/csv'
    
        for file_name in self.file_names:
            self.file_metadata = {
                'name': file_name,
                'parents': self.folder_id
            }
            self.media = MediaFileUpload(path + '\\{0}'.format(file_name), mimetype=self.mime_type)

            self.service.files().create(
                body=self.file_metadata,
                media_body=self.media,
                fields='id'
            ).execute()


if __name__ == "__main__":
    uploader = Uploader()
    uploader.upload('D:\\ITESM\\EEG\\museGUI\\recordings')
    
