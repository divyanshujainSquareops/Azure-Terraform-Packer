## To connect terraform project to azure

create app rezistery = default directory->add->app-rezistery(terraform-first-project)->copy (clientid,client_secret(create certifiacate and secrets),tenent_Id)
create terraform file(main.tf)
add terraform to you subscription=subscription->add role assignment->contributor->select member->add terraform-project

## basics of terraform
Terraform=
why is best=infrastructure as code,multiinfra-onecode use

ansible vc terr=terra maintain a stage of infra,terra can delete and create infra immediatley (but in ansible you have to write new file)
when you have to build infra use terra then you have to configure infra you have to use ansible

tfstate file=it save your resource information,never try to change manually in this file.

extention=.tf,.tf.json
run terraform file=terraform plan

.labels should be diffrent
. in terraform , it follow alphabetical order in multifile system.

terraform plan=it scan all configuration file in tera infra and analyze what to do by terra in this project.it describe infra diffrence b/w tfstate and configuration file.

terraform TFVARS= save variable in one file, terraform  read variable values from this file, extetnion= "<name>.tfvars
pass custom tfvars file=terraform plan -var-file=custom.tfvars (default file= terraform.vars)


terraform-providers=github
terraform providers=give providers name
terraform init= install all  
terraform apply=run the terraform file and build infra
terraform apply --auto-approve=it take yes autmatic
terraform destroy=it destroy resource according to" tfstate file"
terraform refresh=rescan all the resources and its properties
terraform console=it start console
terraform fmt=for proper indentation
