FROM mcr.microsoft.com/dotnet/core/aspnet:2.1
WORKDIR /app
COPY bin/Release/netcoreapp2.1/publish/* ./
ENTRYPOINT ["dotnet", "ApiGateServer.dll"]
