#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
ENV ASPNETCORE_URLS=https://+:443;http://+:80
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Invoice/Invoice.API/Invoice.API.csproj", "Invoice/Invoice.API/"]
COPY ["Common/Lib01/Lib01.csproj", "Common/Lib01/"]
RUN dotnet restore "Invoice/Invoice.API/Invoice.API.csproj" -r linux-x64
COPY . .
WORKDIR "/src/Invoice/Invoice.API"

FROM build AS publish
RUN dotnet publish "Invoice.API.csproj" -c Release -p:IsDocker=true -p:buildOS=linux --no-restore -r linux-x64 --self-contained false -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Invoice.API.dll"]