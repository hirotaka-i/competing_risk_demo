## Introduction

[This repository used this template](https://github.com/MJFF-ResearchCommunity/small-analysis-project-template)


Competing risks are events that prevent the occurrence of the primary event of interest. For example, in a study of dementia, death is a competing risk because dementia cannot develop after death. To account for competing risks, one can use the Fine–Gray model instead of a standard Cox model. In this example, we contrast the Cause‑Specific Cox and the Fine–Gray models under a competing‑risks framework.

**Related files:**

* `data/testdataset.csv`: Example survival pattern
* `code/demo.R`: Code comparing Cause‑Specific Cox vs. Fine–Gray models
* `report/KM_curve.png`: Kaplan–Meier curve for the test dataset
* `report/KM_curve2.png`: Kaplan–Meier curve for the augmented dataset

---

## Example dataset

The test dataset contains 10 participants (group A) and 4 observed events of interest:

```
id  group  time  status
1    A      1     0  # censored
2    A      2     0  # censored
3    A      3     1  # event
4    A      4     1  # event
5    A      5     1  # event
6    A      5     1  # event
7    A      5     0  # censored
8    A      5     0  # censored
9    A      6     0  # censored
10   A      6     0  # censored
```

We then create a second cohort (group B) by copying these records and recoding the first two censored observations as competing events (`status = 2`):

```
id  group  time  status
11   B      1     2  # competing event
12   B      2     2  # competing event
13   B      3     1  # event
14   B      4     1  # event
15   B      5     1  # event
16   B      5     1  # event
17   B      5     0  # censored
18   B      5     0  # censored
19   B      6     0  # censored
20   B      6     0  # censored
```

---

## Model comparisons

### Cause‑Specific Cox model

In the Cause‑Specific Cox model, competing events (`status == 2`) are treated as censored. The hazard ratio compares the instantaneous risk of the event of interest between groups, conditional on being event‑free and alive.

```r
> summary(cs_cox)
Call:
coxph(formula = Surv(time, status == 1) ~ group, data = data)

n=20, number of events=8

            coef exp(coef) se(coef)    z   Pr(>|z|)
groupB    0.0000    1.0000   0.7071 0.000  1.000

        exp(coef) lower .95 upper .95

groupB      1.00      0.25      4.00

Concordance=0.5 (se = 0)
Likelihood ratio test=0  on 1 df, p=1
t Wald test=0 on 1 df, p=1
Score (logrank) test=0 on 1 df, p=1
```

No difference is detected between group A and B (`coef = 0`, HR = 1).

### Fine–Gray subdistribution hazards model

The Fine–Gray model retains subjects who experience the competing event in the risk set with a time‑decaying weight, directly modeling the cumulative incidence function (CIF).

```r
> summary(fg_model)
Competing Risks Regression

Call:
crr(ftime = data$time, fstatus = data$status, cov1 = data$groupB)

             coef exp(coef) se(coef)    z   p-value
groupB    -0.244    0.783   0.628 -0.389  0.698

        exp(coef)   2.5%    97.5%
groupB    0.783    0.229   2.682

Num. cases=20
Pseudo Log-likelihood=-21.7
LR test=0.12 on 1 df, p=0.72
```

Here, the subdistribution hazard for group B is lower (HR ≈ 0.78), reflecting fewer observed events when accounting for the competing risk.

---

## Theoretical background

In the Fine–Gray model, each subject has a weight $w_i(t)$ at time $t$:

* If $T_i > t$ (event‑free, no competing event): $w_i(t) = 1$.
* If $T_i \le t$ and status = 2 (competing event at $T_i$): $w_i(t) = \frac{G(t)}{G(T_i)},$ where $G(t)$ is the survival function for the competing event ($G(t) = P(\text{no competing event by }t)$).
* If $T_i \le t$ and status = 1 (event of interest by $T_i$): $w_i(t) = 0$.

This weighting keeps individuals with competing events partially in the risk set, preserving the proper risk structure for estimating the CIF.

---

## Practical implications

* **Cause‑Specific Cox** estimates the hazard among those still alive and event‑free; it censors competing events completely, which can overestimate the CIF.
* **Fine–Gray** targets the real‑world cumulative incidence, answering: "What fraction develop the event by time $t$ when competing risks are present?"

**Bottom line:**

* Use **Cause‑Specific Cox** for etiologic questions about the underlying hazard among survivors.
* Use **Fine–Gray** for absolute risk prediction and cumulative incidence in the presence of competing risks.
