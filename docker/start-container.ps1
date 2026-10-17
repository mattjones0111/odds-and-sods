# start a new container at bash, expose tcp 5000, kill it when done

docker run --entrypoint /bin/bash -i -t --rm -p 5000:5000 <image>

# start a new container
docker run -p 5000:5000 <image>

# postgres
docker run -d -i --name the-db -p 5432:5432 -e POSTGRES_PASSWORD="changeit" -e POSTGRES_USER="admin" postgres:latest

docker run -d --name postgres17 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD='postgres' -e POSTGRES_DB=postgres -p 6543:5432 -v postgres17_data:/var/lib/postgresql/data postgres:17-alpine

# sql
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Password123" -p 1433:1433 --name sql2022 -h sql2022 -d mcr.microsoft.com/mssql/server:2022-latest

# azurite
docker run -p 10000:10000 -p 10001:10001 -p 10002:10002 mcr.microsoft.com/azure-storage/azurite
