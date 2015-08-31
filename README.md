docker-drupal-contextio
==============

Docker image for Drupal 7.x with Context.IO.

Based on: https://github.com/ricardoamaro/docker-drupal

### How to use:

```sh
git clone https://github.com/janmashat/docker-drupal-dockerio.git
cd docker-drupal-dockerio

docker build -t drupal-dockerio .
docker run -it --name drupal-dockerio -p 80:80 -p 9001:9001 drupal-dockerio
```

If you would like to store the docroot on the host:

```sh
docker run -it --name drupal-dockerio -p 80:80 -p 9001:9001 -v path_on_the_host:/var/www drupal-dockerio
```
