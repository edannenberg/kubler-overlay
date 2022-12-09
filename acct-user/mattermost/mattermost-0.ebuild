EAPI=8

inherit acct-user

ACCT_USER_ID="-1"
ACCT_USER_GROUPS=( "mattermost" )
ACCT_USER_HOME="/opt/mattermost/"

acct-user_add_deps
