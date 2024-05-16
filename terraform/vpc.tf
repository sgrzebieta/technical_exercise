module "vpc" {
    source       = "terraform-google-modules/network/google"

    project_id   = var.project_id
    network_name = "wiz-tc-vpc"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name   = "subnet-01"
            subnet_ip     = "10.10.0.0/17"
            subnet_region = var.region
        },
        {
            subnet_name   = "subnet-02"
            subnet_ip     = "10.20.10.0/24"
            subnet_region = var.region
        },
    ]

    secondary_ranges = {
        subnet-01 = [
            {
                range_name    = "subnet-01-secondary-01"
                ip_cidr_range = "10.30.0.0/18"
            },
            {
                range_name    = "subnet-01-secondary-02"
                ip_cidr_range = "10.40.0.0/18"
            },
        ]
        subnet-02 = [            {
                range_name    = "subnet-03-secondary-03"
                ip_cidr_range = "10.20.20.0/24"
            },
        ]
    }

    routes = [
        {
            name              = "egress-internet"
            description       = "route through IGW to access internet"
            destination_range = "0.0.0.0/0"
            tags              = "egress-inet"
            next_hop_internet = "true"
        },
    ]
}