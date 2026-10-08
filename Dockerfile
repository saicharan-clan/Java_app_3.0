FROM eclipse-temurin:8-jre-alpine
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
CMD ["java", "-jar", "/app.jar"]
