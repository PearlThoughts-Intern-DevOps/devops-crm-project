# Task 11: Terraform Preparation for Twenty CRM

## Objective

Prepare Terraform configuration for Twenty CRM infrastructure on AWS,
using the existing default VPC, an EC2 instance, and an Amazon ECR
repository in `us-east-1`.

Branch: `chirag-task-11`

This task prepares infrastructure configuration only. No AWS infrastructure
was created, modified, or deleted.

## Architecture

```text
AWS us-east-1
|
+-- Existing default VPC
|   |
|   +-- Existing default subnet in us-east-1a
|       |
|       +-- Security group
|       |   +-- Inbound SSH: TCP 22 from configured CIDR
|       |   +-- Inbound application: TCP 2020 from configured CIDR
|       |   +-- Outbound HTTPS: TCP 443
|       |
|       +-- EC2 instance
|           +-- t3.small
|           +-- Encrypted 20 GiB gp3 root volume
|           +-- Public IP requested
|           +-- IMDSv2 required
|
+-- Amazon ECR repository
    +-- Twenty CRM container images
```

Twenty CRM installation, Docker image builds, and image pushes are outside
this configuration.

## Project Structure

```text
terraform/
├── versions.tf
├── provider.tf
├── variables.tf
├── vpc.tf
├── ec2.tf
├── ecr.tf
├── outputs.tf
├── terraform.tfvars.example
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

| File | Purpose |
|---|---|
| versions.tf | Terraform CLI and AWS provider version constraints |
| provider.tf | AWS provider configuration using the region variable |
| variables.tf | Configurable inputs and input validation |
| vpc.tf | Lookups for the existing default VPC and subnet |
| ec2.tf | EC2 instance, security group rules, root disk, and common tags |
| ecr.tf | Container image repository configuration |
| outputs.tf | Infrastructure IDs and addresses |
| terraform.tfvars.example | Safe example input values |
| .gitignore | Excludes local dependencies, state, plans, and variable files |
| .terraform.lock.hcl | Records selected provider version and checksums |
| README.md | Implementation details, verification results, and limitations |

Terraform reads the `.tf` files in this directory as one configuration.
Filenames organize the code; they do not set execution order. References
between blocks tell Terraform which values depend on other values.

## Explanation of Each File

### `versions.tf`

The `terraform` block declares requirements for running this project.
`required_version` controls the Terraform CLI version. `required_providers`
declares the AWS plugin, with `source = "hashicorp/aws"` identifying its
publisher and name. The `~> 6.0` provider constraint accepts 6.x releases
without allowing the next major version, 7.x.

### `provider.tf`

The `provider "aws"` block configures the AWS plugin. Its
`region = var.aws_region` reads the region input instead of repeating a
hardcoded value. Credentials are not included in this file.

### `variables.tf`

Each `variable` block declares an input. `description` explains its purpose,
`type` specifies text or a number, and `default` supplies an optional value.
Inputs without defaults must be supplied when planning. `validation` blocks
check conditions and display an `error_message` for invalid values.
For example, the application port must be an integer from 1 to 65535.
The Variables table below explains every input.

### `vpc.tf`

Two `data` blocks read existing network information. The first selects the
default VPC. The second uses `data.aws_vpc.default.id`, the configured zone,
and `default_for_az = true` to select its default subnet. No new VPC or
subnet is declared. Evaluating these lookups requires AWS API access.

### `ec2.tf`

The `locals` block defines a reusable name prefix and common tags.
`${...}` inserts values into names, while `merge()` combines common tags
with a resource-specific Name tag.

Resource blocks define the security group, separate inbound and outbound
rules, and EC2 instance. The instance references the selected subnet and
security group IDs. `root_block_device` configures disk size, type,
encryption, and deletion on termination. `metadata_options` requires
IMDSv2 tokens. These blocks prepare infrastructure but do not install CRM.

### `ecr.tf`

The `aws_ecr_repository` resource defines the container image repository.
Its name comes from a variable. Nested blocks configure encryption and
scanning, while immutable tags prevent existing tags from being replaced.
`force_delete = false` blocks repository deletion through Terraform while
images remain. Image builds and pushes happen separately.

### `outputs.tf`

Each `output` block gives a name and description to a result. Its `value`
references a resource or data-source attribute, such as
`aws_instance.twenty.public_ip`. The Outputs table below explains all seven
results. Declaring an output does not create the referenced infrastructure.

### `terraform.tfvars.example`

This file demonstrates input assignments, whereas `variables.tf` declares
the inputs themselves. It includes a placeholder AMI and documentation-only
CIDRs. Terraform does not automatically load the `.example` filename.
A future local `terraform.tfvars` can supply real environment values.

### `.gitignore`

This file excludes downloaded dependencies, state, saved plans, logs,
overrides, and local input files from version control. State and saved
plans can contain sensitive values. The example input file and provider
dependency lock file remain eligible for version control.

### `.terraform.lock.hcl`

Generated by `terraform init`, this file records the selected provider
version and checksums. Preserve it in version control for repeatable
provider installation. It is a dependency lock file, not Terraform state
or the temporary `.terraform.tfstate.lock.info` state-operation lock.

### `.terraform/` (Generated Directory)

Initialization creates this hidden directory for downloaded providers and
other local initialization data. It is not application source code and is
excluded from version control. It is omitted from the source-file tree above.

### `README.md`

This document explains the configuration, commands used, observed results,
issues, and remaining limitations. Terraform does not execute Markdown files.

## Work Completed

1. Verified the repository directory and clean working tree.
2. Confirmed that `chirag-task-11` already existed and was the active branch.
   No branch replacement or recreation was needed.
3. Verified Terraform v1.16.1 on macOS ARM64.
4. Created the `terraform/` directory.
5. Created configuration files manually using Vim.
6. Configured the AWS provider for `us-east-1` through an input variable.
7. Used data sources to select the existing default VPC and its default
   subnet in the configured availability zone.
8. Defined EC2 infrastructure and restricted inbound access.
9. Defined one ECR repository.
10. Added outputs, example variables, and Terraform-specific Git exclusions.
11. Ran formatting, initialization, and configuration validation successfully.

## Configuration Details

### Versions and Provider

- Terraform constraint: `>= 1.10.0, < 2.0.0`
- AWS provider source: `hashicorp/aws`
- AWS provider constraint: `~> 6.0`
- Provider version installed during initialization: `6.63.0`

The CLI and provider have independent versions.
The provider constraint permits 6.x releases while excluding 7.x.

No AWS credentials are stored in the configuration.

### Existing Network

The configuration uses these data sources:

- `data.aws_vpc.default`
- `data.aws_subnet.selected`

A data source reads existing infrastructure. A resource block declares
infrastructure Terraform would manage if applied.

Subnet selection explicitly uses the VPC ID, availability zone, and
`default_for_az = true`. It does not select an arbitrary first subnet.

The lookup requires the default VPC and selected default subnet to exist.
It will fail if they are missing rather than create replacements.

### EC2 and Security Group

The instance configuration includes:

- Configurable AMI and instance type.
- A subnet from the existing default VPC.
- A public IP address request.
- An encrypted gp3 root volume.
- Token-based instance metadata access through IMDSv2.
- Project, environment, and management tags.

Inbound traffic is limited to SSH and the application port, each using a
configurable source CIDR. Prefer a trusted public IPv4 address with `/32`
for SSH. The validation rejects `/0`, but broader networks are still
possible and should be chosen deliberately.

Outbound HTTPS is allowed to any IPv4 destination. Other outbound ports
are not explicitly permitted by this configuration.

No SSH key pair is configured. Allowing port 22 alone does not establish
SSH authentication. Public connectivity also depends on existing routing
and network ACLs; public DNS depends on VPC DNS settings.

### ECR

The repository uses:

- Immutable image tags.
- AES256 encryption.
- Scanning on push.
- `force_delete = false`.
- Common project tags.

ECR stores container images. Docker or CI builds and pushes those images
separately. Immutable tags require unique image tags rather than repeatedly
overwriting an existing tag such as `latest`.

No image lifecycle deletion policy was added.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| aws_region | us-east-1 | AWS region |
| project_name | devops-crm | Naming and tagging |
| environment | dev | Environment identifier |
| availability_zone | us-east-1a | Zone for default subnet lookup |
| instance_type | t3.small | EC2 instance type |
| ami_id | Required | Compatible regional x86_64 Linux AMI |
| root_volume_size | 20 | Root volume size in GiB |
| application_port | 2020 | Application TCP port |
| ecr_repository_name | twenty-crm | ECR repository name |
| ssh_allowed_cidr | Required | Allowed SSH source network |
| application_allowed_cidr | Required | Allowed application source network |

The example AMI `ami-00000000000000000` is a placeholder, not a usable AMI.
Its format passing validation does not confirm that it exists.

The example address `203.0.113.10/32` is documentation-only and must be
replaced for real access.

The region and availability zone must be consistent.

## Outputs

| Output | Purpose |
|---|---|
| vpc_id | Existing default VPC ID |
| subnet_id | Selected subnet ID |
| ec2_instance_id | EC2 instance ID |
| ec2_public_ip | Assigned public IPv4 address |
| ec2_public_dns | Public DNS hostname, if available |
| security_group_id | Instance security group ID |
| ecr_repository_url | Repository destination for container images |

New resource values are not available from deployed infrastructure because
nothing was applied.

## Configuration Commands Used

These commands document directory setup, manual editing, and inspection.
Paths beginning with `terraform/` were used from the repository root.

### Check the Working Directory and Installation

```bash
pwd
terraform version
if [ -d terraform ]; then ls -la terraform; else echo "terraform/ does not exist"; fi
```

- `pwd` prints the current directory.
- `terraform version` reports the installed CLI version and platform:
  Terraform v1.16.1 on `darwin_arm64` in this task.
- The conditional checks whether the Terraform directory exists. If it
  does, `ls -la` lists its contents including hidden files; otherwise,
  `echo` prints a message. This check does not change files.

### Create and Inspect the Directory

```bash
mkdir terraform
ls -ld terraform
```

`mkdir` created the directory. `ls -ld` displayed the directory's own
permissions, owner, and other details rather than listing its contents.

### Create Configuration Files with Vim

The following commands opened the configuration files for manual editing:

```bash
vim terraform/versions.tf
vim terraform/provider.tf
vim terraform/variables.tf
vim terraform/vpc.tf
vim terraform/ec2.tf
vim terraform/ecr.tf
vim terraform/outputs.tf
vim terraform/terraform.tfvars.example
vim terraform/.gitignore
```

For each file, press `i` to enter insert mode, paste the content, press
`Esc` to return to normal mode, then type `:wq` and press Enter to save
and exit. Saving creates or updates the local file; it does not contact AWS.
The README was added separately from supplied text.

### Review Saved Configuration

```bash
cat terraform/versions.tf
cat terraform/provider.tf
cat terraform/variables.tf
cat terraform/vpc.tf
cat terraform/ec2.tf
cat terraform/ecr.tf
cat terraform/outputs.tf
cat terraform/terraform.tfvars.example
cat terraform/.gitignore
```

`cat` printed each saved file for review without changing it.

To investigate apparent formatting artifacts, this command was also used:

```bash
LC_ALL=C cat -vet terraform/versions.tf
```

`LC_ALL=C` sets the locale for this command only. The `cat` options make
nonprinting characters visible, show tabs as `^I`, and mark line endings
with `$`. Those display markers are not written into the file.

### Enter the Terraform Working Directory

```bash
cd terraform
```

`cd` changes the terminal's working directory so Terraform operates on
this configuration. It does not modify configuration files.

## Terraform Commands and Validation Results

Commands were run from the `terraform/` directory.

### Formatting

```bash
terraform fmt -recursive
```

This command standardizes Terraform indentation and spacing, including
configuration in subdirectories. It can rewrite local configuration files
but does not query AWS or create infrastructure.

Result: completed without errors or filenames being printed.
No formatting changes were needed.

### Initialization

```bash
terraform init
```

This command prepares the working directory and downloads required provider
plugins. It writes local initialization data and the dependency lock file.
For this configuration's local backend, it requires provider download
access but does not require AWS credentials or create AWS resources.

Result:

```text
Installed hashicorp/aws v6.63.0 (signed by HashiCorp)
Terraform has been successfully initialized!
```

Initialization downloaded the provider and generated
`.terraform.lock.hcl`. That lock file should be committed.

### Configuration Validation

```bash
terraform validate
```

This command checks syntax, references, argument types, and provider schema
compatibility using the initialized dependencies. It does not query AWS
to confirm the default VPC, subnet, or AMI exists.

Result:

```text
Success! The configuration is valid.
```

This confirms configuration syntax and internal consistency against the
installed provider schema. It does not verify live AWS infrastructure,
AMI availability, permissions, or deployment readiness.

### Plan Status

`terraform plan` was intentionally not run at the user's request.

Therefore:

- No successful plan is claimed.
- No AWS credentials or API-access failure was observed.
- The task's successful-plan requirement remains unverified.

A meaningful future plan requires real input values, AWS credentials,
appropriate read permissions, and AWS API access because the configuration
queries the existing VPC and subnet.

After preparing a local `terraform.tfvars` with valid values, the planning
command would be:

```bash
terraform plan -input=false
```

This command is documented for a future step and was not executed.

Do not run `terraform apply` or `terraform destroy` for Task 11.

## Issues Encountered and Resolution

### Git branch listing opened in a pager

The branch output ended with a `:` prompt because Git opened a scrollable
viewer.

Guidance provided: press `q` to leave the pager. The remaining installation
and directory checks were subsequently run and their output reviewed.

### Pasted output appeared to contain escaped characters

Chat displayed characters such as `&#x20;`, escaped underscores, and
apparent Markdown fences.

