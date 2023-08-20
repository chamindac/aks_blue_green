#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
ENV ASPNETCORE_URLS=https://+:443;http://+:80
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Order/Order.API/Order.API.csproj", "Order/Order.API/"]
COPY ["Common/Lib01/Lib01.csproj", "Common/Lib01/"]
RUN dotnet restore "Order/Order.API/Order.API.csproj" -r win-x64
COPY . .
WORKDIR "/src/Order/Order.API"

FROM build AS publish
RUN dotnet publish "Order.API.csproj" -c Release -p:IsDocker=true -r win-x64 --self-contained false --no-restore -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Order.API.dll"]