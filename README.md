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
   curl -O https://raw.githubusercontent.com/administrati0n/http-master/main/mac/AS-http-server-installer.sh && chmod +x AS-http-server-installer.sh && ./AS-http-server-installer.sh
```

## Possible errors when installing/running the script (Mac)

1. Lack of Homebrew:
In console: brew: command not found
Solution: Install Homebrew following the instructions on the [official website](https://brew.sh/index) or
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
### 3. Insufficient rights:
Console: Error: EACCES: permission denied or similar access denied messages.
Solution: Run the command with "sudo" or change the permissions to the desired directory.
### 4. Wrong project path:
In console: Directory not found.
Solution: Check and specify the correct path to the project.
### 5. Invalid user selection:
In console: Wrong choice!.
Solution: Follow the instructions and select one of the options.
### 6. Lack of necessary utilities:
In the console: For example, sed: command not found or ln: command not found.
Solution: Install the missing utilities or replace them with analogues.
### 7. Disk space issues:
In console: No space left on device or similar messages.
Solution: Free up disk space by deleting unnecessary files or moving them to another medium.
### 8. Version or dependency conflicts:
In console: Error messages from npm or node indicating incompatibilities or conflicts.
Solution: Update or rollback packages. If necessary, use the nvm utility to manage Node.js versions.
### 9. Errors in external resources:
In console: curl: (22) The requested URL returned error: 404 Not Found.
Solution: Check if the URL is available and correct. If the resource has been moved, find a new URL and update the script.

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
   curl -O [https://raw.githubusercontent.com/administrati0n/http-master/main/linux/AS-http-server-installer.sh && chmod +x AS-http-server-installer.sh && ./AS-http-server-installer.sh
```
## Possible errors when installing/running the script (Linux)

If you encounter any issues while using the installation script, please follow the guide below for the most common errors and their solutions.

### 1. curl not found!
Symptoms : The script terminates with the message that curl isn't found on your system.

Solution: The script tries to automatically install curl using the available package manager. If you see this error, it means the script couldn't find a recognized package manager. You'll need to manually install curl for your distribution.

### 2. Node.js not found!
Symptoms: The script terminates with a message saying Node.js is not installed.

Solution: Similar to the curl issue, if you see this error, it means that your package manager isn't recognized by the script. Install Node.js manually for your distribution.

### 3. npm not found!
Symptoms: Script complains that npm is missing even after Node.js installation.

Solution: Some Linux distributions separate Node.js and npm into different packages. Make sure you install both. The script attempts to handle this, but in some cases, you might need to install npm separately.

### 4. http-server not found!
Symptoms: Script indicates that http-server isn't installed.

Solution: The script should automatically install http-server via npm. If this error persists, try running npm install -g http-server manually in the terminal.

### 5. Directory not found
Symptoms: The script indicates that the specified project directory doesn't exist.

Solution: Ensure you've provided the correct path to your project. If using the default path, verify that the directory exists on your system.
