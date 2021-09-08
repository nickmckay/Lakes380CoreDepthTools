# Lakes380CoreDepthTools

<!-- badges: start -->
[![R-CMD-check](https://github.com/nickmckay/Lakes380CoreDepthTools/workflows/R-CMD-check/badge.svg)](https://github.com/nickmckay/Lakes380CoreDepthTools/actions)
<!-- badges: end -->

This package helps convert core-section depths to depth below lake floor for Lakes 380 lakes. 

To install, you'll need the `remotes` package if you don't already have it

`install.packages("remotes")`

Then you can install the package

`remotes::install_github("nickmckay/Lakes380CoreDepthTools")`

and then load it with

`library(Lakes380CoreDepthTools)`

Currently, the functionality is pretty basic. To convert core-section depth to depth below lake floor, use the function `coreSection_to_dblf()` with the corename and depth below the top of the core liner. You can run it for one or more depths. Here is an example that will calculate depth below lake floor for 20 to 30 cm below the core liner in core L380_DUNCA3_LC4U_2:


`dblf <- coreSection_to_dblf("L380_DUNCA3_LC4U_2",20:30)`

This will return a dataframe with the depths and some metadata.

All of the depths in the package, both inputs and outputs should be in cm. It should give you an error if you ask for a bad depth range. 

If you're having trouble getting the right core name, try the helper functions `findCoreSectionName()` where you can input a guess and it will give you suggestions, or `listCoreSectionNames()` to see all the known names. 

There is basic help documentation for these functions, see [reference](https://nickmckay.github.io/Lakes380CoreDepthTools/reference/index.html). 



