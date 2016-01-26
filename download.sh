if [ ! -f ./data/mm9_genes.gtf ]; then 
echo 'downloading mm9_genes.gtf';
gsutil cp gs://benchmarkr/generate_counts/mm9_genes.gtf ./data/; 
fi

if [ ! -f ./data/D2Q2.bam ]; then 
echo 'downloading D2Q2.bam';
gsutil cp gs://benchmarkr/generate_counts/D2Q2.bam ./data/; 
fi

if [ ! -f ./data/D2Q2.bam.bai ]; then 
echo 'downloading D2Q2.bam.bai';
gsutil cp gs://benchmarkr/generate_counts/D2Q2.bam.bai ./data/; 
fi

if [ ! -f ./data/D2Q3.bam ]; then 
echo 'downloading D2Q3.bam';
gsutil cp gs://benchmarkr/generate_counts/D2Q3.bam ./data/; 
fi

if [ ! -f ./data/D2Q3.bam.bai ]; then 
echo 'downloading D2Q3.bam.bai';
gsutil cp gs://benchmarkr/generate_counts/D2Q3.bam.bai ./data/; 
fi

if [ ! -f ./data/D3Q2.bam ]; then 
echo 'downloading D3Q2.bam';
gsutil cp gs://benchmarkr/generate_counts/D3Q2.bam ./data/; 
fi

if [ ! -f ./data/D3Q2.bam.bai ]; then 
echo 'downloading D3Q2.bam.bai';
gsutil cp gs://benchmarkr/generate_counts/D3Q2.bam.bai ./data/; 
fi

if [ ! -f ./data/D3Q3.bam ]; then 
echo 'downloading D3Q3.bam';
gsutil cp gs://benchmarkr/generate_counts/D3Q3.bam ./data/; 
fi

if [ ! -f ./data/D3Q3.bam.bai ]; then 
echo 'downloading D3Q3.bam.bai';
gsutil cp gs://benchmarkr/generate_counts/D3Q3.bam.bai ./data/; 
fi


if [ ! -f ./data/20160126_rppa.csv ]; then 
echo 'downloading 0160126_rppa.csv';
	cd ./data/; 
	wget http://tcga-data.nci.nih.gov/docs/publications/TCGApancan_2014/RPPA_input.csv ./data/; 
fi


