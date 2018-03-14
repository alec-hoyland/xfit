# procrustes

Force-fit [Xolotl]() objects so that they satisfy an arbitrary set of constraints. 

![](./images/bed.png) 


# What?

![](https://user-images.githubusercontent.com/6005346/37379826-e395ecdc-270b-11e8-914e-bdb53ef62d26.png)

Let's say you start with the neuron on the left. You're unhappy with it, because:

1. it's voltage troughs don't go down to -70 mV
2. The slow wave goes past -40 mV
3. Its spikes go below the slow wave
4. It doesn't have a burst frequency of .5 Hz
5. It doesn't have a duty cycle of .3

What if you could make this neuron do what you want it to? `procrustes` fiddles with parameters in the model till it does what it should (on the right).

Right now, you can use two algorithms: 

1. `patternsearch` which is deterministic, and is a glorified form of gradient descent
2. `particleswarm` which is based on how flocks of birds fly and avoid predators. It's stochastic 

The bottom plot shows how these algorithms perform. Using `particleswarm`, we can go from the initial neuron to the target neuron in around 5 minutes on a quad-core laptop. 


# Installation 

Get this repo from within `MATLAB` using my package manager:

```
% copy and paste this code in your MATLAB prompt
urlwrite('http://srinivas.gs/install.m','install.m'); 
install sg-s/srinivas.gs_mtools % you'll need this
install sg-s/procrustes 
install sg-s/xolotl
```

or use git if you plan to develop this further: 

```
git clone https://github.com/sg-s/srinivas.gs_mtools
git clone https://github.com/sg-s/procrustes
git clone https://github.com/sg-s/xolotl
```

Finally, make sure you [configure MATLAB so that it is set up to delete files permanently](https://www.mathworks.com/help/matlab/ref/delete.html). Otherwise you will end up with a very large number of temporary files in your trash!


# Usage 

Look at `tests/fine_tune_neuron.m` for an example that has been worked out. 


# License

`procrustes` is free software. GPL v3. 