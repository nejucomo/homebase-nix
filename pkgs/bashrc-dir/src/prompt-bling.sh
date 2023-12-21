export PS1='\n\n  '

function prompt_append
{
  local control="$1"
  local frag="$2"

  PS1+='\033['
  case "$control" in
    bg) PS1+='35' ;; # magenta
    norm) PS1+='33' ;; # yellow
    green) PS1+='1;32' ;; # bright green
    off) PS1+='0' ;; # off
    *) PS1+='1;31' ;; # bright red
  esac
    
  PS1+='m'
  PS1+="$frag"
  ps1+='\033[0m'
}

band_start=3
band=''
if (( $HOMEBASE_NEST_LEVEL >= "$band_start" ))
then
  band="$(printf '%0.s=' $(seq "$band_start" $HOMEBASE_NEST_LEVEL))"
fi

prompt_append bg '---'
prompt_append green "$band"
prompt_append bg '{ '
prompt_append norm '\$?=$?'
prompt_append bg ' ; '
prompt_append norm '\u'
prompt_append bg ' @ '
prompt_append norm '\h'
prompt_append bg ' : '
prompt_append norm '\w'

if [ -n "${IN_NIX_SHELL:-}" ]
then
  prompt_append bg ' ; '
  prompt_append green "$IN_NIX_SHELL"
fi

prompt_append bg ' }'
prompt_append green "$band"
prompt_append bg '---'
prompt_append off '\n\$ '

unset prompt_append
unset band
unset band_start
