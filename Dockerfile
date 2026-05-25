FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY target/application.jar ./application.jar

EXPOSE 11002

ENTRYPOINT ["java", "-jar", "application.jar"]
