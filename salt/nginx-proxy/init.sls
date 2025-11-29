# Install Nginx package to act as a Reverse Proxy / Load Balancer
nginx_pkg:
  pkg.installed:
    - name: nginx

# Configure Nginx with our custom load balancer settings
/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx-proxy/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx_pkg

# Ensure Nginx service is running and restarts if config changes
nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/nginx.conf
