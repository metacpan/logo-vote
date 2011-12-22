# Getting started

## Register OAuth application at Github

https://github.com/account/applications/new

For developing locally, you set something like:

`URL: http://localhost:3000
Callback URL: http://localhost:3000`

## Set up config

Add to `metacpan_contest_vote_local.conf` the values you got
from Github while registering the application:

```text
<github>
    client_id c0ff33
    client_secret m0r3c0ff33
</github>
```