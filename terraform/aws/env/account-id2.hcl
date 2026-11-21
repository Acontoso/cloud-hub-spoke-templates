# Alternative account/environment scaffold; select using TG_ACCOUNT_CONFIG.
# Set TF_STATE_KEY to an environment-specific path when sharing an account.
inputs = {}

remote_state {
  backend = "s3"
  config = {
    bucket       = get_env("TF_STATE_BUCKET")
    region       = get_env("TF_STATE_REGION", "ap-southeast-2")
    key          = get_env("TF_STATE_KEY", "hub-spoke/aws/${get_aws_account_id()}/terraform.tfstate")
    encrypt      = true
    use_lockfile = true
  }
}
