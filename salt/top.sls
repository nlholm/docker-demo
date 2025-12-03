# ----------------------------------------------------------------------
# File: top.sls
# Description: The entry point for SaltStack configuration.
#   This file maps state modules to specific minions.
#   Running 'state.apply' triggers this Highstate.
# ----------------------------------------------------------------------

base:
  # Target: All minions.
  # The asterisk '*' matches any minion ID (in this demo: 'minion1').
  '*':
    
    # ------------------------------------------------------------------
    # 1. INFRASTRUCTURE LAYER
    # ------------------------------------------------------------------
    # Installs Docker Engine, dependencies, and manages the docker group.
    - docker

    # ------------------------------------------------------------------
    # 2. APPLICATION LAYER (Backend)
    # ------------------------------------------------------------------
    # Sets up the content and starts the 3 Nginx containers (Blue, Pink, Yellow) using Docker Compose.
    - nginx-web

    # ------------------------------------------------------------------
    # 3. ROUTING LAYER (Frontend)
    # ------------------------------------------------------------------
    # Installs Nginx on the host to act as a Reverse Proxy & Load Balancer.
    - nginx-proxy