#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy everything
COPY ["dot-net-core-app.csproj", "."]
# Restore as distinct layers
RUN dotnet restore "./dot-net-core-app.csproj"
COPY . .
WORKDIR "/src/."

# Build and publish a release
RUN dotnet build "dot-net-core-app.csproj" -c Release -o /app/build
FROM build AS publish
RUN dotnet publish "dot-net-core-app.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Build runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dot-net-core-app.dll"]