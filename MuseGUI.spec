# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['MuseGUI.py'],
             pathex=['D:/ITESM/EEG/museGUI/', 'D:\ITESM\EEG\museGUI\Lib\site-packages'],
             binaries=[],
             datas=[('D:\ITESM\EEG\museGUI\Lib\site-packages\pylsl\*', 'pylsl\lib'),
             ('icons\*', 'icons'),
             ('D:\ITESM\EEG\museGUI\Lib\site-packages\sklearn', 'sklearn'),
             ('D:\ITESM\EEG\museGUI\Lib\site-packages\google_api_python_client-*', 'google_api_python_client-1.12.8.dist-info'),
             ('D:\ITESM\EEG\museGUI\DriveAPI', 'DriveAPI')
             ],
             hiddenimports=['sklearn', 'googleapiclient', 'apiclient'],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='MuseGUI',
          debug=False,
          strip=False,
          upx=True,
          runtime_tmpdir=None,
          console=True)
