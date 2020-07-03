# Created at Instituto Tecnológico de Orizaba
# Carolina Ayerim Bolaños Ruiz
# Mauricio Rivadeneyra Hernández
# Kelvyn Baruc Sánchez Sánchez
# Eusebio Bolaños Reynoso
# Joaquín Pinto Espinoza

using Gtk.ShortNames, ControlSystems, Plots, SymPy
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

function LLAGUI()
    # Environmental variable to allow Windows decorations
    ENV["GTK_CSD"] = 0

    # Style for CSS
    global provider = CssProviderLeaf(filename = style_file)

    # Measurement of screen-size to allow compatibility to all screen devices
    global w, h = screen_size()

    # main Window
    mainWin = Window()
    set_gtk_property!(mainWin, :title, "LeadLagAssistant v0.1.0")
    set_gtk_property!(mainWin, :width_request, w*0.6)
    set_gtk_property!(mainWin, :height_request, h*0.75)
    set_gtk_property!(mainWin, :window_position, 3)
    set_gtk_property!(mainWin, :resizable, false)

    # Apply style to mainWin from CSS
    set_gtk_property!(mainWin, :name, "mainWin")
    screen = Gtk.GAccessor.style_context(mainWin)
    push!(screen, StyleProvider(provider), 600)

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
        empty!(imgRoot)
        empty!(imgRamp)
        empty!(imgRL)

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

        global rootNumTfData = get_gtk_property(rootNumTf, :text, String)
        global rootDenTfData = get_gtk_property(rootDenTf, :text, String)

        rootNumTfClean = split(rootNumTfData,",")
        global rootArrayNum = Array{Float64}(undef, length(rootNumTfClean))
        for i=1:length(rootNumTfClean)
            a = parse(Float64, rootNumTfClean[i])
            rootArrayNum[i] =  a
        end

        rootDenTfClean = split(rootDenTfData,",")
        global rootArrayDen = Array{Float64}(undef, length(rootDenTfClean))
        for i=1:length(rootDenTfClean)
            a = parse(Float64, rootDenTfClean[i])
            rootArrayDen[i] =  a
        end

        global Gopen = tf(rootArrayNum,rootArrayDen)
        global Gcerr = feedback(Gopen)

        # Step plot
        yRootStep, tRootStep, xRootStep = step(Gcerr)

        # Step ramp
        global Gramp = tf([1],[1,0,0])
        yRootRamp, tRootRamp, xRootRamp = step(Gcerr*Gramp)

        plotRootStep = plot(tRootStep, yRootStep,
            xlabel = "Time (sec)",
            ylabel = "Amplitude",
            framestyle = :box)

        plotRootRamp = plot(tRootRamp,yRootRamp,
            xlabel = "Time (sec)",
            ylabel = "Amplitude",
            framestyle = :box)

        plotRootRL =  rlocusplot(Gopen, framestyle=:box, title = "")

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

        # Overshoot
        PO=100*exp((-ζ[1]*pi)/(sqrt(1-ζ[1]^2)))

        listRoot[1,2] = ωn[1]
        listRoot[2,2] = ζ[1]
        listRoot[3,2] = string(ps)
        listRoot[4,2] = N(Kv)
        listRoot[7,2] = PO
    end

    exportTB = ToolButton("gtk-close")
    imgexportTB = Image()
    set_gtk_property!(imgexportTB, :file, ico3)
    set_gtk_property!(exportTB, :icon_widget, imgexportTB)
    set_gtk_property!(exportTB, :label, "Export")
    set_gtk_property!(exportTB, :tooltip_markup, "Export to .pdf file")
    signal_connect(exportTB, :clicked) do widget

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
    nb = Notebook()
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
    set_gtk_property!(gridRootLFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.45)
    set_gtk_property!(gridRootLFrameUp, :label_xalign, 0.50)
    set_gtk_property!(gridRootLFrameUp, :label_yalign, 0.00)

    # TF, List and table for input data
    gridRootLFUp = Grid()
    set_gtk_property!(gridRootLFUp, :row_spacing, 10)

    # entry for TF

    rootNumTf = Entry()
    rootDenTf = Entry()

    gRootLFUpTF = Frame()
    set_gtk_property!(gRootLFUpTF, :label_xalign, 0.50)
    set_gtk_property!(gRootLFUpTF, :label_yalign, 0.00)
    set_gtk_property!(gRootLFUpTF, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gRootLFUpTF, :height_request, 0.35*((h*0.75)-((h * 0.75) * 0.09))*0.50)

    gridRootLFUp[1,1] = rootNumTf
    gridRootLFUp[1,2] = rootDenTf
    gridRootLFUp[1,3] = gRootLFUpTF

    push!(gridRootLFrameUp, gridRootLFUp)

    gridRootLFrameB = Frame("Output Data")
    set_gtk_property!(gridRootLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridRootLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.50)
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

    gridRootLeft[1,1] = gridRootLFrameUp
    gridRootLeft[1,2] = gridRootLFrameB

    gridRootRight[1,1] = gridRootRFrameUp
    gridRootRight[1,2] = gridRootRFrameB

    mainGridRoot[1,1] = gridRootLeft
    mainGridRoot[2,1] = gridRootRight

    # TF, List and table for input data
    gridRootLFB = Grid()
    set_gtk_property!(gridRootLFB, :row_spacing, 10)

    gRootLFBTF = Frame()
    set_gtk_property!(gRootLFBTF, :label_xalign, 0.50)
    set_gtk_property!(gRootLFBTF, :label_yalign, 0.00)
    set_gtk_property!(gRootLFBTF, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gRootLFBTF, :height_request, 0.35*((h*0.75)-((h * 0.75) * 0.09))*0.50)

    global listRoot = ListStore(String, String)

    push!(listRoot,("ωn","unsolved"))
    push!(listRoot,("ζ","unsolved"))
    push!(listRoot,("Poles", "unsolved"))
    push!(listRoot,("Kv", "unsolved"))
    push!(listRoot,("Rise Time", "unsolved"))
    push!(listRoot,("Peak Time", "unsolved"))
    push!(listRoot,("Overshoot (%)", "unsolved"))
    push!(listRoot,("Settling Time", "unsolved"))

    treeRoot = TreeView(TreeModel(listRoot))
    rowTxt = CellRendererText()

    c1Root = TreeViewColumn("Parameter", rowTxt, Dict([("text",0)]))
    c2Root = TreeViewColumn("Value", rowTxt, Dict([("text",1)]))

    Gtk.GAccessor.resizable(c1Root, true)
    Gtk.GAccessor.resizable(c2Root, true)

    push!(treeRoot, c1Root, c2Root)

    rootODScrollWin = ScrolledWindow()
    set_gtk_property!(rootODScrollWin, :name, "rootODScrollWin")
    set_gtk_property!(rootODScrollWin, :height_request, 0.55*((h*0.75)-((h * 0.75) * 0.09))*0.50)
    screen = Gtk.GAccessor.style_context(rootODScrollWin)
    push!(screen, StyleProvider(provider), 600)

    push!(rootODScrollWin,treeRoot)

    gridRootLFB[1,1] = gRootLFBTF
    gridRootLFB[1,2] = rootODScrollWin

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
    set_gtk_property!(gridLagLFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.45)
    set_gtk_property!(gridLagLFrameUp, :label_xalign, 0.50)
    set_gtk_property!(gridLagLFrameUp, :label_yalign, 0.00)

    gridLagLFrameB = Frame("Output Data")
    set_gtk_property!(gridLagLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLagLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.50)
    set_gtk_property!(gridLagLFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLagLFrameB, :label_yalign, 0.00)

    gridLagRFrameUp = Frame()
    set_gtk_property!(gridLagRFrameUp, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLagRFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.70)
    set_gtk_property!(gridLagRFrameUp, :label_xalign, 0.50)

    gridLagRFrameB = Frame("Operational Amp")
    set_gtk_property!(gridLagRFrameB, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLagRFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.25)
    set_gtk_property!(gridLagRFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridLagRFrameB, :label_yalign, 0.00)

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
