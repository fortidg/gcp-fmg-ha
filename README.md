# GCP FortiManager High Availability (Dual Zone) Deployment

## How do you run these?

1. Log into GCP console and open a cloud shell.
1. Clone this repository to your local environment.
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required variables:
   - `project` - Your GCP project ID
   - `region` - GCP region (e.g., us-central1)
   - `zone` - Primary zone (e.g., us-central1-a)
   - `zone2` - Secondary zone (e.g., us-central1-b)
   - `prefix` - Prefix for all resources
   - `fortimanager_vm_image` - FortiManager VM image
   - `fortimanager_machine_type` - VM instance type
1. Run `terraform init`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.

### Licensing

There are three options for licensing the FortiManager VMs:

"flex" (default) - Set license_type to "flex" and add two unused FortiFlex tokens to the "flex_tokens" variable. Ensure you are using the BYOL FortiManager image. For Example:

```sh
flex_tokens = ["C5095E394QAZ3E640112", "DC65640C2QAZDD9CBC76"]
```

"byol" - Set license_type to "byol" and copy two valid FortiManager licenses into the local directory. Ensure you are using the BYOL FortiManager image. Update terraform.tfvars with the names of the licenses. For example:

```sh
fortimanager_license_files = {
  fmg1_instance = { name = "license1.lic" }
  fmg2_instance = { name = "license2.lic" }
}
```

"payg" - Set license_type to "payg" and ensure that you are using the PAYG FortiManager Image

If you wish to deploy FortiManager instances in only one zone, you can use the same value for "zone" and "zone2".

FortiManager instances can be managed by putting the URLs from the Terraform outputs into the url bar of your favorite browser. These IP addresses will be part of the Terraform outputs upon using apply:

- FortiManager 1: `https://<fmg1-public-ip>`
- FortiManager 2: `https://<fmg2-public-ip>`

## Architecture

This Terraform configuration deploys:

- Two FortiManager instances in different availability zones for high availability
- A VPC network with a single subnet
- External IP addresses for each FortiManager instance
- Internal IP addresses for communication
- Additional storage disks for logging
- Firewall rules for management access

## Outputs

After deployment, the following outputs will be available:

- `fmg1_ip` - HTTPS URL for FortiManager 1
- `fmg2_ip` - HTTPS URL for FortiManager 2  
- `fmg_password` - Admin password for both instances
- Instance IDs for both FortiManager VMs