# Deploying Twenty CRM on AWS EC2

## Objective

The objective of this task was to launch and configure an Amazon EC2 instance,
connect to it securely, and deploy the Twenty CRM application and this custom
Twenty app with Docker Compose. The task also covered core EC2 concepts,
deployment verification, troubleshooting, documentation, and cleanup of AWS
resources to avoid unnecessary charges.

## Required EC2 Configuration

| Setting | Value |
| --- | --- |
| AWS Region | `us-east-1` (US East, N. Virginia) |
| AMI | Amazon Linux, `ami-081b0a6eac00b4f53` |
| Instance type | `t3.small` |
| Root storage | 20 GiB EBS, `gp3` |
| Application port | TCP `2020` |
| SSH port | TCP `22` |

The `t3.small` instance has 2 GiB of memory. The repository recommends at least
4 GiB for the all-in-one Twenty development server, so a 4 GiB swap file was
used to reduce the risk of an out-of-memory failure. Swap is slower than RAM;
for a longer-running environment, a `t3.medium` or larger instance would be
more suitable if the task requirements permit it.

## Architecture

```text
Developer computer
   |
   | SSH (TCP 22, restricted to developer public IP)
   | HTTP (TCP 2020, restricted to developer public IP)
   v
AWS security group
   |
   v
EC2 t3.small / Amazon Linux / 20 GiB EBS
   |
   +-- Docker Compose network
       |
       +-- twenty service
       |   +-- Twenty web server (port 2020)
       |   +-- Worker
       |   +-- PostgreSQL
       |   +-- Redis
       |
       +-- app service
           +-- Builds the custom Twenty app
           +-- Authenticates with the internal Twenty API
           +-- Applies the application manifest, then exits

Persistent Docker volumes
   +-- twenty-crm-database
   +-- twenty-crm-storage
```

The `twenty` container is a long-running service. The `app` container is a
one-time synchronization process, so `Exited (0)` is its expected successful
state.

## Prerequisites

- Access to an AWS account with permission to manage EC2 instances, security
  groups, key pairs, and EBS volumes
- The source repository and the task branch
- A current public IP address for restricted security-group access
- A local SSH client
- Permission to create a Twenty workspace API key

## 1. Validate the AMI

Before launch, the AMI can be checked with the AWS CLI from a configured local
computer:

```bash
aws ec2 describe-images \
  --region us-east-1 \
  --image-ids ami-081b0a6eac00b4f53 \
  --query 'Images[0].{Name:Name,StateName:State,Architecture:Architecture,RootDevice:RootDeviceName}' \
  --output table
```

The image must be available in `us-east-1`, and its architecture must be
compatible with `t3.small`.

## 2. Create and Protect the Key Pair

In the AWS EC2 console:

1. Select the `us-east-1` region.
2. Open **EC2 > Key pairs > Create key pair**.
3. Use a descriptive name such as `twenty-crm-key`.
4. Select RSA and the `.pem` private-key format.
5. Download the key once and store it securely.

On the local computer, restrict the key's permissions:

```bash
chmod 400 ~/Downloads/twenty-crm-key.pem
```

The private key must never be uploaded to EC2, pasted into documentation, or
committed to Git. If it is lost, AWS cannot provide another copy of the private
key.

## 3. Create the Security Group

The security group was configured with the following inbound rules:

| Type | Protocol | Port | Source | Purpose |
| --- | --- | --- | --- | --- |
| SSH | TCP | `22` | Developer public IP `/32` | Administrative access |
| Custom TCP | TCP | `2020` | Developer public IP `/32` | Twenty web interface |

The default outbound rule was retained so that the instance could reach GitHub
and container registries. SSH was not exposed to `0.0.0.0/0`. Port `2020` was
also limited to the developer's IP for this demonstration.

## 4. Launch the Instance

The EC2 launch wizard was configured as follows:

- Name: `twenty-crm`
- AMI: `ami-081b0a6eac00b4f53`
- Instance type: `t3.small`
- Key pair: `twenty-crm-key`
- Network: a VPC with a public subnet and Internet Gateway route
- Auto-assign public IPv4 address: enabled
- Security group: the group described above
- Root EBS volume: 20 GiB `gp3`, encrypted, delete on termination enabled
- Instance metadata: IMDSv2 required

Deployment continued after the instance reached `Running` and both AWS status
checks passed.

## 5. Connect to EC2

From the local computer:

```bash
ssh -i ~/Downloads/twenty-crm-key.pem ec2-user@EC2_PUBLIC_IP
```

`EC2_PUBLIC_IP` is a placeholder and must be replaced with the current public
IPv4 address or public DNS name. Amazon Linux uses `ec2-user` by default.

## 6. Install Docker and Git

On the EC2 instance:

