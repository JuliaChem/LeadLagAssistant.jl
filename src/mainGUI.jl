# Created at Instituto Tecnológico de Orizaba
# Carolina Ayerim Bolaños Ruiz
# Mauricio Rivadeneyra Hernández
# Kelvyn Baruc Sánchez Sánchez
# Eusebio Bolaños Reynoso
# Joaquín Pinto Espinoza

using Gtk.ShortNames, ControlSystems, Plots, SymPy
using Mustache, DataFrames, DefaultApplication, Dates, Printf
import Latexify
pyplot()

# CSS Provider
global style_file = joinpath(dirname(Base.source_path()), "style.css")

# Icons path
global ico1 = joinpath(dirname(Base.source_path()), "icons\\icon_new.ico")
global ico2 = joinpath(dirname(Base.source_path()), "icons\\icon_close.ico")
global ico3 = joinpath(dirname(Base.source_path()), "icons\\icon_pdf.ico")

# Images Path
global rootStep = "C:\\Windows\\Temp\\rootStep.png"
global rootRamp = "C:\\Windows\\Temp\\rootRamp.png"
global rootRL = "C:\\Windows\\Temp\\rootRL.png"

global lagStep = "C:\\Windows\\Temp\\lagStep.png"
global lagRamp = "C:\\Windows\\Temp\\lagRamp.png"
global lagRL = "C:\\Windows\\Temp\\lagRL.png"

global leadStep = "C:\\Windows\\Temp\\leadStep.png"
global leadRamp = "C:\\Windows\\Temp\\leadRamp.png"
global leadRL = "C:\\Windows\\Temp\\leadRL.png"

global leadlagStep = "C:\\Windows\\Temp\\leadlagStep.png"
global leadlagRamp = "C:\\Windows\\Temp\\leadlagRamp.png"
global leadlagRL = "C:\\Windows\\Temp\\leadlagRL.png"

# TF output .tex file
global lagTFopen = "C:\\Windows\\Temp\\lagTFopen.tex"
global lagTFcerr = "C:\\Windows\\Temp\\lagTFcerr.tex"
global lagTFcomp = "C:\\Windows\\Temp\\lagTFcomp.tex"
global lagTFcerrcomp = "C:\\Windows\\Temp\\lagTFcerrcomp.tex"

# Global status variables
global rootLocusStatus = 0
global lagStatusTF = 0

