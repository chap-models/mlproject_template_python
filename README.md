# MLproject template for a Chap model (Python)

A minimal template for writing a Chap-compatible forecasting model in Python. You write a train script, a predict script and an `MLproject` file, and the model runs as a [chapkit](https://dhis2-chap.github.io/chapkit/) service.

The model learns a linear regression from rainfall and temperature to disease cases in the same month. It is not meant to be a good model; the point is to show the steps from a script on your machine to a model running in Chap.

The full walkthrough is in the Chap docs: [Build a model from an MLproject file](https://chap.dhis2.org/chap-modeling-platform/external_models/mlproject_tutorial/). An R version of this template is [mlproject_template_r](https://github.com/chap-models/mlproject_template_r).

## MLproject with chapkit, not the built-in Chap runner

There are two ways Chap can run a model described by an `MLproject` file:

- **The built-in Chap runner**, used by older examples such as [minimalist_example_uv](https://github.com/dhis2-chap/minimalist_example_uv). Chap reads the `MLproject` and runs the train and predict commands itself.
- **chapkit**, used by this template. chapkit reads the same `MLproject` and serves the model as a REST service, and Chap sends it data over HTTP. This is the same way chapkit model services run next to a Chap installation.

You write the same kind of files in both cases. What differs is how the model is run: here `chap eval` gets the `--run-config.as-chapkit` flag, which starts the model as a chapkit service, and the model is deployed as a Docker image that runs that service. You do not write any service code (no `main.py`) for this.

## Requirements

- [uv](https://docs.astral.sh/uv/)
- [chap-core](https://chap.dhis2.org/chap-modeling-platform/chap-cli/chap-core-cli-setup/) 2.5.0 or newer, for step 2
- Docker, for step 3

## Repository structure

```
.
├── MLproject        # How Chap runs the model: entry points, covariates, environment
├── train.py         # Training logic
├── predict.py       # Prediction logic
├── pyproject.toml   # Python dependencies
├── isolated_run.py  # Runs train and predict without Chap
├── Dockerfile       # Packages the model as a chapkit service
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

## 3. Deploy the model

Build an image and start it:

```console
docker build -t my-model .
docker run --rm -p 9090:8000 my-model
```

The image is based on `chapkit-py-cli`, which runs the `MLproject` as a chapkit service on port 8000. Evaluate the running service with:

```console
chap eval --model-name http://localhost:9090 --run-config.is-chapkit-model --dataset-csv input/trainData.csv --output-file output/eval.nc
```

To use the model from the Chap modeling app, run the image next to Chap and let it register itself. See [Running Your Own Model](https://chap.dhis2.org/chap-modeling-platform/modeling-app/running-your-own-model/).
