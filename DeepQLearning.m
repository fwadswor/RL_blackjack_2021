%Deep Q learning script

buffer_net = network;
target_net = network;

buffer_net.numInputs = 4;
buffer_net.numLayers = 2
