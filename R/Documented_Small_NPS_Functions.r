#' Calculate a Net Promoter Score
#'
#' This function calculates a Net Promoter Score from a vector of \emph{Recommend} scores, ideally \code{\link{numeric}} ones. An attempt will be made to coerce \code{\link{factor}}, or \code{\link{character}} data. \code{NA} values, either in the data, or generated by type coercion, are automatically omitted from the calculation. No warning is given in the former case. Net Promoter Scores generated are on a [-1,1] scale; you may want to multiply them by 100 (and perhaps round them!) prior to presentation.
#'
#' @param x A vector of \emph{Recommend} scores
#' @param breaks A \code{list} of length three, giving the integer Likert scale points for \emph{Detractors}, \emph{Passives}, and \emph{Promoters}, respectively. The default is \code{list(0:6, 7:8, 9:10)}
#' @return a Net Promoter Score. Unrounded.
#' @aliases nps
#' @export
#' @seealso \code{\link{npc}}
#' @author Brendan Rocks \email{rocks.brendan@@gmail.com}
#' @examples
#' # This will generate 1000 dummy Likelihood to Recommend reponses
#' x <- sample(0:10, prob=c(0.02, 0.01, 0.01, 0.01, 0.01, 0.03, 0.03, 0.09,
#'     0.22, 0.22, 0.35), 1000, replace=TRUE)
#'
#' # Here are the proportions of respondents giving each Likelihood to 
#' # Recommend response
#' prop.table(table(x))
#'
#' # Here's a histrogram of the scores
#' hist(x, breaks=-1:10, col=c(rep("red",7), rep("yellow",2), rep("green", 2)))
#'
#' # Here's a barplot. It's very similar, though for categorical responses 
#' # it's often slightly easier to interpret.
#' barplot(
#'     prop.table(table(x)),
#'      col=c(rep("red",7), rep("yellow",2), rep("green", 2))
#'      )
#'
#' # Here's the nps
#' nps(x)
#'
#' #You can round it if you like
#' round(nps(x)) ; round(nps(x),1)
nps <- function(x, breaks = list(0:6, 7:8, 9:10)){ 
    x2 <- x[!is.na(x)]
    na <- ! x2 %in% unlist(breaks)
    if(mean(na) != 0) 
        warning(sum(na), " values outside specified range for Recommend scale (",min(unlist(breaks)), ":", max(unlist(breaks)), "), and excluded.  Use 'breaks' to change this.")
    
    tab <- table(factor(x, levels=unlist(breaks)))
    (sum(tab[as.character(breaks[[3]])]) - sum(tab[as.character(breaks[[1]])])) / sum(tab)
}

#' Create Net Promoter Categories from Likelihood to Recommend Scores
#' 
#' This function produces Net Promoter Categories for \code{\link{numeric}} or \code{\link{integer}} \emph{Recommend} data
#' 
#' @name npc
#' @aliases npc
#' @inheritParams nps
#' @return Net Promoter categories
#' @export
#' @seealso \code{\link{nps}}
#' @author Brendan Rocks \email{rocks.brendan@@gmail.com}
#' @examples
#' # The command below will generate Net Promoter categories for each point
#' # on a standard 0:10 Likelihood to Recommend scale
#' npc(0:10)
#'
#'  # Here's how scores and categories map out. Notice that scores which are 
#'  # 'off the scale' drop out as missing/invalid
#' data.frame(score = -2:12, category = npc(-2:12))
#' 
#' # When you have lots of data, summaries are useful
#' rec <- sample(0:10, prob=c(0.02, 0.01, 0.01, 0.01, 0.01, 0.03, 0.03, 0.09,
#'     0.22, 0.22, 0.35), 1000, replace=TRUE)
#' 
#' # A Histrogram of the Likelihood to Recommend scores we just generated
#' hist(rec, breaks=-1:10)
#' 
#' # A look at the by nps category using summary
#' summary(npc(rec))
#'
#' # As above
#' table(npc(rec))
#'
#' # As a crosstabulation
#' table(rec, npc(rec))
#'
#' nps(rec)
npc <- function(x, breaks = list(0:6, 7:8, 9:10)) {
    if(!is.numeric(x)) {
        message("Warning: Data of class ",paste(class(x), collapse=" ")," supplied; converted to numeric.")
        x <- as.numeric(as.character(factor(x, levels = unlist(breaks))))
        }
    cut(x, 
        c(min(unlist(breaks)-1),
            unlist(lapply(breaks, max))),
        labels = c("Detractor","Passive","Promoter")
        )
}


