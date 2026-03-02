genes <- c("BRCA1", "TP53", "EGFR")
expression <- c(12.5, 45.2, 30.1)
condition <- c("Control", "Treatment", "Treatment")
exp_data <- data.frame(genes, expression, condition)
str(exp_data)

png("expression_plot.png", width=800, height=600)
barplot(exp_data$expression,
        names.arg=exp_data$genes,
        main="Gene Expression Levels",
        xlab="Genes", 
        ylab="Expression",
        col=rainbow(nrow(exp_data))
)
dev.off()