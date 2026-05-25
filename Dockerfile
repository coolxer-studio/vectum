FROM openjdk:17-jdk

WORKDIR /app

COPY target/application.jar ./application.jar
COPY src/main/resources/application.properties ./application.properties
COPY vector ./vector

EXPOSE 11002

ENTRYPOINT ["java", "-jar", "application.jar", "--spring.config.location=file:./application.properties"]
