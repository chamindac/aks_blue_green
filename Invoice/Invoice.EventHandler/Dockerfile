#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Invoice/Invoice.EventHandler/Invoice.EventHandler.csproj", "Invoice/Invoice.EventHandler/"]
COPY ["Common/Lib01/Lib01.csproj", "Common/Lib01/"]
RUN dotnet restore "Invoice/Invoice.EventHandler/Invoice.EventHandler.csproj" -r win-x64
COPY . .
WORKDIR "/src/Invoice/Invoice.EventHandler"

FROM build AS publish
RUN dotnet publish "Invoice.EventHandler.csproj" -c Release -p:IsDocker=true -r win-x64 --self-contained false --no-restore -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Invoice.EventHandler.dll"]