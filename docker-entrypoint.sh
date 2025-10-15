#!/bin/bash
set -e

CRONICLE_DIR="/opt/cronicle"

# 1. Validate Username (Letters and Numbers Only)
if ! [[ -n "$ADMIN_USERNAME" && "$ADMIN_USERNAME" =~ ^[a-zA-Z0-9]+$ ]]; then
    echo "Error: Username '$ADMIN_USERNAME' is invalid. It must contain only letters and numbers."
    exit 1
fi

# 2. Validate Password (Letters and Numbers Only)
if ! [[ -n "$ADMIN_PASSWORD" && "$ADMIN_PASSWORD" =~ ^[a-zA-Z0-9]+$ ]]; then
    echo "Error: Password is invalid. It must contain only letters and numbers."
    exit 1
fi

# 3. Validate Email Format
# Note: The regex should NOT be quoted inside the [[ ... ]] and =~ for bash to interpret it as a regex.
EMAIL_REGEX="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"
if ! [[ -n "$ADMIN_EMAIL" && "$ADMIN_EMAIL" =~ $EMAIL_REGEX ]]; then
    echo "Error: Email address '$ADMIN_EMAIL' is invalid."
    exit 1
fi

# If all checks pass, proceed
echo "Validation successful!"
echo "User: $ADMIN_USERNAME"
echo "Email: $ADMIN_EMAIL"

if [ ! -f "$CRONICLE_DIR/conf/config.json" ]; then

	# Setup & Config stuff
	# Apply custom setup if setup template is provided via SETUP_JSON

	SAMPLE_SETUP_JSON="$CRONICLE_DIR/sample_conf/setup.json"
	SAMPLE_CONFIG_JSON="$CRONICLE_DIR/sample_conf/config.json"

	# Update admin username
	if [[ -n "$SETUP_JSON" && -n "$ADMIN_USERNAME" ]]; then
		SETUP_JSON=${SETUP_JSON//__ADMIN_USERNAME__/$ADMIN_USERNAME}
	fi

	# Update admin password
	if [[ -n "$SETUP_JSON" && -n "$ADMIN_PASSWORD" ]]; then

		SALT=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
    	HASHED_PASSWORD=$(node -e "
			var bcrypt = require('bcrypt-node');
			hashed = bcrypt.hashSync( '$ADMIN_PASSWORD' + '$SALT' );
			process.stdout.write(hashed); 
    	")

    	# echo "The generated hash is: $HASHED_PASSWORD"
		# echo "Salt is $SALT"
		
		SETUP_JSON=${SETUP_JSON//__ADMIN_HASHED_PASSWORD__/$HASHED_PASSWORD}
		SETUP_JSON=${SETUP_JSON//__ADMIN_SALT__/$SALT}
 	fi

 	# Update email
 	if [[ -n "$SETUP_JSON" && -n "$ADMIN_EMAIL" ]]; then
		SETUP_JSON=${SETUP_JSON//__ADMIN_EMAIL__/$ADMIN_EMAIL}
	fi

	# copy setup.json contents from environment variable
	if [ -n "$SETUP_JSON" ]; then
		echo "$SETUP_JSON" > "$SAMPLE_SETUP_JSON"
	fi

	# copy config.json contents from environment variable
	if [ -n "$CONFIG_JSON" ]; then
		echo "$CONFIG_JSON" > "$SAMPLE_CONFIG_JSON"
	fi

	echo "Building Cronicle ..."
	node $CRONICLE_DIR/bin/build.js dist
	sleep 2

	echo "Running Cronicle setup..."
	$CRONICLE_DIR/bin/control.sh setup
	sleep 2

fi
# Start Cronicle in foreground
#
echo "Starting Cronicle"

$CRONICLE_DIR/bin/control.sh start
tail -f < /dev/null
