# HPCS terraform module

This is a collection of modules that make it easier to provision and manage HPCS Instance IBM Cloud Platform:

HPCS module provision: 
* HPCS instance 
* HPCS initialization 
* Create creats KMS key
* Configure HPCS Network, Dual Deletion Authorization and Key rotation policy.

## hpcs_instance module

This module creates new HPCS instance if `provision` flag is `true` otherwise get the guid of exiting HPCS intance matching with the provided service name.

## download_from_cos module

This module download the `input.json` file from COS bucket to use input for the HPCS instance initialization.

## hpcs_init module

The main components of this module are..

- **COS Bucket**: HPCS Crypto unit credentials that stored in a Bucket as a json file will be taken as an input by `hpcs-init` terraform module and the secret tke-files that are obtained after execution of template will be stored back as zip file in cos bucket.
- **Terraform**: Reads the terraform configuration files and templates, execute the plan, and communicate with the plugins, manages the resource state and .tfstate file after apply.
- **IBM Cloud TKE Plugin**: The Python script that automates the initialisation process uses IBM CLOUD TKE Plugin

This module initialize the HPCS instance if `initialize` flag is `true` and use the `input.json` file to configure the instance.

## upload_to_cos module

This module uplaode the signature key files for HPCS admins to the provided COS bucket.

## ibm-hpcs-kms-key module

This module creates kms key along with key rotation policy.

## Null resources

The null resources are used to enable the HPCS Network, Dual Deletion Authorization and key rotation policies.

## Terraform versions

Terraform 0.13.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources. This command zeroises the cryptounit.. to remove master keys and signature keys, Use following commands respectively `ibmcloud tke mk-rm` , `ibmcloud tke sigkey-rm`
Please refer `ibmcloud tke help` for more info.

Note: 
* COS Credententials are required when `download_from_cos` and `upload_to_cos` null resources are used
* Cloud TKE Files will be downloaded at `tke_files_path`+` < GUID of the Service Instance >_tkefiles`. To perform any operation after initialisation on tkefiles outside terraform `CLOUDTKEFILES` should be exported to above mentioned path

## Pre-Requisites for Initialisation:
* python version 3.5 and above
* pip version 3 and above

``` hcl 
  pip install pexpect
```
* `ibm-cos-sdk` package is required if initialisation is performed using objeck storage example..
``` hcl 
pip install ibm-cos-sdk
```
* Login to IBM Cloud Account using cli 
```hcl 
ibmcloud login --apikey `<XXXYourAPIKEYXXXXX>` -r `<region>` -g `<resource_group>` -a `< cloud endpoint>
```
* Generate oauth-tokens `ibmcloud iam oauth-tokens`. This step should be done as and when token expires. 
* To install tke plugin `ibmcloud plugin install tke`. find more info on tke plugin [here](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-initialize-hsm#initialize-crypto-prerequisites) 

## Notes On Initialization:
* The current script adds only one signature key admin.
* The signature key associated with the Admin name given in the json file will be selected as the current signature key.
* If number of master keys added is more than three, Master key registry will be `loaded`, `commited` and `setimmidiate` with last three added master keys.
* Please find the example json [here](references/input.json).
* Input can be fed in two ways either through local or through IBM Cloud Object Storage
* The input file is download from the cos bucket using `download_from_cos` null resource
* Secret TKE Files that are obtained after initialisation can be stored back in the COS Bucket as a Zip File using `upload_to_cos`null resource
* After uploading zip file to COS Bucket all the secret files and input file can be deleted from the local machine using `remove_tke_files` null resource.

## Future Enhancements:
* Capability to add and select one or more admin.

