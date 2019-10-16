FROM rocker/shiny-verse

RUN R -e "install.packages(c('DBI', 'odbc', 'RSQLite'))" \
    && R -e "install.packages(c('future', 'promises'))" \
    && R -e "install.packages(c('R6', 'magrittr', 'tools', 'DT'))"

RUN apt install -y alien unixodbc curl
RUN curl -o athena-odbc.rpm \
    https://s3.amazonaws.com/athena-downloads/drivers/ODBC/SimbaAthenaODBC_1.0.5/Linux/simbaathena-1.0.5.1006-1.x86_64.rpm \
    && alien -i athena-odbc.rpm \
    && rm athena-odbc.rpm \
    && odbcinst -i -d -f /opt/simba/athenaodbc/Setup/odbcinst.ini

# ODBC Driver is here: /opt/simba/athenaodbc/lib/64/libathenaodbc_sb64.so
# Driver name? Simba Athena ODBC Driver 64-bit
