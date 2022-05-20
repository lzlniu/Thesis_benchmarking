#!/usr/bin/env Rscript

## Generate plots for benchmarking of STRING protein pairs.
## If requested, also generate the corresponding interactive plots.
## These can be useful to check scores along the benchmarking curve
## or to select specific curves only
## Input:   tab-separated file containing columns with cumulative TP and FP
##          counts("tp_cum", "fp_cum") and dataset labels
## Output:  interactive benchmark plot html (FP vs TP for each dataset)
## Call:    phys-score-benchmark-plots.R <input file> <output file> \
##          <column name of the parameter to be compared> \
##          <column name(s) of plot title labels> \
##          <"interact" (optional)>

## module load tools
## module load gcc
## module load R/3.5.0

## example call: ./string_score_benchmark_plots.1.1.R no_blacklist_ggp_only_out_benchmark_with_prec.tsv no_blacklist_ggp_only_out_benchmark_with_prec_out score label

library(ggplot2)
suppressPackageStartupMessages(library(plotly))

options(warn=1)
options(scipen = 10000) # switch off scientific notation

# set ggplot theme and increase right margin to avoid x axis labels being cut off
theme_set(theme_bw())
theme_update(plot.margin = margin(t = 5.5, r = 15, b = 5.5, l = 5.5))
# plot sizes for combined plots (taking legend into account)
plotwidth_comb <- 8
plotheight_comb <- 6

# get all command line arguments
command_args <- commandArgs(trailingOnly = TRUE)
# files
in_file <- command_args[1]
out_file <- gsub(".pdf|.html", "", command_args[2])
# column name of parameter to be compared
variant_col <- command_args[3]
# generate interactive plot as well?
# all remaining arguments: column name(s) of plot labels (in addition to taxon ID)
if (tail(command_args, n = 1) == "interact") {
  interact <- TRUE
  labels_col <- head(command_args[-(1:3)], n = -1)
} else {
  interact <- FALSE
  labels_col <- command_args[-(1:3)]
}

# import TP + FP count data
pp_data <- read.csv(in_file, sep = "\t", stringsAsFactors = TRUE)
# keep order of input labels for plotting and legend order
pp_data$label <- factor(pp_data$label, levels = unique(pp_data$label))
# extract taxon identifier from STRING IDs
#taxid <- gsub("\\..*$", "", pp_data[1,1])

# generate plot labels
if (length(labels_col) >= 1) {
  plot_label <- unique(pp_data[[labels_col]])
  #print (pp_data[, c(labels_col)])
  #label2 <- unique(pp_data[, c(labels_col)])
  #plot_label <-labels_col 
  #print(plot_label)
  #plot_label <- paste(taxid, label2, sep = ', ')
} else {
 # plot_label <- taxid
}

# plain FP vs TP plot
fp_tp <- ggplot(pp_data, aes(x = fp_cum, y = tp_cum, col=.data[[labels_col]], key = score)) + #col = .data[[variant_col]] if you want to color by score
  scale_colour_manual(values=c("#8dd3c7", "#ffffb3", "#bebada", "#fb8072", "#80b1d3", "#fdb462", "#b3de69", "#fccde5", "#ccebc5", "#bc80bd"))+
#prec_score <- ggplot(pp_data, aes(x = precision, y = score, col=.data[[labels_col]], key = score)) + #col = .data[[variant_col]] if you want to color by score
  #geom_path(size = .05) +
  geom_path() +
  # scale_y_continuous(breaks=seq(0,5000,1000)) +
  # scale_y_continuous(breaks=seq(0,115000,25000)) +
  labs(title = paste0("Protein pairs ranked from high to low scores"),
  # labs(title = paste0("Gene-disease pairs ranked from high to low scores"),
       x = "Cumulative FP count", y = "Cumulative TP count") +
       #x = "Precision", y = "Score") +
  theme(legend.title = element_blank())
#ggsave(paste0(out_file, ".pdf"), plot = prec_score, width = plotwidth_comb, height = plotheight_comb)
ggsave(paste0(out_file, ".pdf"), plot = fp_tp, width = plotwidth_comb, height = plotheight_comb)

if (interact == TRUE) {
  # convert into interactive plot
  fp_tp_ly <- ggplotly(fp_tp, source = "select", tooltip = c("key", "x", "y"))
  htmlwidgets::saveWidget(fp_tp_ly, paste0(out_file, ".html"))
}
