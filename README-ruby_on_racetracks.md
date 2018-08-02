# Ruby on Racetracks

Under the Ruby on Racetracks system, you can be ready to roll in MINUTES instead of hours.  Because it uses Docker instead of Vagrant, you never have to wait for a Vagrant box to boot up.  Scripts are provided to automate the process of setting up this project.

## Prerequisites
* If you are using a Mac or Windows system, you need a Linux virtual machine.  More details on how to install a Linux virtual machine are in the [VirtualBox Tutorial](http://www.virtualboxtutorial.com/).
* Install Docker.  More details on how to do this are in the [Different Docker Tutorial](http://www.differentdockertutorial.com/).  Please go through each of the chapters in the first 3 units to familiarize yourself with the Ruby on Racetracks way of using Docker.  Do NOT be intimidated by the large number of chapters, because each chapter is short.

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
* From the shared directory in the Docker container, "git clone" this repository.
* Enter the command "tmux".  This starts up tmux.  You are in Window 0.
* Enter the following commands:
```
cd sessionizer
sh credentials.sh # Enter your Git name and email address when prompted.
```
* Press Ctrl-b and then Ctrl-c to start a second tmux window.  You are in Window 1.  Press Ctrl-p to go to the previous tmux window.  Press Ctrl-n to go to the next tmux window.
* 
* Enter the following commands:
```
cd sessionizer/src
sh build_fast.sh; sh server.sh
```
* The build_fast.sh script automatically sets up the project for you.  This will take a few minutes.
* The server.sh script runs the local Rails server so that you can view the app in your browser.
* After the setup process is finished and after the Rails server is up and running, you can view your app.  If your Docker port offset is 0, the URL is http://localhost:3000.  If your Docker port offset is different, the port number to use in your browser is also different.  If your port number is "4", the URL is http://localhost:3000.  If you forget what your port number assignments are, they are in the ports.txt file in the shared directory.
* To view the previous page in the a window, press Ctrl-b and then the page up button (or Fn/up arrow combination on a Mac).  To view the next page in a tmux window, press press the page down button (or the Fn/down arrow combination on a Mac).  To exit the page up/page down mode, press Ctrl-C.
* To resume the Docker container in the same condition in which you left it, enter the command "sh resume.sh".
* To reset the Docker container to the original conditions stored in the Docker image, enter the command "sh reset.sh".  You'll need to run the credentials.sh script to provide your Git name and email address, and you'll need to to run the build_fast.sh script to set up the project again.

