
Virtual Dev Environment for Koreader
====================================


Dependencies
------------

* virtualbox4.2+
* vagrant
* git


Usage
-----

* Install dependencies, see above
* Create a directory for koreader dev, say "~/kodev": `mkdir ~/kodev`
* cd into dev directory: `cd ~/kodev`
* clone virtual dev env repo: `git clone https://github.com/koreader/virdevenv.git`
* clone koreader repo: `git clone URL_TO_YOUR_KOREADER_FORK koreader`
* clone koreader-base repo: `git clone URL_TO_YOUR_KOREADER_BASE_FORK koreader-base`
* cd into virtual env repo: `cd ./virdevenv/vm/ubuntu`
* run `vagrant up` to bootstrap the vm (going to take a while)
* run `vagrant ssh` and compile koreader inside the vm!

Following is how koreader dev dir's layout will look like:
```
├── kodev
│   ├── koreader
│   ├── koreader-base
│   ├── virdevenv
```

Your cloned repo will be mounted and synced with the repo inside vm. So you can
develop on the host machine and only use the vm to compile.

If you want to run emulator from inside vm, make sure X window system is installed on
host machine.
