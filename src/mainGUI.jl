# Created at Instituto Tecnológico de Orizaba
# Carolina Ayerim Bolaños Ruiz
# Mauricio Rivadeneyra Hernández
# Kelvyn Baruc Sánchez Sánchez
# Caros´ Dad
# Pinto

using Gtk.ShortNames, ControlSystems

# CSS Provider
global style_file = joinpath(dirname(Base.source_path()), "style.css")

# Icons path
global ico1 = joinpath(dirname(Base.source_path()), "icons\\icon_new.ico")
global ico2 = joinpath(dirname(Base.source_path()), "icons\\icon_close.ico")
global ico3 = joinpath(dirname(Base.source_path()), "icons\\icon_pdf.ico")


function LLAGUI()
    # Environmental variable to allow Windows decorations
    ENV["GTK_CSD"] = 0

    # Style for CSS
    global provider = CssProviderLeaf(filename = style_file)

    # Measurement of screen-size to allow compatibility to all screen devices
    global w, h = screen_size()

    # main Window
    mainWin = Window()
    set_gtk_property!(mainWin, :title, "FeedForAsisst v0.1.10")
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

    closeTB = ToolButton("gtk-close")
    imgcloseTB = Image()
    set_gtk_property!(imgcloseTB, :file, ico2)
    set_gtk_property!(closeTB, :icon_widget, imgcloseTB)
    set_gtk_property!(closeTB, :label, "Close")
    set_gtk_property!(closeTB, :tooltip_markup, "Close program")
    signal_connect(closeTB, :clicked) do widget
        destroy(mainWin)
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
    set_gtk_property!(mainGridRoot, :raw_homogeneous, false)
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

    gridRootLFrameB = Frame("Output Data")
    set_gtk_property!(gridRootLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridRootLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.50)
    set_gtk_property!(gridRootLFrameB, :label_xalign, 0.50)
    set_gtk_property!(gridRootLFrameB, :label_yalign, 0.00)

    gridRootRFrameUp = Frame()
    set_gtk_property!(gridRootRFrameUp, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridRootRFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.70)

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

    push!(rootlocusFrame, mainGridRoot)

    # Notebook for Plots in Root-locus #########################################
    nbRoot = Notebook()
    set_gtk_property!(nbRoot, :tab_pos, 2)

    rootStepFrame = Frame()
    rootRampFrame = Frame()
    rootRootFrame = Frame()

    push!(nbRoot, rootStepFrame, "Step Response")
    push!(nbRoot, rootRampFrame, "Ramp Response")
    push!(nbRoot, rootRootFrame, "Root-locus")

    push!(gridRootRFrameUp, nbRoot)
    # End of root-locus assistant ##############################################

    # Lag assistant #####################################################
    lagFrame = Frame()

    mainGridLag = Grid()
    set_gtk_property!(mainGridLag, :column_homogeneous, false)
    set_gtk_property!(mainGridLag, :raw_homogeneous, false)
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

    gridLagLFrameB = Frame("Output Data")
    set_gtk_property!(gridLagLFrameB, :width_request, (w*0.6)*0.4)
    set_gtk_property!(gridLagLFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.50)
    set_gtk_property!(gridLagLFrameB, :label_xalign, 0.50)

    gridLagRFrameUp = Frame("Plots")
    set_gtk_property!(gridLagRFrameUp, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLagRFrameUp, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.70)
    set_gtk_property!(gridLagRFrameUp, :label_xalign, 0.50)

    gridLagRFrameB = Frame("Operational Amp")
    set_gtk_property!(gridLagRFrameB, :width_request, (w*0.6)*0.57)
    set_gtk_property!(gridLagRFrameB, :height_request, ((h*0.75)-((h * 0.75) * 0.09))*0.25)
    set_gtk_property!(gridLagRFrameB, :label_xalign, 0.50)

    gridLagLeft[1,1] = gridLagLFrameUp
    gridLagLeft[1,2] = gridLagLFrameB

    gridLagRight[1,1] = gridLagRFrameUp
    gridLagRight[1,2] = gridLagRFrameB

    mainGridLag[1,1] = gridLagLeft
    mainGridLag[2,1] = gridLagRight

    push!(lagFrame, mainGridLag)

    # End of root-locus assistant ##############################################






#################################################
    leadFrame = Frame()
    leadlagFrame = Frame()

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
