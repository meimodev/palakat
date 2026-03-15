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
                    # Extract roughly the actions block
                    matches = re.finditer(r'actions:\s*\[(.*?)\]', content, re.DOTALL)
                    for m in matches:
                        actions_block = m.group(1).strip()
                        # print just the button types and their labels
                        print(actions_block)
                    print("\n")