Read-only inspection of affected files confirmed that these artifacts
were not present in the actual files inspected. No corrective edit was
needed. Later, `terraform validate` passed for the complete configuration.

### No Terraform command errors observed

Formatting, initialization, and validation all completed successfully.
There was no Terraform error requiring a configuration fix.

Skipping planning was a workflow decision, not a resolved technical error.

## Git and Local Files

Commit the configuration, example variables, README, and provider lock file.

The `.gitignore` excludes:

- `.terraform/` downloaded dependencies and initialization data.
- Terraform state and backups.
- Saved plans ending in `.tfplan`.
- Crash logs.
- Local override files.
- Temporary state lock information.
- Local `.tfvars` and `.tfvars.json` files.

`terraform.tfvars.example` is a shared template and is not automatically
loaded by Terraform. A real `terraform.tfvars` is automatically loaded
and is excluded from Git.

Do not store AWS credentials in either file.

Git review, staging, committing, pushing, and PR creation were still
pending when this documentation was prepared.

## Scope and Future Cleanup

No apply or destroy command was run, so this task created no AWS resources
requiring cleanup.

The EC2 and ECR resource blocks describe new resources; they do not
automatically adopt existing instances or repositories.

If applied in a future authorized task:

- EC2 termination would delete its root disk because
  `delete_on_termination = true`.
- ECR deletion through Terraform would be blocked while images remain
  because `force_delete = false`.
- The default VPC and subnet would remain outside Terraform resource
  management because they are referenced through data sources.

Any future deployment or cleanup requires a separate review.
