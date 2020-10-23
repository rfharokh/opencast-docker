#!/bin/sh
#
# Copyright 2016 The WWU eLectures Team All rights reserved.
#
# Licensed under the Educational Community License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

opencast_h2_check() {
  echo "Run opencast_h2_check"

  export ORG_OPENCASTPROJECT_DB_DDL_GENERATION="true"
}

opencast_h2_configure() {
  echo "Run opencast_h2_configure"

  export ORG_OPENCASTPROJECT_DB_DDL_GENERATION="true"

  opencast_helper_deleteinfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_DB_VENDOR" \
    "ORG_OPENCASTPROJECT_DB_JDBC_DRIVER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_URL" \
    "ORG_OPENCASTPROJECT_DB_JDBC_USER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_PASS"

  opencast_helper_replaceinfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_DB_DDL_GENERATION"
}

opencast_h2_trytoconnect() {
  echo "Run opencast_h2_trytoconnect"
}

opencast_h2_printddl() {
  echo "-- Database for H2 is created automatically"
}
