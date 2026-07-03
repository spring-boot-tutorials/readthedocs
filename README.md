# Install required Python dependencies (Sphinx etc.)

pip install -r docs/requirements.txt

pip install sphinx-autobuild

# Auto Build

sphinx-autobuild docs/source docs/_build/html

# Build with Make

make html

# Open with your preferred browser, pointing it to the documentation index page

firefox build/html/index.html
