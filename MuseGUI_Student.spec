# -*- mode: python ; coding: utf-8 -*-


block_cipher = None


a = Analysis(['MuseGUI_Student.py'],
             pathex=['C:\\Users\\dafne\\Desktop\\museGUI', 'C:\\Users\\dafne\\Desktop\\museGUI\\Lib\\site-packages'],
             binaries=[],
             datas=[('C:\\Users\\dafne\\Desktop\\museGUI\\Lib\\site-packages\\pylsl\\*', 'pylsl\\lib'),
             ('icons\\*', 'icons'),
             ('C:\\Users\\dafne\\Desktop\\museGUI\\Lib\\site-packages\\sklearn', 'sklearn'),
             ('C:\\Users\\dafne\\Desktop\\museGUI\\Lib\\site-packages\\google_api_python_client-*', 'google_api_python_client-1.12.8.dist-info'),
             ('C:\\Users\\dafne\\Desktop\\museGUI\\DriveAPI', 'DriveAPI')],
             hiddenimports=['sklearn', 'googleapiclient', 'apiclient'],
             hookspath=[],
             hooksconfig={},
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
# Avoid warning
#to_remove = ["_check_build", "_isotonic", "_dbscan_inner", "_hierarchical_fast", "_k_means_elkan", "_k_means_fast", "_k_means_lloyd", "_cdnmf_fast", "_online_lda_fast", "_cd_fast", "_sag_fast", "_sdg_fast", "_barnes_hut_tsne", "_utils", "_pairwise_fast", "_expected_mutual_info_fast", "_ball_tree", "_dist_metrics", "_kd_tree", "_csr_polynomial_expansion", "_liblinear", "_libsvm", "_libsvm_sparse", "_criterion", "_splitter", "_tree", "_cython_blas", "_fast_dict", "_logistic_sigmoid", "_openmp_helpers", "_random", "_seq_dataset", "arrayfuncs", "graph_shortest_path", "murmurhash", "sparsefuncs_fast"]
#for b in a.binaries:
#    found = any(
#        f'{crypto}.cp39-win_amd64.pyd' in b[1]
#        for crypto in to_remove
#    )
#    if found:
#        print(f"Removing {b[1]}")
#        a.binaries.remove(b)

pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='MuseGUI_Student',
          debug=False,
          strip=False,
          upx=True,
          runtime_tmpdir=None,
          console=False)
