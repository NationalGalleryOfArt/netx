# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains integration scripts, configurations, and utilities for the National Gallery of Art's NetX digital asset management system. The primary integrations include:

- TMS (The Museum System) metadata synchronization
- SAML authentication configuration  
- Application log monitoring
- Integration with Adobe AEM and IIIF Image Server (IIP Image)

## Architecture

The repository is organized into three main deployment domains:

### Server Environment Structure
- **Development**: `dev`, `devapp`, `devutil` environments
- **Test**: `test`, `testapp`, `testutil` environments  
- **Production**: `prod`, `prodapp`, `produtil` environments

Server mappings are defined in `netx_servers.config` using associative arrays.

### Core Components

1. **Auto Tasks** (`auto_tasks/`):
   - `syncedMetadata.xml`: Template for TMS metadata synchronization configuration
   - `deploy_all_tms_autotasks_to_netx.bash`: Deployment script for TMS auto tasks
   - `tasks-to-deploy/`: Contains XML task definitions (TMSClearAttributes.xml, TMSDataSyncAutoTask.xml)

2. **SAML Integration** (`saml/`):
   - `samlServices.xml`: SAML authentication service configuration
   - `deploy_saml_config.bash`: SAML configuration deployment script
   - Certificate management scripts for NGA ADFS integration

3. **Log Monitor** (`logmonitor/`):
   - `applogmonitor.config`: Application log monitoring configuration
   - `deploy_logmonitor_config.bash`: Log monitor deployment script

## Common Commands

### Deployment Commands

**Deploy TMS Auto Tasks:**
```bash
cd auto_tasks/
./deploy_all_tms_autotasks_to_netx.bash [environment]
```

**Deploy SAML Configuration:**
```bash
cd saml/
./deploy_saml_config.bash [environment]
```

**Deploy Log Monitor Configuration:**
```bash
cd logmonitor/
./deploy_logmonitor_config.bash [environment]
```

**Distribute SSH Public Key:**
```bash
./distribute_ssh_key.bash [environment]
```

**Environment Options:**
- `dev`, `devapp`, `devutil`
- `test`, `testapp`, `testutil` 
- `prod`, `prodapp`, `produtil`

### Authentication & Security

All deployment scripts require:
- Running as the `netx` user (scripts will sudo if needed)
- Access to configuration files in `/usr/local/nga/etc/`
- SSH access to target servers
- NetX API credentials for auto task deployment

**SSH Key Setup:**
Use `distribute_ssh_key.bash` to install the netx user's SSH public key on target servers for passwordless authentication. This enables SCP operations in deployment scripts without password prompts.

## Key Configuration Files

- `netx_servers.config`: Server environment mappings
- `auto_tasks/syncedMetadata.xml`: TMS database sync template with placeholders for credentials
- `saml/samlServices.xml`: SAML service provider configuration for NGA ADFS
- External configs: `/usr/local/nga/etc/tmsprivateextract.conf`, `/usr/local/nga/etc/netxapi.conf`

## Security Notes

- Database connection strings and API credentials are stored in external config files
- SAML certificates are managed separately and deployed alongside configuration
- All deployment requires proper SSH key authentication to target servers
- Scripts include error handling and validation for critical operations