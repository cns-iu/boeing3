library(colorspace)
library(qualpalr)
# library(ghibli)
# library(nord)
# library("ochRe")
# library(ggthemes)

#pal_str 
#676D83 - plot boarder color 
#f5f7ff - white used in lines in plot
#fafbff - Background color
#231e48 - Text: blue/dark gray used on text present in plot: with #fafbff background
#102e47 - Text: blue/dark gray used in label over orange colors


pal_seq_och <- function (n, h = c(16, 58), c = c(128, NA, 34), l = c(73, 95), 
                         power = c(1.19795221843003, NA), gamma = NULL, fixup = TRUE, 
                         alpha = 1, palette = NULL, rev = FALSE, register = NULL, 
                         ..., h1, h2, c1, c2, l1, l2, p1, p2, cmax, c.) 
{
  if (!is.null(gamma)) 
    warning("'gamma' is deprecated and has no effect")
  if (n < 1L) 
    return(character(0L))
  if (!missing(c.)) 
    c <- c.
  if (length(c) == 3L) 
    c <- c[c(1L, 3L, 2L)]
  if (is.character(h)) 
    palette <- h
  pals <- if (!is.null(palette)) {
    as.matrix(hcl_palettes(type = "Sequential", palette = palette)[, 
                                                                   2L:11L])[1L, ]
  }
  else {
    structure(c(if (length(h) < 2L) c(h, NA) else rep_len(h, 
                                                          2L), if (length(c) < 2L) c(c, 0) else rep_len(c, 
                                                                                                        2L), rep_len(l, 2L), if (length(power) < 2L) c(power, 
                                                                                                                                                       NA) else rep_len(power, 2L), if (length(c) < 3L) NA else c[3L], 
                1), .Names = vars.pal)
  }
  if (!missing(h) && !is.character(h)) {
    h <- if (length(h) < 2L) 
      c(h, NA)
    else rep_len(h, 2L)
    pals["h1"] <- h[1L]
    pals["h2"] <- h[2L]
  }
  if (!missing(c) || !missing(c.)) {
    if (length(c) < 2L) 
      c <- c(c, 0)
    pals["c1"] <- c[1L]
    pals["c2"] <- c[2L]
    if (length(c) == 3L) 
      pals["cmax"] <- c[3L]
  }
  if (!missing(l)) {
    l <- rep_len(l, 2L)
    pals["l1"] <- l[1L]
    pals["l2"] <- l[2L]
  }
  if (!missing(power)) {
    power <- if (length(power) < 2L) 
      c(power, NA)
    else rep_len(power, 2L)
    pals["p1"] <- power[1L]
    pals["p2"] <- power[2L]
  }
  if (!missing(fixup)) 
    pals["fixup"] <- as.logical(fixup)
  if (!missing(h1)) 
    pals["h1"] <- h1
  if (!missing(h2)) 
    pals["h2"] <- h2
  if (!missing(c1)) 
    pals["c1"] <- c1
  if (!missing(c2)) 
    pals["c2"] <- c2
  if (!missing(l1)) 
    pals["l1"] <- l1
  if (!missing(l2)) 
    pals["l2"] <- l2
  if (!missing(p1)) 
    pals["p1"] <- p1
  if (!missing(p2)) 
    pals["p2"] <- p2
  if (!missing(cmax)) 
    pals["cmax"] <- cmax
  if (!is.na(pals["h2"]) && pals["h1"] == pals["h2"]) 
    pals["h2"] <- NA
  if (is.character(register) && nchar(register) > 0L) {
    add_hcl_pals(palette = register, type = if (is.na(pals["h2"])) 
      "Sequential (single-hue)"
      else "Sequential (multi-hue)", parameters = pals)
    register <- TRUE
  }
  else {
    register <- FALSE
  }
  if (is.na(pals["h2"])) 
    pals["h2"] <- pals["h1"]
  if (is.na(pals["c2"])) 
    pals["c2"] <- 0
  if (is.na(pals["p2"])) 
    pals["p2"] <- pals["p1"]
  rval <- seq(1, 0, length = n)
  rval <- seqhcl(rval, pals["h1"], pals["h2"], 
                 pals["c1"], pals["c2"], pals["l1"], 
                 pals["l2"], pals["p1"], pals["p2"], 
                 pals["cmax"], as.logical(pals["fixup"]), 
                 ...)
  if (!missing(alpha)) {
    alpha <- pmax(pmin(alpha, 1), 0)
    alpha <- format(as.hexmode(round(alpha * 255 + 1e-04)), 
                    width = 2L, upper.case = TRUE)
    rval <- ifelse(is.na(rval), NA, paste(rval, alpha, sep = ""))
  }
  if (rev) 
    rval <- rev(rval)
  if (register) 
    invisible(rval)
  else return(rval)
}




