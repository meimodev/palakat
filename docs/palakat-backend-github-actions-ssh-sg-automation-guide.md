# Palakat Backend GitHub Actions SSH Security Group Automation Guide

This guide shows how to let a GitHub Actions deployment workflow temporarily open SSH access to an EC2 instance security group, deploy the Palakat backend over SSH/SCP, and then remove that temporary access again.

The recommended pattern is:

- GitHub Actions assumes an AWS IAM role through OIDC.
- The workflow detects the current GitHub runner public IP.
- The workflow temporarily adds that IP as an inbound SSH rule on the EC2 security group.
- The workflow uploads and deploys the release over SSH.
- The workflow always removes that temporary SSH rule, even if deployment fails.

This avoids leaving SSH permanently open to the internet while still allowing GitHub-hosted runners to deploy.

---

# 1. Why this pattern is useful

GitHub-hosted runners do not come from one stable source IP that you can manually allow forever.

If your EC2 security group only allows SSH from your laptop IP, then GitHub Actions will usually fail with errors like:

```text
scp file to server.
error copy file to dest: ..., error message: dial tcp ...: i/o timeout
```

The approach in this guide solves that by allowing only the current runner IP for the duration of the workflow.

---

# 2. High-level architecture

The deployment flow looks like this:

1. GitHub Actions requests an OIDC token from GitHub.
2. AWS trusts that token and allows the workflow to assume a specific IAM role.
3. That IAM role is allowed to call EC2 APIs to update the target security group.
4. The workflow adds a temporary inbound SSH rule for the current runner IP.
5. The workflow runs `scp` and `ssh` deployment steps.
6. The workflow removes the temporary SSH rule in a cleanup step.

---

# 3. Required GitHub inputs

You will need the following values in GitHub Actions.

## 3.1 Recommended GitHub variables

Use GitHub repository variables for non-sensitive values.

Store these as variables:

- `AWS_REGION`
- `AWS_ROLE_TO_ASSUME`
- `EC2_SECURITY_GROUP_ID`
- `EC2_HOST`
- `EC2_PORT`
- `EC2_USER`

## 3.2 Required GitHub secrets

Use GitHub repository secrets for sensitive values.

Store these as secrets:

- `EC2_SSH_PRIVATE_KEY`
- `EC2_SSH_PASSPHRASE` if your private key is encrypted

---

# 4. How to obtain each value

## 4.1 `AWS_REGION`

This is the AWS region where the EC2 instance exists.

Examples:

- `ap-southeast-1`
- `us-east-1`

How to find it:

- Open the AWS Console.
- Switch to the region where your EC2 instance is running.
- Use that exact region string in GitHub.

## 4.2 `AWS_ROLE_TO_ASSUME`

This is the ARN of the IAM role that GitHub Actions will assume through OIDC.

Example:

```text
arn:aws:iam::123456789012:role/github-actions-palakat-deploy
```

You will create this role later in this guide.

## 4.3 `EC2_SECURITY_GROUP_ID`

This is the security group that controls inbound SSH access for the target EC2 instance.

Example format:

```text
sg-0123456789abcdef0
```

How to find it:

- Open AWS Console.
- Go to EC2.
- Open Instances.
- Select the target instance.
- Open the Security tab.
- Copy the attached security group ID that governs inbound SSH traffic.

Make sure this is the security group actually attached to the active network interface of the instance.

## 4.4 `EC2_HOST`

This is the SSH host used by GitHub Actions.

Use one of these:

- the EC2 public IPv4 address
- the EC2 public DNS name
- a stable domain name that resolves to the EC2 instance

For a simple first setup, the EC2 public IPv4 is easiest.

How to find it:

- Open AWS Console.
- Go to EC2.
- Open Instances.
- Select the target instance.
- Copy the Public IPv4 address.

## 4.5 `EC2_PORT`

This is the SSH port exposed by the EC2 instance.

The default is usually:

```text
22
```

How to verify on the server:

```bash
sudo ss -ltnp | grep ssh
sudo grep -R "^[[:space:]]*Port[[:space:]]" /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null
```

If you did not change SSH configuration, use `22`.

