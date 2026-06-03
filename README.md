# M3401 – Crew 

Crew is a mobile team-productivity and coordination application built using Flutter. This app is designed for students for the same set of tasks have to be assigned and tracked for everyone.

I built this project for  learning and  understanding Flutter app development, Only sake of learning.

## Motivation

Me and my few friends wants to start the DSA problem solving, and we want to monitor each other's progress also. So I got an idea to create this app. that's why it focuses on _same tasks_ instead of assigning tasks to members.

## Idea

- Assign the same tasks to all members of a group
- Let each member complete tasks independently
- Track progress of everyone

## App Structure

A **Crew** represents a group of users. each crew has a fixed structure with defined roles.

### Roles
|Captain|Member|
|-------|-------|
|creates the crew||
|assigns tasks to members|Completes assigned tasks|
|Updates the notice board|Marks tasks as done|

The creator of a crew automatically becomes the captain.

## Crew Types

### Private Crew
- Entry using secret crew code
- for small focused groups (e.g., DSA study groups)

### Public Crew
- Open to all users of app
- for large learning communities (e.g., spoken English practice groups)


## Task System

Captains can assign tasks to all members in a single action.

Each task contains:
- Short description
- External reference link
- Concepts or focus areas
- Time taken (entered by the member)

Members mark tasks as **DONE** after completion.


## Technology Stack

- Flutter
- Dart
- Firebase (Authentication, Database, Notifications)
- Material UI


## Author

Vitthal Shahaji Humbe | Kuron
B.Tech AIML Student
