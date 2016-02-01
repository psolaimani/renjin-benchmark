
.libPaths("~/R/libs")
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


files = list.files(path = ".", pattern = "rppa.R", full.names = T, recursive = T)

for (file in files){
cat(sprintf("benchmarking: %s\n", file))
  for (x in 1:NRUNS){
    cat(sprintf("\t>>>Run %i\n", x))
    benchmarkSource(file=file)
  }
cat(sprintf("finished benchmarking: %s\n", file))
}

# Get credentials from injected JVM enviroment variables
BENCH_USR='benchmarkR_user'
BENCH_PWD='Access4benchmarkR_user'
BENCH_HOST='173.194.246.104'
BENCH_DB='benchmarkR'
BENCH_TYPE='mysql'
conn <- Sys.getenv(c("BENCH_USR", "BENCH_PWD", "BENCH_HOST", "BENCH_DB", "BENCH_TYPE"))
benchDBReport( usr = conn[[1]], pwd = conn[[2]], host_address = conn[[3]], db_name = conn[[4]], con_type = conn[[5]] )

benchGetter(target = "benchmarks")
