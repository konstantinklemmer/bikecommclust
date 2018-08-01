# "Community structures, interactions and dynamics in London's bicycle sharing network" - complementary code

![](https://konstantinklemmer.github.io/images/research/06.png)

This repository contains the complementary code for the paper "Community structures, interactions and dynamics in London's bicycle sharing network" ([arXiv:1804.05584](https://arxiv.org/abs/1804.05584)). This includes the code for data preparation, processing and creation of figures (all done in R) as well as the data analysis (done using [Infomap](https://github.com/mapequation/infomap)). We also provide the generated network dataset and the output dataset (community assignment) from the community detection analysis. These can be found in the `/data/` folder. The network edgelists are also hosted on the Index of [Complex Networks](https://icon.colorado.edu/) at CU Boulder.

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
./Infomap edges.txt outputtest/ -N 20 --tree --map --directed --include-self-links if needed
```
Where the `edges.txt` file is either the aggregated OD-matrix `/data/edges.txt` or the 1h interval matrices from `/data/edges_per_hour/edges{0,...,23}.txt`.

## Citation

```
@misc{munozmendez2018,
	Author = {Fernando Munoz-Mendez and Konstantin Klemmer and Ke Han and Stephen Jarvis},
	Title = {Community structures, interactions and dynamics in London's bicycle sharing network},
	Year = {2018},
	Eprint = {arXiv:1804.05584},
}
```

## Contact

Should you have any questions or suggestions regarding this paper, please contact k.klemmer_AT_warwick.ac.uk