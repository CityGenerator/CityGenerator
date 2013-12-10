class users {

    user{'root':
        ensure=>present,
    }

  #Yes, this will give me root access to your host. you may want to change this key smartguy. 
  ssh_authorized_key{ 'jmorgan@linwider':
    ensure =>'present',
    user =>['root'],
    type=>'ssh-rsa',
    key=>'AAAAB3NzaC1yc2EAAAADAQABAAABAQDDhAD7b0+CmWtMXSECBOgsILu3TnDz1wIpU5TWTfVPxkuiFIJIXC44Nzg9LklzDmZH8OZULnBeadxDGMzb7Hno8V9YAMbpAkckFgiWAOenKcGxIEztPjobRTKAoNgo50N31kCmSXDJpJR0eNwFLDWi5V3S8XbqAFOhzhuAVbqFDqOiJvJYCH12Fz4W0TS4oN6D/mI3yPeLE0e5Nb6tZTPYYkXCx+Z8VNhFgUCfvuGdYPjX8FgAaWd/7rHI0NBynvUc+azmaW+a/G3JeUD5dYT51i5+N8AZGxpDyQlEC7Nc/0O8TJkmkz0aHp75mFd7Qbuk0sbGSONpVNP0SVnSOzyz',
  }
}
