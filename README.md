# Brain-Machine Interface
The design a neural decoder designed to drive a hypothetical prosthetic device

### Description
The following code provide the design a neural decoder designed to drive a hypothetical prosthetic device. This is a realistic and difficult task in brain-machine interfacing. There are provided spike trains recorded from a monkey's brain, as it repeatedly performs an arm movement task. The algorithm was estimated from these data, the precise trajectory of the monkey's hand as he reaches for the target. This was a continuous estimation task. Over the course of each spike train, there was estimated the X & Y position of the monkey's hand at each moment in time.

### Data
Training data are provided in the form of a MATLAB data file. The *.mat* file has a single variable named trial, which is a structure of dimensions (100 trials) x (8 reaching angles). The structure contains spike trains recorded simultaneously from 98 neural units while the monkey reached 182 times along each of 8 different reaching angles (where the trials of different reaching angles were interleaved). The neural data includes both well isolated single-neuron units (~ 30% of all units), as well as multi-neuron units. The structure also contains the monkey’s arm trajectory on each trial. On each trial, both the neural data and arm trajectory are taken from 300 ms before movement onset until 100 ms after movement end.

The spike train recorded from the i-th unit on the n-th trial of the k-th reaching angle is contained in trial(n,k).spikes(i,:), where i = 1, . . . , 98, n = 1, . . . , 100, and k = 1, . . . ,8. A spike train is represented as a sequence of zeros and ones, where time is discretized in 1 ms steps. A zero indicates that the unit did not spike in the 1 ms bin, whereas a one indicates that the unit spiked once in the 1 ms bin. Thus, a spike train of duration T ms is represented by a 1xT vector.

The three-dimensional arm trajectory recorded on the nth trial of the k-th reaching angle is contained in trial(n,k).handPos, which is a 3xT matrix of the hand position (in mm) at each 1 ms time step. On each trial, the data in spikes and handPos are aligned in time. In this task, the monkey reached to targets on a fronto-parallel screen. Most of the arm movement was in the plane of the screen along the horizontal (handPos(1,:)) and vertical (handPos(2,:)) directions. The movement perpendicular to the plane of the screen (handPos(3,:)) was relatively small. The indices k = 1, . . . ,8 correspond to reaching angles (30/180π, 70/180π, 110/180π, 150/180π, 190/180π,
230/180π, 310/180π, 350/180π) respectively. The reaching angles are not evenly spaced around the circle due to experimental constraints that are beyond the scope of this problem set.

(The neural data have been generously provided by the laboratory of Prof. Krishna Shenoy at Stanford University)