pal__seq_mint <- function (n, h = 151, c = c(93, 154, NA), l = c(56, 100), power = 0.757679180887372, 
                      gamma = NULL, fixup = TRUE, alpha = 1, palette = NULL, rev = FALSE, 
                      register = NULL, ..., h1, h2, c1, c2, l1, l2, p1, p2, cmax, 
                      c.) 
{
  if (!is.null(gamma)) 
    warning("'gamma' is deprecated and has no effect")
  if (n < 1L) 
    return(character(0L))
  if (!missing(c.)) 
    c <- c.
  if (length(c) == 3L) 
    c <- c[c(1L, 3L, 2L)]
  if (is.character(h)) 
    palette <- h
  pals <- if (!is.null(palette)) {
    as.matrix(hcl_palettes(type = "Sequential", palette = palette)[, 
                                                                   2L:11L])[1L, ]
  }
  else {
    structure(c(if (length(h) < 2L) c(h, NA) else rep_len(h, 
                                                          2L), if (length(c) < 2L) c(c, 0) else rep_len(c, 
                                                                                                        2L), rep_len(l, 2L), if (length(power) < 2L) c(power, 
                                                                                                                                                       NA) else rep_len(power, 2L), if (length(c) < 3L) NA else c[3L], 
                1), .Names = vars.pal)
  }
  if (!missing(h) && !is.character(h)) {
    h <- if (length(h) < 2L) 
      c(h, NA)
    else rep_len(h, 2L)
    pals["h1"] <- h[1L]
    pals["h2"] <- h[2L]
  }
  if (!missing(c) || !missing(c.)) {
    if (length(c) < 2L) 
      c <- c(c, 0)
    pals["c1"] <- c[1L]
    pals["c2"] <- c[2L]
    if (length(c) == 3L) 
      pals["cmax"] <- c[3L]
  }
  if (!missing(l)) {
    l <- rep_len(l, 2L)
    pals["l1"] <- l[1L]
    pals["l2"] <- l[2L]
  }
  if (!missing(power)) {
    power <- if (length(power) < 2L) 
      c(power, NA)
    else rep_len(power, 2L)
    pals["p1"] <- power[1L]
    pals["p2"] <- power[2L]
  }
  if (!missing(fixup)) 
    pals["fixup"] <- as.logical(fixup)
  if (!missing(h1)) 
    pals["h1"] <- h1
  if (!missing(h2)) 
    pals["h2"] <- h2
  if (!missing(c1)) 
    pals["c1"] <- c1
  if (!missing(c2)) 
    pals["c2"] <- c2
  if (!missing(l1)) 
    pals["l1"] <- l1
  if (!missing(l2)) 
    pals["l2"] <- l2
  if (!missing(p1)) 
    pals["p1"] <- p1
  if (!missing(p2)) 
    pals["p2"] <- p2
  if (!missing(cmax)) 
    pals["cmax"] <- cmax
  if (!is.na(pals["h2"]) && pals["h1"] == pals["h2"]) 
    pals["h2"] <- NA
  if (is.character(register) && nchar(register) > 0L) {
    add_hcl_pals(palette = register, type = if (is.na(pals["h2"])) 
      "Sequential (single-hue)"
      else "Sequential (multi-hue)", parameters = pals)
    register <- TRUE
  }
  else {
    register <- FALSE
  }
  if (is.na(pals["h2"])) 
    pals["h2"] <- pals["h1"]
  if (is.na(pals["c2"])) 
    pals["c2"] <- 0
  if (is.na(pals["p2"])) 
    pals["p2"] <- pals["p1"]
  rval <- seq(1, 0, length = n)
  rval <- seqhcl(rval, pals["h1"], pals["h2"], 
                 pals["c1"], pals["c2"], pals["l1"], 
                 pals["l2"], pals["p1"], pals["p2"], 
                 pals["cmax"], as.logical(pals["fixup"]), 
                 ...)
  if (!missing(alpha)) {
    alpha <- pmax(pmin(alpha, 1), 0)
    alpha <- format(as.hexmode(round(alpha * 255 + 1e-04)), 
                    width = 2L, upper.case = TRUE)
    rval <- ifelse(is.na(rval), NA, paste(rval, alpha, sep = ""))
  }
  if (rev) 
    rval <- rev(rval)
  if (register) 
    invisible(rval)
  else return(rval)
}

