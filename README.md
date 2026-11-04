# MLproject template for a Chap model (Python)

A minimal template for writing a Chap-compatible forecasting model in Python. You write a train script, a predict script and an `MLproject` file. Chap runs the model as a [chapkit](https://dhis2-chap.github.io/chapkit/) service, so no service code is needed.

The model learns a linear regression from rainfall and temperature to disease cases in the same month. It is not meant to be a good model; the point is to show the steps from a script on your machine to a model running in Chap.

The full walkthrough is in the Chap docs: [Build a new model from a template](https://chap.dhis2.org/chap-modeling-platform/external_models/mlproject_tutorial/). If you already have a model and want to make it Chap-compatible, follow [Bring your existing model to Chap](https://chap.dhis2.org/chap-modeling-platform/external_models/existing_model/) instead, and copy files from this template as it describes. An R version of this template is [mlproject_template_r](https://github.com/chap-models/mlproject_template_r).

## Requirements

- [uv](https://docs.astral.sh/uv/)
- [chap-core](https://chap.dhis2.org/chap-modeling-platform/chap-cli/chap-core-cli-setup/) 2.5.0 or newer, for step 2
- [Docker](https://docs.docker.com/get-started/get-docker/), for step 3 only

## Repository structure

```
.
├── MLproject        # How Chap runs the model: entry points, covariates, environment
├── train.py         # Training logic
├── predict.py       # Prediction logic
├── pyproject.toml   # Python dependencies
├── isolated_run.py  # Runs train and predict without Chap
├── Dockerfile       # Packages the model as a chapkit service
├── compose.yml      # Builds and starts the image with docker compose
├── .github/         # Workflows that test and publish the image
├── input/           # Small example dataset
└── output/          # Written by isolated_run.py
```

## 1. Run the model without Chap

```console
uv run python isolated_run.py
```

This trains the model on `input/trainData.csv`, saves it to `output/model.pkl` and writes forecasts for `input/futureClimateData.csv` to `output/predictions.csv`. The forecasts are in the `sample_0` column.

`train.py` and `predict.py` are plain scripts that take file paths as arguments. Change them, add dependencies to `pyproject.toml`, and rerun `isolated_run.py` until the model does what you want.

## 2. Evaluate the model with Chap

```console
chap eval --model-name . --dataset-csv input/trainData.csv --output-file output/eval.nc --plot --run-config.as-chapkit
```

Chap reads `MLproject`, sets up the uv environment, starts the model as a chapkit service, runs a backtest and stops the service again. `output/eval.nc` holds the results and `--plot` writes an HTML plot next to it.

If you use other columns from the dataset, list them under `required_covariates` in `MLproject`.

## 3. Package the model as a Docker image

Build the image and start it:

```console
docker compose up --build
```

The image is based on `chapkit-py-cli`, which runs the `MLproject` as a chapkit service. Your scripts are copied in unchanged. The model is now at http://localhost:9090. In another terminal, check that Chap can use it:

```console
chap eval --model-name http://localhost:9090 --run-config.is-chapkit-model --dataset-csv input/trainData.csv --output-file output/eval.nc
```

Stop it with `Ctrl+C`, or `docker compose down`.

### Publish the image

GitHub builds and publishes the image every time you push to `main`. To push, you need your own copy of this repository: click **Use this template** on GitHub, then clone your copy. Commit and push your changes:

```console
git add -A && git commit -m "Update the model" && git push
```

The **Actions** tab of your repository then shows two workflows from `.github/workflows`:

- **CI** (`ci.yml`) builds the image, starts it and runs `chap eval` against it.
- **Publish Docker image** (`publish-docker.yml`) publishes the image to the GitHub Container Registry as `ghcr.io/<owner>/<repo>:latest`, plus a version tag when you push a tag such as `v1.0.0`.

The first time, check the image under **Packages** on your GitHub profile or organisation page. If it is private, change its visibility to public so that a Chap installation can pull it.

To use the model from the Chap modeling app, run the image next to Chap and let it register itself. See [Running Your Own Model](https://chap.dhis2.org/chap-modeling-platform/modeling-app/running-your-own-model/).
