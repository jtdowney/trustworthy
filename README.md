# Trustworthy [![Build Status](https://secure.travis-ci.org/jtdowney/trustworthy.png?branch=master)](http://travis-ci.org/jtdowney/trustworthy)

Implements a special case (k = 2) of [Adi Shamir's](http://en.wikipedia.org/wiki/Adi_Shamir) [secret sharing algorithm](http://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing). This allows secret files to be encrypted on disk but loaded into a process on start if two of the keys are available.

## Usage

### Generate a new master key

    trustworthy init -c trustworthy.yml

This will create a new master key and ask for two users to be added who can decrypt the master key. The information about users and secrets is stored in trustworthy.yml.

### Add an additional user to the master key

    trustworthy add-user -c trustworthy.yml

The master key will be loaded so that a new user can be added to trustworthy.yml.

### Add a secret

    trustworthy add-secret -c trustworthy.yml -e ENCRYPTION_KEY -i encryption.key -o encryption.key.tw

Secrets are the main purpose behind trustworthy. This will encrypt the file using the master key and will load it into the given environment variable when executed.

### Run a program under trustworthy

    trustworthy exec -c trustworthy.yml rails console

The master key will be loaded so all secrets can be decrypted and stored in the environment. After that the given program will be spawned and inherit the environment.

## Reference

* RSA Labs - [http://www.rsa.com/rsalabs/node.asp?id=2259](http://www.rsa.com/rsalabs/node.asp?id=2259)
* ssss - [http://point-at-infinity.org/ssss/](http://point-at-infinity.org/ssss/)
* Secret sharing on Wikipedia - [http://en.wikipedia.org/wiki/Secret_sharing](http://en.wikipedia.org/wiki/Secret_sharing)

## License

Trustworthy is released under the [MIT license](http://www.opensource.org/licenses/MIT).