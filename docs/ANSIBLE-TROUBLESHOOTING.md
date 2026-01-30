# Resolving Ansible “No start of JSON char” on Amazon Linux 2

## Summary

Ansible module execution failed with:

```
No start of json char found
```

while `raw` commands continued to work.

This issue occurred when managing **Amazon Linux 2 (AL2)** hosts using **modern Ansible (2.19+)** and was caused by a combination of:

* **SSH stdout pollution** on the remote host
* **Python version incompatibility** with Ansible Core

## Root Causes

### 1. SSH Stdout Pollution (Primary Cause)

Amazon Linux 2 injects non-JSON output into SSH sessions, including:

* MOTD banners
* “Last login” messages
* Dynamic update notices

Ansible modules **require clean JSON output** over SSH.
Any additional text breaks Ansible’s module result deserialization, leading to:

```
No start of json char found
```

### 2. Python Version Incompatibility (Secondary Cause)

* Amazon Linux 2 defaults to **Python 3.7**
* Ansible **2.19+ requires Python ≥ 3.8**
* Result: module execution crashes with silent `SyntaxError`s

This failure happens *before* Ansible can return structured error output.

## Step 1 — Silence the Remote Shell (Using `raw`)

Because Python-based modules were failing, the **Ansible `raw` module** was required to bypass Python entirely and fix the host at the shell level.

```bash
# Skip user login banners
ansible web -m raw -a "touch ~/.hushlogin"

# Remove Amazon Linux dynamic MOTD banner
ansible web -m raw -a "sudo rm -f /usr/lib/motd.d/30-banner"

# Disable MOTD and LastLog in SSH daemon
ansible web -m raw -a "sudo sed -i 's/^#\\?PrintMotd.*/PrintMotd no/' /etc/ssh/sshd_config"
ansible web -m raw -a "sudo sed -i 's/^#\\?PrintLastLog.*/PrintLastLog no/' /etc/ssh/sshd_config"

# Restart SSH to apply changes
ansible web -m raw -a "sudo systemctl restart sshd"
```

**Why this works**

* `raw` sends commands directly over SSH
* No Python interpreter is required
* This is the only reliable way to “break in” to a noisy AL2 host

## Step 2 — Install a Compatible Python Version (3.8)

Modern Ansible Core uses Python features unavailable in Python 3.7.

```bash
ansible web -m raw -a "sudo amazon-linux-extras install python3.8 -y"
```

This ensures compatibility with:

* Ansible Core ≥ 2.19
* Modern Ansible modules and syntax

## Step 3 — Configure `ansible.cfg`

To make the fix permanent and consistent, an explicit `ansible.cfg` is required.

```ini
[defaults]
inventory = ./inventory.ini
remote_user = ec2-user

# Force compatible Python version
interpreter_python = /usr/bin/python3.8

# Required for ephemeral / sandbox EC2 hosts
host_key_checking = False
allow_world_readable_tmpfiles = True

[ssh_connection]
# Reduces SSH round-trips and prevents stdout corruption
pipelining = True
```

### Why these settings matter

* **`interpreter_python`**
  Prevents Ansible from auto-selecting Python 3.7 on AL2

* **`pipelining = True`**
  Reduces SSH operations and minimizes chances of banner noise corrupting output

* **`host_key_checking = False`**
  Essential for sandbox environments where EC2 instances are frequently recreated

## Step 4 — Production-Grade Bootstrap Playbook

To make this repeatable, the fixes were consolidated into a dedicated **bootstrap playbook**.

### `bootstrap.yml` (Final Version)

```yaml
---
- name: Bootstrap sandbox EC2
  hosts: web
  gather_facts: false  # Python not ready yet

  tasks:
    - name: Bootstrap host (Python 3.8 + clean SSH output)
      raw: |
        set -e

        # 1. Install Python 3.8 (required for modern Ansible)
        sudo amazon-linux-extras install python3.8 -y || true

        # 2. Silence login banners (user + root)
        touch ~/.hushlogin
        sudo touch /root/.hushlogin

        # Remove Amazon Linux dynamic banner
        sudo rm -f /usr/lib/motd.d/30-banner

        # 3. Disable MOTD and LastLog in SSH daemon
        sudo sed -i 's/^#\?PrintMotd.*/PrintMotd no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?PrintLastLog.*/PrintLastLog no/' /etc/ssh/sshd_config

        # 4. Apply SSH changes
        sudo systemctl restart sshd
```

### Why this is production-grade

* `raw + gather_facts: false` — required for first contact
* `set -e` — fail fast on real errors
* `|| true` — avoids amazon-linux-extras false negatives
* Full banner silencing (hushlogin + MOTD + sshd)
* Safe to run once per host before configuration

---

## Step 5 — Verification

After bootstrapping, standard Ansible modules should work normally:

```bash
ansible web -m setup
```

Expected result:

* Clean JSON output
* No deserialization errors
* Facts successfully gathered

## Key Takeaway

> If `raw` works but `setup` fails, the issue is **almost never Ansible itself**.
>
> It is almost always:
>
> * SSH stdout pollution
> * or Python incompatibility on the remote host

Separating **bootstrap** from **configuration** is the correct, professional solution.
