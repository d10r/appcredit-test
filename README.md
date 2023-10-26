Problem:
```
tx1: A streams fr1 to SuperApp
  callback: SuperApp streams fr1 to Z
tx2: B streams fr2 to SuperApp
  callback: SuperApp streams fr2 (updateFlow or deleteFlow+createFlow) to Z
            SuperApp closes stream from A to SuperApp
```

The final net flowrate is 0.
But the final `deleteFlow` reverts with `APP_RULE_NO_CRITICAL_RECEIVER_ACCOUNT`.

Only if the flowrate for stream SuperApp -> Z in tx2 doesn't exceed the previous flowrate, does it succeeed (* it can slightly exceed it, likely by the remainder app credit left from tx1 due to clipping).

Run with `forge test -vv`