## 4.6 `EC2_USER`

This is the Linux user used for SSH login.

Common examples:

- `ubuntu`
- `ec2-user`
- `palakat`

Use the user whose `authorized_keys` contains the public key that matches your GitHub deployment private key.

For example, if the public key was installed in:

```text
/home/palakat/.ssh/authorized_keys
```

then your `EC2_USER` should be:

```text
palakat
```

## 4.7 `EC2_SSH_PRIVATE_KEY`

This must be the private key contents, not the public key.

A typical value looks like this:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

How to create a dedicated deploy key:

```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f palakat_backend_deploy_key
```

If you want to avoid passphrase handling in CI, create a key without passphrase:

```bash
ssh-keygen -t ed25519 -N "" -C "github-actions-deploy" -f palakat_backend_deploy_key
```

Then:

- add `palakat_backend_deploy_key.pub` to the target user's `authorized_keys`
- store the contents of `palakat_backend_deploy_key` in GitHub secret `EC2_SSH_PRIVATE_KEY`

## 4.8 `EC2_SSH_PASSPHRASE`

Only use this if the private key is encrypted.

If your key was created with a passphrase, store that passphrase in GitHub secret `EC2_SSH_PASSPHRASE`.

If your key was created with `-N ""`, you do not need this secret.

---

# 5. One-time AWS setup

## 5.1 Understand what you are creating

Before clicking around in AWS, it helps to know what each part does.

You need three AWS pieces:

- an **OIDC identity provider** so AWS can trust GitHub's identity tokens
- an **IAM policy** so the workflow is allowed to update the EC2 security group
- an **IAM role** that GitHub Actions assumes temporarily during deployment

Think of it this way:

- GitHub proves its identity to AWS using OIDC
- AWS checks whether that GitHub workflow is allowed to assume your role
- if allowed, AWS gives temporary credentials to the workflow
- the workflow uses those temporary credentials to call EC2 APIs

If the OIDC provider does not exist, you will get an error like:

```text
No OpenIDConnect provider found in your account for https://token.actions.githubusercontent.com
```

If the IAM role trust policy is wrong, you will usually get a role assumption or access denied error.

## 5.2 Create the GitHub OIDC identity provider in AWS

This is a one-time setup per AWS account.

### Step-by-step in AWS Console

1. Sign in to AWS Console.
2. In the search bar, type `IAM` and open **IAM**.
3. In the left sidebar, click **Identity providers**.
4. Click **Add provider**.
5. For **Provider type**, choose `OpenID Connect`.
6. For **Provider URL**, enter:

```text
https://token.actions.githubusercontent.com
```

7. For **Audience**, enter:

```text
sts.amazonaws.com
```

8. Review the values.
9. Click **Add provider**.

### What success looks like

After saving, you should see an identity provider whose URL is:

```text
token.actions.githubusercontent.com
```

That tells AWS that GitHub Actions may present OIDC tokens to request temporary credentials.

### Beginner notes

- You only need to do this once per AWS account.
- If you have multiple AWS accounts, you must create the provider in the exact account where your deploy role lives.
- If you skip this step, `aws-actions/configure-aws-credentials` cannot assume your role.

## 5.3 Create an IAM policy for EC2 security group access

The GitHub workflow needs permission to temporarily add and remove an SSH ingress rule.

### Step-by-step in AWS Console

