# Starting this App the Ruby on Racetracks Way

Under the Ruby on Racetracks system, you can be ready to roll in MINUTES instead of hours.  Because it uses Docker instead of Vagrant, you never have to wait for a Vagrant box to boot up.  Scripts are provided to automate the process of setting up this project.

## Prerequisites
* Install Docker.  More details on how to do this are in the [Different Docker Tutorial](http://www.differentdockertutorial.com/).
* If you are using a Mac or Windows system, you need a Linux virtual machine.  More details on how to install a Linux virtual machine are in the [VirtualBox Tutorial](http://www.virtualboxtutorial.com/).

## Starting the Docker Container
* Enter the following commands:
```
cd
mkdir jhsu802701
cd jhsu802701
git clone https://gitlab.com/jhsu802701/docker-debian-stretch.git
cd docker-debian-stretch
sh rails-sessionizer.sh # Pick a port number offset.
cd rails-sessionizer
sh download_new_image.sh
```
* It will take a few minutes for the Docker image to be downloaded.
* Please note that if you used a non-zero port offset, the port number in the Docker image corresponds to a different port number in the host system.  The port assignments are in the ports.txt file in the shared directory.  If you entered "4", port number 3000 in Docker corresponds to port number 3004 in the host system, port number 1080 in Docker corresponds to port 1084 in the host system, and port number 5432 in Docker corresponds to port 15436 in the host system.
* After the Docker image has been downloaded, you will automatically be logged into the Docker container.  By default, your Docker terminal will be in the shared directory.

## Setup
* From the shared directory in the Docker container, enter the following command to download this app:
```
git clone https://github.com/minnestar/sessionizer.git
```
* Enter the command "tmux".  This starts up tmux.  You are in Window 0.
* Enter the following commands:
```
cd sessionizer
sh credentials.sh # Enter your Git name and email address when prompted.
```
* Press Ctrl-b and then Ctrl-c to start a second tmux window.  You are in Window 1.
* 
* Enter the following commands:
```
cd sessionizer/src
sh build_fast.sh; sh server.sh
```
* The build_fast.sh script automatically sets up the project for you.  This will take a few minutes.
* The server.sh script runs the local Rails server so that you can view the app in your browser.
* After the setup process is finished and after the Rails server is up and running, you can view your app.  If your Docker port offset is 0, the URL is http://localhost:3000.  If your Docker port offset is different, the port number to use in your browser is also different.  If your port number is "4", the URL is http://localhost:3000.  If you forget what your port number assignments are, they are in the ports.txt file in the shared directory.
