## Steps :-
1. Create AMI with packer =
  commands =
            -> packer validate
            -> packer build configuration.json

<img width="893" alt="image" src="https://github.com/divyanshujainSquareops/Terraform-Create-Vnet-VM-Packer-Ami/assets/148210383/2ac8f69b-eb27-445c-a86e-b586c4a96519">

<img width="955" alt="image" src="https://github.com/divyanshujainSquareops/Terraform-Create-Vnet-VM-Packer-Ami/assets/148210383/f92fb2a6-2e02-4d63-9f88-f7abee8aef18">


2. Create terraform file for create resources
   Create resource group
   Create security group
   Create Virtual network and subnet
   Create Network interface
   Create one public Ip
   Create Virtual machine with packer image


![image](https://github.com/divyanshujainSquareops/Terraform-Create-Vnet-VM-Packer-Ami/assets/148210383/65f1e976-aa31-4372-ab8d-a7a83a88eb30)

3. Hit the public Ip and you see running apache server


<img width="956" alt="image" src="https://github.com/divyanshujainSquareops/Terraform-Create-Vnet-VM-Packer-Ami/assets/148210383/5134c7fa-f1ea-4b6f-af18-8b59a664ae7e">

