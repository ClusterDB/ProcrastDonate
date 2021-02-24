
# ProcrastDonate data model:

This section outlines the schemas of the various collections to be stored in MongoDB. See the [REST API
Endpoints](#rest-api-endpoints) section for information on how the data is to be accessed via the client(s).

## `user` collection
Stores user account information, such as name, email, password, etc.

```
{ 
    _id: <ObjectID>,
    username: <string>,
    displayName: <string>,
    email: <string>,
    password: <hashed string>,
    bio: <string>,
    friends: [<ObjectID>],
}
```

## `friend_request` collection
Stores all the outstanding friend requests.

```
{
    _id: <ObjectID>,
    requester: <ObjectID>,
    recipient: <ObjectID>,
    requestDate: <datetime>,
}
```

## `task` collection
Stores all tasks, including completed tasks.

```
{ 
    _id: <ObjectID>,
    title: <string>,
    user: <ObjectID>,
    descriptionText: <string>,
    startDate: <datetime>,
    completedDate: <datetime or null>,
    cancelDate: <datetime or null>,
    renewals: [
      { 
        date: <datetime>, 
        oldDeadline: <datetime>,
        newDeadline: <datetime>,
        oldAmount: <number>,
        newAmount: <number>,
        renewReason: <string>,
        paidOldAmount: <boolean>
      }
    ],
    deadlineDate: <datetime>,
    donationAmount: {
        amount: <positive integer>,
        currency: <string>
    },
    donateOnFailure: <boolean>,
    charity: <ObjectID>,
    tags: [<string>],
}
```
   
Notes:
  - **renewals**: each entry in this array is a record of a renewal. Upon failing to complete a task, a 
  user may opt to renew a task instead of simply letting it go away. Users may also renew a task before it hits the
  deadline to adjust the deadline or how much money they want to donate.
  - **cancelDate**: a user may cancel a task if they wish, avoiding any payment to charity.
  - **donateOnFailure**: a user may elect to flip the outcomes: when completing the task successfully, money is
  donated to charity / when the task is failed no donation is made. We should consider making this the default
  actually so as to avoid making donating to charity as a negative outcome.

## `charity` collection
Stores information about registered charities. In the future, this will also include any metadata required to
facilitate payments to them via stripe.

```
{ 
    _id: <ObjectID>,
    name: <string>,
    descriptionText: <string>,
    website: <string>,
}
```

## `sponsorship` collection 
Stores the metadata associated with a user sponsoring a task to be completed by another user.
   
```
{ 
    _id: <ObjectID>,
    task: <ObjectID>,
    sponsor: <ObjectID>,
    comment: <string>,
    donationAmount: {
        amount: <positive integer>,
        currency: <string>
    },
    startDate: <datetime>,
    cancelDate: <datetime or null>,
    settled: <boolean>,
}
```
   
## `event` collection 
Stores all the events that show up on users timelines. This will likely be populated via a change stream sitting on
its own thread.
   
```
{ 
    _id: <ObjectID>,
    user: <ObjectID>,
    date: <datetime>,
    eventType: <string>,
    comments: [ { author: <ObjectID>, message: <string> } ],
    ...
}
```
   
Depending on the eventType, the rest of the fields have the following forms:

### New Task (`new-task`)
Creation of a new task for the user.
```
{ 
    /* ... shared fields from above ... */
    task: <ObjectID> 
}
```

### Completed Task (`completed-task`)
The user completed a task successfully.
```
{ 
    /* ... shared fields from above ... */
    task: <ObjectID> 
}
```

### Renewed Task (`renewed-task`)
The user renewed a task.

```
{ 
    /* ... shared fields from above ... */
    task: <ObjectID>,
    oldDeadline: <datetime>,
    newDeadline: <datetime>,
    oldAmount: <amount>,
    newAmount: <amount>,
    renewReason: <string>,
}
```
   
### Failed Task (`failed-task`)
The user failed to complete a task before its deadline.
```
{ 
    /* ... shared fields from above ... */
    task: <ObjectID> 
}
```
   
### Canceled Task (`canceled-task`)
The user cancel led a task.

```
{ 
    /* ... shared fields from above ... */
    task: <ObjectID>,
    cancelReason: <string>
}
```
   
### Sponsored Task (`new-sponsorship`)
The user started sponsoring a task.
```
{ 
    /* ... shared fields from above ... */
    sponsorship: <ObjectID> 
}
```
   
### Updated Sponsorship (`updated-sponsorship`)
The user updated an existing sponsorship (e.g. increased donation amount).
```
{ 
    /* ... shared fields from above ... */
    sponsorship: <ObjectID>,
    update: { /* TBD */ }
}
```
   
### Canceled Sponsorship (`canceled-sponsorship`)
The user Canceled an existing sponsorship.
```
{ 
    /* ... shared fields from above ... */
    sponsorship: <ObjectID>,
    cancelReason: <string>
}
```
   
### Sponsored Task Canceled (`sponsored-task-Canceled`)
A task which the user was sponsoring was Canceled.  
``` 
{ 
    /* ... shared fields from above ... */ 
    sponsorship: <ObjectID>
} 
```
   
### Sponsored Task Completed (`sponsored-task-completed`)
A task which the user was sponsoring was successfully completed.
```
{ 
    /* ... shared fields from above ... */
    sponsorship: <ObjectID> 
}
```

### Sponsored Task Failed (`sponsored-task-failed`)
A task which the user was sponsoring was not completed before the deadline.
```
{ 
    /* ... shared fields from above ... */
    sponsorship: <ObjectID> 
}
```

# REST API Endpoints

This section outlines the various REST API Endpoints that can be used to implement a client for ProcrastDonate. This
section still needs to be fleshed out a bit more to include the exact structure / types of the output, as well as the
expected format of the input for the state-modifying requests.
  
## /users/\<username\>
- **GET**: Retrieves the profile information about the user (friends list, bio, name).
- **POST**: create a new user.
   
## /users/\<username\>/friends/\<username\>
- **GET**: retrieve activity involving both the user and the user's friend
- **DELETE**: delete the friendship or friendship request between <username> and <username>
- **POST**: create a new friend request

## /users/\<username\>/tasks

### GET
Retrieves the current list of tasks for a given user. Each task info includes an id, title, description, deadline,
donation recipient(s), and tag(s).

Parameters:
- **active-only**: if "t", then only return active tasks
- **limit**: number, the max number of tasks to return
- **sort-by**: "earliest-deadline" | "latest-start" (default) - return in order of nearest deadlines or most recent start date.
- **date-delimiter**: an ISO-8601 formatted date marking the latest possible start date or oldest possible deadline,
  depending on the value of `sort-by`. Used for pagination.

### POST

Creates a new task for the user. Body must contain an extended JSON object with the following form:

```
{
    "title": <string>,
    "descriptionText": <string>,
    "deadlineDate": <datetime>,
    "donationAmount": {
        "amount": <positive integer>,
        "currency": "USD", // TODO: support more currencies
    },
    donationOnFailure: <boolean>,
    charity: <ObjectID>,
    tags: [ <string> ],
}
```

## /users/\<username\>/sponsorships
### GET
Retrieves a list of sponsorships by the user. This will perform a `$lookup` to fill in the task instead of simply
returning its _id to reduce the network round trips.

Parameters:
- **active-only**: if "t", then only return active tasks
- **limit**: number, the max number of tasks to return
- **sort-by**: "earliest-deadline" | "latest-start" (default) - return in order of nearest deadlines or most recent start date.
- **date-delimiter**: an ISO-8601 formatted date marking the latest possible start date or oldest possible deadline,
  depending on the value of `sort-by`. Used for pagination.

### POST
Creates a new sponsorship for the given user. The body of the request must contain the task id being sponsored and the 
dollar amount at stake.

## /users/\<username\>/activity
Retrieves the timeline of recent activity by this user. This includes entries for any of the above event types
associated with the user.

Parameters:
- **limit**: number, the max number of tasks to return
- **date-before**: an ISO-8601 formatted date marking the latest possible event. Used for pagination.
- **friends**: if "t", then include the activity of the friends of the user.

## /tasks/\<task-id\>
- **GET**: Retrieves the information about an individual task.
- **PATCH**: Updates a given task. This can renew the task, cancel it, or modify one of its fields.
   
## /tasks/\<task-id\>/activity
Retrieves the activity information for a given task (creation, renewals, sponsorships)
