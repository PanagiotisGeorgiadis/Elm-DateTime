# DateTime ![alt text][Elm-Package-Version] ![alt text][CircleCI-build] [![License: MIT][Licence-Icon]](https://opensource.org/licenses/MIT)

The 0.19 version of Elm introduced some [important changes][important-changes] in the Time API which is now split into a [separate package][elm-time].

The DateTime package was inspired because __date and time__ is a crucial part on our everyday lives and most of the products we are working on rely heavily on the ___correct interpretation of both.___
This means that whenever we need to handle date or time we need to be sure that it is a ___valid___ __DateTime__. In order to guarantee the __validity of the DateTime__ but also create a solid package
we had to compromise on using [UTC][UTC-wiki] time.

This basically means that all the results that come from the DateTime package are based on [UTC][UTC-wiki] and therefore the ___consumer should be the one that implements timezone specific solutions.___
That approach makes the DateTime package easier to use without having the overhead of ___timezones___ or ___daylight saving___ and it also gave us the opportunity to focus on implementing generic
DateTime handling functionality instead of having to focus on timezone specific solutions.

The main goal of this package is to serve as an extension of [elm/time][elm-time] and to provide ___isomorphism___ between [Time.Posix][Time-Posix] and __DateTime__.
This basically means that __DateTime__ can be constructed by a [Time.Posix][Time-Posix] type and it can be converted back to [Time.Posix][Time-Posix] without losing any of it's integrity.

&nbsp;

## Constructing a [DateTime][DateTime-url]

You can construct a [DateTime][DateTime-url] in 2 different ways. Either by providing a __Posix Time__ or by combining a [Calendar.Date][Calendar-Date] and a [Clock.Time][Clock-Time].

![Isomorphic DateTime construction](https://github.com/PanagiotisGeorgiadis/elm-datetime/blob/master/assets/Isomorphic-DateTime-Construction.png "Isomorphic DateTime construction")

&nbsp;

You can also ___attempt___ to construct a [DateTime][DateTime-url] by providing its' constituent parts as raw data.

![RawParts to Maybe DateTime](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/assets/RawParts-DateTime-Construction.png "RawParts to Maybe DateTime")

&nbsp;

## Constructing a [Calendar.Date][Calendar-Date]

You can ___attempt___ to construct a [Calendar.Date][Calendar-Date] by providing its' constituent parts as raw data as shown in the diagram below.

![RawParts to Calendar.Date](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/assets/RawParts-Calendar-Construction.png "RawParts to Calendar.Date")

There could be some cases where you don't really care about the time but you only need to store the Dates. Of course this will mean that if you try to convert a [Calendar.Date][Calendar-Date] to
a __Posix Time__ it will always __default to 00:00 hours.__ You can always use this along with a [Clock.Time][Clock-Time] to construct a [DateTime][DateTime-url] in case you need to.

&nbsp;

## Constructing a [Clock.Time][Clock-Time]

You can ___attempt___ to construct a [Clock.Time][Clock-Time] by providing its' constituent parts as raw data as shown in the diagram below.

![RawParts to Clock.Time](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/assets/RawParts-Clock-Construction.png "RawParts to Clock.Time")

Building a timer app could be one of the cases where you don't really care about the [Calendar.Date][Calendar-Date] portion of [DateTime][DateTime-url].
This would mean that you only need a [Clock.Time][Clock-Time] in order to keep track of the time. Be very careful though if you want to get a valid __Posix Time__
you would need to convert your [Clock.Time][Clock-Time] to a [DateTime][DateTime-url] by using a [Calendar.Date][Calendar-Date] as well.

---
### Running the package locally
```
npm install
npm run elm-make
npm test
```

[important-changes]: https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md#modules-moved
[elm-time]: https://package.elm-lang.org/packages/elm/time/latest/
[UTC-wiki]: https://en.wikipedia.org/wiki/Coordinated_Universal_Time
[Time-Posix]: https://package.elm-lang.org/packages/elm/time/latest/Time#Posix
[Calendar-Date]: https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/src/DateTime/Calendar/Internal.elm#L58
[Clock-Time]: https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/src/DateTime/Clock/Internal.elm#L45
[DateTime-url]: https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/src/DateTime/DateTime/Internal.elm#L57
[CircleCI-build]: https://img.shields.io/circleci/project/github/PanagiotisGeorgiadis/Elm-DateTime.svg?style=flat
[Licence-Icon]: https://img.shields.io/badge/License-MIT-blue.svg
[Elm-Package-Version]: https://img.shields.io/elm-package/v/PanagiotisGeorgiadis/Elm-datetime.svg?style=flat
