# Docker Demo

## *Docker & SaltStack Load Balancing Demo*

This project demonstrates an Infrastructure as Code (IaC) environment using Vagrant, SaltStack, Docker and Nginx.

It automatically and idempotently provisions a virtual infrastructure where a Salt Master configures a Minion to run a cluster of Nginx web servers behind an Nginx Load Balancer.

This project was created by [punnalathomas](https://github.com/punnalathomas) and [nlholm](https://github.com/nlholm) as group work for a configuration management systems course. A report for the creation process is available at [Docker Demo Documentation](https://github.com/nlholm/docker-demo-documentation).

![img1](./img/img1.jpeg) 

The basic idea behing load balancing: a load balancer (reverse proxy) stands before a cluster of backend web servers and distrubutes traffic to the servers.

## Architecture Overview

The setup consists of two Virtual Machines running Linux Debian Bookworm:
1.  **Master:** Runs the SaltStack Master service.
2.  **Minion:** Runs Salt Minion, Docker Engine, Nginx Reverse Proxy/Load Balancer and Ngix web servers in Containers.

### Traffic Flow Diagram
```text
[ USER (Host Machine) ]
       |
       |  Browser Request: http://localhost:8080
       |  (Forwarded by VirtualBox to Guest Port 80)
       v
[ VIRTUAL MACHINE (Minion Node) ]
       |
       |  Nginx Load Balancer (Reverse Proxy)
       |
       +--- DECIDES DESTINATION (Round Robin) ---+
       |                                         |
       v                                         v
[ DOCKER CONTAINER 1 ]                [ DOCKER CONTAINER 2 ] ...
   (Blue Site)                           (Pink Site)
```

---

## Prerequisites & System Requirements

Before running the environment, ensure you have the following software installed on your host machine:

### Software
* **Vagrant** (v2.2.x or newer)
* **Oracle VirtualBox** (v6.1 or newer) - Required Provider
* **Git** (for cloning the repository)

### Hardware
* **RAM:** Minimum 8 GB recommended on the host machine.
    * Reasoning: The environment provisions two VMs (Master: 2GB, Minion: 2GB), consuming a total of 4GB RAM.
* **CPU:** Intel/AMD x86_64 architecture.

> **Important for Mac Users (Apple Silicon / M1, M2, M3):**
> This demo relies on x86_64 architecture. It is not compatible with Apple Silicon Macs using the standard VirtualBox provider. Running this on ARM-based Macs will likely fail.

---

## Installation & Setup

### 1. Clone the Repository

Clone this repository to your local machine:
```bash
git clone https://github.com/nlholm/docker-demo.git
cd docker-demo
```

### 2. Provision the Infrastructure

Start the virtual machines. We explicitly enforce the VirtualBox provider to ensure correct resource allocation.

Windows (PowerShell/CMD) / Linux / Mac (Intel):
```Bash
vagrant up
```

*This process may take a few minutes as it downloads the OS image and runs the initial provisioning scripts.*

### 3. Apply Configuration (SaltStack)

Once the VMs are running, you need to verify the connection and apply the state configurations.

**Step 1**: SSH into the Mater node
```Bash
vagrant ssh master
```

**Step 2**: Verify Master-Minion connection before applying changes: verify that the Minion has successfully registered with the Master.

Check accepted keys:
```Bash
sudo salt-key -L
```

You should see 'minion1' listed under 'Accepted Keys'.

Test connectivity (Ping):
```Bash
sudo salt 'minion1' test.ping
```

Expected output:
```Plaintext
minion1:
    True
```

**Step 3**: Apply the Highstate: Run the following command to trigger Docker installation and container deployment:
```Bash 
sudo salt 'minion1' state.apply
```

Expected output: Salt should return a summary report showing Succeeded: X (where X is the number of steps) and Failed: 0.

---

## Verify the Demo

1. Open your web browser on your host machine.

2. Navigate to: http://localhost:8080

3. You should see a web page served by one of the containers.

4. Refresh the page (F5) multiple times.

Result: The background color of the page should cycle between Blue, Pink, and Yellow. This confirms that the Nginx Load Balancer is working correctly and distributing traffic to different backend containers in a Round-Robin fashion.

Alternatively, you can run localhost on the command line either on the Master or on the Minion (as the VMs don't have a graphical user interface by deafult):

Master:
```Bash
vagrant ssh master
# Test the IP address for minion1
curl http://192.168.12.11
```

Minion:
```Bash
vagrant ssh minion1
# Test the localhost (one of the webservers will answer)
curl http://localhost
```

### Project Structure
```Plaintext
docker-demo/
├── Vagrantfile               # VM definition (Master & Minion)
├── .gitattributes            # Enforces LF line endings for scripts (for Windows)
├── scripts/                  # Initial provisioning scripts
│   ├── master.sh             # Sets up Salt Master & Symlinks /srv/salt
│   └── minion.sh             # Sets up Salt Minion
└── salt/                     # SaltStack State Tree
    ├── top.sls               # State entry point
    ├── docker/               # Module: Installs Docker Engine
    ├── nginx-proxy/          # Module: Configures the Load Balancer
    └── nginx-web/            # Module: Deploys backend containers
        ├── docker-compose.yml
        ├── site1/            # Blue Theme Content
        ├── site2/            # Pink Theme Content
        └── site3/            # Yellow Theme Content
```

Project structure - at a glance

```Plaintext
docker-demo/
├── Vagrantfile               # Defines the VM infrastructure (Master & Minion) and port forwarding (Host 8080 -> Guest 80).
├── .gitattributes            # Enforces LF line endings for scripts (for Windows).
├── scripts/                  # Shell scripts for initial VM provisioning.
│   ├── master.sh             # Installs Salt Master and creates a symlink from /vagrant/salt to /srv/salt.
│   └── minion.sh             # Installs Salt Minion and connects it to the Master.
└── salt/                     # Main SaltStack configuration directory (synced to the Master).
    ├── top.sls               # Entry point: Maps state modules to the minion.
    ├── docker/               # Module: Handles Docker installation.
    │   └── init.sls          # Installs Docker Engine and adds 'vagrant' user to the docker group.
    ├── nginx-proxy/          # Module: Handles the Load Balancer.
    │   ├── init.sls          # Installs Nginx on the host.
    │   └── nginx.conf        # Nginx configuration: Distributes traffic to ports 8081, 8082, 8083.
    └── nginx-web/            # Module: Handles the backend web containers.
        ├── init.sls          # Copies website content (including images) and starts Docker containers.
        ├── docker-compose.yml# Defines 3 Nginx services (web1, web2, web3) mapped to different site folders.
        ├── site1/            # Source content for Container 1 (Blue Theme).
        │   ├── index.html
        │   ├── styles.css
        │   └── images/       # Subdirectory for media assets.
        │       └── demo-image.png
        ├── site2/            # Source content for Container 2 (Pink Theme).
        │   ├── index.html
        │   ├── styles.css
        │   └── images/       # Subdirectory for media assets.
        │       └── demo-image.png
        └── site3/            # Source content for Container 3 (Yellow Theme).
            ├── index.html
            ├── styles.css
            └── images/       # Subdirectory for media assets.
                └── demo-image.png
```

Project structure - in detail

### Developer Note: Synced Folders

The provisioning script automatically links the local`salt/` folder to `/srv/salt/` on the Master. This means you can edit files on your host machine (e.g., in VS Code) and simply run `state.apply` on the Master to see changes instantly, without needing to copy files manually.

In case there is need to copy files manually, do the following:
1. Clone the repository onto your Master node.
2. Create a directory for Salt modules:	`sudo mkdir -p /srv/salt`.
3. Copy the salt directory of the cloned repository into the newly created directory: `sudo cp -r docker-demo/salt/* /srv/salt/`.
4. Apply the Highstate: `sudo salt 'minion1' state.apply`.

---

## Note on Production vs. Demo Environment

**Why are the sites different colors?** In this educational demo, we have intentionally modified the CSS of each container (Blue, Pink, Yellow) to provide a clear visual indication that the load balancer is routing traffic to different instances.

**In a Real Production Environment:** In a real-world scenario, all backend containers would serve identical content. The goal of load balancing in production is to distribute workload, ensure redundancy, and provide high availability, while keeping the user experience consistent regardless of which specific server handles the request.

![img2](./img/img2.png)

Load balancer in action


