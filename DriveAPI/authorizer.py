from __future__ import print_function
import pickle
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# try:
#     import argparse
#     flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
# except ImportError:
#     flags = None

class Authorizer:
    def __init__(self, CLIENT_SECRET_FILE, APPLICATION_NAME, SCOPES):
        self.SCOPES = [scope for scope in SCOPES]
        self.CLIENT_SECRET_FILE = CLIENT_SECRET_FILE
        self.APPLICATION_NAME = APPLICATION_NAME
        # print(self.SCOPES)

    def getCredentials(self, ):
        self.creds = None
        if os.path.exists('tokwn.pickle'):
            with open('token.pickle', 'rb') as token:
                self.creds = pickle.load(token)
        if not self.creds or not creds.valid:
            if self.creds and self.creds.expired and self.creds.refresh_token:
                self.creds.refesh(Request())
            else:
                self.flow = InstalledAppFlow.from_client_secrets_file(
                    self.CLIENT_SECRET_FILE, self.SCOPES)
                self.creds = self.flow.run_local_server(port=0)
            with open('tocken.pickle', 'wb') as token:
                pickle.dump(self.creds, token)
        return self.creds