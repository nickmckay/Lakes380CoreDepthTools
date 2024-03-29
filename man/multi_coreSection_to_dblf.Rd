% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coreSectionDepth.R
\name{multi_coreSection_to_dblf}
\alias{multi_coreSection_to_dblf}
\title{Convert depths for multiple core sections}
\usage{
multi_coreSection_to_dblf(corename, cm)
}
\arguments{
\item{corename}{a vector of corenames}

\item{cm}{a vector of corresponding depths that matches the length of corenames}
}
\value{
a tibble
}
\description{
Convert depths for multiple core sections
}
\examples{

multi_coreSection_to_dblf(c("L380_DUNCA3_LC4U_1","L380_DUNCA3_LC4U_2"),c(20,10))

}
