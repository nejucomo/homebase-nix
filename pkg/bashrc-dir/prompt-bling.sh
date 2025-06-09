function homebase-prompt-bling
{
  local status="$1"

  local esc_off='\033[0m'
  local esc_bright_cyan='\033[1;36m'
  local esc_bright_green='\033[1;32m'
  local esc_bright_yellow='\033[1;33m'
  local esc_bright_magenta='\033[1;35m'
  local esc_dim_grey='\033[2;40m'

  local s_box="${esc_off}${esc_bright_magenta}"
  local s_dg="${esc_off}${esc_dim_grey}"
  local s_bc="${esc_off}${esc_bright_cyan}"
  local s_bg="${esc_off}${esc_bright_green}"
  local s_by="${esc_off}${esc_bright_yellow}"

  local box_left="${s_box}┃"

  echo -e "${s_box}┎─────┄┄┄┄┄┄┈┈┈┈"

  [ "$status" -eq 0 ] || echo -e "${s_box}┃ ${s_by}\$? = ${status}"

  echo -e "${s_box}┃ ${s_dg}who: ${s_bc}${USER} ${s_dg}@${s_bc} $(hostname)"
  echo -e "${s_box}┃ ${s_dg}pwd: ${s_bc}${PWD}"

  local gitdesc="$(git describe --all --dirty=" ${s_by}<dirty>" 2> /dev/null)"
  if [ -n "$gitdesc" ]
  then
    echo -en "${s_box}┃ ${s_dg}git: ${s_bg}${gitdesc} ${s_dg}"
    git rev-parse --short HEAD
  fi

  echo -e "${s_box}┖──┄┄┄┈┈${esc_off}"
}

export PS1='\n\n$(homebase-prompt-bling $?)\n\$ '
