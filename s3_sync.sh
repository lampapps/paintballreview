#!/bin/bash

# Site specific

AWS_PROFILE='default'
STAGING_BUCKET='dev.paintballreview'
LIVE_BUCKET='paintballreview.info'
SITE_DIR='_site/'
REGION='us-east-1'
CLOUDFRONTID='E2YF8G7LR4P8GU'
INDEX_PAGE='index.html'
ERROR_PAGE='error.html'

# Include the script that does the work
. ~/scripts/s3_site_sync/s3_site_sync.sh
