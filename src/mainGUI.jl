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

function LLAGUI()
    # Environmental variable to allow Windows decorations
    ENV["GTK_CSD"] = 0

    # Style for CSS
    global provider = CssProviderLeaf(filename = style_file)

    # Measurement of screen-size to allow compatibility to all screen devices
    global w, h = screen_size()

    # main Window
    mainWin = Window()
    set_gtk_property!(mainWin, :title, "FeedForAsisst v0.0.1")
    set_gtk_property!(mainWin, :width_request, w*0.6)
    set_gtk_property!(mainWin, :height_request, h*0.75)
    set_gtk_property!(mainWin, :window_position, 3)
    set_gtk_property!(mainWin, :resizable, false)

    # Apply style to mainWin from CSS
    set_gtk_property!(mainWin, :name, "mainWin")
    screen = Gtk.GAccessor.style_context(mainWin)
    push!(screen, StyleProvider(provider), 600)

    # Grid to allocate widgets
    mainGrid = Grid()

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

    mainToolbar = Toolbar()
    set_gtk_property!(mainToolbar, :height_request, (h * 0.75) * 0.09)
    set_gtk_property!(mainToolbar, :toolbar_style, 2)
    push!(mainToolbar, newTB)
    push!(mainToolbar, closeTB)


    # main Notebook
    nb = Notebook()
    set_gtk_property!(nb, :tab_pos, 3)
    set_gtk_property!(nb, :name, "nb")
    screen = Gtk.GAccessor.style_context(nb)
    push!(screen, StyleProvider(provider), 600)

    # Frames for main Notebook
    tdaFrame = Frame()
    set_gtk_property!(tdaFrame, :width_request, (w*0.6))
    set_gtk_property!(tdaFrame, :height_request, (h*0.75)-((h * 0.75) * 0.09))

    lagFrame = Frame()
    leadFrame = Frame()
    leadlagFrame = Frame()

    push!(nb, tdaFrame, "Time-domain Assitant")
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
