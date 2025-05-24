#!/bin/bash

# args:
# tolyaml
# tolkey
# tolvalue
# list of tolpaths

tolyaml=$1
tolkey=$2
tolvalue=$3

args=()
for a in $@; do
  args+=($a)
done

#echo $tolyaml $tolkey $tolvalue
#for tp in ${args[@]:3}; do
#  echo tolpath: $tp
#done

if [[ ! -f $tolyaml ]]; then
  echo file $tolyaml not found
  exit 1
fi

if [[ $tolvalue == "" ]]; then
  echo missing toleration value
  exit 0
fi

toldef="${tolyaml}-tolerations.yaml"
cat <<EOF > $toldef
- effect: NoSchedule
  key: $tolkey
  operator: Equal
  value: $tolvalue
EOF

echo
echo "==="
echo "Injecting tolerations from $toldef"
echo

for tolpath in ${args[@]:3}; do

  if [[ `./gen/bin/yq eval "$tolpath" $tolyaml` == null ]]; then
    echo adding toleration key $tolkey, value $tolvalue at $tolpath
    ./gen/bin/yq -i "$tolpath += (load(\"$toldef\"))" $tolyaml

  else
    echo file $tolyaml already contains tolerations at $tolpath, skip...
  fi

done

