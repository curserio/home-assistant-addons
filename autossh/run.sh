#!/usr/bin/with-contenv bashio

set -e

CONFIG_PATH=/data/options.json
KEY_PATH=/data/ssh_keys

HOSTNAME=$(jq --raw-output ".hostname" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)

REMOTE_FORWARDING=$(jq --raw-output ".remote_forwarding[]" $CONFIG_PATH)

OTHER_SSH_OPTIONS=$(jq --raw-output ".other_ssh_options" $CONFIG_PATH)
FORCE_GENERATION=$(jq --raw-output ".force_keygen" $CONFIG_PATH)

# https://github.com/hassio-addons/bashio


if [ ! -d "$KEY_PATH" ]; then
  bashio::log.info "No previous key pair found"
  mkdir -p "$KEY_PATH"
  ssh-keygen -b 2048 -t rsa -N "" -C "hassio-setup-via-autossh" -f "${KEY_PATH}/autossh_rsa_key" -q 
  bashio::log.info "The public key is:"
  cat "${KEY_PATH}/autossh_rsa_key.pub"
  bashio::log.warning "Add this key to '~/.ssh/authorized_keys' on your remote server now!"
  bashio::log.warning "Please restart add-on when done. Exiting..."
  exit 1
else
  bashio::log.info "Authentication key pair restored"
fi

echo ""
bashio::log.info "The public key is:"
cat "${KEY_PATH}/autossh_rsa_key.pub"
bashio::log.info "Please add this key to '~/.ssh/authorized_keys' on your remote server"

if [ -z "$HOSTNAME" ]; then
  bashio::log.error "Please set 'hostname' in your config to the address of your remote server"
  exit 1
fi


echo ""
bashio::log.info "Remote server host keys:"
ssh-keyscan -p $SSH_PORT $HOSTNAME || true

echo ""
bashio::log.info "The container is connected via the following IP addresses:"
ip -o address show


COMMAND="/usr/bin/autossh "\
" -M 0 "\
"-o ServerAliveInterval=30 "\
"-o ServerAliveCountMax=3 "\
"-o StrictHostKeyChecking=no "\
"-o ExitOnForwardFailure=yes "\
"-p ${SSH_PORT} -t -t "\
"-i ${KEY_PATH}/autossh_rsa_key "\
"${USERNAME}@${HOSTNAME}"


if [ ! -z "${REMOTE_FORWARDING}" ]; then
  while read -r LINE; do
    COMMAND="${COMMAND} -R ${LINE}"
  done <<< "${REMOTE_FORWARDING}"
fi

COMMAND="${COMMAND} ${OTHER_SSH_OPTIONS}"

echo ""
bashio::log.info "Preparations done."
echo ""
bashio::log.info "Executing command: ${COMMAND}"
/usr/bin/autossh -V
exec ${COMMAND}
