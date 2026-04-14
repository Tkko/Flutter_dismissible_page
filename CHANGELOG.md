## 1.1.0
- BREAKING: Introduces custom ScrollController with ScrollPosition to delegate `applyUserOffset` to updating the dimissible page offset/extent, based on various conditions and gesutes, which fixed all sort of issues when having scrollable content inside the dimissible page. Now you MUST pass the `scrollController` from the `builder` to your scrollable widgets, otherwise it wouldn't work.
- BREAKING: Introduces new `interactionMode` that supports `scroll` and `gesture` modes. Note: multi-axis dimsissible page with scrollable content inside work perfectly AND, if `interactionMode` is `scroll`, then combines both `scroll` and `gesture` mode, because otherwise scrollable widget alone can't deliver multi-axis updates, whereas `scrollController` prevent the scrollable content from scrolling when the dragging/dismissing is happening. But there still can be bugs with multi-axis with scrollable content inside, it is generally not recommended to use multi-axis with scrollable inside.
- Now in the scrollable widget inside dismissible page the dimsissing would not go from up to down when started dragging, so that when reversing the direction, let's say was dragging down, then drag up, when the offset goes to it's initial value(0) it starts scrolling the list and not continues dragging.
- Fixes issues: [Issue #1](https://github.com/Tkko/Flutter_dismissible_page/issues/14), [Issue #2](https://github.com/Tkko/Flutter_dismissible_page/issues/36)
- FIX: In single-axis scroll mode, reversing drag direction now programmatically ends dismiss drag at origin for truly scrollable content, so the remaining delta is routed to inner scrolling instead of leaking into dismiss offset.
- FIX: Removes tiny delta leakage to `_dragExtent` when users quickly reverse scroll direction during dismissal gesture handoff.
- FIX: In single-axis `scroll` interaction mode, when content is smaller than the viewport (not actually scrollable), dismissal now falls back to gesture handling so empty areas still receive drag-to-dismiss interactions.
- Improved: Keeps non-scrollable behavior unchanged (cross-over drag remains as expected for full-screen/non-scrollable pages).
- FIX: In multi-axis `_shouldConsumeUserOffset` is true when `dragOffset` not equals to 0, regardless of the `ineractionMode`, previoisly was working only if the mode was `gesture`, which lead to various small visual bugs with scrollable. Note: this fix makes that until the dragging released it can be dismissed in all directions, to be more precise don't expect it to work as in single-mode when scrolling down, then up and it continue scrolling the list, instead of dragging the page up(at the bottom). So there are trade-offs, but it is generally a better choice I'd say, if you really want to have multi-axis dimissial with scrollable inside.

## 1.0.3
- Fixed unexpected behavior of dismissing the page when user is scrolling the opposite direction [Issue](https://github.com/Tkko/Flutter_dismissible_page/issues/14#issuecomment-1599097053)

## 1.0.2
- Merged Fix mixins of _MultiAxisDismissiblePageState (PR)[https://github.com/Tkko/Flutter_dismissible_page/pull/25]
- Fixed main example
- Fixed package title in README.md
- Bumped version

## 1.0.1
- Nothing special, the formatter, messed up the readme, so I had to update it

## 1.0.0
- From now on you can use Dismissible page with scrollable content
- Added pub screenshots


## 0.7.3
- Implemented [onDragUpdate](https://github.com/Tkko/Flutter_dismissible_page/issues/15) 


## 0.7.2
- rootNavigator [PR](https://github.com/Tkko/Flutter_dismissible_page/pull/13)


## 0.7.1
- Fixed disabled Dismissible
- Improved readme


## 0.7.0 -02/03/2022
- Added Multi direction dismiss
- Improved example
- Improved readme


## 0.6.5 -19/02/2022
- Removed media from pub
- Merged [PR 9](https://github.com/Tkko/Flutter_dismissible_page/pull/9)
    - Added
        | Property  | Default |
        | ------------- | ------------- |
        | transitionDuration  |  Duration(milliseconds: 250) |
        | reverseTransitionDuration  |  Duration(milliseconds: 250) |
- Improved Example App


## 0.6.4 -27/10/2021
Closed issues:

 - [Disabled background](https://github.com/Tkko/Flutter_dismissible_page/issues/5#issue-964593191)
 - [Animation speed](https://github.com/Tkko/Flutter_dismissible_page/issues/6#issue-1037569113)


🔥🚀
Added
| Property  | Default |
| ------------- | ------------- |
| dragSensitivity  |  Duration(milliseconds: 500) |

## 0.6.3 -29/05/2021
🔥🚀
Quick fix


## 0.6.2 -29/05/2021
🔥🚀
Migrated to Null safety


0.6.1 -14/02/2021
🔥🚀
Added
| Property  | Default |
| ------------- | ------------- |
| reverseDuration  |  Duration(milliseconds: 500) |


## 0.6.0 -14/02/2021
🔥🚀
Added
| Property  | Default |
| ------------- | ------------- |
| minScale  | .85 |
| minRadius  | 7 |
| maxRadius  | 30 |
| maxTransformValue  | .4 |


## 0.5.5 -14/02/2021
🔥🚀
Removed unused code
Added Demos

## 0.5.0 -14/02/2021
🔥🚀
Initial version of package. base functionality works properly