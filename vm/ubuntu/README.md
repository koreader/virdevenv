
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
* tell `vagrant` to use virtualbox instead of libvirt (needed under Fedora): `export VAGRANT_DEFAULT_PROVIDER=virtualbox`
* run `vagrant up` to bootstrap the vm (going to take a while)
* run `vagrant ssh` and compile koreader inside the vm: `cd koreader`, `./kodev build` (this will take a while)
* run koreader with `./kodev run`

macOS Notes
-----
1. Install XQuartz
2. Restart
3. Run XQuartz
4. XQuartz -> Applications -> Terminal
5. Inside the terminal run `ssh vagrant@localhost -p 2222 -Y`  

The last step is necessary for setting up X11 forwarding to XQuartz

Now you can continue to run `./kodev run` and it will open on macOS rather than giving you ncurses hell :)

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

Windows Notes
-----
You might have to run vagrant inside of an admin console for symlinks to work.
