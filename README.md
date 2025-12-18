# AndroBoomer

AndroBoomer is an automation tool for Android APK analysis. It can fetch APKs using a package name or analyze local APK files. Tools can be run individually or all together in parallel.

## Installation

```bash
git clone https://github.com/Raunaksplanet/AndroBoomer.git
cd AndroBoomer
./androboomer.sh -i
```

## Usage

### Fetch APK and run all tools

```bash
./androboomer.sh -p com.example.app -A
```

### Analyze a local APK

```bash
./androboomer.sh -a app.apk -A
```

### Run individual tools

```bash
./androboomer.sh -a app.apk -c   # apk-components-inspector
./androboomer.sh -a app.apk -f   # frida-script-gen
./androboomer.sh -a app.apk -d   # apkdig
./androboomer.sh -a app.apk -l   # apkleaks
./androboomer.sh -a app.apk -u   # apk2url
```

## Output

Each tool stores its results in its own folder:
`apk-components-inspector_Output/`, `frida-script-gen_Output/`, `apkdig_Output/`, `apkleaks_Output/`, `apk2url_Output/`

## Requirements

Linux, Python 3, pip, Rust (auto-installed if missing)
