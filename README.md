# LondonBike Dataset - complementary code for "Community structures, interactions and dynamics in London's bicycle sharing network" 

![](https://konstantinklemmer.github.io/images/research/06.png)

This repository contains the complementary code for the paper "Community structures, interactions and dynamics in London's bicycle sharing network" ([arXiv:1804.05584](https://arxiv.org/abs/1804.05584)). This includes the code for data preparation, processing and creation of figures (all done in R) as well as the data analysis (done using [Infomap](https://github.com/mapequation/infomap)). We also provide the generated network dataset and the output dataset (community assignment) from the community detection analysis. These can be found in the `/data/` folder. The network edgelists are also hosted on the [Index of Complex Networks](https://icon.colorado.edu/) at CU Boulder.

## Community detection

Our community detection using the *Louvain algorithm*, *Greedy modularity maximization* and *Random walks* is done with *R* (v3.4.2) using the `igraph` package. These analyses can be found in the `/R/` folder. 

The *Infomap* community detection is done using version v0.19.3. Instructions on how to run *Infomap* on your machine can be found [here](http://www.mapequation.org/code.html).

Once initialized, we create an output directory:
```
#create output directory
mkdir outputtest
```
We then run *Infomap* with the following settings:
```
#run infomap (given valid edges.txt input)
./Infomap edges.txt outputtest/ -N 20 --tree --map --directed #--include-self-links if needed
```
Where the `edges.txt` file is either the aggregated OD-matrix `/data/edges.txt` or the 1h interval matrices from `/data/edges_per_hour/edges{0,...,23}.txt`.

## Citation

```
@inproceedings{Munoz-Mendez2018,
	address = {New York, New York, USA},
	author = {Munoz-Mendez, Fernando and Klemmer, Konstantin  and Han, Ke and Jarvis, Stephen},
	booktitle = {Proceedings of the 2018 ACM International Joint Conference and 2018 International Symposium on Pervasive and Ubiquitous Computing and Wearable Computers - UbiComp '18},
	doi = {10.1145/3267305.3274156},
	file = {::},
	isbn = {9781450359665},
	keywords = {Bikesharing,clustering,community detection,spatio-temporal analysis,urban mobility},
	pages = {1015--1023},
	publisher = {ACM Press},
	title = {{Community Structures, Interactions and Dynamics in London's Bicycle Sharing Network}},
	url = {http://dl.acm.org/citation.cfm?doid=3267305.3274156},
	year = {2018}
}
```

## Contact

Should you have any questions or suggestions regarding this paper, please contact k.klemmer_AT_warwick.ac.uk.