```bash
sudo dnf update -y
sudo dnf install -y docker git curl
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
exit
```

After reconnecting over SSH, Docker was verified:

```bash
docker --version
docker info
git --version
```

Logging out and reconnecting was required for membership in the `docker` group
to take effect.

## 7. Install Docker Compose

The attempted package installation failed:

```bash
sudo dnf install -y docker-compose-plugin
```

Error:

```text
No match for argument: docker-compose-plugin
docker: 'compose' is not a docker command
```

Amazon Linux's enabled repositories did not contain the Compose plugin package,
so the official Compose CLI plugin was installed manually. The instance
architecture was checked first:

```bash
uname -m
```

For the `x86_64` instance:

```bash
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -fSL \
  https://github.com/docker/compose/releases/download/v5.5.0/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version
```

Manual plugin installations do not update automatically, so their versions
must be reviewed during future maintenance.

## 8. Configure Swap

Memory was checked with:

```bash
free -h
```

A 4 GiB swap file was configured:

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

It was verified with:

```bash
free -h
swapon --show
grep -n '/swapfile' /etc/fstab
```

The observed result showed approximately 1.9 GiB RAM and 4 GiB active swap.
Repeating the swap creation commands later produced `Text file busy`,
`mounted`, and `Device or resource busy` messages. These messages occurred
because `/swapfile` was already active; no further action was necessary.

## 9. Clone the Repository and Select the Branch

```bash
cd /home/ec2-user
git clone https://github.com/PearlThoughts-Intern-DevOps/devops-crm-project.git
cd devops-crm-project
git fetch --all --prune
git branch -a
git switch chirag-task-7
git branch --show-current
git status
```

If the branch exists only on the remote, use:

```bash
git switch --track origin/chirag-task-7
```

If it has not yet been created, use:

```bash
git switch -c chirag-task-7
```

## 10. Check Storage and Docker Usage

```bash
df -h
docker system df
```

Before the image build, the 20 GiB root filesystem had approximately 14 GiB
available. Docker initially had no images, containers, volumes, or build cache.

## 11. Configure the Environment

The environment template was copied and protected:

```bash
cp .env.example .env
chmod 600 .env
git check-ignore .env
```

The `.env` file was edited without printing its secret into terminal output or
shell history:

```bash
nano .env
```

Configuration format:

```dotenv
TWENTY_API_KEY=<REDACTED>
TWENTY_IMAGE=twentycrm/twenty-app-dev@sha256:53381e68f6fa50808f624f4c0125ce2143c6d21321ba25886e1115c73367c6e6
TWENTY_PORT=2020
NODE_VERSION=24.5.0
```

The actual API key is intentionally omitted. A key that appeared in a
screenshot was treated as exposed, revoked, and replaced. API keys, `.env`
files, AWS credentials, and private keys must never be committed or included in
screenshots.

## 12. Start Twenty CRM

The Twenty service was started separately so the workspace could initialize
and an API key could be created:

```bash
docker compose up -d twenty
docker compose ps
docker compose logs -f twenty
```

`Ctrl+C` stops following the logs but does not stop the container. The service
was then checked locally:

```bash
curl --fail http://localhost:2020
```

The web interface was opened from the developer computer at:

```text
http://EC2_PUBLIC_IP:2020
```

The development workspace API key was created under **Settings > MCP & APIs**,
assigned the required administrative role, copied once, and stored only in the
protected `.env` file.

## 13. Install a Compatible Docker Buildx Plugin

The first application build failed with:

```text
compose build requires buildx 0.17.0 or later
```

The installed version was confirmed as too old:

```bash
docker buildx version
```

It reported Buildx `0.12.1`. A current user-level plugin was installed without
removing the system package:

```bash
mkdir -p ~/.docker/cli-plugins
curl -fSL \
  https://github.com/docker/buildx/releases/download/v0.36.1/buildx-v0.36.1.linux-amd64 \
  -o ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
```

The binary checksum was verified:

```bash
echo "48af8a397ebd60178778bf63611dbcebe5f5e7a9be90eb9147b24b9587455778  $HOME/.docker/cli-plugins/docker-buildx" \
  | sha256sum --check
```

Buildx was then initialized and checked:

```bash
docker buildx version
docker buildx ls
docker buildx inspect --bootstrap
```

## 14. Build and Deploy the Custom Twenty App

The Compose configuration was validated:

```bash
docker compose config --quiet
```

The application image was built:

```bash
docker compose build app
```

The successful build completed in approximately 125 seconds. The Dockerfile
installed dependencies, ran linting, performed type checking and unit tests,
and built the Twenty application manifest.

The one-time application synchronization service was then started:

```bash
docker compose up -d app
docker compose logs -f app
```

## 15. Deployment Verification

Container state was checked with:

