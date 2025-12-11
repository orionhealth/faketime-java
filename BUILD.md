# Build Guide — faketime-java

This project builds platform-specific JNI native libraries packaged as classifier JARs under the `faketime-agent` module.

## Supported Platforms

The CI matrix builds and publishes the following classifiers:

- **macOS**
  - `mac_x86_64`
  - `mac_aarch64`

- **Linux**
  - `linux_x86_32`
  - `linux_x86_64`
  - `linux_aarch64` (native if running on ARM64, or cross-compiled using `aarch64-linux-gnu-gcc` on x86_64)

- **Windows**
  - `windows_x86_32`
  - `windows_x86_64`

## Windows ARM64

- Not built on GitHub-hosted runners: Ubuntu’s `mingw-w64` only supports x86 and x64 targets.  
- The old `windows-arm64-cross` profile has been **removed** to avoid confusion.  
- To support Windows ARM64:
  - Provide a **self-hosted Windows ARM64 runner** (e.g. Surface Pro X, Windows Dev Kit 2023).  
  - Add a `<profile id="windows-arm64">` to `modules/agent/pom.xml` with activation `<arch>aarch64</arch>`.  
  - Update `compile_win32.bat` or create `compile_win_arm64.bat` using MSVC or a custom MinGW-w64 ARM64 toolchain.  
  - Add a workflow job with `runs-on: [self-hosted, Windows, ARM64]`.

## Local Build

Make sure `JAVA_HOME` is set to a JDK (Java 21 recommended).

### macOS (x86_64 + arm64)
```bash
cd modules/agent
mvn -DskipTests package
```

### Linux x86_64 host
Install multilib toolchain for 32-bit:
```bash
sudo apt-get update
sudo apt-get install -y build-essential gcc-multilib g++-multilib
cd modules/agent
mvn -DskipTests package
```

### Linux ARM64 host
```bash
cd modules/agent
mvn -DskipTests package
```

### Linux ARM64 cross on x86_64 host
```bash
sudo apt-get update
sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
cd modules/agent
mvn -DskipTests -Dlinux.arm64.cross=true package
```

### Windows (x86 + x64)
Install MinGW via Chocolatey:
```powershell
choco install mingw --yes
cd modules/agent
mvn -DskipTests package
```

## CI Workflows

- **Branch builds** (`branch-snapshot-hash.yml`):
  - Computes a snapshot version with commit hash suffix.
  - Builds/publishes all classifiers.

- **Main builds** (`main-publish-pom-version.yml`):
  - Uses the POM version (snapshot or release).
  - Builds/publishes all classifiers.

Artifacts are published to GitHub Packages and uploaded as workflow artifacts for download.
