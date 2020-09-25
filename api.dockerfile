FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
# adding mysql client required by entrypoint script
RUN apt-get update && apt-get install -y default-mysql-client-core
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["src/Backend/Jp.Api.Management/Jp.Api.Management.csproj", "Backend/Jp.Api.Management/"]
RUN dotnet restore "Backend/Jp.Api.Management/Jp.Api.Management.csproj"
COPY src/ .
WORKDIR "/src/Backend/Jp.Api.Management"
RUN dotnet build "Jp.Api.Management.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Jp.Api.Management.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY ./docker_scripts/custom_dotnet_entrypoint.sh /usr/local/bin/custom_dotnet_entrypoint.sh
# adding sso certificate
COPY ./certs/file.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
ENTRYPOINT [ "custom_dotnet_entrypoint.sh", "Jp.Api.Management.dll" ]