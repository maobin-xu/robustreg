{smcl}
{* *! version 1.0.0 2025-08-24}{...}
{title:Title}

{pstd}
{cmd:robustreg} {hline 2} Plot and save regression results from specification combinations. Specification curve analysis, meta-analysis, and robustness.{p_end}


{title:Syntax}

{phang2}{cmd:robustreg} , {opt dep(str)} {opt indep(str)} [{it:options}]{p_end}

{synoptset 20 tabbed}{synopthdr}
{synoptline}
{syntab:Regression Options (using {cmd:reghdfe})}
{synopt: {opt dep(str)} } list of dependent variables. Minimum number of variables is 1 {p_end}
{synopt: {opt indep(str)} } list of independent variables. Minimum number of variables is 1 {p_end}
{synopt: {opt sample(str)} } list of sample variables (that equal 1) to define the samples used in regressions. Default is full sample {p_end}
{synopt: {opt control(str)} } list of control variable sets. Default is no control variable {p_end}
{synopt: {opt fe(str)} } list of fixed effects. Default is no fixed effect {p_end}
{synopt: {opt se(str)} } list of standard error clustering methods. Default is classical standard error without robust adjustment or clustering {p_end}
{synopt: {opt reghdfe_opt(str)} } other options for {cmd:reghdfe} {p_end}

{syntab:Plot Options (using {cmd:twoway} and {cmd:graph export})}
{synopt: {opt plot(str)} } path to save the regression specification curve. This option must be set to plot a curve{p_end}
{synopt: {opt order(str)} } specifications to plot and the order. Default is {opt order(dep, indep, control, fe, se, sample)} {p_end}
{synopt: {opt orderl:abel(str)} } specification labels of the curve. Default is {opt orderl("Dependent variable" "Independent variable" "Control variables" "Fixed effects" "Standard error clustering" "Sample")} {p_end}
{synopt: {opt depl:abel(str)} } specification labels of the dependent variables{p_end}
{synopt: {opt indepl:abel(str)} } specification labels of the independent variables{p_end}
{synopt: {opt samplel:abel(str)} } specification labels of the samples {p_end}
{synopt: {opt controll:abel(str)} } specification labels of the control variable sets {p_end}
{synopt: {opt fel:abel(str)} } specification labels of the fixed effects {p_end}
{synopt: {opt sel:abel(str)} } specification labels of the standard error clustering methods {p_end}
{synopt: {opt level(#)} } confidence level of intervals. Default is {opt level(95)} {p_end}
{synopt: {opt ratio(#)} } ratio of the curve region (upper part) to the label region (lower part). Default is {opt ratio(1)} {p_end}
{synopt: {opt fontsize(str)} } font size of the curve in {cmd:twoway}. Default is {opt fontsize(vsmall)} {p_end}
{synopt: {opt twoway_opt(str)} } other options for {cmd:twoway} {p_end}
{synopt: {opt scatter_opt(str)} } other options for {cmd:twoway scatter}, used to plot the β coefficients {p_end}
{synopt: {opt rarea_opt(str)} } other options for {cmd:twoway rarea}, used to plot the confidence intervals {p_end}
{synopt: {opt graph_opt(str)} } other options for {cmd:graph export}, used to export the curve {p_end}

{syntab: Save Options}
{synopt: {opt save(str)} } path to save the regression results as a Stata data file (.dta) {p_end}
{synopt: {opt stats(str)} } other {opt e()} statistics to save from {cmd:reghdfe}. {it:b}, {it:t}, {it:ll}, {it:ul}, {it:F}, and {it:N} are automatically saved {p_end}


{title:Description}

{pstd}
{cmd:robustreg} is an all-Stata command to plot regression specification curve and save regression results from specification combinations, such as samples, dependent variables, and fixed effects. It is useful for specification curve analysis, meta-analysis, and robustness. This command requires {cmd:reghdfe}.{p_end}

{pstd}
An alternative command is {cmd:specurve} developed by Mingze Gao, which requires users to manually create a YAML configuration file.{p_end}


{title:Examples}

{phang2}{stata clear}{p_end}
{phang2}{stata set obs 1000}{p_end}

{pstd}
Key independent variables:{p_end}

{phang2}{stata gen x1 = rnormal()}{p_end}
{phang2}{stata gen x2 = x1 + 0.2*rnormal()}{p_end}

{pstd}
Control variables:{p_end}

{phang2}{stata gen c1 = rnormal()*2}{p_end}
{phang2}{stata gen c2 = runiform()-0.5 }{p_end}

{pstd}
Dependent variables:{p_end}

{phang2}{stata gen e = rnormal()/5}{p_end}
{phang2}{stata gen y1 = 0.24*x1 + 0.4*exp(c1) + e}{p_end}
{phang2}{stata gen y2 = 0.26*x1 + 0.4*exp(c1) + e}{p_end}

{pstd}
Sample variables:{p_end}

{phang2}{stata gen s1 = mod(_n, 2) == 1}{p_end}
{phang2}{stata gen s2 = mod(_n-1, 3)==1 }{p_end}

{pstd}
Fixed effect variables:{p_end}

{phang2}{stata gen f1 = mod(_n, 2) == 1}{p_end}
{phang2}{stata gen f2 = mod(_n-1, 3) + 1}{p_end}

{pstd}
Save only regression data:{p_end}

{phang2}{stata `"robustreg , dep(y1, y2) indep(x1) control(c1, , c1 c2) fe( , f1, f2) sample( , s1) se(robust, , f2) save("regtab1") "'}{p_end}
    
{pstd}
Save a curve graph with simple settings:{p_end}

{phang2}
{stata `"robustreg , dep(y1, y2) indep(x1) control(c1, , c1 c2) fe( , f1, f2) sample( , s1)  plot("curve1.png") twoway_opt(graphregion(margin(l=42 r=5 t=0 b=0))) graph_opt(width(1500) height(1500)) "'}{p_end}

{pstd}
Save a curve graph and regression results with full settings:{p_end}

{phang2}{cmd}
robustreg , 
dep(y1, y2) depl("Y1" "Y2") 
indep(x1, x2) indepl("X1" "X2") 
control( , c1, c1 c2) controll("No" "Control set 1" "Control set 2") 
fe( , f1, f2) fel("No" "Fixed effects 1" "Fixed effects 2") 
sample( , s1) samplel("Full sample" "Sample 1") 
se( , robust, f2) sel("No" "Robust" "F2") 
save("regtab2")
plot("curve2.png") level(90) ratio(1) fontsize(small)
twoway_opt(graphregion(margin(l=22 r=5 t=0 b=0)) scale(0.6))
rarea_opt(color(gray%40)) scatter_opt(color(gray))
graph_opt(width(3000) height(2000))
{txt}
{p_end}


{title:References}

{phang}
Simonsohn, U., Simmons, J.P. & Nelson, L.D. 2020. "Specification Curve Analysis". {it:Nature Human Behaviour}, 4:1208–1214. https://doi.org/10.1038/s41562-020-0912-z
{p_end}

{title:Author}

{pstd}Maobin Xu{p_end}
{pstd}The Chinese University of Hong Kong, Shenzhen {p_end}
{pstd}Email: {browse "mailto:maobinxu@foxmail.com":maobinxu@foxmail.com}{p_end}






