# DateTime

![Latest version of the package][PackageVersion]
![Latest Elm version supported][ElmVersion]
![CircleCI][CircleCI-build]
![Status of direct dependencies][DependenciesStatus]
![License of the package][PackageLicense]

The 0.19 version of Elm introduced some [important changes][important-changes] in the Time API which is now split into a [separate package][elm-time].

The DateTime package was inspired because __date and time__ is a crucial part on our everyday lives and most of the projects we are working on rely heavily on the ___correct interpretation of both.___
This means that whenever we need to handle date or time we need to be sure that it is a ___valid___ __DateTime__. In order to guarantee the __validity of the DateTime__ but also create a solid package
we had to compromise on using [UTC][UTC-wiki] time.

This basically means that all the results that come from the [DateTime][DateTime-package] package are based on [UTC][UTC-wiki] and therefore the
___consumer should be the one that implements timezone specific solutions.___ That approach makes the DateTime package easier to use without
having the overhead of ___timezones___ or ___daylight saving___ and it also gave us the opportunity to focus on implementing generic DateTime
handling functionality instead of having to focus on timezone specific solutions.

The main goal of this package is to serve as an extension of [elm/time][elm-time] and to provide a [DateTime type][DateTime-DateTime] that is ___isomorphic___ to [Time.Posix][Time-Posix].
This basically means that __DateTime__ can be constructed by a [Time.Posix][Time-Posix] type and it can be converted back to [Time.Posix][Time-Posix] without losing any of it's integrity.

&nbsp;

## Constructing a [DateTime][DateTime-DateTime]

You can construct a [DateTime][DateTime-DateTime] in three different ways:

You can reliably create a [DateTime][DateTime-DateTime] either by providing a __Posix__ or by combining a [Calendar.Date][Calendar-Date] and a [Clock.Time][Clock-Time].

![Isomorphic DateTime construction](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DateTime/master/assets/Isomorphic-DateTime-Construction.png "Isomorphic DateTime construction")

&nbsp;

You can also ___attempt___ to construct a [DateTime][DateTime-DateTime] by providing its' constituent parts as raw data.

![RawParts to Maybe DateTime](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DateTime/master/assets/RawParts-DateTime-Construction.png "RawParts to Maybe DateTime")

&nbsp;

## Constructing a [Calendar.Date][Calendar-Date]

You can create a [Calendar.Date][Calendar-Date] by providing a __Posix__. We should note here though, that since the __Posix__ will contain the milliseconds that
form both a __date__ and a __time__, the [Calendar.Date][Calendar-Date] will ___drop all the time related information.___ If you were to transform a
[Calendar.Date][Calendar-Date] back to [Posix][Time-Posix], it would represent the given `Date` but ___it will always default on midnight hours___, which means that it
___may lose some of the information provided.___ We've decided that we will not allow a [Calendar.Date][Calendar-Date] to [Time.Posix][Time-Posix] conversion since its not an isomorphic one.
You can instead get the __milliseconds__ that represent the given `Date` and combine them with the milliseconds that represent a given `Time`.

![Posix to Calendar.Date](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DateTime/master/assets/Posix-to-Calendar.png "Posix to Calendar.Date")

You can ___attempt___ to construct a [Calendar.Date][Calendar-Date] by providing its' constituent parts as raw data as shown in the diagram below.

![RawParts to Calendar.Date](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DateTime/master/assets/RawParts-Calendar-Construction.png "RawParts to Calendar.Date")

There could be some cases where you don't really care about the time but you only need to store the Dates. Of course this will mean that if you try to convert a [Calendar.Date][Calendar-Date] to
a __Posix Time__ it will always __default to midnight hours (00:00:00.000).__ You can always combine a [Calendar.Date][Calendar-Date] with a [Clock.Time][Clock-Time] to construct a
[DateTime][DateTime-DateTime] in case you need to.

&nbsp;

## Constructing a [Clock.Time][Clock-Time]

You can create a [Clock.Time][Clock-Time] by providing a __Posix__. We should note here though, that since the __Posix__ will contain the milliseconds that
form both a __date__ and a __time__, the [Clock.Time][Clock-Time] will ___drop all the date related information.___ If you were to transform a
[Clock.Time][Clock-Time] back to [Posix][Time-Posix], it would represent the given `Time` but ___it will always default on the Epoch date (1 Jan 1970)___, which means that it
___may lose some of the information provided.___ We've decided that we will not allow a [Clock.Time][Clock-Time] to [Time.Posix][Time-Posix] conversion since its not an isomorphic one.
You can instead get the __milliseconds__ that represent the given `Time` and combine them with the milliseconds that represent a given `Date`.


![Posix to Clock.Time](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DateTime/master/assets/Posix-to-Clock.png "Posix to Clock.Time")

You can ___attempt___ to construct a [Clock.Time][Clock-Time] by providing its' constituent parts as raw data as shown in the diagram below.

![RawParts to Clock.Time](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DateTime/master/assets/RawParts-Clock-Construction.png "RawParts to Clock.Time")

Building a timer app could be one of the cases where you don't really care about the [Calendar.Date][Calendar-Date] portion of [DateTime][DateTime-DateTime].
This would mean that you only need a [Clock.Time][Clock-Time] in order to keep track of the time. Be very careful though if you want to get a valid __Posix Time__
you would need to convert your [Clock.Time][Clock-Time] to a [DateTime][DateTime-DateTime] by using a [Calendar.Date][Calendar-Date] as well.


[important-changes]: https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md#modules-moved
[elm-time]: https://package.elm-lang.org/packages/elm/time/latest/
[UTC-wiki]: https://en.wikipedia.org/wiki/Coordinated_Universal_Time
[Time-Posix]: https://package.elm-lang.org/packages/elm/time/latest/Time#Posix

[DateTime-package]: https://package.elm-lang.org/packages/PanagiotisGeorgiadis/elm-datetime/latest/DateTime

[Calendar-Date]: https://package.elm-lang.org/packages/PanagiotisGeorgiadis/elm-datetime/latest/Calendar#Date
[Clock-Time]: https://package.elm-lang.org/packages/PanagiotisGeorgiadis/elm-datetime/latest/Clock#Time
[DateTime-DateTime]: https://package.elm-lang.org/packages/PanagiotisGeorgiadis/elm-datetime/latest/DateTime#DateTime

[CircleCI-build]: https://img.shields.io/circleci/project/github/PanagiotisGeorgiadis/Elm-DateTime.svg?style=flat

[PackageVersion]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datetime/version.svg
[ElmVersion]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datetime/elm-version.svg
[DependenciesStatus]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datetime/dependencies.svg
[PackageLicense]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datetime/license.svg