#' Calculate the variance of a Net Promoter Score
#' 
#' This function calculates the Net Promoter Score variance, taking a \code{\link{vector}} of length three, with numbers or proportions of \emph{Detractors}, \emph{Passives}, and \emph{Promoters}, respectively.
#' 
#' @param x A \code{\link{vector}} of length three, with numbers or proportions of \emph{Detractors}, \emph{Passives}, and \emph{Promoters}, respectively
#' @name npvar
#' @aliases npvar
#' @return \code{\link{numeric}}. The variance of the distribution, ranging from 0 to 1.
#' @export
#' @seealso \code{\link{nps.var}}, a version which works on raw Recommend responses
#' @author Brendan Rocks \email{rocks.brendan@@gmail.com}
npvar <- function(x) {
    props <- as.numeric(prop.table(x))
    (props[3] + props[1]) - (props[3] - props[1])^2
}

#' Calculate the variance of a Net Promoter Score
#' 
#' This function calculates the Net Promoter Score variance, taking a \code{\link{vector}} of raw \emph{Recommend} data
#' 
#' @name nps.var
#' @aliases nps.var
#' @inheritParams nps
#' @return \code{\link{numeric}}. The variance of the distribution, ranging from 0 to 1.
#' @export
#' @seealso \code{\link{npvar}}, a version which works on counts or proportions of responses
#' @author Brendan Rocks \email{rocks.brendan@@gmail.com}
nps.var <- function(x, breaks = list(0:6, 7:8, 9:10))
    npvar(table(npc(x, breaks)))

#' Calculate the standard error of a Net Promoter Score
#' 
#' This function calculates the standard error (see below) of a Net Promoter Score, taking a \code{\link{vector}} of raw \emph{Recommend} data
#' 
#' @name nps.se
#' @aliases nps.se
#' @inheritParams nps
#' @return \code{\link{numeric}}. The variance of the distribution, ranging from 0 to 1.
#' @export
#' @seealso \code{\link{npvar}}, a version which works on counts or proportions of responses
#' @author Brendan Rocks \email{rocks.brendan@@gmail.com}
nps.se <- function(x, breaks = list(0:6, 7:8, 9:10))
   sqrt(nps.var(x)/sum(!is.na(npc(x))))


