# http-master

http-server launch wizard and convenient server management and configuration.

# Shell Version Installer (Mac OS)
Tested on Ventura.
### Option 1: Manual installation

1. Go to [releases page](https://github.com/administrati0n/http-master/releases) your GitHub repository.
2. Download the latest release, usually it will be named as `AS-http-server-installer.sh` or similar.
3. Open a terminal and navigate to the directory where you downloaded the setup file.
4. Make the file executable:
   
   ```bash
   chmod +x AS-http-server-installer.sh
   ```
5. Start instalation File
6. 
   ```bash
   ./AS-http-server-installer.sh

### Option 2: Install with one command

You can install AS HTTP Server using the following 1 command:

   ```bash
   curl -O https://raw.githubusercontent.com/administrati0n/http-master/main/AS-http-server-installer.sh && chmod +x AS-http-server-installer.sh && ./AS-http-server-installer.sh
```

## Possible errors when installing/running the script (Mac)

1. Lack of Homebrew:
In console: brew: command not found
Solution: Install Homebrew following the instructions on the [official website](https://brew.sh/index) or
   ```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```.
3. Insufficient rights:
Console: Error: EACCES: permission denied or similar access denied messages.
Solution: Run the command with "sudo" or change the permissions to the desired directory.



# Shell Version Installer (Linux)
Tested on Ubuntu, Fedora, Debian, Kali.
### Option 1: Manual installation

1. Go to [releases page](https://github.com/administrati0n/http-master/releases) your GitHub repository.
2. Download the latest release, usually it will be named as `AS-http-server-installer.sh` or similar.
3. Open a terminal and navigate to the directory where you downloaded the setup file.
4. Make the file executable:
   
   ```bash
   chmod +x AS-http-server-installer.sh
5. Start instalation File
6. 
   ```bash
   ./AS-http-server-installer.sh

### Option 2: Install with one command

You can install AS HTTP Server using the following 1 command:

   ```bash
   curl -O https://raw.githubusercontent.com/administrati0n/http-master/main/linux/AS-http-server-installer.sh && chmod +x AS-http-server-installer.sh && ./AS-http-server-installer.sh
```
