# scanFoolery

This tool will dump password authentication attempts to the SSH daemon.

Every SSHD child process will get attached to and at the completetion of the process, the attempted passwords and connection logs will be dumped to the script.

This is handy if you are on a pentest and the client scans computers in their networks and attempts to authenticate with Domain Admin credentials. Looking at you Landsweeper.

# Prerequisites
sudo apt install strace

# Usage

```

┌──(root㉿kali)-[/mnt/hgfs/work/scripting/scanFoolery/scanFoolery]
└─# ./checkmate.sh 
Found Pid: 1076220. Attaching...
May 18 12:43:55 kali sshd[1076220]: Invalid user frank from 172.25.25.131 port 56943
May 18 12:44:03 kali sshd[1076220]: Failed password for invalid user frank from 172.25.25.131 port 56943 ssh2
May 18 12:44:06 kali sshd[1076220]: Failed password for invalid user frank from 172.25.25.131 port 56943 ssh2
May 18 12:44:11 kali sshd[1076220]: Failed password for invalid user frank from 172.25.25.131 port 56943 ssh2
May 18 12:44:12 kali sshd[1076220]: Connection reset by invalid user frank 172.25.25.131 port 56943 [preauth]
Password Attempt 1: "password1!"
Password Attempt 2: ""
Password Attempt 3: "spring2021!"
----------------------------------------------------
Found Pid: 1082034. Attaching...
May 18 12:44:26 kali sshd[1082034]: Failed password for spicy from 172.25.25.131 port 56945 ssh2
May 18 12:44:27 kali sshd[1082034]: Connection reset by authenticating user spicy 172.25.25.131 port 56945 [preauth]
Password Attempt 1: "thegame"
----------------------------------------------------

```

#To install as a service
```
┌──(root㉿kali)-[/mnt/hgfs/work/scripting/scanFoolery/scanFoolery]
└─# ./persist.sh 
Created symlink /etc/systemd/system/multi-user.target.wants/ssh-logging.service → /etc/systemd/system/ssh-logging.service.
```

#Log output
```
┌──(root㉿kali)-[~]
└─# tail -f ssh_pass.log 
May 18 12:44:12 kali sshd[1076220]: Connection reset by invalid user frank 172.25.25.131 port 56943 [preauth]
Password Attempt 1: "password1!"
Password Attempt 2: ""
Password Attempt 3: "spring2021!"
----------------------------------------------------
May 18 12:44:26 kali sshd[1082034]: Failed password for spicy from 172.25.25.131 port 56945 ssh2
May 18 12:44:27 kali sshd[1082034]: Connection reset by authenticating user spicy 172.25.25.131 port 56945 [preauth]
Password Attempt 1: "thegame"
----------------------------------------------------
```
