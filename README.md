# inbox-replica
Recreated the expanding cells effect from `Inbox` by Google in Swift

# Goal
We are going to recreate the expanding cells effect from [Inbox](https://itunes.apple.com/sg/app/inbox-by-gmail-inbox-that/id905060486?mt=8) by Google. The final result looks something like this:

![preview](promo/gl-inbox-preview.gif)

# Observations
### The cell expands to fill the screen when tapped
The cell grows and the portions of the screen around it move outward from it (the part above moves upward and the portion below it moves downwards)

### The navigation bar stays around until it's pushed by the expanding cell
You would only notice this if you look really closely. You might have to watch this a few times.

### Swiping downward in the detail screen brings back the first screen
When scrolling downward brings in the navigation bar from the first screen. The status bar also changes color to be more easily visible. If released at a certain threshold the view controller dismisses and transitions back the the presenting one.

# Game Plan
We'll configure a UITableViewController to display rows of items. Next we'll create a modal transition that performs the expanding effect. Finally we'll have the detail view controller support some of the transition details when scrolling.
