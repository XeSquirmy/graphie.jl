using GLMakie
using LSL

begin
    stream = resolve_streams(timeout=2.0)
    inlet = StreamInlet(stream[1])

    sensor_start = 10
    sensor_end = 14
    sensor_count = 14

    sbuf = zeros(Float32, sensor_count)
    hertz = 45.0

    fig = Figure()
    display(fig)
    sleep(1.0)

    sdataX = Observable{Vector{Float64}}[]
    sdataY = Observable{Vector{Float32}}[]
    axs = Axis[]

    for sensor in 1:sensor_end - sensor_start
        x = Observable{Vector{Float64}}(Float64[])
        y = Observable{Vector{Float32}}(Float32[])

        ax = Axis(fig[sensor, 1])
        scatterlines!(ax, x, y; color=RGBf(1.0 / Float64(sensor), 0, 0))

        push!(sdataX, x)
        push!(sdataY, y)
        push!(axs, ax)
    end

    while true
        ts = pull_sample!(s, inlet, timeout=1.0) |> first

        for sensor in 1:sensor_end - sensor_start
            cursor = sensor + sensor_start - 1

            x = sdataX[cursor]
            y = sdataY[cursor]

            if s[cursor] |> iszero
                continue
            end

            push!(x.val, ts)
            push!(y.val, s[cursor])

            notify.((x, y))
        end

        reset_limits!.(axs)
        sleep(1.0 / hertz)
    end
end