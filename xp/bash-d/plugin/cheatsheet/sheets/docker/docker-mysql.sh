
# docker run

docker run --name myxp -e MYSQL_ROOT_PASSWORD=123qwe -d mysql:5.7.13
# docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag

# docker run:
# --rm              # Automatically remove the container when it exits
# --link=[]         # Add link to another container
# -e x=y            # set up env
# -i                # interactive
# -t                # allocate tty

# connect to it from within docker
docker run -it --link myxp:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'


# get ip of mysql in docker
docker run -it --link myxp:mysql --rm mysql sh -c 'exec echo "$MYSQL_PORT_3306_TCP_ADDR"'
