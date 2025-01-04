# GH_Actions_Runner_Docker

A repo used to place all the auto deploy GitHub self-hosted runner Dockerfile scripts

## Details

- `Windows`: Contains Dockerfile scripts running under Windows Container Env

## Usage

### Build

```ps
docker build --build-arg GITHUB_TOKEN=your_token --build-arg GITHUB_ORG=your_org -t github-runner .
```

### Run

```ps
docker run -d --name github-runner-container -v C:\\Runner:/Runner -e github-runner
```
