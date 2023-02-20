#!/bin/sh

print_running_neeto_audit() {
  cat <<EOT
======================================================================================
Running:

  bundle exec neeto-audit
======================================================================================
EOT
}

verify_neeto_audit() {
  print_running_neeto_audit

  bundle exec neeto-audit
}

