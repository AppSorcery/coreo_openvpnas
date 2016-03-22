## This file was auto-generated by CloudCoreo CLI
## This file was automatically generated using the CloudCoreo CLI
##
## This config.rb file exists to create and maintain services not related to compute.
## for example, a VPC might be maintained using:
##
## coreo_aws_vpc_vpc "my-vpc" do
##   action :sustain
##   cidr "12.0.0.0/16"
##   internet_gateway true
## end
##


coreo_aws_vpc_vpc "${VPC_NAME}" do
  action :find
  cidr "${VPC_OCTETS}/16"
end

coreo_aws_vpc_routetable "${PRIVATE_ROUTE_NAME}" do
  action :find
  vpc "${VPC_NAME}"
  number_of_tables 3
  tags [
        "Name=${PRIVATE_ROUTE_NAME}"
       ]
end

coreo_aws_vpc_routetable "${PUBLIC_ROUTE_NAME}" do
  action :find
  vpc "${VPC_NAME}"
end

coreo_aws_vpc_subnet "${PUBLIC_SUBNET_NAME}" do
  action :find
  route_table "${PUBLIC_ROUTE_NAME}"
  vpc "${VPC_NAME}"
end

coreo_aws_ec2_securityGroups "${VPN_NAME}-elb-sg" do
  action :sustain
  description "Open vpn and https to the world"
  vpc "${VPC_NAME}"
  allows [ 
          { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [1199],
            :cidrs => ${VPN_ACCESS_CIDRS},
          },{ 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [443],
            :cidrs => ${VPN_ACCESS_CIDRS},
          },{ 
            :direction => :egress,
            :protocol => :tcp,
            :ports => ["0..65535"],
            :cidrs => ${VPN_ACCESS_CIDRS},
          }
    ]
end

coreo_aws_ec2_elb "${VPN_NAME}-elb" do
  action :sustain
  type "public"
  vpc "${VPC_NAME}"
  subnet "${PUBLIC_SUBNET_NAME}"
  security_groups ["${VPN_NAME}-elb-sg"]
  listeners [
             {
               :elb_protocol => 'tcp', 
               :elb_port => 1199, 
               :to_protocol => 'tcp', 
               :to_port => 1199
             },
             {
               :elb_protocol => 'tcp', 
               :elb_port => 443, 
               :to_protocol => 'tcp', 
               :to_port => 443
             }
            ]
  health_check_protocol 'tcp'
  health_check_port "1199"
  health_check_timeout 5
  health_check_interval 120
  health_check_unhealthy_threshold 5
  health_check_healthy_threshold 2
end

coreo_aws_route53_record "${VPN_DNS_PREFIX}" do
  action :sustain
  type "CNAME"
  zone "${DNS_ZONE}"
  values ["STACK::coreo_aws_ec2_elb.${VPN_NAME}-elb.dns_name"]
end

coreo_aws_ec2_securityGroups "${VPN_NAME}-sg" do
  action :sustain
  description "Open vpn connections to the world"
  vpc "${VPC_NAME}"
  allows [ 
          { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [443],
            :groups => ["${VPN_NAME}-elb-sg"],
          },{ 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [1199],
            :groups => ["${VPN_NAME}-elb-sg"],
          },{ 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [22],
            :cidrs => ${VPN_SSH_ACCESS_CIDRS},
          },{ 
            :direction => :egress,
            :protocol => :tcp,
            :ports => ["0..65535"],
            :cidrs => ["0.0.0.0/0"],
          }
    ]
end

coreo_aws_ec2_instance "${VPN_NAME}" do
  action :define
  upgrade_trigger "1"
  image_id "${VPN_AMI_ID}"
  size "${VPN_INSTANCE_TYPE}"
  security_groups ["${VPN_NAME}-sg"]
  ssh_key "${VPN_SSH_KEY_NAME}"
  role "${VPN_NAME}"
end

coreo_aws_ec2_autoscaling "${VPN_NAME}" do
  action :sustain 
  minimum 1
  maximum 1
  server_definition "${VPN_NAME}"
  subnet "${PRIVATE_SUBNET_NAME}"
  elbs ["${VPN_NAME}-elb"]
end
