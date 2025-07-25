% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print_niche.R
\name{tag_cancer_noncancer}
\alias{tag_cancer_noncancer}
\title{print cancer and non-maligant cell numbers for each tag}
\usage{
tag_cancer_noncancer(nnt, file = "tag2celltypes.pdf")
}
\arguments{
\item{nnt}{a list contains connectome information of all niches, the result of Dnichenetwork}

\item{file}{pdf}
}
\value{
pdf
}
\description{
print cancer and non-maligant cell numbers for each tag
}
\examples{
tag_cancer_noncancer(nnt)
}
