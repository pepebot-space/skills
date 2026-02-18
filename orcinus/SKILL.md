---
name: orcinus
description: "Container orchestration management for Docker Swarm using the `orcinus` CLI. Use `orcinus create`, `orcinus ls`, `orcinus scale`, `orcinus update`, `orcinus rollback`, `orcinus logs`, and `orcinus cluster` to deploy services, manage clusters, and orchestrate containers via orcinus.yml manifests."
metadata: {
  "pepebot": {
    "emoji": "🐳",
    "requires": {
      "bins": ["orcinus", "docker"]
    },
    "install": [
      {
        "id": "npm",
        "kind": "npm",
        "package": "orcinus",
        "bins": ["orcinus"],
        "label": "Install Orcinus CLI (npm)"
      }
    ]
  }
}
---

# Orcinus — Container Orchestration for Docker Swarm

Orcinus is an agnostic container orchestration management tool for Docker Swarm mode. It uses `orcinus.yml` manifests to define multi-service stacks, manage clusters, scale services, and perform rolling updates.

## CLI Commands Reference

| Command | Description |
|---------|-------------|
| `orcinus create` | Create/deploy all services defined in `orcinus.yml` |
| `orcinus ls` | List services defined in current `orcinus.yml` |
| `orcinus ls all` | List all running services across the swarm |
| `orcinus ls <service_name>` | Show details of a specific service |
| `orcinus ps` | List all running processes/tasks |
| `orcinus inspect` | Inspect all services (detailed info) |
| `orcinus update` | Update services with new configuration |
| `orcinus rollback` | Rollback services to previous version |
| `orcinus scale <service>=<N>` | Scale a service to N replicas |
| `orcinus rm` | Remove all services defined in `orcinus.yml` |
| `orcinus logs` | Get service logs |
| `orcinus logs follow` | Stream logs in real-time |
| `orcinus logs tail` | Show recent log entries |
| `orcinus dashboard <host:port>` | Start web dashboard (default: `0.0.0.0:4000`) |
| `orcinus -f <file.yml> <cmd>` | Use a specific manifest file |

### Cluster Management

| Command | Description |
|---------|-------------|
| `orcinus cluster init <IP>` | Initialize this node as swarm manager |
| `orcinus cluster join <TOKEN>` | Join an existing cluster as worker |
| `orcinus cluster ls` | List all nodes in the cluster |
| `orcinus cluster inspect <hostname>` | Inspect a specific node |
| `orcinus cluster token` | Get the join token for workers |
| `orcinus cluster promote <hostname>` | Promote a worker to manager |
| `orcinus cluster leave` | Leave the cluster (worker) |
| `orcinus cluster leave-manager` | Leave the cluster (manager) |

---

## orcinus.yml Configuration

The `orcinus.yml` file defines your service stack. Place it in your project directory and run `orcinus create` to deploy.

### Complete Schema Reference

```yaml
# Stack name — creates an overlay network with this name
stack: "mystack"

# Volume definitions (referenced by services)
volumes:
  vol_name:
    type: "bind"              # bind | nfs
    source: "/host/path"      # Host path (bind) or NFS export path
    target: "/container/path" # Mount point inside container
  nfs_vol:
    type: "nfs"
    address: "192.168.7.11"   # NFS server IP (nfs type only)
    source: "/nfs/share"
    target: "/mnt/data"

# Service definitions
services:

  service_name:
    # Required
    image: "nginx:latest"           # Docker image

    # Networking
    ports:                           # Port mappings (published:target[/protocol])
      - "80:80"                      # TCP (default)
      - "443:443/tcp"                # Explicit TCP
      - "53:53/udp"                  # UDP
    networks:                        # Overlay networks to join
      - "frontend"
      - "backend"

    # Scaling & Resources
    replicas: 3                      # Number of replicas (default: 1)
    cpu: "2"                         # CPU limit (cores, float)
    memory: "512mb"                  # Memory limit (kb, mb, gb)

    # Container Config
    environment:                     # Environment variables
      - "NODE_ENV=production"
      - "DB_HOST=db.local"
    commands:                        # Container command arguments (Args)
      - "--config=/etc/app.conf"
    hosts:                           # Extra /etc/hosts entries
      - "db.local:192.168.7.20"
    labels:                          # Service labels (key-value object)
      app: "web"
      env: "production"

    # Volumes
    volumes:                         # Reference volume names from top-level
      - "vol_name"
      - "nfs_vol"

    # DNS Configuration
    dns:
      Nameservers:
        - "8.8.8.8"
        - "8.8.4.4"
      Search:
        - "example.org"
      Options:
        - "timeout:3"

    # Placement Constraints
    constraints:                     # Docker swarm placement
      - "node.role == manager"
      - "node.hostname == ak1"

    # Restart Policy
    restartPolicy:
      Condition: "on-failure"        # any | none | on-failure
      Delay: 10000000000             # Nanoseconds between restart attempts
      MaxAttempts: 10                # Max restart attempts (0 = unlimited)
```

---

## orcinus.yml Examples

### Basic Web Server

```yaml
stack: "web"
services:
  app:
    image: "nginx:alpine"
    ports:
      - "80:80"
    replicas: 3
    cpu: "1"
    memory: "256mb"
```

