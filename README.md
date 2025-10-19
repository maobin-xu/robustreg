# robustreg

by **Maobin Xu**. Last updated on 19th October, 2025.

Email: maobinxu@foxmail.com

`robustreg` is useful for specification curve analysis, meta analysis, and robustness. It systematically runs a series of regressions based on user-defined specification combinations, plots the results, and saves the output to a dataset.

An example of the final curve :
![Figure 2](fig/curve2.png)

---

### Installation

`robustreg` is hosted on GitHub. You can install it directly in Stata by running the following command:

```stata
net install robustreg, from("https://raw.githubusercontent.com/maobin-xu/robustreg/main/") replace
```

---

### Syntax

The basic syntax for `robustreg` is:

```stata
robustreg, dep(str) indep(str) [options]
```

---

### Options

#### Regression Options (using `reghdfe`)

* `dep(str)`: A list of dependent variables.
* `indep(str)`: A list of key independent variables.
* `sample(str)`: A list of sample variables (that equal 1) to define the samples used in regressions.
* `control(str)`: A list of control variable sets.
* `fe(str)`: A list of fixed effects.
* `se(str)`: A list of standard error clustering methods.
* `reghdfe_opt(str)`: Any other valid options for the `reghdfe` command.

#### Plot Options (using `twoway` and `graph export`)

* `plot(str)`: Path to save the regression specification curve graph. This option is required to generate the plot.
* `order(str)`: The order of specifications for the curve. The default is `order(dep, indep, control, fe, se, sample)`.
* `orderl(str)`: A list of labels for the order of specifications.
* `depl(str)`: A list of labels for the dependent variables.
* `indepl(str)`: A list of labels for the key independent variables.
* `samplel(str)`: A list of labels for the sample options.
* `controll(str)`: A list of labels for the control variable sets.
* `fel(str)`: A list of labels for the fixed effects.
* `sel(str)`: A list of labels for the standard error clustering methods.
* `level(#)`: The confidence level for the confidence intervals. Default is `95`.
* `twoway_opt(str)`: Other options for the `twoway` command.
* `scatter_opt(str)`: Other options for the `twoway scatter` command, used to plot the β coefficients.
* `rarea_opt(str)`: Other options for the `twoway rarea` command, used to plot the confidence intervals.
* `graph_opt(str)`: Other options for the `graph export` command.

#### Save Options

* `save(str)`: Path to save the regression results as a Stata dataset (.dta).
* `stats(str)`: A list of additional `e()` statistics from `reghdfe` to save.

---

### Examples

First, let's generate some sample data to work with.

```stata
clear
set obs 1000

// Key independent variables
gen x1 = rnormal()
gen x2 = x1 + 0.2*rnormal()

// Control variables
gen c1 = rnormal()*2
gen c2 = runiform()-0.5 

// Dependent variables
gen e = rnormal()/5
gen y1 = 0.24*x1 + 0.4*exp(c1) + e
gen y2 = 0.26*x1 + 0.4*exp(c1) + e

// Sample variables
gen s1 = mod(_n, 2) == 1
gen s2 = mod(_n-1, 3) + 1 == 1

// Fixed effect variables
gen f1 = mod(_n, 2) == 1
gen f2 = mod(_n-1, 3) + 1
```

#### Example 1: Save Regression Results Only

This command runs all possible regressions and saves the results to `regtab1.dta`, without generating a plot.

```stata
robustreg , dep(y1, y2) indep(x1) control(c1, , c1 c2) fe( , f1, f2) sample( , s1) se(robust, , f2) save("regtab1")
```
The results are as follows:

![Figure 3](fig/result.png)

#### Example 2: Generate and Save a Plot

This command generates a specification curve and saves it as `curve1.png`.

```stata
robustreg , dep(y1, y2) indep(x1) control(c1, , c1 c2) fe( , f1, f2) sample( , s1)  plot("curve1.png") twoway_opt(graphregion(margin(l=42 r=5 t=0 b=0))) graph_opt(width(1500) height(1500))
```

![Figure 1](fig/curve1.png)

#### Example 3: Full Customization

This example shows the command with a full set of customized options, including specific labels for each option set.

```stata
robustreg, ///
    dep(y1, y2) indepl("Y1" "Y2") ///
    indep(x1, x2) indepl("X1" "X2") ///
    control( , c1, c1 c2) controll("No" "Control set 1" "Control set 2") ///
    fe( , f1, f2) fel("No" "Fixed effects 1" "Fixed effects 2") ///
    sample( , s1) samplel("Full sample" "Sample 1") ///
    se( , robust, f2) sel("No" "Robust" "F2") ///
    save("regtab2.dta") plot("curve2.png") level(90) ratio(1) fontsize(small) ///
    twoway_opt(graphregion(margin(l=22 r=5 t=0 b=0)) scale(0.6)) ///
    rarea_opt(color(gray%40)) scatter_opt(color(gray)) ///
    graph_opt(width(3000) height(2000))
```

![Figure 2](fig/curve2.png)
