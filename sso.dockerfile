FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
RUN apt-get update && apt-get install -y default-mysql-client-core
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["src/Frontend/Jp.UI.SSO/Jp.UI.SSO.csproj", "Frontend/Jp.UI.SSO/"]
RUN dotnet restore "Frontend/Jp.UI.SSO/Jp.UI.SSO.csproj"
COPY src/ .
WORKDIR "/src/Frontend/Jp.UI.SSO"
RUN dotnet build "Jp.UI.SSO.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Jp.UI.SSO.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY ./docker_scripts/custom_dotnet_entrypoint.sh /usr/local/bin/custom_dotnet_entrypoint.sh
ENTRYPOINT [ "custom_dotnet_entrypoint.sh", "Jp.UI.SSO.dll" ]