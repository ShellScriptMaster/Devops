# cidr-block-obj = [
#     {cidr_block = "192.168.0.0/16", name = "development-vpc"},
#     {cidr_block = "192.168.8.0/24", name = "dev-subnet-2"}
#     ]

dev-cidr-block-obj = [
    {cidr-block = "192.168.0.0/16", name = "vpc-cidr-block"},
    {cidr-block = "192.168.4.0/24" , name = "dev-subnet" }
]

instance_info = [
    {instance_name = "ins-dev-ecs-0" , host_name = "master",  private_ip = "192.168.4.10"} ,
    {instance_name = "ins-dev-ecs-1" , host_name = "worknode-1", private_ip = "192.168.4.11"},
    {instance_name = "ins-dev-ecs-2" , host_name = "worknode-2", private_ip = "192.168.4.12"},
    {instance_name = "ins-dev-ecs-3" , host_name = "worknode-3", private_ip = "192.168.4.13"}    
]