#' Significance tests and confidence intervals for Net Promoter Scores
#'
#' This function performs one and two sample tests for the Net Promoter score(s) of \emph{Recommend} data distributions. Currently, only a Wald type test is supported.
#'
#' @param x A vector of \emph{Recommend} scores
#' @param y A vector of \emph{Recommend} scores, to compare to \code{x}. If not specified, a one sample test on \code{x} is performed. Defaults to \code{NULL}
#' @param test The type of test to perform. Currently only the Wald/Z-test ('\code{wald}') is supported
#' @param conf the confidence level of the test and intervals. Defaults to 0.95
#' @param \dots Not used.
#' @inheritParams nps
#' @return A \code{\link{list}} of class \code{nps.test} containing: 
#' \item{nps.x, nps.y}{The Net Promoter score(s)}
#' \item{delta}{Where both \code{x} and \code{y} have been specified, the absolute difference between the two scores}
#' \item{int}{The confidence interval generated. For a one sample test, this will be a confidence interval around \code{nps.x}. For a two sample test, this will be a confidence interval around the difference between \code{nps.x} and \code{nps.y}}
#' \item{conf}{The confidence level used when performing the test, as specificed by \code{conf} in the function parameters}
#' \item{p.value}{The p value of the significance test}
#' \item{sig}{\code{\link{logical}}. Whether or not the \code{p.value} of the test exceeded 1-\code{conf}}
#' \item{se.hat}{The estimated standard error of \code{delta} for a two sample test, otherwise of \code{x}}
#' \item{type}{\code{\link{character}} string indicating whether a one or two sample test was performed}
#' \item{n.x, n.y}{Counts for \code{x} and \code{y}}
#' @aliases print.nps.test
#' @export
#' @seealso \code{\link{nps.var}}, \code{\link{nps.se}}, \code{\link{nps}}
#' @author Brendan Rocks \email{rocks.brendan@@gmail.com}
nps.test <- function(x, y=NULL, test="wald", conf = .95, breaks = list(0:6, 7:8, 9:10)){

    alpha <- 1-conf
    z     <- qnorm(1-alpha/2)

    nps.x <- nps(x)
    var.x <- nps.var(x)
    n.x   <- sum(!is.na(npc(x)))

    type <- if(is.null(y)) "One sample" else "Two sample"

    if(type == "One sample"){
        se.hat  <- sqrt(var.x/n.x)
        int     <- c(nps.x + z * sqrt(var.x/n.x), nps.x - z * se.hat)
        p.value <- 1 - (pnorm(abs(nps.x - 0) / se.hat) * 2 -1)
        delta   <- abs(0 - nps.x)  
        nps.y   <- n.y <- NA
    }

    if(type == "Two sample"){
        nps.y  <- nps(y)
        var.y  <- nps.var(y)
        n.y    <- sum(!is.na(npc(y)))

        delta   <- abs(nps.x - nps.y)
        se.hat  <- sqrt((var.x/n.x) + (var.y/n.y))
        int     <- c(delta - z * se.hat, delta + z * se.hat)
        p.value <- 1 - (pnorm(delta / se.hat) * 2 -1) 
    }

    out <- list(nps.x = nps.x, nps.y = nps.y, delta = delta, int = int, conf = conf, p.value = p.value, sig = p.value < alpha, se.hat = se.hat, type = type, n.x = n.x, n.y = n.y)
    
    class(out) <- "nps.test"
    return(out)
}

#' Strips Likert scale point labels, returns numeric or ordinal data
#' 
#' Survey systems export responses to Likhert scales with the scale labels on, meaning that R
#' as factors or text as opposed to numeric data. This function takes labelled scales and returns unlabelled numeric data (by default), or an unlabelled ordered factor (if requested).
#' 
#' @name scalestrip
#' @aliases scalestrip
#' @param x a \code{\link{vector}}, \code{\link{matrix}}, or \code{\link{data.frame}}, containing Likert data labelled in the format "Integer - some text", e.g. "10 - Extremely Likely"
#' @param ordinal \code{\link{logical}} (\code{TRUE}\\code{FALSE}).
#' Should the data returned be an ordered factor? Otherwise the data returned is \code{\link{numeric}}. Defaults to \code{FALSE}.
#' @return Unlabelled numeric data (by defualt), or an unlabelled ordered factor (if requested).
#' @export
#' @author Brendan Rocks \email{rocks.brendan@@gmail.com}
scalestrip <- function(x, ordinal=FALSE){
    out <- function(x) switch(ordinal+1, as.numeric(x), ordered(x))

    if(!(is.data.frame(x)|is.matrix(x))){	return(out(as.numeric(gsub("-...+","",x))))		} else

    if(is.data.frame(x)|is.matrix(x)){
    for(i in 1:ncol(x)) {x[,i] <- out(gsub("-...+","",x[,i]))	}
    return(x)}
}

#' @return \code{NULL}
#'
#' @rdname nps.test
#' @export
print.nps.test <- function(x, ...){
    cat(x$type, "Net Promoter Score Z test\n\n")
    
    cat("NPS of x: ", round(x$nps.x,2), " (n = " , x$n.x, ")\n", sep = "")
    
    if(x$type == "Two sample"){
        cat("NPS of y: ", round(x$nps.y,2), " (n = " , x$n.y, ")\n", sep = "")
        cat("Difference:", round(x$delta,2), "\n")
    }
    cat("\n")
    
    cat(if(x$type == "One sample") "Standard error of x:" else "Standard error of difference:", round(x$se.hat, 3), "\n")
    cat("Confidence level:", x$conf, "\n")
    cat("p value:", x$p.value, "\n")
    cat("Confidence interval:", x$int, "\n\n")
}