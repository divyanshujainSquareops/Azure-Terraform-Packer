## terraform init

<img width="402" alt="image" src="https://github.com/divyanshujainSquareops/Azure-Terraform-Packer/assets/148210383/a3258c8a-f84a-4bf6-974c-922d9baec6a6">


## terraform validate

<img width="459" alt="image" src="https://github.com/divyanshujainSquareops/Azure-Terraform-Packer/assets/148210383/ec25a2d9-fc68-48a7-a4b1-b567558aed07">


##  terraform plan -out tfplan 

<img width="862" alt="image" src="https://github.com/divyanshujainSquareops/Azure-Terraform-Packer/assets/148210383/fa3b3943-be09-43ef-92ce-895141a6ce4c">


## Terraform apply 


<img width="717" alt="image" src="https://github.com/divyanshujainSquareops/Azure-Terraform-Packer/assets/148210383/fdd8c25d-216c-46c4-9dfd-f7c8f1596690">


<img width="884" alt="image" src="https://github.com/divyanshujainSquareops/Azure-Terraform-Packer/assets/148210383/43286cbe-6c6a-41c4-8ccd-b636aec024bf">

## Keep following service pre-created
1. resource grouop=Squareops
2. azure storage = tfstate214154
  a. container=tfstate (use to save tfstate file for backup)
  b. file share=terraformwordpressfileshare  (use linux scrpit in wordpress ami packer)
3. azure key vault=save secrets of mysq-db
  username=wpuser
  password=Deepu@123#
  databasename=wordpressdb

