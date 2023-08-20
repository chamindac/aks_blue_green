#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine3.17-amd64 AS base
WORKDIR /app
ENV ASPNETCORE_URLS=https://+:443;http://+:80
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine3.17 AS build
WORKDIR /src
COPY ["Payment/Payment.API/Payment.API.csproj", "Payment/Payment.API/"]
COPY ["Common/Lib01/Lib01.csproj", "Common/Lib01/"]
RUN dotnet restore "Payment/Payment.API/Payment.API.csproj" -r linux-musl-x64
COPY . .
WORKDIR "/src/Payment/Payment.API"

FROM build AS publish
RUN dotnet publish "Payment.API.csproj" -c Release -p:IsDocker=true -p:buildOS=linux --no-restore -r linux-musl-x64 --self-contained false -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Payment.API.dll"]