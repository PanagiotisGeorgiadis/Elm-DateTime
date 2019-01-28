#DateTime

The 0.19 version of Elm introduced some [important changes][important-changes] in the Time API which is now split into a [separate package][elm-time].

The DateTime package was inspired because __date and time__ is a crucial part on our everyday lives and most of the products we are working on rely heavily on the ___correct interpretation of both._ __
This means that whenever we need to handle date or time we need to be sure that it is a ___valid_ __ __DateTime__. In order to guarantee the __validity of the DateTime__ but also create a solid package
we had to make some sacrifices such as not using timezones.

This means that all the results that DateTime returns are based on [UTC][UTC-wiki] and therefore the consumer of the package should be the one that implements timezone specific solutions. This gives us the
freedom to work on generic solutions of DateTime handling instead of having timezone specific solutions.

The main goal of this package is to serve as an extension of [elm/time][elm-time] and to provide isomorphism between [Time.Posix][TimePosix] and __DateTime__. This basically means that __DateTime__ can be constructed by a
[Time.Posix][TimePosix] type and it can be converted back to [Time.Posix][TimePosix] without losing any of it's integrity.

![alt text](https://github.com/PanagiotisGeorgiadis/elm-datetime/blob/master/assets/Isomorphic-Construction.png "RawParts to Maybe DateTime")


You can also construct a DateTime by providing its' parts as raw data for convenience.

![alt text](https://github.com/PanagiotisGeorgiadis/elm-datetime/blob/master/assets/Raw-Parts-Construction.png "Isomorphic Time.Posix conversion to DateTime")


If you want to run locally the package checkout the repo and type the following:

1. If you already have Elm 0.19 version installed globally type:

2. If you don't have Elm 0.19 already installed globally:


[important-changes]: https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md#modules-moved
[elm-time]: https://package.elm-lang.org/packages/elm/time/latest/
[UTC-wiki]: https://en.wikipedia.org/wiki/Coordinated_Universal_Time
[TimePosix]: https://package.elm-lang.org/packages/elm/time/latest/Time#Posix
