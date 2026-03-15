import os
import re

directories = ['apps/palakat_admin/lib', 'apps/palakat_super_admin/lib']

for d in directories:
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                if 'AlertDialog(' in content:
                    print(f"--- {path} ---")
                    # simple extraction of actions list
                    idx = content.find('actions: [')
                    while idx != -1:
                        end_idx = content.find('],', idx)
                        if end_idx != -1:
                            print(content[idx:end_idx+2])
                        else:
                            end_idx = content.find(']', idx)
                            if end_idx != -1:
                                print(content[idx:end_idx+1])
                        idx = content.find('actions: [', end_idx)
                    print("\n")
