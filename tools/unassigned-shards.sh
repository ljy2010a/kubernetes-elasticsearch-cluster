#!/usr/bin/env bash

# The script performs force relocation of all unassigned shards, 
# of all indices to a specified node (NODE variable)

ES_HOST="ES_HOST"
NODE="NODE"

curl ${ES_HOST}:9200/_cat/shards > shards
grep "UNASSIGNED" shards > unassigned_shards

while read LINE; do
  IFS=" " read -r -a ARRAY <<< "$LINE"
  INDEX=${ARRAY[0]}
  SHARD=${ARRAY[1]}

  echo "Relocating:"
  echo "Index: ${INDEX}"
  echo "Shard: ${SHARD}"
  echo "To node: ${NODE}"

  curl -s -XPOST "${ES_HOST}:9200/_cluster/reroute" -d "{
    \"commands\": [
       {
         \"allocate\": {
           \"index\": \"${INDEX}\",
           \"shard\": ${SHARD},
           \"node\": \"${NODE}\",
           \"allow_primary\": true
         }
       }
     ]
  }"; echo
  echo "------------------------------"
done <unassigned_shards

rm shards
rm unassigned_shards

exit 0