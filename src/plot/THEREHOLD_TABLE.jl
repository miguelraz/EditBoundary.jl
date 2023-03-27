
"""
plot_therehold_table(table_data, table_filepath, show_table)

Draw and save table for simplification thereholds of a contour
using PlotlyJS
"""
function plot_therehold_table(
            table_data::Matrix{String},
            table_filepath::String,
            show_table::Bool
         )

    # create table
    trace = table(
            rowwidth = fill(300,size(table_data,1)),
            # table header
            header = attr(
                  values = table_data[1,:].*["";" Pts";" Holes"],
                  align  = "left", 
                  line   = attr(color="#506784", width=1,),
                  font   = attr(family="Arial", size=15, color="white"),
                    fill_color = "#119DFF",
                  ),
            # table cells
            cells = attr(
                        values = table_data[2:end,:], 
                        align  = "left",
                        line   = attr(color="#506784", width=1),
                        font   = attr(family="Arial", size=15, color="blue"),        
                        fill_color = "white",
                    )
            )
    # draw table
    plt = PlotlyJS.plot(trace,Layout(width=600,height=900))
    # show table in screen
    show_table && display(plt)
    # save table in HTML filr
    savefig(plt, table_filepath*".html",format="html")
end