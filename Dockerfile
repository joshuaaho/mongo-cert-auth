# Use the official MongoDB image as a base
FROM mongo:latest

# Create directories for certificates
WORKDIR /CA

RUN openssl req -x509 -newkey rsa:4096 -keyout CA_key.pem -out CA_cert.pem -sha256 -days 3650 -noenc -subj "/C=bb/ST=bb/L=bb/O=bb/OU=bb/CN=bb"

WORKDIR /client

RUN openssl req -new -newkey rsa:4096 -noenc -keyout client_key.pem -out client_req.pem -addext keyUsage=digitalSignature -addext extendedKeyUsage=clientAuth -subj "/C=cc/ST=cc/L=cc/O=cc/OU=cc/CN=cc"

RUN openssl x509 -req -copy_extensions copyall -in client_req.pem -days 365 -CA /CA/CA_cert.pem -CAkey /CA/CA_key.pem -CAcreateserial -out client_cert.pem

RUN cat client_key.pem client_cert.pem > client_cert_key.pem

WORKDIR /mongo_server

RUN openssl req -new -newkey rsa:4096 -noenc -keyout server_key.pem -out server_req.pem -addext subjectAltName=IP:127.0.0.1 -subj "/C=dd/ST=dd/L=dd/O=dd/OU=dd/CN=dd"

RUN openssl x509 -req -copy_extensions copyall -in server_req.pem -days 365 -CA /CA/CA_cert.pem -CAkey /CA/CA_key.pem -CAcreateserial -out server_cert.pem

RUN cat server_key.pem server_cert.pem > server_cert_key.pem

CMD ["sh"]