default["jenkins"]["plugin_manager_version"] = "2.13.0"
# SHA-256 of the jar of each version. A local jar that matches it is not
# downloaded again. For a version missing here, every run asks the server
# for the jar.
default["jenkins"]["plugin_manager_checksums"] = {
  "2.13.0" => "ced30bcaa33209478ad43a6f02e5e217415a1f3a37b28d2d044db7b3e96004e5",
}
