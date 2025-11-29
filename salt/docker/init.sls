# Install prerequisites required to add external repositories
docker_dependencies:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - gnupg

# Create directory for apt keyrings
/etc/apt/keyrings:
  file.directory:
    - mode: 0755

# Download Docker's official GPG key
docker_gpg_key:
  cmd.run:
    - name: |
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
        chmod a+r /etc/apt/keyrings/docker.asc
    - unless: test -f /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
/etc/apt/sources.list.d/docker.sources:
  file.managed:
    - contents: |
        Types: deb
        URIs: https://download.docker.com/linux/debian
        Suites: {{ grains['oscodename'] }}
        Components: stable
        Signed-By: /etc/apt/keyrings/docker.asc

# Update package index if the repository file changes
docker_apt_update:
  cmd.run:
    - name: sudo apt-get update
    - onchanges:
      - file: /etc/apt/sources.list.d/docker.sources

# Install Docker Engine, CLI, Containerd, and Compose plugin
docker_packages:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    - require:
      - cmd: docker_gpg_key
      - file: /etc/apt/sources.list.d/docker.sources

# Ensure Docker service is running and enabled on boot
docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker_packages
    # Restart service if packages are updated or changed
    - watch:
      - pkg: docker_packages

# Add vagrant user to docker group
docker_group_vagrant:
  user.present:
    - name: vagrant
    - groups:
      - docker
    - remove_groups: False # Don't remove other groups
    - require:
      - pkg: docker_packages