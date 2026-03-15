import os
import re

directories = ['apps/palakat_admin/lib', 'apps/palakat_super_admin/lib']

destructive_labels = ['btn_delete', 'btn_reject', 'btn_discard']

for d in directories:
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                if 'AlertDialog(' in content:
                    idx = content.find('AlertDialog(')
                    while idx != -1:
                        end_idx = content.find(');', idx)
                        if end_idx == -1:
                            break
                        dialog_block = content[idx:end_idx]
                        
                        # Find if any destructive action is inside this dialog
                        has_destructive = False
                        for label in destructive_labels:
                            if label in dialog_block:
                                has_destructive = True
                                break
                        
                        if has_destructive:
                            print(f"File: {path}")
                            print(dialog_block)
                            print("-" * 40)
                            
                        idx = content.find('AlertDialog(', end_idx)
