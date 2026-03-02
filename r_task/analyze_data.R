data <- read.csv("/home/khokholmongolll/bioinf/hw_bioinformatics/r_task/sample_data.csv")
head(data)
mean(data$Score)
treat_df <-data[data$Group == 'Treatment', ]
head(treat_df)
max(treat_df$Score)
png("/home/khokholmongolll/bioinf/hw_bioinformatics/r_task/score_boxplot.png", width=800, height=600)
boxplot(Score ~ Group, 
        data = data,
        main = "Score Distribution by Group",
        xlab = "Group", 
        ylab = "Score",
        col = c("lightblue", "lightgreen"))
dev.off()