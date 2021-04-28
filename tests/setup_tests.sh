#!/bin/bash -e

# This script starts docker and systemd (if el7)

if [ "${distribution}" = "ubuntu" ]; then
	echo -en "\n\n \e[48;5;17;97m** SCRIPTS TEST **\e[0m\n\n"
	tests/test_suite.sh
	exit $?

elif [ "${version}" -eq "6" ]; then

	# Run tests in Container
	# We use `--privileged` for cgroup compatability
    echo -en "\n\n \e[48;5;17;97mRUN DOCKER\e[0m\n\n"
    sudo docker run --privileged --rm=true \
         --volume /sys/fs/cgroup:/sys/fs/cgroup \
         --volume `pwd`:$1:rw \
         centos-${version}:ansible \
         /bin/bash -c "bash $1/tests/test_inside_docker.sh;
	 echo \$? > $1/exit_code.tmp"

elif [ "${version}" -ge "7" ]; then

    echo -en "\n\n \e[48;5;17;97mRUN DOCKER\e[0m\n\n"
    sudo docker run --privileged --detach --tty --interactive --env "container=docker" \
           --volume /sys/fs/cgroup:/sys/fs/cgroup \
           --volume `pwd`:$1:rw  \
           centos-${version}:ansible \
           /usr/sbin/init

    export DOCKER_CONTAINER_ID=$(sudo docker ps | grep centos | awk '{print $1}')
    sudo docker logs $DOCKER_CONTAINER_ID
    sudo docker exec --tty --interactive $DOCKER_CONTAINER_ID \
           /bin/bash -c "bash  $1/tests/test_inside_docker.sh;
	   test_exit=\$?
           echo -ne \"------\nEND SCRIPTS TESTS WITH STATUS \$test_exit\n\";
	   echo \$test_exit > $1/exit_code.tmp"

    echo -en "\n\n \e[48;5;17;97mDOCKER PS\e[0m\n\n"
    sudo docker ps -a
    echo -en "\n\n \e[48;5;17;97mDOCKER STOP\e[0m\n\n"
    sudo docker stop $DOCKER_CONTAINER_ID
    echo -en "\n\n \e[48;5;17;97mDOCKER REMOVE\e[0m\n\n"
    sudo docker rm -v $DOCKER_CONTAINER_ID

fi
read test_exit < exit_code.tmp
sudo rm exit_code.tmp
exit $test_exit
