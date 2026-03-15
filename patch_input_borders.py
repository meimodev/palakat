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
                
                # We want to remove `border: const OutlineInputBorder(),` or `border: OutlineInputBorder(),`
                # inside InputDecoration.
                # Actually, there's also `border: const OutlineInputBorder()` without trailing comma.
                # And sometimes `const InputDecoration(border: OutlineInputBorder())`
                
                new_content = re.sub(r'border:\s*const\s*OutlineInputBorder\(\s*\),?', '', content)
                new_content = re.sub(r'border:\s*OutlineInputBorder\(\s*\),?', '', new_content)
                
                # Cleanup empty InputDecorations like `const InputDecoration()` if it was `const InputDecoration(border: const OutlineInputBorder())`
                # Handled by previous regex maybe leaving `const InputDecoration()` or `InputDecoration()`
                
                if content != new_content:
                    with open(path, 'w') as f:
                        f.write(new_content)
                    print(f"Updated {path}")