1. In **IAM**, click **Policies**.
2. Click **Create policy**.
3. Open the **JSON** tab.
4. Paste this starter policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ManageDeploySshIngress",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*"
    }
  ]
}
```

5. Click **Next**.
6. Give the policy a clear name, for example:

```text
PalakatGithubActionsSecurityGroupDeployPolicy
```

7. Optionally add a description explaining that it is used by GitHub Actions to temporarily manage SSH ingress during backend deployment.
8. Click **Create policy**.

### Beginner notes

- This policy only covers security group updates.
- It does not give full EC2 administration rights.
- `Resource: "*"` is acceptable for a first working setup. You can tighten it later if you want.

## 5.4 Create an IAM role for GitHub Actions

This is the role your GitHub workflow will assume using OIDC.

### Step-by-step in AWS Console

1. In **IAM**, click **Roles**.
2. Click **Create role**.
3. For the trusted entity type, choose **Web identity**.
4. For the identity provider, choose the GitHub provider you just created:

```text
token.actions.githubusercontent.com
```

5. For **Audience**, choose or enter:

```text
sts.amazonaws.com
```

6. Continue to the next step.
7. Attach the policy you created in section 5.3.
8. Continue to the naming step.
9. Give the role a clear name, for example:

```text
github-actions-palakat-deploy
```

10. Create the role.

At this point, the role exists, but you still need to tighten its trust relationship so only your repository is allowed to assume it.

## 5.5 Edit the IAM role trust policy so only your repo can use it

After creating the role:

1. Open the new role.
2. Go to the **Trust relationships** tab.
3. Click **Edit trust policy**.
4. Replace the policy with a repository-scoped version.

### Example trust policy for the `main` branch

Replace:

- `123456789012` with your real AWS account ID
- `meimodev/palakat` with your actual GitHub owner/repo if different

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:meimodev/palakat:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### What this means

This policy says:

- trust GitHub's OIDC provider
- allow OIDC role assumption
- only if the GitHub token came from the `meimodev/palakat` repo
- only if the workflow was running from branch `main`

### If you use GitHub Environments

If your production deploy uses a GitHub Environment such as `production`, then this version is often better:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:meimodev/palakat:environment:production"
        }
      }
    }
  ]
}
```

Use this version only if the deployment job actually runs under that GitHub Environment.

## 5.6 Copy the role ARN into GitHub as `AWS_ROLE_TO_ASSUME`

After the role is created:

1. Open the IAM role details page.
2. Copy the **Role ARN**.

It will look similar to this:

```text
arn:aws:iam::123456789012:role/github-actions-palakat-deploy
```

3. In GitHub, open your repository.
4. Go to **Settings**.
5. Go to **Secrets and variables**.
6. Open **Actions**.
7. Create either a repository variable or secret named:

```text
AWS_ROLE_TO_ASSUME
```

8. Paste the copied role ARN as the value.

This is the exact value used by the workflow step:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.AWS_ROLE_TO_ASSUME || secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: ${{ vars.AWS_REGION || secrets.AWS_REGION }}
```

If the ARN in GitHub does not exactly match the real IAM role ARN in AWS, the workflow will fail.

## 5.7 Beginner end-to-end checklist for the AWS side

Use this quick checklist before rerunning GitHub Actions:

1. The AWS account contains an OIDC provider for:

```text
https://token.actions.githubusercontent.com
```

2. The IAM role exists.
3. The IAM role has the EC2 security group policy attached.
4. The role trust policy points at the GitHub OIDC provider.
5. The trust policy `sub` matches your repo and branch or environment.
6. GitHub has `AWS_ROLE_TO_ASSUME` set to the real role ARN.
7. GitHub has `AWS_REGION` set.
8. Your workflow includes:

```yaml
permissions:
  contents: read
  id-token: write
```

## 5.8 Most common beginner mistakes

- creating the OIDC provider in the wrong AWS account
- creating the role in one account but storing an ARN from another account in GitHub
- forgetting to attach the EC2 security group policy to the role
- using a trust policy for the wrong repo name
- using a branch-based trust policy while running the workflow from a different branch
- using an environment-based trust policy without actually configuring the job to use that GitHub Environment
- storing `AWS_ROLE_TO_ASSUME` or `AWS_REGION` under the wrong GitHub setting and leaving the value empty at runtime

---

# 6. Why OIDC is preferred over static AWS keys

Using GitHub OIDC is better than storing long-lived AWS access keys in GitHub because:

- AWS credentials are temporary.
- You can restrict trust to one repository, branch, or environment.
- You do not need to rotate static AWS keys stored in GitHub secrets.
- A compromised GitHub secret does not automatically expose permanent AWS credentials.

---

# 7. Workflow permissions required by GitHub Actions

Your workflow must allow GitHub to issue an OIDC token.

At minimum, include:

```yaml
permissions:
  contents: read
  id-token: write
