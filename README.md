# GH_Actions_Runner_Docker

A repo used to place all the auto deploy GitHub self-hosted runner Dockerfile scripts.

This Dockerfile can automatically install the required the env used for GitHub Self-Hosted Runner by passing your GitHub credentials and other information.

During the first time "boot-up" for the image, it will automatically use your credentials to register a self-hosted runner under your specified repo.

Also, it will setup the auto-run script for the runner to ensure it will still working even after the container stopped or restarted.

PRs are welcome!

## Details

| Item    | Stage       |     |
| :------ | :---------- | :-- |
| Windows | Maintaining | ✔   |
| Linux   | In Plan     | -   |
| OSX     | -           | -   |

### Repo directory descriptions

- `Windows`: Contains Dockerfile scripts running under Windows Container Env

## Usage

### Build

```ps
docker build \
    --build-arg GH_TOKEN=your_token \
    --build-arg GH_ORG=your_org \
    --build-arg GH_REPO=your_repo \
    -t github-runner .
```

### Run

```ps
docker run -d --name github-runner-container -e github-runner
```

### Run (With Resources Constraints)

See [GitHub's Document](https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners)

| Virtual Machine | Processor (CPU) | Memory (RAM) | Storage (SSD) |
| :-------------- | :-------------- | :----------- | :------------ |
| Windows         | 4               | 16 GB        | 14 GB         |

```ps
docker run -d --name github-runner-container \
  --cpus=4 \
  --memory=16g \
  --memory-swap=16g \
  --storage-opt size=14G \
  -e github-runner
```

## Related Links

- [Docker - microsoft/windows](https://hub.docker.com/r/microsoft/windows)
- [Docker - microsoft/windows-server](https://hub.docker.com/r/microsoft/windows-server)
