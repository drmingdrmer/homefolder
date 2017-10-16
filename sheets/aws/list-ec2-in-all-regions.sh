#!/bin/sh

# pip install awscli
# pip install jq

# for region in `aws ec2 describe-regions --output text | cut -f3`
# do
#      echo -e "\nListing Instances in region:'$region'..."
#      aws ec2 describe-instances --region $region
# done

if which -s gecho; then
    # use gnu echo on mac
    _echo=gecho
else
    _echo=echo
fi

for region in `aws ec2 describe-regions --output text | cut -f3`
do
    (
    out=$(
        $_echo -e "Instances in region:'$region': "
        aws ec2 describe-instances --region $region \
         | jq '.Reservations[] | ( .Instances[] | {state: .State.Name, name: .KeyName, type: .InstanceType, key: .KeyName})'
    )
    $_echo -e $out
    ) &
done

wait