```

Without `id-token: write`, the workflow cannot assume the AWS IAM role via OIDC.

---

# 8. Example workflow pattern

Below is a minimal pattern showing the AWS setup, temporary SSH allowlisting, deploy, and cleanup.

```yaml
name: Deploy Palakat Backend

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_TO_ASSUME }}
          aws-region: ${{ vars.AWS_REGION }}

      - name: Get runner public IP
        id: runner_ip
        run: |
          IP=$(curl -fsS https://checkip.amazonaws.com | tr -d '\n')
          echo "ip=$IP" >> "$GITHUB_OUTPUT"

      - name: Allow runner IP in EC2 security group
        run: |
          aws ec2 authorize-security-group-ingress \
            --region "${{ vars.AWS_REGION }}" \
            --group-id "${{ vars.EC2_SECURITY_GROUP_ID }}" \
            --protocol tcp \
            --port "${{ vars.EC2_PORT }}" \
            --cidr "${{ steps.runner_ip.outputs.ip }}/32"

      - name: Upload artifact to EC2
        uses: appleboy/scp-action@v0.1.7
        with:
          host: ${{ vars.EC2_HOST }}
          username: ${{ vars.EC2_USER }}
          key: ${{ secrets.EC2_SSH_PRIVATE_KEY }}
          passphrase: ${{ secrets.EC2_SSH_PASSPHRASE }}
          port: ${{ vars.EC2_PORT }}
          source: "palakat_backend_release.tar.gz"
          target: "/tmp"

      - name: Deploy on EC2
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ vars.EC2_HOST }}
          username: ${{ vars.EC2_USER }}
          key: ${{ secrets.EC2_SSH_PRIVATE_KEY }}
          passphrase: ${{ secrets.EC2_SSH_PASSPHRASE }}
          port: ${{ vars.EC2_PORT }}
          script_stop: true
          script: |
            set -euo pipefail
            echo "Replace this with your real deploy commands"

      - name: Revoke runner IP from EC2 security group
        if: always()
        run: |
          aws ec2 revoke-security-group-ingress \
            --region "${{ vars.AWS_REGION }}" \
            --group-id "${{ vars.EC2_SECURITY_GROUP_ID }}" \
            --protocol tcp \
            --port "${{ vars.EC2_PORT }}" \
            --cidr "${{ steps.runner_ip.outputs.ip }}/32"
```

---

# 9. How the key workflow steps work

## 9.1 Configure AWS credentials

This step exchanges the GitHub OIDC identity for temporary AWS credentials using the IAM role you created.

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.AWS_ROLE_TO_ASSUME }}
    aws-region: ${{ vars.AWS_REGION }}
```

## 9.2 Detect the current runner IP

This fetches the public egress IP address of the GitHub-hosted runner.

```yaml
- name: Get runner public IP
  id: runner_ip
  run: |
    IP=$(curl -fsS https://checkip.amazonaws.com | tr -d '\n')
    echo "ip=$IP" >> "$GITHUB_OUTPUT"
```

The output is later used as a `/32` CIDR.

## 9.3 Temporarily allow SSH from that IP

This opens only the exact runner IP to the target security group.

```yaml
- name: Allow runner IP in EC2 security group
  run: |
    aws ec2 authorize-security-group-ingress \
      --region "${{ vars.AWS_REGION }}" \
      --group-id "${{ vars.EC2_SECURITY_GROUP_ID }}" \
      --protocol tcp \
      --port "${{ vars.EC2_PORT }}" \
      --cidr "${{ steps.runner_ip.outputs.ip }}/32"
```

## 9.4 Upload and deploy

Once the security group rule exists, SSH and SCP should be able to reach the instance on the configured port.

## 9.5 Always remove the temporary rule

Use `if: always()` so the cleanup runs even if the deployment fails halfway through.

```yaml
- name: Revoke runner IP from EC2 security group
  if: always()
  run: |
    aws ec2 revoke-security-group-ingress \
      --region "${{ vars.AWS_REGION }}" \
      --group-id "${{ vars.EC2_SECURITY_GROUP_ID }}" \
      --protocol tcp \
      --port "${{ vars.EC2_PORT }}" \
      --cidr "${{ steps.runner_ip.outputs.ip }}/32"
```

