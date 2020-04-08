#!/usr/bin/env bash

_kube_fzf_usage() {
  local func=$1
  echo -e "\nUSAGE:\n"
  case $func in
    kstern)
      cat << EOF
kstern [resource name] [-a | -n <namespace-query>] [pod-query]
ex) kstern pod

-a                    -  Search in all namespaces
-h                    -  Show help
-c                    - Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
EOF
      ;;
    kget)
      cat << EOF
kget [resource name] [-a | -n <namespace-query>] [pod-query]
ex) kget pod

-a                    -  Search in all namespaces
-h                    -  Show help
-c                    - Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
EOF
      ;;
    tailpod)
      cat << EOF
tailpod [-a | -n <namespace-query>] [pod-query]

-a                    -  Search in all namespaces
-h                    -  Show help
-c                    -  Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
EOF
      ;;
    execpod)
      cat << EOF
execpod [-a | -n <namespace-query>] [pod-query] <command>

-a                    -  Search in all namespaces
-h                    -  Show help
-c                    -  Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
EOF
      ;;
    pfpod)
      cat << EOF
pfpod [ -c | -o | -a | -n <namespace-query>] [pod-query] <source-port:destination-port | port>

-a                    -  Search in all namespaces
-h                    -  Show help
-c                    -  Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
-o                    -  Open in Browser after port-forwarding
EOF
      ;;
    kdesc)
      cat << EOF
kdesc [resource name] [-a | -n <namespace-query> | -c <kubectl context>] [pod-query]
ex) kdesc service

-a                    -  Search in all namespaces
-h                    -  Show help
-c                    -  Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
EOF
      ;;
    krestart)
      cat << EOF
krestart [resource name] [-a | -n <namespace-query> | -c <kubectl context>] [pod-query]
ex) krestart deployment
-a                    -  Search in all namespaces
-h                    -  Show help
-c                    -  Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
EOF
      ;;
    kedit)
      cat << EOF
kedit [resource name] [-a | -n <namespace-query> | -c <kubectl context>] [pod-query]
ex) kedit deployment

-a                    -  Search in all namespaces
-h                    -  Show help
-c                    -  Find kubectl context and do fzf
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
EOF
      ;;
  esac
}

kube_fzf_api_resources() {

	read resource <<< $(kubectl api-resources --no-headers | awk '{print $1}' | sort -u \
		| fzf $(echo $pod_fzf_args) \
		| awk '{ print $1 }')
      if [ -z "$resource" ]; then
        exit 
      fi
    echo "$resource"
}

_kube_fzf_handler() {
  local opt namespace_query pod_query cmd context
  local open=false
  local context=false
  local OPTIND=1
  local func=$1

  shift $((OPTIND))

  while getopts "n:caoh" opt; do
    case $opt in
      h)
        _kube_fzf_usage "$func"
        return 1
        ;;
      n)
        namespace_query="$OPTARG"
        ;;
      a)
        namespace_query="--all-namespaces"
        ;;
      o)
        open=true
        ;;
      c)
        context=true
        ;;
      \?)
        echo "Invalid Option: -$OPTARG."
        _kube_fzf_usage "$func"
        return 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument."
        _kube_fzf_usage "$func"
        return 1
        ;;
    esac
  done
  if [ "$context" = true ] ; then
      read ctx <<< $(kubectl config get-contexts -o=name --no-headers | awk '{print $1}' \
          | fzf $(echo $pod_fzf_args) \
          | awk '{ print $1 }')
      context=$(echo "$ctx")
      if [ -z "$context" ]; then 
        exit
      fi
  else
    context=$(kubectl config current-context)

  fi
  shift $((OPTIND - 1))
  if [ "$func" = "execpod" ] || [ "$func" = "pfpod" ]; then
    if [ $# -eq 1 ]; then
      cmd=$1
      [ -z "$cmd" ] && cmd="sh"
    elif [ $# -eq 2 ]; then
      pod_query=$1
      cmd=$2
      if [ -z "$cmd" ]; then
        if [ "$func" = "execpod" ]; then
          echo "Command required." && _kube_fzf_usage "$func" && return 1
        elif [ "$func" = "pfpod" ]; then
          echo "Port required." && _kube_fzf_usage "$func" && return 1
        fi
      fi
    else
      if [ -z "$cmd" ]; then
        if [ "$func" = "execpod" ]; then
          cmd="sh"
        elif [ "$func" = "pfpod" ]; then
          echo "Port required." && _kube_fzf_usage "$func" && return 1
        fi
      fi
    fi
  else
    pod_query=$1
  fi

  args="$namespace_query|$pod_query|$cmd|$open|$context"
}

_kube_fzf_fzf_args() {
  local search_query=$1
  local extra_args=$2
  local fzf_args="--height=100 --ansi --reverse $extra_args"
  [ -n "$search_query" ] && fzf_args="$fzf_args --query=$search_query"
  echo "$fzf_args"
}


_kube_fzf_search() {
  local namespace rs_name
  local namespace_query=$1
  local pod_query=$2
  local context_selector=$3
  local resource=$4
  local pod_fzf_args=$(_kube_fzf_fzf_args "$pod_query")
  local bat_command=""
  if command -v bat > /dev/null; then
    bat_command="| bat -l yaml --color 'always' --style 'numbers'"
  fi
  if [ -z "$namespace_query" ]; then
      namespace=$(kubectl config get-context --no-headers $context_selector \
        | awk '{ print $5 }')

      namespace=${namespace:=default}
      rs_name=$(kubectl get $resource --namespace=$namespace --context $context_selector --no-headers -o wide \
          | fzf $(echo $pod_fzf_args) --preview "kubectl get $resource {1} -o yaml -n $namespace --context $context_selector $bat_command" \
        | awk '{ print $1 }')
  elif [ "$namespace_query" = "--all-namespaces" ]; then
    read namespace rs_name <<< $(kubectl get $resource --all-namespaces --context $context_selector --no-headers -o wide \
        | fzf $(echo $pod_fzf_args) --preview "kubectl get $resource {2} -o yaml -n {1}  --context $context_selector $bat_command" \
      | awk '{ print $1, $2 }')
  else
    local namespace_fzf_args=$(_kube_fzf_fzf_args "'$namespace_query" "--select-1")
    namespace=$(kubectl get namespaces --context $context_selector --no-headers  \
        | fzf $(echo $namespace_fzf_args) \
      | awk '{ print $1 }')

    namespace=${namespace:=default}
    rs_name=$(kubectl get $resource --namespace=$namespace --context $context_selector --no-headers -o wide \
        | fzf $(echo $pod_fzf_args) --preview "kubectl get $resource {1} -o yaml -n $namespace --context $context_selector $bat_command" \
      | awk '{ print $1 }')
  fi

  [ -z "$rs_name" ] && return 1

  echo "$namespace|$rs_name"
}

_kube_fzf_echo() {
  local reset_color="\033[0m"
  local bold_green="\033[1;32m"
  local message=$1
  echo -e "\n$bold_green $message $reset_color\n"
}

