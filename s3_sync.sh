#!/bin/bash

# Site specific

AWS_PROFILE='default'
STAGING_BUCKET='test.paintballreview'
LIVE_BUCKET='www.paintballreview.info'
SITE_DIR='_site/'
REGION='us-east-1'
CLOUDFRONTID='enterid from cloudfront'
INDEX_PAGE='index.html'
ERROR_PAGE='error.html'

# Include the script that does the work
. ~/scripts/s3_site_sync/s3_site_sync.sh