### Multi-Service Application

```yaml
stack: "myapp"
services:
  frontend:
    image: "myapp/frontend:latest"
    ports:
      - "3000:3000"
    replicas: 3
    cpu: "1"
    memory: "512mb"
    environment:
      - "API_URL=http://backend:8080"
    networks:
      - "appnet"

  backend:
    image: "myapp/backend:latest"
    ports:
      - "8080:8080"
    replicas: 2
    cpu: "2"
    memory: "1gb"
    environment:
      - "DATABASE_URL=postgres://db:5432/myapp"
      - "NODE_ENV=production"
    networks:
      - "appnet"

  db:
    image: "postgres:15"
    ports:
      - "5432:5432"
    environment:
      - "POSTGRES_DB=myapp"
      - "POSTGRES_USER=admin"
      - "POSTGRES_PASSWORD=secret"
    constraints:
      - "node.role == manager"
    networks:
      - "appnet"
```

### MariaDB Cluster with NFS

```yaml
stack: "dbcluster"
volumes:
  dbdata:
    type: "nfs"
    address: "192.168.7.11"
    source: "/nfs/mariadb"
    target: "/var/lib/mysql"
services:
  mariadb:
    image: "mariadb:10.11"
    ports:
      - "3306:3306"
    replicas: 3
    cpu: "2"
    memory: "2gb"
    environment:
      - "MYSQL_ROOT_PASSWORD=secret"
      - "MYSQL_DATABASE=production"
    volumes:
      - "dbdata"
    restartPolicy:
      Condition: "on-failure"
      MaxAttempts: 5
```

### Web Proxy with Docker Socket Bind

```yaml
stack: "proxy"
volumes:
  docker:
    type: "bind"
    source: "/var/run/docker.sock"
    target: "/var/run/docker.sock"
services:
  proxy:
    image: "traefik:v3"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - "docker"
    constraints:
      - "node.role == manager"
    labels:
      traefik.enable: "true"
```

### Logging Stack

```yaml
stack: "logging"
services:
  elasticsearch:
    image: "elasticsearch:8.12.0"
    ports:
      - "9200:9200"
    cpu: "4"
    memory: "4gb"
    environment:
      - "discovery.type=single-node"
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
    constraints:
      - "node.role == manager"

  kibana:
    image: "kibana:8.12.0"
    ports:
      - "5601:5601"
    cpu: "2"
    memory: "1gb"
    environment:
      - "ELASTICSEARCH_HOSTS=http://elasticsearch:9200"
    networks:
      - "logging"
```

---

## Operations Workflow

### Initial Cluster Setup

```bash
# 1. Initialize manager node
orcinus cluster init 192.168.7.11

# 2. Get join token
orcinus cluster token

# 3. On worker nodes, join the cluster
orcinus cluster join <TOKEN>

# 4. Verify cluster
orcinus cluster ls
orcinus cluster inspect <hostname>
```

### Deploy Services

```bash
# Create orcinus.yml in your project directory
# Then deploy:
orcinus create

# Verify deployment
orcinus ls
orcinus ps

# Inspect service details
orcinus inspect
```

### Scaling

```bash
# Scale a single service
orcinus scale web=5

# Verify scale
orcinus ls
```

### Rolling Updates

```bash
# Edit orcinus.yml (change image tag, env, resources, etc.)
# Then apply update:
orcinus update

# If something goes wrong, rollback:
orcinus rollback
```

### Monitoring & Logs

```bash
# View service logs
orcinus logs

# Stream logs in real-time
orcinus logs follow

# Show recent logs
orcinus logs tail

# Start web dashboard on port 4000
orcinus dashboard

# Start dashboard on custom host:port
orcinus dashboard 0.0.0.0:8080
```

### Teardown

```bash
# Remove all services from current orcinus.yml
orcinus rm
```

### Using Custom Manifest File

```bash
# Use a different manifest file
orcinus -f staging.yml create
orcinus -f staging.yml ls
orcinus -f staging.yml rm
```

---

## Best Practices

- **Stack naming**: Use descriptive stack names — they become overlay network names
- **Resource limits**: Always set `cpu` and `memory` to prevent resource exhaustion
- **Replicas**: Use `replicas: 3` or higher for high availability
- **Constraints**: Pin stateful services (databases) to manager nodes
- **NFS volumes**: Use for shared persistent data across swarm nodes
- **Rolling updates**: Always test with `orcinus update` before removing/recreating
- **Rollback**: Use `orcinus rollback` immediately if an update causes issues
- **Dashboard**: Use `orcinus dashboard` for visual monitoring of your swarm
- **Manifest formats**: Orcinus supports both `orcinus.yml` and `orcinus.json`

## Troubleshooting

- **"File doesn't exist"**: Ensure `orcinus.yml` or `orcinus.json` is in the current directory
- **Services not starting**: Check `orcinus logs` and verify image names/tags exist
- **Network issues**: Ensure all nodes have full network connectivity
- **Permission denied**: Run orcinus as root or with Docker group permissions
- **Scale not working**: Verify service name matches exactly what's in `orcinus.yml`
