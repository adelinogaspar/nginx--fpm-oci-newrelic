FROM wyveo/nginx-php-fpm

# alterar a chave do newrelic, caso necessário
#ARG CHAVE_NEWRELIC=<this is where you put your newrelic key>
#ARG NOME_APLICACAO_PHP="<Name of application to show in Newrelic dashboard>"

# diretorio de extensoes do PHP
ARG PHP_EXT_DIR=/usr/lib/php/20170718/
ARG PHP_ADICIONAL_INI=/etc/php/7.2/fpm/conf.d/

# resolve um problema de resolução de DNS
ADD docker/hosts-prd /tmp/

#sobrescreve a configuração do nginx
ADD docker/nginx/nginx-server.conf /etc/nginx/conf.d/default.conf

# instala arquivos base para as dependencias do newrelic
RUN apt-get update && \
    apt-get --allow-unauthenticated -y install wget bsdtar libaio1 \
    net-tools procps php-dev php-pear build-essential

## instala a extensão do newrelic dentro da imagem
ADD docker/newrelic/newrelic-php5-common_8.1.0.209_all.deb /tmp/
ADD docker/newrelic/newrelic-daemon_8.1.0.209_amd64.deb /tmp/
ADD docker/newrelic/newrelic-20170718.so /usr/lib/newrelic-php5/agent/x64/
ADD docker/php/newrelic.ini ${PHP_ADICIONAL_INI}
RUN dpkg -i /tmp/newrelic-php5-common_8.1.0.209_all.deb && \
    dpkg -i /tmp/newrelic-daemon_8.1.0.209_amd64.deb && \
    ln -s /usr/lib/newrelic-php5/agent/x64/newrelic-20170718.so ${PHP_EXT_DIR}newrelic.so
    # o comando abaixo configura a licença do newrelic dentro do arquivo de configuração
    #sed -i "s|REPLACE_WITH_REAL_KEY|$CHAVE_NEWRELIC|g" ${PHP_ADICIONAL_INI}newrelic.ini && \
    #sed -i "s|NOME_APLICACAO_PHP|$NOME_APLICACAO_PHP|g" ${PHP_ADICIONAL_INI}newrelic.ini && \

# instala a extensão do oracle para o php
RUN \
wget -qO- https://raw.githubusercontent.com/caffeinalab/php-fpm-oci8/master/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip | bsdtar -xvf- -C /usr/local && \
wget -qO- https://raw.githubusercontent.com/caffeinalab/php-fpm-oci8/master/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip | bsdtar -xvf-  -C /usr/local && \
wget -qO- https://raw.githubusercontent.com/caffeinalab/php-fpm-oci8/master/oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip | bsdtar -xvf- -C /usr/local && \
ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so && \
ln -s /usr/local/instantclient/lib* /usr/lib && \
ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
echo 'instantclient,/usr/local/instantclient' | pecl install oci8 && \
php -v

ADD docker/php/oracle.ini ${PHP_ADICIONAL_INI}

# cria as variáveis de ambiente do oracle
ENV LD_LIBRARY_PATH /usr/local/instantclient
ENV TNS_ADMIN       /usr/local/instantclient
ENV ORACLE_BASE     /usr/local/instantclient
ENV ORACLE_HOME     /usr/local/instantclient

# adiciona o arquivo com os bancos oracle utilizados dentro da b2w
ADD docker/oracle/tnsnames.ora /usr/local/instantclient/network/admin/
RUN ln -s /usr/local/instantclient/network/admin/tnsnames.ora /usr/local/instantclient/tnsnames.ora