```bash
docker compose ps --all
```

Expected final state:

```text
twenty   Up (healthy)
app      Exited (0)
```

`Exited (0)` is successful for `app` because it applies the custom manifest and
then terminates. Logs and the HTTP endpoint were checked with:

```bash
docker compose logs --no-color --tail=100 app
docker compose logs --no-color --tail=200 twenty
curl -I http://localhost:2020
```

Final UI verification:

1. Open `http://EC2_PUBLIC_IP:2020`.
2. Sign in to Twenty.
3. Refresh the page after app synchronization.
4. Confirm the custom navigation item and page are available.

Resource utilization can be checked with:

```bash
docker stats --no-stream
free -h
df -h /
docker system df
```

## 16. Issues and Resolutions

| Issue | Cause | Resolution |
| --- | --- | --- |
| `docker-compose-plugin` not found | Package absent from enabled Amazon Linux repositories | Installed the official Compose CLI plugin manually |
| `docker: 'compose' is not a docker command` | Compose plugin was not installed | Installed the plugin under `/usr/local/lib/docker/cli-plugins` and made it executable |
| Compose required Buildx 0.17 or later | Amazon Linux supplied Buildx 0.12.1 | Installed Buildx 0.36.1 under the user's Docker plugin directory |
| Swap creation reported `Text file busy` | The 4 GiB swap file was already enabled | Confirmed with `free -h` and `swapon --show`; did not recreate it |
| Risk of Twenty being OOM-killed | `t3.small` has only 2 GiB RAM | Added 4 GiB persistent swap and monitored memory |
| API key appeared in a screenshot | Credential was displayed while gathering evidence | Revoked it, generated a replacement, and excluded secrets from documentation |
| `app` container does not remain running | It is designed as a one-time manifest synchronization service | Treated `Exited (0)` as the expected successful state and checked its logs |

## 17. Cleanup and Cost Control

### Temporary stop

To stop application processes while preserving Docker data:

```bash
cd ~/devops-crm-project
docker compose stop
docker compose ps --all
```

The EC2 instance can then be stopped from **EC2 > Instances > Instance state >
Stop instance**. A stopped instance does not incur instance compute charges,
but its EBS volume and other allocated resources can continue to incur charges.

### Final cleanup

Before termination, preserve the required documentation. Then stop the Compose
project:

```bash
cd ~/devops-crm-project
docker compose down
```

Do not add `--volumes` unless permanent deletion of the local Twenty database
and file data is intended.

In the AWS console:

1. Select the correct instance in `us-east-1`.
2. Choose **Instance state > Terminate instance**.
3. Wait until its state is `Terminated`.
4. Open **Elastic Block Store > Volumes** and confirm that the 20 GiB root
   volume was deleted.
5. Confirm that no unused Elastic IP, snapshot, load balancer, or additional
   volume remains.
6. Delete the task security group if it is no longer needed.
7. Delete the AWS key-pair entry if it is no longer needed.
8. Securely remove the local private-key file when the task is complete.

## 18. EC2 Concepts Learned

- **Region:** A geographical AWS location. AMIs, key pairs, subnets, and many
  other resources are regional. This deployment used `us-east-1`.
- **Availability Zone:** An isolated location inside a region. A subnet belongs
  to one Availability Zone.
- **AMI:** A template containing the operating system and boot configuration
  used to create an instance.
- **Instance type:** Defines virtual CPU, memory, networking characteristics,
  and pricing. `t3.small` is a burstable general-purpose instance.
- **EBS:** Persistent block storage attached to EC2. The task used a 20 GiB
  `gp3` root volume.
- **Key pair:** The public key is stored by EC2 and the private key is retained
  by the user for SSH authentication.
- **Security group:** A stateful virtual firewall controlling allowed inbound
  and outbound traffic. Only ports 22 and 2020 were required inbound.
- **VPC:** The logically isolated network containing subnets, route tables,
  security groups, and the instance.
- **Public subnet:** A subnet whose route table provides a route to an Internet
  Gateway. A public address and suitable rules are also needed for connectivity.
- **Public and private IP addresses:** The private IP is used inside the VPC;
  the public IP enables Internet access. A normal public IP may change after an
  instance stop and start.
- **Instance status checks:** AWS checks the underlying platform and the guest
  instance. Both should pass before deployment begins.
- **IMDSv2:** The secured EC2 instance metadata service, configured to require
  session-oriented metadata requests.
- **Stop versus terminate:** Stop preserves the EBS-backed instance for later
  use, while terminate permanently deletes the instance and, when configured,
  its root volume.
- **Tags:** Key-value labels used for ownership, organization, automation, and
  cost tracking.
- **Swap:** Disk space used as overflow for memory. It can prevent an immediate
  OOM failure but does not provide RAM-level performance.
