---
published: true
title: TMB Stock Assessment Function Library
excerpt: Refactoring common functions out of my TMB models into a centralised library file
---

The main tool used in fisheries stock assessment is a stock assessment model. Stock assessment models produce inferences of stock (population) status by fitting population dynamics model to diverse sets of data, including abundance or biomass indices, as well as biological data from individuals in the population such as age, length, and maturity. Because the available data for every stock is different, there are often no "one-size-fits-all" stock assessment models, thereby requiring some level of customisation of stock assessment models for each unique application.

In fisheries stock assessment modeling, like in any custom mathematical modeling endeavour, there is a need for programming. And like in any programming endeavour, there is often a lot of repetition. For example, including diverse data such as those outlined above in the stock assessment model requires multiple models of the observations, which are often similar enough to require almost identical pieces of code. Often, these similar or identical pieces of code can be refactored out into functions, which may be applied in each instance. This makes for much more elegant, readable code with less repetition, which is the goal of functional programming [link].

Template Model Builder (TMB) is a model building template language that is increasing in popularity among fisheries stock assessment analysts. TMB uses the C++ programming language, and leverages the ```autodiff``` (automatic differentiation) and ```eigen``` (fast matrix multiplication) libraries to enable fast numerical optimisation of objective functions with Quasi-Newton minimisation algorithm. Furthermore, TMB allows  the specification of random effects, and will integrate the objective function over these random effects using the Laplace approximation.



