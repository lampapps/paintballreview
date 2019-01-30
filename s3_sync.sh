#!/bin/bash

# credits: based on savjee.be/_deploy.sh at github
# https://github.com/Savjee/savjee.be/blob/1a84362c4424ecd2ee7d368298ed30c218a2d66a/_deploy.sh

#Updated to build and sync Jeykll site

##
# Options
##

AWS_PROFILE='default'
STAGING_BUCKET='test.paintballreview'
LIVE_BUCKET=' '
SITE_DIR='_site/'
REGION='us-east-1'
CLOUDFRONTID='enterid from cloudfront'


##
# Usage
##
usage() {
cat << _EOF_
Usage: ${0} [staging | live]
    
    staging		Deploy to the staging bucket
    live		Deploy to the live (www) bucket
_EOF_
}
 
##
# Color stuff
##
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)

function red() {
    echo "$RED$*$NORMAL"
}

function green() {
    echo "$GREEN$*$NORMAL"
}

function yellow() {
    echo "$YELLOW$*$NORMAL"
}

##
# Actual script
##

# Expecting at least 1 parameter
if [[ "$#" -ne "1" ]]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

if [[ "$1" = "live" ]]; then
	BUCKET=$LIVE_BUCKET
	green 'Deploying to live bucket'

    elif [[ "$1" = "staging" ]]; then
    BUCKET=$STAGING_BUCKET
    green 'Deploying to staging bucket'

else
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi
#echo $BUCKET
# create and configure the bucket to be a website
yellow '--> Creating a static website bucket'
aws s3api create-bucket --bucket $BUCKET --region $REGION --profile $AWS_PROFILE
aws s3 website s3://$bucket --index-document index.html --error-document error.html --profile $AWS_PROFILE

#Prepend the path to S3 for the bucket
BUCKET='s3://'$BUCKET

# Build the site in the folder
yellow '--> Running Jekyll build'
jekyll build


#red '--> Gzipping all html, css and js files'
#find $SITE_DIR \( -iname '*.html' -o -iname '*.css' -o -iname '*.js' \) -exec gzip -9 -n {} \; -exec mv {}.gz {} \;

yellow '--> Uploading css files'
aws s3 sync $SITE_DIR $BUCKET --exclude '*.*' --include '*.css' --content-type 'text/css' --cache-control 'max-age=604800' --acl public-read --profile $AWS_PROFILE


yellow '--> Uploading js files'
aws s3 sync $SITE_DIR $BUCKET --exclude '*.*' --include '*.js' --content-type 'application/javascript' --cache-control 'max-age=604800' --acl public-read --profile $AWS_PROFILE

# Sync media files first (Cache: expire in 10weeks)
yellow '--> Uploading images (jpg, png, ico)'
aws s3 sync $SITE_DIR $BUCKET --exclude '*.*' --include '*.png' --include '*.jpg' --include '*.ico' --expires 'Sat, 20 Nov 2025 18:46:39 GMT' --cache-control 'max-age=6048000' --acl public-read --profile $AWS_PROFILE


# Sync html files (Cache: 2 hours)
yellow '--> Uploading html files'
aws s3 sync $SITE_DIR $BUCKET --exclude '*.*' --include '*.html' --content-type 'text/html' --cache-control 'max-age=7200, must-revalidate' --acl public-read --profile $AWS_PROFILE


# Sync everything else
yellow '--> Syncing everything else'
aws s3 sync $SITE_DIR $BUCKET --delete --cache-control 'max-age=7200, must-revalidate' --acl public-read --profile $AWS_PROFILE

#Strip the s3:// off the front so next command can run
BUCKET="${BUCKET:5}"

#return the url of the website
green 'http://'$BUCKET'.s3-website-'$REGION'.amazonaws.com/index.html'


# Invalidate all objects on Cloudfrount forcing the cache to refresh from origin
#aws cloundfront create-invalidation -distribution-id $CLOUDFRONTID -paths "/*""

# aws s3 sync $site_dir s3://$LIVE_BUCKET --storage-class=STANDARD_IA



