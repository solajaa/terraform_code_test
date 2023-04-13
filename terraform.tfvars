vpc_cidr = "11.0.0.0/16"
vpc_cidr2 = "12.0.0.0/16"
env_prefix = "dev"
region = "us-east-1"
vpc_id ="aws_vpc.policy_test.id"
ami = "ami-06e46074ae430fba6"
instance_type = "t2.micro"
ec2_count = "2"
#web_tags = "map{strings}"
app_s3 = "adgear-test"
my_ip = "70.27.32.123/32"
domain_name = "alpha1pm.com"
bucket_name = "alpha1pm.com"

common_tags = {
  Project =" codetest"
}
username = [ "adgeartest1", "adgeartest2", "adgeartest3" ]

