# Lakes380CoreDepthTools

<!-- badges: start -->
[![R-CMD-check](https://github.com/nickmckay/Lakes380CoreDepthTools/workflows/R-CMD-check/badge.svg)](https://github.com/nickmckay/Lakes380CoreDepthTools/actions)
[![R-CMD-check](https://github.com/nickmckay/Lakes380CoreDepthTools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/nickmckay/Lakes380CoreDepthTools/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Installation

This package helps convert core-section depths to depth below lake floor for Lakes 380 lakes. 

To install, you'll need the `remotes` package if you don't already have it

`install.packages("remotes")`

Then you can install the package

`remotes::install_github("nickmckay/Lakes380CoreDepthTools")`

and then load it with

`library(Lakes380CoreDepthTools)`


## How to calculate dblf from depths relative to core liners

Currently, the functionality is pretty basic. To convert core-section depth to depth below lake floor, use the function `coreSection_to_dblf()` with the corename and depth below the top of the core liner. You can run it for one or more depths. Here is an example that will calculate depth below lake floor for 20 to 30 cm below the core liner in core L380_DUNCA3_LC4U_2:


`dblf <- coreSection_to_dblf("L380_DUNCA3_LC4U_2",20:30)`

This will return a dataframe with the depths and some metadata.

All of the depths in the package, both inputs and outputs should be in cm. It should give you an error if you ask for a bad depth range. 


### How to calculate dblf from coreliner depth for multiple core sections.

You may want to convert multiple core sections at once. You can do so using a vector or a data.frame that lists the core section names and corresponding depths. For example:

`multi_coreSection_to_dblf(c("L380_DUNCA3_LC4U_1","L380_DUNCA3_LC4U_2"),c(20,10))`

or in the case where you have the information stored in a data.frame

`multi_coreSection_to_dblf(corec("L380_DUNCA3_LC4U_1","L380_DUNCA3_LC4U_2"),c(20,10))`


### Load in a spreadsheet and add in dblf

The function `dblf_from_file()` will let you select a spreadsheet (csv, xls, xlsx) to load in, select the key columns, and write out a csv file with calculated depths. **This works for both core liner depth, and HSI depth**. Just specify conv.type = "coreliner" or conv.type = "hsi".

If you want to convert multiple cores, try you can add a column with the core name to the spreadsheet, and then select that column in the process. That can look as simple as this:

`dblf_from_file(conv.type = "coreliner")`

Alternatively, if it's just one core, this might be easier (this time for HSI):

`dblf_from_file(corename = "L380_FORSY_LC1U_2",conv.type = "HSI")`



## How to calculate dblf from depths output from hyperspectral imaging (HSI)

HSI depths are typically reported relative to the top of the ROI, not the core liner, so a different function is used to convert those depths, but the pattern is similar: 

`dblf <- hsi_to_dblf("L380_DUNCA3_LC4U_2",20:30)`

This will return a dataframe with the depths and some metadata.

**You'll notice that if you enter a top section, the output depths will be identical to the input depths.** This is by design, since the HSI data typically serve as the depth standard for each core. 


### Similarly to core liner depths, there is an option to convert multiple core sections at once: 

`multi_hsi_to_dblf(c("L380_DUNCA3_LC4U_1","L380_DUNCA3_LC4U_2"),c(20,10))`

or in the case where you have the information stored in a data.frame

`multi_hsi_to_dblf(corec("L380_DUNCA3_LC4U_1","L380_DUNCA3_LC4U_2"),c(20,10))`


## Calculate a core section depth if you know dblf

If you want to do the opposite, use `dblf_to_coreSection()`. Here you input the core name (not the section name) which will be the same, but without the final underscore and section number. For example, we could go backwards in this core by doing:

`cs <- dblf_to_coreSection(corename = df$corename, cm = df$depth)`



## Find the right core name
If you're having trouble getting the right core name, try the helper functions `findCoreSectionName()` where you can input a guess and it will give you suggestions, or `listCoreSectionNames()` to see all the known names. 

There is basic help documentation for these functions, see [reference](https://nickmckay.github.io/Lakes380CoreDepthTools/reference/index.html). 


