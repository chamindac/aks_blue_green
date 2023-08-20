#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Order/Order.EventHandler/Order.EventHandler.csproj", "Order/Order.EventHandler/"]
COPY ["Common/Lib01/Lib01.csproj", "Common/Lib01/"]
RUN dotnet restore "Order/Order.EventHandler/Order.EventHandler.csproj" -r linux-x64
COPY . .
WORKDIR "/src/Order/Order.EventHandler"

FROM build AS publish
RUN dotnet publish "Order.EventHandler.csproj" -c Release -p:IsDocker=true -p:buildOS=linux --no-restore -r linux-x64 --self-contained false -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Order.EventHandler.dll"]