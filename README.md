# Trustworthy [![Build Status](https://secure.travis-ci.org/jtdowney/trustworthy.png?branch=master)](http://travis-ci.org/jtdowney/trustworthy)

Implements a special case (k = 2) of [Adi Shamir's](http://en.wikipedia.org/wiki/Adi_Shamir) [secret sharing algorithm](http://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing). This allows secret files to be encrypted on disk and require two secret holders to decrypt it.

## Usage

### Generate a new master key

    trustworthy init

This will create a new master key and ask for two users to be added who can decrypt the master key. The information about users and secrets is stored in trustworthy.yml. With all trustworthy commands you can also specify the configuration file to work with using `-c` or `--config`.

    trustworthy init -c myconfig.yml

### Add an additional user key to the master key

    trustworthy add-key

The master key will be loaded so that a new user key can be added to the configuration.

### Encrypt a file

    trustworthy encrypt -i foo.txt -o foo.txt.tw

The master key will be loaded and then used to encrypt the file specified.

### Decrypt a file

    trustworthy decrypt -i foo.txt.tw -o foo.txt

Decrypting works similar to encrypting, first the master key will be loaded and then used to decrypt the file.

## Configuration format

The configuration uses ruby's `YAML::Store` to provide a simple transactional data store. The salt is used in combination with the user password to derive a key using [scrypt](http://www.tarsnap.com/scrypt.html). That derived key encrypts the point for Shamir's algorithm.

    ---
    a-user:
      salt: 400$8$23$38f426136db22836
      encrypted_point: dzVzPvuzKsTJ7coFLki8tQ==--vGto+f9sQhRuPb+47rUI4oSZ7gaPGKiQtBIwB//wTcvuJOm9gyrLrjH74RKKJlkScBvYuMfnhQyn9T1bIw9obsBs4YsF8VxCsDPG26Ci82n9qOENod2pP4xVzmC4VWCnbi7Y4jS+Rgsq6xp3L2zG6Ci0GWO1bSQO8hFzaMpBiCirqMAGHf0m6Yzqu6h5NFtygcyNyxAY8YxX1oxa6Bj5UwefDKplVGTI0ZbQn9vtdwKFuwXZsv11g5+zLvvq54Z2UZ/AZu/scnhXopL5IZkiclTtX8LUi9Dob3Xpqtf6WXymudvVMG0JaxkUqqRCyWtLSFE3sNdwv+877cS8PglTIKxXIZTIh7FzdEgkLSStGnw=
    another-user:
      salt: 400$8$23$df3b3153ee94da81
      encrypted_point: Shx/GRuOYz+Ts/5f5z1yDw==--1ulNtnX6Zi3z0t12TiCItE5H5dhZZONKcgt6yq1g2prJWd1q5c9ArL10BtK/9lSPoXMsyO8rURKZ3pCM4hzW043B1ksJQtyg6O71ilnSvP+4Yty8oH0SW67cGSgfkfUc0UkfcE2Osfy/YVkP/HH47qTLNTg406uJ2uWjb6OkW8sjD+mq3hp8tehyy20tEBhqyM0UOSCpvhb+EgFfYFDeG+8Gj+r4lfcdqJJvzcy5U17tpYknQm/WbnmIkvgZRFGH/NIthJdPnK43SsdPbVcSHdkw71urJ3pBmgCmyTFcdmpiSl/t1rG09f2KT63YDF+4YUSn1fuIFZXbrLez59svHbKnQ8YHvt9pCXiQHelk8Sk=

## Reference

* RSA Labs - [http://www.rsa.com/rsalabs/node.asp?id=2259](http://www.rsa.com/rsalabs/node.asp?id=2259)
* ssss - [http://point-at-infinity.org/ssss/](http://point-at-infinity.org/ssss/)
* Secret sharing on Wikipedia - [http://en.wikipedia.org/wiki/Secret_sharing](http://en.wikipedia.org/wiki/Secret_sharing)
