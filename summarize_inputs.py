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
                
                if 'TextField(' in content or 'TextFormField(' in content:
                    print(f"--- {path} ---")
                    # simple regex to find decoration
                    for m in re.finditer(r'(?:TextFormField|TextField)\s*\([\s\S]*?decoration:\s*InputDecoration\((.*?)\),', content, re.DOTALL):
                        print(m.group(1).strip().replace('\n', ' '))
                    print("\n")
