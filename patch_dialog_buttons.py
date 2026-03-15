import os
import re

directories = ['apps/palakat_admin/lib', 'apps/palakat_super_admin/lib']

# Replace FilledButton with FilledButton.tonal when inside actions block and containing a destructive label
def replace_in_file(path):
    with open(path, 'r') as f:
        content = f.read()
    
    if 'AlertDialog(' not in content:
        return
        
    new_content = content
    # Look for FilledButton inside actions
    destructive_labels = ['btn_delete', 'btn_reject', 'btn_discard']
    
    # Simple search and replace for specific known destructive blocks
    # btn_delete
    new_content = re.sub(
        r'FilledButton\(\s*onPressed:\s*\(\)\s*=>\s*Navigator\.of\(context\)\.pop\(true\),\s*child:\s*Text\(l10n\.btn_delete\),\s*\)',
        r'FilledButton.tonal(\n              onPressed: () => Navigator.of(context).pop(true),\n              child: Text(l10n.btn_delete),\n            )',
        new_content
    )
    new_content = re.sub(
        r'FilledButton\(\s*onPressed:\s*\(\)\s*=>\s*Navigator\.of\(context\)\.pop\(true\),\s*child:\s*Text\(context\.l10n\.btn_delete\),\s*\)',
        r'FilledButton.tonal(\n              onPressed: () => Navigator.of(context).pop(true),\n              child: Text(context.l10n.btn_delete),\n            )',
        new_content
    )
    
    # btn_reject
    new_content = re.sub(
        r'FilledButton\(\s*onPressed:\s*\(\)\s*=>\s*Navigator\.of\(context\)\.pop\(true\),\s*child:\s*Text\(l10n\.btn_reject\),\s*\)',
        r'FilledButton.tonal(\n              onPressed: () => Navigator.of(context).pop(true),\n              child: Text(l10n.btn_reject),\n            )',
        new_content
    )
    new_content = re.sub(
        r'FilledButton\(\s*onPressed:\s*\(\)\s*=>\s*Navigator\.of\(context\)\.pop\(true\),\s*child:\s*Text\(context\.l10n\.btn_reject\),\s*\)',
        r'FilledButton.tonal(\n              onPressed: () => Navigator.of(context).pop(true),\n              child: Text(context.l10n.btn_reject),\n            )',
        new_content
    )

    # btn_discard
    new_content = re.sub(
        r'FilledButton\(\s*onPressed:\s*\(\)\s*=>\s*Navigator\.of\(context\)\.pop\(true\),\s*child:\s*Text\(l10n\.btn_discard\),\s*\)',
        r'FilledButton.tonal(\n              onPressed: () => Navigator.of(context).pop(true),\n              child: Text(l10n.btn_discard),\n            )',
        new_content
    )
    new_content = re.sub(
        r'FilledButton\(\s*onPressed:\s*\(\)\s*=>\s*Navigator\.of\(context\)\.pop\(true\),\s*child:\s*Text\(context\.l10n\.btn_discard\),\s*\)',
        r'FilledButton.tonal(\n              onPressed: () => Navigator.of(context).pop(true),\n              child: Text(context.l10n.btn_discard),\n            )',
        new_content
    )
    
    if content != new_content:
        with open(path, 'w') as f:
            f.write(new_content)
        print(f"Updated {path}")

for d in directories:
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                patch_path = os.path.join(root, file)
                replace_in_file(patch_path)

