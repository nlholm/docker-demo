base:
  '*':
    - docker
    - nginx-web
    - nginx-proxy

# ----------------------------------------------------------------------
# File: top.sls
# Description: The entry point for SaltStack configuration.
#   This file maps state modules to specific minions.
#   Running 'state.apply' triggers this Highstate.
# ----------------------------------------------------------------------

# base:
# Target: All minions ('*') In this demo environment, this targets 'minion1'.
# '*':
# 1. INFRASTRUCTURE LAYER
# - docker. Installs Docker Engine dependencies and service.
# 2. APPLICATION LAYER (Backend)
# - nginx-web. Sets up the 3 Nginx containers (Blue, Pink, Yellow) via Docker Compose.
# 3. ROUTING LAYER (Frontend)
# - nginx-proxy. Installs and configures the Nginx Reverse Proxy / Load Balancer.