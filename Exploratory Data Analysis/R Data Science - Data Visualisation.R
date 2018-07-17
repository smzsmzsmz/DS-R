### Data Analysis Process ###
# Import -> Tidy -> Transform
#                -> Visualise
#                -> Model -> Communicate

### Data Visualizsation ###
# http://r4ds.had.co.nz/data-visualisation.html

# Packages 
library(tidyverse)

### The mpg data frame
mpg
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + geom_point()
ggplot(data = mpg, mapping = aes(x = cyl, y = hwy)) + geom_point()



ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = class)) + geom_point()
# we could also map "class" to size, but mapping an unordered variable(class) to an ordered aesthetics (size) is not a good idea
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, size = class)) + geom_point()

# Or we could have mapped class to the alpha aesthetic, which controls the transparency of the points, or the shape of the points.
# Left
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))
# Right
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))
# You can also set the aesthetic properties of your geom manually. For example, we can make all of the points in our plot blue:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + geom_point(color = "blue",stroke = 4, fill = "yellow",size = 5, shape = 21)
# Conditional coloring
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = displ <5)) + geom_point()

### Facets 
## facet_warp: it splits plot across the categories 
# one variable
ggplot(data = mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_wrap( ~ class, nrow = 2)
# two varaible
ggplot(data = mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_wrap(drv ~ class, nrow = 3)

## facet_grid does a similar thing but instead of creating plots it creats different grids and plots each one
# two variable
ggplot(data = mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_grid(drv ~ cyl)

# one variable
# showing facet over columns
ggplot(data = mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_grid(. ~ cyl)

# showing facet over rows
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)


### Geometric objects
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_smooth(mapping = aes(x = displ, y = hwy, color =drv, linetype = drv))

# Group doesn't separates the coloring
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

# ggplot2 will automatically group the data for these geoms whenever you map an aesthetic to a discrete variable
ggplot(data = mpg) +
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv),
    show.legend = FALSE
  )

# To display multiple geoms in the same plot, add multiple geom functions to ggplot():
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# ggplot2 will treat these mappings as global mappings that apply to each geom in the graph. 
# In other words, this code will produce the same plot as the previous code:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

# You can use the same idea to specify different data for each layer. Here, our smooth line displays just a subset of the mpg dataset, the subcompact cars. The local data argument in geom_smooth() overrides the global data argument in ggplot() for that layer only.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)

### Statistical transformations
ggplot(data = diamonds) + geom_bar(mapping = aes(x = cut))
# diamond count data is not a variable in the dataset
# where does it come from?
# The algorithm used to calculate new values for a graph is called a stat, short for statistical transformation. The figure below describes how this process works with geom_bar().
# types of stat = arguments:
#   1. identity (use original data without statistical transformation)
demo <- tribble(
  ~cut,         ~freq,
  "Fair",       1610,
  "Good",       4906,
  "Very Good",  12082,
  "Premium",    13791,
  "Ideal",      21551
)

ggplot(data = demo) +
  geom_bar(mapping = aes(x = cut, y = freq), stat = "identity")
#   2. ..prop.. (overriding default mapping: display a bar chart of proportion rather than count)
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))
#   3. draw a greater attention to the statistical tranformation in our code. For example, use stat_summary()
#     summarises the y values for each unique x value, to drraw attention to the summary that you are computing
ggplot(data = diamonds) + 
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )
# note: ggplot2 provides over 20 stats for you to use. each stats is a function. you can look them up in ?stat_bin


### Position Adjustment
# You can colour a bar chart using either the colour aesthetic, or, more usefully, fill:
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))
# Note what happens if you map the fill aesthetic to another variable, like clarity: the bars are automatically stacked.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))
# The stacking is performed automatically by the position adjustment specified by the position argument.
# position arguments:
#   1. position = "identity" will place each object exactly where it falls in the context of the graph
#   2. position = "fill" works like stacking, but makes each set of stacked bars the same height. This makes it easier to compare proportions across groups.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")
#   3. position = "dodge" places overlapping objects directly beside one another. This makes it easier to compare individual values.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

# There's one other type of adjustment that's not useful for bar charts, but it can be very useful for scatterplots. 
# You can avoid this gridding by setting the position adjustment to "jitter". position = "jitter" adds a small amount of random noise to each point. This spreads the points out because no two points are likely to receive the same amount of random noise.
# position = "jitter" with scatterplot
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")