function LLAGUI()
    # Environmental variable to allow Windows decorations
    ENV["GTK_CSD"] = 0

    # Style for CSS
    global provider = CssProviderLeaf(filename = style_file)

    # Measurement of screen-size to allow compatibility to all screen devices
    global w, h = screen_size()

    # DataFrame for RL-Assistant results
    global rootLocusTable = DataFrame(Parameter = String[], Value = String[])

    # main Window
    mainWin = Window()
    set_gtk_property!(mainWin, :title, "LeadLagAssistant v0.1.0")
    set_gtk_property!(mainWin, :width_request, w*0.6)
    set_gtk_property!(mainWin, :height_request, h*0.75)
    set_gtk_property!(mainWin, :window_position, 3)
    set_gtk_property!(mainWin, :resizable, false)

    # Apply style to mainWin from CSS
    set_gtk_property!(mainWin, :name, "mainWin")

    # Grid to locate widgets
    mainGrid = Grid()

    ############################################################################
    # Toolbar
    ############################################################################
    newTB = ToolButton("gtk-new")
    imgnewTB = Image()
    set_gtk_property!(imgnewTB, :file, ico1)
    set_gtk_property!(newTB, :icon_widget, imgnewTB)
    set_gtk_property!(newTB, :label, "New")
    set_gtk_property!(newTB, :tooltip_markup, "New analysis")
    signal_connect(newTB, :clicked) do widget
        global rootLocusTable
        empty!(imgRoot)
        empty!(imgRamp)
        empty!(imgRL)

        empty!(gRootUpTFImg)
        empty!(gRootBTFImg)

        empty!(imgLagRoot)
        empty!(imgLagRamp)
        empty!(imgLagRL)

        empty!(lagTFCompCerrImg)
        empty!(lagTFCompOpenImg)
        empty!(lagTFOpenImg)
        empty!(lagTFCerrImg)
        empty!(lagTFCompImg)

        listRoot[1,2] = "unsolved"
        listRoot[2,2] = "unsolved"
        listRoot[3,2] = "unsolved"
        listRoot[4,2] = "unsolved"
        listRoot[5,2] = "unsolved"
        listRoot[6,2] = "unsolved"
        listRoot[7,2] = "unsolved"
        listRoot[8,2] = "unsolved"

        set_gtk_property!(rootNumTf, :text, "")
        set_gtk_property!(rootDenTf, :text, "")
        set_gtk_property!(lagNumTf, :text, "")
        set_gtk_property!(lagDenTf, :text, "")
        set_gtk_property!(lagKv, :text, "")
        set_gtk_property!(lagT, :text, "")

        set_gtk_property!(exportTB, :sensitive, false)
        set_gtk_property!(suggesLabelRoot, :label, "")
        empty!(rootLocusTable)

        @sigatom set_gtk_property!(lagCheck, :active, false)
        global rootLocusStatus = 0
        global lagStatusTF = 0
    end

    closeTB = ToolButton("gtk-close")
    imgcloseTB = Image()
    set_gtk_property!(imgcloseTB, :file, ico2)
    set_gtk_property!(closeTB, :icon_widget, imgcloseTB)
    set_gtk_property!(closeTB, :label, "Close")
    set_gtk_property!(closeTB, :tooltip_markup, "Close program")
    signal_connect(closeTB, :clicked) do widget
        destroy(mainWin)
    end

    runTB = ToolButton("gtk-media-play")
    set_gtk_property!(runTB, :label, "Solve")
    signal_connect(runTB, :clicked) do widget
        if get_gtk_property(nb, :page, Int) == 0

            global rootNumTfData = get_gtk_property(rootNumTf, :text, String)
            global rootDenTfData = get_gtk_property(rootDenTf, :text, String)

            global rootNumTfClean = split(rootNumTfData,",")
            global rootDenTfClean = split(rootDenTfData,",")

            try
                # Check t0 only numbers
                for i=1:length(rootNumTfClean)
                    parse(Float64, rootNumTfClean[i])
                end

                for i=1:length(rootDenTfClean)
                    parse(Float64, rootDenTfClean[i])
                end

                # Convert to numeric values from string
                global rootArrayNum = Array{Float64}(undef, length(rootNumTfClean))
                for i=1:length(rootNumTfClean)
                    a = parse(Float64, rootNumTfClean[i])
                    rootArrayNum[i] =  a
                end

                global rootArrayDen = Array{Float64}(undef, length(rootDenTfClean))
                for i=1:length(rootDenTfClean)
                    a = parse(Float64, rootDenTfClean[i])
                    rootArrayDen[i] =  a
                end

                if length(rootArrayNum) < length(rootArrayDen)
                    global Gopen = tf(rootArrayNum,rootArrayDen)
                    global Gcerr = feedback(Gopen)

                    # Step plot
                    yRootStep, tRootStep, xRootStep = step(Gcerr)

                    # Step ramp
                    global Gramp = tf([1],[1,0])
                    yRootRamp, tRootRamp, xRootRamp = step(Gcerr*Gramp)

                    plotRootStep = plot(tRootStep, yRootStep,
                    xlabel = "Time (sec)",
                    ylabel = "Amplitude",
                    framestyle = :box)

                    plotRootRamp = plot(tRootRamp,yRootRamp,
                    xlabel = "Time (sec)",
                    ylabel = "Amplitude",
                    framestyle = :box)

                    plotRootRL =  rlocusplot(Gopen, framestyle=:box, title = "", lw=1, lc = :blue)

                    savefig(plotRootStep, rootStep)
                    savefig(plotRootRamp, rootRamp)
                    savefig(plotRootRL, rootRL)

                    set_gtk_property!(imgRoot, :file, rootStep)
                    set_gtk_property!(imgRamp, :file, rootRamp)
                    set_gtk_property!(imgRL, :file, rootRL)

                    # Steady state analysis
                    ωn, ζ, ps = damp(Gcerr)

                    # Kv
                    s = symbols("s", real=true)

                    global GrealNum = 0
                    global GrealDen = 0

                    for i=1:length(rootArrayNum)
                        global GrealNum = GrealNum + rootArrayNum[i]*s^(length(rootArrayNum)-i)
                    end

                    for i=1:length(rootArrayDen)
                        global GrealDen = GrealDen + rootArrayDen[i]*s^(length(rootArrayDen)-i)
                    end

                    Greal = GrealNum/GrealDen

                    Kv = limit(Greal*s, s, 0)

                    # TFopen image
                    msgtex = Latexify.latexify(string("G(s)=", simplify(Greal)))
                    L =
                    """\\documentclass[border=2pt]{standalone}
                    \\usepackage{mathtools}
                    \\begin{document}
                    {{:msg}}
                    \\end{document}
                    """

                    out = render(L, msg = msgtex)
                    filename = "C:\\Windows\\Temp\\TFopen.tex"

                    Base.open(filename, "w") do file
                        write(file, out)
                    end

                    run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "TFopen.tex"`)
                    run(`pdftocairo -png -r 300 "C:\\Windows\\Temp\\TFopen.pdf" "C:\\Windows\\Temp\\TFopen"`)

                    set_gtk_property!(gRootUpTFImg, :file, "C:\\Windows\\Temp\\TFopen-1.png")

                    # TFcerr image
                    GcerrTex = simplify(Greal/(Greal+1))
                    msgtexcerr = Latexify.latexify(string("G(s)=", GcerrTex))
                    L =
                    """\\documentclass[border=2pt]{standalone}
                    \\usepackage{mathtools}
                    \\begin{document}
                    {{:msg}}
                    \\end{document}
                    """

                    out = render(L, msg = msgtexcerr)
                    filename = "C:\\Windows\\Temp\\TFcerr.tex"

                    Base.open(filename, "w") do file
                        write(file, out)
                    end

                    run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "TFcerr.tex"`)
                    run(`pdftocairo -png -r 300 "C:\\Windows\\Temp\\TFcerr.pdf" "C:\\Windows\\Temp\\TFcerr"`)

                    set_gtk_property!(gRootBTFImg, :file, "C:\\Windows\\Temp\\TFcerr-1.png")

                    # Overshoot
                    PO=100*exp((-ζ[1]*pi)/(sqrt(1-ζ[1]^2)))

                    # Settling time
                    Ts = -log(0.05)/(ζ[1]*ωn[1])

                    # Peak Time Response
                    Tp = π/(ωn[1]*sqrt(1 - ζ[1]^2))

                    # #Rise time
                    beta = atan(ωn[1]/(ωn[1]*ζ[1]))
                    tR = (π-beta)/ωn[1]

                    listRoot[1,2] = ωn[1]
                    listRoot[2,2] = ζ[1]
                    listRoot[3,2] = string(ps)
                    listRoot[4,2] = N(Kv)
                    listRoot[5,2] = tR
                    listRoot[6,2] = Tp
                    listRoot[7,2] = PO
                    listRoot[8,2] = Ts

                    push!(rootLocusTable,("Wn",listRoot[1,2]))
                    push!(rootLocusTable,("L",listRoot[2,2]))
                    push!(rootLocusTable,("Closed-loop Poles", listRoot[3,2]))
                    push!(rootLocusTable,("Kv", listRoot[4,2]))
                    push!(rootLocusTable,("Rise Time", listRoot[5,2]))
                    push!(rootLocusTable,("Peak Time", listRoot[6,2]))
                    push!(rootLocusTable,("Overshoot", listRoot[7,2]))
                    push!(rootLocusTable,("Settling Time", listRoot[8,2]))

                    set_gtk_property!(exportTB, :sensitive, true)

                    if PO > 20
                        msg1 = @sprintf("Based on the overshoot: %2.4f you should use a Lead Network", PO)
                        set_gtk_property!(suggesLabelRoot, :label, msg1)
                    end

                    if N(Kv) < 5
                        msg1 = @sprintf("Based on Kv: %2.4f you should use a Lag Network", N(Kv))
                        set_gtk_property!(suggesLabelRoot, :label, msg1)
                    end

                    if (PO > 20) & (N(Kv) < 5)
                        msg1 = @sprintf("You should use a Lead-Lag Network")
                        set_gtk_property!(suggesLabelRoot, :label, msg1)
                    end

                    global rootLocusStatus = 1
                else
                    warn_dialog("Numerator´s order must be lower than denominator", mainWin)
                    set_gtk_property!(rootNumTf, :text, "")
                    set_gtk_property!(rootDenTf, :text, "")
                end
                catch
                    warn_dialog("Enter only numbers!", mainWin)
                    set_gtk_property!(rootNumTf, :text, "")
                    set_gtk_property!(rootDenTf, :text, "")
                end
        end
        # Execute lag compensator
        if get_gtk_property(nb, :page, Int) == 1
            global lagNumTfData = get_gtk_property(lagNumTf, :text, String)
            global lagDenTfData = get_gtk_property(lagDenTf, :text, String)
            global lagKvData = get_gtk_property(lagKv, :text, String)
            global lagTData = get_gtk_property(lagT, :text, String)

            global lagNumTfClean = split(lagNumTfData,",")
            global lagDenTfClean = split(lagDenTfData,",")
            global lagKvClean = split(lagKvData,",")
            global lagTClean = split(lagTData,",")


            try
                # Check t0 only numbers
                for i=1:length(lagNumTfClean)
                    parse(Float64, lagNumTfClean[i])
                end

                for i=1:length(lagDenTfClean)
                    parse(Float64, lagDenTfClean[i])
                end

                # Convert to numeric values from string
                global lagArrayNum = Array{Float64}(undef, length(lagNumTfClean))
                for i=1:length(lagNumTfClean)
                    a = parse(Float64, lagNumTfClean[i])
                    lagArrayNum[i] =  a
                end

                global lagArrayDen = Array{Float64}(undef, length(lagDenTfClean))
                for i=1:length(lagDenTfClean)
                    a = parse(Float64, lagDenTfClean[i])
                    lagArrayDen[i] =  a
                end

                global lagStatusTF = 1
            catch
                warn_dialog("Enter only numbers!", mainWin)
                set_gtk_property!(lagNumTf, :text, "")
                set_gtk_property!(lagDenTf, :text, "")
            end

            if lagStatusTF == 1
                if length(lagKvClean) > 1
                    warn_dialog("Enter only 1 value for Kv", mainWin)
                    set_gtk_property!(lagKv, :text, "")
                else
                    try
                        parse(Float64, lagKvClean[1])

                        global lagKvNum = parse(Float64, lagKvClean[1])
                    catch
                        warn_dialog("Enter only numbers!", mainWin)
                        set_gtk_property!(lagKv, :text, "")
                    end
                end

                if length(lagTClean) > 1
                    warn_dialog("Enter only 1 value for T", mainWin)
                    set_gtk_property!(lagT, :text, "")
                else
                    try
                        parse(Float64, lagTClean[1])

                        global lagTNum = parse(Float64, lagTClean[1])
                    catch
                        warn_dialog("Enter only numbers!", mainWin)
                        set_gtk_property!(lagT, :text, "")
                    end
                end

                try
                    if length(lagArrayNum) < length(lagArrayDen)
                        global Gopen = tf(lagArrayNum,lagArrayDen)
                        global Gcerr = feedback(Gopen)

                        # Steady state analysis
                        ωn1, ζ1, ps1 = damp(Gcerr)

                        # Kv
                        s = symbols("s", real=true)

                        global GrealNum = 0
                        global GrealDen = 0

                        for i=1:length(lagArrayNum)
                            global GrealNum = GrealNum + lagArrayNum[i]*s^(length(lagArrayNum)-i)
                        end

                        for i=1:length(lagArrayDen)
                            global GrealDen = GrealDen + lagArrayDen[i]*s^(length(lagArrayDen)-i)
                        end

                        Greal1 = GrealNum/GrealDen

                        Kv1 = limit(Greal1*s, s, 0)

                        # TFopen image
                        msgtex = Latexify.latexify(string("G(s)=", simplify(Greal1)))
                        L =
                        """\\documentclass[border=2pt]{standalone}
                        \\usepackage{mathtools}
                        \\begin{document}
                        {{:msg}}
                        \\end{document}
                        """

                        out = render(L, msg = msgtex)
                        filename = "C:\\Windows\\Temp\\lagTFopen.tex"

                        Base.open(filename, "w") do file
                            write(file, out)
                        end

                        run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "lagTFopen.tex"`)
                        run(`pdftocairo -png -r 300 "C:\\Windows\\Temp\\TFopen.pdf" "C:\\Windows\\Temp\\lagTFopen"`)

                        set_gtk_property!(lagTFOpenImg, :file, "C:\\Windows\\Temp\\lagTFopen-1.png")

                        # TFcerr image
                        GcerrTex1 = simplify(Greal1/(Greal1+1))
                        msgtexcerr = Latexify.latexify(string("G(s)=", GcerrTex1))
                        L =
                        """\\documentclass[border=2pt]{standalone}
                        \\usepackage{mathtools}
                        \\begin{document}
                        {{:msg}}
                        \\end{document}
                        """

                        out = render(L, msg = msgtexcerr)
                        filename = "C:\\Windows\\Temp\\lagTFcerr.tex"

                        Base.open(filename, "w") do file
                            write(file, out)
                        end

                        run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "lagTFcerr.tex"`)
                        run(`pdftocairo -png -r 300 "C:\\Windows\\Temp\\TFcerr.pdf" "C:\\Windows\\Temp\\lagTFcerr"`)

                        set_gtk_property!(lagTFCerrImg, :file, "C:\\Windows\\Temp\\lagTFcerr-1.png")

                        # uncompensated
                        # Overshoot
                        PO1 = 100*exp((-ζ1[1]*pi)/(sqrt(1-ζ1[1]^2)))

                        # Settling time
                        Ts1 = -log(0.05)/(ζ1[1]*ωn1[1])

                        # Peak Time Response
                        Tp1 = π/(ωn1[1]*sqrt(1 - ζ1[1]^2))

                        # #Rise time
                        beta1 = atan(ωn1[1]/(ωn1[1]*ζ1[1]))
                        tR1 = (π-beta1)/ωn1[1]

                        # β
                        β = lagKvNum / N(Kv1)

                        # Zero
                        global Zero = -1 / lagTNum
                        global Pole = -1 / (β*lagTNum)

                        # TF compensator

                        Gc1 = tf([1, - Zero],[1, - Pole])

                        msgtexcerr = Latexify.latexify(string("G(s)=Kc*",(1*s-Zero)/(1*s-Pole)))
                        L =
                        """\\documentclass[border=2pt]{standalone}
                        \\usepackage{mathtools}
                        \\begin{document}
                        {{:msg}}
                        \\end{document}
                        """

                        out = render(L, msg = msgtexcerr)
                        filename = "C:\\Windows\\Temp\\lagGc.tex"

                        Base.open(filename, "w") do file
                            write(file, out)
                        end

                        run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "lagGc.tex"`)
                        run(`pdftocairo -png -r 300 "C:\\Windows\\Temp\\lagGc.pdf" "C:\\Windows\\Temp\\lagGc"`)

                        set_gtk_property!(lagTFCompImg, :file, "C:\\Windows\\Temp\\lagGc-1.png")

                        GcCerr1 = feedback(Gc1*Gopen)
                        ωn2, ζ2, ps2 = damp(GcCerr1)

                        # Compensated
                        # Overshoot
                        PO2 = 100*exp((-ζ2[2]*pi)/(sqrt(1-ζ2[2]^2)))

                        # Settling time
                        Ts2 = -log(0.05)/(ζ2[2]*ωn2[2])

                        # Peak Time Response
                        Tp2 = π/(ωn2[2]*sqrt(1 - ζ2[2]^2))

                        # #Rise time
                        beta2 = atan(ωn2[2]/(ωn2[2]*ζ2[2]))
                        tR2 = (π-beta2)/ωn2[2]

                        Greal2 = subs(Greal1, s, ps2[2])
                        Greal2 = simplify(Greal2)
                        ϕ = atand(imag(N(Greal2)) / real(N(Greal2)))

                        Kc = 1 / sqrt((imag(Greal2)^2) + (real(Greal2)^2))


                        # List of values
                        listLag[1,2] = ωn1[1]
                        listLag[1,3] = ωn2[2]

                        listLag[2,2] = ζ1[1]
                        listLag[2,3] = ζ2[2]

                        listLag[3,2] = string(ps1)
                        listLag[3,3] = string(ps2)

                        listLag[4,2] = N(Kv1)
                        listLag[4,3] = lagKvNum

                        listLag[5,2] = tR1
                        listLag[5,3] = tR2

                        listLag[6,2] = Tp1
                        listLag[6,3] = Tp2

                        listLag[7,2] = PO1
                        listLag[7,3] = PO2

                        listLag[8,2] = Ts1
                        listLag[8,3] = Ts2

                        listLag[9,3] = ϕ

                        listLag[10,3] = Pole
                        listLag[11,3] = Zero
                        listLag[12,3] = β

                        listLag[13,3] = Kc

                        # Step plot
                        yLagStep, tLagStep, xLagStep = step(Gcerr)

                        GCcerr = feedback(Kc*Gc1*Gopen)
                        yLagStep2, tLagStep2, xLagStep2 = step(GCcerr)

                        # Step ramp
                        global Gramp = tf([1],[1,0])
                        yLagRamp, tLagRamp, xLagRamp = step(Gcerr*Gramp)
                        yLagRamp2, tLagRamp2, xLagRamp2 = step(GCcerr*Gramp)

                        plotLagStep = plot(tLagStep, yLagStep,
                        xlabel = "Time (sec)",
                        ylabel = "Amplitude",
                        framestyle = :box,
                        label = "Uncompensated")
                        plot!(tLagStep2, yLagStep2, label="Uncompensated")

                        plotLagRamp = plot(tLagRamp,yLagRamp,
                        xlabel = "Time (sec)",
                        ylabel = "Amplitude",
                        framestyle = :box,
                        label = "Uncompensated")
                        plot!(tLagRamp2,yLagRamp2, label = "Compensated")

                        plotLagRL =  rlocusplot(Kc*Gc1*Gopen, framestyle=:box, title = "", lw=1, lc = :blue)

                        savefig(plotLagStep, lagStep)
                        savefig(plotLagRamp, lagRamp)
                        savefig(plotLagRL, lagRL)

                        set_gtk_property!(imgLagRoot, :file, lagStep)
                        set_gtk_property!(imgLagRamp, :file, lagRamp)
                        set_gtk_property!(imgLagRL, :file, lagRL)

                        # TFCopen image
                        TFCopen = Kc*Greal1*((1*s-Zero)/(1*s-Pole))
                        msgtex = Latexify.latexify(string("Gc(s)*G(s)=", simplify(TFCopen)))
                        L =
                        """\\documentclass[border=2pt]{standalone}
                        \\usepackage{mathtools}
                        \\begin{document}
                        {{:msg}}
                        \\end{document}
                        """

                        out = render(L, msg = msgtex)
                        filename = "C:\\Windows\\Temp\\lagTFCopen.tex"

                        Base.open(filename, "w") do file
                            write(file, out)
                        end

                        run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "lagTFCopen.tex"`)
                        run(`pdftocairo -png -r 300 "C:\\Windows\\Temp\\lagTFCopen.pdf" "C:\\Windows\\Temp\\lagTFCopen"`)

                        set_gtk_property!(lagTFCompOpenImg, :file, "C:\\Windows\\Temp\\lagTFCopen-1.png")

                        # TFCopen image
                        TFCopen = Kc*Greal1*((1*s-Zero)/(1*s-Pole))
                        TFCcerr = TFCopen/(1 + TFCopen)
                        msgtex = Latexify.latexify(string("C(s)/R(s)=", simplify(TFCcerr)))
                        L =
                        """\\documentclass[border=2pt]{standalone}
                        \\usepackage{mathtools}
                        \\begin{document}
                        {{:msg}}
                        \\end{document}
                        """

                        out = render(L, msg = msgtex)
                        filename = "C:\\Windows\\Temp\\lagTFCcerr.tex"

                        Base.open(filename, "w") do file
                            write(file, out)
                        end

                        run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "lagTFCcerr.tex"`)
                        run(`pdftocairo -png -r 300 "C:\\Windows\\Temp\\lagTFCcerr.pdf" "C:\\Windows\\Temp\\lagTFCcerr"`)

                        set_gtk_property!(lagTFCompCerrImg, :file, "C:\\Windows\\Temp\\lagTFCcerr-1.png")
                    #     push!(rootLocusTable,("Wn",listRoot[1,2]))
                    #     push!(rootLocusTable,("L",listRoot[2,2]))
                    #     push!(rootLocusTable,("Closed-loop Poles", listRoot[3,2]))
                    #     push!(rootLocusTable,("Kv", listRoot[4,2]))
                    #     push!(rootLocusTable,("Rise Time", listRoot[5,2]))
                    #     push!(rootLocusTable,("Peak Time", listRoot[6,2]))
                    #     push!(rootLocusTable,("Overshoot", listRoot[7,2]))
                    #     push!(rootLocusTable,("Settling Time", listRoot[8,2]))
                    #
                    #     set_gtk_property!(exportTB, :sensitive, true)
                    else
                        warn_dialog("Numerator´s order must be lower than denominator", mainWin)
                        set_gtk_property!(lagNumTf, :text, "")
                        set_gtk_property!(lagDenTf, :text, "")
                    end
                catch
                    println("Error en lag")
                end

            end
        end

        # Execute lag compensator
        if get_gtk_property(nb, :page, Int) == 2

        end

        # Execute lag compensator
        if get_gtk_property(nb, :page, Int) == 3

        end

    end

    exportTB = ToolButton("gtk-close")
    imgexportTB = Image()
    set_gtk_property!(imgexportTB, :file, ico3)
    set_gtk_property!(exportTB, :icon_widget, imgexportTB)
    set_gtk_property!(exportTB, :label, "Export")
    set_gtk_property!(exportTB, :tooltip_markup, "Export to .pdf file")
    set_gtk_property!(exportTB, :sensitive, false)
    signal_connect(exportTB, :clicked) do widget
        global pathfile = save_dialog_native("Save as...", Null(), ("*.pdf",))
        global rootLocusTable

        if ~isempty(pathfile)
            # Time for report
            timenow = Dates.now()
            timenow1 = Dates.format(timenow, "dd u yyyy HH:MM:SS")

            if Sys.iswindows()
                # Headers for dataframes
                fmtH1 = string("|",repeat("c|", size(rootLocusTable,2)))
                headerH1 = join(string.(names(rootLocusTable)), " & ")
                rowH1 = join(["{{:$x}}" for x in map(string, names(rootLocusTable))], " & ")

                LSNS = """
                \\documentclass{article}
                \\usepackage{graphicx}
                \\graphicspath{ {C:/Windows/Temp/} }
                \\usepackage[letterpaper, portrait, margin=1in]{geometry}
                \\begin{document}
                \\begin{center}
                \\Huge{\\textbf{LeadLagAssistant v0.1.0}}\\\\
                \\vspace{2mm}
                \\large{\\textbf{Root-locus Assistant Report}}\\break
                \\normalsize{{:time}}\n
                \\vspace{5mm}
                \\rule{15cm}{0.05cm}\n\n\n
                \\vspace{2mm}
                \\includegraphics[width=9cm, height=8cm]{rootStep}\n
                \\normalsize{Figure 1. Step response}\n
                \\vspace{2mm}
                \\includegraphics[width=9cm, height=8cm]{rootRamp}\n
                \\normalsize{Figure 2. Ramp response}\n
                \\vspace{3mm}\n
                \\rule{15cm}{0.05cm}\n
                \\pagebreak

                \\includegraphics[width=9cm, height=8cm]{rootRL}\n
                \\normalsize{Figure 3. Root-locus}\n
                \\vspace{2mm}

                \\rule{15cm}{0.05cm}\n\n\n
                \\vspace{2mm}
                \\normalsize{Table 1. Parameters}\n
                \\vspace{2mm}
                \\begin{tabular}{$fmtH1}
                \\hline
                $headerH1\\\\
                \\hline
                {{#:FGH1}} $rowH1\\cr
                {{/:FGH1}}
                \\hline\n
                \\end{tabular}

                \\vspace{5mm}\n
                \\end{center}
                \\end{document}
                """

                rendered = render(LSNS, time = timenow1, FGH1 = rootLocusTable)

                fileNameBase = string(basename(pathfile), ".tex")
                fileName = string("C:\\Windows\\Temp\\", fileNameBase)
                Base.open(fileName, "w") do file
                    write(file, rendered)
                end
                run(`pdflatex -output-directory="C:\\Windows\\Temp\\" $(fileNameBase)`)

                pdfName = string(pathfile, ".pdf")
                fileNameBase = string(basename(pathfile), ".pdf")
                fileName = string("C:\\Windows\\Temp\\", fileNameBase)
                cp(fileName, string(pathfile, ".pdf"); force=true)
                DefaultApplication.open(pdfName)
            end

            if Sys.islinux()
                warn_dialog("Export as .pdf is not currently implemented on Linux Operating System", mainWin)
            end
        end
    end

    mainToolbar = Toolbar()
    set_gtk_property!(mainToolbar, :height_request, (h * 0.75) * 0.09)
    set_gtk_property!(mainToolbar, :toolbar_style, 2)
    push!(mainToolbar, newTB)
    push!(mainToolbar, exportTB)
    push!(mainToolbar, runTB)
    push!(mainToolbar, closeTB)

    ############################################################################
    # main Notebook
    ############################################################################
    global nb = Notebook()
    set_gtk_property!(nb, :tab_pos, 3)
    set_gtk_property!(nb, :name, "nb")
    screen = Gtk.GAccessor.style_context(nb)
    push!(screen, StyleProvider(provider), 600)

    # Root-locus assistant #####################################################
    rootlocusFrame = Frame()

    mainGridRoot = Grid()
    set_gtk_property!(mainGridRoot, :column_homogeneous, false)
    set_gtk_property!(mainGridRoot, :row_homogeneous, false)
    set_gtk_property!(mainGridRoot, :margin_top, 10)
    set_gtk_property!(mainGridRoot, :margin_bottom, 10)
    set_gtk_property!(mainGridRoot, :margin_left, 10)
    set_gtk_property!(mainGridRoot, :margin_right, 10)
    set_gtk_property!(mainGridRoot, :column_spacing, 10)
    set_gtk_property!(mainGridRoot, :row_spacing, 10)

    gridRootLeft = Grid()
    set_gtk_property!(gridRootLeft, :valign, 3)
    set_gtk_property!(gridRootLeft, :halign, 3)
    set_gtk_property!(gridRootLeft, :column_spacing, 10)
    set_gtk_property!(gridRootLeft, :row_spacing, 10)
    set_gtk_property!(gridRootLeft, :column_homogeneous, true)

    gridRootRight = Grid()
    set_gtk_property!(gridRootRight, :valign, 3)
    set_gtk_property!(gridRootRight, :halign, 3)
    set_gtk_property!(gridRootRight, :column_spacing, 10)
    set_gtk_property!(gridRootRight, :row_spacing, 10)
    set_gtk_property!(gridRootRight, :column_homogeneous, true)

    gridRootLFrameUp = Frame("Input Data")
    set_gtk_property!(gridRootLFrameUp, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridRootLFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.35)
    set_gtk_property!(gridRootLFrameUp, :label_xalign, 0.50)
    set_gtk_property!(gridRootLFrameUp, :label_yalign, 0.00)

    # TF, List and table for input data
    gridRootLFUp = Grid()
    set_gtk_property!(gridRootLFUp, :column_homogeneous, false)
    set_gtk_property!(gridRootLFUp, :row_homogeneous, false)
    set_gtk_property!(gridRootLFUp, :column_spacing, 10)
    set_gtk_property!(gridRootLFUp, :row_spacing, 10)
    set_gtk_property!(gridRootLFUp, :margin_top, 10)
    set_gtk_property!(gridRootLFUp, :margin_bottom, 10)
    set_gtk_property!(gridRootLFUp, :margin_left, 10)
    set_gtk_property!(gridRootLFUp, :margin_right, 10)

    # entry for TF

    rootNumTf = Entry()
    rootDenTf = Entry()

    labelGs = Label("G(s) = ")
    labelDen = Label("[d1,d2... dn]")
    labelNum = Label("[n1,n2... nm]")

    gRootLFUpTF = Frame()
    set_gtk_property!(gRootLFUpTF, :label_xalign, 0.50)
    set_gtk_property!(gRootLFUpTF, :label_yalign, 0.00)
    set_gtk_property!(gRootLFUpTF, :width_request, (w*0.6)*0.385)
    set_gtk_property!(gRootLFUpTF, :height_request, 0.35*((h*0.75)-((h * 0.75) * 0.09))*0.50)

    gRootUpTFImg = Image()
    gRootUpTFImgScroll = ScrolledWindow()
    push!(gRootUpTFImgScroll,gRootUpTFImg)
    push!(gRootLFUpTF, gRootUpTFImgScroll)

    gridRootLFUp[1,1:2] = labelGs
    gridRootLFUp[2,1] = labelNum
    gridRootLFUp[2,2] = labelDen
    gridRootLFUp[3,1] = rootNumTf
    gridRootLFUp[3,2] = rootDenTf
    gridRootLFUp[1:3,3] = gRootLFUpTF

    push!(gridRootLFrameUp, gridRootLFUp)

    gridRootLFrameB = Frame("Output Data")
    set_gtk_property!(gridRootLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridRootLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.60)
    set_gtk_property!(gridRootLFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridRootLFrameB, :label_yalign, 0.00)

    gridRootRFrameUp = Frame()
    set_gtk_property!(gridRootRFrameUp, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridRootRFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.70)

    imgRoot = Image()
    imgRamp = Image()
    imgRL = Image()

    gridRootRFrameB = Frame("Suggestions")
    set_gtk_property!(gridRootRFrameB, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridRootRFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.25)
    set_gtk_property!(gridRootRFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridRootRFrameB, :label_yalign, 0.00)

    suggesLabelRoot = Label("")
    push!(gridRootRFrameB, suggesLabelRoot)

    gridRootLeft[1,1] = gridRootLFrameUp
    gridRootLeft[1,2] = gridRootLFrameB

    gridRootRight[1,1] = gridRootRFrameUp
    gridRootRight[1,2] = gridRootRFrameB

    mainGridRoot[1,1] = gridRootLeft
    mainGridRoot[2,1] = gridRootRight

    # TF, List and table for input data
    gridRootLFB = Grid()
    set_gtk_property!(gridRootLFB, :column_homogeneous, false)
    set_gtk_property!(gridRootLFB, :row_homogeneous, false)
    set_gtk_property!(gridRootLFB, :column_spacing, 10)
    set_gtk_property!(gridRootLFB, :row_spacing, 10)
    set_gtk_property!(gridRootLFB, :margin_top, 10)
    set_gtk_property!(gridRootLFB, :margin_bottom, 10)
    set_gtk_property!(gridRootLFB, :margin_left, 10)
    set_gtk_property!(gridRootLFB, :margin_right, 10)

    gRootLFBTF = Frame()
    set_gtk_property!(gRootLFBTF, :label_xalign, 0.50)
    set_gtk_property!(gRootLFBTF, :label_yalign, 0.00)
    set_gtk_property!(gRootLFBTF, :width_request, (w*0.6)*0.385)
    set_gtk_property!(gRootLFBTF, :height_request, 0.35*((h*0.75)-((h * 0.75) * 0.09))*0.50)

    gRootBTFImg = Image()
    gRootBTFImgScroll = ScrolledWindow()
    push!(gRootBTFImgScroll,gRootBTFImg)
    push!(gRootLFBTF, gRootBTFImgScroll)

    global listRoot = ListStore(String, String)

    push!(listRoot,("ωn","unsolved"))
    push!(listRoot,("ζ","unsolved"))
    push!(listRoot,("Closed-loop Poles", "unsolved"))
    push!(listRoot,("Kv", "unsolved"))
    push!(listRoot,("Rise Time (sec)", "unsolved"))
    push!(listRoot,("Peak Time (sec)", "unsolved"))
    push!(listRoot,("Overshoot (%)", "unsolved"))
    push!(listRoot,("Settling Time (sec)", "unsolved"))

    treeRoot = TreeView(TreeModel(listRoot))
    rowTxt = CellRendererText()

    c1Root = TreeViewColumn("Parameter", rowTxt, Dict([("text",0)]))
    c2Root = TreeViewColumn("Value", rowTxt, Dict([("text",1)]))

    Gtk.GAccessor.resizable(c1Root, true)
    Gtk.GAccessor.resizable(c2Root, true)

    push!(treeRoot, c1Root, c2Root)

    rootODScrollWin = ScrolledWindow()
    set_gtk_property!(rootODScrollWin, :name, "rootODScrollWin")
    set_gtk_property!(rootODScrollWin, :height_request, 0.70*((h*0.75)-((h * 0.75) * 0.09))*0.50)

    rootODScrollWinF = Frame()
    push!(rootODScrollWinF,rootODScrollWin)
    push!(rootODScrollWin,treeRoot)

    gridRootLFB[1,1] = gRootLFBTF
    gridRootLFB[1,2] = rootODScrollWinF

    push!(gridRootLFrameB, gridRootLFB)
    # end list and tree ########################################################

    push!(rootlocusFrame, mainGridRoot)

    # Notebook for Plots in Root-locus #########################################
    nbRoot = Notebook()
    set_gtk_property!(nbRoot, :tab_pos, 2)

    rootStepFrame = Frame()
    rootRampFrame = Frame()
    rootRootFrame = Frame()

    push!(rootStepFrame, imgRoot)
    push!(rootRampFrame, imgRamp)
    push!(rootRootFrame, imgRL)

    push!(nbRoot, rootStepFrame, "Step Response")
    push!(nbRoot, rootRampFrame, "Ramp Response")
    push!(nbRoot, rootRootFrame, "Root-locus")

    push!(gridRootRFrameUp, nbRoot)
    # End of root-locus assistant ##############################################

    # Lag assistant #####################################################
    lagFrame = Frame()

    mainGridLag = Grid()
    set_gtk_property!(mainGridLag, :column_homogeneous, false)
    set_gtk_property!(mainGridLag, :row_homogeneous, false)
    set_gtk_property!(mainGridLag, :margin_top, 10)
    set_gtk_property!(mainGridLag, :margin_bottom, 10)
    set_gtk_property!(mainGridLag, :margin_left, 10)
    set_gtk_property!(mainGridLag, :margin_right, 10)
    set_gtk_property!(mainGridLag, :column_spacing, 10)
    set_gtk_property!(mainGridLag, :row_spacing, 10)

    gridLagLeft = Grid()
    set_gtk_property!(gridLagLeft, :valign, 3)
    set_gtk_property!(gridLagLeft, :halign, 3)
    set_gtk_property!(gridLagLeft, :column_spacing, 10)
    set_gtk_property!(gridLagLeft, :row_spacing, 10)
    set_gtk_property!(gridLagLeft, :column_homogeneous, true)

    gridLagRight = Grid()
    set_gtk_property!(gridLagRight, :valign, 3)
    set_gtk_property!(gridLagRight, :halign, 3)
    set_gtk_property!(gridLagRight, :column_spacing, 10)
    set_gtk_property!(gridLagRight, :row_spacing, 10)
    set_gtk_property!(gridLagRight, :column_homogeneous, true)

    gridLagLFrameUp = Frame("Input Data")
    set_gtk_property!(gridLagLFrameUp, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLagLFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.35)
    set_gtk_property!(gridLagLFrameUp, :label_xalign, 0.50)
    set_gtk_property!(gridLagLFrameUp, :label_yalign, 0.00)

    # TF, List and table for input data
    gridLagLFUp = Grid()
    set_gtk_property!(gridLagLFUp, :column_homogeneous, false)
    set_gtk_property!(gridLagLFUp, :row_homogeneous, false)
    set_gtk_property!(gridLagLFUp, :column_spacing, 10)
    set_gtk_property!(gridLagLFUp, :row_spacing, 10)
    set_gtk_property!(gridLagLFUp, :margin_top, 10)
    set_gtk_property!(gridLagLFUp, :margin_bottom, 10)
    set_gtk_property!(gridLagLFUp, :margin_left, 10)
    set_gtk_property!(gridLagLFUp, :margin_right, 10)
    set_gtk_property!(gridLagLFUp, :valign, 3)
    set_gtk_property!(gridLagLFUp, :halign, 3)

    # entry for TF

    lagNumTf = Entry()
    lagDenTf = Entry()

    labelLagGs = Label("G(s) = ")
    labelLagDen = Label("[d1,d2... dn]")
    labelLagNum = Label("[n1,n2... nm]")

    # Entry for Kv, T
    lagT = Entry()
    lagKv = Entry()
    lagTLabel = Label("T:")
    lagKvLabel = Label("Kv:")

    global lagCheck = CheckButton("Copy from Root-locus Assistant")
    signal_connect(lagCheck, :toggled) do widget
        checkLagStatus = get_gtk_property(lagCheck, :active, Bool)

        if rootLocusStatus == 1
            if checkLagStatus == true
                global rootNumTfData = get_gtk_property(rootNumTf, :text, String)
                global rootDenTfData = get_gtk_property(rootDenTf, :text, String)

                set_gtk_property!(lagNumTf, :text, rootNumTfData)
                set_gtk_property!(lagDenTf, :text, rootDenTfData)
            else
                set_gtk_property!(lagNumTf, :text, "")
                set_gtk_property!(lagDenTf, :text, "")
            end
        else
            if checkLagStatus == true
                @sigatom set_gtk_property!(lagCheck, :active, false)
                warn_dialog("Data are not available from Root-Locus Assistant", mainWin)
            end
        end
    end

    gridLagLFUp[1,1:2] = labelLagGs
    gridLagLFUp[2,1] = labelLagNum
    gridLagLFUp[2,2] = labelLagDen
    gridLagLFUp[3,1] = lagNumTf
    gridLagLFUp[3,2] = lagDenTf
    gridLagLFUp[1:3,3] = lagCheck
    gridLagLFUp[1:2,4] = lagTLabel
    gridLagLFUp[1:2,5] = lagKvLabel
    gridLagLFUp[3,4] = lagT
    gridLagLFUp[3,5] = lagKv

    push!(gridLagLFrameUp, gridLagLFUp)

    gridLagLFrameB = Frame("Output Data")
    set_gtk_property!(gridLagLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLagLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.60)
    set_gtk_property!(gridLagLFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLagLFrameB, :label_yalign, 0.00)

    gridLagRFrameUp = Frame()
    set_gtk_property!(gridLagRFrameUp, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLagRFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.70)

    imgLagRoot = Image()
    imgLagRamp = Image()
    imgLagRL = Image()
    imgLOpAmp = Image()

    gridLagRFrameB = Frame("Operational Amp")
    set_gtk_property!(gridLagRFrameB, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLagRFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.25)
    set_gtk_property!(gridLagRFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLagRFrameB, :label_yalign, 0.00)

    # TF, List and table for input data
    gridLagLFB = Grid()
    set_gtk_property!(gridLagLFB, :column_homogeneous, false)
    set_gtk_property!(gridLagLFB, :row_homogeneous, false)
    set_gtk_property!(gridLagLFB, :column_spacing, 10)
    set_gtk_property!(gridLagLFB, :row_spacing, 10)
    set_gtk_property!(gridLagLFB, :margin_top, 10)
    set_gtk_property!(gridLagLFB, :margin_bottom, 10)
    set_gtk_property!(gridLagLFB, :margin_left, 10)
    set_gtk_property!(gridLagLFB, :margin_right, 10)

    lagNbTF = Notebook()

    lagTFOpenImg = Image()
    lagTFOpenFrame = Frame(lagTFOpenImg)
    lagTFOpenFrameScroll = ScrolledWindow(lagTFOpenFrame)
    set_gtk_property!(lagTFOpenFrameScroll, :tooltip_markup, "Uncompensated Open-loop transfer function")

    lagTFCerrImg = Image()
    lagTFCerrFrame = Frame(lagTFCerrImg)
    lagTFCerrFrameScroll = ScrolledWindow(lagTFCerrFrame)
    set_gtk_property!(lagTFCerrFrameScroll, :tooltip_markup, "Uncompensated Closed-loop transfer function")

    lagTFCompImg = Image()
    lagTFCompFrame = Frame(lagTFCompImg)
    lagTFCompFrameScroll = ScrolledWindow(lagTFCompFrame)
    set_gtk_property!(lagTFCompFrameScroll, :tooltip_markup, "Lag compensator transfer function")

    lagTFCompOpenImg = Image()
    lagTFCompOpenFrame = Frame(lagTFCompOpenImg)
    lagTFCompOpenFrameScroll = ScrolledWindow(lagTFCompOpenFrame)
    set_gtk_property!(lagTFCompOpenFrameScroll, :tooltip_markup, "Compensated Open-loop transfer function")

    lagTFCompCerrImg = Image()
    lagTFOpenCerrFrame = Frame(lagTFCompCerrImg)
    lagTFOpenCerrFrameScroll = ScrolledWindow(lagTFOpenCerrFrame)
    set_gtk_property!(lagTFOpenCerrFrameScroll, :tooltip_markup, "Compensated Closed-loop transfer function")

    push!(lagNbTF, lagTFOpenFrameScroll, "G(s)")
    push!(lagNbTF, lagTFCerrFrameScroll, "C(s)/R(s)")
    push!(lagNbTF, lagTFCompFrameScroll, "Gc(s)")
    push!(lagNbTF, lagTFCompOpenFrameScroll, "Gc(s)*G(s)")
    push!(lagNbTF, lagTFOpenCerrFrameScroll, "C(s)/R(s)")

    gLagLFBTF = Frame()
    set_gtk_property!(gLagLFBTF, :label_xalign, 0.50)
    set_gtk_property!(gLagLFBTF, :label_yalign, 0.00)
    set_gtk_property!(gLagLFBTF, :width_request, (w*0.6)*0.385)
    set_gtk_property!(gLagLFBTF, :height_request, 0.40*((h*0.75)-((h * 0.75) * 0.09))*0.50)

    gLagLFBTFScroll = ScrolledWindow()
    push!(gLagLFBTFScroll,lagNbTF)
    push!(gLagLFBTF,gLagLFBTFScroll)

    global listLag = ListStore(String, String, String)

    push!(listLag,("ωn","unsolved","unsolved"))
    push!(listLag,("ζ","unsolved", "unsolved"))
    push!(listLag,("Poles", "unsolved", "unsolved"))
    push!(listLag,("Kv", "unsolved", "unsolved"))
    push!(listLag,("Rise Time (sec)", "unsolved", "unsolved"))
    push!(listLag,("Peak Time (sec)", "unsolved", "unsolved"))
    push!(listLag,("Overshoot (%)", "unsolved", "unsolved"))
    push!(listLag,("Settling Time (sec)", "unsolved", "unsolved"))
    push!(listLag,("Angle contribution (degrees)", "---", "unsolved"))
    push!(listLag,("Pole", "---", "unsolved"))
    push!(listLag,("Zero", "---", "unsolved"))
    push!(listLag,("β", "---", "unsolved"))
    push!(listLag,("Kc", "---", "unsolved"))

    treeLag = TreeView(TreeModel(listLag))
    rowTxtL = CellRendererText()

    c1Lag = TreeViewColumn("Parameter", rowTxtL, Dict([("text",0)]))
    c2Lag = TreeViewColumn("Original Value", rowTxtL, Dict([("text",1)]))
    c3Lag = TreeViewColumn("Compensated Value", rowTxtL, Dict([("text",2)]))

    Gtk.GAccessor.resizable(c1Lag, true)
    Gtk.GAccessor.resizable(c2Lag, true)
    Gtk.GAccessor.resizable(c3Lag, true)

    push!(treeLag, c1Lag, c2Lag, c3Lag)

    lagODScrollWin = ScrolledWindow()
    set_gtk_property!(lagODScrollWin, :name, "lagODScrollWin")
    set_gtk_property!(lagODScrollWin, :height_request, 0.65*((h*0.75)-((h * 0.75) * 0.09))*0.50)
    screen = Gtk.GAccessor.style_context(lagODScrollWin)
    push!(screen, StyleProvider(provider), 600)

    lagODScrollWinF = Frame()
    push!(lagODScrollWin,treeLag)
    push!(lagODScrollWinF,lagODScrollWin)

    gridLagLFB[1,1] = gLagLFBTF
    gridLagLFB[1,2] = lagODScrollWinF

    push!(gridLagLFrameB, gridLagLFB)
    # end list and tree ########################################################


    gridLagLeft[1,1] = gridLagLFrameUp
    gridLagLeft[1,2] = gridLagLFrameB

    gridLagRight[1,1] = gridLagRFrameUp
    gridLagRight[1,2] = gridLagRFrameB

    mainGridLag[1,1] = gridLagLeft
    mainGridLag[2,1] = gridLagRight

    push!(lagFrame, mainGridLag)

    # Notebook for Plots in Lag compensator #########################################
    nbLag = Notebook()
    set_gtk_property!(nbLag, :tab_pos, 2)

    lagStepFrame = Frame()
    lagRampFrame = Frame()
    lagRootFrame = Frame()
    lagAmpOpFrame = Frame()

    push!(lagStepFrame, imgLagRoot)
    push!(lagRampFrame, imgLagRamp)
    push!(lagRootFrame, imgLagRL)

    push!(nbLag, lagStepFrame, "Step Response")
    push!(nbLag, lagRampFrame, "Ramp Response")
    push!(nbLag, lagRootFrame, "Root-locus")
    push!(nbLag, lagAmpOpFrame, "Amp Op Diagram")

    push!(gridLagRFrameUp, nbLag)

    # End of lag assistant ##############################################

    # Lead assistant #####################################################
    leadFrame = Frame()

    mainGridLead = Grid()
    set_gtk_property!(mainGridLead, :column_homogeneous, false)
    set_gtk_property!(mainGridLead, :row_homogeneous, false)
    set_gtk_property!(mainGridLead, :margin_top, 10)
    set_gtk_property!(mainGridLead, :margin_bottom, 10)
    set_gtk_property!(mainGridLead, :margin_left, 10)
    set_gtk_property!(mainGridLead, :margin_right, 10)
    set_gtk_property!(mainGridLead, :column_spacing, 10)
    set_gtk_property!(mainGridLead, :row_spacing, 10)

    gridLeadLeft = Grid()
    set_gtk_property!(gridLeadLeft, :valign, 3)
    set_gtk_property!(gridLeadLeft, :halign, 3)
    set_gtk_property!(gridLeadLeft, :column_spacing, 10)
    set_gtk_property!(gridLeadLeft, :row_spacing, 10)
    set_gtk_property!(gridLeadLeft, :column_homogeneous, true)

    gridLeadRight = Grid()
    set_gtk_property!(gridLeadRight, :valign, 3)
    set_gtk_property!(gridLeadRight, :halign, 3)
    set_gtk_property!(gridLeadRight, :column_spacing, 10)
    set_gtk_property!(gridLeadRight, :row_spacing, 10)
    set_gtk_property!(gridLeadRight, :column_homogeneous, true)

    gridLeadLFrameUp = Frame("Input Data")
    set_gtk_property!(gridLeadLFrameUp, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLeadLFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.45)
    set_gtk_property!(gridLeadLFrameUp, :label_xalign, 0.50)
    set_gtk_property!(gridLeadLFrameUp, :label_yalign, 0.00)

    gridLeadLFrameB = Frame("Output Data")
    set_gtk_property!(gridLeadLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLeadLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.50)
    set_gtk_property!(gridLeadLFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLeadLFrameB, :label_yalign, 0.00)

    gridLeadRFrameUp = Frame()
    set_gtk_property!(gridLeadRFrameUp, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLeadRFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.70)

    gridLeadRFrameB = Frame("Operational Amp")
    set_gtk_property!(gridLeadRFrameB, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLeadRFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.25)
    set_gtk_property!(gridLeadRFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLeadRFrameB, :label_yalign, 0.00)

    gridLeadLeft[1,1] = gridLeadLFrameUp
    gridLeadLeft[1,2] = gridLeadLFrameB

    gridLeadRight[1,1] = gridLeadRFrameUp
    gridLeadRight[1,2] = gridLeadRFrameB

    mainGridLead[1,1] = gridLeadLeft
    mainGridLead[2,1] = gridLeadRight

    push!(leadFrame, mainGridLead)

    # Notebook for Plots in Lead compensator #########################################
    nbLead = Notebook()
    set_gtk_property!(nbLead, :tab_pos, 2)

    leadStepFrame = Frame()
    leadRampFrame = Frame()
    leadRootFrame = Frame()
    leadGraphicFrame = Frame()
    leadAmpOpFrame = Frame()

    push!(nbLead, leadStepFrame, "Step Response")
    push!(nbLead, leadRampFrame, "Ramp Response")
    push!(nbLead, leadRootFrame, "Root-locus")
    push!(nbLead, leadGraphicFrame, "Graphic Design")
    push!(nbLead, leadAmpOpFrame, "Amp Op Diagram")

    scrollWin = ScrolledWindow()
    push!(scrollWin,nbLead)
    push!(gridLeadRFrameUp, scrollWin)

    # End of lead assistant ##############################################

    # Lead-lagFrame assistant ##################################################
    leadlagFrame = Frame()

    mainGridLeadlag = Grid()
    set_gtk_property!(mainGridLeadlag, :column_homogeneous, false)
    set_gtk_property!(mainGridLeadlag, :row_homogeneous, false)
    set_gtk_property!(mainGridLeadlag, :margin_top, 10)
    set_gtk_property!(mainGridLeadlag, :margin_bottom, 10)
    set_gtk_property!(mainGridLeadlag, :margin_left, 10)
    set_gtk_property!(mainGridLeadlag, :margin_right, 10)
    set_gtk_property!(mainGridLeadlag, :column_spacing, 10)
    set_gtk_property!(mainGridLeadlag, :row_spacing, 10)

    gridLeadlagLeft = Grid()
    set_gtk_property!(gridLeadlagLeft, :valign, 3)
    set_gtk_property!(gridLeadlagLeft, :halign, 3)
    set_gtk_property!(gridLeadlagLeft, :column_spacing, 10)
    set_gtk_property!(gridLeadlagLeft, :row_spacing, 10)
    set_gtk_property!(gridLeadlagLeft, :column_homogeneous, true)

    gridLeadlagRight = Grid()
    set_gtk_property!(gridLeadlagRight, :valign, 3)
    set_gtk_property!(gridLeadlagRight, :halign, 3)
    set_gtk_property!(gridLeadlagRight, :column_spacing, 10)
    set_gtk_property!(gridLeadlagRight, :row_spacing, 10)
    set_gtk_property!(gridLeadlagRight, :column_homogeneous, true)

    gridLeadlagLFrameUp = Frame("Input Data")
    set_gtk_property!(gridLeadlagLFrameUp, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLeadlagLFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.45)
    set_gtk_property!(gridLeadlagLFrameUp, :label_xalign, 0.50)
    set_gtk_property!(gridLeadlagLFrameUp, :label_yalign, 0.00)

    gridLeadlagLFrameB = Frame("Output Data")
    set_gtk_property!(gridLeadlagLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLeadlagLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.50)
    set_gtk_property!(gridLeadlagLFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLeadlagLFrameB, :label_yalign, 0.00)

    gridLeadlagRFrameUp = Frame()
    set_gtk_property!(gridLeadlagRFrameUp, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLeadlagRFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.70)

    gridLeadlagRFrameB = Frame("Operational Amp")
    set_gtk_property!(gridLeadlagRFrameB, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLeadlagRFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.25)
    set_gtk_property!(gridLeadlagRFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLeadlagRFrameB, :label_yalign, 0.00)

    gridLeadlagLeft[1,1] = gridLeadlagLFrameUp
    gridLeadlagLeft[1,2] = gridLeadlagLFrameB

    gridLeadlagRight[1,1] = gridLeadlagRFrameUp
    gridLeadlagRight[1,2] = gridLeadlagRFrameB

    mainGridLeadlag[1,1] = gridLeadlagLeft
    mainGridLeadlag[2,1] = gridLeadlagRight

    push!(leadlagFrame, mainGridLeadlag)

    # Notebook for Plots in Lead-lag##############################################
    nbleadlag = Notebook()
    set_gtk_property!(nbleadlag, :tab_pos, 2)

    leadlagStepFrame = Frame()
    leadlagRampFrame = Frame()
    leadlagRootFrame = Frame()
    leadlagGraphicFrame = Frame()
    leadlagAmpOpFrame = Frame()

    push!(nbleadlag, leadlagStepFrame, "Step Response")
    push!(nbleadlag, leadlagRampFrame, "Ramp Response")
    push!(nbleadlag, leadlagRootFrame, "Root-locus")
    push!(nbleadlag, leadlagGraphicFrame, "Graphic Design")
    push!(nbleadlag, leadlagAmpOpFrame, "Amp Op Diagram")

    scrollleadlag = ScrolledWindow()
    push!(scrollleadlag,nbleadlag)
    push!(gridLeadlagRFrameUp, scrollleadlag)
    ##########End leadlag

    push!(nb, rootlocusFrame, "Root-locus Assistant")
    push!(nb, lagFrame, "Lag compensator")
    push!(nb, leadFrame, "Lead compensator")
    push!(nb, leadlagFrame, "Lead-lag compensator")

    #
    mainGrid[1,1] = mainToolbar
    mainGrid[1,2] = nb

    push!(mainWin,mainGrid)

    # Show program
    Gtk.showall(mainWin)
end
