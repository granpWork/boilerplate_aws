# Build stage
FROM eclipse-temurin:21-jdk-jammy as builder

WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw .
COPY pom.xml .
COPY src/ src

# Ensure mvnw script has execute permissions
RUN chmod +x mvnw

# Build the application and skip tests
RUN ./mvnw clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Create non-root user and set permissions
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/boilerplate_aws-*.jar /app/app.jar

# Health check (assuming Spring Boot Actuator is present)
# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
#     CMD curl -f http://localhost:8080/actuator/health || exit 1

# Configure JVM for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:+ShowCodeDetailsInExceptionMessages"

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]