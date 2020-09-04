# start a new container at bash, expose tcp 5000, kill it when done

docker run --entrypoint /bin/bash -i -t --rm -p 5000:5000 <image>