# pull the azurite image and start a new container with it
# connection strings = https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite

docker run -p 10000:10000 -p 10001:10001 mcr.microsoft.com/azure-storage/azurite
