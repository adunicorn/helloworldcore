# Compile solution
FROM microsoft/aspnetcore-build:2.0 AS build-env

#USER 1001
# copy csproj and restore as distinct layers
RUN mkdir -p /app
COPY *.csproj /app
WORKDIR /app
RUN dotnet restore

## copy everything else and build
COPY . ./
RUN dotnet publish -f netcoreapp2.0 -c Release -r centos-x64 --self-contained true /p:PublishWithAspNetCoreTargetManifest=false -o out



# Build runtime image
FROM microsoft/aspnetcore-build:2.0
#FROM healthforge/s2i-dotnetcore11
#FROM centos

# Add default user
RUN mkdir -p /app
RUN useradd -u 1001 -r -g 0 -d /app -s /sbin/nologin \
      -c "Default Application User" default

COPY --from=build-env /app/out /app
RUN chown -R 1001:0 /app

WORKDIR /app
USER 1001
EXPOSE 5000
ENTRYPOINT ["dotnet", "HelloWorld.dll"]
