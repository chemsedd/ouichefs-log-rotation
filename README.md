# ouichefs-log-rotation
Adds log rotation mechanisms to the Ouichefs file system  
The mechanisms are added as kernel modules to the system, two policies are supported:
- Deleting the oldest file.
- Deleting the largest file.

## Purpose
Server software such as web servers typically log every event, request and error to log files, this can rapidly eat up all available space.  
A common approach to manage log files is to have a regularly scheduled **log rotation**, typically a **cron** job that runs the **logrotate** command that renames, deletes or archives the files once they are too old or too big.  
Another approach that is easier and requires less configuration is to use a log rotation capable file system.

## Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
The project was tested only on the **linux kernel 4.19**.

### Installation
Download **ouichefs-log-rotation**
```
git clone https://github.com/0x000A/ouichefs-log-rotation.git && cd ouichefs-log-rotation
```
Download and patch **ouichefs** file system
```
git clone https://github.com/rgouicem/ouichefs.git
cp patch.txt ouichefs && cd ouichefs
patch -p1 < patch.txt
```
Build and insert **ouichefs** file system  
***NOTE**: If you want to build the module against a different kernel, run `make KERNELDIR=<path>`*
```
make
insmod ouichefs.ko
```
Build `mkfs.ouichefs` and create a **ouichefs** partition  
***NOTE**: This creates a partition of 50 MiB, you can modify the size by changing **count** value in the **dd** command*
```
cd mkfs && make
dd if=/dev/zero of=ouichefs.img bs=1M count=50
./mkfs.ouichefs ouichefs.img
```
Mount the partition  
***NOTE**: This mounts the partition to `/ouichefs`*
```
mount ouichefs.img /ouichefs
```
Build the policies  
***NOTE**: If you want to build the modules against a different kernel, run `make KERNELDIR=<path>`*
```
cd ../..
make
```
Insert a policy
```
insmod oldest.ko
```
## Running the tests
It's highly recommended to use a **ouichefs** partition only for the tests and this is what we will be doing here.  
  
Create a **ouichefs** partition for the tests.  
***NOTE**: This creates a partition of 50 MiB, you can modify the size by changing **count** value in the **dd** command*
```
cd ouichefs/mkfs
dd if=/dev/zero of=test.img bs=1M count=50
./mkfs.ouichefs test.img
```
Run the tests
```
cd ../../tests
./testAll.sh
```

## Usage
Once a policy is added, it is triggered whenever:
- a directory goes out of **inodes**.
- a directory has only **x% inodes** left, **x** can be set at module insertion:
```
insmod oldest.ko x=10
```
- by manually triggering the policy:
```
echo -n 1 > /sys/kernel/oldest
```
