# kube-fzf
thecasualcoder/kube-fzf 포크해서 개인적으로 자주 쓰는 패턴의 스크립트를 추가 하였습니다.


Shell commands using [`kubectl`](https://kubernetes.io/docs/reference/kubectl/overview/) and [`fzf`](https://github.com/junegunn/fzf) for command-line fuzzy searching of [Kubernetes](https://kubernetes.io/) [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/). It helps to interactively:

* search for a Pod
* tail a container of a Pod
* exec in to a container of a Pod
* describe resources
* port forward pod
* rollout restart deployment
* edit resources

## Prerequisite

* [`fzf`](https://github.com/junegunn/fzf)
* [`bat`](https://github.com/sharkdp/bat) supports syntax highlighting for a large number of programming and markup languages
* [`xclip`](https://linux.die.net/man/1/xclip) Only for Linux and it is optional

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

### `kedit <resource name>`
아래 예는 Deployment 리소스를 수정하는 예입니다.
```
kedit deploy [-a | -n <namespace-query> -c <context>] [query]
```

### `kdesc <resource name>`
아래 예는 Pod 리소스의 describe를 보는 예입니다.
```
kdesc pod [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `krestart <resource name>`
아래 예는 Deployment 리소스의 rollout restart를 하는 예입니다.
```
krestart deploy [-a | -n <namespace-query> -c <context>] [pod-query]
```

### `findpod`
```
findpod [-a | -n <namespace-query> -c <context>] [pod-query]
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
pfpod [-a | -n <namespace-query>] -c <context> [pod-query] <port>
```

#### Options

```
-a                    -  Search in all namespaces
-n <namespace-query>  -  Find namespaces matching <namespace-query> and do fzf.
                         If there is only one match then it is selected automatically.
-c                       Kubectl Context
-h                    -  Show help
```
