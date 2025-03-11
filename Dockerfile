FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.16 AS builder


ENV ARTIFACT_NAME=shikhar-limit-manager-data-migration-service-0.0.1-SNAPSHOT.jar
ENV APP_DIR=/usr/app/hdfcbank/shikhar-limit-manager-data-migration-service

ENV GCP_PROFILER_AGENT=https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz

USER root

RUN microdnf install -y tar
RUN microdnf install -y wget
RUN microdnf install -y unzip
RUN microdnf install -y gzip

WORKDIR ${APP_DIR}

COPY ./build/libs/$ARTIFACT_NAME ${APP_DIR}/build/libs/

RUN java -Djarmode=layertools -jar ${APP_DIR}/build/libs/$ARTIFACT_NAME extract

# Create a directory for the Profiler. Add and unzip the agent in the directory.
RUN mkdir -p /opt/cprof
RUN wget -q -O- $GCP_PROFILER_AGENT | tar xzv -C /opt/cprof

FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.16

ENV APP_DIR=/usr/app/hdfcbank/il-data-migration-services

WORKDIR ${APP_DIR}

USER root
#######################
RUN groupadd -g 10001 runner
RUN useradd --uid 10001 -g 10001 runner
#######################

RUN chown -R 10001 ${APP_DIR} && chmod -R 777 ${APP_DIR}

USER 10001

COPY --from=builder /opt/cprof /opt/cprof
COPY --from=builder ${APP_DIR}/dependencies/ ./
COPY --from=builder ${APP_DIR}/spring-boot-loader/ ./
COPY --from=builder ${APP_DIR}/snapshot-dependencies/ ./
COPY --from=builder ${APP_DIR}/application/ ./



ENTRYPOINT ["java", \
    "org.springframework.boot.loader.launch.JarLauncher"]