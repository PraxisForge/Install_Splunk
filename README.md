# Install_Splunk

This repository provides a script to automate the installation of Splunk on Linux distributions.

**Downloading the Script**

Here's how to download the `Splunk_Installation_Script.sh` script to your Linux system:

```bash
curl -O -L https://raw.githubusercontent.com/PraxisForge/Install_Splunk/main/scripts/Splunk_Installation_Script.sh
```
Make the file `Splunk_Installation_Script.sh` executable so that you can run it as a script using the following command:

```bash
sudo chmod +x Splunk_Installation_Script.sh
```
You must run the following command to execute the script:

```bash
./Splunk_Installation_Script.sh
```

While executing the script, ulimit value and defrag are disabled at the beginning. Next, you will be prompted to enter the name of the Linux distribution you are using. For example:

```bash
Enter Linux Distribution Name [amazon-linux, ubuntu, red-hat, centos]:amazom-linux
```
**Note:** If you enter values other than the one mentioned in the bracket, you will be prompted again to enter a valid available option.

After this step, you will be prompted to enter a username to create a user who will have control over the installed Splunk software. For example:

```bash
Enter username:splunk
```
**Note:** Make sure to enter the new user whom you want to have control over the Splunk software.

In the next step, you will be prompted to enter a password to set it for the newly created user. For example:

```bash
Enter password for splunk:
```
After entering the password, you will need to specify the Splunk component, version, and file format you are trying to install. For example:

```bash
Enter The Splunk Component [indexer, search_head, heavy_forwarder, universal_forwarder]:universal_forwarder
Enter The Splunk universal_forwarder Version:9.2.1
Enter the file extension [tgz, rpm, deb]:tgz
```
**Note:** Enter the value of the component and file extension as mentioned inside the brackets.

For file formats such as RPM and DEB, you will be prompted to enter the file name. Please copy those file names as mentioned in the wget link. For example:

```bash
Enter The Splunk File Name (copy it from the wget link, e.g., splunk-9.2.2-d76edf6f0a15-linux-2.6-amd64.deb, splunk-9.2.2-d76edf6f0a15.x86_64.rpm):splunk-9.2.2-d76edf6f0a15.x86_64.rpm
```
**Note:** Please enter a valid file name as mentioned in the wget link while installing Splunk software using RPM and DEB file formats.

After completing this step, the next processes—such as downloading the file, successfully untarring it, and enabling boot-start for the non-root user mentioned at the beginning—will result in a ‘Successfully installed Splunk software’ message if Splunk is installed successfully.

If Splunk software is installed successfully, switch to the newly created non-root user and start the Splunk software using the following command:

**For swithching to non-root user:**

```bash
sudo su splunk
```
**For starting the splunk indexer, search_head, heavy_forwarder:**

```bash
/opt/splunk/bin/splunk start --accept-license
```
**For starting the splunk universal_forwarder:**

```bash
sudo /opt/splunkforwarder/bin/splunk start --accept-license
```
 



