# CME-trajectory-segmentation

# KL Divergence-based Trajectory State Segmentation (Stage 2–3 Detection)

A method for automatically detecting state transitions in trajectories using **Kullback–Leibler (KL) divergence** combined with **local dynamic similarity**.

---

## Overview

This repository implements a principled approach to identify state changes in angular trajectories (e.g., orientation or polarization data). Given a trajectory divided into three stages:

- **Stage 1 (Baseline)**: Known reference period `[t0, t1]` with stable dynamics.
- **Stage 2 (Deviation)**: Period where the trajectory deviates from the baseline.
- **Stage 3 (Recovery)**: Period where the trajectory returns to dynamics similar to Stage 1.

The goal is to **automatically detect the optimal transition points** between Stage 2 and Stage 3 based on the statistical characteristics of Stage 1.

---

## Method Principle

### 1. Feature Representation
Instead of using absolute angles, we use **incremental changes** (differences) as features:

- Δφ: Azimuth angle increment
- Δθ: Polar angle increment

Feature matrix for a segment: `X = [Δφ, Δθ]`

### 2. Stage 1 Statistical Model
We model Stage 1 as a multivariate Gaussian distribution:

- Mean vector **μ₁**
- Covariance matrix **Σ₁** (with regularization `+ (1e-6)·I` to avoid singularity)

### 3. Change Point Detection via KL Divergence

For each candidate segmentation point `k`:

- Stage 2: `[t1+1, k]`
- Stage 3: `[k+1, N]`

We compute the **KL divergence** of each segment relative to the Stage 1 distribution.

**KL Divergence** between two multivariate Gaussians (p and q):

$$
D_{KL}(p || q) = \frac{1}{2} \left[ \ln\left(\frac{\det(\Sigma_q)}{\det(\Sigma_p)}\right) + \text{tr}(\Sigma_q^{-1}\Sigma_p) + (\mu_p - \mu_q)^T \Sigma_q^{-1} (\mu_p - \mu_q) - p \right]
$$

### 4. Scoring Function

To balance the two segments, we introduce a weighting factor **λ** (0 ≤ λ ≤ 1):

$$
\text{Score}(k, \lambda) = KL_3 - \lambda \cdot KL_2
$$

### 5. Optimal Segmentation

- Traverse all possible `k` values.
- For each `k`, search over λ from 0 to 1 with step 0.01.
- Select the segmentation point that yields the most stable / optimal score.

---

## Features

- Robust to noise through incremental features and Gaussian modeling.
- Hyperparameter λ allows flexible trade-off between deviation and recovery detection.
- Suitable for angular/polarization trajectory analysis (e.g., molecular motors, particle tracking, orientation dynamics).

---

