# ============================================================
# MFSD Financial Health Dashboard – Server Launcher
# Run this on the machine at 192.168.50.112
# Dashboard will be accessible at: http://192.168.50.112:3838
# ============================================================

# Install any missing packages automatically
required <- c("flexdashboard","shiny","DBI","odbc","dplyr",
               "plotly","DT","scales","tidyr")
missing  <- required[!required %in% rownames(installed.packages())]
if (length(missing) > 0) {
  message("Installing missing packages: ", paste(missing, collapse=", "))
  install.packages(missing, repos = "https://cloud.r-project.org")
}

# Path to the dashboard Rmd file (adjust if needed)
rmd_path <- normalizePath(
  file.path(dirname(sys.frame(1)$ofile), "MF_Dashboard.Rmd"),
  mustWork = FALSE
)

if (!file.exists(rmd_path)) {
  # Fallback: look in the same folder as this script
  rmd_path <- file.path(getwd(), "MF_Dashboard.Rmd")
}

message("Starting MFSD Dashboard...")
message("URL: http://192.168.50.112:3838")
message("Press Ctrl+C to stop the server.\n")

rmarkdown::run(
  rmd_path,
  shiny_args = list(
    host          = "0.0.0.0",   # listen on all network interfaces
    port          = 3838,
    launch.browser = FALSE       # don't open browser on the server itself
  )
)
