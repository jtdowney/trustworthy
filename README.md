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
      salt: 400$8$28$4c7fc59a31a9f38a
      encrypted_point: !binary |-
        CWcT++kRSAw/0IAVRX6KKAfwbyWBX7ZUh4dZNxL8An413CvRL2tUhWlwsKVl
        ZKyzmc6VjpKqS4ZpGoPPUCu6xrIo5LkLwXVIpDsBx7SCoK72uEsxd9x0GW5i
        9Mf8r40KE3gUCudntBXlxduDrqWZgW1uFFCg+U3ACt28GzGftOGjYW6PCAZO
        N35aHYpGHWhddWeFvbaXNrAPtLSiVWSNW35RU2qo+HS+uSYGO65r9viCXC8f
        3yLZsPjtouDRyMEv5xOPVZKnvsf3Ju3EBH7Abyw/zezS2LvzrtmxHTN5yF92
        xphq0imIR52Yj2/k6pdRz/X/8ZsdS+HEifvvRBM+oVKQ2PQh4MIFPJuE0CWA
        iPnpqdvjYt0M7BsodX2K897A
    another-user:
      salt: 400$8$28$9dceab0f3414ab23
      encrypted_point: !binary |-
        7B1hXxwwXDU0vTLAPj6U9+WWT3o4i1r7prPOamgStDjvv7f0gZp0D3T56gZk
        b+2Q4zwyhTM4p6DS0xdG3lfhnkQEYQ6tROnLbI1O7IvuOmFVsDNLej9ps7hJ
        e1kdFiLaF3efRYtHs2GYdEVrRWWDFgfLDVFVoFbqDruRX1ltTVuaJvS9f7Qb
        FPI8a2gJ0sl+1B5eBJeR1Chbdn3rHxK7SHq+J/SAJV7xKmkQa6B8g2V1D3xE
        oB45Gmgm9o1s1/van72ckT91HPh55B8tHnjeZZwdHEp7Z8lyLrDxhbpQm7ql
        ESpbM8BvdFCmzns5ZSku5Jgc78MwQ5YO1y/QXY+s9so7SDLI9yF18q4no81f
        sNpbmdY+NolXChlDRZcZ9qJk

## Reference

* RSA Labs - [http://www.rsa.com/rsalabs/node.asp?id=2259](http://www.rsa.com/rsalabs/node.asp?id=2259)
* ssss - [http://point-at-infinity.org/ssss/](http://point-at-infinity.org/ssss/)
* Secret sharing on Wikipedia - [http://en.wikipedia.org/wiki/Secret_sharing](http://en.wikipedia.org/wiki/Secret_sharing)

## License

Trustworthy is released under the [MIT license](http://www.opensource.org/licenses/MIT).
