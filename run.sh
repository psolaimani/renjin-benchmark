R -q -e 'install.packages("devtools")'
R -q -e 'library(devtools);devtools::install_github("bedatadriven/hamcrest",force=T)'
R -q -e 'library(devtools);devtools::install_github("psolaimani/BenchmarkR",force=T)'
# loop through directories
for f in $( find -path './[^.]*' -prune -type d ); do
  echo "-----------------------------------------------"
  # print directory name
  echo $f
  #set counter to 0
  COUNT=0
    while [ $COUNT -le $1 ];
      do
          count_info=`printf "round %s out of %s " "$COUNT" "$1"`
          echo $count_info
          cd $f
          echo "R -q -e 'library(packrat); packrat::restore(); library(benchmarkR); runBenchmark();'"
          R -q -e 'library(packrat); packrat::restore();'
          R -q -e "library(benchmarkR); runBenchmark($2);"
          R -q -e 'print(Sys.getenv(c("BENCH_USR", "BENCH_PWD", "BENCH_HOST", "BENCH_DB", "BENCH_TYPE")))'
          cd ..
          COUNT=$(( $COUNT + 1 ))
      done
  echo "-----------------------------------------------"
done
