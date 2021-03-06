#' Meta-analysis for multivariate genome-wide association scan
#' 
#' The function performs meta-analysis for multiple multivariate GWA analyses 
#' 
#' @param reslist A list where each element is a multivariate GWA result of class "MultiRes".
#' @param outfile A string giving the path and file name of the output file. By default, a file
#' named \code{'Multivariate_meta-analysis_results.txt'} will be written into the current working directory.
#' 
#' @return The function returns a matrix containing the meta-analysis results, where the row names are
#' the variants names, and the column names are the names of the studies provided in \code{reslist} or
#' generated by the program if no names are given, with an extra column \code{"p.meta"} containing the 
#' meta-analysis P-values. The results are also written into \code{outfile}.
#' 
#' @author Xia Shen
#' 
#' @references 
#' Xia Shen, ..., Gordan Lauc, Jim Wilson, Yurii Aulchenko (2014).
#' Multi-omic-variate analysis identified the association between 14q32.33 and 
#' compound N-Glycosylation of human Immunoglobulin G \emph{Submitted}.
#' 
#' @seealso 
#' \code{Multivariate}
#' 
#' @examples 
#' \dontrun{
#' ## loading two gwaa.data sets in GenABEL
#' data(ge03d2)
#' data(ge03d2ex)
#' 
#' ## in each dataset, running multivariate GWAS for 3 traits: height, weight, bmi
#' res1 <- Multivariate(gwaa.data = ge03d2, trait.cols = c(5, 6, 8), 
#'                      covariate.cols = c(2, 3))
#' res2 <- Multivariate(gwaa.data = ge03d2ex.clean, trait.cols = c(5, 6, 8), 
#'                      covariate.cols = c(2, 3))
#' 
#' ## running meta-analysis by combining the P-values
#' meta <- MultiMeta(list(res1, res2))
#' }
#' @aliases MultiMeta, multimeta
#' @keywords multivariate, meta-analysis
#' 
`MultiMeta` <- function(reslist, outfile = 'Multivariate_meta-analysis_results.txt') {
    cat('checking data ...')
    k <- length(reslist)
    if (k < 2) stop('not enough studies for meta-analysis!')
    common <- rownames(reslist[[1]])
    for (i in 1:k) {
        if (class(reslist[[i]]) != 'MultiRes') {
            stop('incorrect class of results!')
        }
        common <- common[common %in% rownames(reslist[[i]])]
    }
    if (length(common) == 0) {
		stop('no variant exists in all studies!')
	}
    cat(' OK\n')
    cat('meta-analysis ...')
    pmat <- matrix(NA, length(common), k + 1)
    if (is.null(names(reslist))) {
        listname <- paste('Study', 1:k, sep = '.')
	} else {
        listname <- names(reslist)
	}
    dimnames(pmat) <- list(common, c(listname, 'p.meta'))
    for (i in 1:k) pmat[,i] <- reslist[[i]][common,'P.F']
    pmat[,'p.meta'] <- pchisq(-2*(rowSums(log(pmat[,1:k]))), 2*k, lower.tail = FALSE)
    cat(' OK\n')
    cat('writing results ...')
    write.table(pmat, outfile, row.names = TRUE, col.names = TRUE, quote = FALSE, sep = '\t')
    cat(' OK\n')
    return(pmat)
}
