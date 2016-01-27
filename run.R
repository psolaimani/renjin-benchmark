require(org.renjin.benchmarkr)
require(benchmarkR)
require(RMySQL)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  NRUNS <- as.integer(args[1])
  cat(sprintf("Using %i runs per benchmark\n", NRUNS))
} else {
  NRUNS <- 1
  cat(sprintf("Using default number of runs (%i)\n", as.integer(NRUNS)))
}


files = list.files(path = ".", pattern = "20160126_rppa.R", full.names = T, recursive = T)
print(files)

for (file in files){
cat(sprintf("benchmarking: %s\n", file))
  for (x in 1:NRUNS){
    cat(sprintf("\t>>>Run %i\n", x))
    benchmarkSource(file=file)
  }
cat(sprintf("finished benchmarking: %s\n", file))
}

# Get credentials from injected JVM enviroment variables
conn <- Sys.getenv(c("BENCH_USR", "BENCH_PWD", "BENCH_CONN"))
benchDBReport( usr = conn[[1]], pwd = conn[[2]], con_str = conn[[3]] )
