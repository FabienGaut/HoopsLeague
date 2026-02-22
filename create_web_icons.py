#!/usr/bin/env python3
from PIL import Image
import os

# Chemins
logo_path = 'assets/images/logo_black.png'
web_icons_dir = 'web/icons'

# Charger le logo
logo = Image.open(logo_path)

# Créer les différentes tailles d'icônes
sizes = [
    ('Icon-192.png', 192),
    ('Icon-512.png', 512),
    ('Icon-maskable-192.png', 192),
    ('Icon-maskable-512.png', 512),
]

for filename, size in sizes:
    # Redimensionner le logo
    resized = logo.resize((size, size), Image.Resampling.LANCZOS)
    
    # Sauvegarder
    output_path = os.path.join(web_icons_dir, filename)
    resized.save(output_path, 'PNG')
    print(f'Created {output_path}')

print('All icons created successfully!')
