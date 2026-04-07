inputs = {

}
#Private subnets will include ALB listener subnets (ENI), Workloads subnets & TGW subnets
remote_state {
  backend = "s3"
  config = {
    bucket                          = "s3bucket"
    region                          = "ap-southeast-2"
    key                             = "statefiles/corestate"
    encrypt                         = true
  }
}
