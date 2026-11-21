# Select an account-specific configuration explicitly; do not infer a missing file name.
include "account" {
  path = get_env("TG_ACCOUNT_CONFIG")
}
