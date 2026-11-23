
#!/bin/bash

LOCAL_AUTH="admin:1234"
LOCAL_HOST="127.0.0.1:5984"

REMOTE_AUTH="admin:1234"
# REMOTE_HOST="couchdb.abhijeetrana.com"
REMOTE_HOST="docker.drapcode.us"
REMOTE_PROTOCOL="https" # use 'http' or 'https'

echo "Fetching all databases from remote CouchDB..."
# Fetch all database names and filter out internal system databases
ALL_DBS=$(curl -s -u "${REMOTE_AUTH}" "${REMOTE_PROTOCOL}://${REMOTE_HOST}/_all_dbs" | \
  grep -o '"[^"]*"' | tr -d '"' | \
  grep -vE '^(_replicator|_global_changes|_node)$')

for db in $ALL_DBS; do
  echo "Replicating database: ${db}..."
  curl -s -X POST "http://${LOCAL_AUTH}@${LOCAL_HOST}/_replicate" \
    -H "Content-Type: application/json" \
    -d "{
      \"source\": \"${REMOTE_PROTOCOL}://${REMOTE_AUTH}@${REMOTE_HOST}/${db}\",
      \"target\": \"http://${LOCAL_AUTH}@${LOCAL_HOST}/${db}\",
      \"create_target\": true
    }"
  echo -e "\n"
done

echo "All databases replicated successfully!"