---

# 10. Optional improvement: avoid passphrase handling in CI

If you do not want to manage `EC2_SSH_PASSPHRASE`, use a dedicated deployment key with no passphrase.

Example:

```bash
ssh-keygen -t ed25519 -N "" -C "github-actions-deploy" -f palakat_backend_deploy_key
```

Then:

- store the private key as `EC2_SSH_PRIVATE_KEY`
- remove `passphrase:` from your workflow steps

This is usually simpler for CI/CD.

---

# 11. Recommended production hardening

After the basic flow is working, consider these improvements:

- use a dedicated GitHub Environment like `production`
- protect the environment with required reviewers
- restrict the IAM trust policy to that environment
- use a dedicated deploy SSH user instead of a default AMI user
- use a dedicated deploy SSH key rather than a personal key
- keep the EC2 security group otherwise locked down
- ensure the cleanup rule is always executed

---

# 12. Common failure modes and how to debug them

## 12.1 `AccessDenied` when configuring AWS credentials

Likely causes:

- missing `id-token: write`
- wrong IAM trust policy
- wrong `AWS_ROLE_TO_ASSUME`
- mismatch between repo, branch, or environment and the trust policy `sub`

## 12.2 `UnauthorizedOperation` or EC2 permission errors

Likely causes:

- IAM role is missing one of these permissions:
  - `ec2:AuthorizeSecurityGroupIngress`
  - `ec2:RevokeSecurityGroupIngress`
  - `ec2:DescribeSecurityGroups`

## 12.3 SSH still times out after adding the SG rule

Likely causes:

- wrong `EC2_HOST`
- wrong `EC2_PORT`
- wrong `EC2_SECURITY_GROUP_ID`
- the security group you updated is not attached to the instance
- OS firewall like `ufw` still blocks the port
- SSH daemon is not listening on the configured port

Useful server-side checks:

```bash
sudo systemctl status ssh --no-pager
sudo ss -ltnp | grep ssh
sudo ufw status
curl -4 ifconfig.me
```

## 12.4 SSH reaches the instance but login fails

Likely causes:

- wrong `EC2_USER`
- wrong private key
- matching public key not installed in `authorized_keys`
- wrong passphrase for encrypted private key

## 12.5 Cleanup step fails because the rule does not exist

This can happen on reruns or if the authorize step failed before the rule was created.

You can keep the current simple approach initially, then make the cleanup more defensive later if needed.

---

# 13. Quick verification checklist

Before running the workflow, verify all of the following:

- the AWS OIDC identity provider exists
- the IAM role exists and has the correct trust policy
- the IAM role has EC2 security group permissions
- `AWS_ROLE_TO_ASSUME` is the correct ARN
- `AWS_REGION` matches the EC2 instance region
- `EC2_SECURITY_GROUP_ID` is attached to the target instance
- `EC2_HOST` points to the correct public IP or DNS name
- `EC2_PORT` matches the active SSH port
- `EC2_USER` matches the Linux account with the installed public key
- `EC2_SSH_PRIVATE_KEY` matches that public key
- `EC2_SSH_PASSPHRASE` is set if the key is encrypted
- the workflow includes `permissions.id-token: write`

---

# 14. Recommended final variable and secret layout

## GitHub variables

- `AWS_REGION`
- `AWS_ROLE_TO_ASSUME`
- `EC2_SECURITY_GROUP_ID`
- `EC2_HOST`
- `EC2_PORT`
- `EC2_USER`

## GitHub secrets

- `EC2_SSH_PRIVATE_KEY`
- `EC2_SSH_PASSPHRASE` if required

---

# 15. Final recommendation

For Palakat backend deployments from GitHub-hosted runners, the recommended implementation is:

- use GitHub OIDC to assume an AWS IAM role
- temporarily allow the current runner IP in the EC2 security group
- deploy via SSH/SCP
- always revoke the temporary security group rule afterward

This gives you a practical middle ground between fully open SSH and more complex alternatives like self-hosted runners or AWS SSM-based deployment.
