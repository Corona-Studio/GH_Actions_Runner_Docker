# GH_Actions_Runner_Docker

A repo used to place all the auto deploy GitHub self-hosted runner Dockerfile scripts

## Details

- `Windows`: Contains Dockerfile scripts running under Windows Container Env

## Usage

### Build

```ps
docker build --build-arg GH_TOKEN=your_token --build-arg GH_ORG=your_org --build-arg GH_REPO=your_repo -t github-runner .
```

### Run

```ps
docker run -d --name github-runner-container -v C:\\Runner:/Runner -e github-runner
```
