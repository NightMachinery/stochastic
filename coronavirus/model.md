
# A rough draft of a model for simulating disease spread

This is Fereidoon Mehri's for Dr. Mirsadeghi's simulation course at SUT, 2020 Spring.
As this draft is still incomplete, see the [latest version on my Github](https://github.com/batbone/stochastic/blob/master/coronavirus/model.md). That version is also auto-rendered by Github, so you don't need a Markdown renderer.

## Guide to reading this

I am sketching the structure of the model, and how they should be connected.

Some hints:
* `Function` is any read-only function.
* `Function!` is any function that possibly mutates the state.
* `[]` means array.
* `(,)` means tuple.
* `(int, string) -> int` describes the type of a function.
* I use docstring-style for comments, e.g.:

    "This is a comment!"

* `ASSERT` means some relation must hold.
* Search for `SOPH` to find ideas to make the model more sophisticated scattered in the current doc.

### Concepts

#### Rounds

The model proceeds in turns, which I think should be interpreted as hours. We can, of course, change the parameters of the model to make interpreting it as other intervals of time possible (#SOPH). Using longer intervals will make the computation costs lower, but the results will also be more coarsed.

#### World

The global state of the model. It consists of `Place`s and `Person`s.

#### Places

Each `Place` can have other `Place`s as subplaces. The `Place`'s 'self' is called its root. This can be best shown in a diagram:

![](pics/automaticpaste_2020-04-20-23-20-51.png)

#### Person

Each `Person` belongs to a `Place`. `Person`s do NOT move inside their parent `Place`; Movement is simulated by moving them from `Place` to `Place`. So a location that might at the real world be seen as one place, should oftentimes be modeled as several `Place`s. For example, a supermarket should have a `Place` for employees, and a `Place` for customers. 

#### Feedback

Some parts of the model need to get feedback (i.e., information) from other parts of the model. For example, each `Person` has a `SocialDistancingFactor` which shows how receptive that `Person` is to social distancing. But this also crucially depends on the, e.g., where they are and what the culture/politics is at that `Place`. So we use an information reporting function (which is read-only), named `getSocialDistancing`, which reads information from multiple sources (here both the `Person` and their `Place`), combines this in the appropriate manner, and returns the result.

Another example is the `possibly move` function list of `Person`; These ultimately determine where that Person will end up as the round ends. This list, by default, should contain a function with utmost priority (`0`)(So it runs before others) that will run its parent `Place` `moveChild(child) -> (Place | null)`. Each of these `moveChild` functions should also call their parent `Place`'s `moveChild`, if they themselves are not going to return a `Place` (i.e., if they want to return `null`).

#### Modeling infection

At the end of each round, each `Person`'s `changeState` function is called. This function looks at some properties of the current `Person`, their current state and their `Place`; Then it decides whether to change state and if so to what state. A simplistic implementation might do this:

```
changeState(self) -> DiseaseState
    if self.currentState == DiseaseState.neverInfected and rand() < self.getInfectionProbability()
        return DiseaseState.sick
    end
    return self.currentState
end

changeState!(self) -> void
    self.currentState = self.changeState()
end
```


### Ideas to make model more sophisticated

* Search for SOPH to find more ideas scattered in the current doc.
* Make `Place`s mobile in addition to people.

    This should work similarly to moving people :-?

* Make `Place`s able to be children to multiple parents at once.
* Make current state or an essential summary of it persist in a circular queue, so we can implement time delay. We can also persist every N (24?) rounds to lessen the memory pressure.

## Model's rough class structure (still woefully incomplete)

```
Place: class
    ParentPlace: Place | null
    Subplaces: (Place, DistributiveProbability: float)[]
        ASSERT sum(DistributiveProbability) <= 1

    Actions: (PartialOrder: int, Function!)[] "Functions with lower order numbers will run first."
        Start of round actions
            Possibilities:
                Change probability of accepting travelers as density of infection reaches a threshold.
                ...

        End of round actions

    Count of: int
        count of each state of people (e.g., sick, asymptomatic)(Doesn't include subplaces)

    Measure of: int ?
        size (Doesn't include subplaces, as usual)

    Information Reporting: Function
        all people: -> int
            "Sums all states of people"
        desnity: -> int
            "all people/size"

    receivesInfectivePressure: (Place, PressureWeight: int)[]

    Accept travel request and distribute it in subplaces (including self): Function
        "Accepts with probability pEnter and distribute to each subplace according to DistributiveProbability. (The remainder of probability from subplaces goes into the self.)"
        "SOPH: Discriminate based on properties of entrant people."
```

```
Person: class
    "SOPH: Note that this could also be an animal. :D We just need to set the correct parameters."
    parentPlace: Place
    Might have these properties:
        nationality: enum(countries) or string ?
        
    possiblyMove: (PartialOrder, Function!)[]
        "At the start of round, these will be called in the partial order given. If any of them returns a place, this person will move there and the other functions will not be called.
            If the current location should be returned, nothing will be done but the other functions won't be called.
            If 
    changeState!: Function! 
        "This function should be called for each person at the end of rounds."
    currentState: enum(Disease States)
```

### DiseaseState: enum

* immune

    "This means the `Person` is naturally immune to the disease."

* neverInfected
* asymptomatic
* mildlySick
* sick
* severelySick
* recovered
* dead

## Examples of using the model

### How to model different stuff

#### Travel restrictions

Lowering the probability of `Place` to allow entry.

#### Travel-loving people

Create a new class `TravelLovingPerson` that inherits from `Person` and adds this function to its `super`'s `possibly move`:
```
const travelProbability = 0.0001 # Note that this is going to be called every round, so even a low chance means a lot of moving.

(self) -> (Place | null):
    if rand() <= travelProbability
        return selectRandomPlace()
    else
        return null
    end
```

#### State forces non-nationals out

As `Person`'s `possibly move` calls the parent `Place`'s `moveChild`, the state simply needs to check each `Person`'s `Nationality` and return a `Place` for non-nationals (anywhere in the world, possibly that `Person`'s `hometown`), and `null` for nationals.

#### Short immunity

`Person`'s `changeState` function can insert a property `Person.lastRecoveryDate` when changing that `Person.currentState` to `recovered`. The same function can then check that property and after some time has passed, do the appropriate thing. For example, treat the `Person` as if they were `neverInfected`.

#### People gathering in central locations (e.g., markets)

We can add a new function, named `moveToMarket` to `possiblyMove` of `Person` that queries `Person.parentPlace.getMarkets()`, and moves to one of the returned `Place`s randomly with some probability, and stores the previous location (if not a transient location) into `Person.residentPlace`.

These market `Place`s could then force people out via `Place.moveChild` or we can check in `moveToMarket` whether we are in a market or not; And return to `Person.residentPlace` with high probability.

#### Self-quarintine

We can inherit from `Person` and disable (i.e., remove) all functions (except the mandatory one that checks `moveChild` of parent `Place`) from `Person.possiblyMove`. 

#### Having sick neighboring regions

We can add neighboring regions to `Place.receivesInfectivePressure` (with weights that model, e.g., contact), and then check those neighbors density of sick people (calibrated by their weight) in `Person.changeState`, and adjust the probabilities of getting sick accordingly.