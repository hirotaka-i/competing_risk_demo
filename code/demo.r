library(survival)
library(cmprsk)
library(survminer)

# Read data
df <- read.csv("data/testdata.csv")


# Draw Kaplan-Meier curve
surv_obj <- Surv(time = df$time, event = df$status)
fit <- survfit(surv_obj ~ group, data = df)
png("report/km_curve.png", width = 800, height = 600)
ggsurvplot(fit, data = df, risk.table = TRUE, conf.int = FALSE)
dev.off()

# Now make a group2
df2 <- df
df2$id <- df2$id + 10
df2$group <- 'B'
df2$status[1:2] <- 2 # first two observations, status 0-->2
print(df2)

data = rbind(df, df2)

# KM2
surv_obj <- Surv(time = data$time, event = data$status==1)
fit <- survfit(surv_obj ~ group, data = data)
png("report/km_curve2.png", width = 800, height = 600)
ggsurvplot(fit, data = data, risk.table = TRUE, conf.int = FALSE)
dev.off()

# Cause-specific Cox model taking 2 as censored
cs_cox <- coxph(Surv(time, status == 1) ~ group, data = data)
summary(cs_cox)

# Fine and Gray model taking 2 as competing event
data$groupB <- as.numeric(data$group == 'B')
fg_model <- crr(ftime   = data$time, fstatus = data$status, cov1 = data$groupB)
summary(fg_model)