pal_seq_pur <- function (n, h = 279, c = c(60, 80, NA), l = c(53, 100), power = 0.737201365187713, 
                         gamma = NULL, fixup = TRUE, alpha = 1, palette = NULL, rev = FALSE, 
                         register = NULL, ..., h1, h2, c1, c2, l1, l2, p1, p2, cmax, 
                         c.) 
{
  if (!is.null(gamma)) 
    warning("'gamma' is deprecated and has no effect")
  if (n < 1L) 
    return(character(0L))
  if (!missing(c.)) 
    c <- c.
  if (length(c) == 3L) 
    c <- c[c(1L, 3L, 2L)]
  if (is.character(h)) 
    palette <- h
  pals <- if (!is.null(palette)) {
    as.matrix(hcl_palettes(type = "Sequential", palette = palette)[, 
                                                                   2L:11L])[1L, ]
  }
  else {
    structure(c(if (length(h) < 2L) c(h, NA) else rep_len(h, 
                                                          2L), if (length(c) < 2L) c(c, 0) else rep_len(c, 
                                                                                                        2L), rep_len(l, 2L), if (length(power) < 2L) c(power, 
                                                                                                                                                       NA) else rep_len(power, 2L), if (length(c) < 3L) NA else c[3L], 
                1), .Names = vars.pal)
  }
  if (!missing(h) && !is.character(h)) {
    h <- if (length(h) < 2L) 
      c(h, NA)
    else rep_len(h, 2L)
    pals["h1"] <- h[1L]
    pals["h2"] <- h[2L]
  }
  if (!missing(c) || !missing(c.)) {
    if (length(c) < 2L) 
      c <- c(c, 0)
    pals["c1"] <- c[1L]
    pals["c2"] <- c[2L]
    if (length(c) == 3L) 
      pals["cmax"] <- c[3L]
  }
  if (!missing(l)) {
    l <- rep_len(l, 2L)
    pals["l1"] <- l[1L]
    pals["l2"] <- l[2L]
  }
  if (!missing(power)) {
    power <- if (length(power) < 2L) 
      c(power, NA)
    else rep_len(power, 2L)
    pals["p1"] <- power[1L]
    pals["p2"] <- power[2L]
  }
  if (!missing(fixup)) 
    pals["fixup"] <- as.logical(fixup)
  if (!missing(h1)) 
    pals["h1"] <- h1
  if (!missing(h2)) 
    pals["h2"] <- h2
  if (!missing(c1)) 
    pals["c1"] <- c1
  if (!missing(c2)) 
    pals["c2"] <- c2
  if (!missing(l1)) 
    pals["l1"] <- l1
  if (!missing(l2)) 
    pals["l2"] <- l2
  if (!missing(p1)) 
    pals["p1"] <- p1
  if (!missing(p2)) 
    pals["p2"] <- p2
  if (!missing(cmax)) 
    pals["cmax"] <- cmax
  if (!is.na(pals["h2"]) && pals["h1"] == pals["h2"]) 
    pals["h2"] <- NA
  if (is.character(register) && nchar(register) > 0L) {
    add_hcl_pals(palette = register, type = if (is.na(pals["h2"])) 
      "Sequential (single-hue)"
      else "Sequential (multi-hue)", parameters = pals)
    register <- TRUE
  }
  else {
    register <- FALSE
  }
  if (is.na(pals["h2"])) 
    pals["h2"] <- pals["h1"]
  if (is.na(pals["c2"])) 
    pals["c2"] <- 0
  if (is.na(pals["p2"])) 
    pals["p2"] <- pals["p1"]
  rval <- seq(1, 0, length = n)
  rval <- seqhcl(rval, pals["h1"], pals["h2"], 
                 pals["c1"], pals["c2"], pals["l1"], 
                 pals["l2"], pals["p1"], pals["p2"], 
                 pals["cmax"], as.logical(pals["fixup"]), 
                 ...)
  if (!missing(alpha)) {
    alpha <- pmax(pmin(alpha, 1), 0)
    alpha <- format(as.hexmode(round(alpha * 255 + 1e-04)), 
                    width = 2L, upper.case = TRUE)
    rval <- ifelse(is.na(rval), NA, paste(rval, alpha, sep = ""))
  }
  if (rev) 
    rval <- rev(rval)
  if (register) 
    invisible(rval)
  else return(rval)
}