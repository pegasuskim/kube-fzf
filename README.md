# kube-fzf
thecasualcoder/kube-fzf 포크해서 개인적으로 자주 쓰는 패턴의 스크립트를 추가 하였습니다.

여기에 사용하는 kubectl, teleport 등과 같이 어떠한 리소스를 찾고 그 찾은 결과를 활용해서 다음 명령어 사용되는 모든 패턴에 응용 할 수 있습니다.

Shell commands using [`kubectl`](https://kubernetes.io/docs/reference/kubectl/overview/) and [`fzf`](https://github.com/junegunn/fzf) for command-line fuzzy searching of [Kubernetes](https://kubernetes.io/) [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/). It helps to interactively:

* search for a Pod
* tail a container of a Pod
* exec in to a container of a Pod
* describe a pod
* port forward pod
* rollout restart deployment
* edit service
* edit cronjobs
* edit istio virtualservices
* edit istio destinationrules
* exec tsh(teleport) ssh

## Prerequisite

* [`fzf`](https://github.com/junegunn/fzf)
* [`bat`](https://github.com/sharkdp/bat) supports syntax highlighting for a large number of programming and markup languages
* [`xclip`](https://linux.die.net/man/1/xclip) Only for Linux and it is optional
* [`teleport`](https://gravitational.com/teleport/?utm_medium=ppc&utm_source=adwords&utm_campaign=Brands) Only for Teleport User and it is optional

## Install

### Manual

```
git clone https://github.com/bench87/kube-fzf.git ~/.kube-fzf
cd ~/.kube-fzf
./install
```

## Usage
### `tssh`
Teleport tsh ls를 통해서 서버를 검색후 선택하면 서버에 바로 들어갑니다.
```
tssh
```

### `editvs`
Istio VirtualService를 수정합니다.
```
editvs [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `editdeploy`
Deployment를 수정합니다.
```
editdeploy [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `editdr`
Istio Destinationrule를 수정합니다.
```
editdr [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `editcj`
CronJob을 수정합니다.
```
editcj [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `editsvc`
Service를 수정합니다.
```
editcj [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `descenode`
K8S Node의 describe를 봅니다.
```
describepod [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `findpod`
```
findpod [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `descepod`

```
describepod [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `tailpod`

```
tailpod [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `execpod`

```
execpod [-a | -n <namespace-query>] -c <context> [pod-query] <command>
```

### `pfpod`

```
pfpod [-c | -o | -a | -n <namespace-query>] -c <context> [pod-query] <port>
```

#### Options

```
-a                    -  Search in all namespaces
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
-h                    -  Show help
```
