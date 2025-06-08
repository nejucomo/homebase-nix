function homebase-prompt-bling
{
  local status="$1"

  local esc_bright_cyan='\033[1;36m'
  local esc_bright_yellow='\033[1;33m'
  local esc_bright_magenta='\033[1;35m'
  local esc_dim_grey='\033[2;40m'
  local esc_off='\033[0m'

  local s_box="$esc_bright_magenta"
  local s_bg="$esc_dim_grey"
  local s_fg="$esc_bright_cyan"

  echo -e "${s_box}┎────┄┄┄┄┄┈┈┈${esc_off}"
  echo -e "${s_box}┃ ${s_bg}who: ${s_fg}${USER} ${s_bg}@${s_fg} $(hostname)"
  echo -e "${s_box}┃ ${s_bg}pwd: ${s_fg}${PWD}"
  echo -e "${s_box}┖────┄┄┄┄┄┈┈┈${esc_off}"
}

export PS1='\n\n$(homebase-prompt-bling $?)\n\$ '
