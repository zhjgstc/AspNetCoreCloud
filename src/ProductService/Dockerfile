FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
WORKDIR /app
COPY bin/Debug/netcoreapp3.0/linux-x64/* ./
ENTRYPOINT ["dotnet", "ProductService.dll"]