import os
import re

directories = ['apps/palakat_admin/lib', 'apps/palakat_super_admin/lib']

pattern = re.compile(
    r'ScaffoldMessenger\.of\(\s*context,?\s*\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\((.*?)\),?\s*\),?\s*\);',
    re.DOTALL
)

for d in directories:
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                if 'ScaffoldMessenger.of' in content:
                    needs_import = False
                    
                    def replacer(match):
                        global needs_import
                        needs_import = True
                        text_content = match.group(1).strip()
                        if 'error' in text_content.lower() or 'e.tostring()' in text_content.lower() or '$e' in text_content.lower():
                            return f'AppSnackbars.showError(context, message: {text_content});'
                        else:
                            return f'AppSnackbars.showSuccess(context, message: {text_content});'

                    new_content = pattern.sub(replacer, content)
                    
                    if needs_import and 'AppSnackbars' in new_content:
                        if 'import \'package:palakat_shared/core/widgets/app_snackbars.dart\'' not in new_content and 'import \'package:palakat_shared/palakat_shared.dart\'' not in new_content:
                            lines = new_content.split('\n')
                            import_added = False
                            for i in reversed(range(len(lines))):
                                if lines[i].startswith('import '):
                                    lines.insert(i + 1, "import 'package:palakat_shared/core/widgets/app_snackbars.dart';")
                                    import_added = True
                                    break
                            if import_added:
                                new_content = '\n'.join(lines)
                            
                    if content != new_content:
                        with open(path, 'w') as f:
                            f.write(new_content)
                        print(f"Updated {path}")
