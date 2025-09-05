# MSc-finalProject

## Overview

For my MSc Computer Science (Conversion) final project, I developed a cross-platform mobile application using Google's Flutter SDK over a 2-month period. The app enables climbers to log and track climbing routes, monitor their progress through interactive graphs and performance metrics, and delivers value to a partnered business via a built-in route feedback system.

## Technology Stack

- **Framework:** Flutter  
- **State Management:** Riverpod  
- **Authentication:** Firebase Authentication  
- **Database(s):**  
  - Firestore (NoSQL, cloud-based)  
  - SQLite / SQL (local persistent storage)  
- **Backend Services:** Firebase

## Demo

### Screenshots

#### Authentication

<p align="center">
  <img src="screenshots/Login page.png" alt="Login view" width="300"/>
  <img src="screenshots/Register page.png" alt="Register view" width="300"/>
  <img src="screenshots/Email verification page.png" alt="Email verification view" width="300"/>
</p>

#### Bouldering route view

<p align="center">
  <img src="screenshots/Bouldering route community grade.png" alt="Bouldering route community grade" width="300"/>
  <img src="screenshots/Bouldering route page.png" alt="Bouldering route view" width="300"/>
  <img src="screenshots/Review page.png" alt="Bouldering route review" width="300"/>
</p>

#### Bouldering wall list view

<p align="center">
  <img src="screenshots/Search result.png" alt="Bouldering wall search result" width="300"/>
  <img src="screenshots/Bouldering wall added.png" alt="Link bouldering wall" width="300"/>
  <img src="screenshots/Empty bouldering wall link page.png" alt="Empty bouldering wall list view" width="300"/>
</p>

#### Bouldering wall view

<p align="center">
  <img src="screenshots/Shimmer loading.png" alt="Skeleton screen" width="300"/>
  <img src="screenshots/Bouldering wall page.png" alt="Bouldering wall view" width="300"/>
  <img src="screenshots/No project library.png" alt="No project library" width="300"/>
</p>

#### Project library view

<p align="center">
  <img src="screenshots/Complete route.png" alt="Completed route" width="300"/>
  <img src="screenshots/Project library page.png" alt="Project library view" width="300"/>
  <img src="screenshots/No routes.png" alt="No routes" width="300"/>
</p>

#### Metrics

<p align="center">
  <img src="screenshots/Metrics page 1.png" alt="Metrics view 1" width="300"/>
  <img src="screenshots/Metrics page 2.png" alt="Metrics view 2" width="300"/>
  <img src="screenshots/Metrics page 3.png" alt="Metrics view 3" width="300"/>
</p>

#### Project library list view

<p align="center">
  <img src="screenshots/Create project library.png" alt="Create project library" width="300"/>
  <img src="screenshots/Created project library.png" alt="Created project library" width="300"/>
  <img src="screenshots/Delete project library.png" alt="Delete project library" width="300"/>
</p>

## Design

During the design phase, I utilised a wide range of methods and techniques to plan and structure the system.

- Established the functional and non-functional requirements of the app while using the MoSCoW prioritisation method to highlight the most important features. Where possible, the non-functional requirements were described quantitatively, making them easier to test.

- Created various UML diagrams including use case, activity, and class diagrams to describe the system. I also created an entity relationship diagram to model the database structure.

- From the entity relationship diagram, the database schemas were then formulated. Since the app uses both SQL and NoSQL database formats, these schemas had to be adapted. These changes accounted for the NoSQL document format of Google Firestore.

- Produced SQL `CREATE` statements for the local SQL database.

- Designed UX wireframes.

## Architecture

The app utilises a Model-View-ViewModel (MVVM) architecture. This helps to separate the concerns of the code, keeping it scalable, maintainable, and testable.

## Implementation

- Created an `ErrorState` class to help handle errors and exceptions effectively. Almost every function returns an `ErrorState`, alongside other potential values. This `ErrorState` class contains a `state` attribute, the value of which is a discrete `Enum`. These `Enum` values are specific to errors that occur within different aspects of the app. This enables the UI to be more reactive to user input, since various view elements change in accordance with the `state` value.

- Riverpod was utilised, providing many useful classes for state management. This package worked well with the MVVM architecture while also encouraging a dependency injection pattern for many of the custom classes. This made the code more testable by reducing tight coupling.

- Established good coding practices and naming conventions to keep the code easy to understand and maintain. Additionally, much of the code was encapsulated and re-used, taking advantage of the object-oriented programming paradigm.

## Evaluation

- Created both unit and integration tests to ensure that the app functioned as intended.

- Conducted performance profiling using the integration tests. This way, the tests were standardised and reproducible. These performance tests included frame build times, loading times, and memory usage.

- Designed and conducted UX tests to establish how intuitive and navigable the app was for test users.