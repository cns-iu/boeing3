ARG SHINY_VERSION

FROM rocker/shiny-verse:${SHINY_VERSION:-latest}

# Build arguments
ARG ATHENA_ODBC_RPM
ARG SH_APP_ATHENA_AWS_ACCESS_KEY_ID
ARG SH_APP_ATHENA_AWS_REGION
ARG SH_APP_ATHENA_AWS_SECRET_ACCESS_KEY
ARG SH_APP_ATHENA_DATABASE_ID
ARG SH_APP_ATHENA_ODBC_DRIVER
ARG SH_APP_ATHENA_RESULTS_BUCKET
ARG SH_APP_BASIC_AUTH_PASSWORD
ARG SH_APP_BASIC_AUTH_USERNAME

# Install required software
RUN apt update -y \
    && apt install -y alien unixodbc curl

# Install R packages
RUN R -e "install.packages(c('DBI', 'odbc', 'RSQLite'))" \
    && R -e "install.packages(c('future', 'promises'))" \
    && R -e "install.packages(c('R6', 'magrittr', 'tools'))"

# Install Athena database driver
RUN curl -o athena-odbc.rpm \
    ${ATHENA_ODBC_RPM:-https://s3.amazonaws.com/athena-downloads/drivers/ODBC/SimbaAthenaODBC_1.0.5/Linux/simbaathena-1.0.5.1006-1.x86_64.rpm} \
    && alien -i athena-odbc.rpm \
    && rm athena-odbc.rpm \
    && odbcinst -i -d -f /opt/simba/athenaodbc/Setup/odbcinst.ini

# Copy shiny-server
COPY assets/shiny-server /srv/shiny-server/

# Build .Renviron file (to be migrated to /entrypoint.sh)
RUN { \
    echo "ATHENA_DATABASE_ID=${SH_APP_ATHENA_DATABASE_ID}"; \
    echo "ATHENA_RESULTS_BUCKET=${SH_APP_ATHENA_RESULTS_BUCKET}"; \ 
    echo "AWS_REGION=${SH_APP_ATHENA_AWS_REGION}"; \ 
    echo "AWS_ACCESS_KEY_ID=${SH_APP_ATHENA_AWS_ACCESS_KEY_ID}"; \ 
    echo "AWS_SECRET_ACCESS_KEY=${SH_APP_ATHENA_AWS_SECRET_ACCESS_KEY}"; \ 
    echo "ATHENA_ODBC_DRIVER=${SH_APP_ATHENA_ODBC_DRIVER}"; \ 
    } > /home/shiny/.Renviron \
    && chown shiny:shiny /home/shiny/.Renviron

# Copy entrypoint
COPY assets/docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
