# MongoDB with x.509 Certificate Authentication in Docker

This tutorial guides you through starting a MongoDB instance in Docker that uses x.509 certificate authentication.

## Steps

### 1. Build the Docker Image

Open your terminal and run the following command to build the Docker image:

```bash
docker build -t <image-name> .
```

For simplicity, both the server and client will reside in the same container. During the TLS handshake:

1. The server sends its certificate key file to the client.
2. The client verifies the server's certificate using its Certificate Authority (CA) file.

Once the TLS connection is established, the client authenticates using its own certificate key file, which the server verifies against its own CA file.

All certificates are created using OpenSSL and will be automatically provided after building the image.

### 2. Create a Volume for User Data

Create a Docker volume to store user data:

```bash
docker volume create <vol-name>
```

By default, the container will persist data in a new random volume on each startup, so we specify our own volume to keep track of our user that will be added later on.

### 3. Run the Docker Container with the Volume

Run the Docker container using the volume you created:

```bash
docker run -d --name <container-name> --mount source=<vol-name>,target=/data/db <image-name>
```

`/data/db` is the default path where MongoDB stores its data, so we link it up with our volume.

### 4. Start Another Shell in the Container

Execute a shell within the running container:

```bash
docker exec -it <container-name> sh
```

We will start the mongo server here using this shell

### 5. Start MongoDB

Inside the shell, start the MongoDB server:

```bash
mongod
```

### 6. Add a User Corresponding to the Client Certificate

Run the following command to create a user that corresponds to your client certificate:

```javascript
db.getSiblingDB("$external").runCommand({
  createUser: "CN=cc,OU=cc,O=cc,L=cc,ST=cc,C=cc",
  roles: [
    { role: "readWrite", db: "test" },
    { role: "userAdminAnyDatabase", db: "admin" },
  ],
  writeConcern: { w: "majority", wtimeout: 5000 },
});
```

### 7. Restart MongoDB with TLS Enabled

Stop the server and restart it with TLS enabled, providing the necessary certificates:

```bash
mongod --tlsMode requireTLS --tlsCertificateKeyFile /mongo_server/server_cert_key.pem --tlsCAFile /CA/CA_cert.pem
```

### 8. Authenticate Using the Certificate

Finally, use the following command to authenticate using your client certificate:

```bash
mongosh --tls --tlsCertificateKeyFile /client/client_cert_key.pem --tlsCAFile /CA/CA_cert.pem --authenticationDatabase '$external' --authenticationMechanism MONGODB-X509
```

## References

For more info references can be found below:

### Mongo

- [MongoDB x.509 Client Authentication](https://www.mongodb.com/docs/manual/tutorial/configure-x509-client-authentication/)
- [Configure TLS/SSL for mongod and mongos](https://www.mongodb.com/docs/manual/tutorial/configure-ssl/#mongod-and-mongos-certificate-key-file)

### SSL/TLS/x.509 Certificates

- [TLS/SSL (1)](https://www.youtube.com/watch?v=sEkw8ZcxtFk)
- [TLS/SSL (2)](https://www.youtube.com/watch?v=r1nJT63BFQ0&t=727s)
- [x.509 Certificates](https://www.youtube.com/watch?v=kAaIYRJoJkc)

### OpenSSL

- [OpenSSL docs](https://www.openssl.org/)

### Docker

- [Docker docs](https://docs.docker.com/)
