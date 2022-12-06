#! /bin/sh

set -e
set +x

# env validation
[ -n "$MAX_SLOTS" ] && [ "$MAX_SLOTS" -eq "$MAX_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Env \$MAX_SLOTS ($MAX_SLOTS) is not a number"
  exit 1
fi
if [ "$MAX_SLOTS" -le 0 ]; then
  echo "Env \$MAX_SLOTS ($MAX_SLOTS) must be greater than 0"
  exit 1
fi
[ -n "$WORKER_SLOTS" ] && [ "$WORKER_SLOTS" -eq "$WORKER_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Env \$WORKER_SLOTS ($WORKER_SLOTS) is not a number"
  exit 1
fi
if [ "$WORKER_SLOTS" -le 0 ]; then
  echo "Env \$WORKER_SLOTS ($WORKER_SLOTS) must be greater than 0"
  exit 1
fi
[ -n "$MIN_FREE_SLOTS" ] && [ "$MIN_FREE_SLOTS" -eq "$MIN_FREE_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$MIN_FREE_SLOTS ($MIN_FREE_SLOTS) is not a number"
   exit 1
fi
if [ "$MIN_FREE_SLOTS" -lt 1 ]; then
  echo "Env \$MIN_FREE_SLOTS ($MIN_FREE_SLOTS) must be greater or equal 1"
  exit 1
fi
if [ -n "$WORKER_TAG" ]; then
  tmp="BUDDY_WORKERS_FREESLOTS_$WORKER_TAG"
  FREE_SLOTS=${!tmp}
  tmp="BUDDY_WORKERS_COUNT_$WORKER_TAG"
  WORKERS=${!tmp}
else
  FREE_SLOTS=$BUDDY_WORKERS_FREE_SLOTS_NOT_TAGGED
  WORKERS=$BUDDY_WORKERS_COUNT_NOT_TAGGED
fi
[ -n "$FREE_SLOTS" ] && [ "$FREE_SLOTS" -eq "$FREE_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$FREE_SLOTS ($FREE_SLOTS) is not a number. \$WORKER_TAG ($WORKER_TAG) has wrong value"
   exit 1
fi
[ -n "$WORKERS" ] && [ "$WORKERS" -eq "$WORKERS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$WORKERS ($WORKERS) is not a number. \$WORKER_TAG ($WORKER_TAG) has wrong value"
   exit 1
fi
echo "\$MAX_SLOTS: $MAX_SLOTS"
echo "\$FREE_SLOTS: $FREE_SLOTS"
echo "\$WORKER_SLOTS: $WORKER_SLOTS"
echo "\$MIN_FREE_SLOTS: $MIN_FREE_SLOTS"
echo "\$WORKERS: $WORKERS"
REAL_WORKER_SLOTS=$((WORKERS * WORKER_SLOTS))
REAL_FREE_SLOTS=$((FREE_SLOTS - MIN_FREE_SLOTS))
if [ "$FREE_SLOTS" -lt "$MIN_FREE_SLOTS" ] && [ "$REAL_WORKER_SLOTS" -lt "$MAX_SLOTS" ]; then
  export WORKERS=$((WORKERS + 1))
elif [ "$REAL_FREE_SLOTS" -ge "$WORKER_SLOTS" ] && [ "$WORKERS" -gt 0 ]; then
  export WORKERS=$((WORKERS - 1))
fi
echo "New \$WORKERS: $WORKERS"
export WORKERS="$WORKERS"