# Firestore Sync Example App

This is an example app exposing the bug with synchronization of limited queries on subcollections.

An example Firestore project was set up for this example (`firestore-sync-issue-example`) and the corresponding GoogleService-Info.plist is in the project already.

## Description

The example app is using the following subcollection:

`/examples/$instanceUUID/cookies`

Where `$instanceUUID` is a UUID which is generated for every installation of the app so multiple tests do not collide with each other. It is logged on startup every time, e.g.:

    Example app instance ID: 950774D1-01E4-4260-8F6E-C1612FAAD790

Two simple queries are set up on the above subcollection:

- One queries for the first 5 elements of the subcollection.
- And another queries for a single top element.

## Example Session

The video of one of the sessions with the app can be found in `Session 2.mp4`.

---
