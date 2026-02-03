set shell := ["pwsh", "-NoProfile", "-Command"]

# Symlink Files
[windows]
link:
    @sudo .\SymLink.ps1 -Verbose

# Build Project or Files
[windows]
build file="":
    @if ("{{file}}" -ne "") { genlinx build "{{file}}" } else { .\build.ps1 }

# Run Tests
test:
    @.\Invoke-Test.ps1

# Run Profile
profile:
    @.\Invoke-Profile.ps1

# Archive Project
[windows]
archive:
    @.\archive.ps1
