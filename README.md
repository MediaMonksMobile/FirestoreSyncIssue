# Firestore Sync Example App

This is to isolate Firestore's bugs with limited queries on subcollections. 

**Update:**

The main issue (reported here: https://github.com/firebase/firebase-ios-sdk/issues/1548) appears to be fixed. 

The second issue (see below) seems to be a known one but is not fixed yet, but we use this example to demonstrate it as well.

**Update 2:**

The second issue has been fixed. See https://github.com/firebase/firebase-ios-sdk/issues/1591.

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

As mentioned above, this seems to be fixed. See The Second Issue below.

- Make sure you have more than 5 documents in the list (tap "Get More Cookies" button to generate some).

- Start deleting random documents one by one. (You will notice that the list briefly jumps after removal of every item. This is NOT the main issue, see the Second Issue below. Keep deleting.)

- At some point you'll notice that items begin disappearing on their own eventually giving you an empty list. 

- In case the app is restarted, then the list still will be empty.

- Checking the subcollection in the console reveals that only the documents manually deleted have actually disappeared. The other documents are still there, but are not visible in the app.

- If you add new documents, then they'll appear in the list. Repeating the steps repeats the problem again.

The video of one such sessions can be found [here](./Session.mp4).

## The Second Issue

- Make sure you have have documents in the list (tap "Get More Cookies" button to generate some).

- Delete any document. Note that the list jumps briefly during the process. This is is issue. 

(See another video [here](./Session2.mp4)).

The console reveals that the query listener receives 3 updates:

    2018-07-25 16:30:45.613118+0200 FirestoreSyncIssue[58674:20831755] Deleting the document for 'Stroopwafel #9'
    2018-07-25 16:30:45.623390+0200 FirestoreSyncIssue[58674:20831755] Top 5 collection snapshot changed: 4 document(s) (from cache: 0)
    2018-07-25 16:30:45.623700+0200 FirestoreSyncIssue[58674:20831755] Items: (
        "Coconut macaroon #10",
        "Oreo #7",
        "Charcoal biscuit #10",
        "Cream cracker #9"
    )
    2018-07-25 16:30:45.978800+0200 FirestoreSyncIssue[58674:20831755] Deleted 'Stroopwafel #9'
    2018-07-25 16:30:46.343615+0200 FirestoreSyncIssue[58674:20831755] Top 5 collection snapshot changed: 5 document(s) (from cache: 1)
    2018-07-25 16:30:46.343926+0200 FirestoreSyncIssue[58674:20831755] Items: (
        "Coconut macaroon #10",
        "Stroopwafel #9",
        "Oreo #7",
        "Charcoal biscuit #10",
        "Cream cracker #9"
    )
    2018-07-25 16:30:46.474503+0200 FirestoreSyncIssue[58674:20831755] Top 5 collection snapshot changed: 5 document(s) (from cache: 0)
    2018-07-25 16:30:46.474843+0200 FirestoreSyncIssue[58674:20831755] Items: (
        "Coconut macaroon #10",
        "Oreo #7",
        "Charcoal biscuit #10",
        "Cream cracker #9",
        "Charcoal biscuit #8"
    )

In the first update the item appears to be immediatelly deleted, which is expected. Then we get an update from cache where this item is back and a bit later we see the snapshot properly updated with the deleted item being gone finally and a new one appearing at the 5th place.

We tried to work this problem around by ignoring snapshots from the cache in case we had non-cached data before, however this does not work in all the cases, sometimes a cached update is all we get.

---
