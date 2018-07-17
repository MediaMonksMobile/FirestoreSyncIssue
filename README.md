# Firestore Sync Example App

This is to isolate Firestore's bug with synchronization of limited queries on subcollections.

## Requirements

A Firestore project was set up for this example (`firestore-sync-issue-example`) and the corresponding
`GoogleService-Info.plist` is in the project already, so you should be ready to go. This particular project is not
required to demo the issue, i.e. you can always put your own .plist file and still see the problem (assuming access rules are OK). An example dataset can be always generated from the app via "Get More Cookies" button.

Firebase pods are not in the repo, so do `pod install` first.

## Overview

The example uses the following subcollection:

`/examples/$instanceUUID/cookies`

Where `$instanceUUID` is a UUID generated for every installation of the app so multiple tests do not collide with each other. This is similar to per-user documents/subcollection in our actual app. The UUID is logged on startup, look for a line like this:

    Example app instance ID: 950774D1-01E4-4260-8F6E-C1612FAAD790

The app listens to two simple queries (see `ExampleViewController.m`):

1. Query A fetches the top 5 elements of the above subcollection. No sorting or filtering is done, only a limit to 5 is set. The document snapshots returned are then displayed as items in a table.

2. Query B fetches the first element of the same subcollection. No sorting or filtering again, only a limit to 1. The single item returned is then displayed in a title on top of the table with top 5 elements.

Documents corresponding to the items in the table can be deleted by swiping them left and tapping "Eat". This is needed to demonstrate the main issue.

In addition to the above whenever query B returns its single item then we listen to the changes in this item as well.
This is needed to demonstrate another issue, which is not isolated yet, i.e. this can be disabled now and won't affect
the demo.

When an item in the table is tapped, then the corresponding document is updated by toggling a single boolean field in it. This functionality is needed to demonstrate this not yet isolated issue as well and can be disabled too.

## The Main Issue

- Make sure you have more than 5 documents in the list (tap "Get More Cookies" button to generate some).

- Start deleting random documents one by one. (You will notice that the list briefly jumps after removal of every item. This is NOT the main issue but a well-known caching problem. Keep deleting.)

- At some point you'll notice that items begin disappearing on their own eventually giving you an empty list. 

- In case the app is restarted, then the list still will be empty.

- Checking the subcollection in the console reveals that only the documents manually deleted have actually disappeared. The other documents are still there, but are not visible in the app.

- If you add new documents, then they'll appear in the list. Repeating the steps repeats the problem again.

The video of one such sessions can be found [here](./Session\ 2.mp4).

---
