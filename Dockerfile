FROM microsoft/aspnetcore-build:2.0 AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

## copy everything else and build
COPY . ./
RUN dotnet publish -f netcoreapp2.0 -c Release -r rhel.7-x64 --self-contained false /p:PublishWithAspNetCoreTargetManifest=false -o out

# build runtime image
FROM microsoft/aspnetcore-build:2.0

# Add default user
RUN mkdir -p /app && \
    useradd -u 1001 -r -g 0 -d /app -s /sbin/nologin \
      -c "Default Application User" default

COPY --from=build-env /app/out /app   
RUN chown -R 1001:0 /app

WORKDIR /app
USER 1001
EXPOSE 5000
#ENTRYPOINT ["dotnet", "HelloWorld.dll"]
