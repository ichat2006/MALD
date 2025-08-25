# MALD

*MALD* is my small research/engineering project that pairs a **Python** backend with an optional **Swift (iOS)** client.  
The Python side handles data prep / modeling / utilities; the Swift app is a lightweight front-end for demos and quick iteration.

> Research & education only — **not** a production system.

---

## Table of Contents
- [Why this exists](#why-this-exists)
- [Features](#features)
- [Architecture (high level)](#architecture-high-level)
- [Project layout](#project-layout)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [How to run (Python)](#how-to-run-python)
- [How to run (iOS / Swift — optional)](#how-to-run-ios--swift--optional)
- [Optional: API server](#optional-api-server)
- [Optional: Docker](#optional-docker)
- [Development workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [License (MIT)](#license-mit)

---

## Why this exists
I wanted a compact playground where I can:
- Prototype models/utilities in Python with a clean, reproducible environment.
- Optionally visualize or poke those models through a tiny Swift/iOS front end.
- Keep everything simple enough to drop into another project later.

---

## Features
- **Reproducible Python environment** via `requirements.txt`.
- **Clean Python package** under `mald/` for reusable logic.
- **Optional iOS demo app** (Xcode) to interact with the Python outputs or a small HTTP API.
- **Simple configuration** using environment variables (`.env`) or CLI flags.
- **Script-friendly layout** so you can run `python -m mald.something` or `python scripts/train.py`.

---
## Requirements
- **Python 3.9–3.12**
- **PyTorch (required)**
- **Flask (required)**
- **Utils: numpy, pandas, scikit-learn, matplotlib, tqdm, python-dotenv**
- **(Optional) jupyterlab for notebooks**
- **Optional) gunicorn if you want a production-ish WSGI runner**
---

