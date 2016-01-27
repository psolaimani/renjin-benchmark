cd ./scripts/

#if [ ! -f ./mm9_genes.gtf ]; then
#echo 'downloading mm9_genes.gtf';
#gsutil cp gs://benchmarkr/generate_counts/mm9_genes.gtf ./;
#fi

#if [ ! -f ./D2Q2.bam ]; then
#echo 'downloading D2Q2.bam';
#gsutil cp gs://benchmarkr/generate_counts/D2Q2.bam ./;
#fi

#if [ ! -f ./D2Q2.bam.bai ]; then
#echo 'downloading D2Q2.bam.bai';
#gsutil cp gs://benchmarkr/generate_counts/D2Q2.bam.bai ./;
#fi

#if [ ! -f ./D2Q3.bam ]; then
#echo 'downloading D2Q3.bam';
#gsutil cp gs://benchmarkr/generate_counts/D2Q3.bam ./;
#fi

#if [ ! -f ./D2Q3.bam.bai ]; then
#echo 'downloading D2Q3.bam.bai';
#gsutil cp gs://benchmarkr/generate_counts/D2Q3.bam.bai ./;
#fi

#if [ ! -f ./D3Q2.bam ]; then
#echo 'downloading D3Q2.bam';
#gsutil cp gs://benchmarkr/generate_counts/D3Q2.bam ./;
#fi

#if [ ! -f ./D3Q2.bam.bai ]; then
#echo 'downloading D3Q2.bam.bai';
#gsutil cp gs://benchmarkr/generate_counts/D3Q2.bam.bai ./;
#fi

#if [ ! -f ./D3Q3.bam ]; then
#echo 'downloading D3Q3.bam';
#gsutil cp gs://benchmarkr/generate_counts/D3Q3.bam ./;
#fi

#if [ ! -f ./D3Q3.bam.bai ]; then
#echo 'downloading D3Q3.bam.bai';
#gsutil cp gs://benchmarkr/generate_counts/D3Q3.bam.bai ./;
#fi

if [ ! -f data_20160126_rppa.csv ]; then
echo 'downloading data_20160126_rppa.csv';
	wget http://tcga-data.nci.nih.gov/docs/publications/TCGApancan_2014/RPPA_input.csv;
	mv RPPA_input.csv data_20160126_rppa.csv
fi
