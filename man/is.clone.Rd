% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nichenet.R
\name{is.clone}
\alias{is.clone}
\title{Get logic vector, whether input clones express tags}
\usage{
is.clone(code)
}
\arguments{
\item{code}{vector, clone codes}
}
\value{
TorF logic vector showing whether clones express tags
}
\description{
Get logic vector, whether input clones express tags
}
\examples{
istagclone=is.clone(names(clone.size))
}
