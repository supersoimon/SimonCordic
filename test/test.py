
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def write_angle_byte(dut, index, value):
    # Set the data and select the byte, then raise the write strobe.
    dut.ui_in.value = value
    dut.uio_in.value = index | 0b100
    await ClockCycles(dut.clk, 1)

    # Lower the strobe so the next write has a new rising edge.
    dut.uio_in.value = index
    await ClockCycles(dut.clk, 1)


async def read_output(dut, selector):
    dut.uio_in.value = selector << 4
    await ClockCycles(dut.clk, 1)
    return int(dut.uo_out.value)


@cocotb.test()
async def test_cordic(dut):
    dut._log.info("Starting CORDIC test")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Write a zero-degree angle (17-bit signed value = 0).
    await write_angle_byte(dut, 0, 0)
    await write_angle_byte(dut, 1, 0)
    await write_angle_byte(dut, 2, 0)

    # Start the CORDIC.
    dut.uio_in.value = 0b1000
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0

    # Select busy output and wait for completion.
    await ClockCycles(dut.clk, 1)
    busy = 1

    for _ in range(30):
        busy = await read_output(dut, 6)
        if (busy & 1) == 0:
            break

    assert (busy & 1) == 0, "CORDIC did not finish within 30 cycles"

    # Read X coordinate.
    x0 = await read_output(dut, 0)
    x1 = await read_output(dut, 1)
    x2 = await read_output(dut, 2)

    # Read Y coordinate.
    y0 = await read_output(dut, 3)
    y1 = await read_output(dut, 4)
    y2 = await read_output(dut, 5)

    x = x0 | (x1 << 8) | ((x2 & 1) << 16)
    y = y0 | (y1 << 8) | ((y2 & 1) << 16)

    # Convert 17-bit two's-complement values to signed integers.
    if x & (1 << 16):
        x -= 1 << 17
    if y & (1 << 16):
        y -= 1 << 17

    dut._log.info(f"CORDIC result: X={x}, Y={y}")

    # Basic sanity check: the result should not be entirely zero.
    assert x != 0 or y != 0, "CORDIC returned zero for both coordinates"

    # Check that the iteration counter returned to zero.
    step = await read_output(dut, 7)
    assert step == 0, f"Expected step=0, got {step}"

    dut._log.info("CORDIC test passed")
