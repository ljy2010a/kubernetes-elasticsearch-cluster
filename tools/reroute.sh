#!/usr/bin/env bash

ES_HOST="ES_HOST"
FROM_NODE="FROM_NODE"
NODE="NODE"

curl ${ES_HOST}:9200/_cat/shards > shards
grep "index" shards > move_shards

while read LINE; do
  IFS=" " read -r -a ARRAY <<< "$LINE"
  INDEX=${ARRAY[0]}
  SHARD=${ARRAY[1]}

  echo "Relocating:"
  echo "Index: ${INDEX}"
  echo "Shard: ${SHARD}"
  echo "From node: ${FROM_NODE}"
  echo "To node: ${NODE}"

  curl -s -XPOST "${ES_HOST}:9200/_cluster/reroute" -d "{
    \"commands\": [
       {
         \"move\": {
           \"index\": \"${INDEX}\",
           \"shard\": ${SHARD},
           \"from_node\": \"${FROM_NODE}\",
           \"to_node\": \"${NODE}\"
         }
       }
     ]
  }"; echo
  echo "------------------------------"
done <move_shards

rm shards
rm move_shards

exit 0