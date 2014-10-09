# Wishbone
The WISHBONE System-On-Chip (SOC) Interconnection Architecture, also knows as WISHBONE Bus, is a free, open-source
standard that defines a common interface among IP Cores in a System-On-Chip. By doing so, it alleviates integration
problems. That in turn, encourages IP reuse which leads to improvements in portability and reliability of the system,
and results in faster time-to-market for the end users.

WISHBONE is intended as a general purpose portable interface that is independent of the underlying semiconductor
technology. As such, its specification defines a set o signals and bus cycles, but does not specify any electrical
information nor enforces a bus topology.

The WISHBONE bus uses a MASTER/SLAVE model of communication. In this model the MASTER entities are capable of driving
the bus, by generating bus cycles, whereas SLAVES entities may only use the bus when instructed/inquired by a MASTER.

# Wishbone Interconnection (INTERCON)
The interconnection is the component responsible for tying all the various subcomponents/entities, MASTERS and SLAVES,
together in a manner that meets all communication and timing needs.

### Implementation Details

* **Uses a shared bus topology**:

    Care must be taken so that just one participant drive the bus at any time.

* **Based on multiplexers.**

    One other tricky part of designing a shared bus inside a FPGA is that bus participants which are not driving the
bus must neither drive a low, nor a high signal on the bus. Typically, this is achieved by setting the signal
drivers to a ”High-Z” state, which means using Tri-State buffers. Since, normally, FPGAs do not have internal
Tri-States buffers a switch logic based on multiplexers was implemented.


* **1 to N multiplexing (1 Masters, N Slaves)**

    The facts that this is a single MASTER implementation and SLAVES may not use the bus when not addressed, the
only care that must be taken it to not overlap the SLAVES memory maps.

* ** Partial address decoding **

    Each slave present in the bus has a corresponding entry in the memory map. Each of this entries consists of a base
    address (BASEADDR) and a size (SIZE). The SIZE corresponds to the effective number of addresses occupied by the
    slave, starting at the BASEADDR. In other words, this SIZE correspond to the maximum OFFSET.

    The decoding process is done in two steps:
    The first step is done by comparators (one for each slave) implemented in this interconnection block. These
    comparators use the base address to select the slave or not. They do this by masking out the OFFSET bits of the
    address and then comparing base adresses. The masking out of the OFFSET bits is acheived using the SIZE.
    The second step is done by a fine decoder inside the selected slave. It will receive just the OFFSET and verify if
    it is valid.

    Using this decoding scheme has the drawback of imposing that the number of addresses used by the slaves must be a
    power of two, even when not all addresses are used. Hence, memory addresses can be waste.

# TODO

1. Better documentation.
2. Improve testbench
