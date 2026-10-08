FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY bin/Release/net10.0/linux-x64/publish/ ./
ENTRYPOINT ["dotnet", "ProductService.dll"]
