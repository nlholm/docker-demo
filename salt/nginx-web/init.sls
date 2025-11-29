# Ensure that docker module is installed prior to containers 
include:
  - docker

# Create the project directory for the demo
/home/vagrant/nginx-demo:
  file.directory:
    - user: vagrant
    - group: vagrant
    - mode: 755

# Copy the docker-compose configuration file
/home/vagrant/nginx-demo/docker-compose.yml:
  file.managed:
    - source: salt://nginx-web/docker-compose.yml
    - user: vagrant
    - group: vagrant
    - mode: 644
    - require:
      - file: /home/vagrant/nginx-demo

# Copy site1 content (Blue theme) to the minion
/home/vagrant/nginx-demo/site1:
  file.recurse:
    - source: salt://nginx-web/site1
    - user: vagrant
    - group: vagrant
    - file_mode: 644
    - dir_mode: 755
    - require:
      - file: /home/vagrant/nginx-demo

# Copy site2 content (Pink theme) to the minion
/home/vagrant/nginx-demo/site2:
  file.recurse:
    - source: salt://nginx-web/site2
    - user: vagrant
    - group: vagrant
    - file_mode: 644
    - dir_mode: 755
    - require:
      - file: /home/vagrant/nginx-demo

# Copy site3 content (Yellow theme) to the minion
/home/vagrant/nginx-demo/site3:
  file.recurse:
    - source: salt://nginx-web/site3
    - user: vagrant
    - group: vagrant
    - file_mode: 644
    - dir_mode: 755
    - require:
      - file: /home/vagrant/nginx-demo

# Start the Docker containers using Docker Compose
nginx_web_up:
  cmd.run:
    - name: docker compose up -d --remove-orphans
    - cwd: /home/vagrant/nginx-demo
    - require:
      - file: /home/vagrant/nginx-demo/docker-compose.yml
      - file: /home/vagrant/nginx-demo/site1
      - file: /home/vagrant/nginx-demo/site2
      - file: /home/vagrant/nginx-demo/site3
      - sls: docker
    
    # - unless: "docker ps | grep -q nginx-web1 && docker ps | grep -q nginx-web2 && docker ps | grep -q nginx-web3"
